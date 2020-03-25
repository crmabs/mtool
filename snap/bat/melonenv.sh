#!/bin/bash

 

 

echo "for Arnold environment don't forget to run:"
echo 'ha -envonly';
# for fusion
funode="${JOB}/bin/FusionRenderNode.exe";
echo "linux fusion render node path: ${funode}"

echo 'configured for MELON'
export BMF_RENDERNODE='"O:\snap\bin\FusionRenderNode.exe"'
printenv BMF_RENDERNODE
 

