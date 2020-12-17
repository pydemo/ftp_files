# Purpose

This script will download files from SFTP server (using control file) and upload them to HDFS.

### FTP control file format (download)

    /home/test/server/Equities/test, om_test_exclusion_list
    /home/test/server/Equities/test, om_test_exclusion_list_123


### HDFS control file format (upload)


    /user/test/test/stage/control_file_TEST/200723_09_18_32/home/test/server/Equities/test/SDQ_STATUS.csv,om_test_exclusion_list
    /user/test/test/stage/control_file_TEST/200723_09_18_32/home/test/server/Equities/test/AP_STATUS.csv,om_test_exclusion_list






# Usage

```bash
$ ./ftp2_hdfs.sh SOURCE_FTP_SERVER FTP_CTRL_FILE_LOC HDFS_STAGE_LOC FTP_USER
```

## Set FTP password

```bash
$ . spwd
```

## Example

```bash
$ ./ftp2_hdfs.sh  test.nam.test '~/server/control_file_TEST.csv' '/user/test/test/stage' test
```


## Get code

If you are on test:

```bash
export GIT_EXEC_PATH=/tmp/ob_git/libexec/git-core/
alias git=/tmp/ob_git/bin/git


git  clone https://cedt-test-bitbucket.nam.test/bitbucket/scm/test-core/test-fid-batch-ui-reports.git -b feature/ob_uno ob_uno
```


## Push updates

If you are changing code - change `f2_h.sh`, not the "all-in-one" version (`ftp2_hdfs.sh`)

If you are on test:

```bash
$ ./push.sh
```