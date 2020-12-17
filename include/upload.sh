#!/bin/bash 
#************************************************************************************************************
#*
#*    Script Name: upload.sh
#*
#*    Description: upload tools.
#*
#*    Usage: . upload.sh
#*
#*    Author: user_1
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

