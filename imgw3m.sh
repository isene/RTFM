#!/bin/bash
# w3m image viewer for RTFM

W3MIMGDISPLAY="/usr/lib/w3m/w3mimgdisplay"
FILENAME=$1
posx=$2
posy=$3
width=$4
height=$5

if [ $1 == "CLEAR" ]; then
	w3m_command="6;$posx;$posy;$width;$height;\n4;\n3;"
else
	w3m_command="0;1;$posx;$posy;$width;$height;;;;;$FILENAME\n4;\n3;"
fi

echo -e $w3m_command|$W3MIMGDISPLAY
