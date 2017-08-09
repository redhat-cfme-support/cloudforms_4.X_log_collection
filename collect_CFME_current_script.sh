#!/bin/bash
collect_logs_directory=$(pwd)
# save directory from which command is initiated
pushd /var/www/miq/vmdb
# make the vmdb/log directory the current directory 
rm -f log/evm_full_archive_$(uname -n)* log/evm_current_$(uname -n)*
# eliminiate any prior collected logs to make sure that only one collection is current

#Source in the file so that we can call postgresql functions
source /etc/default/evm

if [ -d "$APPLIANCE_PG_DATA/pg_log" ]
then

echo "This CloudForms appliance has a Database server and is running version: $(psql --version)"
echo " Log collection starting:"
XZ_OPT=-9 tar -cJvf log/evm_current_$(uname -n)_$(date +%Y%m%d_%H%M%S).tar.xz --sparse -X $collect_logs_directory/exclude_files   BUILD GUID VERSION REGION log/*.log log/*.txt config/* /var/log/* log/apache/*
$APPLIANCE_PG_DATA/pg_log/* $APPLIANCE_PG_DATA/postgresql.conf

else
echo "This CloudForms appliance is not a Database server"
echo " Log collection starting:"
XZ_OPT=-9 tar -cJvf log/evm_current_$(uname -n)_$(date +%Y%m%d_%H%M%S).tar.xz --sparse -X $collect_logs_directory/exclude_files   BUILD GUID VERSION REGION log/*.log log/*.txt config/* /var/log/* log/apache/*

fi
# and restore previous current directory
popd
