#!/bin/bash

# 1     2   3   4  5        6    7
# Date: Tue Mar 17 22:39:36 2020 +0100

function oneline() {
    local lnum=$2;
    local line="${1}";
    #echo ${line};
    local nwsp=$(echo ${line} | sed 's|\s||g');
    if [[ -n "${nwsp}" ]]; then
        local dyear="$(echo ${line} | cut -d' ' -f6)";
        local dmonth="$(echo ${line} | cut -d' ' -f3)";
        local ddayn="$(echo ${line} | cut -d' ' -f4)";
        local ddweek="$(echo ${line} | cut -d' ' -f2)";
        local dtimeraw="$(echo ${line} | cut -d' ' -f5)"
        echo "${dyear} ${dmonth} ${ddayn}";
    fi
}


#  by line
function perline(){
  
    local count=0;
    git log --reverse | grep "Date" |
    while IFS= read -rs line || [[ -n "${line}" ]]; do
        local nwsp=$(echo ${line} | sed 's|\s||g');
        if [[ -n "${nwsp}" ]]; then
            oneline "${line}" ${count};
            count=$((count +1));
            echo ${count} > ./_repow;
        fi
    done
     
}


repon=$(basename `pwd`);
echo 'repository: ' ${repon};
perline | uniq -c | xargs -r -L 1;
total=$(cat ./_repow);
echo 'total: ' ${total};
echo ' ';
rm ./_repow;
