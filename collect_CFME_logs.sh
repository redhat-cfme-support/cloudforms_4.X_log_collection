#!/bin/bash

# save directory from which command is initiated
collect_logs_directory=${BASH_SOURCE%/*}

# used in filenames and globs
vmdb_hostname=$(uname -n)

# base name for tar
tar_base_name="log/evm_full_${collection_type}_${vmdb_hostname}"

# make the vmdb/log directory the current directory
vmdb_logs_directory="/var/www/miq/vmdb"
pushd ${vmdb_logs_directory}

# eliminiate any prior collected logs to make sure that only one collection is current
rm -f log/evm_full_archive_$vmdb_hostname* \
      log/evm_archived_$vmdb_hostname*     \
      log/evm_archive_$vmdb_hostname*      \
      log/evm_current_$vmdb_hostname*

# Source in the file so that we can call postgresql functions
source /etc/default/evm

tarball="${tar_base_name}_$(date +%Y%m%d_%H%M%S).tar.xz"

include_files="BUILD GUID VERSION REGION"                              # CFME version/identifiers
include_files="$include_files $vmd_log_files"                          # CFME log files to include
include_files="$include_files /var/log/* var/apache/*"                 # System/apache log files

if [[ -n "$APPLIANCE_PG_DATA" && -d "$APPLIANCE_PG_DATA/pg_log" ]]; then
    echo "This CloudForms appliance has a Database server and is running version: $(psql --version)"

    include_files="$include_files $APPLIANCE_PG_DATA/pg_log/*"         # PG log files
    include_files="$include_files $APPLIANCE_PG_DATA/postgresql.conf"  # PG config files
else
    echo "This CloudForms appliance is not a Database server"
fi


echo " Log collection starting:"
XZ_OPT=-9 tar -cJvf ${tarball} --sparse                \
              -X $collect_logs_directory/exclude_files \
              $include_files

# and restore previous current directory
popd

# let the user know where the archive is
echo "Archive Written To: ${vmdb_logs_directory}/${tarball}"
