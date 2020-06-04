#!/bin/bash

seq="${1}";
seqRoot="${JOB}/tmp/seqz";
maxfilename="${seqRoot}/${seq}_max.txt";
seqfilename="${seqRoot}/${seq}_cur.txt";
lockfilename="${seqRoot}/${seq}_lok.lock";

if [[ ! -e "${seqfilename}" ]]; then
echo 'err';
exit 1;
fi

if { set -C; 2>/dev/null >"${lockfilename}"; }; then
    trap "rm -f ${lockfilename}" EXIT
else
    #echo 'lock taken';
    exit 1;
fi



if [[ ( ! -e "${seqfilename}" ) || ( ! -e "${maxfilename}"  ) ]]; then
    echo 'err';
    exit;
fi

maxval=$(cat "${maxfilename}");
sval=$(cat "${seqfilename}");

if [[ ( ${sval} -gt ${maxval} ) ]]; then
    #rm -f "${seqfilename}";
    #echo 'done' > "${seqfilename}";
    echo 'done';
    exit;
fi


nextn=$((${sval} + 1));
rm -f "${seqfilename}";
echo ${nextn} > "${seqfilename}";
echo  ${sval};