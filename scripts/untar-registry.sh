#!/bin/bash

source common.sh

if [ -d ../registry/compressed/ ]; then find ../registry/compressed/ -type f -exec file {} \; | grep compressed | awk -F: '{print $1}' | while IFS='' read -r cpd; do tar -zxf "$cpd" -C ../registry && rm -rf "$cpd"; done; fi

logger "untar registry success"
