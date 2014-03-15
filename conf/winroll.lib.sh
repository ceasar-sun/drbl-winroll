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

WINROLL_REMOTE_MASTER="$WINROLL_CONF_ROOT/remote_master.conf"

_NIC_INFO=$WINROLL_TMP/_nic_info.conf
cscript //nologo `cygpath.exe -w /bin/get_nic_info.vbs` > $_NIC_INFO

#_GID_Administrators='Administrators'
_GID_Administrators='544'

alias clear='echo -e -n "\E[2J"'

waiting_to_reboot(){
	while [ $(ls $WINROLL_TMP/winroll-*.lock | wc -l) -gt 0 ]
	do
		echo `date` "$SERVICE_NAME: waiting_to_unlock:" `ls $WINROLL_TMP/winroll-*.lock | wc -l`  | tee -a $WINROLL_LOG
		sleep 5;
	done
}

check_if_root_and_envi(){
	if [ -z "$(id| grep -iE "groups(=|=.*[[:punct:]])$_GID_Administrators\(")" ] ; then
	id | tee -a $WINROLL_LOG
		echo "You have no privilege to change, abort !!!" 
		exit 1
	fi
	
	chown -R .$_GID_Administrators $WINROLL_CONF_ROOT
	chmod g+w $WINROLL_CONF_ROOT/*.conf
}

if_as_templete_mode(){

	NICMAC_ADDR_MD5=$(awk -F "\t" "{print \$1}" $_NIC_INFO | head -n 1 | md5sum | awk '{print $1}' )
	[ "$(cat $WINROLL_CONF_ROOT/as_templete.md5)" == "$NICMAC_ADDR_MD5" ] && IF_AS_TEMPLETE_MODE=y

}