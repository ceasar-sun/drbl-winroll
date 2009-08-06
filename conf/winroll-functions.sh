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

WINROLL_CONF_ROOT="/drbl_winRoll-config"
WINROLL_TMP="/var/log"
WINROLL_CONFIG="$WINROLL_CONF_ROOT/winroll.conf"
WINROLL_LOG="$WINROLL_TMP/winrollsrv.log"
TEMP="/var/log"
TMP="/var/log"

waiting_to_reboot(){
	while [ $(ls $WINROLL_TMP/winroll-*.lock | wc -l) -gt 0 ]
	do
		echo `date` "$SERVICE_NAME: waiting_to_unlock:" `ls $WINROLL_TMP/winroll-*.lock | wc -l`  | tee -a $WINROLL_LOG
		sleep 5;
	done
}

check_if_root_and_envi(){
	echo `whoami`, `id`
	if [ ! -n "$(id| grep '(Administrators)')" ]; then
		echo "You have no privilege to change, abort !!!"
		read
		exit 1
	fi
	
	chown -R .Administrators $WINROLL_CONF_ROOT
	chmod g+w $WINROLL_CONF_ROOT/*.conf
	#username=`whoami`
	#if [ ! "$username" = "Administrator" ]; then
	#	echo "[$username] , You aren't Administrtor, keep go on ?";
	#	echo "[Ctrl+C] to exit; Any key to continue"
	#fi
}

