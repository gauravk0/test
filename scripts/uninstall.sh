#!/bin/bash
#######################################################
# Program: Gmetrics Agent setup uninstallation.
#
# Purpose:
#  This script uninstalls gmetrics-agent on the remote system,
#  can be run in interactive.
#
# License:
#  This program is distributed in the hope that it will be useful,
#  but under groots software technologies @rights.
#
#######################################################

# Check for people who need help - aren't we all nice ;-)
#######################################################

# Set script name
#######################################################

SCRIPTNAME="gmetrics_agent_uninstall.sh"

# Import Hostname
#######################################################

HOSTNAME=$(hostname)

# Logfile
#######################################################

LOGDIR=/var/log/groots/metrics/
LOGFILE=$LOGDIR/"$SCRIPTNAME".log
if [ ! -d $LOGDIR ]
then
        mkdir -p $LOGDIR
elif [ ! -f $LOGFILE ]
then
        touch $LOGFILE
fi

# Logger function
#######################################################

log () {
while read line; do echo "[`date +"%Y-%m-%dT%H:%M:%S,%N" | rev | cut -c 7- | rev`][$SCRIPTNAME]: $line"| tee -a $LOGFILE 2>&1 ; done
}

# Main function
#######################################################

# To disable gmetrics-agent service and daemon-reload
#######################################################

disable_service () {

echo "#################################################" | log
echo "Disabling gmetrics-agent service" | log
sudo systemctl disable gmetrics-agent | log
echo "#################################################" | log
sudo systemctl stop gmetrics-agent | log
echo "gmetrics-agent service stopped" | log
echo "#################################################" | log
rm -rvf /lib/systemd/system/gmetrics-agent.service | log
echo "gmetrics-agent service successfully removed." | log
echo "#################################################" | log
echo "Daemon reloading to make changes" | log
sudo systemctl daemon-reload | log
}

# To remove /etc/logrotate.d/gmetrics-agent logrotate file
#######################################################

remove_logrotate () {

echo "#################################################" | log
echo "Removing logrotate file" | log
sudo rm -rvf /etc/logrotate.d/gmetrics-agent | log
echo "#################################################" | log
echo "Removed "/etc/logrotate.d/gmetrics-agent" file" | log
}

# To remove port from /etc/services
#######################################################

remove_service_port () {

echo "#################################################" | log
echo "Take backup of "/etc/services"" | log
cp -avp /etc/services /etc/services_$(date +"%d-%m-%YT%H-%M-%S") | log
echo "#################################################" | log
echo "Remove port from Service file" | log
sed -i '/gmetrics-agent 5666\/tcp # Gmetrics services/d' /etc/services | log
}


# To remove groots & empty tmp directory
#######################################################

remove_groots_directory () {

echo "#################################################" | log
echo "Emptying "/groots/tmp/" directory" | log
rm -rvf /groots/tmp/* | log
rm -rvf /groots/tmp/.svn/ | log
echo "#################################################" | log
echo "Removing "/groots/metrics" directory" | log
rm -rvf /groots/metrics | log
echo "Verifing deletion of "/groots/metrics" directory.." | log

if [ ! -d /groots/metrics ]; then
echo "/groots/metrics is completely removed." | log
else
echo "/groots/metrics could not be removed. " | log
exit 1;
fi

}

# To remove groots user and home directory
#######################################################

remove_user () {

echo "#################################################" | log
echo "Removing groots user" | log
userdel groots
if [ ! -d /home/groots/ ]; then
echo "#################################################" | log
echo "groots user home directory is not present" | log
else
echo "#################################################" | log
rm -rf /home/groots | log
echo "Removed groots home directory" | log
fi

}

# To remove firewall port for gmetrics-agent
#######################################################

remove_firewall_entry () {

OSNAME=$(cat /etc/*release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print $1}')

if [ $OSNAME == "Ubuntu" ]; then
        echo "#################################################" | log
        echo "Removing gmetrics-agent ufw entry" | log
        rm -rvf /etc/ufw/applications.d/gmetrics-agent | log

elif [  $OSNAME == "Centos" ]; then
        echo "#################################################" | log
        echo "Removing port 5666 from firewalld" | log
        firewall-cmd --permanent --remove-port=5666/tcp | log
        firewall-cmd --reload | log
        firewall-cmd --list-all | log
        echo "gmetrics-agent port is removed." | log
fi

}


# To remove sudoers-entry for gmetrics-agent
#######################################################

remove_sudoers_entry () {

echo "#################################################" | log
echo "Removing sudoers entry for gmetrics-agent" | log
rm -rvf /etc/sudoers.d/gmetrics-agent | log
echo "removed "/etc/sudoers.d/gmetrics-agent" " | log

}

# Function calling
#######################################################

while true
do
        echo "#######################################################" | log
        echo "Gmetrics agent installtion starting at [`date`]." | log

        disable_service
        remove_firewall_entry
        remove_logrotate
        remove_service_port
        remove_user
        remove_sudoers_entry
        remove_groots_directory

        echo "Gmetrics Agent is successfully uninstalled." | log
        echo "Gmetrics Agent uninstallation is completed at [`date`]." | log
		echo "#######################################################" | log
		
break
done
