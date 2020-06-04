#!/bin/bash

# version 1.2
# float16 and float32 both supported

 

# 1 input file
# 2 output file
# 3 target dir - optional

 
function slog(){
   s.lw "${1}" 'Flff';
}

inputfile=$(realpath "${1}");
outputfile="${2}";
targetdir="${3}";

me=`basename "$0"`;
 
outb=`basename "${outputfile}"`;
origOut=$(realpath `dirname "${outputfile}"`);
outf="${origOut}/${outb}";
outputfile="${outf}";
slog "${me} output dir: ${origOut}";

 

slog "source:[${inputfile}] result:[${outputfile}]";

indir=$(dirname "${inputfile}");
outbase=$(basename "${outputfile}");
tfil="${indir}/${outbase}";

# intermediate images
inalfa=$(m.side "${tfil}" 'exr' '_inalfa_linear');
albedo=$(m.side "${tfil}" 'exr' '_albedo_linear');
beauty=$(m.side "${tfil}" 'exr' '_beauty_linear');
nobedo=$(m.side "${tfil}" 'exr' '_nobedo_linear');
laplacian=$(m.side "${tfil}" 'exr' '_laplacian_linear');
variance=$(m.side "${tfil}" 'exr' '_variance_linear');
prepared=$(m.side "${tfil}" 'exr' '_prepared_linear');

if [[ ! -z "${targetdir}" ]]; then
   # slog "target dir defined. [${targetdir}]";
   
   lp=$(realpath "${targetdir}");
   if [[ ! -d "${lp}" ]]; then
        mkdir -p "${lp}";
   fi

   inalfa="${lp}/"$(basename "${inalfa}");
   albedo="${lp}/"$(basename "${albedo}");
   beauty="${lp}/"$(basename "${beauty}");
   nobedo="${lp}/"$(basename "${nobedo}");
   laplacian="${lp}/"$(basename "${laplacian}");
   variance="${lp}/"$(basename "${variance}");
   prepared="${lp}/"$(basename "${prepared}");


   [ ${SNAPVERBOSE:-0} -eq 1 ] && slog " final targetdir:[${lp}]";
else
   slog " target dir not defined - using input's folder";
fi


#slog "currd: ${origOut}";
if [[ ! -d "${origOut}" ]]; then
   mkdir -p "${origOut}";
fi
 


function doit(){

   # 0,0,0,A
   oiiotool -i "${inputfile}" --iscolorspace linear --ch R=0,G=0,B=0,A --nosoftwareattrib --eraseattrib ".*" -o ${inalfa} >/dev/null;

   # r -> albedo RGB0
   oiiotool -i "${inputfile}" --iscolorspace linear --ch R=denoise_albedo_noice.R,G=denoise_albedo_noice.G,B=denoise_albedo_noice.B --nosoftwareattrib --eraseattrib ".*" -o ${albedo} >/dev/null;
   
   # r -> beauty RGBA
   oiiotool -i "${inputfile}" --iscolorspace linear --ch R,G,B,A --nosoftwareattrib --eraseattrib ".*" -o ${beauty} >/dev/null;

   # beauty - albedo = nobedo RGBA  - original alpha is preserved
   oiiotool -i ${beauty} --iscolorspace linear --ch R,G,B,A ${albedo} --iscolorspace linear --ch R,G,B,A=0  --sub --nosoftwareattrib --eraseattrib ".*" -o ${nobedo} >/dev/null;

   # nobedo -> abs(laplacian) RGB1
   oiiotool -i ${nobedo} --ch R,G,B,A --iscolorspace linear --laplacian --abs --nosoftwareattrib --eraseattrib ".*" -o ${laplacian} >/dev/null;

  
 
   # load as variance.RGB1
   oiiotool -i ${laplacian} --iscolorspace linear --ch variance.R=R,variance.G=G,variance.B=B,variance.A=1  --nosoftwareattrib --eraseattrib ".*" -o ${variance} >/dev/null;
      
   # variance + other channels + metadata
      oiiotool -i ${variance} --iscolorspace linear "${inputfile}" --iscolorspace linear --chappend --nosoftwareattrib --eraseattrib ".*" \
      --attrib "arnold/aovs/denoise_albedo_noice/filter" "gaussian_filter" \
      --attrib "arnold/aovs/denoise_albedo_noice/filter_width" 2 \
      --attrib "arnold/aovs/denoise_albedo_noice/lpe" 1 \
      --attrib "arnold/aovs/denoise_albedo_noice/lpe_expression" "((C<TD>A)|(CVA)|(C<RD>A))" \
      --attrib "arnold/aovs/denoise_albedo_noice/source" "denoise_albedo" \
      --attrib "arnold/aovs/N_noice/filter" "gaussian_filter" \
      --attrib "arnold/aovs/N_noice/filter_width" 2 \
      --attrib "arnold/aovs/N_noice/source" "N" \
      --attrib "arnold/aovs/RGBA/filter" "gaussian_filter" \
      --attrib "arnold/aovs/RGBA/filter_width" 2 \
      --attrib "arnold/aovs/RGBA/lpe" 1 \
      --attrib "arnold/aovs/RGBA/lpe_expression" "C.*" \
      --attrib "arnold/aovs/RGBA/source" "RGBA" \
      --attrib "arnold/aovs/variance/filter" "variance_filter" \
      --attrib "arnold/aovs/variance/filter_width" 2 \
      --attrib "arnold/aovs/variance/lpe" 1 \
      --attrib "arnold/aovs/variance/lpe_expression" "C.*" \
      --attrib "arnold/aovs/variance/source" "RGBA" \
      --attrib "arnold/aovs/Z_noice/filter" "gaussian_filter" \
      --attrib "arnold/aovs/Z_noice/filter_width" 2 \
      --attrib "arnold/aovs/Z_noice/source" "Z" \
   -o ${prepared} >/dev/null;

   sleep 1;
   
}
 
doit;
