#!/bin/bash

function slog(){
   s.lw "${1}" 'rgba';
}

iin="${1}";
input=$(realpath "${iin}");
icol="${2}";
rgbasrc=$(realpath "${icol}");

outfile="${3}";
output="${outfile}";
b_in=$(basename "${input}");
b_rgba=$(basename "${rgbasrc}");
b_out=$(basename "${output}");
slog "infile:[${b_in}] + rgba:[${b_rgba}] => [${b_out}]";


stufDir=$(dirname "${output}");
if [[ ! -d "${stufDir}" ]]; then
   mkdir -p "${stufDir}";
fi

clist=$(m.allch_except "${input}" 'R, G, B, A,');
#slog " base chs: [${clist}]";
oiiotool -i "${input}" --ch "${clist}" "${rgbasrc}" --ch R,G,B,A --chappend -o "${output}";

if [[ ${SNAPVERBOSE:-0} -eq 1 ]]; then
    clist=$(m.allchannels "${output}");
    slog "channels in output: [${clist}]";
fi

slog "done: [${output}]"