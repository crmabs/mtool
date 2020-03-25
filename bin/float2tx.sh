#!/bin/bash
[[ -z $1 ]] && { echo "***ERROR no source path given!"; return 0; }
m.float2tx $1;