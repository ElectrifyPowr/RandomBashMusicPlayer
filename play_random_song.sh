#!/bin/bash

#
# ---------------- usage ---------------
#
# executing the script:
#   play_random_song.sh
#
# help:
#   play_random_song.sh -h
#   play_random_song.sh -help
#   play_random_song.sh h
#   play_random_song.sh help
#
#
#

firstarg=$1

if [[ $firstarg = "-h" ]] || [[ $firstarg = "-help" ]] || [[ $firstarg = "h" ]] || [[ $firstarg = "help" ]]; then
    echo ""
    echo "---------- what this script does: -----------"
    echo " Plays all music files in current directory randomly"
    echo " You can also define a custom path"
    echo ""
    echo "---------- usage: ---------------------------"
    echo "play_random_song.sh"
    echo ""

    exit 1
fi

# when loop gets stopped via CTRL-C, make sure to clear all background playing jobs
function finish {
    echo "stopping all background playig processes"
    killall afplay
}
trap finish EXIT


# ask if music should be played from preferred directory
read -p "Play music from preffered directory (y/n)? " -n 1 -r
echo   # move to new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    cd /path/to/preferred/directory/
    echo "playing music from preferred directory..."
else
    echo "playing music from current directory..."
fi



# file extensions for music files
file_extension='mp3'

# min range of random number
min=0

# max range of random number ->total number of music files in current dir
num_files=$(ls -1 *.$file_extension | wc -l)
# subtract 1 due to index starting at 0
num_files=$(($num_files-1))

# save all file names in variable
all_files=($(ls -d *.$file_extension))


while [[ true  ]]; do

    # generate random number in range of min & max
    randy=$(jot -r 1  $min $num_files)

    echo "Playing random file $randy: ${all_files[$randy]}"
    #echo ${all_files[$randy]}

    # get duration of random file
    duration=$(afinfo ${all_files[$randy]} | awk '/estimated duration/ { print $3 }')
    # convert duration into integer
    duration=$(echo "$duration/1" | bc)

    # play song in background
    afplay ${all_files[$randy]} &

    # read for any keypress for playing next song
    # (give read timeout -> same as duration of song)
    read -p "" -n 1 -r -t $duration ; echo
    killall afplay

done










