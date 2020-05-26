
# Gmetrics remote Agent installation

## Purpose

 This script installs gmetrics-remote Agent on the remote systems. (Centos7/Ubuntu)

## Introduction

 Steps involved in the installation one by one:

* Checking the OS background and installing packages
* Gmetrics remote User aaddition  
* Gmetrics remote plugin directory creation 
* Gmetrics remote pulling ipaddress of system 
* Changing ping file permission 
* Gmetrics remote plugins download to plugin dir  
* Gmetrics remote extracting taragent zip file
* Gmetrics remote service port entry 
* Gmetrics remote user sudoers entry 
* Assigning LANIP address in config file
* Gmetrics remote port adding in firewall
* Enable and Start the Gmetrics remote service
* Gmetrics remote connectivity test

## SETUP

### Clone the repo using

* Verifying git availability, git --version 

* If git not installed then, to install git 
 
  sudo yum install git (Centos7)
 
  sudo apt-get install git (Ubuntu18)

* Clone in /root/ directory, 
 
  git clone -b alpha https://github.com/grootsadmin/groots-metrics.git 

### Instruction 
 
* Installation of packages are commented, as the necessary packages can be installed manually later as required.
 
* Gmetrics remote Agent tar files are placed in  
 
  cd /root/groots-metrics/gmetrics-remote-agent/

  gmetrics-remote-deb-v4.3.2.2020.tar.gz (Ubuntu) , 
 
  gmetrics-remote-el7-v4.3.2.2020.tar.gz (Centos7)

* Gmetrics plugins directories are placed in
 
  cd /root/groots-metrics/gmetrics-remote-plugin/
  
* Scripts are placed under 
 
  cd /root/groot-metrics/gmetrics-automation/  
 
## Scipt run 

* execute remote agent installation script (to be run as root),  

  sh /root/groots-metrics/gmetrics-automation/gmetrics_agent_setup.sh

## Log file 

* If gmetrics-remote service does not started then refer installation log file which is generated at, 
  
  cat /var/log/groots/gmetrics/gmetrics_agent_setup.sh.log
  
* And gmetrics-remote service log file at, 

  cat /groots/monitoring/var/gmetrics-remote.log 
  

## Testing

  Locally test, 
  telnet localhost 5666

  Remote test, 
  telnet REMOTE_IP 5666
 
## For Addition of Plugins 
 
* Plugins files are placed in, 
 
  /root/groots-metrics/gmetrics-remote-plugin/
  
  Copy the plugins,
  to /groots/monitoring/libexec	

* cp -av /root/groots-metrics/gmetrics-remote-plugin/DIR_NAME/* /groots/monitoring/libexec/

  ### Appsensors plugins 
  cp -av /root/groots-metrics/gmetrics-remote-plugin/appsensors/* /groots/monitoring/libexec/

  ### Aws plugins 
  cp -av /root/groots-metrics/gmetrics-remote-plugin/aws/* /groots/monitoring/libexec/  

  ### Backup plugins 
  cp -av /root/groots-metrics/gmetrics-remote-plugin/backup/* /groots/monitoring/libexec/  

  ### Dnsrecords plugins 
  cp -av /root/groots-metrics/gmetrics-remote-plugin/dnsrecords/* /groots/monitoring/libexec/  

  ### Docker plugins 
  cp -av /root/groots-metrics/gmetrics-remote-plugin/docker/* /groots/monitoring/libexec/

  ### Expiry plugins 
  cp -av /root/groots-metrics/gmetrics-remote-plugin/expiry/* /groots/monitoring/libexec/

  ### Hardware plugins 
  cp -av /root/groots-metrics/gmetrics-remote-plugin/hardware/* /groots/monitoring/libexec/

  ### Kubernetes plugins 
  cp -av /root/groots-metrics/gmetrics-remote-plugin/kubernetes/* /groots/monitoring/libexec/

  ### Lamp plugins 
  cp -av /root/groots-metrics/gmetrics-remote-plugin/lamp/* /groots/monitoring/libexec/

  ### Mithi plugins 
  cp -av /root/groots-metrics/gmetrics-remote-plugin/mithi/* /groots/monitoring/libexec/

  ### Os plugins 
  cp -av /root/groots-metrics/gmetrics-remote-plugin/os/* /groots/monitoring/libexec/

  ### Website plugins 
  cp -av /root/groots-metrics/gmetrics-remote-plugin/website/* /groots/monitoring/libexec/

  ### Zimbra plugins
  cp -av /root/groots-metrics/gmetrics-remote-plugin/zimbra/* /groots/monitoring/libexec/ 

### Error : 
If you got following error in monitoring.

ERROR : "Is there a typo in the command or service configuration?: sudo: sorry, you must have a tty to run sudo"

Then execute following command and reschedule command and check the result.

sed -i -e 's/Defaults    requiretty.*/#Defaults    requiretty/g' /etc/sudoers

## License
  This program is distributed in the hope that it will be useful,
  but under groots software technologies @rights.


