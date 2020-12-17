#!/bin/bash
read -s -p "Enter password(FTP_PWD):"  VALUE
export FTP_PWD=$VALUE
echo "
Password is set."