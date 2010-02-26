@echo off

REM ####################################################################
REM # Unattended drbl-winRoll installation
REM #
REM # License: GPL
REM # Author	: Ceasar Sun Chen-kai <ceasar@nchc.org.tw>
REM # Last update	: 2007/3/5
REM #
REM # Usage: winroll-setup.bat
REM #
REM # References:
REM # [1] Henrik Bengtsson, Unattended Cygwin Installation, June 2, 2004.
REM #     http://www.maths.lth.se/help/windows/cygwin/
REM # [2] DRBL FAQ
REM #     http://drbl.nchc.org.tw/faq/index.php#path=./1_DRBL_common&entry=10_change_MS_hostname.faq
REM # [3] DRBL : Note for drbl4win, Dec. 2005.
REM #     http://www.ceasar.tw/modules/news/article.php?storyid=98
REM ####################################################################

REM # identify your OS language 
REM set ENG_OS_PATH=%USERPROFILE%\Desktop
REM set ZHTW_OS_PATH=%USERPROFILE%\桌面
set FR_OS_PATH=%USERPROFILE%\Bureau
set NL_OS_PATH=%USERPROFILE%\Bureaublad

REM # Global parameter
set LANG=
set OS_VERSION=
set SOURCE_DIR=%cd%
set ACTION=i
set CYGWIN_ROOT=
set SERVICE_ACCOUNT_NAME=LocalSystem
set SERVICE_ACCOUNT_PW=
set OS_VERSION=
set WINROLL_SERVICE=winrollsrv
set AUTOHOSTNAME_SERVICE=autohostname
set AUTONEWSID_SERVICE=autonewsid
set IF_NEWSID_SERVICE=n
set IF_AUTOHOSTNAME_SERVICE=n
set SSHD_SERVICE=sshd
set SSHD_SERVER_PW=1qaz2wsx
REM # Define ROOT_NAME atfer include language file
set ROOT_NAME=
set INIT_CONF=conf
set WINROLL_LOCAL_BACKUP=%USERPROFILE%\drbl-winroll.bak

set SYSINT_LINCESE_URL=http://www.sysinternals.com/Licensing.html
set SYSINT_LINCESE_URL=http://drbl.nchc.org.tw/drbl-winroll/download/newsid-licence.php
set NEWSID_DOWNLOAD_URL=http://drbl.nchc.org.tw/drbl-winroll/download/newsid-download.php

set CYGWIN_ROOT=%SystemDrive%\cygwin
set CYGWIN_LOCAL_MIRROR=
set LOCAL_REPOSITORY=%SOURCE_DIR%
set INIT_CONFIG_FILE=%INIT_CONF%\winroll.conf
set INIT_HOSTS_FILE=%INIT_CONF%\hosts.conf
set INIT_CLIENT_MAC_NETWORK_FILE=%INIT_CONF%\client-mac-network.conf
set INIT_FUNCTIONS_FILE=%INIT_CONF%\winroll-functions.sh
rem set INIT_KEYWORD_CONF=%INIT_CONF%\keyword-conf
set INIT_DOC_FOLDER=doc

call :CHECK_OS_VERSION
call :SET_LANGUAGE
set ROOT_NAME=%ADMIN%
cls
call :PRINTHEAD
echo %YOUR_OS_VERSION_IS% :"%OS_VERSION%"
echo %YOUR_LANGUAGE_IS% : %LANGUAGE_DESC%

call :CHECK_IF_WINADMIN

REM call :CHECK_CYGWIN_ARGUMENTS

set WINROLL_CONFIG_FOLDER=%CYGWIN_ROOT%\drbl_winroll-config
set WINROLL_CONFIG_FILE=%WINROLL_CONFIG_FOLDER%\winroll.conf
set WINROLL_FUNCTIONS_FILE=%WINROLL_CONFIG_FOLDER%\winroll-functions.sh
set WINROLL_HOSTS_FILE=%WINROLL_CONFIG_FOLDER%\hosts.conf
set WINROLL_CLIENT_MAC_NETWORK_FILE=%WINROLL_CONFIG_FOLDER%\client-mac-network.conf
set WINROLL_DOC_FOLDER=%CYGWIN_ROOT%\drbl_winroll-doc
set WINROLL_UNINSTALL_FOLDER=%WINROLL_CONFIG_FOLDER%\uninstall
set WINROLL_UNINSTALL_PARA=drbl_winroll-uninstall-para.cmd
set WINROLL_SETUP_LOG=winroll-setup.log

IF EXIST "%CYGWIN_ROOT%" (
	IF NOT EXIST "%WINROLL_LOCAL_BACKUP%" (
		echo mkdir "%WINROLL_LOCAL_BACKUP%"
		mkdir "%WINROLL_LOCAL_BACKUP%"
	)
	call :CHECK_ACTION
) ELSE (
	set ACTION=i
)

call :CREAT_SETUP_LOG

if "%ACTION%" == "i" (
	call :DRBL-WINROLL_INSTALL
	call .\doc\Faq.%LANG%.txt
)
if "%ACTION%" == "f" (
	call :DRBL-WINROLL_INSTALL
	call .\doc\Faq.%LANG%.txt
)
if "%ACTION%" == "r" (
	call :DRBL-WINROLL_REINSTALL
	call .\doc\Faq.%LANG%.txt
)
if "%ACTION%" == "u" (
	call :DRBL-WINROLL_UNINSTALL
	call .\doc\Faq.%LANG%.txt
)

if  "%IF_NEWSID_SERVICE%" == "y" (
	call :STARTUP_AUTONEWSID
)

goto :EOF
REM #####################################
REM # Sub function
REM #####################################
:CHECK_OS_VERSION
	set OS_VERSION=NONE
	
	reg QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v  ProductName | find "2000" >OS-version.txt
	if "%ERRORLEVEL%" == "0" (
		set OS_VERSION=WIN2000
		goto :END_OF_CHECK_OS_VERSION
	)

	reg QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v  ProductName | find "XP" >OS-version.txt
	if "%ERRORLEVEL%" == "0" (
		set OS_VERSION=WINXP
		goto :END_OF_CHECK_OS_VERSION
	)

	reg QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v  ProductName | find "2003" >OS-version.txt
	if "%ERRORLEVEL%" == "0"  (
		set OS_VERSION=WIN2003
		goto :END_OF_CHECK_OS_VERSION
	)

	reg QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v  ProductName | find "2008" >OS-version.txt
	if "%ERRORLEVEL%" == "0"  (
		set OS_VERSION=WIN2008
		goto :END_OF_CHECK_OS_VERSION
	)

	reg QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v  ProductName | find "Vista" >OS-version.txt
	if "%ERRORLEVEL%" == "0"  (
		set OS_VERSION=Vista
		set STARTMENU_PATH=%ALLUSERSPROFILE%\Start Menu\Programs\Cygwin
		goto :END_OF_CHECK_OS_VERSION
	)

	reg QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v  ProductName | find "Windows 7" >OS-version.txt
	if "%ERRORLEVEL%" == "0"  (
		set OS_VERSION=WIN7
		set STARTMENU_PATH=%ALLUSERSPROFILE%\Start Menu\Programs\Cygwin
		goto :END_OF_CHECK_OS_VERSION
	)

	REM # Just in case for Windows 2000 
	if "%SystemRoot%" == "C:\WINNT" (
		set OS_VERSION=WIN2000
		goto :END_OF_CHECK_OS_VERSION
	)

	if "%OS_VERSION%" == "NONE" (
		echo .
		echo !!! Unknow your OS version ... !!!
		echo !!! Please attach "OS-version.txt" file at installation folder and mail to "ceasar@nchc.org.tw" to call for support !!!
		reg QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v  ProductName >OS-version.txt
		echo !!! Program EXIT !!!
		pause
		exit 1
		goto :EOF
	)
	:END_OF_CHECK_OS_VERSION
goto :EOF

REM # To decide language during installation
:SET_LANGUAGE
	set LANG=0
	
	REM # Just in case for Win 2000, because it has no reg command to use 
	if "%OS_VERSION%" == "WIN2000" (
		set set LANG=en
		goto :BEFORE_OF_CALL_LANGUAGE
	)
	
	REM ### For zh_TW 
	reg QUERY "HKEY_CURRENT_USER\Control Panel\International" /v Locale | find "00000404" > Locale.txt
	IF "%ERRORLEVEL%" == "0" (
		set LANG=tc
		goto :BEFORE_OF_CALL_LANGUAGE
	)
	REM # IF EXIST "%ZHTW_OS_PATH%" (
	REM #   set LANG=tc
	REM #   goto :BEFORE_OF_CALL_LANGUAGE
	REM #)
	
	REM ### For English
	reg QUERY "HKEY_CURRENT_USER\Control Panel\International" /v Locale | find "00000409" > Locale.txt
	IF "%ERRORLEVEL%" == "0" (
		set LANG=en
		goto :BEFORE_OF_CALL_LANGUAGE
	)

	REM ### A sample for other language
	REM reg QUERY "HKEY_CURRENT_USER\Control Panel\International" /v Locale | find "0000040x" > Locale.txt
	REM IF "%ERRORLEVEL%" == "0" (
	REM 	set LANG=xxx
	REM 	goto :BEFORE_OF_CALL_LANGUAGE
	REM )

	IF EXIST "%FR_OS_PATH%" (
		set LANG=fr
		goto :BEFORE_OF_CALL_LANGUAGE
	)
	IF EXIST "%NL_OS_PATH%" (
		set LANG=nl
		goto :BEFORE_OF_CALL_LANGUAGE
	)
  
	IF "%LANG%" == "0" (
		set LANG=unknow
		echo *** Warning !! ****
		echo !! Your currnet language not be supported complete yet,
		echo !! But you still can install it under this release.
		echo !! Let me know if any problem. Email :ceasar@nchc.org.tw !!
		echo .
		echo !! [Ctrl+C] to exit, any key to continue.
		pause
	)
	:BEFORE_OF_CALL_LANGUAGE

	CALL lang\%LANG%.cmd
	
	REM # to setup STARTMENU_PATH for special windows version
	if "%OS_VERSION%" == "Vista"  (
		set STARTMENU_PATH=%ALLUSERSPROFILE%\Start Menu\Programs\Cygwin
	)
	if "%OS_VERSION%" == "WIN2008"  (
		set STARTMENU_PATH=%ALLUSERSPROFILE%\Start Menu\Programs\Cygwin
	)
	if "%OS_VERSION%" == "WIN7"  (
		set STARTMENU_PATH=%ALLUSERSPROFILE%\Start Menu\Programs\Cygwin
	)

	:END_OF_SET_LANGUAGE
goto :EOF

:PRINTHEAD
	echo  %HEAD01%
	echo  %HEAD02%
	echo  %HEAD03%
	echo  %HEAD04%
	echo  %HEAD05%
	echo  %HEAD06%
	echo  %HEAD07%
	echo  %HEAD08%
	echo  %HEAD09%
	echo  %HEAD10%
	echo  %HEAD11%
	echo  %HEAD12%
	echo  %HEAD13%
	echo  %HEAD14%
	echo  %HEAD15%
goto :EOF

:CREAT_SETUP_LOG
	date /T >%WINROLL_SETUP_LOG%
	echo LANG=%LANG%>>%WINROLL_SETUP_LOG%
	echo OS_VERSION=%OS_VERSION%>>%WINROLL_SETUP_LOG%
	echo SURCE_DIR=%cd%>>%WINROLL_SETUP_LOG%
	echo ACTION=%ACTION%>>%WINROLL_SETUP_LOG%
	echo CYGWIN_ROOT=%CYGWIN_ROOT%>>%WINROLL_SETUP_LOG%
	echo SERVICE_ACCOUNT_NAME=%SERVICE_ACCOUNT_NAME%>>%WINROLL_SETUP_LOG%
	echo SERVICE_ACCOUNT_PW=%SERVICE_ACCOUNT_PW%>>%WINROLL_SETUP_LOG%
	echo OS_VERSION=%OS_VERSION%>>%WINROLL_SETUP_LOG%>>%WINROLL_SETUP_LOG%
	echo AUTOHOSTNAME_SERVICE=%AUTOHOSTNAME_SERVICE%>>%WINROLL_SETUP_LOG%
	echo AUTONEWSID_SERVICE=%AUTONEWSID_SERVICE%>>%WINROLL_SETUP_LOG%
	echo SSHD_SERVICE=%SSHD_SERVICE%>>%WINROLL_SETUP_LOG%
	echo USERNAME=%USERNAME%>>%WINROLL_SETUP_LOG%
	echo INIT_CONF=%INIT_CONF%>>%WINROLL_SETUP_LOG%
	echo SYSINT_LINCESE_URL=%SYSINT_LINCESE_URL%>>%WINROLL_SETUP_LOG%
	echo NEWSID_DOWNLOAD_URL=%NEWSID_DOWNLOAD_URL%>>%WINROLL_SETUP_LOG%
	echo CYGWIN_ROOT=%CYGWIN_ROOT%>>%WINROLL_SETUP_LOG%
	echo LOCAL_REPOSITORY=%LOCAL_REPOSITORY%>>%WINROLL_SETUP_LOG%
	echo INIT_DOC_FOLDER=%INIT_DOC_FOLDER%>>%WINROLL_SETUP_LOG%
goto :EOF

:CHECK_IF_WINADMIN
	echo %YOUR_CURRENT_ACCOUNT_IS% : "%USERNAME%"
	IF "%USERNAME%" == "%ROOT_NAME%" (
	 REM Dummy line
	) ELSE (
	  echo .
	  echo %PLZ_CONFIRM_ADMIN_ACCOUNT%
	  echo !!! %IF_KEEP_GO%
	  pause
	)

goto :EOF

:CHECK_ACTION
	echo .
	echo ... DRBL-winRoll %INSTALLED% %PLZ_CHOOSE% ...
	
	set ACTION=u
	echo [r]: %REINSTALL%
	echo [u]: %UNINSTALL%
	echo [f]: %FORCE_INSTALL%
	set /P ANSWER="[u] "

	if "%ANSWER%" == "r" (
		set ACTION=r
	)
	if "%ANSWER%" == "f" (
		set ACTION=f
	
	)

goto :EOF

:CYGWIN_INSTALL
	echo %HR%
	echo %NEXT_STEP% :  %INSTALL% Cygwin
	echo %HR%
	REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	REM Debug information
	REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	echo CYGWIN %INSTALL% %DIRECTORY% ='%CYGWIN_ROOT%'
	echo %LOCAL_REPOSITORY_DIRECTORY%='%LOCAL_REPOSITORY%'

	REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	REM Assert that there exists a valid %LOCAL_REPOSITORY% directory.
	REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	IF NOT EXIST "%LOCAL_REPOSITORY%" (
	  echo %ERR_REP_DONT_EXIST% %LOCAL_REPOSITORY%
	  exit /B 1
	)
	IF NOT EXIST "%LOCAL_REPOSITORY%\cygwin_mirror" (
	  echo %ERR_DIR_DONT_EXIST% %LOCAL_REPOSITORY%\cygwin_mirror\
	  exit /B 1
	)
	IF NOT EXIST "%LOCAL_REPOSITORY%\cygwin_mirror\release" (
	  echo %ERR_DIR_DONT_EXIST% %LOCAL_REPOSITORY%\cygwin_mirror\release\
	  exit /B 1
	)
	IF NOT EXIST "%LOCAL_REPOSITORY%\cygwin_mirror\setup.ini" (
	  echo %ERR_FIL_DONT_EXIST% %LOCAL_REPOSITORY%\cygwin_mirror\setup.ini
	  exit /B 1
	)
	REM Find Cygwin's setup.exe
	set CYGWIN_SETUP=%LOCAL_REPOSITORY%\cygwin_mirror\cyg-setup.exe
	IF NOT EXIST "%LOCAL_REPOSITORY%\cygwin_mirror\cyg-setup.exe" (
		echo %ERR_CYGWIN_SETUP_DONT_EXIST% %LOCAL_REPOSITORY%\cygwin_mirror\
	    exit /B 1
	)

	REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	REM Create a fake installation skeleton for Cygwin setup
	REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	IF NOT EXIST "%CYGWIN_ROOT%" (
	  mkdir "%CYGWIN_ROOT%"
	)

	IF NOT EXIST "%CYGWIN_ROOT%\etc\setup" (
	  mkdir "%CYGWIN_ROOT%\etc\setup"
	) ELSE (
	  del /Q "%CYGWIN_ROOT%\etc\setup\last-*"
	)

	REM -- Note that last-* must *not* containing whitespace, e.g. " " etc. 
	REM -- This is why there below is no space in front of ">".
	echo Install> "%CYGWIN_ROOT%\etc\setup\last-action"
	echo %LOCAL_REPOSITORY%> "%CYGWIN_ROOT%\etc\setup\last-cache"
	echo cygwin_mirror> "%CYGWIN_ROOT%\etc\setup\last-mirror"

	REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	REM Finally, run Cygwin setup quietly
	REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	echo .
	echo %START_TO% CYGWIN %AUTO_INSTALL% , %NO_ANY_ATTENDED% !!
	echo To run  %CYGWIN_SETUP% -q -d -L -l "%LOCAL_REPOSITORY%\cygwin_mirror" -R "%CYGWIN_ROOT%"
	echo .
	pause
	REM real do cygwin installation
	"%CYGWIN_SETUP%" -q -d -L -l "%LOCAL_REPOSITORY%\cygwin_mirror" -R "%CYGWIN_ROOT%"
	
	REM Create link files for cygwin program menu
	copy "%INIT_CONF%\*.lnk" "%STARTMENU_PATH%"
	REM "%CYGWIN_ROOT%\bin\ln.exe" STARTMENU_PATH-s "%CYGWIN_ROOT%\drbl_winroll-config" "%STARTMENU_PATH%"
	REM echo %CYGWIN_ROOT%\bin\bash.exe --login -i %CYGWIN_ROOT%\bin\winrollsrv-controllor.sh > "%STARTMENU_PATH%\winrollsrv-controllor.bat"
	
	echo %CREATE_WINROLL_CONFIG%
	mkdir "%WINROLL_CONFIG_FOLDER%" "%WINROLL_DOC_FOLDER%" "%WINROLL_UNINSTALL_FOLDER%" "%WINROLL_CONFIG_FOLDER%\keyword-conf"
	copy "%INIT_CONFIG_FILE%" "%WINROLL_CONFIG_FOLDER%"
	xcopy /E "%INIT_CONF%\keyword-conf" "%WINROLL_CONFIG_FOLDER%\keyword-conf"
	copy "%INIT_HOSTS_FILE%" "%WINROLL_CONFIG_FOLDER%"
	copy "%INIT_CLIENT_MAC_NETWORK_FILE%" "%WINROLL_CONFIG_FOLDER%"

	copy "%INIT_FUNCTIONS_FILE%" "%WINROLL_CONFIG_FOLDER%"
	xcopy /E "%INIT_DOC_FOLDER%" "%WINROLL_DOC_FOLDER%"
	copy ".\sbin\*.*" "%CYGWIN_ROOT%\bin"

	copy "%INIT_CONF%\*.reg" "%WINROLL_UNINSTALL_FOLDER%"
	copy "%INIT_CONF%\drbl_winroll-uninstall.bat" "%APPDATA%"

	REM # copy language file for uninstall usage
	copy "lang\%LANG%.cmd" "%APPDATA%\%WINROLL_UNINSTALL_PARA%"
	REM echo @echo off>"%APPDATA%\%WINROLL_UNINSTALL_PARA%"
	REM echo set STARTMENU_PATH=%STARTMENU_PATH%>>"%APPDATA%\%WINROLL_UNINSTALL_PARA%"
	REM echo set SYSTEM_ADMIN=%ADMIN%>>"%APPDATA%\%WINROLL_UNINSTALL_PARA%"
	echo. >>"%APPDATA%\%WINROLL_UNINSTALL_PARA%"
	echo set CYGWIN_ROOT=%CYGWIN_ROOT%>>"%APPDATA%\%WINROLL_UNINSTALL_PARA%"
	echo set STARTMENU_PATH=%STARTMENU_PATH%>>"%APPDATA%\%WINROLL_UNINSTALL_PARA%"

	REM Add cygwin binary path into current path
	set PATH=%CYGWIN_ROOT%\bin;%PATH%
	
	echo ... %INSTALL_WINROLL_SERVICE% ...
	"%CYGWIN_ROOT%\bin\cygrunsrv.exe" -I "%WINROLL_SERVICE%" -d "DRBL-winroll auto-config service" -p "%CYGWIN_ROOT%\bin\winrollsrv.sh" -e "CYGWIN=${_cygwin}" -i
goto :EOF

:CYGWIN_UNINSTALL
	echo %HR%
	echo %NEXT_STEP% : %UNINSTALL% Cygwin
	echo %HR%
	REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	REM Debug information
	REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	echo !!! %WARNING% : %START_TO% %REMOVE%  CYGWIN : '%CYGWIN_ROOT%' (CYGWIN_ROOT) !!!
	echo .
	echo CYGWIN %INSTALL%%DIRECTORY% ='%CYGWIN_ROOT%'
	echo %LOCAL_REPOSITORY_DIRECTORY%='%LOCAL_REPOSITORY%'

	echo ... %REMOV_WINROLL_SERVICE% ...
	%CYGWIN_ROOT%\bin\cygrunsrv.exe -E %WINROLL_SERVICE%
	%CYGWIN_ROOT%\bin\cygrunsrv.exe -R %WINROLL_SERVICE%
	
	echo %REMOVE_REGISTRY%
	regedit.exe /s .\%INIT_CONF%\UninstallCygwin.reg

	echo %REMOVE% CYGWIN %STARTMENU%
	rd /Q /S "%STARTMENU_PATH%"

	echo %REMOVE% CYGWIN %DIRECTORY%
	rd /Q /S "%CYGWIN_ROOT%"
goto :EOF

:AUTOHOSTNAME_SETUP
	echo %HR%
	echo %NEXT_STEP% : %SETUP_AUTOHOSTNAME_SERVICE%
	echo %HR%
	
	set ANSWER_IF_GO=y
	echo %IF_INSTALL_AUTOHOSTNAME% [Y/n]
	set /P ANSWER_IF_GO="[Y/n]"
	if "%ANSWER_IF_GO%" == "n" (
		goto :END_OF_AUTOHOSTNAME_SETUP
	)
	
	set HOSTNAME_PREFIX=PC
	echo .
	echo %Select_HOSTNAME_FORMAT% (%HOSTNAME_PREFIX%-XXX )
	echo .
	echo [1]%BY_IP%
	echo [2]%BY_MAC%
	echo [3]%BY_HOSTS_FILE% :%MORE_DETAIIL_TO_REFER% '%WINROLL_HOSTS_FILE%'
	set /P ANSWER="[1] "
	rem echo Hostname format is : %ANSWER%
	rem if not "%ANSWER%" == "2" ( if not "%ANSWER%" == "3"  echo =[1]: %BY_IP%  )
	rem if "%ANSWER%" == "2" ( echo =[2]: %BY_MAC% )
	rem if "%ANSWER%" == "3" ( echo =[3]: %BY_HOSTS_FILE% )
	
	if "%ANSWER%" == "3" (
		goto :SKIP_HN_PREFIX
	)
	echo %SET_HOSTNAME_PREFIX%
	set /P ANSWER_HOSTNAME_PREFIX="[%HOSTNAME_PREFIX%] "
	
	:SKIP_HN_PREFIX

	if NOT "%ANSWER_HOSTNAME_PREFIX%" == "" (
		set HOSTNAME_PREFIX=%ANSWER_HOSTNAME_PREFIX%
	)

	set WS_PARA=/N:%HOSTNAME_PREFIX%-$IP[7+]
	IF "%ANSWER%" == "2" (
		set WS_PARA=/N:%HOSTNAME_PREFIX%-$MAC
	)
	IF "%ANSWER%" == "3" (
		set WS_PARA=/RDF:%WINROLL_HOSTS_FILE% /DFK:$MAC
	)
	echo ** %SHOW_HOSTNAME_FORMAT% : %WS_PARA%
	
	REM # for workgroup
	set WG_PREFIX=
	set ANSWER_IF_GO='y'
	echo .
	echo %IF_INSTALL_AUTOWG%
	set /P ANSWER_IF_GO="[Y/n] "
	
	if "%ANSWER_IF_GO%" == "n" (
		goto :END_OF_AUTOGROUP_SETUP
	)

	rem set WG_PREFIX=$(nbtstat.exe -n | grep -E "<00>.+GROUP" | sed -r "s/\s+/ /g" | cut -d " " -f 2)
	set WG_PREFIX=WG
	set WG_PARA=
	if "%WG_PREFIX%" == "" (
		set WG_PREFIX=WG
	)
	set ANSWER=1
	echo %SELECT_WORKGROUP_FORMAT%
	echo .
	echo [1]: %FIXED%: [%WG_PREFIX%]
	echo [2]: IP/NETMASK: [%WG_PREFIX%-XXX]
	echo [3]: %DNS_SUFFIX%
	set /P ANSWER="[1] "

	rem if not "%ANSWER%" == "2" ( if not "%ANSWER%" == "3" ( set ANSWER=1  ) )
	rem if "%ANSWER%" == "1" ( echo =[1]: %FIXED% )
	rem if "%ANSWER%" == "2" ( echo =[2]: IP/NETMASK )
	rem if "%ANSWER%" == "3" ( echo =[3]: %DNS_SUFFIX% )
	
	if "%ANSWER%" == "3" (
		goto :SKIP_WG_PREFIX
	)

	echo %SET_WG_PREFIX%
	set /P ANSWER_WG_PREFIX="[%WG_PREFIX%] "
	if not "%ANSWER_WG_PREFIX%" == "" (
		set WG_PREFIX=%ANSWER_WG_PREFIX%
	)
	:SKIP_WG_PREFIX

	echo .
	REM if "%ANSWER%" == "1" ( set WG_PARA=%WG_PREFIX% )
	if "%ANSWER%" == "1" ( set WG_PARA=%WG_PREFIX% )
	if "%ANSWER%" == "2" ( set WG_PARA=%WG_PREFIX%-$NM )
	if "%ANSWER%" == "3" ( set WG_PARA=$DNS_SUFFIX )

	echo ** %SHOW_WORKGROUP_FORMAT% : %WG_PARA%
	
	:END_OF_AUTOGROUP_SETUP
	echo HN_WSNAME_PARAM = %WS_PARA%>> %WINROLL_CONFIG_FILE%
	echo WG_WSNAME_PARAM = %WG_PARA%>> %WINROLL_CONFIG_FILE%
	
	set IF_AUTOHOSTNAME_SERVICE=y
	echo .
	rem  20080520 後用 winrollsrv 取代
	rem echo ... %INSTALL_AUTOHOSTNAME_SERVICE% ...
	rem "%CYGWIN_ROOT%\bin\cygrunsrv.exe" -I "%AUTOHOSTNAME_SERVICE%" -d "Auto Hostname Checker" -p "%CYGWIN_ROOT%\bin\autohostname.sh" -e "CYGWIN=${_cygwin}" -u "LocalSystem" -w ""
	echo IF_AUTOHOSTNAME_SERVICE = %IF_AUTOHOSTNAME_SERVICE%>>%WINROLL_CONFIG_FILE%
	echo IF_AUTOHOSTNAME_SERVICE = %IF_AUTOHOSTNAME_SERVICE%>>%WINROLL_SETUP_LOG%
	:END_OF_AUTOHOSTNAME_SETUP
	goto :EOF

:AUTOHOSTNAME_REMOVE
	echo %HR%
	echo Step 2. %REMOV_AUTOHOSTNAME_SERVICE%
	echo %HR%

	echo .
	echo ... %REMOVE_NEEDED_FILES% ...

	del /F /Q %CYGWIN_ROOT%\bin\autohostname.sh
	del /F /Q %CYGWIN_ROOT%\bin\wsname.exe
	
	rem echo .
	rem  echo ... %REMOV_AUTOHOSTNAME_SERVICE% ...
	rem %CYGWIN_ROOT%\bin\cygrunsrv.exe -E %AUTOHOSTNAME_SERVICE%
	rem %CYGWIN_ROOT%\bin\cygrunsrv.exe -R %AUTOHOSTNAME_SERVICE%
		
goto :EOF

:NETWORK_MODE_SETUP
	rem echo ... %FORCE_TO_NIC_AS_DHCP% ...
	rem netsh -c interface ip set address name="%NIC_NAME%" source=dhcp

	echo %HR%
	echo %NEXT_STEP% : %SETUP_NETWORK_MODE%
	echo %HR%
		
	set ANSWER=1
	set NETWORK_MODE=dhcp
	echo %SELECT_NETWORK_MODE%
	echo [1]DHCP
	echo [2]%BY_FILE% : %MORE_DETAIIL_TO_REFER% '%WINROLL_CLIENT_MAC_NETWORK_FILE%'
	echo [3]%SKIP% (%DO_NOTHIMG_FOR_NETWORK%) 
	set /P ANSWER="[1] "

	if "%ANSWER%" == "2" ( set NETWORK_MODE=/RDF:%WINROLL_CLIENT_MAC_NETWORK_FILE% )
	if "%ANSWER%" == "3" ( set NETWORK_MODE=none )

	echo ** %USE_NETWORK_MODE_IS% : %NETWORK_MODE%
	echo CONFIG_NETWORK_MODE = %NETWORK_MODE%>>%WINROLL_CONFIG_FILE%
	
	if "%NETWORK_MODE%" == "dhcp" (
		echo . 
		echo ... %FORCE_TO_NIC_AS_DHCP% ...
		echo .
		netsh interface ip set address "%NIC_NAME%" source=dhcp
	)
	:END_OF_NETWORK_MODE_SETUP
goto :EOF

:NETWORK_MODE_REMOVE

	REM echo Do nothing
	REM netsh interface ip set address "%NIC_NAME%" source=dhcp
		
goto :EOF

:AUTONEWSID_SETUP
	echo %HR%
	echo %NEXT_STEP% : %SETUP_AUTONEWSID_SERVICE%
	echo %HR%
	
	set ANSWER_IF_GO=n
	echo %IF_INSTALL_AUTONEWSID% (Default: No)
	set /P ANSWER_IF_GO="[y/N]"
	if not "%ANSWER_IF_GO%" == "y" (
		goto :END_OF_AUTONEWSID_SETUP
	)

	echo %PLZ_READ_LICENSE%
	echo %SHOW_URL% : %SYSINT_LINCESE_URL%
	explorer %SYSINT_LINCESE_URL%
	echo .
	echo .
	pause
	
	set IF_AGREE=y
	echo %ANS_IF_AGREE%
	set /P IF_AGREE="[Y/n]"
	if "%IF_AGREE%" == "n" (
		echo %NOT_AGREE_EXIT%
		goto :END_OF_AUTONEWSID_SETUP
	)
	
	REM # Download newsid.zip from sysinternals.com
	%CYGWIN_ROOT%\bin\rm.exe -rf %TMP%\NewSid.zip %TMP%\newsid.exe %TMP%\Eula.txt
	%CYGWIN_ROOT%\bin\wget.exe %NEWSID_DOWNLOAD_URL% -P %TMP%
	%CYGWIN_ROOT%\bin\unzip.exe %TMP%\NewSid.zip -d %TMP%
	%CYGWIN_ROOT%\bin\mv.exe %TMP%\newsid.exe %CYGWIN_ROOT%\bin
	%CYGWIN_ROOT%\bin\chmod.exe +x %CYGWIN_ROOT%\bin\newsid.exe
	
	%CYGWIN_ROOT%\bin\rm.exe -rf %TMP%\NewSid.zip %TMP%\newsid.exe %TMP%\Eula.txt
	
	set IF_NEWSID_SERVICE=y
	echo ... %COPY_NEEDED_FILES% ...
	rem copy .\sbin\autonewsid.sh %CYGWIN_ROOT%\bin
	echo IF_NEWSID_SERVICE=%IF_NEWSID_SERVICE%>>%WINROLL_CONFIG_FILE%
	echo IF_NEWSID_SERVICE=%IF_NEWSID_SERVICE%>>%WINROLL_SETUP_LOG%

	echo .
	echo ... %INSTALL_AUTONEWSID_SERVICE% ...
	REM set DEPEND_SERVICE=
	REM if "%IF_AUTOHOSTNAME_SERVICE%" == "y" (
	REM	set DEPEND_SERVICE=-y "%AUTOHOSTNAME_SERVICE%"
	REM )

	REM # use -y to assigen what service must be started before the new service
	REM # 200612.0 的版本中在被拿掉,原因會造成 autonewsid 一直 autohostname 被中斷

	rem  20080520 後用 winrollsrv 取代
	rem "%CYGWIN_ROOT%\bin\cygrunsrv.exe" -I "%AUTONEWSID_SERVICE%" -d "Auto New SID" -p "%CYGWIN_ROOT%\bin\autonewsid.sh" -e "CYGWIN=${_cygwin}" -i %DEPEND_SERVICE%
	
	:END_OF_AUTONEWSID_SETUP
goto :EOF

:AUTONEWSID_REMOVE
	echo %HR%
	echo %NEXT_STEP% : %REMOV_AUTONEWSID_SERVICE%
	echo %HR%

	echo .
	echo ... %REMOVE_NEEDED_FILES% ...

	del /F /Q %CYGWIN_ROOT%\bin\autonewsid.sh
	del /F /Q %CYGWIN_ROOT%\bin\newsid.exe

	rem echo .
	rem echo ... %REMOV_AUTONEWSID_SERVICE% ...
	rem %CYGWIN_ROOT%\bin\cygrunsrv.exe -E %AUTONEWSID_SERVICE%
	rem %CYGWIN_ROOT%\bin\cygrunsrv.exe -R %AUTONEWSID_SERVICE%
	
	:END_OF_AUTONEWSID_REMOVE
goto :EOF

:SSHD_SETUP
	echo %HR%
	echo %NEXT_STEP% : %SETUP_SSHD_SERVICE%
	echo %HR%

	set ANSWER_IF_GO=y
	echo %IF_INSTALL_SSH_SERVICE%
	set /P ANSWER_IF_GO="[Y/n]"
	
	rem set SSHD_SERVER_PW_OPT=-w %SSHD_SERVER_PW%
	
	if "%ANSWER_IF_GO%" == "n" (
		goto :END_OF_SSHD_SETUP
	)
	
	if "%OS_VERSION%" == "Vista" (
		set SSHD_SERVER_PW_OPT=
	) else if "%OS_VERSION%" == "WIN7" (
		set SSHD_SERVER_PW_OPT=
	) else (
		set SSHD_SERVER_PW_OPT=-w %SSHD_SERVER_PW%
	)

	%CYGWIN_ROOT%\bin\chmod.exe +r %CYGWIN_ROOT%\etc\passwd %CYGWIN_ROOT%\etc\group
	%CYGWIN_ROOT%\bin\chmod.exe u+w %CYGWIN_ROOT%\etc\passwd %CYGWIN_ROOT%\etc\group
	%CYGWIN_ROOT%\bin\chmod.exe +x %CYGWIN_ROOT%\var
	%CYGWIN_ROOT%\bin\bash.exe --login -c "ssh-host-config -y -c ntsec %SSHD_SERVER_PW_OPT%"
	%CYGWIN_ROOT%\bin\cygrunsrv.exe -S %SSHD_SERVICE%
	
	if "%OS_VERSION%" == "WINXP" (
		echo .
		echo """ %OPEN_SSHD_PORTON_FIREWALL% """
		echo !!! %NON_DRBL_COMMAND_IF_REMOVE% !!!
		echo .
		pause
		REM # It only support "netsh firewal" command in XP-sp2 or later
		netsh firewall add portopening TCP 22 sshd
	)
	echo %CREATE_ADMIN_SSH_FOLDER% : %CYGWIN_ROOT%\%ROOT_NAME%\.ssh
	mkdir %CYGWIN_ROOT%\home\%ROOT_NAME%\.ssh
	
	if EXIST "%WINROLL_LOCAL_BACKUP%\.ssh\authorized_keys"  (
		call :IMPORT_SSH_KEY
	)

	:END_OF_SSHD_SETUP
goto :EOF

:IMPORT_SSH_KEY
	echo %FIND_SSH_KEY_IF_IMPORT% "%WINROLL_LOCAL_BACKUP%\.ssh" ?
	set ANSWER_IF_GO=y
	REM set /P ANSWER_IF_GO="Only [Y]"
	set /P ANSWER_IF_GO="[Y/n]"
	REM # MS-DOS 的 bat script 限制,在條件式中 set /P 會失效 .....

	if "%ANSWER_IF_GO%" == "n" (
		goto :END_OF_SSHD_SETUP
	)
	copy /Y "%WINROLL_LOCAL_BACKUP%\.ssh" "%CYGWIN_ROOT%\home\%ROOT_NAME%\.ssh"
	echo --- Import backuped ssh key from %WINROLL_LOCAL_BACKUP%\.ssh\authorized_keys>>%WINROLL_SETUP_LOG%

	:END_OF_IMPORT_SSH_KTU
goto :EOF

:SSHD_REMOVE
	echo %HR%
	echo %NEXT_STEP% : %REMOVE_SSHD_SERVICE%
	echo %HR%

	%CYGWIN_ROOT%\bin\cygrunsrv.exe -E %SSHD_SERVICE%
	%CYGWIN_ROOT%\bin\cygrunsrv.exe -R %SSHD_SERVICE%
	if EXIST "%CYGWIN_ROOT%\home\%ROOT_NAME%\.ssh\authorized_keys"  (
		mkdir "%WINROLL_LOCAL_BACKUP%\.ssh"
		echo %FIND_SSH_KEY_AND_MOVE% "%WINROLL_LOCAL_BACKUP%\.ssh"
		pause
		copy /Y "%CYGWIN_ROOT%\home\%ROOT_NAME%\.ssh" "%WINROLL_LOCAL_BACKUP%\.ssh"
		echo WINROLL_LOCAL_BACKUP\.ssh = %WINROLL_LOCAL_BACKUP%\.ssh>>%WINROLL_SETUP_LOG%
	)

	if "%OS_VERSION%" == "WINXP" (
		echo .
		echo """ %REMOVE_SSHD_PORTON_FIREWALL% """
		echo !!! %NON_DRBL_COMMAND_IF_REMOVE% !!!
		echo .
		pause

		netsh firewall delete portopening TCP 22
	)
	rem delete "sshd" and "sshd_server" account
	net user sshd /DELETE 1> /dev/null 2>&1
	net user sshd_server /DELETE 1> /dev/null 2>&1

	:SSHD_REMOVE
goto :EOF

:STARTUP_AUTONEWSID
	echo .
	echo %FIRST_USE_NEWSID% %ACCEPT_LICENCE%
	pause 
	%CYGWIN_ROOT%\bin\cygrunsrv.exe -S %WINROLL_SERVICE%
	echo --- Start %WINROLL_SERVICE% service right now>>%WINROLL_SETUP_LOG%
	copy %WINROLL_SETUP_LOG% %CYGWIN_ROOT%
	echo .
	echo %HR%
	echo %PLZ_WAIT_TO_REBOOT%
	echo %HR%
	:SLEEP_TIME
	%CYGWIN_ROOT%\bin\sleep.exe 5
	echo .
	goto :SLEEP_TIME
	:END_OF_SLEEP_TIME
	pause

	:END_OF_STARTUP_AUTONEWSID
goto :EOF

:DRBL-WINROLL_INSTALL
	echo .
	echo ... %START_TO% %INSTALL% DRBL-winRoll ...
	echo .
	pause
	call :CYGWIN_INSTALL
	call :AUTOHOSTNAME_SETUP
	call :NETWORK_MODE_SETUP
	call :AUTONEWSID_SETUP
	call :SSHD_SETUP
	
	copy %WINROLL_SETUP_LOG% %CYGWIN_ROOT%
	echo %FOOTER01%
	echo %FOOTER02%
	echo %FOOTER03%
	echo %FOOTER04%
	echo %FOOTER05%
	echo %FOOTER06%
	echo %FOOTER07%
	echo %FOOTER08%
	echo %FOOTER09%
	echo %FOOTER10%
	echo %FOOTER11%
	echo %FOOTER12%
	echo %FOOTER13%
	echo %FOOTER14%
	echo %FOOTER15%
	pause
	:END_OF_DRBL-WINROLL_INSTALL
goto :EOF

:DRBL-WINROLL_UNINSTALL
	echo .
	echo ... %START_TO% %UNINSTALL% DRBL-winRoll ...
	echo .
	
	if EXIST "%APPDATA%\drbl_winroll-uninstall.bat" (
		"%APPDATA%\drbl_winroll-uninstall.bat"
		del /F /Q "%APPDATA%\drbl_winroll-uninstall.bat"
		goto :END_OF_DRBL-WINROLL_UNINSTALL
	)else (
	
		call :SSHD_REMOVE
		call :AUTONEWSID_REMOVE
		call :NETWORK_MODE_REMOVE
		call :AUTOHOSTNAME_REMOVE
		call :CYGWIN_UNINSTALL
	
		echo .
		echo ... %UNINSTALL_COMPLETED% !!!
		pause
	)
	net user sshd /DELETE 1> /dev/null 2>&1
	net user sshd_server /DELETE 1> /dev/null 2>&1

	:END_OF_DRBL-WINROLL_UNINSTALL
goto :EOF

:DRBL-WINROLL_REINSTALL
	echo .
	echo ... %START_TO% %REINSTALL% DRBL-winRoll ...
	call :DRBL-WINROLL_UNINSTALL
	call :DRBL-WINROLL_INSTALL
	:END_OF_DRBL-WINROLL_REINSTALL
goto :EOF

:EOF
exit /B 1