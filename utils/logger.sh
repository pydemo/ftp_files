#!/bin/bash
#************************************************************************************************************
#*
#*    Script Name: logger.sh
#*
#*    Description: log support utils.
#*
#*    Usage: . looger.sh
#*
#*    Author: ob66759
#*
#************************************************************************************************************
depth=0
NULL=''
hn=$(hostname)

counter=0
scounter=0
maxlen=17
bytlen=${#script_name}

diff=$(($maxlen-$bytlen))

fgen=$(printf "%${diff}s"); 
filler=${fgen// /_}
 
fgen=$(printf "%8s");
u_filler=${fgen// / }

INFO_LEN=50
 
 
#echo $bytlen $diff, $filler
snpadded="${script_name}${filler}"



function _ENTRY_ {
#SFTP_WAIT_SECONDS=`expr ${SFTP_WAIT_MINS} '*' 60`
#CURR_UNIX_TIME=`date +%s`
#SFTP_END_TIME=`expr ${CURR_UNIX_TIME} + ${SFTP_WAIT_SECONDS}`

 elapsed["$1"]=`date +%s`
 elapsed["ms_$1"]=`date +%s%N`
 

 depth=$(($depth+1))
 parent=`basename "$1"`
 padlimit=$(($depth*2))
pad=$(printf '%*s' "$padlimit")
pad=${pad// /|}

 #echo "$pad entering \"${1}\""
 log "$pad->ENTERING FUNCTION: \"$2\""  
status=$FAILURE
}

function _EXIT_ {

 padlimit=$(($depth*2))
pad=$(printf '%*s' "$padlimit")
pad=${pad// /|}  


secs=$((`date +%s` - ${elapsed["$1"]}))
msecs=$((`date +%s%N` - ${elapsed["ms_$1"]}))
 log "${pad}<-EXITING FUNCTION: \"$2\" STATUS: [$4]    ELAPSED: [$(( ${secs} / 3600 ))h $(( (${secs} / 60) % 60 ))m $(( ${msecs}/1000000 /1000 % 60))s $(( ${msecs}/1000000%1000 ))ms]"

 #echo "$pad exiting \"${1}\""
 depth=$(($depth-1))
}


function NOTNULL {
  if [ -z "$3" ]          #  Not enough parameters passed
  then                    #+ to assert() function.
    echo "Not enough params in $FUNCNAME [$1] [${FUNCNAME[1]}]"
	echo "$@"
    exit $ERR_PARAM_COUNT   #  No damage done.
  fi
 msg="${@:3}"
 fn=`basename "$1"`
 caller="$parent [$2]:$FUNCNAME"
 caller="$1:$2|$FUNCNAME"
dpadlimit=$(($depth*2))
dpad=$(printf '%*s' "$dpadlimit")
dpad=${dpad// /|} 
 padlimit=$(($INFO_LEN-${#caller}-${#LINENO}));pad=$(printf '%*s' "$padlimit");pad=${pad// /.}; log "$dpad$caller:$LINENO$pad|INFO${u_filler}|$msg" 
}

function INFO {
  parent=$(basename "$1")
  caller="$1:$2|$FUNCNAME"
  if [ -z "$3" ]          #  Not enough parameters passed
  then                    #+ to assert() function.
    
	E $caller $LINENO ERR_PARAM_COUNT "**$parent**$2**: Not enough params in $FUNCNAME [$#] [${@:3}]"
	#echo "$@"
    #exit $ERR_PARAM_COUNT   #  No damage done.
  fi
 msg="${@:3}"
dpadlimit=$(($depth*2))
dpad=$(printf '%*s' "$dpadlimit")
dpad=${dpad// /|}

padlimit=$(($INFO_LEN-${#caller}-${#LINENO}));pad=$(printf '%*s' "$padlimit");pad=${pad// /.}; log "$dpad$caller:$LINENO$pad|INFO${u_filler}| $msg" 

}


function WARNING {

  parent=$(basename "$1")
  caller="$parent [$2]:$0"
  if [ -z "$3" ]          #  Not enough parameters passed
  then                    #+ to assert() function.
    
	E $caller $LINENO ERR_PARAM_COUNT "**$parent**$2**: Not enough params in $0 [$#] [${@:3}]"
	#echo "$@"
    #exit $ERR_PARAM_COUNT   #  No damage done.
  fi
 msg="${@:3}"
 
 wcounter=$((wcounter+1))

 fgen=$(printf "%20s");
 filler1=${fgen// /#}
 
padlimit=$((5-${#2}))
pad=$(printf '%*s' "$padlimit")
pad=${pad// /_}

 echo "WARNING${filler1} #${wcounter}"
 echo "WARNING${filler1}"
 log "$parent [$2$pad]|WARNING_____|$LINENO|$msg" 
 echo "WARNING${filler1}"
 echo "WARNING${filler1}"

}

function SCRIPTEXIT {
 cfn="${FUNCNAME[1]}"
 parent=`basename "$1"`
 caller="$parent [$2]:$0"
 fgen=$(printf "%80s");
 filler3=${fgen// /=}
 echo ${filler3}

secs=$((`date +%s` - ${elapsed["$parent"]}))
msecs=$((`date +%s%N` - ${elapsed["ms_$parent"]}))
 #log "${pad}||EXITING FUNCTION: \"$2\" STATUS: [$4]    ELAPSED: [$(( ${secs} / 3600 ))h $(( (${secs} / 60) % 60 ))m $(( ${msecs}/1000000 /1000 ))s $(( ${msecs}/1000000%1000 ))ms]"

 
 log "$depth|$parent [$2]|SCRIPTEXIT [$LINENO]|[$scounter errors] [$wcounter warnings]     ELAPSED: [$(( ${secs} / 3600 ))h $(( (${secs} / 60) % 60 ))m $(( ${msecs}/1000000 /1000 % 60))s $(( ${msecs}/1000000%1000 ))ms]"
 echo ${filler3}
 #log "SCRIPTEXIT|Exit status: [[$scounter]]" 
}


function SCRIPTENTRY {
parent=$(basename "$1")
 elapsed["$parent"]=`date +%s`
 elapsed["ms_$parent"]=`date +%s%N`
  
  caller="$parent [$2]:$0"
  if [ -z "$3" ]          #  Not enough parameters passed
  then                    #+ to assert() function.
    
	E $caller $LINENO ERR_PARAM_COUNT "**$parent**$2**: Not enough params in $0 [$#] [${@:3}]"
	#echo "$@"
    #exit $ERR_PARAM_COUNT   #  No damage done.
  fi
 msg="${@:3}"
 
 
 location=$3
 args=$4


 fn=`basename "$0"`
 fgen=$(printf "%100s");
 filler1=${fgen// /=}
 


 log "$depth|$parent:$2|SCRIPTENTRY [$LINENO]|$location/$script_name $args" 
}



function TEST {

[ $IS_TEST -eq 1 ] && return 0 || return 1
}

function on {
#ENTRY $0 $LINENO  $@

	return 0 
}

function off {

	return 1
}


function ERROR {
  parent=$(basename "$1")
  if [ -z "$3" ]          #  Not enough parameters passed
  then                    #+ to assert() function.
    caller="$parent [$2]:$0"
	E $caller $LINENO ERR_PARAM_COUNT "**$parent**$2**: Not enough params in $0 [$#] [${@:3}]"
	#echo "$@"
    #exit $ERR_PARAM_COUNT   #  No damage done.
  fi
 msg="${@:3}"
 caller="$(basename "$1"):$2.$0"
 
 #INFO $caller $LINENO $(type NN) 

 status=$3
 

 fn=`basename "$0"`
 fgen=$(printf "%42s");
 filler1=${fgen// /#}
 
 if [ "$FE" = "$status" ] 
   then
  ex='FORCED_EXIT'
 else
  ex='ERROR'
 fi
 caller="$(basename "$1"):$2.$0"
 echo "${script_name}|${filler1}$ex"
 echo "${script_name}|${filler1}$ex" 
 echo "${script_name}|${filler1}$ex" 
 log "$depth|$parent [$2]|ERROR__|$LINENO|${@:3}" 
 echo "${script_name}|${filler1}$ex" 
 echo "${script_name}|${filler1}$ex" 
 echo "${script_name}|${filler1}$ex" 


}

