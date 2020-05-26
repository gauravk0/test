
# Gmetrics monitor core Setup Installation

## Purpose

 This script installs and configures Gmetrics-Core on system (Centos7)

## Instruction 

* First it is mandatory to check and prepare the installation environment for Gmetrics-Core. 
* Package count at initial should be 405 with Base "minimal" install and packages "Compatibility Libraries" and "Developement Tools"
* Parition should be customised as per given in docs/manual.
* With gmetrics_envcheck script, installation environment can be checked. (It checks Gmetrics User, OS details, Swap memory, Gmetrics directory, sudoers entry, and package count.)


## Introduction

### Overview of steps in the Core side installation:

* Gmetrics User creation, and adding monitorinng user to group 
* Sudoers entry
* Firewall configuration for opening of ports, and disabling Selinux.
* Download and Extract GMetrics package
* Installing and extracting monitoring os libraries packages.
* Restore monitoring services file, and component packages (monitoringCore.tar.gz)
* creating and checking monitoring configuration test (configtest)
* Restore log rotate & cron
* Restore virtual host and extract Virtual host files
* Updating servername with IP address in /etc/httpd/conf/httpd.conf
* Restore Thruk dashboard, install and update ownership of thruk files.
* check the status of httpd, gmetrics and npcd services ; and start.
* Listing gmetrics services status with onboot status.
* Enable and start grafana service. 
* Download nodejs and create Grafana dashboad automation


## SETUP

### Downloading the specific Directory using snv 

 in /root directory, 
 svn checkout https://github.com/grootsadmin/groots-metrics/branches/alpha/gmetrics-automation  --non-interactive --no-auth-cache --username grootsadmin --password  Grootsadmin#2019@
 

## Scipt run 

* execute gmetrics_checkenv script,

  sh /root/gmetrics-automation/gmetrics_checkenv.sh

* execute gmetrics-core installation script,
  
  sh /root/gmetrics-automation/gmetrics-core-setup.sh


## Manual Tasks after installation

* Changing email-id to client's email-id , /groots/monitoring/config_files/etc/objects/contacts.cfg
* Replacing the client's Ip in Grafana config file and comment the section access url using hostname, /etc/httpd/conf.d/grafana.conf
* Add default SSL entries in this file, /etc/httpd/conf.d/pnp4nagios.conf
  echo "SSLCertificateFile /etc/pki/tls/certs/localhost.crt" >> /etc/httpd/conf.d/pnp4nagios.conf
  echo "SSLCertificateKeyFile /etc/pki/tls/private/localhost.key" >> /etc/httpd/conf.d/pnp4nagios.conf
* For generating graphs for the remote hosts re-execute node grafana_dashboard_automatation.js by adding the remote host name and restart grafana service. 

## Testing

* Login on all browsers by using below given default credentials, check thruk dashboard with http://IP/thruk and default credentials. 
* Verify all service status and firewall status
* Test grafana installation.
* Login check -> http://<IP/HOSTNAME>/graph   ------->> Without SSL.
* In cd /groots/monitoring/dashboard_files/monitoringgraph/, vi node grafana_dashboard_automatation.js.
  Upadate and save password from this file for graph user: "configuration" >> Data source >> Click on "PNP" data source >> Selcect "Basic Auth Details"
* Go to host on left side in GUI, and Select Force Check from the top right pop-up and Submit the command.
* Make sure all graphs are loading. 


### Log file 

log file to be generated at /var/log/groots/gmetrics/gmetrics-core-setup.sh.log


## License
 This program is distributed in the hope that it will be useful,
 but under groots software technologies @rights.


