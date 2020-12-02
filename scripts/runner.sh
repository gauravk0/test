#!/bin/bash
#######################################################
# Program: Gmetrics Agent installation.
#
# Purpose:
#  This script installing gmetrics-agent on the remote system,
#  can be run in interactive.
#
# License:
#  This program is distributed in the hope that it will be useful,
#  but under groots software technologies @rights.
#
#######################################################

# Check for people who need help - aren't we all nice ;-)
#######################################################

# Set scrit name
#########################################################
SCRIPTNAME="setup.sh"

#########################################################
# Get user-given variables
#########################################################

while (( $# )); do

        case "$1" in
        -b|--branch)
        BRANCH=$2
        ;;
        -h|--help)
        USAGE: ./$SCRIPTNAME --branch <master/alpha/beta>
        exit 3
        ;;
        esac
        shift
done

# Main Function 
#########################################################

GITPATH="https://raw.githubusercontent.com/grootsadmin/gmetrics-agent-setup/$BRANCH/v5/bin/gmetrics_agent_setup.sh"

echo "curl -s -k $GITPATH | bash"

# End function
########################################################
