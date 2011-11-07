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
REM # use registry 'HKEY_CURRENT_USER\Control Panel\International\Locale' value  
REM set ENG_OS_PATH=%USERPROFILE%\Desktop
REM set ZHTW_OS_PATH=%USERPROFILE%\桌面
REM set FR_OS_PATH=%USERPROFILE%\Bureau
REM set NL_OS_PATH=%USERPROFILE%\Bureaublad

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
set WINROLL_WEB_FAQ_URL=http://drbl.nchc.org.tw/drbl-winroll/faq.php

set CYGWIN_ROOT=%SystemDrive%\cygwin
set CYGWIN_LOCAL_MIRROR=
set LOCAL_REPOSITORY=%SOURCE_DIR%
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
	rem call .\doc\Faq.%LOCALE_CODE%.txt
	)
if "%ACTION%" == "f" (
	call :DRBL-WINROLL_INSTALL
	rem call .\doc\Faq.%LOCALE_CODE%.txt
)
if "%ACTION%" == "r" (
	call :DRBL-WINROLL_REINSTALL
	rem call .\doc\Faq.%LOCALE_CODE%.txt
)
if "%ACTION%" == "u" (
	call :DRBL-WINROLL_UNINSTALL
	rem call .\doc\Faq.%LOCALE_CODE%.txt
)
REM explorer %WINROLL_WEB_FAQ_URL%?localecode=%LOCALE_CODE%

if  "%IF_NEWSID_SERVICE%" == "y" (
	call :STARTUP_AUTONEWSID
)

goto :EOF
REM #####################################
REM # Sub function
REM #####################################
:CHECK_OS_VERSION
	set OS_VERSION=NONE
	
	cscript %INIT_CONF%\reg_query.vbs //Nologo "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProductName" > OS-version.txt

	type OS-version.txt | find "2000"
	if "%ERRORLEVEL%" == "0" (
		set OS_VERSION=WIN2000
		goto :END_OF_CHECK_OS_VERSION
	)

	type OS-version.txt | find "XP"
	if "%ERRORLEVEL%" == "0" (
		set OS_VERSION=WINXP
		goto :END_OF_CHECK_OS_VERSION
	)

	type OS-version.txt | find "2003"
	if "%ERRORLEVEL%" == "0"  (
		set OS_VERSION=WIN2003
		goto :END_OF_CHECK_OS_VERSION
	)

	type OS-version.txt | find "2008"
	if "%ERRORLEVEL%" == "0"  (
		set OS_VERSION=WIN2008
		goto :END_OF_CHECK_OS_VERSION
	)

	type OS-version.txt | find "Vista"
	if "%ERRORLEVEL%" == "0"  (
		set OS_VERSION=Vista
		rem set STARTMENU_PATH=%ALLUSERSPROFILE%\Start Menu\Programs\Cygwin
		goto :END_OF_CHECK_OS_VERSION
	)

	type OS-version.txt | find "Windows 7"
	if "%ERRORLEVEL%" == "0"  (
		set OS_VERSION=WIN7
		rem set STARTMENU_PATH=%ALLUSERSPROFILE%\Start Menu\Programs\Cygwin
		goto :END_OF_CHECK_OS_VERSION
	)
	
	if "%OS_VERSION%" == "NONE" (
		echo .
		echo !!! Unknow your OS version ... !!!
		echo !!! Please attach "OS-version.txt" file at installation folder and email to "ceasar@nchc.org.tw" !!!
		echo !!! Program EXIT !!!
		pause
		exit 1
		goto :EOF
	)
	:END_OF_CHECK_OS_VERSION
goto :EOF

REM # To decide language during installation
:SET_LANGUAGE
	set LOCALE_CODE=0

	cscript %INIT_CONF%\reg_query.vbs //Nologo "HKEY_CURRENT_USER\Control Panel\International\Locale" > Locale.txt
	for /F "tokens=* delims=" %%S in ('type Locale.txt') do set LOCALE_CODE=%%S

	REM ### For zh_TW 
	rem type Locale.txt | find "00000404"
	rem IF "%ERRORLEVEL%" == "0" (
	rem 	set LANG=tc
	rem 	goto :BEFORE_OF_CALL_LANGUAGE
	rem )

	rem IF EXIST "%FR_OS_PATH%" (
	rem 	set LANG=fr
	rem 	goto :BEFORE_OF_CALL_LANGUAGE
	rem )
	rem IF EXIST "%NL_OS_PATH%" (
	rem 	set LANG=nl
	rem 	goto :BEFORE_OF_CALL_LANGUAGE
	rem )

	IF NOT EXIST "lang\%LOCALE_CODE%.cmd" (
		set LOCALE_CODE=unknow
		echo *** Warning !! ****
		echo !! Your currnet language not be supported complete yet,
		echo !! But you still can install it under this release.
		echo !! Let me know if any problem. Email :ceasar@nchc.org.tw !!
		echo .
		echo !! [Ctrl+C] to exit, any key to continue.
		pause
	)
	
	:BEFORE_OF_CALL_LANGUAGE

	CALL lang\%LOCALE_CODE%.cmd
	
	REM # assign "STARTMENU_PATH" from registry value
	cscript %INIT_CONF%\reg_query.vbs //Nologo "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\Common Programs" > program-path.txt
	for /F "tokens=* delims=" %%S in ('type program-path.txt') do set STARTMENU_PATH=%%S\cygwin

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
	echo OS_VERSION=%OS_VERSION%>>%WINROLL_SETUP_LOG%
	echo LOCALE_CODE=%LOCALE_CODE%>>%WINROLL_SETUP_LOG%
	echo STARTMENU_PATH=%STARTMENU_PATH%>>%WINROLL_SETUP_LOG%
	echo SURCE_DIR=%cd%>>%WINROLL_SETUP_LOG%
	echo ACTION=%ACTION%>>%WINROLL_SETUP_LOG%
	echo CYGWIN_ROOT=%CYGWIN_ROOT%>>%WINROLL_SETUP_LOG%
	echo SERVICE_ACCOUNT_NAME=%SERVICE_ACCOUNT_NAME%>>%WINROLL_SETUP_LOG%
	echo SERVICE_ACCOUNT_PW=%SERVICE_ACCOUNT_PW%>>%WINROLL_SETUP_LOG%
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

	rem IF NOT EXIST "%CYGWIN_ROOT%\etc\setup" (
	rem   mkdir "%CYGWIN_ROOT%\etc\setup"
	rem ) ELSE (
	rem   del /Q "%CYGWIN_ROOT%\etc\setup\last-*"
	rem )

	REM -- Note that last-* must *not* containing whitespace, e.g. " " etc. 
	REM -- This is why there below is no space in front of ">".
	rem echo Install> "%CYGWIN_ROOT%\etc\setup\last-action"
	rem echo %LOCAL_REPOSITORY%> "%CYGWIN_ROOT%\etc\setup\last-cache"
	rem echo cygwin_mirror> "%CYGWIN_ROOT%\etc\setup\last-mirror"

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
	copy /Y "%INIT_CONF%\*.lnk" "%STARTMENU_PATH%"
	
	echo %CREATE_WINROLL_CONFIG%
	if not exist "%WINROLL_CONFIG_FOLDER%" ( mkdir "%WINROLL_CONFIG_FOLDER%" )
	if not exist "%WINROLL_DOC_FOLDER%" ( mkdir "%WINROLL_DOC_FOLDER%" )
	if not exist "%WINROLL_CONFIG_FOLDER%\keyword-conf" ( mkdir "%WINROLL_CONFIG_FOLDER%\keyword-conf" )
	
	copy /V "%INIT_CONF%\*.conf" "%WINROLL_CONFIG_FOLDER%"
	xcopy  /Y /E "%INIT_CONF%\keyword-conf" "%WINROLL_CONFIG_FOLDER%\keyword-conf"

	copy /Y "%INIT_CONF%\*.lib.sh" "%WINROLL_CONFIG_FOLDER%"
	xcopy /Y /E "%INIT_DOC_FOLDER%" "%WINROLL_DOC_FOLDER%"
	copy /Y ".\sbin\*.*" "%CYGWIN_ROOT%\bin"

	copy /Y "%INIT_CONF%\*.reg" "%WINROLL_UNINSTALL_FOLDER%"
	copy /Y "%INIT_CONF%\drbl_winroll-uninstall.bat" "%APPDATA%"
	REM # copy language file for uninstall usage
	copy /Y "lang\%LOCALE_CODE%.cmd" "%APPDATA%\%WINROLL_UNINSTALL_PARA%"

	echo. >>"%APPDATA%\%WINROLL_UNINSTALL_PARA%"
	echo set CYGWIN_ROOT=%CYGWIN_ROOT%>>"%APPDATA%\%WINROLL_UNINSTALL_PARA%"
	echo set STARTMENU_PATH=%STARTMENU_PATH%>>"%APPDATA%\%WINROLL_UNINSTALL_PARA%"

	REM Add cygwin binary path into current path
	set PATH=%CYGWIN_ROOT%\bin;%PATH%
	
	echo ... %INSTALL_WINROLL_SERVICE% ...
	"%CYGWIN_ROOT%\bin\cygrunsrv.exe" -I "%WINROLL_SERVICE%" -d "DRBL-winroll auto-config service" -p "/bin/winrollsrv.sh" -e "CYGWIN=${_cygwin}" -i
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
	
	if EXIST "%WINROLL_LOCAL_BACKUP%\hosts.txt"  (
		copy /Y "%WINROLL_LOCAL_BACKUP%\hosts.txt" "%CYGWIN_ROOT%\drbl_winroll-config"
	)
	if EXIST "%WINROLL_LOCAL_BACKUP%\winroll.conf"  (
		REM copy /Y "%WINROLL_LOCAL_BACKUP%\winroll.conf" "%CYGWIN_ROOT%\drbl_winroll-config"
		rem call :IMPORT_WINROLL_CONFIG
	)
	if "%ANSWER_IF_IMPORT_CONF%" == "y" (
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
	if "%ANSWER%" == "1" ( set WG_PARA=%WG_PREFIX% )
	if "%ANSWER%" == "2" ( set WG_PARA=%WG_PREFIX%-$NM )
	if "%ANSWER%" == "3" ( set WG_PARA=$DNS_SUFFIX )

	echo ** %SHOW_WORKGROUP_FORMAT% : %WG_PARA%
	
	:END_OF_AUTOGROUP_SETUP
	echo HN_WSNAME_PARAM = %WS_PARA%>> %WINROLL_CONFIG_FILE%
	echo WG_WSNAME_PARAM = %WG_PARA%>> %WINROLL_CONFIG_FILE%
	
	set IF_AUTOHOSTNAME_SERVICE=y
	echo .
	echo IF_AUTOHOSTNAME_SERVICE = %IF_AUTOHOSTNAME_SERVICE%>>%WINROLL_CONFIG_FILE%
	echo IF_AUTOHOSTNAME_SERVICE = %IF_AUTOHOSTNAME_SERVICE%>>%WINROLL_SETUP_LOG%

:END_OF_AUTOHOSTNAME_SETUP
goto :EOF

:IMPORT_WINROLL_CONFIG
	echo Detect old config winroll.conf , import it for Windows hostname and workgroup ?
	set /P ANSWER_IF_IMPORT_CONF="[y/N]"
	if "%ANSWER_IF_IMPORT_CONF%" == "y" (
		type "%WINROLL_LOCAL_BACKUP%\winroll.conf" >> "%WINROLL_CONFIG_FILE%"
	)
	
:END_OF_IMPORT_WINROLL_CONFIG
goto :EOF

:AUTOHOSTNAME_REMOVE
	echo %HR%
	echo Step 2. %REMOV_AUTOHOSTNAME_SERVICE%
	echo %HR%

	echo .
	echo ... %REMOVE_NEEDED_FILES% ...

	del /F /Q %CYGWIN_ROOT%\bin\autohostname.sh
	del /F /Q %CYGWIN_ROOT%\bin\wsname.exe
		
goto :EOF

:NETWORK_MODE_SETUP

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
	
:END_OF_NETWORK_MODE_SETUP
goto :EOF

:NETWORK_MODE_REMOVE

	REM echo Do nothing
	REM netsh interface ip set address "%NIC_NAME%" source=dhcp
	
:END_OF_NETWORK_MODE_REMOVE
goto :EOF

:ADD2AD_SETUP

	echo %HR%
	echo %NEXT_STEP% : %SETUP_AUTO_ADD2AD_SERVICE% 
	echo %HR%
		
	set ANSWER_IF_GO=n
	echo %IF_INSTALL_ADD2AD% [Y/n]
	set /P ANSWER_IF_GO="[y/N]"
	if "%ANSWER_IF_GO%" == "n" (
		goto :END_OF_ADD2AD_SETUP
	)
	
	set _AD_DOMAIN=my-domain.org
	echo %SET_DEFAULT_AD_DOMAIN%
	set /P ANSWER_AD_DOMAIN="[%_AD_DOMAIN%] "
	if NOT "%ANSWER_AD_DOMAIN%" == "" (
		set _AD_DOMAIN=%ANSWER_AD_DOMAIN%
	)

	set _AD_USERD=%ADMIN%
	echo %SET_DEFAULT_AD_USERD%
	set /P ANSWER_AD_USERD="[%_AD_USERD%] "
	if NOT "%ANSWER_AD_USERD%" == "" (
		set _AD_USERD=%ANSWER_AD_USERD%
	)

	set _AD_PASSWORDD=
	echo %SET_DEFAULT_AD_PASSWORDD%
	set /P ANSWER_AD_PASSWORDD="[%_AD_PASSWORDD%] "
	if NOT "%ANSWER_AD_PASSWORDD%" == "" (
		set _AD_PASSWORDD=%ANSWER_AD_PASSWORDD%
	)

	set IF_AUTOHOSTNAME_SERVICE=y
	set ADD2AD_RUN_FILE=add2ad.bat

	set _ADD2AD_RUN_SCRIPT=netdom join %%computername%% /domain:%_AD_DOMAIN% /userd:%_AD_USERD% /passwordd:%_AD_PASSWORDD% /reboot:8
	
	echo ** %SHOW_ADD2AD_RUN_SCRIPT% : %_ADD2AD_RUN_SCRIPT%
	echo ** %NOTE_NETDOM_NECESSITY% 
	
	echo %_ADD2AD_RUN_SCRIPT% >> %WINROLL_CONFIG_FOLDER%\%ADD2AD_RUN_FILE%
	echo IF_ADD2AD_SERVICE = %IF_AUTOHOSTNAME_SERVICE%>>%WINROLL_CONFIG_FILE%
	echo ADD2AD_RUN_FILE = %ADD2AD_RUN_FILE%>>%WINROLL_CONFIG_FILE%
	
:END_OF_ADD2AD_SETUP
goto :EOF


:AUTONEWSID_SETUP
	echo %HR%
	echo %NEXT_STEP% : %SETUP_AUTONEWSID_SERVICE%
	echo %HR%
	
	:IF_INSTALL_AUTONEWSID
	set ANSWER_IF_GO=n
	echo %IF_INSTALL_AUTONEWSID% (Default: No)
	set /P ANSWER_IF_GO="[y/N]"
	if not "%ANSWER_IF_GO%" == "y" (
		goto :END_OF_AUTONEWSID_SETUP
	)

	set NEWSID_PROGRAM_PATH=%TMP%\newsid.exe
	echo %PLEASE_INPUT_NEWSID_PROGRAM_PATH%
	echo .
	set /P NEWSID_PROGRAM_PATH="[%TMP%\newsid.exe]"
	if NOT EXIST "%NEWSID_PROGRAM_PATH%" (
		echo %PROGRAM_NOT_FOUND% !!
		goto :IF_INSTALL_AUTONEWSID
	)
	basename %NEWSID_PROGRAM_PATH% >%TMP%\NEWSID_PROGRAM_NAME.txt
	for /F "tokens=* delims=" %%S in ('type %TMP%\NEWSID_PROGRAM_NAME.txt') do set NEWSID_PROGRAM_NAME=%%S
	
	set NEWSID_PROGRAM_PARAMS=
	echo %PLEASE_INPUT_NEWSID_PROGRAM_PARAMS% 
	set /P NEWSID_PROGRAM_PARAMS="[ex:/a /n (for newsid.exe)]"
	echo %FULL_NEW_SID_COMMAND% : %NEWSID_PROGRAM_NAME% %NEWSID_PROGRAM_PARAMS%

	echo ... %COPY_NEEDED_FILES% ...
	copy %NEWSID_PROGRAM_PATH% %CYGWIN_ROOT%\bin

	set IF_NEWSID_SERVICE=y
	echo AUTONEWSID_PARAM = %NEWSID_PROGRAM_NAME% %NEWSID_PROGRAM_PARAMS%>> %WINROLL_CONFIG_FILE%
	echo IF_NEWSID_SERVICE = y>>%WINROLL_CONFIG_FILE%
	echo IF_NEWSID_SERVICE = y>>%WINROLL_SETUP_LOG%
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

	:END_OF_AUTONEWSID_REMOVE
goto :EOF

:SSHD_SETUP
	echo %HR%
	echo %NEXT_STEP% : %SETUP_SSHD_SERVICE%
	echo %HR%

	set ANSWER_IF_GO=y
	echo %IF_INSTALL_SSH_SERVICE%
	set /P ANSWER_IF_GO="[Y/n]"
	
	rem set SSHD_SERVER_PW_OPT=-w %a_random_string%
	%CYGWIN_ROOT%\bin\bash.exe --login -c "perl -le 'print map+(A..Z,a..z,0..9)[rand 62],0..7'" >%WINROLL_CONFIG_FOLDER%\SSHD_SERVER_PW.txt
	for /F "tokens=* delims=" %%S in ('type %WINROLL_CONFIG_FOLDER%\SSHD_SERVER_PW.txt') do set SSHD_SERVER_PW=%%S

	
	if "%ANSWER_IF_GO%" == "n" (
		goto :END_OF_SSHD_SETUP
	)
	
	if "%OS_VERSION%" == "Vista" (
		set SSHD_SERVER_PW_OPT=
	rem ) else if "%OS_VERSION%" == "WIN7" (
	rem 	set SSHD_SERVER_PW_OPT=
	) else (
		set SSHD_SERVER_PW_OPT=-w %SSHD_SERVER_PW%
	)

	%CYGWIN_ROOT%\bin\chmod.exe +r /etc/passwd  /etc/group
	%CYGWIN_ROOT%\bin\chmod.exe u+w /etc/passwd  /etc/group
	%CYGWIN_ROOT%\bin\chmod.exe 755 /var
	%CYGWIN_ROOT%\bin\touch.exe /var/log/sshd.log
	%CYGWIN_ROOT%\bin\bash.exe --login -c "ssh-host-config -y -c ntsec %SSHD_SERVER_PW_OPT%"
	%CYGWIN_ROOT%\bin\cygrunsrv.exe -S %SSHD_SERVICE%
	%CYGWIN_ROOT%\bin\chmod.exe 600 /drbl_winroll-config/SSHD_SERVER_PW.txt

	
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
	)else (
		

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
	set PATH=%PATH%;%CYGWIN_ROOT%\bin;%CYGWIN_ROOT%\sbin;%CYGWIN_ROOT%\usr\sbin
	call :AUTOHOSTNAME_SETUP
	call :NETWORK_MODE_SETUP
	call :ADD2AD_SETUP
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
