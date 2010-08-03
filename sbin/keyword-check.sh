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

echo "OS verion: '$OS_VERSION', Locale number: '$LOCALEID'"
echo "Use keyword config: '$WINROLL_CONF_ROOT/keyword-conf/$OS_KEYWORD_CONF/$LOCALEID.conf'"

_devname_str="$(get_nic_name_str)"
for ((i=1;i<`echo ${_devname_str} | awk -F ":" '{print NF}'`;i++)) ; do
	_devname="$(echo $_devname_str | awk -F ":" '{print $'$i'}' | sed -e 's/^\s*//g')"
	echo "Get NIC ->'$_devname'"
done

#_devname=$(get_nic_name_str "00-18-32-E7-D1-E1" |  sed -e "s/:$//g" )
#echo "Get by mca:00-18-32-E7-D1-E1 ->'$_devname'"

_ip_str=$(get_ip_str)
for ip in $_ip_str ; do
	echo "Extarct IP: '$ip'";
done

get_ip_str | head -n 1 | cut -d ":" -f 2 | sed -e "s/\s*//g" |awk -F. '{print $1+1000"-"$2+1000"-"$3+1000"-"$4+1000 }' | sed -e 's/^1//' -e 's/\-1/-/g'		


