# RING2MONGO
Ring2Mongo uses PyEarthWorm to interface the EW Tracebuff Transport system to a Mongo Database.

## Installation & Configuration

This module already assumes [Earthworm](http://earthwormcentral.org), [Anaconda Python](https://www.anaconda.com/download/#linux), and [PyEarthworm](https://github.com/Boritech-Solutions/GSOF2RING) are already installed and configured and with the same bit-size (32 or 64 bits). A copy of it is included in the git repo as as submodule run: 

    git submodule init
    git submodule update
    
to fetch relevant files. To install and run:

1. Download or clone the repository in an place accessible to executables for the user that runs earthworm.
2. Move the compiled PyEW shared library into the gsof2ring folder.
3. In startstop_*.d add the command 'Gsof2Ring.sh' with the following parameters:
    1. -p: Configuration file
    
The resulting commandline command should look like this:

    Ring2Mongo.sh -p <Path to config file>


### Ring2Mongo.d configuration file

Unlike normal Earthworm modules, GSOF2Ring has a simpler type of configuration file. 
It has three major sections:

1. Earthworm: Contains EW related info
     1. RING_ID: The integer that has the Ring ID
     2. MOD_ID: The integer that has the Module ID
     3. INST_ID: The integer tha belongs to the Installation ID
2. MongoDB: Contains the MongoDB related info
     1. URL: Mongo database connection url
     2. DB: Mongo database collection name

The following is an example of a configuration file (usually named ring2mongo.d): 

    [Earthworm]
    RING_ID: 1000
    MOD_ID: 8
    INST_ID: 141
    HB: 30

    [MongoDB]
    URL: mongodb://localhost:27017/
    DB: ew-waves

### Ring2Mongo.desc descriptor file
The descriptor files follows the normal Earthworm descriptor files structure and must include:

    modName  ring2mongo
    modId    MOD_Ring2Mongo
    instId  ${EW_INST_ID}

Where:  
_modName:_ a unique name for this module (May include station name)  
_modId:_ a unique Module ID as stated in earthworm.d (must be the same in .d)  
_instId:_ usually left as  ${EW_INST_ID} (and must be the same one stated in .d)  

## Contact us

If you have any comment or question contact us at:

[Boritech Solutions](http://BoritechSolutions.com)

#### Acknowledgement:

 * Module Launcher coded by Erol Kalkan (USGS)
 * The development and maintenance of Ring2Mongo is funded entirely by software and research contracts with Boritech Solutions.
