###########################################################################
#  drbl-winroll service
#
# License: GPL
# Author	: Ceasar Sun Chen-kai <ceasar@nchc.org.tw> 
# Purpose	: Check if keyword config be match your system locale
# Date	: 2010/08/02
#
# Usage:  %CYGWIN_ROOT%\bin\autohostname.sh -e "CYGWIN=${_cygwin}"
#
###########################################################################

WINROLL_LIBS="/drbl_winroll-config/winroll.lib.sh"
for lib in $WINROLL_LIBS ; do 
	[ -f "$lib" ] && . $lib
done


DEFAULT_DEVICE_KEYWORD_CONF="$WINROLL_CONF_ROOT/keyword-conf/_legacy/_default.conf"
	
OS_VERSION=$(detect_win_version)
LOCALEID=$(detect_locale_code)

if [ "$OS_VERSION" == "win2000" ] || [ "$OS_VERSION" == "xp" ] || [ "$OS_VERSION" == "win2003" ]; then
	OS_KEYWORD_CONF=_legacy
else
	OS_KEYWORD_CONF=$OS_VERSION
fi 

if [ -e  $WINROLL_CONF_ROOT/keyword-conf/$OS_KEYWORD_CONF/$LOCALEID.conf ] ; then
	. $WINROLL_CONF_ROOT/keyword-conf/$OS_KEYWORD_CONF/$LOCALEID.conf
else
	echo "No match keyword for your OS:$OS_VERSION and locale code in path :$WINROLL_CONF_ROOT/keyword-conf/$OS_KEYWORD_CONF/$LOCALEID.conf"
	echo "use $DEFAULT_DEVICE_KEYWORD_CONF as default keyword"
	. $DEFAULT_DEVICE_KEYWORD_CONF
fi 

_devname_str=$(ipconfig /all | grep "$_Ethernet_Adapter_KEYWORD"| dos2unix |  sed -e "s/$_Ethernet_Adapter_KEYWORD//g" )
for ((i=1;i<`echo ${_devname_str} | awk -F ":" '{print NF}'`;i++)) ; do
	_devname="$(echo $_devname_str | awk -F ":" '{print $'$i'}' | sed -e 's/^\s*//g')"
	line_nm_rev=$(ipconfig /all | tac | grep -n "$devname"| head -n 1 | awk -F ":" '{print $1}')
	this_ip=$(ipconfig /all | tac | head -n $line_nm_rev | grep "$_IPV4_ADDRESS_KEYWORDD"| head -n 1| dos2unix | awk -F ":" '{print $2}'| sed -e "s/\s*//g")
	echo "Get NIC name:'$_devname' and its ip address :'$this_ip'"
done


