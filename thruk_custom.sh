#!bin/bash
#######################################################
# Program: Thruk gmetrics customisation
#
# Purpose:
#  This script customizes thruk for gmetrics
#  can be run in interactive.
#
# License:
#  This program is distributed in the hope that it will be useful,
#  but under groots software technologies @rights.
#
#######################################################

# Set script name
#######################################################
SCRIPTNAME=`basename $0`

# Logfile
#######################################################
LOGDIR=/var/log/groots/gmetrics/
LOGFILE=$LOGDIR/"$SCRIPTNAME".log
if [ ! -d $LOGDIR ]
then
        mkdir -p $LOGDIR
elif [ ! -f $LOGFILE ]
then
        touch $LOGFILE
fi

# Logger function
########################################################

log () {
while read line; do echo "[`date +"%Y-%m-%dT%H:%M:%S,%N" | rev | cut -c 7- | rev`][$SCRIPTNAME]: $line"| tee -a $LOGFILE 2>&1 ; done
}

download_thruk_package () {

        VERSION="2.38"
        DOWNLOADPATH="/root/gmetricsdata/"
        URLPATH="https://download.thruk.org/pkg/v$VERSION/rhel7/x86_64"
        echo "########################################################"
        echo "Creating $DOWNLOADPATH directory to download Thruk packages " | log
        ls -ltrh $DOWNLOADPATH 2>/dev/null || mkdir -p $DOWNLOADPATH
        echo "########################################################"
        echo "Downloading Thruk packages with $VERSION under $DOWNLOADPATH" | log
        wget $URLPATH/libthruk-"$VERSION"-0.rhel7.x86_64.rpm -P $DOWNLOADPATH | log
        wget $URLPATH/thruk-plugin-reporting-"$VERSION"-1.rhel7.x86_64.rpm -P $DOWNLOADPATH | log
        wget $URLPATH/thruk-base-"$VERSION"-1.rhel7.x86_64.rpm -P $DOWNLOADPATH | log
        wget $URLPATH/thruk-"$VERSION"-1.rhel7.x86_64.rpm  -P $DOWNLOADPATH | log
        ls -ltrh "$DOWNLOADPATH"*.rpm || { echo "Thruk packages are not downloaded under $DOWNLOADPATH" | log ; exit 1 ;}
        echo "########################################################"
        echo "Installating Thruk packages on server" | log
        yum install "$DOWNLOADPATH"*.rpm -y | log

}

file_etc_thruk_cgi_cfg () {

        THRUKCGIFILE="/etc/thruk/cgi.cfg"

        if [ ! -f "$THRUKCGIFILE"_original ]; then
                echo "########################################################"
            cp -av $THRUKCGIFILE "$THRUKCGIFILE"_original | log
        else
                echo "########################################################"
                cp -av $THRUKCGIFILE "$THRUKCGIFILE"_`date +"%Y-%m-%d-%H-%M-%S"` | log
        fi

        echo "########################################################" | log
        echo "customising /etc/thruk/cgi for gmetrics" | log
        echo "sed -i 's/default_user_name/#default_user_name/g'" | log
        sed -i 's/default_user_name/#default_user_name/g' $THRUKCGIFILE
        echo "sed -i 's/authorized_for_admin=thrukadmin/authorized_for_admin=manager,graph,gmetricsadmin@localhost,harish@groots.in,root@localhost,grootsadmin/g'" | log
        sed -i 's/authorized_for_admin=thrukadmin/authorized_for_admin=manager,graph,gmetricsadmin@localhost,harish@groots.in,root@localhost,grootsadmin/g' $THRUKCGIFILE
        echo "sed -i 's/refresh_rate=90/refresh_rate=30/g' " | log
        sed -i 's/refresh_rate=90/refresh_rate=30/g' $THRUKCGIFILE
}


file_etc_thruk_thruk_conf () {

        THRUKCONFFILE="/etc/thruk/thruk.conf"

        if [ ! -f "$THRUKCONFFILE"_original ]; then
                echo "########################################################"
            cp -av $THRUKCONFFILE "$THRUKCONFFILE"_original | log
        else
                echo "########################################################"
                cp -av $THRUKCONFFILE "$THRUKCONFFILE"_`date +"%Y-%m-%d-%H-%M-%S"` | log
        fi


        echo "########################################################" | log
        echo "Customising /etc/thruk/thruk.conf for gmetrics" | log
        echo "sed -i '/^[[:blank:]]*use_strict_host_authorization/ {s/0/1/g;}'" | log
        sed -i '/^[[:blank:]]*use_strict_host_authorization/ {s/0/1/g;}'  $THRUKCONFFILE
        echo "sed -i '/^[[:blank:]]*navframesize/ {s/172/195/g;}'" | log
        sed -i '/^[[:blank:]]*navframesize/ {s/172/195/g;}'  $THRUKCONFFILE
        echo "sed -i '/^[[:blank:]]*navframesize/ {s/172/195/g;}'" | log
        sed -i '/^[[:blank:]]*ssl_verify_hostnames/ {s/1/0/g;}'  $THRUKCONFFILE
        echo "sed -i '/ssl_ca_path/ s/^/# /'" | log
        sed -i '/ssl_ca_path/ s/^/# /' $THRUKCONFFILE
        echo "sed -i '/^[[:blank:]]*ssl_verify_hostnames/ {s/1/0/g;}'" | log
        sed -i '/^[[:blank:]]*ssl_verify_hostnames/ {s/1/0/g;}' $THRUKCONFFILE
        echo "sed -i 's/default_user_name/#default_user_name/g'" | log
        sed -i 's/default_user_name/#default_user_name/g' $THRUKCONFFILE
        echo "sed -i 's/#cookie_path/cookie_path/g'" | log
        sed -i 's/#cookie_path/cookie_path/g' $THRUKCONFFILE
        echo "sed -i 's/#mode_file/mode_file/g'" | log
        sed -i 's/#mode_file/mode_file/g' $THRUKCONFFILE
        echo "sed -i 's/#mode_dir/mode_dir/g'" | log
        sed -i 's/#mode_dir/mode_dir/g' $THRUKCONFFILE
        echo "sed -i '/^[[:blank:]]*thruk_user/ {s/apache/groots/g;}'" | log
        sed -i '/^[[:blank:]]*thruk_user/ {s/apache/groots/g;}' $THRUKCONFFILE
        echo "sed -i '/^[[:blank:]]*thruk_group/ {s/apache/groots/g;}'" | log
        sed -i '/^[[:blank:]]*thruk_group/ {s/apache/groots/g;}' $THRUKCONFFILE
        echo "sed -i '/^[[:blank:]]*info_popup_event_type/ {s/onclick/onmouseover/g;}'" | log
        sed -i '/^[[:blank:]]*info_popup_event_type/ {s/onclick/onmouseover/g;}' $THRUKCONFFILE
        echo "sed -i 's/#show_logout_button/show_logout_button/g'" | log
        sed -i 's/#show_logout_button/show_logout_button/g' $THRUKCONFFILE
        echo "sed -i '/^[[:blank:]]*show_logout_button/ {s/0/1/g;}'" | log
        sed -i '/^[[:blank:]]*show_logout_button/ {s/0/1/g;}' $THRUKCONFFILE
        echo "sed -i 's/#first_day_of_week/first_day_of_week/g'" | log
        sed -i 's/#first_day_of_week/first_day_of_week/g' $THRUKCONFFILE
        echo "sed -i 's/# report_max_objects/report_max_objects/g'" | log
        sed -i 's/# report_max_objects/report_max_objects/g' $THRUKCONFFILE
        echo "sed -i '/^[[:blank:]]*report_max_objects/ {s/1000/2000/g;}'" | log
        sed -i '/^[[:blank:]]*report_max_objects/ {s/1000/2000/g;}' $THRUKCONFFILE
        echo "sed -i 's/#bug_email_rcpt/bug_email_rcpt/g'" | log
        sed -i 's/#bug_email_rcpt/bug_email_rcpt/g' $THRUKCONFFILE
        echo "sed -i '/^[[:blank:]]*bug_email_rcpt/ {s/bugs@thruk.org/support@groots.in/g;}' " | log
        sed -i '/^[[:blank:]]*bug_email_rcpt/ {s/bugs@thruk.org/support@groots.in/g;}' $THRUKCONFFILE
        echo "sed -i 's/#basic_auth_enabled/basic_auth_enabled/g'" | log
        sed -i 's/#basic_auth_enabled/basic_auth_enabled/g' $THRUKCONFFILE
        echo "sed -i '/^[[:blank:]]*basic_auth_enabled/ {s/1/0/g;}'" | log
        sed -i '/^[[:blank:]]*basic_auth_enabled/ {s/1/0/g;}' $THRUKCONFFILE
        echo "sed -i '/^[[:blank:]]*cookie_auth_session_timeout/ {s/604800/3600/g;}'" | log
        sed -i '/^[[:blank:]]*cookie_auth_session_timeout/ {s/604800/3600/g;}' $THRUKCONFFILE
        echo "sed -i '/^[[:blank:]]*cookie_auth_session_cache_timeout/ {s/30/0/g;}'" | log
        sed -i '/^[[:blank:]]*cookie_auth_session_cache_timeout/ {s/30/0/g;}' $THRUKCONFFILE
        echo "sed -i 's/#report_from_email/report_from_email/g'" | log
        sed -i 's/#report_from_email/report_from_email/g' $THRUKCONFFILE
        echo "'/^[[:blank:]]*report_from_email/ {s/User Name <example@mail.com>/Gmetrics_Notification <notification@groots.in>/g;}'" | log
        sed -i '/^[[:blank:]]*report_from_email/ {s/User Name <example@mail.com>/Gmetrics_Notification <notification@groots.in>/g;}' $THRUKCONFFILE
        echo "sed -i 's/#report_subject_prepend/report_subject_prepend/g'" | log
        sed -i 's/#report_subject_prepend/report_subject_prepend/g' $THRUKCONFFILE
        echo "sed -i '/^[[:blank:]]*report_subject_prepend/ {s/URGENT REPORT:/[Gmetrics]/g;}'"
        sed -i '/^[[:blank:]]*report_subject_prepend/ {s/URGENT REPORT:/[Gmetrics]/g;}' $THRUKCONFFILE

}


userpasswd_update_htpasswd () {

        if [ ! -f /etc/thruk/htpasswd_original ]; then
                echo "########################################################" | log
            cp -av /etc/thruk/htpasswd /etc/thruk/htpasswd_original | log
        else
                echo "########################################################"
                cp -av /etc/thruk/htpasswd /etc/thruk/htpasswd_`date +"%Y-%m-%d-%H-%M-%S"` | log
        fi

        echo "########################################################" | log
        echo "Update htpasswd in /etc/thruk/htpasswd for users" | log
        cat /root/gmetrics-build/gmetrics-dash/templates/passwd.txt > /etc/thruk/htpasswd
}


append_thruk_menu_conf () {

        THRUKMENUFILE="/usr/share/thruk/menu.conf"

        if [ ! -f "$THRUKMENUFILE"_original ]; then
                echo "########################################################" | log
            cp -av "$THRUKMENUFILE" "$THRUKMENUFILE"_original | log
        else
                echo "########################################################"
                cp -av "$THRUKMENUFILE" "$THRUKMENUFILE"_`date +"%Y-%m-%d-%H-%M-%S"` | log
        fi

        echo "########################################################" | log
        echo "Appending "/usr/share/thruk/menu.conf" " | log
        cat /root/gmetrics-build/gmetrics-dash/templates/menu.conf > $THRUKMENUFILE
}


update_thruk_cookie_auth () {

        THRUKCOOKIEAUTHFILE="/usr/share/thruk/thruk_cookie_auth.include"


        if [ ! -f "$THRUKCOOKIEAUTHFILE"_original ]; then
                echo "########################################################" | log
            cp -av "$THRUKCOOKIEAUTHFILE" "$THRUKCOOKIEAUTHFILE"_original | log
        else
                echo "########################################################"
                cp -av "$THRUKCOOKIEAUTHFILE" "$THRUKCOOKIEAUTHFILE"_`date +"%Y-%m-%d-%H-%M-%S"` | log
        fi

        echo "########################################################" | log
        echo "Updating changes in $THRUKCOOKIEAUTHFILE " | log
        echo "sed -i '5{s/^/#/}'  $THRUKCOOKIEAUTHFILE"
        sed -i '5{s/^/#/}'  $THRUKCOOKIEAUTHFILE
        echo "sed -i "6 i RewriteRule ^/$              /thruk/ [R=302,L]" $THRUKCOOKIEAUTHFILE"
        sed -i "6 i RewriteRule ^/$              /thruk/ [R=302,L]" $THRUKCOOKIEAUTHFILE
}

update_thruk_lib_thruk () {

        THRUKLIBFILE="/usr/share/thruk/lib/Thruk.pm"

        if [ ! -f "$THRUKLIBFILE"_original ]; then
                echo "########################################################" | log
                echo "Taking backup of $THRUKLIBFILE" | log
            cp -av "$THRUKLIBFILE" "$THRUKLIBFILE"_original | log
        else
                echo "########################################################"
                echo "Taking backup of $THRUKLIBFILE" | log
                cp -av "$THRUKLIBFILE" "$THRUKLIBFILE"_`date +"%Y-%m-%d-%H-%M-%S"` | log
        fi

        echo "sed -i "s/Thruk - Monitoring Web Interface/Groots - Monitoring Web Interface/g"" | log
        sed -i "s/Thruk - Monitoring Web Interface/Groots - Monitoring Web Interface/g" $THRUKLIBFILE
        echo "sed -i "s/Monitoring web interface for Naemon, Nagios, Icinga and Shinken/Monitoring web interface for Groots/g"" | log
        sed -i "s/Monitoring web interface for Naemon, Nagios, Icinga and Shinken/Monitoring web interface for Groots/g"  $THRUKLIBFILE
        echo "sed -i "s/Sven Nierlein, 2009-present, <sven@nierlein.org>/Groots Software Technologies, <support@groots.in>/g"" | log
        sed -i "s/Sven Nierlein, 2009-present, <sven@nierlein.org>/Groots Software Technologies, <support@groots.in>/g" $THRUKLIBFILE
        echo "sed -i "s/Thruk is Copyright (c) 2009-2019 by Sven Nierlein and others/Groots Software Technologies, <support@groots.in>/g"" | log
        sed -i -e '/This is free software; you can redistribute it/,+3d' $THRUKLIBFILE
        sed -i "s/Thruk is Copyright (c) 2009-2019 by Sven Nierlein and others/Groots Software Technologies, <support@groots.in>/g" $THRUKLIBFILE


}

file_thruk_lib_controller_root () {

        THRUKLIBCONTROLLER="/usr/share/thruk/lib/Thruk/Controller/Root.pm"

        if [ ! -f "$THRUKLIBCONTROLLER"_original ]; then
                echo "########################################################" | log
                echo "Taking backup of $THRUKLIBCONTROLLER" | log
            cp -av "$THRUKLIBCONTROLLER" "$THRUKLIBCONTROLLER"_original | log
        else
                echo "########################################################"
                echo "Taking backup of $THRUKLIBCONTROLLER" | log
                cp -av "$THRUKLIBCONTROLLER" "$THRUKLIBCONTROLLER"_`date +"%Y-%m-%d-%H-%M-%S"` | log
        fi

        echo "sed -i "s/Thruk Monitoring Webinterface/Groots Monitoring Webinterface/g"" | log
        sed -i "s/Thruk Monitoring Webinterface/Groots Monitoring Webinterface/g"  $THRUKLIBCONTROLLER
        echo "sed -i "s/Thruk::Controller::Root - Root Controller for Thruk/Thruk::Controller::Root - Root Controller for Groots/g"" | log
        sed -i "s/Thruk::Controller::Root - Root Controller for Thruk/Thruk::Controller::Root - Root Controller for Groots/g"   $THRUKLIBCONTROLLER

}


file_thruk_lib_controller_error () {

        THRUKLIBCONTROLLERERROR="/usr/share/thruk/lib/Thruk/Controller/error.pm"

        if [ ! -f "$THRUKLIBCONTROLLERERROR"_original ]; then
                echo "########################################################" | log
                echo "Taking backup of $THRUKLIBCONTROLLERERROR" | log
            cp -av "$THRUKLIBCONTROLLERERROR" "$THRUKLIBCONTROLLERERROR"_original | log
        else
                echo "########################################################"
                echo "Taking backup of $THRUKLIBCONTROLLERERROR" | log
                cp -av "$THRUKLIBCONTROLLERERROR" "$THRUKLIBCONTROLLERERROR"_`date +"%Y-%m-%d-%H-%M-%S"` | log
        fi

        echo "sed -i "s/Thruk::Controller::error - Thruk Controller/Thruk::Controller::error - Groots Controller/g"" | log
        sed -i "s/Thruk::Controller::error - Thruk Controller/Thruk::Controller::error - Groots Controller/g" $THRUKLIBCONTROLLERERROR
        echo "sed -i "s/Thruk Controller/Groots Controller/g"" | log
        sed -i "s/Thruk Controller/Groots Controller/g" $THRUKLIBCONTROLLERERROR
        echo "sed -i "s/If you believe this is an error.*/'You are not authorized person to view this page.<br> You are not a superuser to view this configuration.',/g"" | log
        sed -i "s/If you believe this is an error.*/'You are not authorized person to view this page.<br> You are not a superuser to view this configuration.',/g"  $THRUKLIBCONTROLLERERROR
        sed -i '/please specify at least one backend in your.*/ {s/thruk_local.conf/groots_local.conf/g;}' $THRUKLIBCONTROLLERERROR
        echo "sed -i '/please specify at least one backend in your.*/ {s|www.thruk.org/documentation/install.html|www.groots.in|g;}'" | log
        sed -i '/please specify at least one backend in your.*/ {s|www.thruk.org/documentation/install.html|www.groots.in|g;}' $THRUKLIBCONTROLLERERROR

}



# Function calling
#######################################################

download_thruk_package
file_etc_thruk_cgi_cfg
userpasswd_update_htpasswd
file_etc_thruk_thruk_conf
update_thruk_cookie_auth
update_thruk_lib_thruk
file_thruk_lib_controller_root
file_thruk_lib_controller_error
