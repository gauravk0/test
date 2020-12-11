#!/bin/bash
#######################################################
# Program: Gmetrics Agent build.
#
# Purpose:
#  This script gmetrics agent build for Centos & Ubuntu,
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

# Global path declaration 
#######################################################

SOURCETARPATH="/root/gmetricsdata/nrpe-4.0.3"
TARPATH="/root/gmetricsdata/nrpe-nrpe-4.0.3"
TARFILE="https://github.com/NagiosEnterprises/nrpe/archive/nrpe-4.0.3.tar.gz"
PLUGINTARFILE="https://nagios-plugins.org/download/nagios-plugins-2.3.3.tar.gz"
PLUGINTARPATH="/root/gmetricsdata/nagios-plugins-2.3.3"
DESTPATH="/root/gmetricsdata/"

package_install_ubuntu () {

    echo "#######################################################" | log
    echo "Installing pre-prerequisites packages.." | log
    sudo apt update 
    sudo apt-file update 
    sudo apt install autoconf gcc make unzip libgd-dev libmcrypt-dev libssl-dev dc snmp libnet-snmp-perl gettext sysstat openssl perl vim dos2unix mlocate rpm git apt-file -y 
}

package_install_centos7 () {

    echo "#######################################################" | log
    echo "Installing pre-prerequisites packages for centos7.." | log
    yum update -y
    yum install -y epel-release sysstat openssl openssl-devel perl wget gcc glibc glibc-common gd gd-devel make net-snmp bind-utils net-snmp-devel net-snmp-utils net-snmp-perl net-tools vim dos2unix mlocate
    yum groupinstall "Development Tools" -y --setopt=group_package_types=mandatory,default,optional
}

package_install_centos8 () {

    echo "#######################################################" | log
    echo "Installing pre-prerequisites packages for centos8.."
    yum update -y 
    dnf install libnsl
    yum install -y gcc glibc glibc-common make gettext automake autoconf wget openssl-devel net-snmp net-snmp-utils epel-release
    yum --enablerepo=PowerTools,epel install perl-Net-SNMP -y
    yum install compat-openssl10 libnsl.so.1 -y
    yum install https://download-ib01.fedoraproject.org/pub/epel/8/Everything/x86_64/Packages/t/tcp_wrappers-libs-7.6-96.el8.x86_64.rpm -y
    
}

download_nrpe_source () {

    echo "#######################################################" | log
    echo "Creating temp directory" | log
    mkdir -p $DESTPATH | log
    echo "#######################################################" | log
    echo "Downloading nrpe source under "$DESTPATH" " | log
    wget $TARFILE -P $DESTPATH
    echo "#######################################################" | log
    echo "Extracting the tar "nrpe-4.0.3.tar.gz"" | log
    tar -xvf "$SOURCETARPATH".tar.gz -C $DESTPATH | log

    if [ ! -d $DESTPATH/nrpe-nrpe-4.0.3 ]; then
        echo "#######################################################" | log
        echo "Source tar is not extracted under $DESTPATH. Aborting.." | log
        exit 1;
    fi


    echo "#######################################################" | log
    echo "Taking backup of $TARPATH " | log
    cp -avr "$TARPATH" "$TARPATH"_original | log
    cp $TARPATH/sample-config/nrpe.cfg.in $TARPATH/sample-config/nrpe.cfg.in_original | log
    cp $TARPATH/src/nrpe.c $TARPATH/src/nrpe.c_original | log
    cp $TARPATH/src/check_nrpe.c $TARPATH/src/check_nrpe.c_original | log
    echo "Customisation in nrpe.cfg.in" | log
    sed -i 's/NRPE/GMETRICS/g' $TARPATH/sample-config/nrpe.cfg.in
    sed -i 's/check_nrpe/check_metrics/g' $TARPATH/sample-config/nrpe.cfg.in
    sed -i 's/#log_file=@logdir@\/nrpe.log/log_file=@logdir@\/gmetrics-agent.log/g' $TARPATH/sample-config/nrpe.cfg.in
    sed -i 's/debug=0/debug=1/g' $TARPATH/sample-config/nrpe.cfg.in
    sed -i 's/pid_file=@piddir@\/nrpe.pid/pid_file=@piddir@\/gmetrics-agent.pid/g' $TARPATH/sample-config/nrpe.cfg.in
    sed -i 's/command_timeout=60/command_timeout=6000/g' $TARPATH/sample-config/nrpe.cfg.in
    sed -i 's/connection_timeout=300/connection_timeout=6000/g' $TARPATH/sample-config/nrpe.cfg.in

}

gmetrics_customisation () {

    NRPEFILE="$DESTPATHnrpe-nrpe-4.0.3/src/nrpe.c"
    echo "#######################################################" | log
    echo "Updating gmetrics customisation changes in source file " | log
    sed -i '/* / s|nrpe.c - Nagios Remote Plugin Executor|gmetrics-agent.c - Gmetrics Agent Plugin Executor|g' $NRPEFILE;
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

    CHECK_NRPEFILE="$DESTPATHnrpe-nrpe-4.0.3/src/check_nrpe.c"
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
    cp "$TARPATH"/include/nrpe.h $TARPATH/include/nrpe.h_original | log
    cp "$TARPATH"/include/common.h.in "$TARPATH"/include/common.h.in_original | log
    cp "$TARPATH"/include/config.h.in "$TARPATH"/include/config.h.in_original | log
    sed -i '/^#define NRPE_HELLO_COMMAND/ {s/_NRPE_CHECK/_METRICS_CHECK/g;}' "$TARPATH"/include/common.h.in;
}


source_compile_ubuntu () {

    echo "#######################################################" | log
    echo "Adding groots user" | log
    useradd groots
    echo "#######################################################" | log
    echo "Creating a "/groots/metrics/"  and  "/var/log/groots/metrics/" directory" | log
    mkdir -p /groots/metrics/
    mkdir -p /var/log/groots/metrics/
    echo "#######################################################" | log
    echo "Updating ownership for "/groots/metrics"" | log
    chown -R groots. /groots/metrics
    echo "#######################################################" | log
    echo "Starting compiling of source nrpe..." | log
    ls -ltrh /usr/lib/x86_64-linux-gnu/ > /dev/null || { echo >&2 "/usr/lib/x86_64-linux-gnu/ is not present. Aborting." | log ; exit 1; }
    cd "$TARPATH"
    sudo ./configure --prefix=/groots/metrics/ --exec-prefix=/groots/metrics/ --with-nrpe-user=groots --with-nrpe-group=groots --with-nagios-user=groots --with-nagios-group=groots --enable-command-args --with-ssl-lib=/usr/lib/x86_64-linux-gnu/ --with-logdir=/var/log/groots/metrics/

}

source_compile_centos7 () {

    echo "#######################################################" | log
    echo "Adding groots user" | log
    useradd groots
    echo "#######################################################" | log
    echo "Creating a "/groots/metrics/"  and  "/var/log/groots/metrics/" directory" | log
    mkdir -p /groots/metrics/
    mkdir -p /var/log/groots/metrics/
    echo "#######################################################" | log
    echo "Updating ownership for "/groots/metrics"" | log
    chown -R groots. /groots/metrics
    echo "#######################################################" | log
    echo "Starting compiling of source nrpe..." | log
    ls -ltrh /usr/lib/gcc/x86_64-redhat-linux/ > /dev/null || { echo >&2 "//usr/lib/gcc/x86_64-redhat-linux/ is not present. Aborting." | log ; exit 1; }
    cd "$TARPATH"
    sudo ./configure --prefix=/groots/metrics/ --exec-prefix=/groots/metrics/ --with-nrpe-user=groots --with-nrpe-group=groots --with-nagios-user=groots --with-nagios-group=groots --enable-command-args --with-ssl-lib=/usr/lib/gcc/x86_64-redhat-linux/ --with-logdir=/var/log/groots/metrics/

}

source_compile_centos8 () {

    echo "#######################################################" | log
    echo "Adding groots user" | log
    useradd groots
    echo "#######################################################" | log
    echo "Creating a "/groots/metrics/"  and  "/var/log/groots/metrics/" directory" | log
    mkdir -p /groots/metrics/
    mkdir -p /var/log/groots/metrics/
    echo "#######################################################" | log
    echo "Updating ownership for "/groots/metrics"" | log
    chown -R groots. /groots/metrics
    echo "#######################################################" | log
    echo "Starting compiling of source nrpe..." | log
    ls -ltrh /usr/lib/gcc/x86_64-redhat-linux/8/ > /dev/null || { echo >&2 "/usr/lib/gcc/x86_64-redhat-linux/8/ is not present. Aborting." | log ; exit 1; }
    cd "$TARPATH"
    sudo ./configure --prefix=/groots/metrics/ --exec-prefix=/groots/metrics/ --with-nrpe-user=groots --with-nrpe-group=groots --with-nagios-user=groots --with-nagios-group=groots --enable-command-args --with-ssl-lib=/usr/lib/gcc/x86_64-redhat-linux/8/ --with-logdir=/var/log/groots/metrics/

}

compile_binary () {

    echo "#######################################################" | log
    echo "Preparing and installing binaries and nrpe daemon.." | log
    cd "$TARPATH"
    make
    make all
    make install-groups-users
    make install
    make install-daemon
    make install-config
    make install-inetd
    make install-init
    echo "#######################################################" | log
    echo "Compile & binaries installation completed.." | log
}


verify_install () {

    echo "#######################################################" | log
    echo "Creating a "/groots/metrics/config" directory for gmetrics-agent.cfg" | log
    mkdir /groots/metrics/config/
    touch /groots/metrics/config/gmetrics-agent.cfg
    echo "#######################################################" | log
    echo "Copying contents into gmetrics-agent.cfg" | log
    sudo cp -av /groots/metrics/etc/nrpe.cfg /groots/metrics/config/gmetrics-agent.cfg | log
    echo "#######################################################" | log
    echo "Enabling nrpe.service" | log
    systemctl enable nrpe.service
}

agent_service_port () {

    echo "#######################################################" | log
    echo "Taking backup for "/etc/services"" | log
    cp -ap /etc/services /etc/services_original | log
    echo "#######################################################" | log
    echo "Adding gmetrics-agent port in "/etc/services"" | log
    sudo sh -c "echo >> /etc/services" | log
    echo "gmetrics-agent 5666/tcp                # Gmetrics services" >> /etc/services | log
    tail /etc/services | log

}

agent_sudoers_entry () {

    echo "#######################################################" | log
    echo "Adding monitoring user in sudoers file to execute plugins" | log
    echo 'Defaults:groots    !requiretty' > /etc/sudoers.d/gmetrics-agent
    echo "groots          ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers.d/gmetrics-agent
    cat /etc/sudoers.d/gmetrics-agent | log

}

firewall_configuration_ubuntu () {

    echo "#######################################################" | log
    echo "Configuring Firewall for gmetrics-agent for ubuntu" | log
    sudo mkdir -p /etc/ufw/applications.d
    sudo sh -c "echo '[GMETRICS]' > /etc/ufw/applications.d/gmetrics-agent"
    sudo sh -c "echo 'title=Gmetrics Agent Plugin Executor' >> /etc/ufw/applications.d/gmetrics-agent"
    sudo sh -c "echo 'description=Allows agent execution of Gmetrics plugins' >> /etc/ufw/applications.d/gmetrics-agent"
    sudo sh -c "echo 'ports=5666/tcp' >> /etc/ufw/applications.d/gmetrics-agent"
    sudo ufw allow GMETRICS
    sudo ufw reload
    sudo cat /etc/ufw/applications.d/gmetrics-agent | log
}

firewalld_configuration_centos () {

    echo "#######################################################" | log
    echo "Configuring Firewall for gmetrics-agent for centos" | log
    echo "Adding gmetrics-agent port 5666.." | log 
    firewall-cmd --zone=public --add-port=5666/tcp
    firewall-cmd --zone=public --add-port=5666/tcp --permanent
    firewall-cmd --reload
    echo "#######################################################" | log
    echo "Listing port.."
    firewall-cmd --list-all | log 

}

agent_config () {

    echo "#######################################################" | log
    echo "Enabling nrpe.service.." | log
    systemctl enable nrpe.service
    sudo cp /groots/metrics/config/gmetrics-agent.cfg /groots/metrics/config/gmetrics-agent.cfg_original | log
    sudo sh -c "sed -i '/^allowed_hosts=/s/$/,3.7.198.168/' /groots/metrics/config/gmetrics-agent.cfg" | log
    sudo sh -c "sed -i 's/^dont_blame_nrpe=.*/dont_blame_nrpe=1/g' /groots/metrics/config/gmetrics-agent.cfg" | log
    systemctl start nrpe
    echo "#######################################################" | log
    echo "Starting nrpe and checking status for nrpe service" | log
    systemctl status nrpe | log
    echo "#######################################################" | log
    echo "Checking nrpe version with check_nrpe" | log
    /groots/metrics/libexec/check_nrpe -H localhost | log
    echo "#######################################################" | log
    echo "Updating ownership for "/groots/metrics".." | log
    chown -R groots:groots /groots/metrics | log
    echo "#######################################################" | log
    echo "Checking status nrpe.service" | log
    sudo systemctl status nrpe.service  | log
    sudo systemctl stop nrpe.service
    echo "#######################################################" | log
    echo "Stopping nrpe.service and Verifying status for nrpe.service" | log
    sudo systemctl status nrpe.service | log

}


agent_service_customisation_ubuntu () {

    echo "#######################################################" | log
    echo "Renaming check_nrpe command" | log
    cp /groots/metrics/libexec/check_nrpe /groots/metrics/libexec/check_metrics | log
    echo "#######################################################" | log
    echo "Update new file entry in main config file" | log
    echo 'include=/groots/metrics/config/gmetrics-agent.cfg' >> /groots/metrics/etc/gmetrics-config.cfg
    echo "#######################################################" | log
    echo "Rename gmetrics-binary file name " | log
    cp /groots/metrics/bin/nrpe /groots/metrics/bin/gmetrics-agent | log
    echo "#######################################################" | log
    echo "Rename gmetrics-agent service file" | log
    cp /lib/systemd/system/nrpe.service /lib/systemd/system/gmetrics-agent.service | log
    echo "
[Unit]
Description=Groots Agent Remote Plugin Executor
Documentation=https://www.groots.in/
After=var-run.mount nss-lookup.target network.target local-fs.target time-sync.target
Before=getty@tty1.service plymouth-quit.service xdm.service
Conflicts=nrpe.socket
[Install]
WantedBy=multi-user.target
[Service]
Type=simple
Restart=on-abort
PIDFile=/groots/metrics/var/gmetrics-agent.pid
RuntimeDirectory=groots
RuntimeDirectoryMode=0755
ExecStart=/groots/metrics/bin/gmetrics-agent -c /groots/metrics/etc/gmetrics-config.cfg -f
ExecReload=/bin/kill -HUP $MAINPID
ExecStopPost=/bin/rm -f /groots/metrics/gmetrics-agent.pid
TimeoutStopSec=60
User=groots
Group=groots
PrivateTmp=true
OOMScoreAdjust=-500" > /lib/systemd/system/gmetrics-agent.service
}

agent_service_customisation_centos () {

    echo "#######################################################" | log
    echo "Renaming check_nrpe command" | log
    cp /groots/metrics/libexec/check_nrpe /groots/metrics/libexec/check_metrics | log
    echo "#######################################################" | log
    echo "Update new file entry in main config file" | log
    echo 'include=/groots/metrics/config/gmetrics-agent.cfg' >> /groots/metrics/etc/gmetrics-config.cfg
    echo "#######################################################" | log
    echo "Rename gmetrics-binary file name " | log
    cp /groots/metrics/bin/nrpe /groots/metrics/bin/gmetrics-agent | log
    echo "#######################################################" | log
    echo "Rename gmetrics-agent service file" | log
    cp  /usr/lib/systemd/system/nrpe.service /usr/lib/systemd/system/gmetrics-agent.service
    echo "
[Unit]
Description=Groots Agent Remote Plugin Executor
Documentation=https://www.groots.in/
After=var-run.mount nss-lookup.target network.target local-fs.target time-sync.target
Before=getty@tty1.service plymouth-quit.service xdm.service
Conflicts=nrpe.socket
[Install]
WantedBy=multi-user.target
[Service]
Type=simple
Restart=on-abort
PIDFile=/groots/metrics/var/gmetrics-agent.pid
RuntimeDirectory=groots
RuntimeDirectoryMode=0755
ExecStart=/groots/metrics/bin/gmetrics-agent -c /groots/metrics/etc/gmetrics-config.cfg -f
ExecReload=/bin/kill -HUP $MAINPID
ExecStopPost=/bin/rm -f /groots/metrics/gmetrics-agent.pid
TimeoutStopSec=60
User=groots
Group=groots
PrivateTmp=true
OOMScoreAdjust=-500" > /usr/lib/systemd/system/gmetrics-agent.service
}

start_gmetrics_agent () {

    echo "#######################################################" | log
    echo "Stop existing nrpe service." | log
    systemctl stop nrpe
    echo "#######################################################" | log
    echo "Disabling nrpe service from system" | log
    systemctl disable nrpe | log
    mv /lib/systemd/system/nrpe.service /groots/metrics/var/
    echo "#######################################################" | log
    echo "Update gmetrics-agent log files ownership" | log
    chown -R groots. /var/log/groots/metrics/
    echo "#######################################################" | log
    echo "Reloading daemon to save changes and restart gmetrics-agent" | log
    systemctl daemon-reload
    echo "#######################################################" | log
    echo "Enabling and starting gmetrics-agent service.. " | log
    systemctl enable gmetrics-agent | log
    systemctl restart gmetrics-agent | log
    echo "#######################################################" | log
    echo "gmetrics-agent service status.."
    systemctl status gmetrics-agent | log
    echo "#######################################################" | log
    echo "Verify service status in log"
    tail  /var/log/groots/metrics/gmetrics-agent.log
    echo "#######################################################" | log
    echo "Verify gmetrics-agent config."
    /groots/metrics/libexec/check_metrics -H 127.0.0.1
}


append_gmetrics_agent_config () {

    echo "#######################################################" | log
    echo "Appending gmetrics-agent plugins configuration commands from template.cfg.." | log
    cat /root/gmetrics-build/config/template.cfg >> /groots/metrics/config/gmetrics-agent.cfg
#   cat /root/gmetrics-build/config/template.cfg > $DESTPATH/template.cfg
#   cat /root/gmetricsdata/template.cfg >> /groots/metrics/config/gmetrics-agent.cfg
    echo "Successfully updated "/groots/metrics/config/gmetrics-agent.cfg"" | log

}

download_plugin_source () {

    echo "#######################################################" | log
    echo "Downloading the Source https://nagios-plugins.org/download/" | log
    wget --no-check-certificate $PLUGINTARFILE -P $DESTPATH
    echo "#######################################################" | log
    echo "Extracting the plugins tar file" | log
    tar -xvf "$PLUGINTARPATH".tar.gz -C $DESTPATH | log

    if [ ! -d $DESTPATH/nagios-plugins-2.3.3 ]; then 
            echo "#######################################################" | log 
            echo "Plugin source tar is not properly untar in $DESTPATH. Aborting.." | log 
            exit 1;
    fi

    echo "#######################################################" | log
    echo "Taking backup of the source plugins tar file.." | log
    cp -arv "$PLUGINTARPATH" "$PLUGINTARPATH"_original | log
    sed -i 's/* Nagios/* Gmetrics Core/g' "$PLUGINTARPATH"/plugins/*.c | log
    sed -i 's/* Copyright (c) 2000-2018 Nagios Plugins Development Team/* Copyright (c) 2018-2020 Groots Development Team/g' "$PLUGINTARPATH"/plugins/*.c | log

}


compile_plugins () {

    echo "#######################################################" | log
    echo "Starting to compile gmetrics-agent plugins.." | log
    cd "$PLUGINTARPATH"
    sudo ./configure --prefix=/groots/metrics/ --exec-prefix=/groots/metrics/ --with-nagios-user=groots --with-nagios-group=groots
    sudo make
    sudo make install
    echo "#######################################################" | log
    echo "Plugins compiled successfully" | log
}

verify_gmetrics_ports () {

    echo "#######################################################" | log
    echo "Verifying gmetrics-agent listening ports.." | log
    netstat -plnt | egrep "5666" | log
}


update_permission () {

    echo "#######################################################" | log
    echo "Updating permission for /bin/ping" | log
    chmod u+s /bin/ping
    chmod u+s /bin/ping6
    echo "#######################################################" | log
    pkexec chmod 0440 /etc/sudoers
    echo "#######################################################" | log
    echo "Updating permission for installed plugins.." | log
    chown -R groots. /groots/metrics
    echo "Verifying permission for /groots/metrics/libexec/ " | log
    ls -ltrh /groots/metrics/libexec/ | log
    echo "#######################################################" | log
    echo "Restart services to apply installed plugins." | log
    systemctl restart gmetrics-agent

}


test_plugins () {

    echo "#######################################################" | log
    echo "Testing gmetrics plugins with check_metrics.."  | log
    echo "/groots/metrics/libexec/check_metrics -H localhost -c check_users" | log
    /groots/metrics/libexec/check_metrics -H localhost -c check_users -a '-w 5 -c 8' | log
    echo "/groots/metrics/libexec/check_metrics -H localhost -c check_load -a '-w 20,20,20 -c 30,30,30'" | log
    /groots/metrics/libexec/check_metrics -H localhost -c check_load -a '-w 20,20,20 -c 30,30,30' | log

}


add_logrotation () {

    echo "#######################################################" | log
    echo "Add gmetrics agent logrotate script." | log
    echo "
/var/log/groots/metrics/gmetrics-agent.log {
rotate 30
daily
missingok
notifempty
compress
dateext
dateformat -%Y-%m-%d
create
dateyesterday
}" > /etc/logrotate.d/gmetrics-agent
    echo "#######################################################" | log
    echo "Verifying logrotate entry" | log
    cat /etc/logrotate.d/gmetrics-agent  | log

}

disable_gmetrics_service () {

    echo "#######################################################" | log
    echo "Stop running gmetricsa-agent service on build server" | log
    sudo systemctl disable gmetrics-agent.service
    sudo systemctl stop gmetrics-agent.service
    echo "#######################################################" | log
    echo "Verifying disabled gmetrics-agent service" | log
    echo "#######################################################" | log
    echo "Service is stopped, Service should not be listening on any port..." | log
    netstat -plnt | egrep 5666 | log
    echo "#######################################################" | log
    echo > /var/log/groots/metrics/gmetrics-agent.log
}

create_build_ubuntu () {

    echo "#######################################################" | log
    echo "Generating gmetrics-agent build version for ubuntu.." | log
    Y=`date +'%Y'`
    D=`date +'%d'`
    M=`date +'%m'`
    tar -pczvf /root/gmetrics-agent-deb-V6.$D.$M.$Y.tar.gz /groots/metrics/ /lib/systemd/system/gmetrics-agent.service /etc/logrotate.d/gmetrics-agent /etc/sudoers.d/gmetrics-agent /var/log/groots/metrics/
    echo "Verifying the contents of gmetrics-agent build " | log
    tar -tvf /root/gmetrics-agent-deb-V6.$D.$M.$Y.tar.gz | log
    echo "#######################################################" | log
    echo "Generating mdsum for gmetrics build validation.." | log 
    md5sum /root/gmetrics-agent-deb-V6.$D.$M.$Y.tar.gz | log 
    echo "#######################################################" | log
    echo "Gmetrics build is successfully created.." | log
}

create_build_centos () {

    echo "#######################################################" | log
    echo "Generating gmetrics-agent build version for Centos.. " | log
    Y=`date +'%Y'`
    D=`date +'%d'`
    M=`date +'%m'`

    if [ "$OSNAME" = "CentOS" ] && [ "$OS_VERSION" = "7" ]; then
        tar -pczvf /root/gmetrics-agent-el7-V6.$D.$M.$Y.tar.gz /groots/metrics/ /lib/systemd/system/gmetrics-agent.service /etc/logrotate.d/gmetrics-agent /etc/sudoers.d/gmetrics-agent /var/log/groots/metrics/
        echo "Verifying the contents of gmetrics-agent build " | log
        tar -tvf /root/gmetrics-agent-el7-V6.$D.$M.$Y.tar.gz | log
        echo "#######################################################" | log
        echo "Generating mdsum for gmetrics build validation.." | log
        md5sum /root/gmetrics-agent-el7-V6.$D.$M.$Y.tar.gz | log
        echo "#######################################################" | log
        echo "Gmetrics -agent build for CentOS7 is successfully created.." | log
    
    elif [ "$OSNAME" = "CentOS" ] && [ "$OS_VERSION" = "8" ]; then
        tar -pczvf /root/gmetrics-agent-el8-V6.$D.$M.$Y.tar.gz /groots/metrics/ /lib/systemd/system/gmetrics-agent.service /etc/logrotate.d/gmetrics-agent /etc/sudoers.d/gmetrics-agent /var/log/groots/metrics/
        echo "Verifying the contents of gmetrics-agent build " | log
        tar -tvf /root/gmetrics-agent-el8-V6.$D.$M.$Y.tar.gz | log
        echo "#######################################################" | log
        echo "Generating mdsum for gmetrics build validation.." | log
        md5sum /root/gmetrics-agent-el8-V6.$D.$M.$Y.tar.gz | log
        echo "#######################################################" | log
        echo "Gmetrics-agent build for CentOS8 is successfully created.." | log
    fi

    
}

# server os details 
###################################################
server_os_details


if [ "$OSNAME" = "Ubuntu" ]; then

        echo "#######################################################" | log
        echo "Gmetrics Agent build creation starting at [`date`]." | log

        package_install_ubuntu
        download_nrpe_source
        gmetrics_customisation
        check_metrics_customization
        headerfile_customisation
        source_compile_ubuntu
        compile_binary
        verify_install
        agent_service_port
        agent_sudoers_entry
        firewall_configuration_ubuntu
        agent_config
        agent_service_customisation_ubuntu
        start_gmetrics_agent
        append_gmetrics_agent_config
        download_plugin_source
        compile_plugins
        verify_gmetrics_ports
        update_permission
        test_plugins
        add_logrotation
        disable_gmetrics_service
        create_build_ubuntu

elif [ "$OSNAME" = "CentOS" ] && [ "$OS_VERSION" = "7" ] || [ "$OS_VERSION" = "8" ]; then

        echo "#######################################################" | log
        echo "Gmetrics Agent build creation starting at [`date`]." | log

            if [ "$OSNAME" = "CentOS" ] && [ "$OS_VERSION" = "8" ]; then
                package_install_centos8
            elif [ "$OSNAME" = "CentOS" ] && [ "$OS_VERSION" = "7" ]; then
                package_install_centos7
            fi
 
        download_nrpe_source
        gmetrics_customisation
        check_metrics_customization
        headerfile_customisation

            if [ "$OSNAME" = "CentOS" ] && [ "$OS_VERSION" = "8" ]; then
                source_compile_centos8
            elif [ "$OSNAME" = "CentOS" ] && [ "$OS_VERSION" = "7" ]; then
                source_compile_centos7
            fi
        
        compile_binary
        verify_install
        agent_service_port
        agent_sudoers_entry
        firewalld_configuration_centos
        agent_config
        agent_service_customisation_centos
        start_gmetrics_agent
        append_gmetrics_agent_config
        download_plugin_source
        compile_plugins
        verify_gmetrics_ports
        update_permission
        test_plugins
        add_logrotation
        disable_gmetrics_service
        create_build_centos

fi

echo "#######################################################" | log
echo "Gmetrics Agent build creation completed at [`date`]." | log
