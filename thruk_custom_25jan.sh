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

	VERSION="2.40-2"
	DOWNLOADPATH="/root/gmetricsdata/ThrukCustom/"
	echo "########################################################"
	ls -ltrh $DOWNLOADPATH >/dev/null || mkdir -p $DOWNLOADPATH
	echo "Downloading Thruk packages with $VERSION under $DOWNLOADPATH" | log
	wget --recursive -np -nd  --reject="index.html*" https://download.thruk.org/pkg/v"$VERSION"/rhel7/x86_64/ -P $DOWNLOADPATH
	echo "########################################################"
	echo "Creating $DOWNLOADPATH directory to download Thruk packages " | log
	ls -ltrh "$DOWNLOADPATH"*.rpm || { echo "Thruk packages are not downloaded under $DOWNLOADPATH" | log ; exit 1 ;}
	echo "########################################################" | log 
	echo "Installating Thruk packages on server" | log
	yum install "$DOWNLOADPATH"*.rpm -y | log

}

backup_files () {

echo  "########################################################" | log 
echo "Starting backup for Thruk packages files " | log 

LIST=("
/etc/thruk/cgi.cfg
/etc/thruk/htpasswd
/etc/thruk/log4perl.conf
/etc/thruk/thruk.conf
/usr/share/thruk/menu.conf
/usr/share/thruk/thruk_cookie_auth.include
/usr/share/thruk/lib/Thruk.pm
/usr/share/thruk/lib/Thruk/Config.pm
/usr/share/thruk/lib/Thruk/UserAgent.pm
/usr/share/thruk/lib/Thruk/Controller/Root.pm
/usr/share/thruk/lib/Thruk/Controller/error.pm
/usr/share/thruk/lib/Thruk/Controller/extinfo.pm
/usr/share/thruk/lib/Thruk/Controller/graphs.pm
/usr/share/thruk/lib/Thruk/Controller/login.pm
/usr/share/thruk/lib/Thruk/Controller/status.pm
/usr/share/thruk/lib/Thruk/Utils/CLI.pm
/usr/share/thruk/lib/Thruk/Utils/LMD.pm
/usr/share/thruk/lib/Thruk/Utils/SelfCheck.pm
/usr/share/thruk/lib/Thruk/Utils/CLI/Cron.pm
/usr/share/thruk/plugins/plugins-available/business_process/templates/bp.tt
/usr/share/thruk/plugins/plugins-available/conf/lib/Monitoring/Config.pm
/usr/share/thruk/plugins/plugins-available/conf/lib/Thruk/Controller/conf.pm
/usr/share/thruk/plugins/plugins-available/conf/root/conf.css
/usr/share/thruk/plugins/plugins-available/conf/templates/_conf_frame.tt
/usr/share/thruk/plugins/plugins-available/conf/templates/conf.tt
/usr/share/thruk/plugins/plugins-available/conf/templates/conf_backends.tt
/usr/share/thruk/plugins/plugins-available/conf/templates/conf_data.tt
/usr/share/thruk/plugins/plugins-available/conf/templates/conf_plugins.tt
/usr/share/thruk/plugins/plugins-available/core_scheduling/root/core_scheduling.css
/usr/share/thruk/plugins/plugins-available/mobile/t/controller_mobile.t
/usr/share/thruk/plugins/plugins-available/mobile/t/templates_mobile.t
/usr/share/thruk/plugins/plugins-available/mobile/templates/mobile.tt
/usr/share/thruk/plugins/plugins-available/mobile/templates/mobile_home.tt
/usr/share/thruk/plugins/plugins-available/panorama/0.tab
/usr/share/thruk/plugins/plugins-available/panorama/lib/Thruk/Controller/panorama.pm
/usr/share/thruk/plugins/plugins-available/panorama/root/js/panorama_js_functions.js
/usr/share/thruk/plugins/plugins-available/panorama/root/js/panorama_js_panlet_icon_widget_label.js
/usr/share/thruk/plugins/plugins-available/panorama/root/js/panorama_js_settings_tab.js
/usr/share/thruk/plugins/plugins-available/panorama/root/js/panorama_js_tabbar.js
/usr/share/thruk/plugins/plugins-available/panorama/t/controller_panorama.t
/usr/share/thruk/plugins/plugins-available/reports2/root/reports.css
/usr/share/thruk/plugins/plugins-available/reports2/templates/reports.tt
/usr/share/thruk/plugins/plugins-available/reports2/templates/reports_edit.tt
/usr/share/thruk/root/index.html
/usr/share/thruk/root/thruk/startup.html
/usr/share/thruk/root/thruk/cache/Thruk2-$VERSION.css
/usr/share/thruk/root/thruk/cache/thruk-$VERSION.js
/usr/share/thruk/root/thruk/cache/thruk-panorama-$VERSION.js
/usr/share/thruk/templates/_add_bookmark.tt
/usr/share/thruk/templates/_common_js_bugs.tt
/usr/share/thruk/templates/_disclaimer.tt
/usr/share/thruk/templates/_excel_export.tt
/usr/share/thruk/templates/_footer.tt
/usr/share/thruk/templates/_grafana_graph.tt
/usr/share/thruk/templates/_header.tt
/usr/share/thruk/templates/_header_prefs.tt
/usr/share/thruk/templates/_infobox.tt
/usr/share/thruk/templates/_logs.tt
/usr/share/thruk/templates/_status_detail_table.tt
/usr/share/thruk/templates/_status_filter.tt
/usr/share/thruk/templates/_status_hostdetail_table.tt
/usr/share/thruk/templates/avail_report_host.tt
/usr/share/thruk/templates/avail_report_hostgroup.tt
/usr/share/thruk/templates/changes.tt
/usr/share/thruk/templates/config_commands.tt
/usr/share/thruk/templates/docs.tt
/usr/share/thruk/templates/error.tt
/usr/share/thruk/templates/extinfo_type_0.tt
/usr/share/thruk/templates/extinfo_type_1.tt
/usr/share/thruk/templates/extinfo_type_2.tt
/usr/share/thruk/templates/extinfo_type_3.tt
/usr/share/thruk/templates/extinfo_type_6.tt
/usr/share/thruk/templates/index.tt
/usr/share/thruk/templates/login.tt
/usr/share/thruk/templates/main.tt
/usr/share/thruk/templates/side.tt
/usr/share/thruk/templates/status_detail.tt
/usr/share/thruk/templates/status_grid.tt
/usr/share/thruk/templates/status_overview.tt
/usr/share/thruk/templates/tac.tt
/usr/share/thruk/templates/user_profile.tt
/usr/share/thruk/templates/graph_frame.tt
/usr/share/thruk/templates/_blocks.tt
/usr/share/thruk/themes/themes-available/Thruk2/fonts
/usr/share/thruk/themes/themes-available/Thruk2/stylesheets
/usr/share/thruk/themes/themes-available/Thruk2/css/style.css
/usr/share/thruk/themes/themes-available/Thruk2/css/stylemaintt.css
/usr/share/thruk/themes/themes-available/Thruk2/css/stylesidett.css
/usr/share/thruk/themes/themes-available/Thruk2/images
/usr/share/thruk/root/thruk/images
")


	for file in ${LIST[@]}; do

		if [ ! -f "$file"_original ]; then
		echo "########################################################" | log
		echo "Taking backup of $file file " | log
		cp -av "$file" "$file"_original | log
		else
		echo "########################################################" | log 
		echo "Taking backup of $file file" | log
		cp -av "$file" "$file"_`date +"%Y-%m-%d-%H-%M-%S"` | log
		fi

	done 

}


file_etc_thruk_cgi_cfg () {

	THRUKCGIFILE="/etc/thruk/cgi.cfg"
	echo "########################################################" | log 
	echo "Changes in $THRUKCGIFILE file. Appending changes difference in log file. " | log
	echo "########################################################" | log 
	sed -i 's/default_user_name/#default_user_name/g' $THRUKCGIFILE
	sed -i 's/authorized_for_admin=thrukadmin/authorized_for_admin=manager,graph,gmetricsadmin@localhost,harish@groots.in,root@localhost,grootsadmin/g' $THRUKCGIFILE
	sed -i 's/refresh_rate=90/refresh_rate=30/g' $THRUKCGIFILE
	diff -i "$THRUKCGIFILE"_original $THRUKCGIFILE  | log

}


file_etc_thruk_thruk_conf () {

	THRUKCONFFILE="/etc/thruk/thruk.conf"
	echo "########################################################" | log
	echo "Changes in $THRUKCONFFILE file. Appending changes difference in log file." | log
	echo "########################################################" | log
	sed -i '/^[[:blank:]]*use_strict_host_authorization/ {s/0/1/g;}'  $THRUKCONFFILE
	sed -i '/^[[:blank:]]*navframesize/ {s/172/195/g;}'  $THRUKCONFFILE
	sed -i '/^[[:blank:]]*ssl_verify_hostnames/ {s/1/0/g;}'  $THRUKCONFFILE
	sed -i '/ssl_ca_path/ s/^/# /' $THRUKCONFFILE
	sed -i '/^[[:blank:]]*ssl_verify_hostnames/ {s/1/0/g;}' $THRUKCONFFILE
	sed -i 's/default_user_name/#default_user_name/g' $THRUKCONFFILE
	sed -i 's/#cookie_path/cookie_path/g' $THRUKCONFFILE
	sed -i 's/#mode_file/mode_file/g' $THRUKCONFFILE
	sed -i 's/#mode_dir/mode_dir/g' $THRUKCONFFILE
	sed -i '/^[[:blank:]]*thruk_user/ {s/apache/groots/g;}' $THRUKCONFFILE
	sed -i '/^[[:blank:]]*thruk_group/ {s/apache/groots/g;}' $THRUKCONFFILE
	sed -i '/^[[:blank:]]*info_popup_event_type/ {s/onclick/onmouseover/g;}' $THRUKCONFFILE
	sed -i 's/#show_logout_button/show_logout_button/g' $THRUKCONFFILE
	sed -i '/^[[:blank:]]*show_logout_button/ {s/0/1/g;}' $THRUKCONFFILE
	sed -i 's/#first_day_of_week/first_day_of_week/g' $THRUKCONFFILE
	sed -i 's/# report_max_objects/report_max_objects/g' $THRUKCONFFILE
	sed -i '/^[[:blank:]]*report_max_objects/ {s/1000/2000/g;}' $THRUKCONFFILE
	sed -i 's/#bug_email_rcpt/bug_email_rcpt/g' $THRUKCONFFILE
	sed -i '/^[[:blank:]]*bug_email_rcpt/ {s/bugs@thruk.org/support@groots.in/g;}' $THRUKCONFFILE
	sed -i 's/#basic_auth_enabled/basic_auth_enabled/g' $THRUKCONFFILE
	sed -i '/^[[:blank:]]*basic_auth_enabled/ {s/1/0/g;}' $THRUKCONFFILE
	sed -i '/^[[:blank:]]*cookie_auth_session_timeout/ {s/604800/3600/g;}' $THRUKCONFFILE
	sed -i '/^[[:blank:]]*cookie_auth_session_cache_timeout/ {s/30/0/g;}' $THRUKCONFFILE
	sed -i 's/#report_from_email/report_from_email/g' $THRUKCONFFILE
	sed -i '/^[[:blank:]]*report_from_email/ {s/User Name <example@mail.com>/Gmetrics_Notification <notification@groots.in>/g;}' $THRUKCONFFILE
	sed -i 's/#report_subject_prepend/report_subject_prepend/g' $THRUKCONFFILE
	sed -i '/^[[:blank:]]*report_subject_prepend/ {s/URGENT REPORT:/[Gmetrics]/g;}' $THRUKCONFFILE
	diff -i "$THRUKCONFFILE"_original $THRUKCONFFILE  | log
}


userpasswd_update_htpasswd () {

	echo "########################################################" | log
	echo "Update htpasswd in /etc/thruk/htpasswd for users" | log
	cat /root/gmetrics-build/gmetrics-dash/templates/passwd.txt > /etc/thruk/htpasswd
}


append_thruk_menu_conf () {

	THRUKMENUFILE="/usr/share/thruk/menu.conf"
	echo "########################################################" | log
	echo "Appending "/usr/share/thruk/menu.conf". Appending changes difference in log file. " | log
	cat /root/gmetrics-build/gmetrics-dash/templates/menu.conf > $THRUKMENUFILE
}


update_thruk_cookie_auth () {

	THRUKCOOKIEAUTHFILE="/usr/share/thruk/thruk_cookie_auth.include"
	echo "########################################################" | log
	echo "Changes in $THRUKCOOKIEAUTHFILE file. Appending changes difference in log file." | log
	echo "########################################################" | log
	sed -i '5{s/^/#/}'  $THRUKCOOKIEAUTHFILE
	sed -i "6 i RewriteRule ^/$              /thruk/ [R=302,L]" $THRUKCOOKIEAUTHFILE
	diff -i "$THRUKCOOKIEAUTHFILE"_original $THRUKCOOKIEAUTHFILE  | log
}

update_thruk_lib_thruk () {

	THRUKLIBFILE="/usr/share/thruk/lib/Thruk.pm"

	echo "########################################################" | log 
	echo "Changes in $THRUKLIBFILE file. Appending changes difference in log file. " | log 
	echo "########################################################" | log
	sed -i "s/Thruk - Monitoring Web Interface/Groots - Monitoring Web Interface/g" $THRUKLIBFILE
	sed -i "s/Monitoring web interface for Naemon, Nagios, Icinga and Shinken/Monitoring web interface for Groots/g"  $THRUKLIBFILE
	sed -i "s/Sven Nierlein, 2009-present, <sven@nierlein.org>/Groots Software Technologies, <support@groots.in>/g" $THRUKLIBFILE
	sed -i -e '/This is free software; you can redistribute it/,+3d' $THRUKLIBFILE
	sed -i "s/Thruk is Copyright (c) 2009-2019 by Sven Nierlein and others/Groots Software Technologies, <support@groots.in>/g" $THRUKLIBFILE
	diff -i "$THRUKLIBFILE"_original $THRUKLIBFILE  | log
}

file_thruk_lib_controller () {

	THRUKLIBCONTROLLER="/usr/share/thruk/lib/Thruk/Controller/Root.pm"
	echo "########################################################" | log 
	echo "Changes in $THRUKLIBCONTROLLER file. Appending changes difference in log file. " | log 
	echo "########################################################" | log
	sed -i "s/Thruk Monitoring Webinterface/Groots Monitoring Webinterface/g"  $THRUKLIBCONTROLLER
	sed -i "s/Thruk::Controller::Root - Root Controller for Thruk/Thruk::Controller::Root - Root Controller for Groots/g"   $THRUKLIBCONTROLLER
	diff -i "$THRUKLIBCONTROLLER"_original $THRUKLIBCONTROLLER  | log
	
	THRUKLIBCONTROLLERERROR="/usr/share/thruk/lib/Thruk/Controller/error.pm"
	echo "########################################################" | log 
	echo "Changes in $THRUKLIBCONTROLLERERROR file. Appending changes difference in log file. " | log
	echo "########################################################" | log
	sed -i "s/Thruk::Controller::error - Thruk Controller/Thruk::Controller::error - Groots Controller/g" $THRUKLIBCONTROLLERERROR
	sed -i "s/Thruk Controller/Groots Controller/g" $THRUKLIBCONTROLLERERROR
	sed -i "s/If you believe this is an error, check the HTTP server authentication requirements.*/'You are not authorized person to view this page.<br> You are not a superuser to view this configuration.',/g"  $THRUKLIBCONTROLLERERROR
	sed -i '/please specify at least one backend in your.*/ {s/thruk_local.conf/groots_local.conf/g;}' $THRUKLIBCONTROLLERERROR
	sed -i '/please specify at least one backend in your.*/ {s|www.thruk.org/documentation/install.html|www.groots.in|g;}' $THRUKLIBCONTROLLERERROR
	diff -i "$THRUKLIBCONTROLLERERROR"_original $THRUKLIBCONTROLLERERROR  | log
	
	THRUKLIBCONTROLLERGRAPH="/usr/share/thruk/lib/Thruk/Controller/graphs.pm"
	echo "########################################################" | log 
	echo "Customising and appending graphs.pm from templates to $THRUKLIBCONTROLLERGRAPH " | log
	cat /root/gmetrics-build/gmetrics-dash/templates/graphs.pm > $THRUKLIBCONTROLLERGRAPH
	
	
	THRUKLIBCONTROLLERLOGIN="/usr/share/thruk/lib/Thruk/Controller/login.pm"
	echo "########################################################" | log 
	echo "Changes in $THRUKLIBCONTROLLERLOGIN file. Appending changes difference in log file. " | log 
	echo "########################################################" | log
	sed -i "s/Thruk::Controller::login - Thruk Controller/Thruk::Controller::login - Groots Controller/g" $THRUKLIBCONTROLLERLOGIN
	sed -i "s/Thruk Controller/Groots Controller/g" $THRUKLIBCONTROLLERLOGIN 
	sed -i '/^[[:blank:]]*$c->cookie/ {s/thruk_test/_gs_sess/g;}' $THRUKLIBCONTROLLERLOGIN
	sed -i '/^[[:blank:]]*my $testcookie/ {s/thruk_test/_gs_sess/g;}' $THRUKLIBCONTROLLERLOGIN 
	diff -i "$THRUKLIBCONTROLLERLOGIN"_original $THRUKLIBCONTROLLERLOGIN  | log
}

file_thruk_lib_utils () {

	THRUKLIBUTILS="/usr/share/thruk/lib/Thruk/Utils/CLI.pm"
	echo "########################################################" | log 
	echo "Changes in $THRUKLIBUTILS file. Appending changes difference in log file. " | log 
	echo "########################################################" | log
	sed -i "s/Utilities Collection for CLI scripting with Thruk/Utilities Collection for CLI scripting with Groots/g"  $THRUKLIBUTILS
	sed -i "s/all connected backends in Thruk/all connected backends in Groots/g" $THRUKLIBUTILS
	sed -i "s/Changes will be stashed into Thruks internal object/Changes will be stashed into Groots internal object/g"  $THRUKLIBUTILS
	diff -i "$THRUKLIBUTILS"_original $THRUKLIBUTILS  | log
	
	THRUKLIBUTILSSELFCHECK="/usr/share/thruk/lib/Thruk/Utils/SelfCheck.pm"
	echo "########################################################" | log 
	echo "Changes in $THRUKLIBUTILSSELFCHECK file. Appending changes difference in log file. " | log 
	sed -i "s/Utilities Collection for Checking Thruks Integrity/Utilities Collection for Checking Groots Integrity/g" $THRUKLIBUTILSSELFCHECK
	diff -i "$THRUKLIBUTILSSELFCHECK"_original $THRUKLIBUTILSSELFCHECK  | log
	
	THRUKLIBUTILSCRON="/usr/share/thruk/lib/Thruk/Utils/CLI/Cron.pm"
	echo "########################################################" | log 
	echo "Changes in $THRUKLIBUTILSCRON file. Appending changes difference in log file. " | log 
	sed -i "s/Install thruks internal cronjobs/Install Groots internal cronjobs/g"  $THRUKLIBUTILSCRON
	diff -i "$THRUKLIBUTILSCRON"_original $THRUKLIBUTILSCRON  | log
}

file_thruk_plugins_available_bp () {

	PLUGINSAVAILABLEBP="/usr/share/thruk/plugins/plugins-available/business_process/templates/bp.tt"
	echo "########################################################" | log 
	echo "Changes in $PLUGINSAVAILABLEBP file. Appending changes difference in log file. " | log 
	echo "########################################################" | log
	sed -i '/^[[:blank:]]*<div style="text-align/ {s/margin-bottom: 3px/margin-bottom: 10px/g;}' $PLUGINSAVAILABLEBP
	diff -i "$PLUGINSAVAILABLEBP"_original $PLUGINSAVAILABLEBP  | log
	
}

file_thruk_plugins_available_conf () {

	PLUGINSAVAILABLECONF="/usr/share/thruk/plugins/plugins-available/conf/lib/Monitoring/Config.pm"
	echo "########################################################" | log 
	echo "Changes in $PLUGINSAVAILABLECONF file. Appending changes difference in log file. " | log 
	echo "########################################################" | log
	sed -i "s/Monitoring::Config - Thruks Object Database/Monitoring::Config - Groots Object Database/g" $PLUGINSAVAILABLECONF
	diff -i "$PLUGINSAVAILABLECONF"_original $PLUGINSAVAILABLECONF  | log

}

file_thruk_plugins_available_conf_pm () {

	PLUGINSAVAILABLECONFPM="/usr/share/thruk/plugins/plugins-available/conf/lib/Thruk/Controller/conf.pm"
	echo "########################################################" | log 
	echo "Changes in $PLUGINSAVAILABLECONFPM file. Appending changes difference in log file. " | log 
	echo "########################################################" | log
	sed -i "s/Thruk::Controller::conf - Thruk Controller/Thruk::Controller::conf - Groots Controller/g"  $PLUGINSAVAILABLECONFPM
	sed -i "s/Thruk Controller./Groots Controller./g" $PLUGINSAVAILABLECONFPM 
	sed -i "s/Thruk Configuration/Groots Configuration/g" $PLUGINSAVAILABLECONFPM
	sed -i "s/Thruk Addons/Groots Addons/g" $PLUGINSAVAILABLECONFPM
	sed -i "s/Thruk Backends Manager/Groots Backends Manager/g" $PLUGINSAVAILABLECONFPM
	diff -i "$PLUGINSAVAILABLECONFPM"_original $PLUGINSAVAILABLECONFPM  | log

}

file_thruk_plugins_available_conf_frame () {

	PLUGINSAVAILABLECONFFRAME="/usr/share/thruk/plugins/plugins-available/conf/templates/_conf_frame.tt"
	echo "########################################################" | log 
	echo "Changes in $PLUGINSAVAILABLECONFFRAME file. Appending changes difference in log file. " | log 
	echo "########################################################" | log
	sed -i 's|>Thruk<|>Groots<|g' /usr/share/thruk/plugins/plugins-available/conf/templates/_conf_frame.tt $PLUGINSAVAILABLECONFFRAME
	diff -i "$PLUGINSAVAILABLECONFFRAME"_original $PLUGINSAVAILABLECONFFRAME  | log

}

file_thruk_plugins_available_conf_templates () {

	PLUGINSAVAILABLECONFTEMP="/usr/share/thruk/plugins/plugins-available/conf/templates/conf.tt"
	echo "########################################################" | log 
	echo "Changes in $PLUGINSAVAILABLECONFTEMP file. Appending changes difference in log file. " | log 
	sed -i 's/Thruk Settings/Groots Settings/g' $PLUGINSAVAILABLECONFTEMP
	sed -i 's/Thruks settings/Groots settings/g' $PLUGINSAVAILABLECONFTEMP
	sed -i 's|Plugin Manager for Thruk Addons|Plugin Manager for Groots Addons|g' $PLUGINSAVAILABLECONFTEMP
	sed -i 's|thruk.org/documentation.html#_component_thruk_backend"|www.groots.in"|g' $PLUGINSAVAILABLECONFTEMP
	diff -i "$PLUGINSAVAILABLECONFTEMP"_original $PLUGINSAVAILABLECONFTEMP  | log
	
	PLUGINSAVAILABLECONFBACKEND="/usr/share/thruk/plugins/plugins-available/conf/templates/conf_backends.tt"
	echo "########################################################" | log 
	echo "Changes in $PLUGINSAVAILABLECONFBACKEND file. Appending changes difference in log file. " | log 
	sed -i 's|www.thruk.org/documentation.html|www.groots.in|g' $PLUGINSAVAILABLECONFBACKEND
	sed -i 's|style="width:120px"|style="width:145px"|g' $PLUGINSAVAILABLECONFBACKEND
	diff -i "$PLUGINSAVAILABLECONFBACKEND"_original $PLUGINSAVAILABLECONFBACKEND  | log
	
	PLUGINSAVAILABLECONFDATA="/usr/share/thruk/plugins/plugins-available/conf/templates/conf_data.tt"
	echo "########################################################" | log 
	echo "Changes in $PLUGINSAVAILABLECONFDATA file. Appending changes difference in log file. " | log
	sed -i 's|style="width:60px"|style="width:80px"|g' $PLUGINSAVAILABLECONFDATA
	diff -i "$PLUGINSAVAILABLECONFDATA"_original $PLUGINSAVAILABLECONFDATA  | log
	
	PLUGINSAVAILABLECONFPLUGINS="/usr/share/thruk/plugins/plugins-available/conf/templates/conf_plugins.tt"
	echo "########################################################" | log 
	echo "Changes in $PLUGINSAVAILABLECONFPLUGINS file. Appending changes difference in log file. " | log
	sed -i 's/restart Thruk after changing/restart Groots after changing/g' $PLUGINSAVAILABLECONFPLUGINS
	diff -i "$PLUGINSAVAILABLECONFPLUGINS"_original $PLUGINSAVAILABLECONFPLUGINS  | log
	
}
	
file_thruk_plugins_available_core_schedule () {

	PLUGINSAVAILABLECORESCHLD="/usr/share/thruk/plugins/plugins-available/core_scheduling/root/core_scheduling.css"
	echo "########################################################" | log 
	echo "Changes in $PLUGINSAVAILABLECORESCHLD file. Appending changes difference in log file. " | log
	sed -i "5 i   border-radius: 5px important;" $PLUGINSAVAILABLECORESCHLD
	sed -i 's|important|!important|g' $PLUGINSAVAILABLECORESCHLD
	diff -i "$PLUGINSAVAILABLECORESCHLD"_original $PLUGINSAVAILABLECORESCHLD  | log
	
}

file_thruk_plugins_available_mobile_t () {


	PLUGINSAVAILABLEMOBILET="/usr/share/thruk/plugins/plugins-available/mobile/t/controller_mobile.t"
	echo "########################################################" | log 
	echo "Changes in $PLUGINSAVAILABLEMOBILET file. Appending changes difference in log file. " | log
	sed -i 's|Mobile Thruk|Groots Mobile|g' $PLUGINSAVAILABLEMOBILET
	sed -i 's|ThrukMobile|GrootsMobile|g' $PLUGINSAVAILABLEMOBILET
	diff -i "$PLUGINSAVAILABLEMOBILET"_original $PLUGINSAVAILABLEMOBILET  | log
	
}


file_thruk_plugins_available_mobile_templates () {

	PLUGINSAVAILABLEMOBILETTEMP="/usr/share/thruk/plugins/plugins-available/mobile/t/controller_mobile.t"
	echo "########################################################" | log 
	echo "Changes in $PLUGINSAVAILABLEMOBILETTEMP file. Appending changes difference in log file. " | log
	sed -i 's|Mobile Thruk|Groots Mobile|g'  $PLUGINSAVAILABLEMOBILETTEMP
	diff -i "$PLUGINSAVAILABLEMOBILETTEMP"_original $PLUGINSAVAILABLEMOBILETTEMP  | log
	
	PLUGINSAVAILABLEMOBILETEMPTT="/usr/share/thruk/plugins/plugins-available/mobile/templates/mobile.tt"
	echo "########################################################" | log 
	echo "Changes in $PLUGINSAVAILABLEMOBILETEMPTT file. Appending changes difference in log file. " | log
	sed -i 's|Mobile Thruk|Groots Mobile|g'  $PLUGINSAVAILABLEMOBILETEMPTT
	diff -i "$PLUGINSAVAILABLEMOBILETEMPTT"_original $PLUGINSAVAILABLEMOBILETEMPTT  | log
	
	
	PLUGINSAVAILABLEMOBILETEMPHOME="/usr/share/thruk/plugins/plugins-available/mobile/templates/mobile_home.tt"
	echo "########################################################" | log 
	echo "Changes in $PLUGINSAVAILABLEMOBILETEMPHOME file. Appending changes difference in log file. " | log
	sed -i 's|Mobile Thruk|Groots Mobile|g' $PLUGINSAVAILABLEMOBILETEMPHOME
	diff -i "$PLUGINSAVAILABLEMOBILETEMPHOME"_original $PLUGINSAVAILABLEMOBILETEMPHOME  | log
	
}

file_thruk_plugins_available_panorama () {

	PLUGINSAVAILABLEPANORAMA="/usr/share/thruk/plugins/plugins-available/panorama/0.tab"
	echo "########################################################" | log 
	echo "Changes in $PLUGINSAVAILABLEPANORAMA file. Appending changes difference in log file. " | log
	sed -i 's|Thruk Panorama Dashboards|Groots Panorama Dashboards|g'  $PLUGINSAVAILABLEPANORAMA
	sed -i 's|user:   thrukadmin|user:   root@localhost|g' $PLUGINSAVAILABLEPANORAMA
	diff -i "$PLUGINSAVAILABLEPANORAMA"_original $PLUGINSAVAILABLEPANORAMA  | log
	
	PLUGINSAVAILABLEPANORAMALIBTHRUK="/usr/share/thruk/plugins/plugins-available/panorama/lib/Thruk/Controller/panorama.pm"
	echo "########################################################" | log 
	echo "Changes in $PLUGINSAVAILABLEPANORAMALIBTHRUK file. Appending changes difference in log file. " | log
	sed -i 's|Thruk::Controller::panorama - Thruk Controller|Thruk::Controller::panorama - Groots Controller|g' $PLUGINSAVAILABLEPANORAMALIBTHRUK
	sed -i "s/Thruk Controller./Groots Controller./g" $PLUGINSAVAILABLEPANORAMALIBTHRUK
	sed -i '/^[[:blank:]]*$c->stash->{title}/ {s/Thruk Panorama/Groots Panorama/g;}'  $PLUGINSAVAILABLEPANORAMALIBTHRUK
	sed -i 's|Thruk Panorama Dashboard Export|Groots Panorama Dashboard Export|g'  $PLUGINSAVAILABLEPANORAMALIBTHRUK
	diff -i "$PLUGINSAVAILABLEPANORAMALIBTHRUK"_original $PLUGINSAVAILABLEPANORAMALIBTHRUK  | log
	
	
}

file_thruk_plugins_available_panorama_root () {

	PLUGINSAVAILABLEPANORAMAROOT="/usr/share/thruk/plugins/plugins-available/panorama/root/js/panorama_js_functions.js"
	echo "########################################################" | log 
	echo "Changes in $PLUGINSAVAILABLEPANORAMAROOT file. Appending changes difference in log file. " | log
	sed -i 's|Thruk Panorama Dashboard<br><br>|Groots Panorama Dashboard<br><br>|g'  $PLUGINSAVAILABLEPANORAMAROOT
	sed -i 's|Copyright 2009-present Sven Nierlein, sven@consol.de<br>|Groots Software Technologies, support@groots.in<br>|g' $PLUGINSAVAILABLEPANORAMAROOT
	sed -i -e '/License: GPL v3<br>/,+1d' $PLUGINSAVAILABLEPANORAMAROOT
	diff -i "$PLUGINSAVAILABLEPANORAMAROOT"_original $PLUGINSAVAILABLEPANORAMAROOT  | log
	
	PLUGINSAVAILABLEPANORAMAWIDGET="/usr/share/thruk/plugins/plugins-available/panorama/root/js/panorama_js_panlet_icon_widget_label.js"
	echo "########################################################" | log 
	echo "Changes in $PLUGINSAVAILABLEPANORAMAWIDGET file. Appending changes difference in log file. " | log
	sed -i '/^[[:blank:]]*TP.lastAvailError/ {s/Thruk/Groots/g;}' $PLUGINSAVAILABLEPANORAMAWIDGET
	diff -i "$PLUGINSAVAILABLEPANORAMAWIDGET"_original $PLUGINSAVAILABLEPANORAMAWIDGET  | log
	
	PLUGINSAVAILABLEPANORAMASETTINGTAB="/usr/share/thruk/plugins/plugins-available/panorama/root/js/panorama_js_settings_tab.js"
	echo "########################################################" | log 
	echo "Changes in $PLUGINSAVAILABLEPANORAMASETTINGTAB file. Appending changes difference in log file. " | log
	sed -i '/^[[:blank:]]*var exportText/ {s/Thruk Panorama Dashboard Export/Groots Panorama Dashboard Export/g;}' $PLUGINSAVAILABLEPANORAMASETTINGTAB
	diff -i "$PLUGINSAVAILABLEPANORAMASETTINGTAB"_original $PLUGINSAVAILABLEPANORAMASETTINGTAB  | log
	
	PLUGINSAVAILABLEPANORAMAT="/usr/share/thruk/plugins/plugins-available/panorama/t/controller_panorama.t"
	echo "########################################################" | log 
	echo "Changes in $PLUGINSAVAILABLEPANORAMAT file. Appending changes difference in log file. " | log
	sed -i 's|Thruk Panorama Dashboard Export|Groots Panorama Dashboard Export|g' $PLUGINSAVAILABLEPANORAMAT
	diff -i "$PLUGINSAVAILABLEPANORAMAT"_original $PLUGINSAVAILABLEPANORAMAT  | log
	
}

file_thruk_plugins_available_reports () {

	PLUGINSAVAILABLEREPORTS="/usr/share/thruk/plugins/plugins-available/reports2/templates/reports.tt"
	echo "########################################################" | log 
	echo "Changes in $PLUGINSAVAILABLEREPORTS file. Appending changes difference in log file. " | log
	sed -i 's|www.thruk.org/faq.html#_phantomjs|www.groots.in|g' $PLUGINSAVAILABLEREPORTS
	sed -i 's|style="width: 160px|style="width: 161px|g' $PLUGINSAVAILABLEREPORTS
	sed -i 's|edit.png|rpedit.png|g' $PLUGINSAVAILABLEREPORTS
	sed -i "s|alt='View Report Preview' title='View Report Preview' width=16 height=16|alt='View Report Preview' title='View Report Preview' width=20 height=23|g" $PLUGINSAVAILABLEREPORTS
	sed -i "s|title='View Report' width=16 height=16|title='View Report' width=20 height=20 style=position: relative;top: -2px;|g" 
	sed -i 's|style=position: relative;top: -2px;|style="position: relative;top: -2px;"|g'
	sed -i "s|title='Send Report by Mail' width=16 height=16|title='Send Report by Mail' width=31 height=18 style=position: relative;top: -3px;|g"  $PLUGINSAVAILABLEREPORTS
	sed -i "s|style=position: relative;top: -3px;|style="position: relative;top: -3px;"|g" $PLUGINSAVAILABLEREPORTS
	sed -i "s|title='Download JSON raw data' width=16 height=16|title='Download JSON raw data' width=22 height=22 style=position: relative;top:1px;|g" $PLUGINSAVAILABLEREPORTS
	sed -i "s|style=position: relative;top:1px;|style="position: relative;top:1px;"|g"  $PLUGINSAVAILABLEREPORTS
	diff -i "$PLUGINSAVAILABLEREPORTS"_original $PLUGINSAVAILABLEREPORTS  | log
}

file_thruk_plugins_available_reports_edit () {

	PLUGINSAVAILABLEREPORTSEDIT="/usr/share/thruk/plugins/plugins-available/reports2/templates/reports_edit.tt"
	echo "########################################################" | log 
	echo "Changes in $PLUGINSAVAILABLEREPORTSEDIT file. Appending changes difference in log file. " | log
	sed -i 's|class="report_remove_button report_button" style="width: 90px|class="report_remove_button report_button" style="width: 99px|g' $PLUGINSAVAILABLEREPORTSEDIT
	sed -i 's|class="report_save_button report_button" style="width: 160px;|class="report_save_button report_button" style="width: 160px;position: relative;top: 10px;|g' $PLUGINSAVAILABLEREPORTSEDIT
	sed -i 's|class="report_clone_button report_button" style="width: 130px;|class="report_clone_button report_button" style="width: 144px;|g' $PLUGINSAVAILABLEREPORTSEDIT
	diff -i "$PLUGINSAVAILABLEREPORTSEDIT"_original $PLUGINSAVAILABLEREPORTSEDIT  | log
}


file_thruk_root () {
	
	THRUKROOT="/usr/share/thruk/root/index.html"
	echo "########################################################" | log 
	echo "Changes in $THRUKROOT file. Appending changes difference in log file. " | log
	sed -i 's|<title>Thruk - Monitoring Webinterface</title>|<title>Groots - Monitoring Webinterface</title>|g' $THRUKROOT
	diff -i "$THRUKROOT"_original $THRUKROOT  | log

	THRUKROOTSTARTUP="/usr/share/thruk/root/thruk/startup.html"
	echo "########################################################" | log 
	echo "Changes in $THRUKROOTSTARTUP file. Appending changes difference in log file. " | log
	sed -i 's|Thruk Monitoring Webinterface|Groots Monitoring Webinterface|g' $THRUKROOTSTARTUP
	sed -i 's|please have a look at the apache error log and the thruk error log.|please have a look at the apache error log and the Groots error log.|g' $THRUKROOTSTARTUP
	sed -i 's|Thruks FastCGI Daemon is warming up|Groots FastCGI Daemon is warming up|g'  $THRUKROOTSTARTUP
	sed -i 's|alt="Thruk" title="Thruk"|alt="Groots" title="Groots"|g'  $THRUKROOTSTARTUP
	sed -i -e '/Copyright (c) 2009-2015 Thruk Developer Team./,+2d' $THRUKROOTSTARTUP
	sed -i 's|Produced by Thruk (http://www.thruk.org).|Groots software technologies (https://www.groots.in).|g'  $THRUKROOTSTARTUP
	sed -i 's|www.thruk.org|www.groots.in|g' $THRUKROOTSTARTUP
	diff -i "$THRUKROOTSTARTUP"_original $THRUKROOTSTARTUP  | log


}



# Function calling
#######################################################

download_thruk_package
backup_files
file_etc_thruk_cgi_cfg
userpasswd_update_htpasswd
file_etc_thruk_thruk_conf
update_thruk_cookie_auth
update_thruk_lib_thruk
file_thruk_lib_controller
file_thruk_lib_utils
file_thruk_plugins_available_bp
file_thruk_plugins_available_conf
file_thruk_plugins_available_conf_pm
file_thruk_plugins_available_conf_frame
file_thruk_plugins_available_conf_templates
file_thruk_plugins_available_core_schedule
file_thruk_plugins_available_mobile_t
file_thruk_plugins_available_mobile_templates
file_thruk_plugins_available_panorama
file_thruk_plugins_available_panorama_root
file_thruk_plugins_available_reports
file_thruk_plugins_available_reports_edit
file_thruk_root
