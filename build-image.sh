#!/bin/bash

echo "\nbuild docker hadoop image\n"
docker build -t urad/hadoop:1.0 .
