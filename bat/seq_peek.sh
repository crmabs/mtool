#!/bin/bash

seq="${1}";
info="${2}";
#m max
#c curr
seqRoot="${JOB}/tmp/seqz";
maxfilename="${seqRoot}/${seq}_max.txt";
seqfilename="${seqRoot}/${seq}_cur.txt";
lockfilename="${seqRoot}/${seq}_lok.lock";
if { set -C; 2>/dev/null >"${lockfilename}"; }; then
    trap "rm -f ${lockfilename}" EXIT
else
    #echo 'lock taken';
    exit 1;
fi

mx=$(cat "${maxfilename}");
cr=$(cat "${seqfilename}");

if [[ "${info}" == "m" ]]; then
    # max
    echo ${mx};    
else
    # pure current
    if [[ "${info}" == "c" ]]; then
        echo ${cr};
        exit;
    fi

    # evaluated current
    if [[ ${cr} -gt ${mx} ]]; then
        echo 'done';
    else
        echo ${cr};
    fi
fi
