#!/bin/bash
 
function slog(){
   s.lw "${1}" 'rVar';
}

function rwspace(){
    echo "${1}" | sed -e 's/\s\+//g';
}

function allchannels(){
    local srci="${1}";
    local ach=$(oiiotool.exe --info -v "${srci}" | grep -e "channel list:" | sed 's|channel list:||g' );
    echo "${ach}";
}

function allch_except(){
    local aexc=$(echo $(allchannels "${1}") | sed 's|'"${2}"'||g' );
    rwspace "${aexc}";
}



function oneline() {
    local onefile="${1}";
    slog " processing:[${onefile}]";

    clist=$(allch_except "${onefile}" 'variance.R, variance.G, variance.B, variance.A');
    #echo "${clist}";

    fext=$(m.fn_ext "${onefile}");
    resFile="${outDir}/vrep_linear${fext}";

    # variance to invert(grey)
    oiiotool.exe -i "${onefile}" --iscolorspace linear --ch "${clist}"  "${bossVari}" --iscolorspace linear --ch variance.R=R,variance.G=G,variance.B=B,variance.A=1   --chappend  -o "${resFile}";
    
}

# process by spaces
function perline(){
    local input="${1}";
    echo ${input} |
    while read -r -d' ' f; do
            oneline "${f}";
    done
}

#------------------

# inputdir with the files to max
srcDir=$(realpath "${1}");
# pattern for the source files
namePat="${2:-''}";

# outdir for result
outDir="${3}";
# the collected variance to push in
bossVari="${4}";
 
outDir=$(realpath "${outDir}");

 

slog "sourced:[${srcDir}]  outd:[${outDir}]";

if [[ ! -d "${outDir}" ]]; then
    mkdir -p "${outDir}";
fi

# files from dir
exrfiles=$(find ${srcDir} -maxdepth 1 -type f -name "*${namePat}*.exr" -print );
exrfiles="${exrfiles} nos"; # needed, last one is not processed otherwise
#echo ${exrfiles};
 

perline "${exrfiles}";

 
sleep 1;

slog "done, results in:[${outDir}]";