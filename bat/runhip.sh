#!/bin/bash
 

hip="${1}";
rop="${2}";
start="${3}";
end="${4}";
step="${5}";
 
# 1         2           3           4        5          6         7          8
# masterHip currentHip sceneSign smpQuality outScale ropToRender activeObj mapNames
hython "${WGPATH}/mtool/bat/runrop.py"  "${hip}"  "${rop}"  "${start}"  "${end}"  "${step}";
