#!/bin/bash

function m.src_indep(){
    expsource ${WGPATH}/mtool/m-indep.sh;
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


function m.repext(){
    if [[ -z "$1" ]]; then
        echo "***ERROR no input path!"
        return 0;
    fi
    local outf="${1%.*}";
    echo "${outf}.$2";
}

function m.dupe(){
    if [[ -z "$1" ]]; then
        echo "***ERROR no input path!"
        return 0;
    fi
    local outf="${1%.*}";
    echo "${outf}_.$2";
}

function m.tmpfile(){
    if [[ -z "$1" ]]; then
        echo "***ERROR no input path!"
        return 0;
    fi
    local outf="${1%.*}_";
    local inext="${k#*.}";
    local outext="${inext}";
    if [[ -n "$2" ]]; then
        outext="$2";
    fi
    echo "${outf}.${outext}"
}



function m.title() {
  if [[ -z "$ORIG" ]]; then
    ORIG=$PS1
  fi
  TITLE="\[\e]2;$*\a\]"
  PS1=${ORIG}${TITLE}
}




# ----------- up: truely independent, down: dependent only from above -----



m.txnext(){
    local res=$(m.repext $1 'tx');
    echo "${res}";
}


m.float2graytx() {
    local pin="$1";
     local tx=$(m.txnext "${pin}");
    local gray=$(m.tmpfile "${pin}" 'exr');
    oiiotool.exe -i "${pin}" --chsum:weight=.2126,.7152,.0722 --ch 0,0,0 -o ${gray}
    maketx --hicomp --oiio --fixnan box3 -d float -u --stats --filter radial-lanczos3 --format exr -o "${tx}"  "${gray}"  >/dev/null 2>&1;
    rm -f "${gray}";
    echo "${tx}";
}

m.float2tx() {
    local tx=$(m.txnext "${1}");
    maketx --hicomp --oiio --fixnan box3 -d float -u --stats --filter radial-lanczos3 --format exr -o "${tx}" "$1"  >/dev/null 2>&1;
    echo "${tx}";
}


m.8bit2tx(){
    local pin="$1";
    local lin=$(m.tmpfile "${pin}" 'png');
    local tx=$(m.txnext "${pin}");
    # any sRGB -> 8bit linear png 
    oiiotool.exe -i "${pin}" --colorconvert sRGB linear -o "${lin}"
    maketx --oiio --fixnan box3 -d uint8 -u --stats --filter radial-lanczos3 --format tiff -o "${tx}" "${lin}"  >/dev/null 2>&1;
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

function m.fstore() { 
    filedata[${#filedata[@]}]=$1
}


# 0 - OK - do nothing
# 1 - empty path - nonfixable
# 2 - no extension - nonfixable
# 3 - fixable - fix it!
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
        #echo "ERR wtf, empty file to check for nice...";
        return 1; # don't work with empty path
    fi

    # cannot handle case
    # zero dots?
    local fdot=$(m.dotcount "{$ffile}");
    if [[ $fdot == 0 ]]; then
        #echo "SKIP file with no extension ${n}"
        return 2; # well valid, don't touch it!
    fi

     
    # dots > 2 ?
    local dots=$(m.dotcount "${vname}");
    if [[ $dots > 0 ]]; then
        isnic=3;
    fi

    # white space?
    local hasws=0;
    m.hasws "${vname}";
    if [[ $? == 1 ]]; then
        isnic=3;
        hasws=1;
    fi

    MVRB=1;
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

    m.fstore $fdir;
    m.fstore $vname;
    m.fstore $vext;

    return $isnic;

}

  

 
m.isfixable(){
    

    m.dfile "${1}";
    local res=$?;
    echo "dfile res:${res}----${1}";
    if [[ $res == 3 ]]; then
         
        return 0; #fixable
    fi
    
    if [[ $res == 0 ]]; then
         
        return 1; #ok
    else 
        
        return 1; #unfixable 1 and 2
    fi
}



m.fix2nice(){
    declare -a -g filedata;
    local fn="${1}";
    #echo "${fn}";
    local np="";
    m.isfixable "${fn}";
    #echo "${fn}";
    local res=$?;
    #echo "[res:${res}][${filedata[0]}][${filedata[1]}][${filedata[2]}]";
    local vname="${filedata[1]}";
    echo "vn-(${vname})";
    if [[ ${res} == 0 ]]; then
         echo "fixable ${fn}";
         vname=${filedata[1]};
         np=$(m.tonice "${vname}");
         echo "javitott[${np}]";
         echo ' '
    fi
    unset -v filedata;
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
 

export -f m.fix2nice  m.tonice   m.dfile m.vfxext m.countchar m.hasws m.isseq m.seqext m.dotcount m.isfixable m.fstore 
 

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
export PATH="${mtool}/bin:${PATH}";
