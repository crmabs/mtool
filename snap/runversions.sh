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
smpQuality="lo";

# output scale
# if == 1   -> override cam res = false
# otherwise -> override cam res = true
# gets converted to string by the hythpon script
# accepted   1  2   4    8   
# scale      1  0.5 0.25 0.125
# 
outScale=4;


# a merge that will render all connected rops
ropToRender='ropall';

# single frame only
frame=2;


# .comp to run
compToRun='sprayandbox.comp';






# ---------- per line stuff

# scene signature - drives the naming
sceneSign='aerosol_100ml_icaridin';

# active objects - these are going to be unhidden 
activeObj='aerosol_100ml_solo';

# map names - set the colmap parameter on active objects
mapNames='aerosol_100ml/34_1_Anti-Insect_Icardin_aerosol_100ml_label.tx';

 
#
#                                                                                                                    global for all versions --| |-- per line
oneline="'${JOB}/bat/${renderKotta}' '${hyScript}' '${compToRun}' '${mHip}' '${smpQuality}' ${outScale} '${ropToRender}' '${sceneSign}' ${frame} '${activeObj}' '${mapNames}'";
echo "${oneline}";
eval "${oneline}";
# ...



#./rendershoot.sh './shooth.py' 'shoot_spraybox.hip' 'sb_60ml_anti_insect' 'half' "box60ml|spray_60ml" "box_60ml/final/29_1_Anti-Teek_Box_60ml.tx|label_60ml/29_2_Anti-Teek_Spray_60ml.tx" 'sbprev.comp'
#./rendershoot.sh './shooth.py' 'shoot_spraybox.hip' 'sb_60ml_deet40' 'half' "box60ml|spray_60ml" "box_60ml/final/02_1_DEET40_Box_60ml.tx|label_60ml/2_2_DEET40_Label_60ml.tx" 'sbprev.comp'
#./rendershoot.sh './shooth.py' 'shoot_spraybox.hip' 'sb_60ml_icaridin' 'half' "box60ml|spray_60ml" "box_60ml/final/13_1_Icaridin_Box_60ml.tx|label_60ml/13_2_Icaridin_Spray_60ml.tx" 'sbprev.comp'
#./rendershoot.sh './shooth.py' 'shoot_spraybox.hip' 'sb_60ml_deet50' 'half' "box60ml|spray_60ml" "box_60ml/final/06_1_DEET50_Box_60ml.tx|label_60ml/6_2_DEET50_Box_60ml.tx" 'sbprev.comp'
#./rendershoot.sh './shooth.py' 'shoot_spraybox.hip' 'sb_60ml_natural' 'half' "box60ml|spray_60ml" "box_60ml/final/09_1_Natural_Box_60ml.tx|label_60ml/9_2_Natural_Spray_60ml.tx" 'sbprev.comp'

