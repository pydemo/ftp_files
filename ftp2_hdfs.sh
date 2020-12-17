#!/bin/bash
#************************************************************************************************************
#*
#*    Script Name: ftp2_hdfs.sh
#*
#*    Description: this script is used for downloading  control file from sftp location.
#*
#*    Usage: ./ftp2_hdfs.sh SOURCE_SERVER REMOTE_CTRL_FILE_LOC STAGE_LOC FTP_USER
#*
#*	  Example:
#*			./ftp2_hdfs.sh  $(hostname -f) '~/server/control_file_TEST.csv' '/user/gfolyrep/uno_ref/stage' ob66759
#*
#*    Author: ob66759
#*
#************************************************************************************************************
#set -e


IS_TEST=0



if [[ ! "${#@}" -eq "4" ]]; then
	echo  "ERROR: Missing parameter."	
	echo "
#************************************************************************************************************
#*    Usage: ./ftp2_hdfs.sh SOURCE_SERVER REMOTE_CTRL_FILE_LOC STAGE_LOC FTP_USER
#*
#*	  Set FTP_PWD: $ . spwd
#*
#*	  Example:
#*			./ftp2_hdfs.sh  $(hostname -f) '~/server/control_file_TEST.csv' '/user/gfolyrep/uno_ref/stage' ob66759
#************************************************************************************************************"	
	echo "Exiting..."
	exit 1
fi
	
#exit
typeset -A control
typeset -A elapsed






function log {
    LOG_LINE=`date "+%Y-%m-%d %H:%M:%S"`" $1"
    echo $LOG_LINE
}

SCRIPT=$(basename -- "$0")
script_name=$(basename $0)
sn=$script_name

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"



TMP_DIR="${TMPDIR-/tmp}"









SCRIPT="$(readlink --canonicalize-existing "$0")"
SCRIPTPATH="$(dirname "$SCRIPT")"
export SCRIPTPATH

#. $SCRIPTPATH/utils/common.sh
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


#. $SCRIPTPATH/utils/common.sh
#!/bin/bash
#************************************************************************************************************
#*
#*    Script Name: common.sh
#*
#*    Description: common utils.
#*
#*    Usage: . common.sh
#*
#*    Author: ob66759
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
#. $SCRIPTPATH/utils/lftp.sh
#!/bin/bash 
#************************************************************************************************************
#*
#*    Script Name: common.sh
#*
#*    Description: common utils.
#*
#*    Usage: . common.sh
#*
#*    Author: ob66759
#*
#************************************************************************************************************




function lftp_get_file {
	mod=$(basename "${BASH_SOURCE[0]}")
	_ENTRY_ $1  "$mod->$FUNCNAME" $LINENO  $@
	
   remote_file_name=$2
   local_file_name=$3
   SOURCE_SERVER=$4
   SFTP_USERID=$5
   SFTP_PASSWORD=$6
    NN "$1|$FUNCNAME" $LINENO remote_file_name
	NN "$1|$FUNCNAME" $LINENO local_file_name
	NN "$1|$FUNCNAME" $LINENO SOURCE_SERVER

	NN "$1|$FUNCNAME" $LINENO SFTP_USERID
	NN "$1|$FUNCNAME" $LINENO SFTP_PASSWORD 0
   
   INFO "$1|$FUNCNAME" $LINENO "Invoking LFTP GET command"
   home=$PWD
	local_dir=$(dirname "${local_file_name}")
	file_name=$(basename "${local_file_name}")
	
	NN "$1|$FUNCNAME" $LINENO local_dir
	NN "$1|$FUNCNAME" $LINENO file_name
	
	cd $local_dir

   out=$(lftp -c "open sftp://${SOURCE_SERVER}; user $SFTP_USERID $SFTP_PASSWORD; get $remote_file_name"  2>&1) 
   
   status="$?"
   cd $home
	[ ! "$status" -eq "0" ] && E "$1|$FUNCNAME" $LINENO LFTP_FAILURE "Cannot lftp/get file [$file_name].\n$out"

	NN "$1|$FUNCNAME" $LINENO status
	[ ! -f $local_file_name ] && E "$1|$FUNCNAME" $LINENO FAILURE "Download failed [$local_file_name]."

   INFO "$1|$FUNCNAME" $LINENO "lftp [$file_name] STATUS: [$status]"

_EXIT_ $1  "$mod->$FUNCNAME" $LINENO $status $@
}



function lftp_get_dir {
	mod=$(basename "${BASH_SOURCE[0]}")
	_ENTRY_ $1  "$mod->$FUNCNAME" $LINENO  $@
	
   remote_dir_name=$2
   local_dir_name=$3
   SOURCE_SERVER=$4
   SFTP_USERID=$5
   SFTP_PASSWORD=$6
    NN "$1|$FUNCNAME" $LINENO remote_dir_name
	NN "$1|$FUNCNAME" $LINENO local_dir_name
	NN "$1|$FUNCNAME" $LINENO SOURCE_SERVER

	NN "$1|$FUNCNAME" $LINENO SFTP_USERID
	NN "$1|$FUNCNAME" $LINENO SFTP_PASSWORD 0
   
   INFO "$1|$FUNCNAME" $LINENO "Invoking LFTP GET command"
	#cur_dir=$PWD
	#cd $local_dir_name
   out=$(lftp -c "open sftp://${SOURCE_SERVER}; user $SFTP_USERID $SFTP_PASSWORD; mirror --verbose --use-pget-n=8 -c --verbose  $remote_dir_name $local_dir_name"  2>&1) 
   status="$?"
	[ ! "$status" -eq "0" ] && E "$1|$FUNCNAME" $LINENO FAILURE "Cannot lftp/get dir [$remote_dir_name].\n$out"
	
	

	NN "$1|$FUNCNAME" $LINENO status
	
    INFO "$1|$FUNCNAME" $LINENO "DIR: lftp [$remote_dir_name] STATUS: [$status]"

_EXIT_ $1  "$mod->$FUNCNAME" $LINENO $status $@
}

#local vs remote file size match
function lftp_assert_fs {
	mod=$(basename "${BASH_SOURCE[0]}")
	_ENTRY_ $1  "$mod->$FUNCNAME" $LINENO  $@
	
   remote_dir_name=$2
   local_dir_name=$3
   SOURCE_SERVER=$4
   SFTP_USERID=$5
   SFTP_PASSWORD=$6
    NN "$1|$FUNCNAME" $LINENO remote_dir_name
	NN "$1|$FUNCNAME" $LINENO local_dir_name
	NN "$1|$FUNCNAME" $LINENO SOURCE_SERVER

	NN "$1|$FUNCNAME" $LINENO SFTP_USERID
	NN "$1|$FUNCNAME" $LINENO SFTP_PASSWORD 0
   
   INFO "$1|$FUNCNAME" $LINENO "Invoking LFTP GET command"


	cd $local_dir_name; ls -lS *.csv|awk '{print $5,$9}' |while IFS=" " read  col1 col2
	do
		INFO $sn $LINENO "File size = $col1, file name = $col2"
		local_fsize=$col1
		local_fname=$col2
		NN "$1|$FUNCNAME" $LINENO local_fsize
		NN "$1|$FUNCNAME" $LINENO local_fname		
		out=$(lftp -c "open sftp://${SOURCE_SERVER}; user $SFTP_USERID $SFTP_PASSWORD; cd $remote_dir_name; du --bytes  $local_fname" 2>&1)
		[ ! "$?" -eq "0" ] && E "$1|$FUNCNAME" $LINENO FAILURE "Cannot du remote dir [$remote_dir_name].\n$out"
		NN "$1|$FUNCNAME" $LINENO out
		remote_fsize=$(echo $out| awk -F' ' '{print $1}')
		remote_fname=$(echo $out| awk -F' ' '{print $2}')
		NN "$1|$FUNCNAME" $LINENO remote_fsize
		NN "$1|$FUNCNAME" $LINENO remote_fname
		if test $local_fsize -eq $remote_fsize; then
			INFO "$1|$FUNCNAME" $LINENO "Filesize match for [$local_fname/$local_fsize]"
		else
			E "$1|$FUNCNAME" $LINENO FAILURE "ERROR: File size mismatch for  [$local_fname]: $local_fsize <> $remote_fsize." 
		fi
	done 
INFO "$1|$FUNCNAME" $LINENO "FTP vs. LOCAL: File sizes match."
_EXIT_ $1  "$mod->$FUNCNAME" $LINENO $status $@
}


function lftp_assert_de {
	mod=$(basename "${BASH_SOURCE[0]}")
	_ENTRY_ $1  "$mod->$FUNCNAME" $LINENO  $@
	
   remote_dir_name=$2
   
   SOURCE_SERVER=$3
   SFTP_USERID=$4
   SFTP_PASSWORD=$5
    NN "$1|$FUNCNAME" $LINENO remote_dir_name
	
	NN "$1|$FUNCNAME" $LINENO SOURCE_SERVER

	NN "$1|$FUNCNAME" $LINENO SFTP_USERID
	NN "$1|$FUNCNAME" $LINENO SFTP_PASSWORD 0
   
   INFO "$1|$FUNCNAME" $LINENO "Invoking LFTP GET command"

   out=$(lftp -c "open sftp://${SOURCE_SERVER}; user $SFTP_USERID $SFTP_PASSWORD; ls $remote_dir_name")
   status="$?"
	[ ! "$status" -eq "0" ] && E "$1|$FUNCNAME" $LINENO FAILURE "Cannot lftp/asser_de [$remote_dir_name].\n$out"

	NN "$1|$FUNCNAME" $LINENO status
	INFO "$1|$FUNCNAME" $LINENO "DIR: lftp [$remote_dir_name] STATUS: [$status]"
_EXIT_ $1  "$mod->$FUNCNAME" $LINENO $status $@
}

function lftp_assert_fc {
	mod=$(basename "${BASH_SOURCE[0]}")
	_ENTRY_ $1  "$mod->$FUNCNAME" $LINENO  $@
	
   remote_dir_name=$2
   local_dir_name=$3
   SOURCE_SERVER=$4
   SFTP_USERID=$5
   SFTP_PASSWORD=$6
    NN "$1|$FUNCNAME" $LINENO remote_dir_name
	NN "$1|$FUNCNAME" $LINENO local_dir_name
	NN "$1|$FUNCNAME" $LINENO SOURCE_SERVER

	NN "$1|$FUNCNAME" $LINENO SFTP_USERID
	NN "$1|$FUNCNAME" $LINENO SFTP_PASSWORD 0 
   
   INFO "$1|$FUNCNAME" $LINENO "Invoking LFTP GET command"
	
   out=$(diff <(lftp -c "open sftp://${SOURCE_SERVER}; user $SFTP_USERID $SFTP_PASSWORD; cd $remote_dir_name; cls -l *.csv|wc -l") <(ls -l $local_dir_name/*.csv|wc -l) 2>&1)
	status="$?"
	[ ! "$status" -eq "0" ] && E "$1|$FUNCNAME" $LINENO FAILURE "Cannot lftp/count files [$remote_dir_name].\n$out"
	

#status="$?"
NN "$1|$FUNCNAME" $LINENO status

   INFO "$1|$FUNCNAME" $LINENO "DIR: lftp [$remote_dir_name] STATUS: [$status]"
   if [ "$out" == "" ];then
		INFO "$1|$FUNCNAME" $LINENO 'Count match.' 
	else
		
		
		E "$1|$FUNCNAME" $LINENO FAILURE "DIFF report: [$out]." 
	fi


_EXIT_ $1  "$mod->$FUNCNAME" $LINENO $status $@
}


#. $SCRIPTPATH/utils/file_utils.sh
#!/bin/bash 
#************************************************************************************************************
#*
#*    Script Name: file_utils.sh
#*
#*    Description: file utils.
#*
#*    Usage: . file_utils.sh
#*
#*    Author: ob66759
#*
#************************************************************************************************************




function del_file {
mod=$(basename "${BASH_SOURCE[0]}")
_ENTRY_ $1 "$mod->$FUNCNAME" $LINENO  $@

 file_name=$2
 NN "$1|$FUNCNAME" $LINENO file_name
 if [ ! -f $file_name ]; then
    INFO "$1|$FUNCNAME" $LINENO "File [$file_name] does not exists. Passing..."
	
 else
  rm -rf ${file_name}
  if [[ "$?" -eq "FUNCNAME" ]]
   then      
		status=$SUCCESS
       INFO "$1|$FUNCNAME" $LINENO "File [$file_name] is DELETED."
   else
		_EXIT_ "$FUNCNAME" $LINENO $status $@	
       E "$1|$FUNCNAME" $LINENO ERR_FILE_DELETE_FAILED "ERROR: Cannot remove file [$file_name]." 
   fi
 fi
_EXIT_ $1 "$mod->$FUNCNAME" $LINENO $status $@	
}

# "$1|$FUNCNAME:$LINENO"  $fname
function assert_fe {
mod=$(basename "${BASH_SOURCE[0]}")
_ENTRY_ $1  "$mod->$FUNCNAME" $LINENO  $@
 file_name=$2
 NN "$1|$FUNCNAME" $LINENO file_name
 if [ ! -f $file_name ]; then
    E "$1|$FUNCNAME" $LINENO ERR_ASSERT_FAILED "ERROR: File [$file_name] does not exists."
 else
 status=$SUCCESS
  INFO "$1|$FUNCNAME" $LINENO "File [$file_name] exists."
  
 fi
_EXIT_ $1  "$mod->$FUNCNAME" $LINENO $status $@
}
# "$1|$FUNCNAME:$LINENO"  $dname
function assert_de {
mod=$(basename "${BASH_SOURCE[0]}")
_ENTRY_ $1  "$mod->$FUNCNAME" $LINENO  $@
 dir_name=$2
 NN "$1|$FUNCNAME" $LINENO dir_name
 if [ ! -d $dir_name ]; then
    E "$1|$FUNCNAME" $LINENO ERR_ASSERT_FAILED "ERROR: Dir [$dir_name] does not exists."
 else
 status=$SUCCESS
  INFO "$1|$FUNCNAME" $LINENO "Dir [$dir_name] exists."
  
 fi
_EXIT_ $1  "$mod->$FUNCNAME" $LINENO $status $@
}

#. $SCRIPTPATH/utils/hdfs_utils.sh
#!/bin/bash 
#************************************************************************************************************
#*
#*    Script Name: hdfs_utils.sh
#*
#*    Description: HDFS utils.
#*
#*    Usage: . hdfs_utils.sh
#*
#*    Author: ob66759
#*
#************************************************************************************************************




function hdfs_mkdir { 
mod=$(basename "${BASH_SOURCE[0]}")
_ENTRY_ $1  "$mod->$FUNCNAME" $LINENO  $@
	
	UPLOAD_LOC=$2
	out=$(hdfs dfs -mkdir -p $UPLOAD_LOC 2>&1)
	status="$?"
	[ ! "$status" -eq "0" ] && E "$1|$FUNCNAME" $LINENO HDFS_FAILURE "Cannot mkdir [$UPLOAD_LOC].\n$out"

_EXIT_ $1  "$mod->$FUNCNAME" $LINENO $status $@	
}	


function hdfs_upload { 
mod=$(basename "${BASH_SOURCE[0]}")
_ENTRY_ $1  "$mod->$FUNCNAME" $LINENO  $@
	FROM_LOC=$2
	UPLOAD_LOC=$3
	out=$(hdfs dfs -put $FROM_LOC/* $UPLOAD_LOC	2>&1)
	status="$?"
	[ ! "$status" -eq "0" ] && E "$1|$FUNCNAME" $LINENO HDFS_FAILURE "Cannot upload from [$FROM_LOC] to [$UPLOAD_LOC].\n$out"

_EXIT_ $1  "$mod->$FUNCNAME" $LINENO $status $@	
}	

function hdfs_assert_fc {
	mod=$(basename "${BASH_SOURCE[0]}")
	_ENTRY_ $1  "$mod->$FUNCNAME" $LINENO  $@
	local_dir_name=$2
   hdfs_dir_name=$3
   

    NN "$1|$FUNCNAME" $LINENO hdfs_dir_name
	NN "$1|$FUNCNAME" $LINENO local_dir_name
   
   INFO "$1|$FUNCNAME" $LINENO "Invoking HDFS LS command"
	
   out=$(diff <(hdfs dfs -ls $hdfs_dir_name/*.csv|wc -l) <(ls -l $local_dir_name/*.csv|wc -l) 2>&1)
	status="$?"
	[ ! "$status" -eq "0" ] && E "$1|$FUNCNAME" $LINENO HDFS_FAILURE "Cannot ls files [$hdfs_dir_name].\n$out"
	

#status="$?"
NN "$1|$FUNCNAME" $LINENO status

   
   if [ "$out" == "" ];then
		INFO "$1|$FUNCNAME" $LINENO 'HDFS vs. LOCAL: Count match.' 
	else
		
		
		E "$1|$FUNCNAME" $LINENO FAILURE "DIFF report: [$out]." 
	fi


_EXIT_ $1  "$mod->$FUNCNAME" $LINENO $status $@
}


#local vs HDFS file size match
function hdfs_assert_fs {
	mod=$(basename "${BASH_SOURCE[0]}")
	_ENTRY_ $1  "$mod->$FUNCNAME" $LINENO  $@
	local_dir_name=$2
    hdfs_dir_name=$3
   

    NN "$1|$FUNCNAME" $LINENO hdfs_dir_name
	NN "$1|$FUNCNAME" $LINENO local_dir_name
   
    INFO "$1|$FUNCNAME" $LINENO "Invoking HDFS LS command"


	cd $local_dir_name; ls -lS *.csv|awk '{print $5,$9}' |while IFS=" " read  col1 col2
	do
		INFO $sn $LINENO "File size = $col1, file name = $col2"
		local_fsize=$col1
		local_fname=$col2
		NN "$1|$FUNCNAME" $LINENO local_fsize
		NN "$1|$FUNCNAME" $LINENO local_fname		
		out=$(hdfs dfs -ls  "${hdfs_dir_name}/${local_fname}" 2>&1)
		[ ! "$?" -eq "0" ] && E "$1|$FUNCNAME" $LINENO HDFS_FAILURE "Cannot ls remote dir [$hdfs_dir_name].\n$out"
		NN "$1|$FUNCNAME" $LINENO out
		#exit
		remote_fsize=$(echo $out| awk -F' ' '{print $5}')
		remote_fname=$(echo $out| awk -F' ' '{print $8}')
		NN "$1|$FUNCNAME" $LINENO remote_fsize
		NN "$1|$FUNCNAME" $LINENO remote_fname
		#exit
		if test $local_fsize -eq $remote_fsize; then
			INFO "$1|$FUNCNAME" $LINENO "Filesize match for [$local_fname/$local_fsize]"
		else
			E "$1|$FUNCNAME" $LINENO FAILURE "ERROR: File size mismatch for  [$local_fname]: $local_fsize <> $remote_fsize." 
		fi
	done 
INFO "$1|$FUNCNAME" $LINENO "LOCAL vs. HDFS: File sizes match."
_EXIT_ $1  "$mod->$FUNCNAME" $LINENO $status $@
}


#. $SCRIPTPATH/include/upload.sh
#!/bin/bash 
#************************************************************************************************************
#*
#*    Script Name: upload.sh
#*
#*    Description: upload tools.
#*
#*    Usage: . upload.sh
#*
#*    Author: ob66759
#*
#************************************************************************************************************


 
function kerberos_config { 
mod=$(basename "${BASH_SOURCE[0]}")
_ENTRY_ $1  "$mod->$FUNCNAME" $LINENO  $@
	kdestroy
	export KRB5_CONFIG=/opt/Cloudera/KRB5/krb5.conf
	NN "$1|$FUNCNAME" $LINENO KRB5_CONFIG
	export KRB5CCNAME=/tmp/krb5cc_$UID
	NN "$1|$FUNCNAME" $LINENO KRB5CCNAME
	out=$(kinit -k -t /opt/Cloudera/keytabs/`whoami`.`hostname -s`.keytab `whoami`/`hostname -f`@`sed -r -n "s/[ \t]+default_realm *= *(.*)/\1/p" /etc/krb5/krb5.conf` 2>&1) 
	status="$?"
	[ ! "$status" -eq "0" ] && E "$1|$FUNCNAME" $LINENO FAILURE "Kerberos config failed.\n$out"
_EXIT_ $1  "$mod->$FUNCNAME" $LINENO $status $@	
}	
#Append to HDFS control file
function append_ctrl_file {
	mod=$(basename "${BASH_SOURCE[0]}")
	_ENTRY_ $1  "$mod->$FUNCNAME" $LINENO  $@
	local_dir_name=$2
	hdfs_dir_name=$3
	table_name=$4
	ctrl_fn=$5
	NN "$1|$FUNCNAME" $LINENO local_dir_name
	NN "$1|$FUNCNAME" $LINENO table_name
	NN "$1|$FUNCNAME" $LINENO ctrl_fn
    ctrl_loc=$(dirname "$ctrl_fn")
	NN "$1|$FUNCNAME" $LINENO ctrl_loc
	[ ! -d $ctrl_loc ] && mkdir -p $ctrl_loc
	
	[ ! -d $ctrl_loc ] && E "$1|$FUNCNAME" $LINENO ERR_ASSERT_FAILED "Cannot create out dir [$ctrl_loc]"
	
	[ ! -f $ctrl_fn ] && touch $ctrl_fn
	[ ! -f $ctrl_fn ] && E "$1|$FUNCNAME" $LINENO ERR_ASSERT_FAILED "Cannot create control file [$ctrl_fn]"
	cnt=0
	COUNTER=0
	TEMPFILE=$TMP_DIR_TS/$$.tmp 

	cd $local_dir_name; ls -lS *.csv|awk '{print $9}' |while IFS=" " read  local_fname
	do
		NN "$1|$FUNCNAME" $LINENO local_fname
		hdfs_dir_name=${hdfs_dir_name%/}
		echo  "${hdfs_dir_name}/${local_fname},$table_name" >> $ctrl_fn
		cnt=$((cnt+1))
		COUNTER=$[COUNTER + 1]
		NN "$1|$FUNCNAME" $LINENO COUNTER
		echo $COUNTER > $TEMPFILE
	done 

	COUNTER=$(cat $TEMPFILE)  
unlink $TEMPFILE
INFO "$1|$FUNCNAME" $LINENO "HDFS CNTL: Appended \"$COUNTER\" records."
_EXIT_ $1  "$mod->$FUNCNAME" $LINENO $status $@
}
#Upload control file to HDFS
function upload_ctrl_file {
	mod=$(basename "${BASH_SOURCE[0]}")
	_ENTRY_ $1  "$mod->$FUNCNAME" $LINENO  $@
	
	if [[ ! "${#@}" -eq "3" ]]; then
		E "$1|$FUNCNAME" $LINENO ERR_MISSING_PARAMETER "Missing parameter."	
	fi
	hdfs_dir_name=$2
	out_ctrl_fn=$3
	
	NN "$1|$FUNCNAME" $LINENO hdfs_dir_name
	
	NN "$1|$FUNCNAME" $LINENO out_ctrl_fn
	
	




	
	[ ! -f $out_ctrl_fn ] && E "$1|$FUNCNAME" $LINENO ERR_ASSERT_FAILED "Control file does not exists. Exiting upload..."
	out=$(hdfs dfs -put -f $out_ctrl_fn $hdfs_dir_name 2>&1)
	status="$?"
	[ ! "$status" -eq "0" ] && E "$1|$FUNCNAME" $LINENO HDFS_FAILURE "Cannot HDFS/put control file.\n$out"
	

	HDFS_CTRL_FN=$hdfs_dir_name/$CTRL_FNAME
	out=$(hdfs dfs -stat "%n" $HDFS_CTRL_FN)
	status="$?"
	[ ! "$status" -eq "0" ] && E "$1|$FUNCNAME" $LINENO HDFS_FAILURE "Cannot HDFS/stat failed.\n$out"	
	
	[[ ! "${out}" == "${CTRL_FNAME}" ]] && E "$1|$FUNCNAME" $LINENO HDFS_FAILURE "Control file upload failed."

INFO "$1|$FUNCNAME" $LINENO "HDFS CNTL: Control file uploaded."
_EXIT_ $1  "$mod->$FUNCNAME" $LINENO $status $@
}



#. $SCRIPTPATH/include/download.sh
#!/bin/bash 
#************************************************************************************************************
#*
#*    Script Name: download.sh
#*
#*    Description: Download tools.
#*
#*    Usage: . download.sh
#*
#*    Author: ob66759
#*
#************************************************************************************************************


function get_ctrl_file {
mod=$(basename "${BASH_SOURCE[0]}")
_ENTRY_ $1  "$mod->$FUNCNAME" $LINENO  $@
	remote_file_loc=$2
	local_file_loc=$3
	
	#del_file "$1|$FUNCNAME:$LINENO"  ${local_file_loc}
	[ -f $local_file_loc ] && rm -rf ${local_file_loc}
	
	lftp_get_file "$1|$FUNCNAME:$LINENO" $remote_file_loc $local_file_loc $SOURCE_SERVER $SFTP_USERID $SFTP_PASSWORD
	#assert_fe "$1|$FUNCNAME:$LINENO"  ${local_file_loc}
	[ ! -f $local_file_loc ] && E "$1|$FUNCNAME" $LINENO FAILURE "ERROR: Control file does not exists after download [$local_file_loc]"
	
    

_EXIT_ $1  "$mod->$FUNCNAME" $LINENO $status $@	
}

function download_files {
mod=$(basename "${BASH_SOURCE[0]}")
_ENTRY_ $1  "$mod->$FUNCNAME" $LINENO  $@
	SOURCE_LOC=$2
	DOWNLOAD_LOC=$3
	TABLE_NAME=$4
	NN "$1|$FUNCNAME" $LINENO DOWNLOAD_LOC
	[ -d $DOWNLOAD_LOC ] && E "$1|$FUNCNAME" $LINENO ERR_ASSERT_FAILED "ERROR: Download dir already exists [$DOWNLOAD_LOC]"
	mkdir -p $DOWNLOAD_LOC
	[ ! -d $DOWNLOAD_LOC ] && E "$1|$FUNCNAME" $LINENO ERR_ASSERT_FAILED "ERROR: Could not create download dir [$DOWNLOAD_LOC]"
	
	lftp_assert_de "$sn:$LINENO" $SOURCE_LOC  $SOURCE_SERVER $SFTP_USERID $SFTP_PASSWORD
	lftp_get_dir "$sn:$LINENO" $SOURCE_LOC  $DOWNLOAD_LOC  $SOURCE_SERVER $SFTP_USERID $SFTP_PASSWORD
	lftp_assert_fc "$sn:$LINENO" $SOURCE_LOC  $DOWNLOAD_LOC  $SOURCE_SERVER $SFTP_USERID $SFTP_PASSWORD
	lftp_assert_fs "$sn:$LINENO" $SOURCE_LOC  $DOWNLOAD_LOC  $SOURCE_SERVER $SFTP_USERID $SFTP_PASSWORD 

_EXIT_ $1  "$mod->$FUNCNAME" $LINENO $status $@	
}



if on 
then
	SFTP_WAIT_MINS=10


	NN $sn $LINENO SFTP_WAIT_MINS
	SFTP_WAIT_SECONDS=`expr ${SFTP_WAIT_MINS} '*' 60`
	CURR_UNIX_TIME=`date +%s`
	SFTP_END_TIME=`expr ${CURR_UNIX_TIME} + ${SFTP_WAIT_SECONDS}`

	NN $sn $LINENO CURR_UNIX_TIME
	NN $sn $LINENO SFTP_END_TIME

	PARENT_BN="$(ps -o comm= $PPID)"
	PARENT_SHELL=$PPID.$PARENT_BN

	NN $sn $LINENO PARENT_BN
	NN $sn $LINENO PARENT_SHELL
	
	NN $sn $LINENO SCRIPTPATH
	NN $sn $LINENO SCRIPT_DIR
	NN $sn $LINENO TMP_DIR
	NN $sn $LINENO IS_TEST
	NN $sn $LINENO SCRIPT
fi

if on 
then
	
	if TEST; then 
		SOURCE_SERVER=$(hostname -f)
		REMOTE_CTRL_FILE_LOC='~/server/control_file_TEST.csv'
		STAGE_LOC='/user/gfolyrep/uno_ref/stage'
		REMOTE_CONTROL_FN=$(basename  "$REMOTE_CTRL_FILE_LOC")
		#LOCAL_CONTROL_FLOC="./in/$LOCAL_CONTROL_FN"
		SFTP_USERID='ob66759'
		NN $sn $LINENO FTP_PWD 0
		SFTP_PASSWORD="${FTP_PWD}"
		CTRL_UPLOAD_LOC=$STAGE_LOC


			
			
	else
		SOURCE_SERVER=$1
		REMOTE_CTRL_FILE_LOC=$2
		STAGE_LOC=$3
		SFTP_USERID=$4
		NN $sn $LINENO FTP_PWD 0
		SFTP_PASSWORD="${FTP_PWD}"
		REMOTE_CONTROL_FN=$(basename  "$REMOTE_CTRL_FILE_LOC")
		#LOCAL_CONTROL_FN=$(basename  "$REMOTE_CTRL_FILE_LOC")
		CTRL_UPLOAD_LOC=$STAGE_LOC

		
	fi
	
	
	CTRL_FNAME=$(basename -- "$REMOTE_CTRL_FILE_LOC")
	CTRL_EXT="${CTRL_FNAME##*.}"
	CTRL_FN="${CTRL_FNAME%.*}"
	

	
	#NN $sn $LINENO OUT_ROOT
	TS_DIR=`date +%y%m%d_%H_%M_%S`
	NN $sn $LINENO TS_DIR
	
	
	#OUT_TS_PATH="$OUT_ROOT/$CTRL_FN/$TS_DIR"
	TMP_DIR_TS="$TMP_DIR/$CTRL_FN/$TS_DIR"
	OUT_DIR="$TMP_DIR_TS/out"
	IN_DIR="$TMP_DIR_TS/in"
	
	#NN $sn $LINENO OUT_TS_PATH
	NN $sn $LINENO TMP_DIR_TS
	NN $sn $LINENO OUT_DIR
	NN $sn $LINENO IN_DIR
	
	if on; then
		[ ! -d $TMP_DIR_TS ] && mkdir -p $TMP_DIR_TS
		[ ! -d $TMP_DIR_TS ] && E "$1|$FUNCNAME" $LINENO ERR_ASSERT_FAILED "Cannot create tmp dir [$TMP_DIR_TS]"
		[ ! -d $OUT_DIR ] && mkdir -p $OUT_DIR
		[ ! -d $IN_DIR ] && mkdir -p $IN_DIR
	fi
	
	

	#exit
			
	NN $sn $LINENO SOURCE_SERVER
	NN $sn $LINENO REMOTE_CTRL_FILE_LOC
	NN $sn $LINENO CTRL_FNAME
	NN $sn $LINENO CTRL_FN
	NN $sn $LINENO CTRL_EXT
	#NN $sn $LINENO LOCAL_CONTROL_FN
	#NN $sn $LINENO LOCAL_CONTROL_FLOC
	NN $sn $LINENO SFTP_USERID
	NN $sn $LINENO SFTP_PASSWORD 0
fi

#///////////////////////////////////////////////////////////
SCRIPTENTRY $0 $LINENO $SCRIPTPATH "$@"






[ $IS_TEST -ne 0 ] && WARNING $0 $LINENO "It's a test" || INFO $0 $LINENO "It's a LIVE process."

kerberos_config "$sn:$LINENO"




if on #test
then
	INFO $sn $LINENO `whoami`
	INFO $sn $LINENO `pwd`
	#init_alpha $sn $LINENO
	INFO $sn $LINENO 'After init.'
	if on
	then
		in_ctrl_file="$IN_DIR/$REMOTE_CONTROL_FN"
		NN "$sn" $LINENO in_ctrl_file
		get_ctrl_file "$sn:$LINENO" $REMOTE_CTRL_FILE_LOC  $in_ctrl_file
		echo ""
	fi
	
	out_ctrl_fn="$OUT_DIR/$CTRL_FNAME"
	while IFS=, read -r SOURCE_LOC TABLE_NAME
	do
		if [[ ${#SOURCE_LOC} -ge 2  ]]
		then
			[ "$SOURCE_LOC" == "" ] && E "$sn" $LINENO ERR_CSV_FORMAT "ERROR: CSV file [$in_ctrl_file] SOURCE_LOC is not set."
			[ "$TABLE_NAME" == "" ] && E "$sn" $LINENO ERR_CSV_FORMAT "ERROR: CSV file [$in_ctrl_file] TABLE_NAME is not set."
			
			

			
			if on; 	then #download
				DOWNLOAD_LOC="${IN_DIR}${SOURCE_LOC}"
				download_files "$sn:$LINENO" $SOURCE_LOC $DOWNLOAD_LOC $TABLE_NAME
			fi
			
			if on; then #upload


				
				
				if TEST; then
					UPLOAD_LOC="$STAGE_LOC/$CTRL_FN/${TS_DIR}${SOURCE_LOC}/"
				else
					UPLOAD_LOC="$STAGE_LOC/$CTRL_FN/${TS_DIR}${SOURCE_LOC}/"
				fi
				NN $sn $LINENO UPLOAD_LOC
				
				hdfs_mkdir "$sn:$LINENO"  $UPLOAD_LOC
				hdfs_upload "$sn:$LINENO" $DOWNLOAD_LOC $UPLOAD_LOC

				hdfs_assert_fc "$sn:$LINENO" $DOWNLOAD_LOC $UPLOAD_LOC
				hdfs_assert_fs "$sn:$LINENO" $DOWNLOAD_LOC $UPLOAD_LOC
				
				NN $sn $LINENO out_ctrl_fn
				append_ctrl_file "$sn:$LINENO" $DOWNLOAD_LOC $UPLOAD_LOC $TABLE_NAME $out_ctrl_fn
				
				

				
				
				#exit
			fi
			#exit

		else
			INFO $sn $LINENO "Empty string in file [$in_ctrl_file]"
		fi
	done < $in_ctrl_file
	

	upload_ctrl_file "$sn:$LINENO" $CTRL_UPLOAD_LOC $out_ctrl_fn


fi




SCRIPTEXIT  $sn $LINENO $SCRIPTPATH "$@"
exit $SUCCESS