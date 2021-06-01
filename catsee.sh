#!/bin/sh

#              __               
#  _________ _/ /_________  ___ 
# / ___/ __ `/ __/ ___/ _ \/ _ \ 
#/ /__/ /_/ / /_(__  )  __/  __/ 
#\___/\__,_/\__/____/\___/\___/                               
#
#Display a random image in new terminal windows
#AUTHOR: Stephen Marks
#Dependencies: kitty, icat, imagemagick, perl, xdotool
#
#
source $HOME/.config/catsee/config.sh

#while getopts "cdps:" opt; do #make switch
#	case $opt in
#	esac
#done

if [[ ! -f  "$HOME/.config/catsee/config.sh" ]]; then
	DIR=$"$HOME/Pictures"
	SIZE="quarter"
	POS="top-right"
fi
	
KILLFLAG=$(echo $(perl -lpe 's/\0/ /g' /proc/$(xdotool getwindowpid $(xdotool getactivewindow))/cmdline))
if [[ $KILLFLAG != "kitty" ]]; then
	exit 1 #If terminal emulator is not kitty exit
fi

if [[ -d "${DIR}" ]]; then # ls --> matrix, delim = newline
 file_matrix=($(ls "${DIR}"))
 num_files=${#file_matrix[*]}
fi

PHOTO=$(echo $(ls "${DIR}/${file_matrix[$((RANDOM%num_files))]}")) #Selects random photo from DIR
PHOTOWIDTH=$(echo $(identify -format '%w %h' "$PHOTO" | awk '{print $1}'))
PHOTOHEIGHT=$(echo $(identify -format '%w %h' "$PHOTO" | awk '{print $2}'))
WINDOWWIDTH=$(echo $(kitty +kitten icat --print-window-size | awk 'BEGIN { FS = "x" } ; {print $1}'))
WINDOWCOLS=$(echo $(tput cols))
WINDOWHEIGHT=$(echo $(kitty +kitten icat --print-window-size | awk 'BEGIN { FS = "x" } ; {print $2}'))
WINDOWLINES=$(echo $(tput lines))

if [[ $SIZE = "third" ]]; then
	NEWWIDTH=$(echo $(( $WINDOWWIDTH / 3 )) )
elif [[ $SIZE = "quarter" ]]; then
	NEWWIDTH=$(echo $(( $WINDOWWIDTH / 4 )) )
elif [[ $SIZE = "fifth" ]]; then
	NEWWIDTH=$(echo $(( $WINDOWWIDTH / 5 )) )
elif [[ $POS = "banner" ]]; then
	NEWWIDTH=$(echo $(( $WINDOWWIDTH / 8 )) )
fi

NAME=$(echo $(echo $PHOTO | awk 'BEGIN {FS = "/" } ; {print $6}' ))

if [[ ! -f ~/.config/catsee/cache/"${NAME}+${NEWWIDTH}.catsee" ]]; then
	convert "$PHOTO" -filter Triangle -define filter:support=2 -thumbnail $NEWWIDTH -unsharp 0.25x0.25+8+0.065 -dither None -posterize 136 -quality 100 -define jpeg:fancy-upsampling=off -define png:compression-filter=5 -define png:compression-level=9 -define png:compression-strategy=1 -define png:exclude-chunk=all -interlace none -colorspace sRGB -strip ~/.config/catsee/cache/"${NAME}+${NEWWIDTH}.catsee"
	#convert "$PHOTO" -resize $NEWWIDTH /home/steve/.config/catsee/cache/"${NAME}+${NEWWIDTH}.catsee"
fi

NEWHEIGHT=$(echo $(identify -format '%w %h' /home/steve/.config/catsee/cache/"${NAME}+${NEWWIDTH}.catsee" | awk '{print $2}'))
PHOTOCOLS=$(echo $(( ($NEWWIDTH + 4)  / 9 )) )
PHOTOLINES=$(echo $(( ($NEWHEIGHT + 9) / 18 )) )
RIGHT=$(echo $(( $WINDOWCOLS - $PHOTOCOLS )) )
BOTTOM=$(echo $(( $WINDOWLINES - $PHOTOLINES )) )
#kitty +kitten icat --align right /home/steve/.config/catsee/cache/"${NAME}+${NEWWIDTH}.catsee"
if [[ $POS = "top-right" ]]; then 
	kitty +kitten icat --place "${PHOTOCOLS}x${PHOTOLINES}@${RIGHT}x0" /home/steve/.config/catsee/cache/"${NAME}+${NEWWIDTH}.catsee"
elif [[ $POS = "bottom-right" ]]; then 
	kitty +kitten icat --place "${PHOTOCOLS}x${PHOTOLINES}@${RIGHT}x${BOTTOM}" /home/steve/.config/catsee/cache/"${NAME}+${NEWWIDTH}.catsee"
elif [[ $POS = "banner" ]]; then 
	kitty +kitten icat --place "${PHOTOCOLS}x${PHOTOLINES}@${RIGHT}x0" /home/steve/.config/catsee/cache/"${NAME}+${NEWWIDTH}.catsee"
fi
