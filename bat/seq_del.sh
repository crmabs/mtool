#!/bin/bash

function slog(){
    s.lw "${1}" 'SEQ_';
}
seqname="${1}";

seqRoot="${JOB}/tmp/seqz";
maxfilename="${seqRoot}/${seqname}_max.txt";
seqfilename="${seqRoot}/${seqname}_cur.txt";
lockfilename="${seqRoot}/${seqname}_lok.lock";
if { set -C; 2>/dev/null >"${lockfilename}"; }; then
    trap "rm -f ${lockfilename}" EXIT
else
    #echo 'lock taken';
    exit 1;
fi

rm -f "${maxfilename}" "${seqfilename}" >/dev/null 2>&1;
slog "seq [${seqname}] deleted";