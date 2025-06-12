#!/bin/bash

set -e;

USER_DATA=/usr/src/node-red/data/.; 
TARGET_DATA=/data/; 

echo "Start migration";

cd $USER_DATA;
echo "Copy $USER_DATA to $TARGET_DATA";
cp -Rv $USER_DATA $TARGET_DATA;

echo "Migration Success";