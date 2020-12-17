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

