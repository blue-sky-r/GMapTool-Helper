#!/usr/bin/env bash

# (c) 2016 Robert.BlueSky - GARMIN Map Tool / GMT Helper script
#
# DESC: Useful helper script for extracting subset of maps from single map file
#
# REQUIRES: GMapTool [ http://www.gmaptool.eu/en/content/linux-version ]
#
# IMPLEMENTED HELPERS:
# - LIST to list maps included in image
# - EXTRACT selected maps from image
#

# VERSION
#
VER="1.0"

# info
#
INFO="(c) 2016 Robert.BlueSky - GARMIN Map Tool (GMT) Helper script $VER"

# IMG file to examine
#
IMG="$1"

# country list to extract
#
CCLIST="$2"

# MapSet Name (default "GMapTool")
#
NAME="${3:-GMapTool}"

# PATH to gmt tool
#
GMT=./gmt

# WORKING dir (requires enough space)
#
TMP=/tmp/maps

# result map filename
#
RESULT="gmapsupp.img"

# FUNCTIONS
#
function banner
{
    local msg="$1"
    local i

	echo
	echo "$1"
	for (( i=1; i<=${#msg}; i++ ))
	{
	    echo -n "="
	}
	echo
	echo
}

# helper execution based on linked name
#
case $0 in

# LIST
# ====
*-list*)

	# usage help
	#
	[ $# -lt 1 ] && cat <<< """
	$INFO:
	
	usage: $0 map.img
	
	LIST sorted countries list included in map file map.img 
	""" && exit 1

	#  L: PID 1, FID 4037, map 15FE8D5, (547400 0),  ZLIN, CESKA REPUBLIKA  >CZECH REPUBLIC City Navigator Europe NTU 2016.3  >City Navigator Europe NTU 2016.3
	#
	$GMT -i -v "$IMG" | awk '/L: PID [0-9]+, FID [0-9]+, map/ {print $0}' | awk -F, '{c=gensub(/([A-Z ]+)>.*/,"\\1",1,$6); print c}' | sort | uniq
	;;
	
# EXTRACT
# =======
*-extract*)

	# usage help
	#
	[ $# -lt 2 ] && cat <<< """
	$INFO:
	
	usage: $0 map.img 'C1,C2' [mapset-name]
	
	EXTRACT only specific coutries from map.img to result map $RESULT 
	mapset-name is optional name (shown in Garmin map-info selection)
	
	Note: Extract helper requires enough space in $TMP to extract all maps from image
	""" && exit 1

	# workspace
	#
	mkdir "$TMP"

	#  L: PID 1, FID 4037, map 15FE8D5, (547400 0),  ZLIN, CESKA REPUBLIKA  >CZECH REPUBLIC City Navigator Europe NTU 2016.3  >City Navigator Europe NTU 2016.3
	#
	
	# get all maps from image
	#
	IMGMAPLIST=$( $GMT -i -v "$IMG" | awk '/L: PID [0-9]+, FID [0-9]+, map/ {print $0}' )

	# NAME has two parts: source_version - supplied_name
	#
	SRCVER=$( echo "$IMGMAPLIST" | awk -F">" '{print $3; exit}' )
	NAME="$SRCVER-$NAME"
		
	# EXTRACT all maps from image
	#
	banner "EXCTRACTING all maps from image $IMG ..."
	$GMT -S -v -o "$TMP" "$IMG"
	
	#  select maps for requested countries to $CCMAPS
	#
	banner "COUNTRY -> MAPS"
	CCMAPS=""
	OLDIFS="$IFS"; IFS=","
	for country in $CCLIST
	{
		echo -en "$country -> "
		ADD=$( echo "$IMGMAPLIST" | awk -v cc="$country"  -v tmp="$TMP" '$0 ~ cc  {id=gensub(/^.*, map ([0-9A-F]+),.*$/,"\\1",1); printf "%s/%d.img ",tmp,strtonum("0x"id)}' )
		CCMAPS="$CCMAPS$ADD"
		echo "$ADD"
	}
	IFS="$OLDIFS"

	# JOIN all requested maps
	#
	banner "JOIN MAPS NAME:$NAME -> $RESULT"
	$GMT -LicenseAcknowledge -j -v -m "$NAME" -o "$RESULT" $CCMAPS

	# show result
	#
	ls -l "$RESULT"

	# CLEANUP
	#
	rm -rf "$TMP"
		
	;;

# DEFAULT
# =======
*)
	cat <<< """
	
	$INFO:
	
	To get full advantage of this script create two symlinks to this helper:
	1) including string '-list'    in the name to get LIST    functionality (e.g. 'gmt-list -> $0')
	2) including string '-extract' in the name to get EXTRACT functionality (e.g. 'gmt-extract -> $0)

	Then conveniently use:
	gmt-list	to get LIST    helper
	gmt-extract	to get EXTRACT helper
	"""
	;;
		
esac
