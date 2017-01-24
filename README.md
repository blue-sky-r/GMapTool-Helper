# What is gmt-helper
gmt-helper.sh is a helper tool for extracting required maps from single map file for GARMIN navigation device. 
 For example Europe image file is getting bigger with each new release and doesn't fit to available limited storage
 capacity of the older GARMIN devices. And after all, you seldom need entire Europe map for your travel. Therefore
 there is a need to extract only required segments of the map for loading into your GARMIN. This task can be
 done in MapSource which is windows based GUI for planning trips, managing the maps and more. However, on linux
 platform there is no corresponding tool to MapSource AFAIK. This simple helper can be used to perform extraction task.
 
gmt-helper is simple shell/bash script for command line usage (no GUI) on linux platform (might work on windows
 platform as well with cygwin or windows version of bash - but was not tested at all as I'm linux/osx user)

I have implemented gmt-helper for my personal use on linux wks and I have been using it ~~without any issues since then.~~

##UPDATE
It has been found that extracts made by [GMapTool](http://www.gmaptool.eu/en/content/linux-version "GMapTool Homepage") have
broken internal index therefore searching by state / city / address does not work. For this reason I do not recommend using
neither GMapTool nor gmt-helper to create garmin extracts. The only option is using MapSource. 

## Implemented modalities
gmt-helper implements two basic modalities in single script. To simplify usage and minimize script parameters
 the modality selection is based on name of executed script. Therefore it is recommended to create two symlinks
 to gmt-helper.sh and call only symlinks for required modality:

* one wich contains string '-list', for example _'gmt-list' -> 'gmt-helper.sh'_
* second one wich contains string '-extract', for example _'gmt-extract' -> 'gmt-helper.sh'_

_Note: symlinks are also provided in this git repository_

By executing the symlink you indirectly provide modality parameter (the name of the executable). This trick is often
 used on embedded linux devices (routers, NAS, ip camera), where basuc functionality is provided by single shell executable. 

## Dependencies
gmt-helper requires [GMapTool](http://www.gmaptool.eu/en/content/linux-version) for all modalities (LIST, EXTRACT). Default configuration
 expects to find **gmt** tool in the local directory where gmt-helper is located (see configuration section bellow).

## Configuration
configuration options (variables) are located at the beginning of the script with short description:

These are the most important configuration settings. Default values should be ok in the most cases (verify GMT path).

    # PATH to gmt tool
    #
    GMT=./gmt

    # WORKING dir (requires enough space)
    #
    TMP=/tmp/maps

    # result map filename
    #
    RESULT="gmapsupp.img"


## LIST
gmt-helper LIST modality simply lists all maps included in map image file:
 
    > gmt-list path/to/gmapsupp.img
    
    BALGARIYA
    BOSNA I HERCEGOVINA
    BYELARUS
    CESKA REPUBLIKA
    CRNA GORA
    CYPRUS
    ...
   
Required single parameter is the path to the image file. If no parameter is provided the short usage help is shown.
 Printout is alphabetically sorted in ascending order. Listed map names are required for extraction process.
 Depending on the image size it might take a few seconds to parse all maps. 
 This modality doesn't allocate any working space.
 
## EXTRACT
gmt-helper EXTRACT modality performs the extraction of required maps from single image file:
 
    > gmt-extract path/to/gmapsupp.img 'BYELARUS,CESKA REPUBLIKA,CYPRUS' 'BL,CZ,CY'
    
    BALGARIYA
    BOSNA I HERCEGOVINA
    BYELARUS
    CESKA REPUBLIKA
    CRNA GORA
    CYPRUS

Required the first two parameters are:

* path to the source image file
* comma separated list of countries requested for extraction (the names must exactly match names shown in LIST modality)

Third paramneter is optional, but recommended one:

* any text identifying extracted maps (will be visible on GARMIN device in settings->map->info)

The extraction process can take a while and allocates full space to extract all parts of image file to working dir.
 After extraction is done the cleanup will remove entire working directory. 
 
**Note:** Please make sure you have enough free space in the working directory (see configuration).

Hope it helps ...

#### History
 version 1.0 - the initial GitHub release in 2016

_keywords:_ garmin, gps, map, extract, image, img, bash

