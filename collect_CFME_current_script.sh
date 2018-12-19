#!/bin/bash

collection_type="current"
vmdb_logs_files="log/*.log log/*.txt"

if [[ -e ${BASH_SOURCE%/*} ]]; then
  starting_dir=$(pwd)
  cd ${BASH_SOURCE%/*}
  source ./collect_CFME_logs.sh
  cd $starting_dir
else
  echo "ERROR:  Unable to find collect log script!"
  exit 1
fi
