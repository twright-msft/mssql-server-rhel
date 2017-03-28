# mssql-server-rhel
# Maintainers: Travis Wright (twright-msft on GitHub)
# GitRepo: https://github.com/twright/mssql-server-rhel

# Base OS layer: latest RHEL 7
FROM registry.access.redhat.com/rhel7:latest

# Install latest mssql-server package
RUN subscription-manager register --username twright-msft --password 'Yukon900!' --auto-attach
#RUN yum-config-manager 
RUN yum install -y curl
RUN curl https://packages.microsoft.com/config/rhel/7/mssql-server.repo > /etc/yum.repos.d/mssql-server.repo
RUN yum install -y mssql-server

# Default SQL Server TCP/Port.
EXPOSE 1433

#Import the sqlservr.sh script
ADD ./sqlservr.sh /opt/mssql/bin/
RUN chmod a+x /opt/mssql/bin/sqlservr.sh

# Run SQL Server process.
CMD /bin/bash /opt/mssql/bin/sqlservr.sh