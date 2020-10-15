#!/bin/bash
# w3m image viewer for RTFM
# z3bra -- 2014-01-21
# http://blog.z3bra.org/2014/01/images-in-terminal.html

test -z "$3" && exit

W3MIMGDISPLAY="/usr/lib/w3m/w3mimgdisplay"
FILENAME=$1
FONTH=16 # Size of one terminal row
FONTW=12 # Size of one terminal column
COLUMNS=`tput cols`
LINES=`tput lines`

read width height <<< `echo -e "5;$FILENAME" | $W3MIMGDISPLAY`

max_width=$(($FONTW * $COLUMNS))
max_height=$(($FONTH * $(($LINES - 4)))) # substract for top/bottom windows 

if test $width -gt $max_width; then
height=$(($height * $max_width / $width))
width=$max_width
fi
if test $height -gt $max_height; then
width=$(($width * $max_height / $height))
height=$max_height
fi

posx=$(($FONTW * $2))
posy=$(($FONTH * $3))
maxw=$(($max_width + 10)) 
maxh=$(($max_height + 10))

w3m_command="6;$posx;$posy;$maxw;$maxh;\n4;\n3;"
echo -e $w3m_command|$W3MIMGDISPLAY

w3m_command="0;1;$posx;$posy;$width;$height;;;;;$FILENAME\n4;\n3;"

echo -e $w3m_command|$W3MIMGDISPLAY
