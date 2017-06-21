#!/bin/bash
#ADDED TO VISUDO

if [ -d "$1" ] # path is a directory
then
	if [[ "$(stat --format '%U' "$1")" == "www-data" ]] # owner of path is www-data
	then
		echo "$1" | grep -q '^/var/www/transferme.it/[a-z]*/[a-z]*'
        if [[ $? -eq 0 ]] ; then
            {
                srm -rfs "$1" &
                cpulimit -p "$!" -l 5 & # limit cpu to 5% max
			} &> /dev/null # silences output
			echo "1"
		else
			echo "the path: $1 is not within allowed path"
		fi
	else
		echo "$1 is not owned by www-data"
	fi
else
	echo "1"
fi