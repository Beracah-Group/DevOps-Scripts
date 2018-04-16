#!/usr/bin/env bash
set -e

mkdir /mnt/cattlestorage
echo "//$STORAGE_ACCOUNT_NAME.file.core.windows.net/cattlestorage /mnt/cattlestorage cifs vers=3.0,username=$STORAGE_ACCOUNT_NAME,password=$STORAGE_ACCESS_KEY,dir_mode=0777,file_mode=0777" >> /etc/fstab
