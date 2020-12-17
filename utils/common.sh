#!/bin/bash
#************************************************************************************************************
#*
#*    Script Name: common.sh
#*
#*    Description: common utils.
#*
#*    Usage: . common.sh
#*
#*    Author: user_1
#*
#************************************************************************************************************
SUCCESS=0
FAILURE=1
HDFS_FAILURE=2
LFTP_FAILURE=3
FE=101
ERR_PARAM_COUNT=9
ERR_FILE_DELETE_FAILED=10
ERR_SFTP_GET_FAILED=11
ERR_ASSERT_FAILED=12
ERR_CSV_FORMAT=13

function assert           #  If condition false,
{                         #+ exit from script
                          #+ with appropriate error message.
  parent=$(basename "$1")
  caller="$parent [$2]:$0"
  if [ -z "$3" ]          #  Not enough parameters passed
  then                    #+ to assert() function.
    
	E $caller $LINENO ERR_PARAM_COUNT "**$parent**$2**: Not enough params in $0 [$#] [${@:3}]"
	#echo "$@"
    #exit $ERR_PARAM_COUNT   #  No damage done.
  fi
 msg="${@:3}"

  lineno=$2

  astn="\"$3\" = \"$4\""
  if [ ! $astn ] 
  then
  
    ERROR $caller $LINENO "Assertion failed:  \"$astn\""
    #INFO "File \"${script_name}\", line $lineno"    # Give name of file and line number.
    exit $ERR_ASSERT_FAILED
  # else
  #   return
  #   and continue executing the script.
  fi  
} # Insert a similar assert() function into a script you need to debug. 


#NN=notnull
function NN      #  If condition false,
{                     #+ exit from script
                      #+ with appropriate error message.
	#depth=$(($depth+1))
  parent=$(basename "$1")
  caller="$parent [$2]:$FUNCNAME"
  if [ -z "$3" ]          #  Not enough parameters passed
  then                    #+ to assert() function.
    
	E $caller $LINENO ERR_PARAM_COUNT "**$parent**$2**: Not enough params in $FUNCNAME [$#] [${@:3}]"
	#echo "$@"
    #exit $ERR_PARAM_COUNT   #  No damage done.
  fi
 msg="${@:3}"
  
  arg=$3
  eval "val=\$$arg"



  lineno=$2
  fn=`basename "$FUNCNAME"`
  astn="\"$val\" = \"\""

  if [ ${#val} -eq 0 ] 
  then
    ERROR "$caller" $LINENO "NOT NULL Assertion failed [$arg is null] [${@:3}]."
    #NOTNULL "$caller" $LINENO "File \"${script_name}\", line $lineno"    # Give name of file and line number.
    exit $ERR_ASSERT_FAILED
  # else
  #   return
  #   and continue executing the script.
  else
	#echo "$0 $1 $2"
  padlimit=$((20-${#arg}))
  pad=$(printf '%*s' "$padlimit")
  pad=${pad// /.}
	if [ ${#4} -eq 0 ]
	then 
		#NOTNULL "$1:$2|$0" $LINENO  " \"$arg\"$pad[$val]"
		INFO "$1:$2|$FUNCNAME" $LINENO " \"$arg\"$pad[$val]"
	else
		INFO "$1:$2|$FUNCNAME" $LINENO  " \"$arg\"$pad[****]"
	fi
  fi  
  #depth=$(($depth-1))
}

function E {
  parent=$(basename "$1")
  caller="$parent [$2]:$FUNCNAME"
  if [ -z "$3" ]          #  Not enough parameters passed
  then                    #+ to assert() function.
    
	E $caller $LINENO ERR_PARAM_COUNT "**$parent**$2**: Not enough params in $FUNCNAME [$#] [${@:3}]"
	#echo "$@"
    #exit $ERR_PARAM_COUNT   #  No damage done.
  fi
 msg="${@:3}"
 
 scounter=$((scounter+1)) 
  arg=$3
  #NN "$(basename "$1"):$2.$0" $LINENO $arg 
  eval "val=\$$arg"
 m="Terminating [${script_name}]"
 #echo "$val" , "$FE" 
 if [ $val -eq $FE ]
   then
	m='Forced exit...'
 fi
 
 
  fgen=$(printf "%80s");
 filler1=${fgen// /#}
 echo "EXIT${filler1}"
 echo "EXIT${filler1}"
 log "$parent [$2]|E_____[$LINENO]|$m $val [$arg] ${@:4}"
 #log "$parent [$2]|EXIT___|$LINENO|$m $val [$arg] ${@:3}" 
 echo "EXIT${filler1}"
 echo "EXIT${filler1}"

 #status=$val
 #SCRIPTEXIT "$caller" $LINENO $SCRIPTPATH "$msg"
 exit $val
}