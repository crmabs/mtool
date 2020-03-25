#!/bin/bash


#re-src
m.src(){
    source ${WGPATH}/mtool/m-sanitize.sh
}

btofslash () { echo "$1" | sed 's|\\|/|g'; }
ftobslash () { echo "$1" | sed 's|/|\\|g'; }

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


# 1:src  2:pattern/char
m.countchar(){
    echo "${2}" | awk -F"${1}" '{print NF-1}'
}

# nof .
m.dotcount(){
    local r=$( m.countchar '.' "${1}" );
    echo $r;
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
    local np="";
    m.isnice "${fn}";
    if [[ ! $? == 0 ]]; then
        echo "FIX - ${fn}";
        np=$(m.tonice "${fn}");
        echo "    - ${np}";
    fi
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


m.isnumber(){
    if [[ ! "$1" =~ ^(0|[-]?[1-9]+[0-9]*)$ ]]; then
         
         
        return 1; # $$$ minden booleanosat ilyenre, ami most van az gagyi
    else
         
        return 0;
    fi
}


# <root> <depth|r|c|0> <sh scriptname> <runmode: d=dry ...>
m.runftree(){
    m.ftree "${1}" ${2} | xargs -r -L 1 "${MBAT}/${3}.sh" d
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
