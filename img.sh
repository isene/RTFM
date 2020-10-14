#!/bin/bash
# Usage: img.sh <image> <x> <y> <max width> <max height>" && exit

source "`ueberzug library`"

ImageLayer 0< <(
    ImageLayer::add [identifier]="rfm" [x]="$2" [y]="$3" [max_width]="$4" [max_height]="$5" [path]="$1"
    read && exit
)
