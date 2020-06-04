#!/bin/bash

seqname="${1}";
seqcurr="${2}";
seqmax="${3}";
reset="${4}";

seqRoot="${JOB}/tmp/seqz";
maxfilename="${seqRoot}/${seqname}_max.txt";
seqfilename="${seqRoot}/${seqname}_cur.txt";
lockfilename="${seqRoot}/${seqname}_lok.lock";

function slog(){
    s.lw "${1}" 'SEQ_';
}

# before lock -> have the dir to create the lock file
if [[ ! -d "${seqRoot}" ]]; then
    mkdir -p "${seqRoot}";
    slog "sequence tmp dir for job:[${JOB}] created:[${seqRoot}]";
fi

if { set -C; 2>/dev/null >"${lockfilename}"; }; then
    trap "rm -f ${lockfilename}" EXIT
else
    # echo 'lock taken';
    exit 1;
fi



if [[ ( -e "${maxfilename}" ) && ( -e "${seqfilename}" ) ]]; then

    if [[ ${reset} == 'f' ]]; then

        rm -f "${maxfilename}";
        echo "${seqmax}" > "${maxfilename}";
        rm -f "${seqfilename}";
        echo ${seqcurr} > "${seqfilename}";
        slog "seq [${seqname}] reset.  curr:${seqcurr}  max:${seqmax}";
        exit
    else
        slog "seq [${seqname}] exists already.";
        exit 1;
    fi


else
    echo "${seqmax}" > "${maxfilename}";
    echo "${seqcurr}" > "${seqfilename}";
    slog "seq [${seqname}] created.  curr:${seqcurr}  max:${seqmax}";
fi


