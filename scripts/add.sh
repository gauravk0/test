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
SCRIPTNAME=$(basename $0)

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

#if [ "${1}" = "--help" -o "${#}" != "6" ];
#then
#echo -e "
#        Plugin list: sms, appsensors, aws, backup, dns, docker, elk, expiry, hardware, lamp, mithi, os, website, jvm, node, jenkins
#        OPTION                 DESCRIPTION
#        -----------------------------------------
#        --help                   help
#        -p [plugin]            plugin name
#        -----------------------------------------
#        Usage: sh $SCRIPTNAME  -p [plugin name]
#        Ex: sh addplugin.sh -p aws";
#    exit 3;
#fi

# Get OS
#######################################################

OSNAME=$(cat /etc/*release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print $1}')
echo "#######################################################" | log
echo "Verifying if Subversion is present or not.." | log

if [ $OSNAME = "CentOS" ]; then

    svn --version > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo "#######################################################" | log
        echo "Svn is installed!" | log
    else
        echo "Svn is not installed! Exiting now.." | log
        echo "#######################################################"
        echo "To install svn: yum install subversion -y " | log
        exit 3;
    fi
fi


if [ $OSNAME = "Ubuntu" ]; then

    svn --version > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo "########################################################" | log
        echo "Svn is installed!" | log
    else
        echo "Svn is not installed! Exiting now.." | log
        echo "########################################################" | log
        echo "To install svn: apt install subversion  " | log
        exit 3;
    fi
fi


# collecting git Username and Password
#######################################################


echo "Enter plugin name.." | log
read PLUGINNAME

echo "#######################################################" | log
echo "Enter git username:" | log
read USERNAME

echo "#######################################################" | log
echo "Enter git Password:" | log
read -s PASSWORD

# Destination path
#######################################################

DEST="/groots/metrics/libexec/"

# Svn command to Download plugin folder from git to /groots/metrics/libexec
#######################################################

SVNCMD="--non-interactive --no-auth-cache --username $USERNAME --password "$PASSWORD" $DEST"
GITPATH="svn checkout https://github.com/grootsadmin/gmetrics-plugins/trunk/os/linux"

if [ "$PLUGINNAME" = "sms" ] || [ "$PLUGINNAME" = "Sms" ] || [ "$PLUGINNAME" = "SMS" ] ; then
    echo "Plugin "sms" selected to add in "$DEST" " | log
    $GITPATH/sms $SVNCMD
        rm -rf $DEST/.svn
    echo "$PLUGINNAME plugin successfully added. " | log


elif [ "$PLUGINNAME" = "aws" ] || [ "$PLUGINNAME" = "Aws" ] || [ "$PLUGINNAME" = "AWS" ] ; then
    echo "Plugin "aws" selected to add in "$DEST" " | log
    $GITPATH/aws $SVNCMD
        rm -rf $DEST/.svn
    echo "$PLUGINNAME plugin successfully added. " | log


elif [ "$PLUGINNAME" = "appsensors" ] || [ "$PLUGINNAME" = "Appsensors" ] || [ "$PLUGINNAME" = "APPSENSORS" ]; then
    echo "Plugin "appsensors" selected to add in "$DEST" " | log
    $GITPATH/appsensors $SVNCMD
        rm -rf $DEST/.svn
    echo "$PLUGINNAME plugin successfully added. " | log


elif [ "$PLUGINNAME" = "expiry" ] || [ "$PLUGINNAME" = "Expiry" ] || [ "$PLUGINNAME" = "EXPIRY" ]; then
    echo "Plugin "expiry" selected to add in "$DEST" " | log
    $GITPATH/expiry $SVNCMD
        rm -rf $DEST/.svn
    echo "$PLUGINNAME plugin successfully added. " | log


elif [ "$PLUGINNAME" = "backup" ] || [ "$PLUGINNAME" = "Backup" ] || [ "$PLUGINNAME" = "BACKUP" ]; then
    echo "Plugin "backup" selected to add in "$DEST" " | log
    $GITPATH/backup $SVNCMD
        rm -rf $DEST/.svn
    echo "$PLUGINNAME plugin successfully added. " | log


elif [ "$PLUGINNAME" = "dns" ] || [ "$PLUGINNAME" = "DNS" ] || [ "$PLUGINNAME" = "dns" ]; then
    echo "Plugin "dns" selected to add in "$DEST" " | log
    $GITPATH/dns $SVNCMD
        rm -rf $DEST/.svn
    echo "$PLUGINNAME plugin successfully added. " | log


elif [ "$PLUGINNAME" = "docker" ] || [ "$PLUGINNAME" = "Docker" ] || [ "$PLUGINNAME" = "DOCKER" ]; then
    echo "Plugin "docker" selected to add in "$DEST" " | log
    $GITPATH/docker $SVNCMD
        rm -rf $DEST/.svn
    echo "$PLUGINNAME successfully added. " | log


elif [ "$PLUGINNAME" = "hardware" ] || [ "$PLUGINNAME" = "Hardware" ] || [ "$PLUGINNAME" = "HARDWARE" ]; then
    echo "Plugin "hardware" selected to add in "$DEST" " | log
    $GITPATH/hardware $SVNCMD
        rm -rf $DEST/.svn
    echo "$PLUGINNAME plugin successfully added. " | log


elif [ "$PLUGINNAME" = "lamp" ] || [ "$PLUGINNAME" = "Lamp" ] || [ "$PLUGINNAME" = "LAMP" ]; then
    echo "Plugin "lamp" selected to add in "$DEST" " | log
    $GITPATH/lamp $SVNCMD
        rm -rf $DEST/.svn
    echo "$PLUGINNAME plugin successfully added. " | log


elif [ "$PLUGINNAME" = "mithi" ] || [ "$PLUGINNAME" = "Mithi" ] || [ "$PLUGINNAME" = "MITHI" ]; then
    echo "Plugin "mithi" selected to add in "$DEST" " | log
    $GITPATH/mithi $SVNCMD
        rm -rf $DEST/.svn
    echo "$PLUGINNAME plugin successfully added. " | log


elif [ "$PLUGINNAME" = "os" ] || [ "$PLUGINNAME" = "Os" ] || [ "$PLUGINNAME" = "OS" ]; then
    echo "Plugin "os" selected to add in "$DEST" " | log
    $GITPATH/os $SVNCMD
        rm -rf $DEST/.svn
    echo "$PLUGINNAME plugin successfully added. " | log


elif [ "$PLUGINNAME" = "jvm" ] || [ "$PLUGINNAME" = "Jvm" ] || [ "$PLUGINNAME" = "JVM" ]; then
    echo "Plugin "jvm" selected to add in "$DEST" " | log
    $GITPATH/jvm $SVNCMD
        rm -rf $DEST/.svn
    echo "$PLUGINNAME plugin successfully added. " | log


elif [ "$PLUGINNAME" = "website" ] || [ "$PLUGINNAME" = "Website" ] || [ "$PLUGINNAME" = "WEBSITE" ]; then
    echo "Plugin "website" selected to add in "$DEST" " | log
    $GITPATH/website $SVNCMD
        rm -rf $DEST/.svn
    echo "$PLUGINNAME plugin successfully added. " | log

elif [ "$PLUGINNAME" = "node" ] || [ "$PLUGINNAME" = "Node" ] || [ "$PLUGINNAME" = "NODE" ]; then
    echo "Plugin "node" selected to add in "$DEST" " | log
    $GITPATH/node $SVNCMD
    rm -rf $DEST/.svn
    echo "$PLUGINNAME plugin successfully added. " | log

elif [ "$PLUGINNAME" = "jenkins" ] || [ "$PLUGINNAME" = "Jenkins" ] || [ "$PLUGINNAME" = "JENKINS" ]; then
    echo "Plugin "jenkins" selected to add in "$DEST" " | log
    $GITPATH/jenkins $SVNCMD
    rm -rf $DEST/.svn
    echo "$PLUGINNAME plugin successfully added. " | log

elif [ "$PLUGINNAME" = "ELK" ] || [ "$PLUGINNAME" = "Elk" ] || [ "$PLUGINNAME" = "elk" ]; then
    echo "Plugin "elk" selected to add in "$DEST" " | log
    $GITPATH/elk $SVNCMD
    rm -rf $DEST/.svn
    echo "$PLUGINNAME plugin successfully added. " | log

else
    echo "#######################################################"
    echo "Invalid $PLUGINNAME. Enter valid plugin name."
    exit 3;
fi


sudo echo 'store-plaintext-passwords = no' >> /root/.subversion/servers
