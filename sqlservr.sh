#!/bin/bash
#
# Microsoft(R) SQL Server(R) launch script for Docker
#
# IMPORTANT NOTE: This is only a temporary solution.  This will no longer be required after vNext CTP 2.0.
#
ACCEPT_EULA=${ACCEPT_EULA:-}
SA_PASSWORD=${SA_PASSWORD:-}
#COLLATION=${COLLATION:-SQL_Latin1_General_CP1_CI_AS}
have_sa_password=""
#have_collation=""
sqlservr_setup_prefix=""
configure=""
reconfigure=""
# Check system memory
#
let system_memory="$(awk '/MemTotal/ {print $2}' /proc/meminfo) / 1024"
if [ $system_memory -lt 3250 ]; then
    echo "ERROR: This machine must have at least 3.25 gigabytes of memory to install Microsoft(R) SQL Server(R)."
    exit 1
fi
# Create system directories
#
mkdir -p /var/opt/mssql/data
mkdir -p /var/opt/mssql/etc
mkdir -p /var/opt/mssql/log
# Check the EULA
#
if [ "$ACCEPT_EULA" != "Y" ] && [ "$ACCEPT_EULA" != "y" ]; then
    echo "ERROR: You must accept the End User License Agreement before this container" > /dev/stderr
    echo "can start. The End User License Agreement can be found at " > /dev/stderr
    echo "http://go.microsoft.com/fwlink/?LinkId=746388." > /dev/stderr
    echo ""
    echo "Set the environment variable ACCEPT_EULA to 'Y' if you accept the agreement." > /dev/stderr
    exit 1
fi
# Configure SQL engine
#
if [ ! -f /var/opt/mssql/data/master.mdf ]; then
    configure=1
    if [ ! -z "$SA_PASSWORD" ] || [ -f /var/opt/mssql/etc/sa_password ]; then
        have_sa_password=1
    fi
#   if [ ! -z "$COLLATION" ] || [ -f /var/opt/mssql/etc/collation ]; then
#       have_collation=1
#   fi
    if [ -z "$have_sa_password" ]; then
        echo "ERROR: The system administrator password is not configured. You can set the" > /dev/stderr
        echo "password via environment variable (SA_PASSWORD) or configuration file" > /dev/stderr
        echo "(/var/opt/mssql/etc/sa_password)." > /dev/stderr
        exit 1
    fi
fi
# If user wants to reconfigure, set reconfigure flag
#
if [ -f /var/opt/mssql/etc/reconfigure ]; then
    reconfigure=1
fi
# If we need to configure or reconfigure, run through configuration
# logic
#
if [ "$configure" == "1" ] || [ "$reconfigure" == "1" ]; then
    sqlservr_setup_options=""
#   if [ -f /var/opt/mssql/etc/collation ]; then
#       sqlservr_setup_options+="-q $(cat /var/opt/mssql/etc/collation)"
#   else
#       if [ ! -z "$COLLATION" ]; then
#           sqlservr_setup_options+="-q $COLLATION "
#       fi
#   fi
    set +e
    cd /var/opt/mssql
    echo 'Configuring Microsoft(R) SQL Server(R)...'
    if [ -f /var/opt/mssql/etc/sa_password ]; then
        SQLSERVR_SA_PASSWORD_FILE=/var/opt/mssql/etc/sa_password /opt/mssql/bin/sqlservr --setup $sqlservr_setup_options 2>&1 > /var/opt/mssql/log/setup-$(date +%Y%m%d-%H%M%S).log
    elif [ ! -z "$SA_PASSWORD" ]; then
        SQLSERVR_SA_PASSWORD_FILE=<(echo -n "$SA_PASSWORD") /opt/mssql/bin/sqlservr --setup $sqlservr_setup_options 2>&1 > /var/opt/mssql/log/setup-$(date +%Y%m%d-%H%M%S).log
    else
        if [ ! -z '$sqlservr_setup_options' ]; then
            /opt/mssql/bin/sqlservr --setup $sqlservr_setup_options 2>&1 > /var/opt/mssql/log/setup-$(date +%Y%m%d-%H%M%S).log
        fi
    fi
    retcode=$?
    if [ $retcode != 0 ]; then
        echo "Microsoft(R) SQL Server(R) setup failed with error code $retcode. Please check the setup log in /var/opt/mssql/log for more information." > /dev/stderr
        exit 1
    fi
    set -e
    rm -f /var/opt/mssql/etc/reconfigure
    rm -f /var/opt/mssql/etc/sa_password
    echo "Configuration complete."
fi

# Start SQL Server
exec /opt/mssql/bin/sqlservr