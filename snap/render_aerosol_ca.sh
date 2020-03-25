#!/bin/bash

# prepares environment 
# runs hython scripts
# prepares composition
# composite
# copy to output
renderKotta="snapkotta.sh";

# hython script that prepares and renders the scene 
# also saves the modified scene
hyScript="hytakesnap.py";

# master hip to render
mHip="shoot_spraybox.hip";

# sampling quality
# hi -> adaptive on
# lo -> adaptive off
smpQuality="hi";

# output scale
# if == 1   -> override cam res = false
# otherwise -> override cam res = true
# gets converted to string by the hythpon script
# accepted   1  2   4    8   
# scale      1  0.5 0.25 0.125
# 
outScale=1;


# a merge that will render all connected rops
ropToRender='ropall';

# single frame only
frame=2;


# .comp to run
compToRun='aerosol_solo_ca.comp';


# config file
configFile='config_aerosol_ca.txt'

SECONDS=0
 
${JOB}/bat/runconfig.sh  "${renderKotta}" "${hyScript}" "${compToRun}" "${mHip}" "${smpQuality}" "${outScale}" "${ropToRender}" ${frame} "${configFile}";

duration=$SECONDS
echo "$(($duration / 60)) min $(($duration % 60)) secs elapsed total." 



