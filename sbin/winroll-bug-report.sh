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
#WINROLL_CONFIG="/drbl_winRoll-config/winRoll.txt"
WINROLL_FUNCTIONS="/drbl_winRoll-config/winroll-functions.sh"
. $WINROLL_FUNCTIONS

# Local service paremeter 
SERVICE_NAME='winrollsrv'

report_tmpdir=$(mktemp -d --tmpdir=/tmp winroll-bug-report.XXXXXX)

echo "Copy relative configuration files ..."
cp -a $WINROLL_CONF_ROOT $report_tmpdir
echo "Copy relative logs ..."
cp -a $WINROLL_TMP $report_tmpdir
echo "Get pc informations by 'set' ..."
echo "Get Windows ProductName from registry"
touch $report_tmpdir/pc-info.txt
echo "cat /proc/registry/HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows\ NT/CurrentVersion/ProductName" >> $report_tmpdir/pc-info.txt
cat /proc/registry/HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows\ NT/CurrentVersion/ProductName >> $report_tmpdir/pc-info.txt
echo "cat /proc/registry/HKEY_CURRENT_USER/Control\ Panel/International/Locale" >> $report_tmpdir/pc-info.txt
cat /proc/registry/HKEY_CURRENT_USER/Control\ Panel/International/Locale >> $report_tmpdir/pc-info.txt
set >> $report_tmpdir/pc-info.txt
cd `dirname $report_tmpdir`; zip -r -q `basename $report_tmpdir`.zip `basename $report_tmpdir`; mv `basename $report_tmpdir`.zip  /winroll-bug-report.`date +%Y%m%d`.zip
rm -rf $report_tmpdir
echo "================================================="
echo "Your bug report file is here: c:\cygwin\winroll-bug-report."`date +%Y%m%d`".zip"
echo "Please attach it and your problem description to ceasar@nchc.org.tw"
echo "================================================="
echo "Press 'Enter' to exit !!"
read
