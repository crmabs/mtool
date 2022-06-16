#!/bin/bash

if [[ -z ${1} ]]; then
	echo 'pls specify args: hip rop start end step'
	echo 'Skip the first / defining the ROP!  /out/renderop => out/renderrop'
	exit 1;
fi

hip="${1}";
rop="${2}";
start="${3}";
end="${4}";
step="${5}";


if [[ -z ${start} ]]; then
	start=1;
	echo 'no start defined using start = 1'
fi


if [[ -z ${end} ]]; then
	end=1;
	echo 'no end defined using end = 1'
fi


if [[ -z ${step} ]]; then
	step=1;
	echo 'no step defined using step = 1'
fi



hython "${WGPATH}/mtool/bat/runrop.py"  "${hip}"  "${rop}"  "${start}"  "${end}"  "${step}";
