#!/bin/bash

res="eee";
while [[ "${res}" != "done" ]]
do
   res=$(seq_get.sh "demo");

   if [[ "${res}" == "err" ]]; then
      echo "error occured. racer gives up.";
      exit 1;
   fi

   # seqN done
   echo "${1} ${res}";
done

echo "-->  ${1} finished";
exit