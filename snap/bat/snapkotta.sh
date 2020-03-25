#!/bin/bash

# 1        2         3    4          5        6           7         8         9
# hyScript compToRun mHip smpQuality outScale ropToRender activeObj sceneSign mapNames


${JOB}/bat/checkenv.sh
if [[ $? -eq 0 ]]; then
    echo 'env is OK.';
else
    echo 'trouble with env';
    exit;
fi


hyScript="${1}";
compToRun="${2}";
mHip="${3}";
smpQuality="${4}";
outScale="${5}";
ropToRender="${6}";
sceneSign="${7}";
frame="${8}"
activeObj="${9}";
mapNames="${10}";


masterHip="${JOB}/Scene/shoot/Houdini/${mHip}";
currentHip="${JOB}/Scene/shoot/Houdini/gen/${sceneSign}.hip";
masterComp="${JOB}/Comp/master/${compToRun}";
currentComp="${JOB}/Scene/shoot/3DRender/${sceneSign}/${compToRun}";
hyScriptPath="${JOB}/bat/${hyScript}";

echo "${hyScriptPath}  ${masterHip}  ${currentHip}  ${sceneSign}  ${smpQuality}  ${outScale}  ${ropToRender} ${frame} ${activeObj}  ${mapNames}";

if [[ -z ${RECOMP} ]]; then
# 1         2           3           4        5          6         7          8
# masterHip currentHip sceneSign smpQuality outScale ropToRender activeObj mapNames
hython "${hyScriptPath}"  "${masterHip}"  "${currentHip}"  "${sceneSign}"  "${smpQuality}"  "${outScale}"  "${ropToRender}"  ${frame}  "${activeObj}"  "${mapNames}";
fi

if [[ -z ${NOCOMP} ]]; then
    cp "${masterComp}" "${currentComp}";
    echo " ";
    echo "scene signature: ${sceneSign} ";
    echo "current comp: ${currentComp} ";
    ${JOB}/bat/runcomp.bat ${currentComp} 1 1 1;
    echo 'compositing done';

    mkdir -p "${JOB}/Out/gen/${sceneSign}";
    cp "${JOB}/Scene/shoot/3DRender/${sceneSign}/pack_transp.png" "${JOB}/Out/gen/${sceneSign}/${sceneSign}_transp.png";
    cp "${JOB}/Scene/shoot/3DRender/${sceneSign}/pack_wb.png" "${JOB}/Out/gen/${sceneSign}/${sceneSign}.png";
fi


echo "${JOB}/Out/gen/${sceneSign}/${sceneSign}.png";
echo 'ready   ';
echo ' ';
