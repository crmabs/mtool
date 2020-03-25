#!/bin/bash

# 1 input file
# 2 output file
# 3 black point
# 4 .. extra input images

inputfile="${1}";
outputfile="${2}";
blackpoint=${3};   # 0.0065 pl egy jo szam
varparam=${4}; #  def: 0.5 
searchradius=${5}; # def:12
patchradius=${6}; # def:3
extraimages=${@:7}; # additional images
me=`basename "$0"`;

dbpnt=0.0065;
dvarp=0.5;
dsrad=12;
dpatrad=3;

if [[ ( $inputfile == '--help' ) || ( $inputfile == '-h' )  || ( $inputfile == '--h' ) || ( $inputfile == '-help' ) || ( -z $inputfile ) ]]; then
   echo ' '
   echo 'noicew'
   echo "  Wrapper for arnold denoiser 'noice'. Prepares the input image to be fed to noice denoiser.";
   echo "  The input does't have to be made with Arnold renderer but requires the following image planes:";
   echo '  R, G, B, A, Z_noice, N_noice.Y, N_noice.Z, N_noice.X, denoise_albedo_noice.R, denoise_albedo_noice.G, denoise_albedo_noice.B';
   echo ' ';
   echo 'arguments:';
   echo '  '$me '<input file>  <output file>  <black point>  <variance threshold>  <search radius>  <patch radius>  <extra images..>';
   echo ' ';
   echo 'shortcuts 1:   d gets replaced with the default values';
   echo '  '$me 'input_file output_file d d d d extra_images..';
   echo '  '$me 'input_file output_file d d d 4 extra_images..';
   echo '  '$me 'input_file output_file d d 15 d';
   echo ' ';
   echo 'shortcuts 2:   a sets all params to default';
   echo '  '$me 'input_file output_file a';
   echo '  '$me 'input_file output_file a extra_images..';
   echo ' ';
   echo 'default values:';
   echo '  black point:' $dbpnt;
   echo '  variance:' $dvarp;
   echo '  search radius:' $dsrad;
   echo '  patch radius:' $dpatrad;
   exit 0;
fi


if [[ ( $blackpoint == 'd' )  ]]; then
   blackpoint=$dbpnt;
fi

if [[ $varparam == 'd' || ( -z $varparam ) ]]; then
   varparam=$dvarp;
fi

if [[ $searchradius == 'd' || ( -z $searchradius ) ]]; then
   searchradius=$dsrad;
fi

if [[ $patchradius == 'd' || ( -z $patchradius ) ]]; then
   patchradius=$dpatrad;
fi

if [[ $blackpoint == 'a' || ( -z $blackpoint ) ]]; then
   blackpoint=$dbpnt;
   varparam=$dvarp;
   searchradius=$dsrad;
   patchradius=$dpatrad;
   extraimages=${@:4};
fi


echo '  source:       ' $inputfile;
echo '  result:       ' $outputfile;
echo '  black point:  ' $blackpoint;
echo '  variance:     ' $varparam;
echo '  search radius:' $searchradius;
echo '  patch radius: ' $patchradius;
echo '  extra images: ' $extraimages;

# intermediate images
albedo='_albedo.exr';
beauty='_beauty.exr';
nobedo='_nobedo.exr';
laplacian='_laplacian.exr';
clamped='_clamped.exr';
variance='_variance.exr';
prepared='_prepared.exr';


function cleanup(){
   rm -f $albedo $beauty $nobedo $laplacian $clamped $variance $prepared;
}



function doit(){
   # r -> albedo RGB0
   oiiotool -i "${inputfile}" --ch R=denoise_albedo_noice.R,G=denoise_albedo_noice.G,B=denoise_albedo_noice.B --nosoftwareattrib --eraseattrib ".*" -o $albedo;
   
   # r -> beauty RGBA
   oiiotool -i "${inputfile}" --ch R,G,B --nosoftwareattrib --eraseattrib ".*" -o $beauty;

   # beauty - albedo = nobedo RGBA  - original alpha is preserved
   oiiotool -i $beauty $albedo  --sub --nosoftwareattrib --eraseattrib ".*" -o $nobedo;

   # nobedo -> abs(laplacian) RGB1
   oiiotool -i $nobedo --ch R,G,B --laplacian --abs --nosoftwareattrib --eraseattrib ".*" -o $laplacian;

   # laplacian -> blacked
   # clamp01 ( sub(black point ) )
   oiiotool -i $laplacian --subc ${blackpoint} --clamp:min=0:max=1 --nosoftwareattrib --eraseattrib ".*" -o $clamped;
 
   # load as variance.RGB1
   oiiotool -i $clamped --ch variance.R=R,variance.G=G,variance.B=B,variance.A=1  --nosoftwareattrib --eraseattrib ".*" -o $variance;
      
   # variance + other channels + metadata
   oiiotool -i $variance "${inputfile}" --chappend --nosoftwareattrib --eraseattrib ".*" \
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
   -o $prepared;

   

   noice -i $prepared  "${extraimages}" -o "${outputfile}" -v $varparam -sr $searchradius -pr $patchradius; 

}

SECONDS=0;
doit;
cleanup;
duration=$SECONDS;
outbn=`basename ${outputfile}`;
echo "${outbn} denoised. took $(($duration / 60)) min $(($duration % 60)) sec";