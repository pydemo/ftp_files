#!/bin/bash 
#************************************************************************************************************
#*
#*    Script Name: hdfs_utils.sh
#*
#*    Description: HDFS utils.
#*
#*    Usage: . hdfs_utils.sh
#*
#*    Author: user_1
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

