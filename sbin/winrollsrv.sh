#!/bin/sh

###########################################################################
#  drbl-winRoll service
#
# License: GPL
# Author	: Ceasar Sun Chen-kai <ceasar@nchc.org.tw> , Steven steven@nchc.org.tw
# Purpose	: Main service for drbl-winroll, refer winroll.conf(winroll.txt) to run auto-config for windows
# Date	: 2008/05/20
#
# Usage:  %CYGWIN_ROOT%\bin\autohostname.sh -e "CYGWIN=${_cygwin}"
#
###########################################################################
#WINROLL_CONFIG="/drbl_winRoll-config/winRoll.txt"
WINROLL_FUNCTIONS="/drbl_winRoll-config/winroll-functions.sh"
. $WINROLL_FUNCTIONS

# Local service paremeter 
SERVICE_NAME='winrollsrv'
LOCKFILE=winrollsrv.lock
REBOOT_FLAG=winrollsrv.reboot

# For lock service 
rm -rf $WINROLL_TMP/$REBOOT_FLAG;
if [ $(ls $WINROLL_TMP/winroll-*.reboot 2>/dev/null | wc -l) -gt 0 ]; then
	echo `date` "$SERVICE_NAME:reboot flag:" `ls $WINROLL_TMP/winroll-*.reboot | wc -l`
	exit;
fi
touch $WINROLL_TMP/$LOCKFILE;
echo `date` "$SERVICE_NAME: start lock:" 

NEED_TO_REBOOT=0

#######################
# Sun function
#######################
do_config_network(){
	SERVICE_NAME="CONFIG_NETWORK"
	DEFAULT_CLIENT_MAC_NETWORK="$WINROLL_CONF_ROOT/client-mac-network.conf"
	
	# CONFIG_NETWORK_MODE = none ; do nothing
	# CONFIG_NETWORK_MODE = dhcp ; do dhcp
	# CONFIG_NETWORK_MODE = /RDF:/drbl_winroll-config/client-mac-network.conf  ; config by file 
	 
	CONFIG_NETWORK_MODE="$(sed -e "s/\s*=\s*/=/g" $WINROLL_CONFIG | grep -e "^CONFIG_NETWORK_MODE=" | sed -e "s/^CONFIG_NETWORK_MODE=//" -e "s/(\s! )//g")"
	if [ "$CONFIG_NETWORK_MODE" = "none" ] || [ -z "$CONFIG_NETWORK_MODE" ] ; then
		echo "CONFIG_NETWORK_MODE : none"
		return 3;
	elif [ "$CONFIG_NETWORK_MODE" = "dhcp" ] ; then
		ipconfig /renew >/dev/null ; ipconfig /release >/dev/null; ipconfig /renew >/dev/null
		IF_IPRENEW=1
		echo "CONFIG_NETWORK_MODE : dhcp"
		return 2;
	elif [ -n "$(echo $CONFIG_NETWORK_MODE | grep -e '/RDF' 2> /dev/null )" ] ; then
		CLIENT_MAC_NETWORK="$(echo $CONFIG_NETWORK_MODE | awk -F ':' '{print $2}' )"
		[ -e "$CLIENT_MAC_NETWORK" ] || ( echo "No CLIENT_MAC_NETWORK file : $CLIENT_MAC_NETWORK" ; return 11 )
		
		# get network default configuration
		nw_conf_tmp=nic-conf.tmp
		grep -e "^_DEFAULT" $CLIENT_MAC_NETWORK | sed -e "s/\s*=\s*/=/g" -e "s/\s\{1,\}/,/g" -e "s/,\{1,\}/,/g"  -e "s/\#/ #/" -e "s/^_DEFAULT_/export _DEFAULT_/g" > $WINROLL_TMP/$nw_conf_tmp
		. $WINROLL_TMP/$nw_conf_tmp

		# get configuration domaains
		network_domain_list=$(grep -e "^subnet.\{1,\}[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}\/[0-9]\{1,2\}" $CLIENT_MAC_NETWORK | sed -e "s/subnet//g"| tr -d " ",{ )

		# get mac address of itself machine
		mac_address_list=$(ipconfig /all | grep "Physical Address" | cut -d":" -f2 | sed -e "s/\s//g")

		for mac in $mac_address_list ; do
			thisdm=
			thisip=$(grep $mac $CLIENT_MAC_NETWORK 2>/dev/null |awk -F '=' '{print $2}'| sed -e "s/\s//g" )
			[ -z "$thisip" ] && echo "No ip for the mac :$mac" && break
			bin_thisip=$(ipcalc $thisip | grep Address: | awk -F" " '{print $3 $4 }'| sed -e "s/\.//g")
			dec_this_ip=$(echo "ibase=2; obase=A; $bin_thisip" | bc)
			for dm in $network_domain_list ; do
				bin_max_ip=$(ipcalc $dm  | grep HostMax: | awk -F" " '{print $3 $4 }'| sed -e "s/\.//g")
				dec_max_ip=$(echo "ibase=2; obase=A; $bin_max_ip" | bc)
				bin_min_ip=$(ipcalc $dm  | grep HostMin: | awk -F" " '{print $3 $4 }'| sed -e "s/\.//g")
				dec_min_ip=$(echo "ibase=2; obase=A; $bin_min_ip" | bc)
				#echo "'$dm','$dec_this_ip','$dec_max_ip','$dec_min_ip'" >> /var/log/bug.tmp
				(( $dec_this_ip <= $dec_max_ip )) && (( $dec_this_ip >= $dec_min_ip  )) && thisdm=$dm && break;
			done
			echo "'$mac','$thisip','$thisdm'";
			if [ -z "$thisdm" ] ; then 
				bin_max_ip=$(ipcalc $_DEFAULT_NETWORK  | grep HostMax: | awk -F" " '{print $3 $4 }'| sed -e "s/\.//g")
				dec_max_ip=$(echo "ibase=2; obase=A; $bin_max_ip" | bc)
				bin_min_ip=$(ipcalc $_DEFAULT_NETWORK  | grep HostMin: | awk -F" " '{print $3 $4 }'| sed -e "s/\.//g")
				dec_min_ip=$(echo "ibase=2; obase=A; $bin_min_ip" | bc)
				echo "'$dec_this_ip','$dec_max_ip','$dec_min_ip'"
				(( $dec_this_ip > $dec_max_ip )) || (( $dec_this_ip < $dec_min_ip  ))  && echo "no fit domain:" && return 12

			else
				_DEFAULT_NETWORK=$thisdm
				this_nw_conf_tmp=this-nic-conf.tmp
				line_nm_dm_reverse=$(tac $CLIENT_MAC_NETWORK | grep -n -e "^subnet.\{1,\}$thisdm" | awk -F ":" '{print $1}' )
				line_nm_dm_content=$(tail -n $line_nm_dm_reverse $CLIENT_MAC_NETWORK | grep -n "}" | head -n 1 | awk -F ":" '{print $1}')
				# grep -e "^_DEFAULT" $CLIENT_MAC_NETWORK | sed -e "s/\s*=\s*/=/g" -e "s/\s\{1,\}/,/g" -e "s/,\{1,\}/,/g"  -e "s/^_DEFAULT_/export _DEFAULT_/g" > $WINROLL_TMP/$nw_conf_tmp
				tail -n $line_nm_dm_reverse $CLIENT_MAC_NETWORK | head -n $line_nm_dm_content | grep THIS_ | sed -e "s/^\s*//g" -e "s/\s*=\s*/=/g" -e "s/\s\{1,\}/,/g" -e "s/,\{1,\}/,/g" -e "s/\#/ #/" -e "s/THIS_/export _DEFAULT_/g"  > $WINROLL_TMP/$this_nw_conf_tmp
				. $WINROLL_TMP/$this_nw_conf_tmp
			fi

			# netsh int ip set address <nicsname> static <ipaddress> <subnetmask> <gateway> <metric>
			# netsh -c interface  ip set address name="區域連線" static 172.16.91.12 255.255.255.0 172.16.91.2 1
			line_nm_rev=$(ipconfig /all | grep -n $mac | awk -F ":" '{print $1}')
			devname=$(ipconfig /all | head -n $line_nm_rev | tac | grep "Ethernet adapter"| head -n 1| sed -e "s/Ethernet adapter//g" -e "s/^\s*//g" -e "s/:$//g" )
			echo $devname
			echo "_DEFAULT_NETWORK = $_DEFAULT_NETWORK"
			echo "_DEFAULT_GATEWAY = $_DEFAULT_GATEWAY"
			echo "_DEFAULT_DNS = $_DEFAULT_DNS"
			echo "_DEFAULT_WINS = $_DEFAULT_WINS"
			echo "_DEFAULT_DNS_SUFFIX = $_DEFAULT_DNS_SUFFIX"
			exit
		done
		
	else 
		echo "CONFIG_NETWORK_MODE :$CONFIG_NETWORK_MODE ?? " 
	fi



}
do_autohostname(){

	# wsname.exe 的 log file 不能改，不然無法取得 return code
	export WSNAME_LOG="$TEMP/wsname.log"
	NEED_TO_CHANGE=0
	IF_IPRENEW=0

	# get necessary parameters form winroll.conf
	HNAME=$(hostname | sed -e "s/\s//g")
	HN_WSNAME_DEF_PARAM=$(sed -e "s/\s*=\s*/=/g" $WINROLL_CONFIG | grep -e "^HN_WSNAME_DEF_PARAM=" | sed -e "s/^HN_WSNAME_DEF_PARAM=//" -e "s/\s//g")
	HN_WSNAME_PARAM=$(sed -e "s/\s*=\s*/=/g" $WINROLL_CONFIG | grep -e "^HN_WSNAME_PARAM=" | sed -e "s/^HN_WSNAME_PARAM=//" -e "s/(\s! )//g")
	
	[ ! -f "$WSNAME_LOG" ] && touch $WSNAME_LOG;
	if [ -z "$HN_WSNAME_PARAM" ] ; then	HN_WSNAME_PARAM=$HN_WSNAME_DEF_PARAM; fi
	echo "" > $WSNAME_LOG		# Clean advanced log
	echo "'$HN_WSNAME_DEF_PARAM','$WSNAME_LOG','$HN_WSNAME_PARAM','$HNAME'" #| tee -a  $WINROLL_LOG
	wsname.exe $HN_WSNAME_PARAM	# use /TEST to pre-test the hostname assigned by wsname

	#2006/4/14 上午 12:21:32 : Could not determine local IP address. - Rename request aborted!
	#2006/4/14 上午 12:21:32 : Terminate                 : Exit code 4

	#2006/4/12 下午 05:48:22 : Computer is already named NEW-55. - Rename request aborted!
	#2006/4/12 下午 05:48:22 : Terminate                 : Exit code 7

	#2006/4/12 下午 05:51:06 : Search Key not found in Data File - Rename request aborted!
	#2006/4/12 下午 05:51:06 : Terminate                 : Exit code 14

	#2006/4/12 下午 05:51:32 : Can't find data file "C:\\cygwin\\drbl-config\\hostssss.conf" - Rename request aborted!
	#2006/4/12 下午 05:51:32 : Terminate                 : Exit code 13

	#2006/4/12 下午 05:52:44 : Rename Method             : SetComputerNameEx
	#2006/4/12 下午 05:52:44 : Rename Successful - reboot required to take effect

	#2006/4/12 下午 06:36:07 : New name validity check   : Failed - Rename request aborted!
	#2006/4/12 下午 06:36:07 : Terminate                 : Exit code 8

	#2006/4/12 下午 06:34:46 : Command Line              : C:\cygwin\bin\wsname.exe /DFGHHJ
	#2006/4/12 下午 06:34:58 : Termination               : WSName closed normally from the GUI

	WS_RETURN_CODE=$(tail -n 1 $WSNAME_LOG | tr -d "\r")

	#Assign a new hostname and rebooot to active
	if [ -n "$(echo $WS_RETURN_CODE | grep -e 'Rename Successful - reboot ' 2> /dev/null )" ] ; then
		NEED_TO_CHANGE=1
	# No ip release 
	elif [ -n "$(echo $WS_RETURN_CODE | grep -e 'Exit code 4' 2> /dev/null )" ] ; then
		NEED_TO_CHANGE=0
		echo "No ip release ,Please check $HN_WSNAME_PARAM for more detail !!";
	# Hostname is already correct
	elif [ -n "$(echo $WS_RETURN_CODE | grep -e 'Exit code 7' 2> /dev/null )" ] ; then
		NEED_TO_CHANGE=0
		echo "Hostname is already correct. - Rename request aborted !!";
	# Other case : Exit code 8 : New name validity check  ,13 :Can't find data file , 14:Search Key not found in Data File
	else 
		#  If configuration error or other reason to setup hostname fial , use default parameter 
		echo "Error:$WS_RETURN_CODE Use default parameter !!"
		#if [ -n "$(echo $HN_WSNAME_DEF_PARAM | grep -e '$IP' 2> /dev/null)" ] ; then
		#	ipconfig /renew; ipconfig /release; ipconfig /renew
		#	IF_IPRENEW=1
		#fi
		NEED_TO_CHANGE=0
		wsname.exe $HN_WSNAME_DEF_PARAM
		WS_RETURN_CODE=$(tail -n 1 $WSNAME_LOG | tr -d "\r")
		# if use $IP as default, but client can't get a release IP .!! It's a special case
		if [ -n "$(echo $WS_RETURN_CODE | grep -e 'Exit code 4' 2> /dev/null )" ] ; then
			NEED_TO_CHANGE=0
			echo "No ip release ,Please check $HN_WSNAME_PARAM for more detail !!";
			# use other format as default, and active ti change
		elif [ -z "$(echo $WS_RETURN_CODE | grep -e 'Exit code 7' 2> /dev/null )" ] ; then
			NEED_TO_CHANGE=1
		fi
	fi
	echo "'$WS_RETURN_CODE','$NEED_TO_CHANGE'"
	# done for hostname

	# For workgroup
	WG_STR=
	WG_WSNAME_PARAM=$(sed -e "s/\s*=\s*/=/g" $WINROLL_CONFIG | grep -e "^WG_WSNAME_PARAM=" | sed -e "s/^WG_WSNAME_PARAM=//" -e "s/(\s)//g" )
	echo WG_WSNAME_PARAM="$WG_WSNAME_PARAM"

	if [ -n "$WG_WSNAME_PARAM" ] ;then
		#if [ "$IF_IPRENEW" != "1" ] ; then
		#	ipconfig /renew; ipconfig /release; ipconfig /renew
		#fi
		
		NM="$(ipconfig | grep "Subnet Mask" | head -n 1 | cut -d ":" -f 2 | sed -e "s/\s*//g" )"
		IP="$(ipconfig | grep "IP Address" | head -n 1 | cut -d ":" -f 2 | sed -e "s/\s*//g" |awk -F. '{print $1+1000"-"$2+1000"-"$3+1000"-"$4+1000 }' | sed -e 's/^1//' -e 's/\-1/-/g' )"
		DNS_SUFF="$(ipconfig /all | grep 'DNS Suffix Search List' 2>/dev/null |head -n 1 | cut -d ":" -f 2 | cut -d "." -f 1,2 |sed -e "s/\./-/g" -e "s/\s*//g" )"

		if [ "$NM" = "255.255.0.0" ] ;then
			NM_STR=$(echo $IP| cut -d "-" -f 2,3)
		else
			NM_STR=$(echo $IP| cut -d "-" -f 3)
		fi
		
		WG_STR=$(echo $WG_WSNAME_PARAM | sed -e "s/\$DNS_SUFFIX/$DNS_SUFF/g" -e "s/\$NM/$NM_STR/g" -e 's/\s//g')

		echo WG_STR="$WG_STR"
		
		if [ -n "$WG_STR" ] && [ "${#WG_STR}" -le 15 ] ; then
			wsname.exe /N /WG:$WG_STR
			WS_RETURN_CODE=$(tail -n 1 $WSNAME_LOG )
			if [ -n "$(echo $WS_RETURN_CODE | grep -e 'Workgroup Name set successfully' 2> /dev/null )" ] ; then
				# reset workgroup, need to reboot
				echo "reset workgroup, need to reboot"
				NEED_TO_CHANGE=1
			elif [ -n "$(echo $WS_RETURN_CODE | grep -e 'Workgroup and is already set to' 2> /dev/null )" ] ; then
				# workgroup is already correct
				echo "workgroup is already correct"
			else 
				#  If configuration error or other reason to setup hostname fial , use default parameter 
				echo "Not define !!"
			fi
		else 
			echo "Bad workgroup string lenght :'$WG_STR'"
		fi
	fi
	# done for workgroup
	if [ "$NEED_TO_CHANGE" = "1" ] ; then
		NEED_TO_REBOOT=1
		echo `date` "AUTOHOSTNAME need to reboot :" 
	fi
}
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
		echo "do fix_usersid_restart_sshd" 
	fi
	rm -rf "$WINROLL_TMP/$FIX_SSHD_LOCKFILE"
}

do_autonewsid(){

	SID_MD5CHK_FILE="$WINROLL_CONF_ROOT/sid.md5"
	NICMAC_ADDR_MD5=""
	NEED_TO_CHANGE=0

	[ ! -f "$SID_MD5CHK_FILE" ] && touch $SID_MD5CHK_FILE;

	NICMAC_ADDR_MD5="$(ipconfig /all | grep "Physical Address" | head -n 1 | cut -d ":" -f 2 | sed -e "s/\s*//g" | md5sum | cut -d ' ' -f 1)"
	NEED_TO_CHANGE=0

	echo $NICMAC_ADDR_MD5 

	if [ "$(cat $SID_MD5CHK_FILE)" != "$NICMAC_ADDR_MD5" ] ; then
		echo "Renew sid for: $NICMAC_ADDR_MD5 " 
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
	if [ "$NEED_TO_CHANGE" = "1" ] ; then
		NEED_TO_REBOOT=1
		echo `date` "AUTONEWSID need to reboot :" 
	fi

}
#######################
# Main function
#######################
check_if_root_and_envi

FIX_SSHD_LOCKFILE=fixsshd.lock

# for fix sshd service 
[ -f "$WINROLL_TMP/$FIX_SSHD_LOCKFILE" ] && fix_usersid_restart_sshd

do_config_network;
echo "done nnnn"
exit
IF_AUTOHOSTNAME_SERVICE="$(sed -e "s/\s*=\s*/=/g" $WINROLL_CONFIG | grep -e "^IF_AUTOHOSTNAME_SERVICE=" | sed -e "s/^IF_AUTOHOSTNAME_SERVICE=//" -e "s/(\s! )//g")"
[ "$IF_AUTOHOSTNAME_SERVICE" = "y" ] && do_autohostname;

IF_NEWSID_SERVICE=$(sed -e "s/\s*=\s*/=/g" $WINROLL_CONFIG | grep -e "^IF_NEWSID_SERVICE=" | sed -e "s/^IF_NEWSID_SERVICE=//" -e "s/(\s! )//g")
[ "$IF_NEWSID_SERVICE" = "y" ] && do_autonewsid;


#Unlock the service
rm -rf  $WINROLL_TMP/$LOCKFILE;
echo `date` "$SERVICE_NAME: unlock:" 

# Check if any service be lock, perpare to reboot, 
if [ "$NEED_TO_REBOOT" = "1" ]; then
	# touch $WINROLL_TMP/$REBOOT_FLAG;
	echo `date` "$SERVICE_NAME: set rboot flag:" 
	ls -al `which reboot`
	#waiting_to_reboot;
	reboot -r 10;
	echo `date` "$SERVICE_NAME: do reboot:" 
fi


