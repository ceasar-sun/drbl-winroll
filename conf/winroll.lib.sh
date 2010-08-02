#!/bin/sh

###########################################################################
# Unattended drbl-winRoll installation
#
# License: GPL
# Author	: Ceasar Sun Chen-kai <ceasar@nchc.org.tw> , Steven steven@nchc.org.tw
# Purpose	: Solve windows hostname duplication problem for using clone tool to distribute  Win-OS in one local LAN. 
# Date		: 2005/03/14
#
# Usage:  %CYGWIN_ROOT%\bin\autohostname.sh -e "CYGWIN=${_cygwin}"
#
###########################################################################

WINROLL_CONF_ROOT="/drbl_winroll-config"
WINROLL_TMP="/var/log"
WINROLL_CONFIG="$WINROLL_CONF_ROOT/winroll.conf"
WINROLL_LOG="$WINROLL_TMP/winrollsrv.log"
TEMP="/var/log"
TMP="/var/log"

_GID_Administrators='544'

waiting_to_reboot(){
	while [ $(ls $WINROLL_TMP/winroll-*.lock | wc -l) -gt 0 ]
	do
		echo `date` "$SERVICE_NAME: waiting_to_unlock:" `ls $WINROLL_TMP/winroll-*.lock | wc -l`  | tee -a $WINROLL_LOG
		sleep 5;
	done
}

check_if_root_and_envi(){
	if [ -z "$(id| grep -iE 'gid=.*,'$_GID_Administrators'\(' )" ] ; then
		echo "You have no privilege to change, abort !!!" | tee -a $WINROLL_LOG
		id | tee -a $WINROLL_LOG
		read
		exit 1
	fi
	
	chown -R .$_GID_Administrators $WINROLL_CONF_ROOT
	chmod g+w $WINROLL_CONF_ROOT/*.conf
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


