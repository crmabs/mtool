#!/bin/bash

 

# 1 input file
# 2 output file
 
projlog="${JOB}/_snaplog.txt";
function slog(){
   s.lw "${1}" 'nPst';
}

inputfile=$(realpath "${1}");
outputfile="${2}";

varparam=${3}; #  def: 0.5 
searchradius=${4}; # def:12
patchradius=${5}; # def:3

me=`basename "$0"`;

currentDir=$(realpath `dirname "${inputfile}"`);

b_inf=$(basename "${inputfile}");
outb=`basename "${outputfile}"`;
outfolder=$(realpath `dirname "${outputfile}"`);
outputfile="${outfolder}/${outb}";
[ ${SNAPVERBOSE:-0} -eq 1 ] && slog "${me} output dir: ${outfolder}";

if [[ ! -d "${outfolder}" ]]; then
   mkdir -p "${outfolder}";
fi


# defaults
dvarp=0.5;
dsrad=12;
dpatrad=3;

if [[ ( "${inputfile}" == '--help' ) || ( "${inputfile}" == '-h' )  || ( "${inputfile}" == '--h' ) || ( "${inputfile}" == '-help' ) || ( -z "${inputfile}" ) ]]; then
   echo 'see noicew.sh for help!';
   exit 0;
fi

if [[ ${varparam} == 'd' || ( -z ${varparam} ) ]]; then
   varparam=${dvarp};
fi

if [[ ${searchradius} == 'd' || ( -z ${searchradius} ) ]]; then
   searchradius=${dsrad};
fi

if [[ ${patchradius} == 'd' || ( -z ${patchradius} ) ]]; then
   patchradius=${dpatrad};
fi

if [[ ${varparam} == 'a' || ( -z ${varparam} ) ]]; then
   
   varparam=${dvarp};
   searchradius=${dsrad};
   patchradius=${dpatrad};
fi

#slog "  Noice post"
[ ${SNAPVERBOSE:-0} -eq 1 ] && slog "  source:        ${inputfile}";
[ ${SNAPVERBOSE:-0} -eq 1 ] && slog "  result:        ${outputfile}";
[ ${SNAPVERBOSE:-0} -eq 1 ] && slog "  variance:${varparam}   search radius:${searchradius}   patch radius:${patchradius}";


# intermediate images
inalfa=$(m.side "${outputfile}" 'exr' '_inalfa_linear');
albedo=$(m.side "${outputfile}" 'exr' '_albedo_linear');
beauty=$(m.side "${outputfile}" 'exr' '_beauty_linear');
nobedo=$(m.side "${outputfile}" 'exr' '_nobedo_linear');
laplacian=$(m.side "${outputfile}" 'exr' '_laplacian_linear');
clamped=$(m.side "${outputfile}" 'exr' '_clamped_linear');
variance=$(m.side "${outputfile}" 'exr' '_variance_linear');
prepared=$(m.side "${outputfile}" 'exr' '_prepared_linear');
rawdeno=$(m.side "${outputfile}" 'exr' '_rawdeno_linear');
combined=$(m.side "${outputfile}" 'exr' '_combined_linear');
 
#slog "rawdeno: ${rawdeno}";

function cleanup(){
    rm -f "${inalfa}";
    rm -f "${albedo}";
    rm -f "${beauty}";
    rm -f "${nobedo}";
    rm -f "${laplacian}";
    rm -f "${clamped}";
    rm -f "${variance}";
    rm -f "${prepared}";
    rm -f "${rawdeno}";
    rm -f "${combined}";
}



function doit(){


   [ ${SNAPVERBOSE:-0} -eq 1 ] && slog "denoise starts. src:[${b_inf}]";

   #echo "-t ${NOICTH:--1} -i "${prepared}" -o "${rawdeno}" -v ${varparam} -sr ${searchradius} -pr ${patchradius}";
   #noice -t ${NOICTH:--1} -i "${prepared}" -o "${rawdeno}" -v ${varparam} -sr ${searchradius} -pr ${patchradius};
   noice -t ${NOICTH:--1} -i "${prepared}" -o "${rawdeno}" -v ${varparam} -sr ${searchradius} -pr ${patchradius} | xargs -L 1 -n 1 -r -d '\n' -i echo -e "\t\tNoic\t{}" | grep --line-buffered -e 'Start denoising\|thread\|Output file will be' | sed 's|  Output file will be|noice out:|g' >> "${SNAPLOG}";

   oiiotool -i "${rawdeno}" --iscolorspace linear --ch R,G,B,A=0 "${inalfa}" --ch R=0,G=0,B=0,A --add --nosoftwareattrib --eraseattrib ".*" -o "${combined}";

   sleep 1;
   mv "${combined}" "${outputfile}";
}
 
SECONDS=0;
doit;
cleanup;
duration=$SECONDS;
emes=$(m.sec2min ${duration});
outbn=`basename ${outputfile}`;
slog "denoised:[${b_inf}] -> [${outbn}] took ${emes}";
