#!/bin/bash

function  cleanup() {
    rm -f ./_csign.txt;
    rm -f ./_cobj.txt;
    rm -f ./_ctex.txt;
}

function onepair() {
    local opair="${1}";
    if [[ -n "${opair}" ]]; then
        #echo ${opair};
        local obj="$(echo ${opair} | cut -d' ' -f1)";
        local tex="$(echo ${opair} | cut -d' ' -f2)";
        local nwobj="$(echo ${obj} | sed 's|\s||g')";
        local nwtex="$(echo ${tex} | sed 's|\s||g')";
        # they are only equal if the pair is single
        if [[ ${nwobj} == ${nwtex} ]]; then
            #echo "s:[${obj}]";
            echo "${obj}" > ./_csign.txt;
        else
            #echo "o:[${obj}] t:[${tex}]";
            echo "${obj}" >> ./_cobj.txt;
            echo "${tex}" >> ./_ctex.txt;
        fi
    fi
}

function linetocomma(){
    echo "$(sed ':a;N;$!ba;s/\n/,/g' ${1})";
}

function oneline() {

    cleanup;
    local line="${1}";
    #echo ${line};
    local nwsp=$(echo ${line} | sed 's|\s||g');
    if [[ -n "${nwsp}" ]]; then
        echo ${line} |
        while IFS= read -rs -d',' opair || [[ -n "${opair}" ]]; do
            nwsp=$(echo ${opair} | sed 's|\s||g');
            if [[ -n "${nwsp}" ]]; then
                onepair "${opair}";
            fi
        done
        
        # one line done - time to render
        csign=$(linetocomma './_csign.txt');
        cobj=$(linetocomma './_cobj.txt');
        ctex=$(linetocomma './_ctex.txt');
        #echo "s:${csign} o:${cobj} t:${ctex}";

        # render one line from the config
        oneline="'${JOB}/bat/${renderKotta}' '${hyScript}' '${compToRun}' '${mHip}' '${smpQuality}' ${outScale} '${ropToRender}' '${csign}' ${frame} '${cobj}' '${ctex}'";
        echo "${oneline}";
        eval "${oneline}";
        cleanup;
        echo '---';
    fi

}

# process file by line
function perline(){

    local input="${1}";
    cat ${input} |
    while IFS= read -rs line || [[ -n "${line}" ]]; do
        local nwsp=$(echo ${line} | sed 's|\s||g');
        if [[ -n "${nwsp}" ]]; then
            oneline "${line}" 1;
        fi
    done

    cleanup;
}


renderKotta="${1}";
hyScript="${2}";
compToRun="${3}";
mHip="${4}";
smpQuality="${5}";
outScale="${6}";
ropToRender="${7}";
frame="${8}";
configFile="${9}";

perline "${JOB}/${configFile}";
 