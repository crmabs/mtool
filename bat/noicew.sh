#!/bin/bash

# version 1.3
# float16 and float32 both supported

# 1 input file
# 2 output file


function slog(){
   s.lw "NOCW ${1}";
}

# defaults
dvarp=0.9;
dsrad=9;
dpatrad=3;


me=`basename "$0"`;

function dumphelp(){
   echo ' '
   echo '     noicew'
   echo "  Wrapper for arnold denoiser 'noice'. Prepares the input image to be fed to noice denoiser.";
   echo "  The input does't have to be made with Arnold renderer but requires the following image planes:";
   echo '  R, G, B, A, Z_noice, N_noice.Y, N_noice.Z, N_noice.X, denoise_albedo_noice.R, denoise_albedo_noice.G, denoise_albedo_noice.B';
   echo ' ';
   echo 'arguments:';
   echo '  '${me} '<input file>  <output file>   <variance threshold>  <search radius>  <patch radius> ';
   echo ' ';
   echo 'shortcuts 1:   d gets replaced with the default values';
   echo '  '${me} 'input_file output_file d d d ';
   echo '  '${me} 'input_file output_file d d 4 ';
   echo '  '${me} 'input_file output_file d 15 d';
   echo ' ';
   echo 'shortcuts 2:   a sets all params to default';
   echo '  '${me} 'input_file output_file a';
   echo ' ';
   echo 'default values:';
   echo '  variance:' ${dvarp};
   echo '  search radius:' ${dsrad};
   echo '  patch radius:' ${dpatrad};
   exit 0;
}

if [[ ( -n ${1} ) && ( -z ${2} ) ]]; then
   echo 'ERROR -- output file not specified.';
   dumphelp;
   exit 1;
fi

if [[ ( -z ${1} ) || ( ${1} == '--help' ) || ( ${1} == '-help' ) || ( ${1} == '--h' ) || ( ${1} == '-h' ) || ( ${1} == 'help' ) || ( ${1} == 'h' ) ]] ; then
   dumphelp;
   exit 0;
fi

inputfile=$(realpath "${1}");
outputfile=$(realpath "${2}");
 
varparam=${3}; #  def: 0.5 
searchradius=${4}; # def:12
patchradius=${5}; # def:3



outbase=`basename "${outputfile}"`;
outfolder=$(realpath `dirname "${outputfile}"`);
outputfile="${outfolder}/${outbase}";
slog "${me} output dir: ${outfolder}";

if [[ ! -d "${outfolder}" ]]; then
   mkdir -p "${outfolder}";
fi



currentDir="${outfolder}";
slog "output dir: ${currentDir}";




if [[ ( "${inputfile}" == '--help' ) || ( "${inputfile}" == '-h' )  || ( "${inputfile}" == '--h' ) || ( "${inputfile}" == '-help' ) || ( -z "${inputfile}" ) ]]; then
   dumphelp;
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

slog "  NOICEW"
slog "  source:        ${inputfile}";
slog "  result:        ${outputfile}";
slog "  variance:      ${varparam}";
slog "  search radius: ${searchradius}";
slog "  patch radius:  ${patchradius}";

# intermediate images
inalfa=$(m.side "${inputfile}" 'exr' '_inalfa_linear');
albedo=$(m.side "${inputfile}" 'exr' '_albedo_linear');
beauty=$(m.side "${inputfile}" 'exr' '_beauty_linear');
nobedo=$(m.side "${inputfile}" 'exr' '_nobedo_linear');
laplacian=$(m.side "${inputfile}" 'exr' '_laplacian_linear');
variance=$(m.side "${inputfile}" 'exr' '_variance_linear');
prepared=$(m.side "${inputfile}" 'exr' '_prepared_linear');
rawdeno=$(m.side "${inputfile}" 'exr' '_rawdeno_linear');
combined=$(m.side "${inputfile}" 'exr' '_combined_linear');


#slog "inalfa: [${inalfa}]  albedo: [${albedo}]";


function cleanup(){
rm -f "${inalfa}";
rm -f "${albedo}";
rm -f "${beauty}";
rm -f "${nobedo}";
rm -f "${laplacian}";
rm -f "${variance}";
rm -f "${prepared}";
rm -f "${rawdeno}";
rm -f "${combined}";
}



function doit(){

   noicepre.sh "${inputfile}" "${outputfile}";
   noicepost.sh "${inputfile}" "${outputfile}" ${varparam} ${searchradius} ${patchradius};
}
 
SECONDS=0;
doit;
cleanup;
duration=$SECONDS;
emes=$(m.sec2min ${duration});
outbn=`basename ${outputfile}`;
slog "result: ${outbn} took ${emes}";
echo "${outputfile}";