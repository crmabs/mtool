#!/bin/bash

seqname="${1}";

if [[ ! -e "${JOB}/tmp/seqz/${seqname}_cur.txt" ]]; then
echo 'err';
exit 1;
fi

success=0;
nextn="none";
while [[ ${success} -ne 1 ]] 
do
    nextn=$(seq_inc.sh "${seqname}");
    res=$?;
    if [[ ${res} -eq 0 ]]; then
        success=1;
    else
        # retrying
        sleep 0.5;
    fi
done

# seqN done err
echo ${nextn};