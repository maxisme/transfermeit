#!/bin/bash
#ADDED TO VISUDO

if [ -d "$1" ] # path is a directory
then
	if [[ "$(stat --format '%U' "$1")" == "www-data" ]] # owner of path is www-data
	then
		echo "$1" | grep -q '^/var/www/transferme.it/public_html/[a-z]*/[a-z]*'
        if [[ $? -eq 0 ]] ; then
			/usr/bin/srm -rf "$1" & #runs in background
			echo "1"
		else
			echo "the path: $1 is not within transferme.it website"
		fi
	else
		echo "$1 is not owned by www-data"
	fi
else
	echo "$1 is not a directory or doesn't exist"
fi