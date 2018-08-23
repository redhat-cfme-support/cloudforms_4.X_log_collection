#!/bin/bash

# save directory from which command is initiated
collect_logs_directory=$(pwd)

# make the vmdb/log directory the current directory
vmdb_logs_directory="/var/www/miq/vmdb"
pushd ${vmdb_logs_directory}

# eliminiate any prior collected logs to make sure that only one collection is current
rm -f log/evm_full_archive_$(uname -n)* log/evm_archived_$(uname -n)*

#Source in the file so that we can call postgresql functions
source /etc/default/evm

tarball="log/evm_archive_$(uname -n)_$(date +%Y%m%d_%H%M%S).tar.xz"

#add if required, but do not change atime 
touch -a $collect_logs_directory/exclude_files

if [[ -n "$APPLIANCE_PG_DATA" && -d "$APPLIANCE_PG_DATA/pg_log" ]]; then
    echo "This CloudForms appliance has a Database server and is running version: $(psql --version)"
    echo " Log collection starting:"
    XZ_OPT=-9 tar -cJvf ${tarball} --sparse -X $collect_logs_directory/exclude_files BUILD GUID VERSION REGION log/* config/*  /var/log/* log/apache/* $APPLIANCE_PG_DATA/pg_log/* $APPLIANCE_PG_DATA/postgresql.conf
else
    echo "This CloudForms appliance is not a Database server"
    echo " Log collection starting:"
    XZ_OPT=-9 tar -cJvf ${tarball} --sparse -X $collect_logs_directory/exclude_files BUILD GUID VERSION REGION log/* config/* /var/log/* log/apache/*
fi

# and restore previous current directory
popd

# let the user know where the archive is
echo "Archive Written To: ${vmdb_logs_directory}/${tarball}"
