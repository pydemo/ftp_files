#!/bin/ksh
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


function exitFailed {
    log "$1"
    log "Script ${SCRIPT} Failed"
    exit 1
}

function checkCmdSucc {
    if [[ "$?" -eq "0" ]]; then
        log "$1"
    else
        exitFailed "$2"
    fi
}

function sftpFiles {
   log "Invoking SFTP command"

   expect -c "spawn sftp -c aes128-ctr -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${SFTP_USERID}@${SFTP_HOST}
             expect \"Password:\"
             send \"${SFTP_PASSWORD}\r\"
             expect \"sftp>\"
             $(cat ${SFTP_BATCH})
            "
   if [[ "$?" -eq "0" ]]
   then
       SFTP_STATUS="SUCCEEDED"
       log "SFTP Command Succeeded"
   else
       CURR_UNIX_TIME=`date +%s`
       if [[ ${CURR_UNIX_TIME} -gt ${SFTP_END_TIME} ]]
       then
           if [[ ${FAIL_ON_FILE_NOT_AVAILABLE} -eq "N" ]]
           then
               SFTP_STATUS="FAILED"
               log "Error SFTP Command Failed. Source File Not Available. Not failing the Job as oats_reject_sftp_fail_on_file_not_available is set to 'N'"
           else
               exitFailed "Error SFTP Command Failed. Source File Not Available."
           fi
       else
           log "SFTP Command Failed. Source File Not Available. Sleeping for 60 Seconds before Retrying SFTP"
           sleep 60
           sftpFiles
       fi
   fi
}


