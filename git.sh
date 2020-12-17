#!/bin/bash
export GIT_EXEC_PATH=/tmp/ob_git/libexec/git-core/
/tmp/ob_git/bin/git $@
alias git=/tmp/ob_git/bin/git
#git config --global credential.helper store
