#!/bin/sh

###########################################################################
#  drbl-winroll service
#
# License: GPL
# Author	: Ceasar Sun Chen-kai <ceasar@nchc.org.tw> , Steven steven@nchc.org.tw
# Purpose	: Main service for drbl-winroll, refer winroll.conf(winroll.txt) to run auto-config for windows
# Date	: 2008/05/20
#
# Usage:  %CYGWIN_ROOT%\bin\autohostname.sh -e "CYGWIN=${_cygwin}"
#
###########################################################################
WINROLL_LIBS="/drbl_winroll-config/winroll.lib.sh"
for lib in $WINROLL_LIBS ; do 
	[ -f "$lib" ] && . $lib
done

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

_NIC_INFO=$WINROLL_TMP/_nic_info.conf
cscript //nologo `cygpath.exe -w /bin/get_nic_info.vbs` > $_NIC_INFO

NEED_TO_REBOOT=0

#######################
# Sun function
#######################
get_remote_master_conf(){

	# get necessary parameters form winroll.conf
	WINROLL_REMOTE_CONF=$(sed -e "s/\s*=\s*/=/g" $WINROLL_REMOTE_MASTER | grep -e "^WINROLL_REMOTE_CONF=" | sed -e "s/^WINROLL_REMOTE_CONF=//" -e "s/\s//g")
	
	if [ -n "$(echo $WINROLL_REMOTE_CONF | grep -ie '^http://' 2> /dev/null )" ] ; then
		echo "get WINROLL_REMOTE_CONF via $WINROLL_REMOTE_CONF:"
		wget -t 5 -T 3 "$WINROLL_REMOTE_CONF" -O  $WINROLL_TMP/winroll_remote_master.conf 2> /dev/null
		[ "$?" = 0 ] && sed -e "s/^\s*//g" -e "s/^#.*//g" -e "s/\s*$//g"  -e "s/^.*\s*\=\s*$//g" -e "s/\s*=\s*/=/g"  -e "/^$/d" -i $WINROLL_TMP/winroll_remote_master.conf
	elif [ -n "$(echo $WINROLL_REMOTE_CONF | grep -ie '^tftp://' 2> /dev/null )" ] ; then
		# use tftp client
		echo "get WINROLL_REMOTE_CONF via $WINROLL_REMOTE_CONF:"
	fi
	
	# Add a newline if without it in winroll.conf
	[[ $(tail -c1 $WINROLL_CONFIG) && -f $WINROLL_CONFIG ]] && echo ''>>$WINROLL_CONFIG
	
	while read -r line
	do
		KEY="$(echo $line | awk -F "=" '{print $1}' )"
		sed -e "s|^\s*${KEY}\s*=.*|$(echo ${line} | sed 's|\\|\\\\|g')|g" -i $WINROLL_CONFIG
		[ -z "$( grep -E "^\s*$KEY\s*=.*" $WINROLL_CONFIG 2> /dev/null )" ] && (echo $line >> $WINROLL_CONFIG)
	done < $WINROLL_TMP/winroll_remote_master.conf
	[ -f "$WINROLL_TMP/winroll_remote_master.conf" ] &&  mv $WINROLL_TMP/winroll_remote_master.conf $WINROLL_TMP/winroll_remote_master.conf.bak
	read
}

do_config_network(){
	#SERVICE_NAME="CONFIG_NETWORK"
	DEFAULT_CLIENT_MAC_NETWORK="$WINROLL_CONF_ROOT/client-mac-network.conf"
	
	# CONFIG_NETWORK_MODE = none ; do nothing
	# CONFIG_NETWORK_MODE = dhcp ; do dhcp
	# CONFIG_NETWORK_MODE = /RDF:/drbl_winroll-config/client-mac-network.conf  ; config by file 
	 
	CONFIG_NETWORK_MODE="$(sed -e "s/\s*=\s*/=/g" $WINROLL_CONFIG | grep -e "^CONFIG_NETWORK_MODE=" | sed -e "s/^CONFIG_NETWORK_MODE=//" -e "s/(\s! )//g" -e "s/\s*$//g")"
	if [ "$CONFIG_NETWORK_MODE" = "none" ] || [ -z "$CONFIG_NETWORK_MODE" ] ; then
		echo "CONFIG_NETWORK_MODE : none"
		return 3;
	elif [ "$CONFIG_NETWORK_MODE" = "dhcp" ] ; then
		#_devname_str=$(get_nic_name_str)
		#for ((i=1;i<`echo ${_devname_str} | awk -F ":" '{print NF}'`;i++)) ; do
		awk -F "\t" '{print $2}' $_NIC_INFO | while read dev; do
			_devname=${dev}
			echo "Gen network adapter '$_devname' cmd into : TEMP/set_network_adapter.cmd"
			cat >$TEMP/set_network_adapter.cmd<<EOF
REM This cmd is create by winrollsrv.sh
netsh interface ip set address name="$_devname" source=dhcp
netsh interface ip set dns name="$_devname" source=dhcp
netsh interface ip set wins name="$_devname" source=dhcp
EOF
			unix2dos $TEMP/set_network_adapter.cmd
			cmd /Q /C `cygpath -d $TEMP/set_network_adapter.cmd`
			echo "Set NIC:'$_devname' as dhcp mode"
		done
		ipconfig /renew >/dev/null ; ipconfig /release >/dev/null; ipconfig /renew >/dev/null
		IF_IPRENEW=1
		echo "CONFIG_NETWORK_MODE : dhcp"
		return 2;
	elif [ -n "$(echo $CONFIG_NETWORK_MODE | grep -ie '^/RDF' 2> /dev/null )" ] ; then

		CLIENT_MAC_NETWORK_Winpath="$(echo $CONFIG_NETWORK_MODE | awk -F ':' '{print $2":"$3}' )"

		# deal with http/tftp remote conf
		if [ -n "$(echo $CLIENT_MAC_NETWORK_Winpath | grep -ie '^http://' 2> /dev/null )" ] ; then 
			wget -t 5 -T 3 "$CLIENT_MAC_NETWORK_Winpath" -O  $WINROLL_CONF_ROOT/client-mac-network.rem.conf 2> /dev/null
			[ "$?" = 0 ] && mv $WINROLL_CONF_ROOT/client-mac-network.rem.conf $WINROLL_CONF_ROOT/client-mac-network.conf
			# convert CLIENT_MAC_NETWORK_Winpath to Winodws format
			CLIENT_MAC_NETWORK_Winpath="$(cygpath -w $WINROLL_CONF_ROOT/client-mac-network.conf)"
		elif [  -n "$(echo $CONFIG_NETWORK_MODE | grep -ie '^tftp://' 2> /dev/null )" ] ; then
			tftp get "$CLIENT_MAC_NETWORK_Winpath" 2> /dev/null
			[ "$?" = 0 ] && mv $WINROLL_CONF_ROOT/client-mac-network.rem.conf $WINROLL_CONF_ROOT/client-mac-network.conf
			CLIENT_MAC_NETWORK_Winpath="$(cygpath -w $WINROLL_CONF_ROOT/client-mac-network.conf)"
		fi
		
		rm -f $WINROLL_CONF_ROOT/client-mac-network.rem.conf
		
		CLIENT_MAC_NETWORK="$(cygpath -u $CLIENT_MAC_NETWORK_Winpath )"
		[ ! -e "$CLIENT_MAC_NETWORK" ] &&  echo "No CLIENT_MAC_NETWORK file : $CLIENT_MAC_NETWORK" && return 1
		
		# get network default configuration
		nw_conf_tmp=nic-conf.tmp
		grep -e "^_DEFAULT" $CLIENT_MAC_NETWORK | sed -e "s/\s\{1,\}//g" -e "s/,\{1,\}/,/g"  -e "s/\#/ #/" -e "s/^_DEFAULT_/export _DEFAULT_/g" > $WINROLL_TMP/$nw_conf_tmp
		. $WINROLL_TMP/$nw_conf_tmp

		# get configuration domains
		network_domain_list=$(grep -e "^subnet.\{1,\}[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}\/[0-9]\{1,2\}" $CLIENT_MAC_NETWORK | sed -e "s/subnet//g"| tr -d " ",{ )
		[ -n "$_DEFAULT_NETWORK" ] && network_domain_list="$_DEFAULT_NETWORK $network_domain_list"
		
		# get mac address of itself machine
		#mac_address_list="$(ipconfig /all | dos2unix  | awk -F ":" "/ [0-9A-F]+-[0-9A-F]+-[0-9A-F]+-[0-9A-F]+-[0-9A-F]+-[0-9A-F]+$/{print \$2}" | sed -e 's/\s//g' )"
		mac_address_list=$(awk -F "\t" "{print \$1}" $_NIC_INFO )

		for mac in $mac_address_list ; do
			this_nw_conf_tmp=this-nic-conf.tmp
			thisip=
			grep -i $mac $CLIENT_MAC_NETWORK 2>/dev/null | sed -e "s/\s//g" -e "s/$mac/export thisip/ig" > $WINROLL_TMP/this-nic-conf.tmp
			. $WINROLL_TMP/$this_nw_conf_tmp
			
			# To get nic device name 
			#line_nm_rev=$(ipconfig /all | grep -n "$mac"| head -n 1 | awk -F ":" '{print $1}')
			#_devname=$(ipconfig /all | head -n $line_nm_rev | tac | grep "$_Ethernet_Adapter_KEYWORD"| head -n 1| dos2unix |  sed -e "s/$_Ethernet_Adapter_KEYWORD//g" -e "s/^\s*//g" -e "s/:$//g" )
			_devname=$(awk -F "\t" "\$1 ~/^$mac/  {print \$2}" $_NIC_INFO)

			# can't find match mac address for itself
			[ -z "$thisip" ] && echo "No match item for '$_devname' :$mac ," && continue
			
			# use "none" for this mac address 
			[ "$thisip"  = "none" ] && echo "$_devname ,$mac => none" && continue
			
			# use "dhcp" for this mac address 
			if [ "$thisip"  = "dhcp" ] ; then
				echo "Gen network adapter '$_devname' cmd into : $TEMP/set_network_adapter.cmd"
				cat >$TEMP/set_network_adapter.cmd<<EOF
REM This cmd is create by winrollsrv.sh
netsh interface ip set address name="$_devname" source=dhcp
netsh interface ip set dns name="$_devname" source=dhcp
netsh interface ip set wins name="$_devname" source=dhcp
EOF
				unix2dos $TEMP/set_network_adapter.cmd
				cmd /Q /C `cygpath -d $TEMP/set_network_adapter.cmd`

				ipconfig /release "$_devname" >/dev/null; ipconfig /renew "$_devname" >/dev/null
				IF_IPRENEW=1
				continue
			fi
			
			[ -n "$(ipcalc $thisip | grep 'INVALID ADDRESS')" ] && echo "Illegal ip :$thisip " && continue
			
			_THIS_NETWORK=$_DEFAULT_NETWORK
			_THIS_IP=$thisip
			_THIS_GATEWAY=$_DEFAULT_GATEWAY
			_THIS_NETMASK=
			_THIS_DNS=$_DEFAULT_DNS
			_THIS_WINS=$_DEFAULT_WINS
			_THIS_DNS_SUFFIX=$_DEFAULT_DNS_SUFFIX

			bin_thisip=$(ipcalc $_THIS_IP | grep Address: | awk -F" " '{print $3 $4 }'| sed -e "s/\.//g")
			dec_this_ip=$(echo "ibase=2; obase=A; $bin_thisip" | bc)

			# calculate suitable domain
			for dm in $network_domain_list ; do
				bin_max_ip=$(ipcalc $dm  | grep HostMax: | awk -F" " '{print $3 $4 }'| sed -e "s/\.//g")
				dec_max_ip=$(echo "ibase=2; obase=A; $bin_max_ip" | bc)
				bin_min_ip=$(ipcalc $dm  | grep HostMin: | awk -F" " '{print $3 $4 }'| sed -e "s/\.//g")
				dec_min_ip=$(echo "ibase=2; obase=A; $bin_min_ip" | bc)
				#echo "'$dm','$dec_this_ip','$dec_max_ip','$dec_min_ip'"
				(( $dec_this_ip <= $dec_max_ip )) && (( $dec_this_ip >= $dec_min_ip  )) && _THIS_NETWORK=$dm && break;
			done
			
			if [ "$_THIS_NETWORK" != "$_DEFAULT_NETWORK" ] ; then
				line_nm_dm_reverse=$(tac $CLIENT_MAC_NETWORK | grep -n -e "^subnet.\{1,\}$_THIS_NETWORK" | awk -F ":" '{print $1}' )
				line_nm_dm_content=$(tail -n $line_nm_dm_reverse $CLIENT_MAC_NETWORK | grep -n "}" | head -n 1 | awk -F ":" '{print $1}')
				tail -n $line_nm_dm_reverse $CLIENT_MAC_NETWORK | head -n $line_nm_dm_content | grep THIS_ | sed -e "s/^\s*//g" -e "s/\s*//g" -e "s/\s\{1,\}/,/g" -e "s/,\{1,\}/,/g" -e "s/\#/ #/" -e "s/THIS_/export _THIS_/g"  >> $WINROLL_TMP/$this_nw_conf_tmp
				. $WINROLL_TMP/$this_nw_conf_tmp
			fi
			
			_THIS_NETMASK=$(ipcalc $_THIS_NETWORK| grep Netmask | awk -F " " '{print $2}')
			echo "'$_devname','$_THIS_NETWORK','$_THIS_IP','$_THIS_NETMASK','$_THIS_GATEWAY','$_THIS_DNS','$_THIS_WINS','$_THIS_DNS_SUFFIX'"

			# netsh int ip set address <nicsname> static <ipaddress> <subnetmask> <gateway> <metric>
			# netsh -c interface  ip set address name="區域連線" static 172.16.91.12 255.255.255.0 172.16.91.2 1
			echo "Gen network adapter '$_devname' cmd into : $TEMP/set_network_adapter.cmd"
			cat >$TEMP/set_network_adapter.cmd<<EOF
REM This cmd is create by winrollsrv.sh
netsh -c interface ip set address name="$_devname" source=static addr=$_THIS_IP mask=$_THIS_NETMASK gateway=$_THIS_GATEWAY 1
EOF
			
			# delete all previous dns records
			if [ -n "$_THIS_DNS" ] ; then
				echo "Gen adapter '$_devname' cmd for delete dns : $TEMP/set_network_del_dns.cmd"
				cat >>$TEMP/set_network_adapter.cmd<<EOF
netsh interface ip del dns "$_devname" all
EOF
			fi

			# add a dns record 
			for dns in $(echo $_THIS_DNS | tr , ' ') ; do
				# skip illegal ip
				[ -n "$(ipcalc $dns | grep 'INVALID ADDRESS')" ]  && echo "Illegal dns ip :$dns" && continue
				echo "Gen adapter '$_devname' cmd for DNS '$dns' : $TEMP/set_network_dns.cmd"
				cat >>$TEMP/set_network_adapter.cmd<<EOF
netsh interface ip add dns "$_devname" $dns
EOF
			done

			# delete all previous wins records
			if [ -n "$_THIS_WINS" ] ; then 
				echo "Gen adapter '$_devname' cmd for delete wins : $TEMP/set_network_del_wins.cmd"
				cat >>$TEMP/set_network_adapter.cmd<<EOF
netsh interface ip del wins "$_devname" all
EOF

			fi
			
			# add a wins record 
			for wins in $(echo $_THIS_WINS | tr , ' ') ; do
				# skip illegal ip
				[ -n "$(ipcalc $wins | grep 'INVALID ADDRESS')" ]  && echo "Illegal wins ip :$wins" && continue
				echo "Gen adapter '$_devname' cmd for add wins : $TEMP/set_network_add_wins.cmd"
				cat >>$TEMP/set_network_adapter.cmd<<EOF
netsh interface ip add wins "$_devname" $wins
EOF
			done
			unix2dos $TEMP/set_network_adapter.cmd
			cmd /Q /C `cygpath -d $TEMP/set_network_adapter.cmd`	
			sleep 10;
			
			# For setup dns suffix search list
			_current_dns_suffix="$(cat /proc/registry/HKEY_LOCAL_MACHINE/SYSTEM/CurrentControlSet/Services/Tcpip/Parameters/SearchList 2>/dev/null)"
			if [ -n "$_THIS_DNS_SUFFIX" ] &&  [ "$_THIS_DNS_SUFFIX" != "$_current_dns_suffix" ] ; then 
				# skip illegal ip
				echo "Reset DNS suffix as : $_THIS_DNS_SUFFIX"
        		cat >$WINROLL_TMP/set_dns_suffix.vbs<<EOF
''' This vbs is create by winrollsrv.sh
SET WSHShell = CreateObject("WScript.Shell")
WSHShell.RegWrite"HKLM\System\CurrentControlSet\Services\TCPIP\Parameters\SearchList","$_THIS_DNS_SUFFIX","REG_SZ"
EOF
				unix2dos $WINROLL_TMP/set_dns_suffix.vbs
				wscript `cygpath -d $WINROLL_TMP/set_dns_suffix.vbs`
			fi
		done
	else 
		echo "CONFIG_NETWORK_MODE :$CONFIG_NETWORK_MODE ?? " 
	fi
	
	# Due to refresh network config , so re-gen nic information 
	cscript //nologo `cygpath.exe -w /bin/get_nic_info.vbs` > $_NIC_INFO
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
	
	# deal with http/tftp remote conf
	if [ -n "$(echo $HN_WSNAME_PARAM | grep -ie '^/RDF:http://' 2> /dev/null )" ] ; then
		HN_WSNAME_REMOTE_RDF=$(echo $HN_WSNAME_PARAM | awk -F " " '{print $1}'| sed -e "s/^\/RDF://g")
		wget -t 5 -T 3 "$HN_WSNAME_REMOTE_RDF" -O  $WINROLL_CONF_ROOT/hosts.rem.conf 2> /dev/null
		
		[ "$?" = 0 ] && mv $WINROLL_CONF_ROOT/hosts.rem.conf $WINROLL_CONF_ROOT/hosts.conf
		# system would use hosts.conf that be left last time if failed to get remote config file
		
		# convert  to Winodws format
		HN_WSNAME_LOCAL_RDF="$(cygpath -w $WINROLL_CONF_ROOT/hosts.conf)"
		HN_WSNAME_PARAM=$(echo $HN_WSNAME_PARAM | sed -e "s|$(echo ${HN_WSNAME_REMOTE_RDF})|$(echo ${HN_WSNAME_LOCAL_RDF} | sed 's|\\|\\\\|g')|")
	elif [  -n "$(echo $CONFIG_NETWORK_MODE | grep -ie '^/RDF:tftp://' 2> /dev/null )" ] ; then
		tftp get "$CLIENT_MAC_NETWORK_Winpath" 2> /dev/null
		
		[ "$?" = 0 ] && mv $WINROLL_CONF_ROOT/hosts.rem.conf $WINROLL_CONF_ROOT/hosts.conf
		# system would use hosts.conf that be left last time if failed to get remote config file
		
		# convert to Winodws format
		HN_WSNAME_LOCAL_RDF="$(cygpath -w $WINROLL_CONF_ROOT/hosts.conf)"
		HN_WSNAME_PARAM=$(echo $HN_WSNAME_PARAM | sed -e "s/$HN_WSNAME_REMOTE_RDF/$HN_WSNAME_LOCAL_RDF/")
	fi
	
	rm -f $WINROLL_CONF_ROOT/hosts.rem.conf
	
	[ ! -f "$WSNAME_LOG" ] && touch $WSNAME_LOG;
	if [ -z "$HN_WSNAME_PARAM" ] ; then	HN_WSNAME_PARAM=$HN_WSNAME_DEF_PARAM; fi
	echo "" > $WSNAME_LOG		# Clean advanced log
	echo "'$HN_WSNAME_DEF_PARAM','$WSNAME_LOG','$HN_WSNAME_PARAM','$HNAME'" #| tee -a  $WINROLL_LOG
	#read
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
		NEED_TO_CHANGE=0
		wsname.exe $HN_WSNAME_DEF_PARAM
		WS_RETURN_CODE=$(tail -n 1 $WSNAME_LOG | tr -d "\r")
		# if use $IP as default, but client can't get a release IP .!! It's a special case
		if [ -n "$(echo $WS_RETURN_CODE | grep -e 'Exit code 4' 2> /dev/null )" ] ; then
			NEED_TO_CHANGE=0
			echo "No ip release ,Please check $HN_WSNAME_PARAM for more detail !!";
		elif [ -n "$(echo $WS_RETURN_CODE | grep -e 'Exit code 7' 2> /dev/null )" ] ; then
			NEED_TO_CHANGE=0
		elif [ -n "$(echo $WS_RETURN_CODE | grep -e ' reboot ' 2> /dev/null )" ] ; then
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
		#NM="$(ipconfig | dos2unix | awk -F ":" "\$2 ~/ [0-9]+.[0-9]+.[0-9]+.[0-9]+$/ {print \$2}" | sed -e 's/\s//g' | awk -F "." "\$1 == 255 {print \$0}"  | head -n 1 )"
		NM=$(awk -F "\t" "\$3 !~/^169.254/ && \$4 !~/^255.255.0.0,64$/  {print \$4}" $_NIC_INFO | awk -F ","  '{print $1}' | head -n 1)
		#IP="$(get_ip_str |awk -F. '{print $1+1000"-"$2+1000"-"$3+1000"-"$4+1000 }' | sed -e 's/^1//' -e 's/\-1/-/g' )"
		IP=$(awk -F "\t" "\$3 !~/^169.254/ && \$4 !~/^255.255.0.0,64$/  {print \$3}" $_NIC_INFO | awk -F ","  '{print $1}' | head -n 1)
		refine_IP=$(echo $IP |awk -F. '{print $1+1000"-"$2+1000"-"$3+1000"-"$4+1000 }' | sed -e 's/^1//' -e 's/\-1/-/g')

		#DNS_SUFF="$(ipconfig /all | grep "$_DNS_SEARCH_SUFFIX_KEYWORD" 2>/dev/null |head -n 1 | cut -d ":" -f 2 | cut -d "." -f 1,2 |sed -e "s/\./-/g" -e "s/\s*//g" )"
		_DNS_SUFFIX_REGISTRY_KeyList="HKEY_LOCAL_MACHINE/SYSTEM/CurrentControlSet/Services/Tcpip/Parameters/DhcpDomain HKEY_LOCAL_MACHINE/SYSTEM/CurrentControlSet/Services/Tcpip/Parameters/SearchList"
		_DNS_SUFFIX_REGISTRY_Value=
		
		for key in $_DNS_SUFFIX_REGISTRY_KeyList ; do 
			[ -n "$(cat /proc/registry/$key 2>/dev/null)" ] && _DNS_SUFFIX_REGISTRY_Value="$(cat /proc/registry/$key |cut -d "," -f 1)" && break;
		done
		# use first 2 strings as dns suffix name
		[ -n "$_DNS_SUFFIX_REGISTRY_Value" ] && DNS_SUFF="$(echo $_DNS_SUFFIX_REGISTRY_Value | awk -F '.' '{ printf "%s.%s",$1,$2}' )"
		
		if [ "$NM" = "255.255.255.0" ] ;then
			NM_STR=$(echo $refine_IP| cut -d "-" -f 3)
		else
			NM_STR=$(echo $refine_IP| cut -d "-" -f 2,3)
		fi
		
		WG_STR=$(echo $WG_WSNAME_PARAM | sed -e "s/\$DNS_SUFFIX/$DNS_SUFF/g" -e "s/\$NM/$NM_STR/g" -e 's/\s//g')

		echo "WG_STR='$WG_STR', NM=$NM, _DNS_SUFFIX_REGISTRY_Value=$_DNS_SUFFIX_REGISTRY_Value "
		
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
	echo "do fix_usersid_restart_sshd" 

	cygrunsrv -Q sshd 
	if [ "$?" -eq "0" ]; then
		cygrunsrv -E sshd
		priv_sshd_user=$(cygrunsrv.exe -V -Q sshd | grep -e "^Account" | awk -F ":" '{print $2}' | sed -e "s/\.\\\//" -e "s/ //")
		#echo "chown $priv_sshd_user.$_GID_Administrators /etc/ssh*"
		# $priv_sshd_user is an knew issue in XP edition 
		chown $priv_sshd_user.$_GID_Administrators /etc/ssh*
		chmod 644 /var/log/sshd.log /etc/ssh_host*_key.pub /etc/sshd_config
		chmod 600 /etc/ssh_host*_key
		chmod 750 /etc/ssh_config
		echo "Restart sshd service ..."
		cygrunsrv -S sshd
	fi
	rm -rf "$WINROLL_TMP/$FIX_SSHD_LOCKFILE"
}

do_autonewsid(){

	SID_MD5CHK_FILE="$WINROLL_CONF_ROOT/sid.md5"
	NICMAC_ADDR_MD5=""
	NEED_TO_CHANGE=0

	[ ! -f "$SID_MD5CHK_FILE" ] && touch $SID_MD5CHK_FILE;

	NICMAC_ADDR_MD5=$(awk -F "\t" "{print \$1}" $_NIC_INFO | head -n 1 | md5sum | awk '{print $1}' )
	NEED_TO_CHANGE=0

	if [ "$(cat $SID_MD5CHK_FILE)" != "$NICMAC_ADDR_MD5" ] ; then
		echo "Renew sid for: $NICMAC_ADDR_MD5 " 
		rm -rf $SID_MD5CHK_FILE;
		cygrunsrv -Q sshd 
		if [ "$?" -eq "0" ]; then
			echo "Stop sshd service ..."
			cygrunsrv -E sshd
		fi

		NEED_TO_CHANGE=1
		mv -f /etc/passwd /etc/passwd.old
		mv -f /etc/group /etc/group.old
		
		AUTONEWSID_PARAM="$(sed -e "s/\s*=\s*/=/g" $WINROLL_CONFIG | grep -e "^AUTONEWSID_PARAM=" | sed -e "s/^AUTONEWSID_PARAM=//" -e "s/(\s! )//g")"
		echo "Run: $AUTONEWSID_PARAM";
		`$AUTONEWSID_PARAM`
		while [ $(ps au| grep newsid | wc -l) -gt 0 ]
		do
			echo "Waiting for renew sid ..."
			sleep 10;
		done
		echo "$NICMAC_ADDR_MD5" > $SID_MD5CHK_FILE
		touch "$WINROLL_TMP/$FIX_SSHD_LOCKFILE"
	else
		echo "Sid already renewed in $NICMAC_ADDR_MD5, skip this !"
	fi
	

	if [ "$NEED_TO_CHANGE" = "1" ] ; then
		echo "chmod ug+rw $WINROLL_CONF_ROOT/*.conf"
		chmod ug+rw $WINROLL_CONF_ROOT/*.conf
		chmod ug+rx $WINROLL_LIBS
		NEED_TO_REBOOT=1
		echo `date` "AUTONEWSID need to reboot :" 
	fi

}

do_add2ad(){

	ADD2AD_MD5CHK_FILE="$WINROLL_CONF_ROOT/add2ad.md5"
	ADD2AD_RUN_FILE="$WINROLL_CONF_ROOT/add2ad.bat"
	NICMAC_ADDR_MD5=""
	
	if [ "$NEED_TO_REBOOT" = "1" ]; then
		return;
	fi

	[ ! -f "$ADD2AD_MD5CHK_FILE" ] && touch $ADD2AD_MD5CHK_FILE;

	NICMAC_ADDR_MD5=$(awk -F "\t" "{print \$1}" $_NIC_INFO | head -n 1 | md5sum | awk '{print $1}' )
	NEED_TO_CHANGE=0

	echo $NICMAC_ADDR_MD5 

	if [ "$(cat $ADD2AD_MD5CHK_FILE)" != "$NICMAC_ADDR_MD5" ] ; then
		echo "Add pc to add server : $NICMAC_ADDR_MD5 " 
		rm -rf $ADD2AD_MD5CHK_FILE;
		
		ADD2AD_RUN_FILE="$(sed -e "s/\s*=\s*/=/g" $WINROLL_CONFIG | grep -e "^ADD2AD_RUN_FILE=" | sed -e "s/^ADD2AD_RUN_FILE=//" -e "s/(\s! )//g")"

		echo "Run : $WINROLL_CONF_ROOT/$ADD2AD_RUN_FILE";
		$WINROLL_CONF_ROOT/$ADD2AD_RUN_FILE

		if [ "$?" = 0 ] ; then
			rm -rf $WINROLL_CONF_ROOT/$ADD2AD_RUN_FILE
			echo $NICMAC_ADDR_MD5 >$ADD2AD_MD5CHK_FILE
			NEED_TO_CHANGE=0
			echo `date` "ADD2AD need to reboot :"
		fi
	fi
}

#######################
# Main function
#######################
[ -f "/etc/passwd" ] || mkpasswd -l >/etc/passwd
[ -f "/etc/group" ] || mkgroup -l >/etc/group

check_if_root_and_envi

# for fix sshd service 
FIX_SSHD_LOCKFILE=fixsshd.lock
[ -f "$WINROLL_TMP/$FIX_SSHD_LOCKFILE" ] && fix_usersid_restart_sshd

[ -f "$WINROLL_REMOTE_MASTER" ] && get_remote_master_conf

do_config_network;

IF_AUTOHOSTNAME_SERVICE="$(sed -e "s/\s*=\s*/=/g" $WINROLL_CONFIG | grep -e "^IF_AUTOHOSTNAME_SERVICE=" | sed -e "s/^IF_AUTOHOSTNAME_SERVICE=//" -e "s/(\s! )//g")"
[ "$IF_AUTOHOSTNAME_SERVICE" = "y" ] && do_autohostname;

IF_NEWSID_SERVICE=$(sed -e "s/\s*=\s*/=/g" $WINROLL_CONFIG | grep -e "^IF_NEWSID_SERVICE=" | sed -e "s/^IF_NEWSID_SERVICE=//" -e "s/(\s! )//g")
[ "$IF_NEWSID_SERVICE" = "y" ] && do_autonewsid;

IF_ADD2AD_SERVICE=$(sed -e "s/\s*=\s*/=/g" $WINROLL_CONFIG | grep -e "^IF_ADD2AD_SERVICE=" | sed -e "s/^IF_ADD2AD_SERVICE=//" -e "s/(\s! )//g")
[ "$IF_ADD2AD_SERVICE" = "y" ] && do_add2ad;


# Delete remote config before to unlock service
[ -f "$WINROLL_REMOTE_MAIN_CONFIG" ] &&  rm -f  $WINROLL_REMOTE_MAIN_CONFIG 
#Unlock the service
rm -rf  $WINROLL_TMP/$LOCKFILE;
echo `date` "$SERVICE_NAME: unlock:" 

# Check if any service be lock, perpare to reboot, 
if [ "$NEED_TO_REBOOT" = "1" ]; then
	# touch $WINROLL_TMP/$REBOOT_FLAG;
	echo `date` "$SERVICE_NAME: set rboot flag:" 
	chmod +x /bin/shutdown
	/bin/shutdown -r 10;
	[ "$?" != 0 ] && ( ls -al /bin/shutdown ; echo "reboot fail !!")
fi


