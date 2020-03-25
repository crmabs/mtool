#!/bin/bash

#re-src
m.src(){
    trysource ${WGPATH}/mtool/m-helper.sh
}



m.currnano(){
    local ns=`date +%N`;
    echo ${ns:2:2}${ns:(-4):2};
}

m.currdate(){
    local yearday=`date +%j`;
    local linsec=`date +%s`;
    echo ${yearday}${linsec:(-3)};
}


m.rndstr(){
    local cdate=$(m.currdate);    
    local cnano=$(m.currnano);
    echo ${cdate}${cnano};
}


m.isokvarname(){
    if [[ ! "$1" =~ ^[a-zA-Z_]+[a-zA-Z0-9_]*$ ]]; then
        echo "Invalid bash variable [${1}]";
        echo 0;
        return 1; 
    else
        echo 1;
    fi
}


m.isnumber(){
    if [[ ! "$1" =~ ^(0|[-]?[1-9]+[0-9]*)$ ]]; then
         
         
        return 1; # $$$ minden booleanosat ilyenre, ami most van az gagyi
    else
         
        return 0;
    fi
}


m.isindexvalid(){
    # echo "valid index $2";
    declare -n r=$1;
    local idx=$2;
    local max=${#r[@]};
    # echo " max:$max idx:$idx"
    [[ ! $max -gt 0 ]] && {  echo 0; return 1;}
    [[ ! $idx -ge 0 ]] && {  echo 0; return 1;}
    [[ ! $idx -lt $max ]] && { echo 0; return 1; }
    echo 1;
}


# 1:src  2:pattern/char
m.countchar(){
    echo "${2}" | awk -F"${1}" '{print NF-1}'
}

# nof .
m.dotcount(){
    local r=$( m.countchar '.' "${1}" );
    echo $r;
}

# contains ANY white space characters 
m.hasws(){
    local n="${1}";
    local regexp="[[:space:]]"
    if [[ $n =~ $regexp ]]; then
        return 1;
    else
        return 0;
    fi
}

# ltrim + rtrim
m.trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   
    echo "$var"
}


 
#debug $$$
m.ql(){
    echo "left--$1";
}

#debug $$$
m.qr(){
    echo "$1--right";
}

# returns files from a tree with a given extenension
m.typeintree() {
    find "$1" -name "*.$2" -type f
}

# files in tree
# default depth 1
# <root> [depth|r]
m.ftree() {
    local level=1;
    m.isnumber "${2}";
    if [[ $? -eq 0 ]]; then
        #number
        if [[ $2 -le 0 ]]; then
            level=1;
        else
            level=$2;
        fi
    else
        #letter
        if [[ "${2}" = 'c' ]]; then
            level=1;
        fi

        if [[ "${2}" = 'r' ]]; then
            level=10000;
        fi
    fi

   
    find "$1" -maxdepth ${level} -type f ! -wholename "*/.*";
}

# dirs in tree
# 0 c 1 -n  ==> all mean 1
# not supplied: => 1
# number n supplied => n
# r ==> infinite recursion
m.dtree(){
    local level=1;
    m.isnumber "${2}";
    if [[ $? -eq 0 ]]; then
        #number
        if [[ $2 -le 0 ]]; then
            level=1;
        else
            level=$2;
        fi
    else
        #letter
        if [[ "${2}" = 'c' ]]; then
            level=1;
        fi

        if [[ "${2}" = 'r' ]]; then
            level=10000;
        fi
    fi

    find "$1" -maxdepth ${level} -type d ! -wholename "*/.*";
}

# <root> <depth|r|c|0> <sh scriptname> <runmode: d=dry ...>
m.runftree(){
    m.ftree "${1}" ${2} | xargs -r -L 1 "${MBAT}/${3}.sh" d
}


# duplicate backslash
m.dup_backslash(){
    echo $1 | sed 's|\\|\\\\|g';
}

# remove bslash dupes
m.rem_backslash(){
    echo $1 | sed 's|\\\\|\\|g';
}


# internal for isset
m.isvarexist_w(){
    local "$@" # inject 'name' argument in local scope
    &>/dev/null declare -p "$name" # return 0 when var is present
}

#
# check if variable is set at all
#  works for both scalar and array types
#
# usage
#
# if has_declare name="vars_name" ; then
#   echo "variable present: vars_name=$vars_name"
# fi
#
m.isvarexist() {
    local n="${1}";
    if m.isvarexist_w name="$n"; then
         
        return 0;  # true -> exists
    else
        
        return 1; # false -> not exists
    fi
}

# destroy a variable
m.killvar(){
    unset -v ${1} >/dev/null 2>&1;
}



# filename / vfxname sanitizer
# remove double spaces, space to _, . to -
m.tonice(){
    echo "$1" | sed 's/\ \ */\ /g' | sed 's/\ $//' | sed 's/\ /\_/g' | sed 's/\./\-/g';
}

# handles seq ONLY 
# returns extension like this]
# /q/work/otp/image.0132.png ->  .0132.png
# technically this is the base logic to detect an image seq
#
m.seqext() {
    local n="${1}";
    local res="";

    # mennyivel jobban nez ki, mint a sed-es escapelt cucc
    if [[ "$n" =~ ([-_.][0-9]*[.][A-Za-z]*)[A-Za-z]*$ ]]; then 
        #echo "match: '${BASH_REMATCH[1]}'"; # nem tudom miert az 1es index az...
        res="${BASH_REMATCH[1]}"
    fi

    echo "${res}";
}

# 0/true: 
# SOME true examples
# "image.9.png"         .n.
# "image.0092931.png"   .padn. 
# "image_12.png"        _n.
# "image_0099.png"      
# "image-411.png"
# "wicked.33.png.lajos.huza_1334.tif"  --> _1334.tif  also valid
#
# 1/false: 
# SOME false examples
# "image.png" 
# "image00341.png" expects 2 separators
# "image.final.0234.png" 
# "image1.png" 
m.isseq() {
    local sext=$(m.seqext "${1}");
    if [[ ${#sext} == 0 ]]; then
        return 1;
    fi
    return 0;
}


# .ext 
# .seq.ext
# get the extension
# handles extensions both for
#  path.numbering.ext -> sequence frames
#  path.ext -> single ones
m.vfxext() {
    local n="${1}";
    local res="";
    m.isseq "${n}";
    if [[ $? == 0 ]]; then
        res=$(m.seqext "${n}");
    else
        res=".${n#*.}";
    fi
    echo "${res}";
}

# loads file ($1) info to the global dict ($2)
# <file> -> <dict>
m.dfile() {
    
    local isnic=0; 
    local n="${1}";
    local fnoext="${n%.*}"; # no ext
    local ffile="${n##*/}"; # full filename
    local fdir="${n%/*}"; # directory part
    local parent=${fdir##*/} # parent
    local vext=$(m.vfxext "${ffile}");
    local vname=${ffile%"${vext}"};
    
    # cannot handle case
    if [[ ${#n} == 0 ]]; then
        echo "ERR wtf, empty file to check for nice...";
        return 1; # don't work with empty path
    fi

    # cannot handle case
    # zero dots?
    local fdot=$(m.dotcount "{$ffile}");
    if [[ $fdot == 0 ]]; then
        echo "SKIP file with no extension ${n}"
        return 1; # well valid, don't touch it!
    fi

    # create dict
    m.dnew "$2";

    # from here on -> can be sanitizied

    # dots > 2 ?
    local dots=$(m.dotcount "${vname}");
    if [[ $dots > 0 ]]; then
        isnic=1;
    fi

    # white space?
    local hasws=0;
    m.hasws "${vname}";
    if [[ $? == 1 ]]; then
        isnic=1;
        hasws=1;
    fi

    if [[ $MVRB == 1 ]]; then
        echo "        orig ${n}";
        echo "         dir ${fdir}";
        echo "      no ext ${fnoext}";
        echo "      parent ${parent}";
        echo "   full file ${ffile}";
        echo "    vfx name ${vname}";    
        echo "     vfx ext ${vext}";
        echo "     is nice ${isnic}";
        echo "      has ws ${hasws}";
        echo "        dots ${dots}";
    fi

    m.dadd "${2}" 'fdir' ${fdir};
    m.dadd "${2}" 'fnoext' ${fnoext};
    m.dadd "${2}" 'parent' ${parent};
    m.dadd "${2}" 'ffile' ${ffile};
    m.dadd "${2}" 'vname' ${vname};
    m.dadd "${2}" 'vext' ${vext};
    m.dadd "${2}" 'isnic' ${isnic};
    return $isnic;

}

# load the file info into the singleton dcur dictionary 
# kind of a well-known variable
m.dsel(){
    m.dfile "$1" 'dcur';
    if [[ ! $? == 0 ]]; then
       return 1;
    else 
        return 0;
    fi
}

# is path sanitized?
#  no more then 2 dots (.)
#  no spaces
m.isnice(){
    m.dsel $1;
    if [[ ! $? == 0 ]]; then
       return 1;
    else 
        return 0;
    fi
}


 

m.fix2nice(){
    local fn="${1}";
    local np="nice-stringbe";
    m.isnice "${fn}";
    if [[ ! $? == 0 ]]; then
        echo "FIX - ${fn}";
        np=$(m.tonice "${fn}");
        echo "    - ${np}";
    fi
}

# to linux path
#  supported c:\tibi\v.exr \\server\vv\image.png
m.linpath(){
    local pin="$1";
    local drive_part="";
    local path_part="";
    local wp="";
    if [[ ${pin:1:1} == ":" ]]; then
        drive_part="${pin:0:1}";
        path_part="${pin:2}";
        wp="\\${drive_part}${path_part}";
    else
        wp=${pin};
    fi
    local linp=$(btofslash "${wp}");
    echo "${linp}";
}

# converts to windows path
#
# supported:
# a:/melo a:\melo \\mlno\o /a/melo
#
# NOTE: true (mounted) linux path is not handled!
#  bad: /mnt/a/tibi/lajos/valami.tga  
m.winpath(){

    local drive_part="";
    local path_part="";
    local pin="$1";

    local pin="$1";
    if [[ ${pin:1:3} == ":\\\\"  ]]; then 
        # fusion path detected
        local wp=$(m.rem_backslash "$pin");
        echo "${wp}";
        return 0;
    fi

    if [[ ! ${pin:1:1} == ":" ]]; then
        # /q/work/khb   \\mlno\o\otp
        # echo "net path";
        if [[ ${pin:2:1} == "/" ]]; then
            # /q/work/khb
            # echo "mounted letter";
            drive_part="${pin:1:1}:";
            path_part="${pin:2}";
        else
            
            if [[ ${pin:0:2} == "\\\\" ]]; then
                # \\mlno\o\otp
                # echo "windows mount";
                drive_part="";
                path_part="$pin";
            fi
        fi
    else
        # a:/blala  a:\blaa
        # echo "drive letter";
        drive_part="";
        path_part="${pin}";
    fi

    if [[ -z ${path_part} ]]; then
        # unsupported format
        echo '***ERROR:illegal path ' "${pin}";
        return 0;
    fi


    local raw="${drive_part}${path_part}";
    #echo "raw ${raw}";

    local sles=$(ftobslash "${raw}");
    echo "${sles}";
}

# converts to fusion load/saver path
m.fupath(){
    local pin="$1";
    if [[ ${pin:1:3} == ":\\\\"  ]]; then 
        #already a fusion path
        echo "${pin}";
        return 0;
    fi

    local sles=$(m.winpath "${pin}");
    local fup=$(m.dup_backslash "${sles}");
    echo "${fup}";
}




m.waitjob(){
    local jobkey=$1
    echo "job runs [${jobkey}]"
    while :
    do
        [ ! -f ${MTRASH}/${jobkey}*_key ] && break;
        sleep 1;
    done
    echo "job finished [${jobkey}]"
}

m.remkey(){
    rm -f "${MTRASH}/$1";
}

m.getkey(){
    local postfix=$1;
    [[ -z ${postfix} ]] && postfix="key";
    echo `m.rndstr`"_${postfix}";
}

m.bgexekey(){
    local tkey=$2
    touch ${MTRASH}/$tkey
    start ConEmu64.exe -run ${BBAT}/twrap.bat "$1" $tkey "${@:2}" -new_console:nb
}

m.bgexe(){
    local tkey=$(m.getkey)
    m.bgexekey "$1" $tkey "${@:2}" 
}

m.bgjob(){
    local jobkey=$2
    local tkey=$(m.getkey)
    tkey=${jobkey}_${tkey}
    m.bgexekey "${BBAT}/$1.bat" "$tkey"
}

# blocks the caller but opens a new window
m.fgwindowed(){
    #                bat a1 a2 a3 ...
    ConEmu64.exe -run "$@" -new_console:nb
    
    #echo "this can be captured as returning data";
}

# blocking run in the console
m.fgexe(){
    # echo "fgexe bat:[$1] arg1:[$2] arg2:[$3] a3:[$4] a4:[$5]";
    $@;
    
    #echo "returning with this";
}

# run bat in foreground
m.fgbat(){
     
    local wb=$(m.winpath "$2");
    m.fgexe "${MBAT}/$1.bat" "$wb" "${@:3}";
}

m.bgbat(){
    echo "bgbat bat:[$1] arg1:[$2] ${@:3}";
    m.bgexe "${MBAT}/$1.bat" "${@:2}";
}

m.repext(){
    if [[ -z "$1" ]]; then
        echo "***ERROR no input path!"
        return 0;
    fi
    local outf="${1%.*}";
    echo "${outf}.$2";
}


m.dupe(){
    if [[ -z "$1" ]]; then
        echo "***ERROR no input path!"
        return 0;
    fi
    local outf="${1%.*}";
    echo "${outf}_.$2";
}



# replaces the file's extension to exr 
m.exrnext(){
    local res=$(m.repext $1 'exr');
    echo "${res}";
}

 

m.txnext(){
    local res=$(m.repext $1 'tx');
    echo "${res}";
}

#                1               2             3
#  m.templateio <template name> <in seq path> <out seq path>
#  template name: png2lib
#  input seq: path for fusion loader    \\\\mlno\\o\\otpbank\\pack50_final.1.tga    Q:\\clients\\rocco\\spot\\final.tga
#  output seq path for fusion  saver    \\\\mlno\\o\\otpbank\\pack50_final.1.exr    Q:\\clients\\rocco\\spot\\final.exr
m.templateio() {   
    local cn=$(m.getkey 'c');
    local compname="${MTRASH}/${cn}.comp";
    cat ${MTEMPLATE}/template_$1.comp | sed "s|##INSEQ##|$2|g" | sed "s|##OUTSEQ##|$3|g" > "$compname"
    echo $compname
}
 

# passes parameters to runcomp.bat
#       %BMF_RENDERNODE% %1 -render -start %2 -end %3 -step %4  -pri high -quiet -quit
#  1           2       3     4
# <comp name> <start> <end> <step>
m.runcomp() {
    m.fgbat runcomp $@
}

#  1               2             3              4       5     6
# <template name> <in seq path> <out seq path> <start> <end> <step>
m.templaterender() {
    local comp=$(m.templateio $1 $2 $3);
    m.runcomp ${comp} $4 $5 $6 >/dev/null 2>&1;
    echo $comp;
}

# toplevel - hardcoded for png2lin 1 1 1
#  1
# <png path>
m.runpng2lin() {
    local inp="$1";
    local fin=$(m.fupath "${inp}");
    fin=$(m.dup_backslash "${fin}");
    local fout=$(m.exrnext "${fin}" 'png');
    # echo "inp: [${inp}]";
    # echo "fin: [${fin}]";
    # echo "fout:[${fout}]";
    local comp=$(m.templaterender 'png2lin' "${fin}" "${fout}" 1 1 1);
    rm -f "${comp}";
}

#
# 8bitictx ugyanez, de az tesztelve is van
# elvileg ez is teljesen megoldana a problemankat, de nem volt meg idom tesztelni 
#
#
# png, tif, bmp, jpg, .. any 8bit image format -> .tx
# convert sRGB->linear
#m.8bit2tx() {
#    maketx -v --oiio --checknan -d uint8 --colorconvert sRGB linear -u --stats --filter radial-lanczos3 --opaque-detect --monochrome-detect --format exr $1  >/dev/null 2>&1;
#}

# exr, hdr, ... any floating format -> .tx
# input must be linear
m.float2tx() {
    maketx --hicomp -v --oiio --checknan -d float -u --stats --filter radial-lanczos3 --format exr "$1"  >/dev/null 2>&1;
    local tx=$(m.txnext "${1}");
    echo "${tx}";
}


# jojo, de ez meg gyorsabb:
# oiiotool.exe -i /q/tmp/i/kep.png --colorconvert sRGB linear -o /q/tmp/i/kep_lin.png
#m.8bit2txold(){
#    local pin="$1";
#    local lin=$(m.dupe "${pin}" 'png');
#    local exr=$(m.exrnext "${pin}");
#    local tx=$(m.txnext "${pin}");
#    # sRGB -> 8bit linear exr 
#    iconvert.exe -d byte -g auto -t OpenEXR "${pin}" "${exr}" compression zip >/dev/null 2>&1; 
#    iconvert.exe -d byte -g off -t png "${exr}" "${lin}" >/dev/null 2>&1;
#    # 8bit linear exr -> tx
#   
#    maketx -v --oiio --checknan -d uint8 -u --stats --filter radial-lanczos3 --opaque-detect --monochrome-detect --format tiff -o "${tx}" "${lin}"  >/dev/null 2>&1;
#    rm -f "${exr}";
#    rm -f "${lin}";
#    echo "${tx}";
#}


# any sRGB 8bit -> linear .tx
m.8bit2tx(){
    local pin="$1";
    local lin=$(m.dupe "${pin}" 'png');
    local tx=$(m.txnext "${pin}");
    # any sRGB -> 8bit linear png 
    oiiotool.exe -i "${pin}" --colorconvert sRGB linear -o "${lin}"
    maketx -v --oiio --checknan -d uint8 -u --stats --filter radial-lanczos3 --format tiff -o "${tx}" "${lin}"  >/dev/null 2>&1;
     
    rm -f "${lin}";
    echo "${tx}";
}

# monitors and prints content of a file
m.monitor() {
    touch $1
    tail -n 0 -f $1
}


# ---------------------------- DYNAMIC DICTIONARY -----------------------
# nincs kesz.. annyira megy is
m.dprint(){
    local p="${1}";
    eval  "echo keys   - \${$p[@]}";
    eval  "echo values - \${!$p[@]}";
}

# remove element by key
# returns the removed value
m.drem(){
    local key="${1}";
    [[ ${#key} == 0 ]] && { echo ""; return 0;  }

    elemval=$(m.dget "${1}" "${2}");
    unset $1[$2] >/dev/null 2>&1;
    echo ${elemval};
}


# 0 - OK
# 1 - already exists
m.dnew(){
    local r=0;
    m.isvarexist ${1};
    if [[ $? == 0 ]]; then
        if [[ $MVRB == 1 ]]; then
            echo "WARN dict exists ${1} -=> gets reset!";
        fi

        m.killvar $1 
        m.dnew $1 >/dev/null 2>&1;

    else
        declare -Ag $1;
        #echo "OK - dict created ${1}";
        echo 0;
    fi
}

# set value in a dict by key
# <dictname> <key> <value>
m.dadd(){
    m.isvarexist "${1}";
    if [[ ! $? == 0 ]]; then
        m.dnew "${1}";
    fi

    eval "${1}[${2}]=${3}";
}

# get value from a dict by key
# <dictname> <key> 
m.dget(){
    m.isvarexist "${1}";
    if [[ ! $? == 0 ]]; then
        echo "ERROR cannot get from dict [${1}] - not exists.";
        return 1;
    fi
    eval "echo \${${1}[${2}]}"
}

# nof pairs in dict
m.dsize(){
    eval "echo \${#$1[@]}";
}

# verbose info
m.dinfo(){
    local p="${1}";
    m.isvarexist ${p};
    if [[ ! $? == 0 ]]; then
        echo "no such dict [${p}]";
    else
        
        nof=$(m.dsize $p);
        if [[ $nof == 0  ]]; then
             echo "dict [$p] is empty";
        else
            echo "dict [$p] size:$nof";
            m.dprint "${p}";
        fi
    fi
}


m.dictest(){
    kulcs='kulcsocs';
    valju='varju';
    dname="${1}";
    echo $dname
    m.dnew $dname;
    
    eval "${dname}[${kulcs}]=${valju}";

    m.dadd $dname 'sulyos' 'pecsetes';

    eval ${dname}[sanyi]=4;
    eval ${dname}[basz]=134;
    eval  "echo \${$dname[@]}";
    eval  "echo \${!$dname[@]}";
    m.dinfo $dname;
}



# ---------------------------- DYNAMIC ARRAY -----------------------
# nincs kesz..

  
function m.acount() {
    # m.isvarexist "${1}";
    # [[ ! $? == 0 ]] && { return 1 ; }
    # m.isokvarname "${1}";
    # [[ ! $? == 0 ]] && { return 1 ; }
    declare -n r=$1;
    echo ${#r[@]};
}

# Dynamically create an array by name
# 0 - OK
# 1 - ERR
function m.anew() {
    m.isokvarname "$1";
    [[ ! $? == 0 ]] && { echo 1; return 1 ; }
    
    # $$$ is created check!! 

    declare -g -a $1=\(\)   
}

# append to end of array
function m.aadd() { 
    #[[ ! $(m.isokvarname "$1") == 1 ]] && { echo 1; return 1 ; }
    m.isvarexist "$1";
    [[ ! $? == 0 ]] && { return 1 ; }
    declare -n r=$1
    r[${#r[@]}]=$2
}

# Update an index by position
# <array> <index> <value>
function m.aset() {
    # [[ ! $(m.isokvarname "$1") == 1 ]] && { echo 1; return 1 ; }
    # [[ ! $(m.isvarexist "$1") == 1 ]] && { echo 1; return 1 ; }
    # $$$ index bound check 
    declare -n r=$1 
    r[$2]=$3
}

# ennek getall legyen a neve $$$
# Get the array content ${array[@]}
function m.agetall {
    # [[ ! $(m.isokvarname "$1") == 1 ]] && { echo 1; return 1 ; }
    # [[ ! $(m.isvarexist "$1") == 1 ]] && { echo 1; return 1 ; }
    declare -n r=$1 
    echo ${r[@]}
}

# Get the value stored at a specific index eg. ${array[0]}  
function m.aget() {
    
    # [[ ! $(m.isvarexist "$1") == 1 ]] && {   echo 1; return 1 ; }
    # [[ ! $(m.isokvarname "$1") == 1 ]] && {   echo 1; return 1 ; }
    # [[ ! $(m.isnumber "$2") == 1 ]] && {   echo 1; return 1 ; }

    declare -n r=$1;
    local idx=$2;
    [[ ! $(m.isindexvalid ${!r} ${idx} ) == 1 ]] && {   echo 1; return 1; }
    
    echo ${r[$idx]};
}




m.dynamic_array_demo(){
    array_names=(bob jane dick)

    for name in "${array_names[@]}"
    do
        m.anew dyn_$name
    done

    echo "Arrays Created"
    declare -ag | grep "a dyn_"

    # Insert three items per array
    for name in "${array_names[@]}"
    do
        echo "Inserting dyn_$name abc"
        m.aadd dyn_$name "abc"
        echo "Inserting dyn_$name def"
        m.aadd dyn_$name "def"
        echo "Inserting dyn_$name ghi"
        m.aadd dyn_$name "ghi"
    done

    for name in "${array_names[@]}"
    do
        echo "Setting dyn_$name[0]=first"
        m.aset dyn_$name 0 "first"
        echo "Setting dyn_$name[2]=third"
        m.aset dyn_$name 2 "third"
    done 

    declare -ag | grep 'a dyn_'

    for name in "${array_names[@]}"
    do
        m.arr_get dyn_$name
    done


    for name in "${array_names[@]}"
    do
        echo "bajos--Dumping dyn_$name by index"
        
        local meret=$(m.acount dyn_$name);
        echo "meret $meret";
        local ertt=$(m.aget dyn_$name 2);
        echo "ertek $ertt";
        # Print by index
        for (( i=0 ; i < $meret ; i++ ))
        do
            echo "ciki $i";
            # local ffsz=$(m.aget "dyn_$name" $i)
            # echo "fffaasz $ffsz";
            # echo "dyn_$name[$i]: $ffsz";

        done
    done

    for name in "${array_names[@]}"
    do
        echo "Dumping dyn_$name"
        for n in $(m.arr_get dyn_$name)
        do
            echo $n
        done
    done

}


# ------------------------






# -----------------------------------------
# runs when the file gets sourced

#silent mode
export MVRB=0;


# mtool root
mtool=$(m.linpath "${WGPATH}/mtool");
echo "mtool root: [${mtool}]";

# temp files
[ ! -e "${mtool}/_tmp" ] && mkdir -p "${mtool}/_tmp";
export MTRASH="${mtool}/_tmp";

# fusion comp templates
export MTEMPLATE="${mtool}/template";

# linux path to bat utilities folder
# use m.fgbat() and m.bgbat() to run them
export MBAT="${mtool}/bat"

# windows path to bat utilities
# use this variable in any .bat file
# to access this collection. 
export BBAT=$(m.winpath "${MBAT}");
export PATH="${mtool}/bin:${PATH}"
