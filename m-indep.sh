#!/bin/bash

function m.src_indep(){
    source ${WGPATH}/mtool/m-indep.sh;
}

function btofslash () { echo "$1" | sed 's|\\|/|g'; }
function ftobslash () { echo "$1" | sed 's|/|\\|g'; }

function m.amon() {
    local al="${JOB}/arnoldlog.txt";
    touch "${al}";
    tail -n 0 -f ${al};
}

function m.tonice(){
    echo "$1" | sed 's/\ \ */\ /g' | sed 's/\ $//' | sed 's/\ /\_/g' | sed 's/\./\-/g';
}

function m.seqext() {
    local n="${1}";
    local res="";
    if [[ "$n" =~ ([-_.][0-9]*[.][A-Za-z]*)[A-Za-z]*$ ]]; then 
        res="${BASH_REMATCH[1]}"
    fi
    echo "${res}";
}
 
function m.hasws(){
    local n="${1}";
    local regexp="[[:space:]]"
    if [[ $n =~ $regexp ]]; then
        return 1;
    else
        return 0;
    fi
}
 
function m.countchar(){
    echo "${2}" | awk -F"${1}" '{print NF-1}'
}


function m.isnumber(){
    if [[ ! "$1" =~ ^(0|[-]?[1-9]+[0-9]*)$ ]]; then
        return 1;  
    else
         
        return 0;
    fi
}


# handles lofasz.exr and lofasz.3.exr -> lofasz
function m.fn_base() {
   local fba="${1%.*}";
   echo "${fba%.*}";
}

# color.1.exr tibor.exr -> exr
function m.fn_ext(){
   echo ".${1#*.}";
}

# color.1.exr -> exr
function m.fn_mext() {
   local fba="${1#*.}";
   echo "${fba#*.}";
}


# <root> <depth>
function m.dtree() {
    m.fd_ftree "${1}" $2 'd';
}

# <root> <depth>
function m.ftree() {
    
    # echo "e1root:${1}   E2DEP:${2}  ";
    #  echo ' ';
    m.fd_ftree "${1}" $2 'f';
}


#  1      2       3              4               5
# <root> <depth> <script/line>  <runmode|dry>   <batch param>
function m.runftree(){
    #echo "r1oot:${1} r2dept:${2} r3sh:${3} r4dry:${4} r6bextra:${5}";

    m.ftree "${1}" ${2} | xargs -P 1 -r -L 1 "${MBAT}/${3}.sh" ${4} ${5};
    
}

# the last .ext only
function m.repext(){
    if [[ -z "$1" ]]; then
        echo "***ERROR no input path!"
        return 0;
    fi
    
    local mext=$(m.fn_mext "${1}");
    echo "${1}" | sed "s|${mext}|${2}|g";
   
}


function m.tmpfile(){
    if [[ -z "$1" ]]; then
        echo "***ERROR no input path!"
        return 0;
    fi
    local fb=$(m.fn_base "${1}");
    local outf="${fb}_";
    local inext=$(m.fn_ext "${1}");
    local outext="${inext}";
    if [[ -n "$2" ]]; then
        outext="${2}";
    fi
    echo "${outf}${outext}"
}


function m.side(){
    if [[ -z "$1" ]]; then
        echo "***ERROR no input path!"
        return 0;
    fi

    postfix='';
    if [[ ( -n "${3}" ) ]]; then
        postfix="${3}";
    fi

    local fb=$(m.fn_base "${1}");
    local outf="${fb}${postfix}";
    local origext=$(m.fn_ext "${1}");
    local outext="${origext}";


    local res="${outf}${outext}";

    if [[ ( -n "$2" ) && ( "${2}" != '_' ) ]]; then
        res=$(m.repext "${res}" "${2}");
    fi

    echo "${res}";
}


function m.namekey(){
    local fb=$(basename "${1}");
    echo "${2}${fb}" | sed 's|\.||g' ;
}

function m.waituntilany() {
    local wdir="${1}";
    local wpat="${2}";
    sleep 2;
    local nofbusyfiles=$(find "${wdir}" -name "${wpat}" -type f | wc -l);
    while [[ ${nofbusyfiles} -gt 0 ]]
    do
        sleep 2;
        nofbusyfiles=$(find "${wdir}" -name "${wpat}" -type f | wc -l);
    done
}

# dir nof
function m.waitfornof() {
    local wdir="${1}";
    local wnof=${2};
    local nof=$(ls -1 "${wdir}" | wc -l);
    while [[ ! ${nof} -eq ${wnof} ]]
    do
        sleep 1;
        nof=$(ls -1 "${wdir}" | wc -l);
    done;
}

# remove all new line 
function m.singleline() {
    echo "$(sed ':a;N;$!ba;s/\n/,/g' ${1})";
}

# max 10 char long random string 
function m.rndstr(){
    local yearday=`date +%j`;
    local linsec=`date +%s`;
    local ns=`date +%N`;
    ns=${ns%%00};
    sleep 0.1;
    local nns=`date +%N`;
    nns=${nns%%00};
    echo "${yearday}${linsec:(-3)}${ns:0:2}${nns:0:2}";
}

# remove white space
function m.remws(){
    echo ${1} | sed 's|\s||g';
}

# dir patFile ext
function m.noffiles(){
    #echo "ls -1 "${1}/"*"${2}"*"${3}" | wc -l;";
    local lista=$(ls -1d "${1}/"*"${2}"*"${3}" 2>/dev/null) ;
    if [[ $? -ne 0 ]]; then
        echo '0';
    fi
 
    local szavak=$(echo "${lista}" | wc -w);
    if [[ ${szavak} -eq 0 ]]; then
        # nincsenek szavak - ures sor / sorok
        echo '0';
    else
        echo "${lista}" | wc -l ;
    fi

}

# sec -> Xmin Ysec
function m.sec2min(){
    local em=$((${1} / 60));
    local rs=$((${1} % 60));
    if [[ ( -z "${em}" ) || ( ${em} -eq 0 )]]; then
        echo "${1}s";
    else
        echo "${em}min ${rs}s";
    fi
}


# remove ws 
function m.rwspace(){
    echo "${1}" | sed -e 's/\s\+//g';
}

function m.allchannels(){
    local srci="${1}";
    local ach=$(oiiotool.exe --info -v "${srci}" | grep -e "channel list:" | sed 's|channel list:||g' );
    echo "${ach}";
}

function m.allch_except(){
    local aexc=$(echo $(m.allchannels "${1}") | sed 's|'"${2}"'||g' );
    m.rwspace "${aexc}";
}


# ----------- up: truely independent, down: dependent only from above -----



m.txnext(){
    local res=$(m.repext "$1" 'tx');
    echo "${res}";
}


m.float2graytx() {
    local pin="$1";
     local tx=$(m.txnext "${pin}");
    local gray=$(m.tmpfile "${pin}" 'exr');
    oiiotool.exe -i "${pin}" --iscolorspace linear --chsum:weight=.2126,.7152,.0722 --ch 0,0,0 -o ${gray}
    maketx --hicomp --oiio --fixnan box3 -d float -u --stats --filter radial-lanczos3 --format exr -o "${tx}"  "${gray}"  >/dev/null;
    rm -f "${gray}";
    echo "${tx}";
}

m.float2tx() {
    local tx=$(m.txnext "${1}");
    maketx --hicomp --oiio --fixnan box3 -d float -u --stats --filter radial-lanczos3 --format exr -o "${tx}" "$1"  >/dev/null;
    echo "${tx}";
}


m.8bit2tx(){
    local pin="$1";
    if [[ ! -e "${1}" ]]; then
        echo "file not found:[${pin}]";
        exit 1;
    fi
    
    pin=$(realpath "${pin}");

    # any sRGB -> 8bit linear png
    local lin=$(m.side "${pin}"  'png' '_linear' );
    local tx=$(m.side "${pin}" 'tx' '' );
    #echo "lin:[${lin}]";
    #echo "tx: [${tx}";
    oiiotool.exe -i "${pin}" --colorconvert sRGB linear -o "${lin}"  >/dev/null;
    maketx --oiio -d uint8 -u --format tiff -o "${tx}" "${lin}"  >/dev/null;
    rm -f "${lin}";
    echo "${tx}";
}


#  1       2       3      
# <path> <depth> <f|d>     
m.fd_ftree(){
    #echo "f1Root:${1} f2dept:${2} f3mode:${3}";
    local t='f';
    if [[ "${3}" == 'd' ]]; then
        #echo 'dirmode!';
        t='d'; 
    fi

    local level=1;
    m.isnumber "${2}";
    if [[ $? -eq 0 ]]; then
         
        if [[ $2 -le 0 ]]; then
            level=1;
        else
            level=$2;
        fi
    else
         
        if [[ "${2}" = 'c' ]]; then
            level=1;
        fi

        if [[ "${2}" = 'r' ]]; then
            level=10000;
        fi
    fi




 #echo "f1Root:${1}-f2dept:${level}-f3type:${t}";
# echo '   '
     
    
    find "${1}" -maxdepth ${level}  -type "${t}"   ! -wholename "*/.*";
}




m.dotcount(){
    local r=$( m.countchar '.' "${1}" );
    echo $r;
}
 
m.isseq() {
    local sext=$(m.seqext "${1}");
    if [[ ${#sext} == 0 ]]; then
        return 1;
    fi
    return 0;
}
 
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
 
m.winpath(){
    local drive_part="";
    local path_part="";
    local pin="$1";

    local pin="$1";
    if [[ ${pin:1:3} == ":\\\\"  ]]; then 
        
        local wp=$(m.rem_backslash "$pin");
        echo "${wp}";
        return 0;
    fi

    if [[ ! ${pin:1:1} == ":" ]]; then
         
        if [[ ${pin:2:1} == "/" ]]; then
            
            drive_part="${pin:1:1}:";
            path_part="${pin:2}";
        else
            
            if [[ ${pin:0:2} == "\\\\" ]]; then
                
                drive_part="";
                path_part="$pin";
            fi
        fi
    else
        
        drive_part="";
        path_part="${pin}";
    fi

    if [[ -z ${path_part} ]]; then
        
        echo '***ERROR:illegal path ' "${pin}";
        return 0;
    fi


    local raw="${drive_part}${path_part}";
     

    local sles=$(ftobslash "${raw}");
    echo "${sles}";
}
 

export -f m.rwspace m.allchannels m.allch_except m.side  m.fn_base m.fn_ext m.fn_mext m.namekey m.waituntilany m.singleline m.rndstr m.remws  m.waitfornof m.noffiles m.sec2min m.repext;
 

# -----------------------------------------
# runs when the file gets sourced 

#silent mode
export MVRB=0;


# mtool root
mtool=$(m.linpath "${WGPATH}/mtool");
echo "mtool root: [${mtool}]";

# temp files
#[ ! -e "${mtool}/_tmp" ] && mkdir -p "${mtool}/_tmp";
#export MTRASH="${mtool}/_tmp";

# fusion comp templates
#export MTEMPLATE="${mtool}/template";

# linux path to bat utilities folder
# use m.fgbat() and m.bgbat() to run them
# export MBAT="${mtool}/bat"

# windows path to bat utilities
# use this variable in any .bat file
# to access this collection. 
#export BBAT=$(m.winpath "${MBAT}");
export PATH="${mtool}/bin:${mtool}/bat:${PATH}";


if [[  ${JOB##*/} == 'snap'  ]]; then
    export PATH="${JOB}/bin:${PATH}";
    export PATH="${JOB}/bat:${PATH}";

    echo 'snap bin bat is on path';
else
    echo 'not a snap project';

fi


source snaplog.sh;