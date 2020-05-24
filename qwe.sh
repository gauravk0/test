
#!/bin/bash
###########################################################
# Program: To check the pre checks for Gmetrics installation.
#
# Purpose:
#  To check the environment for Gmetrics Installation
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

# Logfile
#######################################################

LOGFILE=/var/log/groots/gmetrics/"$SCRIPTNAME".log
LOGDIR=/var/log/groots/gmetrics/
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

# Verifying if the user is root or has root privileges.
##################################

check_logged_user() {

LOGGEDUSER=$(whoami)
if [ $LOGGEDUSER != root ]
then
        echo 'You are not authorized to run this script, this script required "root" user or equivalent privileges.' | log
        echo "#######################################################" | log
        exit 3;
fi
}


# Main Logic.
#######################################################

# Obtaining the OS name and version of the Server.
#############################################################

gmetrics_os_details () {

OSNAME=$(cat /etc/*release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print $1}')
OS_VERSION=$(cat /etc/*release | grep "VERSION_ID" | sed 's/VERSION_ID=//g' |sed 's/["]//g' | awk '{print $1}' | cut -d. -f1)

}

# Finding the package count.
########################################

package_count_Check () {

echo "##########################################"  | log
echo "Counting the installed packages: " | log

packagecount=$(rpm -qa | wc -l)
echo "Installed package: $packagecount " | log

if [ $packagecount -ge 405 ] ; then
        echo "All necessary packages are present" | log
else
        echo "Package count does not meet, it should be 405. Reinstallation of OS is needed. " | log
		exit 3;
fi
}

# Checking Gmetrics user exists or not .
#######################################

gmetrics_user_check () {

echo "##########################################"  | log
echo "Searching For User groots..." | log

if [ $(getent passwd groots) ] ; then
    echo "User: groots already exists " | log
else
    echo " User: groots is not present. "  | log
fi
}

# Finding gmetrics directory, exists or not.
##############################################

gmetrics_directory_check () {

echo "############################################"  | log
echo "Finding the gmetrics directory.." | log
DIR="/groots"

if [ -d $DIR ] ; then
        echo " Gmetrics Directory \"$DIR\" is present. " | log
else
        echo " Gmetrics Directory \"$DIR\" is not present. " | log

fi
}

# Checking SWAP memory
##########################################################

swap_mem_info () {

echo "############################################" | log 
echo "Checking the Allocation of Swap... " | log 

if free | awk '/^Swap:/ {exit !$2}'; then

    echo "Swap is Available" | log 
	echo "Detailed information about Swap memory: " | log 
	free -mh | grep Swap | log 
	echo "####################################################" | log 
	echo "Checking the allocated SWAP memory to the system..." | log 
	
	swap=$(free -b | grep Swap | awk '{print $2}' )
	echo "Swap is allocated $swap in (bytes) " | log 

	if [ $swap -lt 2147483648 ]; then
		echo "Swap is to be required minimum 2GB" | log
	else
		echo "Swap is allocated correctly (minimum 2 GB) " | log 
	fi 

else
    echo "Swap is not allocated" | log 
fi
}

# Finding Sudoers entry for gmetrics
###########################################

gmetrics_sudoers_entry () {

echo "#############################################" | log
echo "Searching Gmetrics-core entry in Sudoers file" | log

file=/etc/sudoers.d/gmetrics-core

if [ ! -f $file ] ; then
	echo "OK."	| log 
else
	echo "Sudoers file \"$file\" for gmetrics is present" | log 
	
fi
}		


# Main Functions calling.
###################################

         # Obtaining the OS server details and calling function
		#gmetrics_os_details


        # Checking the logged user as, root or user having equivalent privileges.
        check_logged_user

        # Finding Operating system details.
        gmetrics_os_details

        # Finding the count of packages.
        package_count_Check

        # Checking if the Gmetrics user exists or not.
        gmetrics_user_check

        # Checking the Gmetrics dir exists or not.
        gmetrics_directory_check
		
		# SWAP memory info. 
		swap_mem_info
		
        # Finding Sudoers entry for gmetrics.
        gmetrics_sudoers_entry
		

        echo "Gmetrics installation pre check is done successfully." | log
        echo "Gmetrics Installation pre check is completed at [`date`]." | log

fi

# End Main Logic.
###########################################






