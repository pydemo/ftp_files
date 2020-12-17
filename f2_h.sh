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
#*	  Set OS_PWD: $ . spwd
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

. $SCRIPTPATH/utils/logger.sh 
. $SCRIPTPATH/utils/common.sh
. $SCRIPTPATH/utils/lftp.sh
. $SCRIPTPATH/utils/file_utils.sh
. $SCRIPTPATH/utils/hdfs_utils.sh
. $SCRIPTPATH/include/upload.sh
. $SCRIPTPATH/include/download.sh
#type assert

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

#Apload control file to HDFS
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