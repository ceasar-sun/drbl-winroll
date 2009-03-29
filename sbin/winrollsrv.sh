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

# Local service paremeter 
declare CYGWIN_ROOT='c:\cygwin\'
declare WINROLL_LOCAL_BACKUP=$HOMEPATH/drbl-winroll.bak
declare WINROOT=Administrator
declare SSHD_SNAME='sshd'
declare AUTOHN_SNAME='autohostname'
declare AUTOSID_SNAME='autonewsid'
declare action="c"
declare NEED_TO_RUN_SID=0
declare NEED_TO_RUN_SID=0
declare SSHD_SERVER_PW=1qaz2wsx
		
declare SYSINT_LINCESE_URL="http://drbl.nchc.org.tw/drbl-winroll/download/newsid-licence.php"
declare NEWSID_DOWNLOAD_URL="http://drbl.nchc.org.tw/drbl-winroll/download/newsid-download.php"


config_sshd(){
	ssh-host-config -y -c ntsec -w $SSHD_SERVER_PW
	cygrunsrv -S $SSHD_SNAME
	
	netsh firewall add portopening TCP 22 sshd 1>/dev/null 2>&1
	[ -d "/home/$WINROOT/.ssh" ] || mkdir /home/$WINROOT/.ssh
	
	if [ -f "$WINROLL_LOCAL_BACKUP\.ssh\authorized_keys" ]; then
		echo "Import $WINROLL_LOCAL_BACKUP\.ssh ?" 
		ANSWER_IF_GO=y
		read -p "[Y/n] " ANSWER_IF_GO junk

		if [ "$ANSWER_IF_GO" != "n" ]; then
			cp -af "$WINROLL_LOCAL_BACKUP\.ssh" "/home/$WINROOT/"
			echo "Import backuped ssh key : $WINROLL_LOCAL_BACKUP\.ssh\authorized_keys "
		fi
	fi
}
config_autohostname(){
	HOSTNAME_PREFIX=PC
	HN_WSNAME_PARAM=$(sed -e "s/\s*=\s*/=/g" $WINROLL_CONFIG | grep -e "^HN_WSNAME_PARAM=" | sed -e "s/^HN_WSNAME_PARAM=//" -e "s/(\s! )//g")
	WG_WSNAME_PARAM=$(sed -e "s/\s*=\s*/=/g" $WINROLL_CONFIG | grep -e "^WG_WSNAME_PARAM=" | sed -e "s/^WG_WSNAME_PARAM=//" -e "s/(\s! )//g" )

	if [ -z "$HN_WSNAME_PARAM" ]; then
		WINROLL_HOSTS_FILE="$CYGWIN_ROOT\drbl_winRoll-config\hosts.txt"
		echo "Please select hostname format:"
		echo .
		echo "[1] by IP"
		echo "[2] by MAC"
		echo "[3] by_file, more detail to refrer $WINROLL_HOSTS_FILE"
		read -p "[1] " ANSWER junk
	
		echo "Set hostname perfix:"
		read -p "[$HOSTNAME_PREFIX] " ANSWER_HOSTNAME_PREFIX junk
		[ -n "$ANSWER_HOSTNAME_PREFIX" ] && HOSTNAME_PREFIX=$ANSWER_HOSTNAME_PREFIX
	
		WS_PARA="/N:$HOSTNAME_PREFIX-\$IP[7+]"
		if [ "$ANSWER" = "2" ]; then
			WS_PARA="/N:$HOSTNAME_PREFIX-\$MAC"
		fi
		if [ "$ANSWER" = "3" ]; then
			WS_PARA="/RDF:$WINROLL_HOSTS_FILE /DFK:\$MAC"
		fi
		echo "Set hostname format :$WS_PARA"
		echo "HN_WSNAME_PARAM = $WS_PARA" >> $WINROLL_CONFIG
	else
		echo "Use current hostname format :$HN_WSNAME_PARAM"
		read -p "[$HN_WSNAME_PARAM] " ANSWER_HN_WSNAME_PARAM junk
		[ -n "$ANSWER_HN_WSNAME_PARAM" ] && HN_WSNAME_PARAM=$ANSWER_HN_WSNAME_PARAM
		
		cp -f $WINROLL_CONFIG $WINROLL_CONFIG.bak
		grep -v -e "^HN_WSNAME_PARAM =" $WINROLL_CONFIG > $WINROLL_CONFIG.new
		echo "HN_WSNAME_PARAM = $HN_WSNAME_PARAM" >> $WINROLL_CONFIG.new
		mv -f $WINROLL_CONFIG.new $WINROLL_CONFIG
	fi
	
	if [ -z "$WG_WSNAME_PARAM" ]; then
		WG_PREFIX="WG"
		# WG_PREFIX=$(nbtstat.exe -n | grep -E "<00>.+GROUP" | sed -r "s/\s+/ /g" | cut -d " " -f 2)
		
		echo "Please selet workgroup format:"
		echo .
		echo "[1]: Fixed: [$WG_PREFIX]"
		echo "[2]: By IP/NETMASK: [$WG_PREFIX-XXX]"
		echo "[3]: By DNS SUFFIX"

		read -p"[1] " ANSWER junk
		
		if [ "$ANSWER" != "3" ]; then
			echo "Set workgroup prefix:"
			read -p "[$WG_PREFIX] " ANSWER_WG_PREFIX junk
			[ -n "$ANSWER_WG_PREFIX" ] && WG_PREFIX=$ANSWER_WG_PREFIX
		fi
		
		echo .
		WG_WSNAME_PARAM="$WG_PREFIX"
		[ "$ANSWER" = "2" ] && WG_WSNAME_PARAM="$WG_PREFIX-\$NM"
		[ "$ANSWER" = "3" ] && WG_WSNAME_PARAM="\$DNS_SUFFIX"
		echo "Set workgroup format as $WG_WSNAME_PARAM"
		echo "WG_WSNAME_PARAM = $WG_WSNAME_PARAM" >> $WINROLL_CONFIG
	
	else
		echo "Use current workgroup format :$WG_WSNAME_PARAM"
		read -p "[$WG_WSNAME_PARAM] " ANSWER_WG_WSNAME_PARAM junk
		[ -n "$ANSWER_WG_WSNAME_PARAM" ] && WG_WSNAME_PARAM=$ANSWER_WG_WSNAME_PARAM
		
		cp -f $WINROLL_CONFIG $WINROLL_CONFIG.bak
		grep -v -e "^WG_WSNAME_PARAM =" $WINROLL_CONFIG > $WINROLL_CONFIG.new
		echo "WG_WSNAME_PARAM = $WG_WSNAME_PARAM" >> $WINROLL_CONFIG.new
		mv -f $WINROLL_CONFIG.new $WINROLL_CONFIG
	fi
	unix2dos $WINROLL_CONFIG
	[ -z "`cygrunsrv -Q $AUTOHN_SNAME 2>/dev/null `" ] && cygrunsrv -I "$AUTOHN_SNAME" -d "Auto Hostname Checker" -p "$CYGWIN_ROOT\bin\autohostname.sh" -e "CYGWIN=${_cygwin}" -i

}
config_autonewsid(){
	if [ ! -x "`which newsid 2>/dev/null`" ]; then
		NEED_TO_RUN_SID="1"
		IF_AGREE=y
		echo "Please view the license, accept or not ?"
		explorer $SYSINT_LINCESE_URL
		echo .
		read -p "[Y/n]" IF_AGREE junk
		if [ "$IF_AGREE" = "n" ]; then 
			echo "Please accept it if you need to use the toolkit !!"
			return
		fi
		
		rm.exe -rf $TMP/NewSid.zip $TMP/newsid.exe $TMP/Eula.txt
		wget.exe $NEWSID_DOWNLOAD_URL -P $TMP
		unzip.exe $TMP/NewSid.zip -d $TMP
		mv.exe $TMP/newsid.exe /usr/bin
		chmod.exe +x /usr/bin/newsid.exe
		
		rm.exe -rf $TMP/NewSid.zip $TMP/newsid.exe $TMP/Eula.txt
	fi
	[ -z "`cygrunsrv -Q $AUTOSID_SNAME 2>/dev/null `" ] && cygrunsrv -I "$AUTOSID_SNAME" -d "Auto New SID" -p "$CYGWIN_ROOT\bin\autonewsid.sh" -e "CYGWIN=${_cygwin}" -i
}

remove_sshd(){
	echo "Remove $SSHD_SNAME service ..."
	cygrunsrv.exe -E $SSHD_SNAME 1> /dev/null 2>&1
	cygrunsrv.exe -R $SSHD_SNAME 1> /dev/null 2>&1
	echo "Delet open port TCP 22 if need ..."
	netsh firewall delete portopening TCP 22 1> /dev/null 2>&1
	echo "Delete user 'sshd', 'sshd_server' ..."
	net user sshd /DELETE 1> /dev/null 2>&1
	net user sshd_server /DELETE 1> /dev/null 2>&1
	
	if [ -f "/home/$WINROOT/.ssh/authorized_keys" ];then
		mkdir -p "$WINROLL_LOCAL_BACKUP"
		echo "Find exist ssh key and backup to : $WINROLL_LOCAL_BACKUP/.ssh"
		cp -af  "/home/$WINROOT/.ssh" "$WINROLL_LOCAL_BACKUP/"
	fi
}
remove_autohostname(){
	echo "Remove $AUTOHN_SNAME service ..."	
	cygrunsrv.exe -E $AUTOHN_SNAME 1> /dev/null 2>&1
	cygrunsrv.exe -R $AUTOHN_SNAME 1> /dev/null 2>&1
}
remove_autonewsid(){
	echo "Remove $AUTOSID_SNAME service ..."	
	cygrunsrv.exe -E $AUTOSID_SNAME 1> /dev/null 2>&1
	cygrunsrv.exe -R $AUTOSID_SNAME 1> /dev/null 2>&1
}
list_winroll_service(){
	declare -a srv_name
	declare -a srv_stat
	
	srv_name[1]=$AUTOHN_SNAME; srv_stat[1]=off
	srv_name[2]=$AUTOSID_SNAME; srv_stat[2]=off
	srv_name[3]=$SSHD_SNAME; srv_stat[3]=off
	
	for (( i=1; i<=3; i=i+1)); do
		#[ -n "`cygrunsrv -Q $AUTOHN_SNAME 2>/dev/null `" ] && AUTOHN_STAT=on
		[ -n "`cygrunsrv -Q ${srv_name[$i]} 2>/dev/null `" ] && srv_stat[$i]=on
	done
	
	echo "********************************************"
	echo "**  Welcome to use drbl-winroll Controler **"
	echo "********************************************"
	echo "Which service want to edit?"
	echo "[1] ${srv_name[1]} ....... [${srv_stat[1]}]"
	echo "[2] ${srv_name[2]} ....... [${srv_stat[2]}]"
	echo "[3] ${srv_name[3]} ....... [${srv_stat[3]}]"
	echo "[x] Quit"
	echo "============================================"
	read -p "[x]" ANS_NUM junk
	
	if [ "$ANS_NUM" = "1" ]; then
		if [ -z "`cygrunsrv -Q ${srv_name[$ANS_NUM]} 2>/dev/null `" ]; then
			config_autohostname
		else
			echo "re-Config or remove service ?"
			read -p "[C|r]" ANS_ACT junk
			[ "$ANS_ACT" = "r" ] && remove_autohostname || config_autohostname
		fi
	elif [ "$ANS_NUM" = "2" ]; then
		[ -z "`cygrunsrv -Q ${srv_name[$ANS_NUM]} 2>/dev/null `" ] && config_autonewsid ||remove_autonewsid
	elif [  "$ANS_NUM" = "3" ]; then
		[ -z "`cygrunsrv -Q ${srv_name[$ANS_NUM]} 2>/dev/null `" ] && config_sshd || remove_sshd
	else
		echo "Bye !! "
		sleep 2;
		exit
	fi
	
}
# Main 
check_if_root
while [ $# -gt 0 ]; do
	case "$1" in
		-r|--remove)
			shift; action="r"
		;;
		-c|--config)
	    		shift; action="c"
		;;
		-s|--start)
			shift; action="s"
		;;
		-h|--help)
			Usage; exit 1;
	  	;;
		*)
			Usage; exit 1;
		;;
	esac
done

if [ "$action" = "r" ]; then
	[ -n "`cygrunsrv -Q $AUTOHN_SNAME 2>/dev/null `" ] && remove_autohostname
	[ -n "`cygrunsrv -Q $AUTOSID_SNAME 2>/dev/null `" ] && remove_autonewsid
	[ -n "`cygrunsrv -Q $SSHD_SNAME 2>/dev/null `" ] && remove_sshd
elif [ "$action" = "s" ]; then 
	[ -z "`cygrunsrv -Q $AUTOHN_SNAME 2>/dev/null `" ] && config_autohostname
	[ -z "`cygrunsrv -Q $AUTOSID_SNAME 2>/dev/null `" ] && config_autonewsid
	[ -z "`cygrunsrv -Q $SSHD_SNAME 2>/dev/null `" ] && config_sshd

else
	while [ "1" = "1" ]
	do
		clear;
		list_winroll_service
	done
fi
exit 0
