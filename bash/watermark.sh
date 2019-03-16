#!/bin/bash

EXTENSION=".${1##*.}"
NEW_EXTENSION="_watermarked${EXTENSION}"
IMAGE_WIDTH=$(identify -ping -format '%w' $1)
WATERMARK_WIDTH=$(expr $IMAGE_WIDTH / 10)
NEW_FILENAME=${1/$EXTENSION/$NEW_EXTENSION}

convert $2 -resize "$WATERMARK_WIDTH^>" "$2_resized"
composite -gravity $3 -geometry $4 "$2_resized" $1 $NEW_FILENAME

mv $NEW_FILENAME $5

rm "$2_resized"
