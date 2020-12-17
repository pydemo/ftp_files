#!/bin/bash 
#************************************************************************************************************
#*
#*    Script Name: download.sh
#*
#*    Description: Download tools.
#*
#*    Usage: . download.sh
#*
#*    Author: user_1
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
