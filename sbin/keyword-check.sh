###########################################################################
#  drbl-winroll service
#
# License: GPL
# Author	: Ceasar Sun Chen-kai <ceasar@nchc.org.tw> 
# Purpose	: Check if get_nic_info.vbs can get correct information of network interface
#
# Usage:  %CYGWIN_ROOT%\bin\autohostname.sh -e "CYGWIN=${_cygwin}"
#
###########################################################################

WINROLL_LIBS="/drbl_winroll-config/winroll.lib.sh"
for lib in $WINROLL_LIBS ; do 
	[ -f "$lib" ] && . $lib
done
WINROLL_LIBS="/drbl_winroll-config/winroll.lib.sh"
for lib in $WINROLL_LIBS ; do 
	[ -f "$lib" ] && . $lib
done

_NIC_INFO=$WINROLL_TMP/_nic_info.conf
cscript //nologo `cygpath.exe -w /bin/get_nic_info.vbs` > $_NIC_INFO


