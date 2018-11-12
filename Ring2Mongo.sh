#!/usr/bin/env python
# Launcher Created by Erol Kalkan (USGS)

import configparser, argparse
import EWMod
import time

def main():
    
    # Lets get the parameter file
    Config = configparser.ConfigParser()
    parser = argparse.ArgumentParser(description='This is a Ring2Mongo Module for Earthworm')
    parser.add_argument('-f', action="store", dest="ConfFile",   default="ring2mongo.d", type=str)
    results = parser.parse_args()
    Config.read(results.ConfFile)

    RING_ID = int(Config['Earthworm']['RING_ID'])
    MOD_ID = int(Config['Earthworm']['MOD_ID'])
    INST_ID = int(Config['Earthworm']['INST_ID'])
    HB = int(Config['Earthworm']['HB'])

    URL = str(Config['MongoDB']['URL'])
    DB_ID = str(Config['MongoDB']['DB'])

    # Start an EW Module
    Mod = EWMod.Ring2Plot(RING_ID, MOD_ID, INST_ID, HB, URL, DB_ID)
    Mod.start()
    
    try:
        while True:
            time.sleep(1)

    except KeyboardInterrupt:
        print("\nSTATUS: Stopping, you hit ctl+C. ")
        Mod.stop()
        
if __name__ == '__main__':
    main()
