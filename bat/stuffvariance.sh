#!/bin/bash
 
function slog(){
   s.lw "${1}" 'StfV';
}


# inputdir with the files to stuff the variance in
srcDir=$(realpath "${1}");
# target dir to the stuffed results into
targetDir=$(realpath "${2}");
# variance to stuff
variFile=$(realpath "${3}");
# pattern for the source files
namePat="${4:-''}";

slog "sourced:[${srcDir}]  targetDir:[${targetDir}]  variance:[${variFile}]";

if [[ ! -d "${targetDir}" ]]; then
    mkdir -p "${targetDir}";
fi

# files from dir
exrfiles=$(find ${srcDir} -maxdepth 1 -type f -name "*${namePat}*.exr" -print );
exrfiles="${exrfiles} nos"; # needed, last one is not processed otherwise
#echo ${exrfiles};


function oneline() {
    local onefile="${1}";
    local inext=$(m.fn_ext "${onefile}");
    local stuffedFile="${targetDir}/mvst_linear${inext}";

    slog " stuffing:[${onefile}]";

       
    novar=$(m.allch_except "${onefile}" 'variance.R, variance.G, variance.B, variance.A');
    varchs='variance.R=R, variance.G=G, variance.B=B, variance.A=A';
    # stuff
    oiiotool.exe -i "${onefile}" --ch "${novar}" "${variFile}" --ch "${varchs}" --chappend -o "${stuffedFile}";
}

# process by spaces
function perline(){
    local input="${1}";
    echo ${input} |
    while read -r -d' ' f; do
            oneline "${f}";
    done
}

perline "${exrfiles}";
