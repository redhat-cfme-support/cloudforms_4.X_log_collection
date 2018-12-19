#!/bin/bash

collection_type="current"
vmdb_logs_files="log/*.log log/*.txt"

source ${BASH_SOURCE%/*}/collect_CFME_logs.sh
