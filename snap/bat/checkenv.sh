#!/bin/bash

 
if [[ -z "${BMF_RENDERNODE}" ]]; then
    echo 'set BMF_RENDERNODE env! winpath to fusionrendernode.exe  which is here (linux path): ${JOB}/bin/FusionRenderNode.exe';
    exit 1;
else
    echo "Fusion OK. path: ${BMF_RENDERNODE}";
fi


if [[ ${ARNOLD_BINDIR} == *scripts/bin ]]; then
    echo 'Arnold OK.';
else
    echo 'Arnold FAILS';
    echo "for Arnold environment run:"
    echo 'ha -envonly'
    exit 1;
fi
 