#!/bin/bash

# find 10k file of current and sub folder, move them to tmp and display them with size order

dirpath='/tmp'
filepath='.'

find "$filepath" -size +10k -type f | xargs -i mv {} "$dirpath"
ls -lS "$dirpath" | awk '{if (NR>1) pring $NF}'
