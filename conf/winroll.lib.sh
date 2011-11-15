#!/bin/bash

###########################################################################
# Unattended drbl-winRoll installation
#
# License: GPL
# Author	: Ceasar Sun Chen-kai <ceasar@nchc.org.tw> , Steven steven@nchc.org.tw
# Purpose	: Solve windows hostname duplication problem for using clone tool to distribute  Win-OS in one local LAN. 
#
#
###########################################################################

WINROLL_CONF_ROOT="/drbl_winroll-config"
WINROLL_TMP="/var/log"
WINROLL_CONFIG="$WINROLL_CONF_ROOT/winroll.conf"
WINROLL_LOG="$WINROLL_TMP/winrollsrv.log"
TEMP="/var/log"
TMP="/var/log"

#_GID_Administrators='Administrators'
_GID_Administrators='root'

alias clear='echo -e -n "\E[2J"'

waiting_to_reboot(){
	while [ $(ls $WINROLL_TMP/winroll-*.lock | wc -l) -gt 0 ]
	do
		echo `date` "$SERVICE_NAME: waiting_to_unlock:" `ls $WINROLL_TMP/winroll-*.lock | wc -l`  | tee -a $WINROLL_LOG
		sleep 5;
	done
}

check_if_root_and_envi(){
	if [ -z "$(id| grep -iE 'groups=.*\('$_GID_Administrators'\)')" ] ; then
		id | tee -a $WINROLL_LOG
		echo "You have no privilege to change, abort !!!" 
		exit 1
	fi
	
	chown -R .$_GID_Administrators $WINROLL_CONF_ROOT
	chmod g+w $WINROLL_CONF_ROOT/*.conf
}
get_nic_name_str(){
	# it will return nic device name with ':' as separator. But output is pure stream if assign a mac address
	mac=$1;
	local _tmp_line_nm_rev;
	local _tmp_dev_str;

	if [ -n "$mac" ] ; then
		_tmp_line_nm_rev=$(ipconfig /all | grep -n "$mac"| head -n 1 | awk -F ":" '{print $1}')
		_tmp_dev_str=$(ipconfig /all | head -n $_tmp_line_nm_rev | tac | grep "$_Ethernet_Adapter_KEYWORD"| head -n 1| dos2unix | sed -e "s/$_Ethernet_Adapter_KEYWORD//g" -e "s/^\s*//g" -e "s/:$//g" )
	else
		 _tmp_dev_str=$(ipconfig /all | grep "$_Ethernet_Adapter_KEYWORD"| dos2unix |  sed -e "s/$_Ethernet_Adapter_KEYWORD//g" -e 's/^\s*//g' )
	fi
	[ -n "$ _tmp_dev_str" ] && echo "$_tmp_dev_str" ;
}

get_ip_str(){
	local _tmp_ip_str;
	_tmp_ip_str="$(ipconfig | grep "$_IPV4_ADDRESS_KEYWORD" | cut -d ":" -f 2 | sed -e "s/\s*//g" )"
	[ -n "$_tmp_ip_str" ] && echo $_tmp_ip_str

}
detect_win_version(){
	OS_VERSION=
	OS_ProductName=$(cat /proc/registry/HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows\ NT/CurrentVersion/ProductName)
	LOCALEID=$(cat /proc/registry/HKEY_CURRENT_USER/Control\ Panel/International/Locale)
	
	if [ -n "$(echo $OS_ProductName | grep '2000')" ] ; then
		OS_VERSION=win2000
	elif [ -n "$(echo $OS_ProductName | grep 'XP')" ] ; then
		OS_VERSION=xp
	elif [ -n "$(echo $OS_ProductName | grep '2003')" ] ; then
		OS_VERSION=win2003
	elif [ -n "$(echo $OS_ProductName | grep 'Vista')" ] ; then
		OS_VERSION=vista
	elif [ -n "$(echo $OS_ProductName | grep 'Windows 7')" ] ; then
		OS_VERSION=win7
	elif [ -n "$(echo $OS_ProductName | grep '2008')" ] ; then
		OS_VERSION=win2008
	else
		OS_VERSION=
	fi 
	echo $OS_VERSION
}
detect_locale_code(){
	echo $(cat /proc/registry/HKEY_CURRENT_USER/Control\ Panel/International/Locale)
}


