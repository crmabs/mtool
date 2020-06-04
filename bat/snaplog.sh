#!/bash/bin

function s.logtimestamp() {
    date +%A_%H:%M:%S;
}

function resetlog() {
    rm -v -f "${SNAPLOG}";
    touch "${SNAPLOG}";
}

# default - reset and listen
# any arg - join in
function s.mon() {
    if [[ -z "${1}" ]]; then
        resetlog;
    fi
    s.lw "snaplog active. logfile: ${SNAPLOG}";
    tail -n0 -s 1 -F "${SNAPLOG}";
}

# message tag
function s.lw() {
    local mess="${1}";
    if [[ -z "${2}" ]];then
        local prefx="SNPL";
    else
        local prefx="${2}";
    fi
    local datf="$(s.logtimestamp)";
    local logmess="${datf} ${prefx}\\t| ${mess}";
    echo -e "${logmess}" >> "${SNAPLOG}";
    #echo -e "${logmess}";

}

# title tag
function s.sect(){
    s.lw '' "${2}";
    s.lw '' "${2}";
    s.lw "  ${1}" "${2}";
    s.lw '' "${2}";
    s.lw '' "${2}";
    s.lw '' "${2}";
    s.lw '' "${2}";
    s.lw '' "${2}";
}

 



export SNAPLOG="${JOB}/_snaplog.txt";
export -f s.logtimestamp s.lw s.mon s.sect;
