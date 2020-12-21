#!/bin/bash
#######################################################
# Program: Gmetrics Core build.
#
# Purpose:
#  This script prepares Gmetrics Core build for centos7,
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


server_os_details () {

echo "#######################################################" | log
echo "Finding installed operating system details" | log
OSNAME=$(cat /etc/*release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print $1}')
echo "Installed operating system : $OSNAME" | log
OS_VERSION=$(cat /etc/*release | grep "VERSION_ID" | sed 's/VERSION_ID=//g' |sed 's/["]//g' | awk '{print $1}' | cut -d. -f1)
echo "OS Version is : $OS_VERSION" | log
}


gmetrics_core_packages_installation () {

echo "#######################################################" | log
echo "Install extra OS library package installation" | log 
yum  install epel-release -y
yum install wget telnet unzip mail mailx mlocate vim sysstat openssl mod_fcgid dos2unix glibc glibc-common gd gd-devel make net-snmp openssl-devel bind-utils net-snmp-devel net-snmp-utils net-snmp-perl  perl-devel -y
echo "#######################################################" | log
echo "Install group libraries" | log 
yum groupinstall "Development Tools" -y --setopt=group_package_types=mandatory,default,optional
echo "#######################################################" | log
echo "Install Nagios plugin package installation" | log 
yum install git man openssh-server openssh-clients iotop htop atop setuptool ntsysv rsync ntp httpd httpd-tools mod_perl net-tools httpd-devel expat-devel postfix bc lsof firewalld whois gettext automake autoconf perl-Net-SNMP nmap-ncat -y
echo "#######################################################" | log
echo "Install Check_MK installation" | log 
yum install gcc gcc-c++ perl net-snmp rpcbind mod_python mod_ssl php php-gd -y
yum install http://repo.iotti.biz/CentOS/7/x86_64/mod_python-3.5.0-16.el7.lux.1.x86_64.rpm -y
yum update -y

}

# Global path declaration
#######################################################

NAGIOSSOURCEFILE="https://github.com/NagiosEnterprises/nagioscore/releases/download/nagios-4.4.6/nagios-4.4.6.tar.gz"
NRPESOURCEFILE="https://github.com/NagiosEnterprises/nrpe/archive/nrpe-4.0.3.tar.gz"
DESTPATH="/root/gmetricsdata/"

download_nagios_source () {

echo "#######################################################" | log
echo "Creating temp directory" | log
mkdir -p $DESTPATH | log
echo "#######################################################" | log
echo "Downloading nagios source under "$DESTPATH" " | log
wget $NAGIOSSOURCEFILE -P $DESTPATH
tar -xvzf "$DESTPATH"nagios*tar.gz -C $DESTPATH | log
echo "#######################################################" | log
echo "Extracting nagios tar ball.."
FILEUNTAR=`tar -tvf "$DESTPATH"nagios*tar.gz | head -n 1 | awk '{print $6}' | sed -e 's|/||g'`
UNTARPATH=""$DESTPATH""$FILEUNTAR""
}

customisation_nagios () {
echo "#######################################################" | log
echo "Taking Backup of $UNTARPATH/base/nagios.c" | log
cp -av $UNTARPATH/base/nagios.c $UNTARPATHbase/nagios.c_original
echo "#######################################################" | log
echo "Updating customisation in $UNTARPATH/base/nagios.c file" | log
sed -i '/^[[:blank:]]*printf/ {s/Nagios/Gmetrics/g;}' $UNTARPATH/base/nagios.c;
sed -i '/^[[:blank:]]*printf/ s|Copyright (c) 1999-2009 Ethan Galstad|Copyright (c) 2018-2020 Groots Software|g' $UNTARPATH/base/nagios.c;
sed -i '/^[[:blank:]]*printf/ {s|www.nagios.org|www.groots.in|g;}' $UNTARPATH/base/nagios.c;
sed -i '/^[[:blank:]]*logit/ {s/Nagios/Gmetrics/g;}' $UNTARPATH/base/nagios.c;
sed -i '/^[[:blank:]]*if(!strstr/ {s/"nagios.cfg"/"gmetrics-config.cfg"/g;}' $UNTARPATH/base/nagios.c;
sed -i 's|Copyright (c) 2009-present Gmetrics Core Development Team and Community Contributor|Copyright (c) 2009-present Nagios Development Team and Community Contributor|g' $UNTARPATH/base/nagios.c;

}

customisation_nagiostat () {

echo "#######################################################" | log
echo "Taking Backup of $UNTARPATH/base/nagiostats.c" | log
cp -av $UNTARPATH/base/nagiostats.c $UNTARPATH/base/nagiostats.c_original | log
echo "#######################################################" | log
echo "Updating customisation in $UNTARPATH/base/nagiostats.c" | log
sed -i '/^[[:blank:]]*printf/ s|Copyright (c) 2003-2008 Ethan Galstad (www.nagios.org)|Copyright (c) 2018-2020 Gmetrics DevOps Team (www.groots.in)|g' $UNTARPATH/base/nagiostats.c
sed -i '/^[[:blank:]]*printf/ {s/Nagios/Gmetrics/g;}' $UNTARPATH/base/nagiostats.c
}

customisation_events () {

echo "#######################################################" | log
echo "Taking Backup of $UNTARPATH/base/events.c" | log
cp -av $UNTARPATH/base/events.c $UNTARPATH/base/events.c_original
echo "#######################################################" | log
echo "Updating customisation in $UNTARPATH/base/events.c" | log
sed -i '/^[[:blank:]]*printf/ {s/Nagios/Gmetrics/g;}' $UNTARPATH/base/events.c;
}


customisation_cgi () {
echo "#######################################################" | log
echo "Taking Backup of $UNTARPATH/sample-config/cgi.cfg.in" | log
cp -av $UNTARPATH/sample-config/cgi.cfg.in $UNTARPATH/sample-config/cgi.cfg.in_original
echo "#######################################################" | log
echo "Updating customisation in "$UNTARPATH/sample-config/cgi.cfg.in" cgi file"
sed -i '/# / s/Nagios/GMETRICS/g' $UNTARPATH/sample-config/cgi.cfg.in;
sed -i 's|main_config_file=@sysconfdir@/nagios.cfg|main_config_file=@sysconfdir@/gmetrics-config.cfg|g' $UNTARPATH/sample-config/cgi.cfg.in
sed -i 's|authorized_for_system_information=nagiosadmin|authorized_for_system_information=root@localhost,manager|g' $UNTARPATH/sample-config/cgi.cfg.in
sed -i 's|authorized_for_configuration_information=nagiosadmin|authorized_for_configuration_information=root@localhost,manager|g' $UNTARPATH/sample-config/cgi.cfg.in
sed -i 's|authorized_for_system_commands=nagiosadmin|authorized_for_system_commands=root@localhost,manager|g' $UNTARPATH/sample-config/cgi.cfg.in

sed -i 's|authorized_for_all_services=nagiosadmin|authorized_for_all_services=root@localhost,manager|g' $UNTARPATH/sample-config/cgi.cfg.in
sed -i 's|authorized_for_all_hosts=nagiosadmin|authorized_for_all_hosts=root@localhost,manager|g' $UNTARPATH/sample-config/cgi.cfg.in
sed -i 's|authorized_for_all_service_commands=nagiosadmin|authorized_for_all_service_commands=root@localhost,manager|g' $UNTARPATH/sample-config/cgi.cfg.in
sed -i 's|authorized_for_all_host_commands=nagiosadmin|authorized_for_all_host_commands=root@localhost,manager|g' $UNTARPATH/sample-config/cgi.cfg.in

sed -i 's|#authorized_for_read_only=user1,user2|authorized_for_read_only=graph|g' $UNTARPATH/sample-config/cgi.cfg.in
sed -i 's|authorized_for_all_host_commands=nagiosadmin|authorized_for_all_host_commands=root@localhost,manager|g' $UNTARPATH/sample-config/cgi.cfg.in
sed -i 's|lock_author_names=1|lock_author_names=0|g' $UNTARPATH/sample-config/cgi.cfg.in
}

customisation_httpd () {

echo "#######################################################" | log
echo "Taking Backup of $UNTARPATH/sample-config/httpd.conf.in" | log
cp -av $UNTARPATH/sample-config/httpd.conf.in $UNTARPATH/sample-config/httpd.conf.in_original
echo "#######################################################" | log
echo "Updating customisation in $UNTARPATH/sample-config/httpd.conf.in" | log
sed -i '/^[[:blank:]]*AuthName/ {s/Nagios/Gmetrics/g;}' $UNTARPATH/sample-config/httpd.conf.in;
sed -i '/^[[:blank:]]*AuthUserFile/ {s/htpasswd.users/.gmetrics-config.users/g;}' $UNTARPATH/sample-config/httpd.conf.in;

}

customisation_nagios_cfg () {

echo "#######################################################" | log
echo "Taking Backup of $UNTARPATH/sample-config/nagios.cfg.in" | log
cp -av $UNTARPATH/sample-config/nagios.cfg.in $UNTARPATH/sample-config/nagios.cfg.in_original
echo "#######################################################" | log
echo "Taking Backup of $UNTARPATH/sample-config/nagios.cfg.in" | log

sed -i '/# / s/NAGIOS.CFG/GMETRICS-CONFIG.CFG/g' $UNTARPATH/sample-config/nagios.cfg.in;
sed -i '/^[[:blank:]]*log_file/ {s/nagios.log/gmetrics-config.log/g;}' $UNTARPATH/sample-config/nagios.cfg.in;
sed -i '/^[[:blank:]]*command_file/ {s/nagios.cmd/gmetrics-config.cmd/g;}' $UNTARPATH/sample-config/nagios.cfg.in;
sed -i 's|#query_socket=@localstatedir@/rw/nagios.qh|query_socket=@localstatedir@/rw/gmetrics-config.qh|g' $UNTARPATH/sample-config/nagios.cfg.in;
sed -i '/^[[:blank:]]*temp_file/ {s/nagios.tmp/gmetrics.tmp/g;}' $UNTARPATH/sample-config/nagios.cfg.in;
sed -i 's|service_check_timeout=60|service_check_timeout=6000|g' $UNTARPATH/sample-config/nagios.cfg.in;
sed -i 's|host_check_timeout=30|host_check_timeout=3000|g' $UNTARPATH/sample-config/nagios.cfg.in;
sed -i 's|event_handler_timeout=30|event_handler_timeout=3000|g' $UNTARPATH/sample-config/nagios.cfg.in;
sed -i 's|notification_timeout=30|notification_timeout=3000|g' $UNTARPATH/sample-config/nagios.cfg.in;
sed -i 's|ocsp_timeout=5|ocsp_timeout=600|g' $UNTARPATH/sample-config/nagios.cfg.in;
sed -i 's|ochp_timeout=5|ochp_timeout=600|g' $UNTARPATH/sample-config/nagios.cfg.in;
sed -i 's|perfdata_timeout=5|perfdata_timeout=600|g' $UNTARPATH/sample-config/nagios.cfg.in;
sed -i 's|date_format=us|date_format=euro|g' $UNTARPATH/sample-config/nagios.cfg.in;
sed -i '/^[[:blank:]]*debug_file/ {s/nagios.debug/gmetrics-config.debug/g;}' $UNTARPATH/sample-config/nagios.cfg.in;

}


configure_binary () {

echo "#######################################################" | log
echo "Compiling Nagios binaries and staring installation.." | log

cd $UNTARPATH
./configure --prefix=/groots/metrics/config --exec-prefix=/groots/metrics/config --with-command-group=nagcmd --with-nagios-user=groots --with-nagios-group=groots
make all ;
make install ;
make install-init ;
make install-commandmode ;
make install-config ;
make install-webconf ;
make install-exfoliation ;

}

set_groots_permission () {

echo "#######################################################" | log
echo "Setting groots permission to /groots/metrics/config/libexec/eventhandlers/" | log
cp -R contrib/eventhandlers /groots/metrics/config/libexec/
chown -hR groots:groots /groots/metrics/config/libexec/eventhandlers/
}

confirm_nagios_config () {

echo "#######################################################" | log
echo "Verifying Configuration test for nagios.." | log
/groots/metrics/config/bin/nagios -v /groots/metrics/config/etc/nagios.cfg || { echo "Configuration test for nagios failed!Aborting.."; exit 1;}
echo "Configuration test is completed. Found 0 Errors." | log
}


update_configuration_file () {

echo "#######################################################" | log
echo "Updating cgi configuration file " | log

cp /groots/metrics/config/etc/cgi.cfg /groots/metrics/config/etc/cgi.cfg_original | log
sed -i 's/refresh_rate=90/refresh_rate=30/g' /groots/metrics/config/etc/cgi.cfg
cp /groots/metrics/config/etc/nagios.cfg /groots/metrics/config/etc/nagios.cfg_original | log
cp /groots/metrics/config/etc/nagios.cfg /groots/metrics/config/etc/gmetrics-config.cfg | log

sed -i 's/refresh_rate=90/refresh_rate=30/g' /groots/metrics/config/etc/cgi.cfg
#sed -i '/cfg_file=/groots/metrics/config/etc/objects/templates.cfg/a cfg_file=/groots/metrics/config/etc/objects/manager.cfg' /groots/metrics/config/etc/gmetrics-config.cfg
sed -i '29i cfg_file=/groots/metrics/config/etc/objects/manager.cfg' /groots/metrics/config/etc/gmetrics-config.cfg
sed -i 's|lock_file=/run/nagios.lock|lock_file=/var/run/gmetrics-config.lock|g' /groots/metrics/config/etc/gmetrics-config.cfg;
sed -i 's|temp_path=/tmp|temp_path=/groots/metrics/tmp|g' /groots/metrics/config/etc/gmetrics-config.cfg;
sed -i 's|admin_email=groots@localhost|admin_email=monitor@groots.in|g' /groots/metrics/config/etc/gmetrics-config.cfg;
sed -i 's|admin_pager=pagegroots@localhost|#admin_pager=pagegroots@localhost|g' /groots/metrics/config/etc/gmetrics-config.cfg;
sed -i 's|max_debug_file_size=1000000|max_debug_file_size=1000000000|g' /groots/metrics/config/etc/gmetrics-config.cfg;
sed -i 's|#host_down_disable_service_checks=0|host_down_disable_service_checks=1|g' /groots/metrics/config/etc/gmetrics-config.cfg;
}


update_object_file () {

cp /groots/metrics/config/etc/objects/localhost.cfg /groots/metrics/config/etc/objects/localhost.cfg_original | log
sed -i 's/localhost/Monitor/g' /groots/metrics/config/etc/objects/localhost.cfg
echo "#######################################################" | log
echo "Updating /groots/metrics/config/etc/objects/manager.cfg config file" | log
cat /root/gmetrics-build/gmetrics-core/template/manager.cfg > /groots/metrics/config/etc/objects/manager.cfg
echo "Updating /groots/metrics/config/etc/objects/manager.cfg config file" | log
cp -av /groots/metrics/config/etc/objects/contacts.cfg /groots/metrics/config/etc/objects/contacts.cfg_original | log
cat /root/gmetrics-build/gmetrics-core/template/contacts.cfg > /groots/metrics/config/etc/objects/contacts.cfg
echo "#######################################################" | log
echo "Commenting contact group in "/groots/metrics/config/etc/objects/templates.cfg" " | log 
sed -i 's/contact_groups                  admins/#contact_groups                  admins/g' /groots/metrics/config/etc/objects/templates.cfg

}


set_user_password () {

echo "#######################################################" | log
echo "Setting password for root@localhost user" | log
htpasswd -B -c -C10 -b /groots/metrics/config/etc/.gmetrics-config.users root@localhost groots#2345
echo "#######################################################" | log
echo "For deleting user" | log
echo "#######################################################" | log
echo "htpasswd -D /groots/metrics/config/etc/.gmetrics-config.users <USERNAME>" | log

}


update_binary_nagios () {

echo "#######################################################" | log
echo "Copying nagios config file" | log
cp /groots/metrics/config/bin/nagios /groots/metrics/config/bin/gmetrics | log
echo "#######################################################" | log
echo "Updating permission for /groots/metrics/config/bin/gmetrics " | log
chmod 0774 /groots/metrics/config/bin/gmetrics
echo "#######################################################" | log
echo "Updating ownership for /groots/metrics/config/bin/gmetrics " | log
chown -R groots. /groots/metrics/config/bin/gmetrics
ls -ltrh /groots/metrics/config/bin/gmetrics

}

update_configtest () {

echo "#######################################################" | log
echo "Preparing configtest script "/groots/metrics/bin/configtest" " | log
mkdir /groots/metrics/bin/ && mkdir /groots/metrics/tmp  
cat /root/gmetrics-build/gmetrics-core/template/configtest > /groots/metrics/bin/configtest
echo "#######################################################" | log
echo "Updating execution permission for "/groots/metrics/bin/configtest" " | log
dos2unix /groots/metrics/bin/configtest
chmod +x /groots/metrics/bin/configtest
echo "#######################################################" | log
echo "Verifying Gmetrics configuration with Configtest" | log
/groots/metrics/bin/configtest

}


Update_gmetrics_core_servicefile () {

echo "#######################################################" | log
echo "Updating gmetrics-core service file.." | log

echo "
[Unit]
Description=Gmetrics Core.
Documentation=https://www.groots.in
After=network.target local-fs.target

[Service]
Type=forking
Restart=on-failure
ExecStartPre=/groots/metrics/config/bin/gmetrics -v /groots/metrics/config/etc/gmetrics-config.cfg
ExecStart=/groots/metrics/config/bin/gmetrics -d /groots/metrics/config/etc/gmetrics-config.cfg
ExecStop=/bin/kill -s TERM ${MAINPID}
ExecStopPost=/bin/rm -f /groots/metrics/config/var/rw/gmetrics-config.cmd
ExecReload=/bin/kill -s HUP ${MAINPID}
Restart=always
RestartSec=3

LimitNOFILE=10000
TimeoutStopSec=20

[Install]
WantedBy=multi-user.target" > /usr/lib/systemd/system/gmetrics-core.service

echo "#######################################################" | log
echo "Updating ownership to /groots/metrics " | log
chown -R groots. /groots/metrics
echo "#######################################################" | log
echo "Restarting gmetrics-core service" | log
systemctl enable gmetrics-core
systemctl restart gmetrics-core
echo "#######################################################" | log
echo "Gmetrics-core service status.." | log
systemctl status gmetrics-core | log
echo "#######################################################" | log
echo "Taking backup of "/groots/metrics/config/etc/nagios.cfg "" | log
mv /groots/metrics/config/etc/nagios.cfg /groots/metrics/config/etc/nagios.cfg_`date`
mv /usr/lib/systemd/system/nagios.service /groots/metrics/config/sbin/
}


update_directory_permission () {

echo "#######################################################" | log
echo "Verifying if "/groots/metrics/config/var/rw/" is present or not.." | log 
ls -ld /groots/metrics/config/var/rw/ 2>/dev/null  || { echo "Directory is not present "/groots/metrics/config/var/rw/"" | log ; exit; }
echo "#######################################################" | log
echo "Updating directory for "/groots/metrics/config/var/rw/" " | log
chown groots:nagcmd /groots/metrics/config/var/rw/
chmod g+rwx /groots/metrics/config/var/rw/
chmod g+s /groots/metrics/config/var/rw/
chown -hR groots:nagcmd /groots/metrics/config/var/rw/
echo "#######################################################" | log
echo "Checking permission and ownership for /groots/metrics/config/var/rw/ " | log 
ll /groots/metrics/config/var/rw/ | log 

}


download_nrpe_source () {

    echo "#######################################################" | log
    echo "Downloading nrpe source under "$DESTPATH" " | log
    wget $NRPESOURCEFILE -P $DESTPATH
    echo "#######################################################" | log
    echo "Extracting the tar "nrpe-4.0.3.tar.gz"" | log
    FILEUNTAR=`tar -tvf "$DESTPATH"nrpe*tar.gz | head -n 1 | awk '{print $6}' | sed -e 's|/||g'`
    UNTARPATH=""$DESTPATH""$FILEUNTAR""
    tar -xvf "$DESTPATH"nrpe*.tar.gz  -C $DESTPATH | log

    if [ ! -d $UNTARPATH ]; then
        echo "#######################################################" | log
        echo "Source tar is not extracted under $DESTPATH. Aborting.." | log
        exit 1;
    fi


    echo "#######################################################" | log
    echo "Taking backup of $UNTARPATH " | log
    cp -avr "$UNTARPATH" "$UNTARPATH"_original | log
    cp $UNTARPATH/sample-config/nrpe.cfg.in $UNTARPATH/sample-config/nrpe.cfg.in_original | log
    cp $UNTARPATH/src/nrpe.c $UNTARPATH/src/nrpe.c_original | log
    cp $UNTARPATH/src/check_nrpe.c $UNTARPATH/src/check_nrpe.c_original | log
    echo "Customisation in nrpe.cfg.in" | log
    sed -i 's/NRPE/GMETRICS/g' $UNTARPATH/sample-config/nrpe.cfg.in
    sed -i 's/check_nrpe/check_metrics/g' $UNTARPATH/sample-config/nrpe.cfg.in
    sed -i 's/#log_file=@logdir@\/nrpe.log/log_file=@logdir@\/gmetrics-agent.log/g' $UNTARPATH/sample-config/nrpe.cfg.in
    sed -i 's/debug=0/debug=1/g' $UNTARPATH/sample-config/nrpe.cfg.in
    sed -i 's/pid_file=@piddir@\/nrpe.pid/pid_file=@piddir@\/gmetrics-agent.pid/g' $UNTARPATH/sample-config/nrpe.cfg.in
    sed -i 's/command_timeout=60/command_timeout=6000/g' $UNTARPATH/sample-config/nrpe.cfg.in
    sed -i 's/connection_timeout=300/connection_timeout=6000/g' $UNTARPATH/sample-config/nrpe.cfg.in

}

gmetrics_customisation () {

    NRPEFILE=""$UNTARPATH"/src/nrpe.c"
    echo "#######################################################" | log
    echo "Updating gmetrics customisation changes in source file " | log
    sed -i '/* / s|nrpe.c - Nagios Remote Plugin Executor|gmetrics-agent.c - Gmetrics Agent Plugin Executor|g' $NRPEFILE;
    sed -i ' /*/ s|Copyright (c) 2009-2017 Nagios Enterprises| Copyright (c) 2018-2020 Groots Software|g' $NRPEFILE;
    sed -i '/^[[:blank:]]*sprintf/ {s/NRPE/GMETRICS/g;}' $NRPEFILE;
    sed -i '/^[[:blank:]]*snprintf/ {s/NRPE/GMETRICS/g;}' $NRPEFILE;
    sed -i '/^[[:blank:]]*printf/ {s/NRPE/GMETRICS/g;}' $NRPEFILE;
    sed -i '/^[[:blank:]]*openlog/ {s/nrpe/gmetrics-agent/g;}' $NRPEFILE;
    sed -i '/^[[:blank:]]*strncpy/ {s/NRPE/GMETRICS/g;}' $NRPEFILE;
    sed -i '/^[[:blank:]]*logit/ {s/NRPE/GMETRICS/g;}' $NRPEFILE;
    sed -i '/* / s/Nagios/Gmetrics core/g' $NRPEFILE;
    sed -i '/^[[:blank:]]*printf/ {s/check_nrpe/check_metrics/g;}' $NRPEFILE;
    sed -i '/^[[:blank:]]*printf/ {s/nrpe/gmetrics-agent/g;}' $NRPEFILE;
    sed -i '/* Command line/ s/nrpe/gmetrics-agent/g' $NRPEFILE;
    sed -i 's|Copyright (c) 2009-2017 Nagios Enterprises| Copyright (c) 2018-2020 Groots Software|g' $NRPEFILE;
    #sed -i ' /*/ s|Copyright (c) 2009-2017 Nagios Enterprises| Copyright (c) 2018-2020 Groots Software|g' $NRPEFILE;
    sed -i ' /*/ s|              1999-2008 Ethan Galstad (nagios@nagios.org)||g' $NRPEFILE;
    sed -i '/^\ *sprintf/ s|Copyright (c) 2009-2017 Nagios Enterprises\n| Copyright (c) 2018-2020 Groots Software\n|g' $NRPEFILE;
    sed -i '/^\ *sprintf/ s|              1999-2008 Ethan Galstad (nagios@nagios.org)\n|               2018-2020 Groots DevOps (support@groots.in) \n|g' $NRPEFILE;
    sed -i '/^[[:blank:]]*printf/ s|Copyright (c) 2009-2017 Nagios Enterprises\n| Copyright (c) 2018-2020 Groots Software\n|g' $NRPEFILE;
    sed -i '/^[[:blank:]]*printf/ s|1999-2008 Ethan Galstad (nagios@nagios.org)| 2018-2020 Groots DevOps (support@groots.in)|g' $NRPEFILE;
    sed -i 's|printf("NRPE - Nagios Agent Plugin Executor\n");|printf("GMETRICS - GMETRICS Agent Plugin Executor\n");|g' $NRPEFILE;
    sed -i '/^[[:blank:]]*printf/ {s/Nagios/Gmetrics Core/g;}' $NRPEFILE;
    echo "Completed gmetrics customisation.." | log
}

check_metrics_customization () {

    CHECK_NRPEFILE=""$UNTARPATH"/src/check_nrpe.c"
    echo "#######################################################" | log
    echo "Updating the check_metrics customisation in the source file" | log
    sed -i 's|* check_nrpe.c - NRPE Plugin For Nagios|* check_metrics.c - GMETRICS Plugin For GMETRICS CORE|g' $CHECK_NRPEFILE;
    sed -i 's|* This plugin will attempt to connect to the NRPE|*This plugin will attempt to connect to the GMETRICS|g' $CHECK_NRPEFILE;
    sed -i '/* / s/check_nrpe/check_metrics/g' $CHECK_NRPEFILE;
    sed -i 's|* check_nrpe.c - Nagios Remote Plugin Executor|* gmetrics-agent.c - Gmetrics Agent Plugin Executor|g' $CHECK_NRPEFILE;
    sed -i '/^[[:blank:]]*printf/ {s/CHECK_NRPE/CHECK_METRICS/g;}' $CHECK_NRPEFILE;
    sed -i '/^[[:blank:]]*printf/ {s/NRPE/GMETRICS/g;}' $CHECK_NRPEFILE;
    sed -i '/^[[:blank:]]*printf/ {s/check_nrpe/check_metrics/g;}' $CHECK_NRPEFILE;
    sed -i 's|Copyright (c) 2009-2017 Nagios Enterprises| Copyright (c) 2018-2020 Groots Software|g' $CHECK_NRPEFILE;
    sed -i ' /*/ s|              1999-2008 Ethan Galstad (nagios@nagios.org)||g' $CHECK_NRPEFILE;
    sed -i '/^[[:blank:]]*printf/ s|Copyright (c) 2009-2017 Nagios Enterprises\n| Copyright (c) 2018-2020 Groots Software\n|g' $CHECK_NRPEFILE;
    sed -i '/^[[:blank:]]*printf/ s|1999-2008 Ethan Galstad (nagios@nagios.org)| 2018-2020 Groots DevOps (support@groots.in)|g' $CHECK_NRPEFILE;
    sed -i '/^#define DEFAULT_NRPE_COMMAND/ {s/_NRPE_CHECK/_METRICS_CHECK/g;}' $CHECK_NRPEFILE;
    sed -i "/^[[:blank:]]*const char/ {s/CHECK_NRPE STATE/CHECK_METRICS STATE/g;}" $CHECK_NRPEFILE;
    sed -i '/^[[:blank:]]*printf/ {s/Nagios/GMETRICS CORE/g;}' $CHECK_NRPEFILE;
    echo "Completed check_metrics customisation for gmetrics.." | log
}

headerfile_customisation () {

    echo "#######################################################" | log
    echo "Updating the header file " | log
    cp "$UNTARPATH"/include/nrpe.h "$UNTARPATH"/include/nrpe.h_original | log
    cp "$UNTARPATH"/include/common.h.in "$UNTARPATH"/include/common.h.in_original | log
    cp "$UNTARPATH"/include/config.h.in "$UNTARPATH"/include/config.h.in_original | log
	cp "$UNTARPATH"/src/Makefile.in /root/gmetricsdata/nrpe-4.0.3/src/Makefile.in_original | log 
	sed -i '/^#define NRPE_HELLO_COMMAND/ {s/_NRPE_CHECK/_METRICS_CHECK/g;}' "$UNTARPATH"/include/common.h.in;
}


source_compile () {

    echo "#######################################################" | log
    echo "Updating ownership for "/groots/metrics"" | log
    chown -R groots. /groots/metrics
    echo "#######################################################" | log
    echo "Starting compiling of source nrpe..." | log
    ls -ltrh /usr/lib/gcc/x86_64-redhat-linux/ > /dev/null || { echo >&2 "//usr/lib/gcc/x86_64-redhat-linux/ is not present. Aborting." | log ; exit 1; }
    cd "$UNTARPATH"
	sudo ./configure --prefix=/groots/metrics/config --exec-prefix=/groots/metrics/config --with-nrpe-user=groots --with-nrpe-group=groots --with-nagios-user=groots --with-nagios-group=groots --enable-command-args --with-ssl-lib=/usr/lib/x86_64-redhat-linux6E
}


compile_binary () {

    echo "#######################################################" | log
    echo "Preparing and installing binaries and nrpe daemon.." | log
    cd "$UNTARPATH"
    make
    make all
    make install-daemon
	make install-plugin
    echo "#######################################################" | log
    echo "Compile & binaries installation completed.." | log
}

test_nrpe_configuration () {

	echo "#######################################################" | log
	echo "Testing gmetrics configuration.." | log 
	if [ ` sh /groots/metrics/bin/configtest |grep -w "Total Errors" | awk '{print $4}'` = 0 ]; then 
	echo "#######################################################" | log
	echo "0 Errors in configtest" | log 
	else
	echo "#######################################################" | log
	echo "Errors found in configtest. Please check..!!"
	exit 3; 
	fi 

}


update_file_dir_permission () {

	echo "#######################################################" | log
	echo "Updating permission for files and directory" | log 
	chmod +x /groots/metrics/config/sbin/*
	chmod ug+x /groots/metrics/config/bin/*
	chmod ug+x /groots/metrics/config/libexec/*
	
}


nrpe_symbolic_link () {

	echo "#######################################################" | log
	echo "Creating symbolic link for check_metrics" | log 
	cp -av /groots/metrics/config/libexec/check_nrpe /groots/metrics/config/libexec/check_metrics | log 
	echo "#######################################################" | log
	echo "Restarting gmetrics-core service" | log 
	systemctl restart gmetrics-core
	echo "#######################################################" | log
	echo "Checking gmetrics-core service status " | log 
	systemctl status gmetrics-core | log 
}

# Calling function
#######################################################

server_os_details


if [ "$OSNAME" = "CentOS" ] && [ "$OS_VERSION" = "7" ]; then

  download_nagios_source
  customisation_nagios
  customisation_nagiostat
  customisation_events
  customisation_cgi
  customisation_httpd
  customisation_nagios_cfg
  configure_binary
  set_groots_permission
  confirm_nagios_config
  update_configuration_file
  update_object_file
  set_user_password
  update_binary_nagios
  update_configtest
  Update_gmetrics_core_servicefile
  update_directory_permission
  download_nrpe_source
  gmetrics_customisation
  check_metrics_customization
  headerfile_customisation
  source_compile
  compile_binary
  test_nrpe_configuration
  update_file_dir_permission
  nrpe_symbolic_link

fi
