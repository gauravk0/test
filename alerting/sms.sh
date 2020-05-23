

#!/bin/bash
########################################################
# Program: Gmetrics monitoring sms balance check.
#
# Purpose:
#  Checking sms plan balance and validity checking.
#  can be run in interactive.
#
# License:
#  This program is distributed in the hope that it will be useful,
#  but under groots software technologies @rights.
#
########################################################

#Set script name
########################################################
SCRIPTNAME=`basename $0`

# Import Hostname
########################################################
HOSTNAME=$(hostname)

# Usage Details
########################################################

if [ "${1}" = "--help" -o "${#}" = "0" ];
       then
       echo -e "Usage: $SCRIPTNAME -w [VALUE] -c [VALUE]
        OPTION          DESCRIPTION
        ----------------------------------
        --help              Help
        -w [VALUE]      Warning Threshold
        -c [VALUE]      Critical Threshold
        ----------------------------------
        Use: $SCRIPTNAME -w 500 -c 300
Note : [VALUE] must be an integer.";
       exit 3;
fi


# Get user-given variables
########################################################

while getopts "w:c:" Input;
do
       case ${Input} in
       w)      WARN=${OPTARG};;
       c)      CRIT=${OPTARG};;
       *)      echo "Usage: $SCRIPTNAME -w [VALUE] -c [VALUE] or Use --help "
               exit 3
               ;;
       esac
done

########################################################
if [ $WARN -lt $CRIT ]
then
        echo "ERROR : Warning threshold must not be less than Critical threshold."
        exit 3
fi

########################################################
# Main Logic
########################################################

USERNAME="grootssoftwaretechnologies"
PASSWORD="9764611003"

COMMAND="http://login.bulksmsgateway.in/userbalance.php?user=$USERNAME&password=$PASSWORD&type=3"

# Check sms balance details.
########################################################

BALANCE="$(curl -Ss -k -XGET $COMMAND 2>/dev/null | awk -F\" '/remainingcredits/ {print $4}' )"

# Check sms plan validity.
########################################################

VALIDITY="$(curl -Ss -k -XGET $COMMAND 2>/dev/null | awk -F\" '/validity/ {print $8}' )"

# Check sms plan type.
########################################################

PLAN="$(curl -Ss -k -XGET $COMMAND 2>/dev/null | awk -F ":" '{print $4}' | sed 's/["}]//g' )"

########################################################
OUTPUT="SMS plan $PLAN, remaining sms $BALANCE and validity is $VALIDITY"
########################################################

if [ "$BALANCE" -gt "$WARN" ]
then
        STATUS="OK";
        EXITSTAT=0;

elif [ "$BALANCE" -lt "$WARN" ]
        then
                if [ "$BALANCE" -le "$CRIT" ]
                then
                        STATUS="CRITICAL";
                        EXITSTAT=2;
                else
                        STATUS="WARNING";
                        EXITSTAT=1;
                fi
else
        STATUS="UNKNOWN";
        EXITSTAT=3;
fi
echo "$OUTPUT | Credit = $BALANCE"c";$WARN;$CRIT;0"
exit $EXITSTAT

