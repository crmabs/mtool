#!/bin/bash

  

# perline | uniq -c | xargs -r -L 1;
# total=$(cat ./_repow); 
# rm ./_repow;
# repon=$(basename `pwd`);
# echo ${repon} ${total};

# lines to 
# sed ':a;N;$!ba;s/\n/ /g'

# git log --reverse | grep -i -e 'Date' -A 2 | sed 's|--||g' | xargs -r -L 1

#                                            kill newline                replace -- to newline
#git log --reverse | grep -i -e 'Date' -A 2 | sed ':a;N;$!ba;s/\n//g' > ./_rl;
#cat ./_rl 
#| awk 'BEGIN { FS="--"; OFS="\n" } { print $1, $2, $3 }' 
#| sed 's|Date:||g'

reponame=$(basename `pwd`);
echo 'repository:  ' ${reponame};
git log --reverse | grep -i -e 'Date' -A 2 | sed ':a;N;$!ba;s/\n//g'  | sed 's|--|*|g' | sed 's|Date:||g' | tr '*' '\n' | xargs -r -L 1 | cut -d' ' -f '1 2 3 4 5 7-';
echo ' ';