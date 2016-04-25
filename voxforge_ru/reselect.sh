#!/bin/bash

cd selected

# Creating file list
cat ../data/*/wav.scp | uniq | egrep -o 'selected/[^ ]*' | sed 's/selected\///' > src

# Make directories
cat src | awk -F '/' '{print $1}' | uniq | xargs mkdir
cat src | awk -F '/' '{print $1 "\/" $2}' | uniq | xargs mkdir

# Copying
while read line; do 
  extracted=`echo "../extracted/$line" | sed 's/anonymous[^-]*-/anonymous-/'`
  cp $extracted $line
done < src

# Cleaning up
rm src
cd -
