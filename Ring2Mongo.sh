#!/usr/bin/env python
#    Ring2Mongo uses PyEarthWorm to interface the EW Tracebuff Transport system to a Mongo Database.
#    Copyright (C) 2018  Francisco J Hernandez Ramirez
#    You may contact me at FJHernandez89@gmail.com, FHernandez@boritechsolutions.com
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>

import configparser, argparse
import numpy as np
from threading import Thread
from pymongo import MongoClient
import PyEW, time, json, datetime

def main():

  # Lets get the parameter file
  Config = configparser.ConfigParser()
  parser = argparse.ArgumentParser(description='This is a Ring2Mongo Module for Earthworm')

  parser.add_argument('-f', action="store", dest="ConfFile",   default="ring2mongo.d", type=str)

  results = parser.parse_args()
  Config.read(results.ConfFile)

  # Create and connect to a Mongo Server 
  url = str(Config.get('MongoDB', 'URL'))
  global client
  client = MongoClient(url)

  # Start an EW Module
  global Mod
  Mod = PyEW.EWModule(int(Config.get('Earthworm','RING_ID')), int(Config.get('Earthworm','MOD_ID')), \
                      int(Config.get('Earthworm','INST_ID')), int(Config.get('Earthworm','HB')), False)

  # Add input ring to Module as Output 0
  Mod.add_ring(int(Config.get('Earthworm','RING_ID')))

  # Add database output
  db = client[str(Config.get('MongoDB', 'DB'))]
  
  # Begin the run
  global run
  run = True

  while run:
        
    ## Check if EW module is ok
    if Mod.mod_sta() is False:
        break
    
    # Fetch a wave from Ring 0
    wave = Mod.get_wave(0)

    # if wave is empty return
    if wave != {}: 
    
        # Generate the time array
        time_array = np.zeros(wave['data'].size)
        time_skip = 1/wave['samprate']
        for i in range(0, wave['data'].size):
            time_array[i] = (wave['startt'] + (time_skip*i)) * 1000
        time_array = np.array(time_array, dtype='datetime64[ms]')

        # Change the time array from numpy to string, data from numpy to string
        # Could use: time_array.tolist() but nodejs is botching the ISOString input
        # Could use:  np.array2string(time_array, max_line_width=4096) but nodejs botches that too
        wave['times'] = time_array.astype('uint64').tolist()
        wave['data']= wave['data'].tolist()
        wave['time'] = datetime.datetime.utcnow()

        # Store in mongodb
        # if wave['station'] not in db.list_collection_names():
        db[wave['station']].ensure_index("time", expireAfterSeconds=3*60)
        wave_id = db[wave['station']].insert_one(wave).inserted_id

        #print(wave_id)

        #Sleep for a milisec (Yeah, it's needed otherwise it consumes too much CPU)
        time.sleep(0.001)

  print("ring2mongo has terminated")

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print("\nSTATUS: Stopping, you hit ctl+C. ")
        run = False
        Mod.goodbye()
        client.close()

