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