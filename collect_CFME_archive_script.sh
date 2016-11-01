#!/bin/bash
collect_logs_directory=$(pwd)
# save directory from which command is initiated
pushd /var/www/miq/vmdb
# make the vmdb/log directory the current directory 
rm -f log/evm_full_archive_$(uname -n)* log/evm_current_$(uname -n)*
# eliminiate any prior collected logs to make sure that only one collection is current

# determine what level of CFME this command is executing on
read tbuild < BUILD
echo "$tbuild"
subset=${tbuild:0:3}
echo CloudForms "$subset"

case $subset in
"5.5"|"5.6"|"5.7")
 message="cloudforms 4.* release"
 if [ -e "/var/opt/rh/rh-postgresql94/lib/pgsql/data/postgresql.conf" ] ; then
  postgresql_path_files="/var/opt/rh/rh-postgresql94/lib/pgsql/data/*.conf /var/opt/rh/rh-postgresql94/lib/pgsql/data/pg_log/* "
  else
  echo "this appliance does not contain a running postgresql instance, no postgresql materials collected"
 fi
 ;;
*)
 message="unknown cloudforms release, log collection terminated "
 ;;
esac


if [ -e /opt/rh/postgresql92/root/var/lib/pgsql/data/pg_log/postgresql.log ]
then
echo "XZ_OPT=-9 tar -cJvf log/evm_current_$(uname -n)_$(date +%Y%m%d_%H%M%S).tar.xz --sparse -X $collect_logs_directory/exclude_files BUILD GUID VERSION REGION log/*.log log/*.txt config/*  /var/log/* log/apache/* $postgresql_path_files "
else
XZ_OPT=-9 tar -cJvf log/evm_current_$(uname -n)_$(date +%Y%m%d_%H%M%S).tar.xz --sparse -X $collect_logs_directory/exclude_files BUILD GUID VERSION REGION log/*.log log/*.txt config/*  /var/log/* log/apache/* 
fi

# and restore previous current directory
popd
