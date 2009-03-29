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

#Golbal paremeter for drbl-winroll
WINROLL_FUNCTIONS="/drbl_winRoll-config/winroll-functions.sh"
. $WINROLL_FUNCTIONS

# sub function
fix_usersid_restart_sshd(){
	mkpasswd -l >/etc/passwd
	mkgroup -l >/etc/group
	
	cygrunsrv -Q sshd 
	if [ "$?" -eq "0" ]; then
		chmod 644 /var/log/sshd.log
		chmod 644 /etc/ssh_host*_key.pub
		chmod 600 /etc/ssh_host*_key
		chmod 750 /etc/ssh_config
		chmod 644 /etc/sshd_config
		echo "Restart sshd service ..."
		cygrunsrv -E sshd
		sleep 5
		cygrunsrv -S sshd
	fi
	rm -rf "$WINROLL_TMP/$FIX_SSHD_LOCKFILE"
}

# Local service paremeter 
SERVICE_NAME='autonewsid'
NEWSID_LOG="$WINROLL_TMP/newsid.log"
SID_MD5CHK_FILE="$WINROLL_CONF_ROOT/sid.md5"
NICMAC_ADDR_MD5=""
NEED_TO_CHANGE=0
LOCKFILE=winroll-autonewsid.lock
FIX_SSHD_LOCKFILE=fixsshd.lock
REBOOT_FLAG=winroll-autonewsid.reboot
[ ! -f "$NEWSID_LOG" ] && touch $NEWSID_LOG;
[ ! -f "$NEWSID_LOG" ] || (cp $NEWSID_LOG $NEWSID_LOG.tmp; rm -rf $NEWSID_LOG; mv $NEWSID_LOG.tmp $NEWSID_LOG)
[ ! -f "$SID_MD5CHK_FILE" ] && touch $SID_MD5CHK_FILE;

# for fix sshd service 
[ -f "$WINROLL_TMP/$FIX_SSHD_LOCKFILE" ] && fix_usersid_restart_sshd

# For lock service 
rm -rf $WINROLL_TMP/$REBOOT_FLAG;

# 不知為何用 find 會找不到檔案
#if [ $(find $WINROLL_TMP -name "winroll-*.reboot"| wc -l) -gt 0 ]; then
if [ $(ls $WINROLL_TMP/winroll-*.reboot | wc -l) -gt 0 ]; then
	echo `date` "$SERVICE_NAME:reboot flag:" `ls $WINROLL_TMP/winroll-*.reboot | wc -l`| tee -a $WINROLL_LOG
	exit;
fi
touch $WINROLL_TMP/$LOCKFILE;
echo `date` "$SERVICE_NAME:start lock:" | tee -a $WINROLL_LOG

# Start main 
NICMAC_ADDR_MD5="$(ipconfig /all | grep "Physical Address" | head -n 1 | cut -d ":" -f 2 | sed -e "s/\s*//g" | md5sum | cut -d ' ' -f 1)"
echo $NICMAC_ADDR_MD5 | tee -a $NEWSID_LOG
#######################
# Main function
#######################
if [ "$(cat $SID_MD5CHK_FILE)" != "$NICMAC_ADDR_MD5" ] ; then
	echo "Renew sid for: $NICMAC_ADDR_MD5 " | tee -a $NEWSID_LOG
	rm -rf $SID_MD5CHK_FILE;
	NEED_TO_CHANGE=1
	mv -f /etc/passwd /etc/passwd.old
	mv -f /etc/group /etc/group.old
	
	newsid.exe /a /n;
	while [ $(ps au| grep newsid | wc -l) -gt 0 ]
	do
		echo "Waiting for renew sid ..."
		sleep 10;
	done
	echo "$NICMAC_ADDR_MD5" > $SID_MD5CHK_FILE
	touch "$WINROLL_TMP/$FIX_SSHD_LOCKFILE"
fi
#Unlock the service
rm -rf  $WINROLL_TMP/$LOCKFILE;
echo `date` "$SERVICE_NAME: unlock:" | tee -a $WINROLL_LOG

# Check if any service be lock, perpare to reboot, 
if [ "$NEED_TO_CHANGE" = "1" ]; then
	touch $WINROLL_TMP/$REBOOT_FLAG;
	echo `date` "$SERVICE_NAME: set rboot flag:" | tee -a $WINROLL_LOG
	waiting_to_reboot;
	reboot -r 10;
	echo `date` "$SERVICE_NAME: do reboot:" | tee -a $WINROLL_LOG
fi
exit