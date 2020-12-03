#!/bin/bash
#######################################################
# Program: To add Plugins on remote side
#
# Purpose:
#  This script adds Plugins to remote host directory /groots/metrics/libexec
#  can be run in interactive.
#
# License:
#  This program is distributed in the hope that it will be useful,
#  but under groots software technologies @rights.
#
#######################################################

# Check for people who need help - aren't we all nice ;-)
#######################################################

#Set script name
#######################################################

SCRIPTNAME="addplugin.sh"

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

# Usage details
######################################################

if [ "${1}" = "--help" -o "${#}" != "2" ];
then
echo -e "
	Plugin list: sms, appsensors, aws, backup, dns, docker, elk, expiry, hardware, lamp, mithi, os, website, jvm, node, jenkins
	OPTION                 DESCRIPTION
	-----------------------------------------
	--help                   help
	-p [plugin]            plugin name
	-----------------------------------------
	Usage: sh $SCRIPTNAME  -p [plugin name]
	Ex: sh addplugin.sh -p aws";
	exit 3;
fi


#######################################################
# Get user-given variables
#######################################################

while getopts "p:" Input;
do
        case ${Input} in
        p) PLUGINNAME=$OPTARG;;
        *) echo "Usage: $SCRIPTNAME -p [plugin name]"
        exit 3;
        ;;
        esac
done

# type command is checking whether svn command present or not.
#######################################################

type svn >/dev/null 2>&1 || { echo >&2 "This plugin require "subversion" package, but it's not installed. Aborting."; exit 1; }

# To disable svn password cache storing
#######################################################

disable_svn_password () {

echo "#######################################################" | log
echo "Disabling svn password store" | log
sudo echo 'store-plaintext-passwords = no' >> /root/.subversion/servers
}

#  Download plugins from git using svn to /groots/metrics/libexec
#######################################################

copy_plugin () {

# Plugin list for available plugins
#######################################################

list=("sms" "appsensors" "aws" "backup" "dns" "docker" "elk" "expiry" "hardware" "lamp" "mithi" "os" "website" "jvm" "node" "jenkins")

# Verify if plugin present or not
#######################################################

if [[ " ${list[*]} " == *" $PLUGINNAME "* ]]; then
	echo "#######################################################" | log
	echo "List contains plugin - $PLUGINNAME" | log
else
	echo "#######################################################" | log
	echo "Plugin is not present. Enter a valid plugin name.." | log
	exit 1;
fi

# Collecting git username & password
######################################################

echo "#######################################################" | log
echo "Enter git username:" | log
read USERNAME

echo "#######################################################" | log
echo "Enter git Password:" | log
read -s PASSWORD

for item in ${list[@]}; 
do

	# Destination path
	#######################################################
	DEST="/groots/metrics/libexec/"	

	# Command for svn & git master repo path
	#######################################################

	SVNCMD="--non-interactive --no-auth-cache --username $USERNAME --password "$PASSWORD" $DEST"
	GITPATH="svn checkout https://github.com/grootsadmin/gmetrics-plugins/trunk/os/linux"
	echo "#######################################################" | log
	echo "Plugin "$PLUGINNAME" selected to add in "$DEST" " | log

	$GITPATH/$PLUGINNAME $SVNCMD  2>/dev/null || { echo "Incorrect git credentials, Exiting now..." | log ; exit 1; }
	rm -rf $DEST/.svn

	echo "#######################################################" | log
	echo "$PLUGINNAME plugin successfully added to $DEST. " | log

break
done 

}


# Function calling
#######################################################

while true
do
	disable_svn_password
	copy_plugin      
break
done

# End Main logic.
#######################################################
