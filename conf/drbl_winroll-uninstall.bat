@echo off

REM ####################################################################
REM # Uninstall drbl-winroll 
REM #
REM # License: GPL
REM # Author	: Ceasar Sun Chen-kai <ceasar@nchc.narl.org.tw>
REM #
REM # Usage: uninstall-winroll.bat
REM #
REM ####################################################################

REM # Global parameter
REM set CYGWIN_ROOT=%SystemDrive%\cygwin
set WINROLL_SRV=/bin/winrollsrv-controllor.sh
set WINROLL_UNINSTALL_FOLDER=%CYGWIN_ROOT%\drbl_winroll-config\uninstall
set STARTMENU_PATH=
set SYSTEM_ADMIN=

set PATH=%PATH%;c:\cygwin\bin;c:\cygwin\sbin;c:\cygwin\usr\sbin

REM #
REM # To identify your OS language and start menu path
REM # 
CALL "%APPDATA%\drbl_winroll-uninstall-para.cmd"

call :CHECK_IF_WINADMIN

echo ============================================
echo *** %UNINSTALL% drbl-winroll
echo ============================================
echo !!!
echo !!! %WARNING% : %SURE_TO% %UNINSTALL% drbl-winroll (%CYGWIN_ROOT%) ?
set ANS=n
set /P ANS="[y/N]"
if NOT "%ANS%" == "y" (
	echo  *** %PROGRAM_ABORTED% !!
	pause
	goto :EOF
)

echo .
echo .. %START_TO% %UNINSTALL% ...

echo .
echo *** %REMOVE% %RUNSHELL%:
echo ps aux |grep bash | sed -e "s/^I//"| gawk -F " " '{print $1}' | xargs -n 1 -r kill -9
ps aux |grep bash | sed -e "s/^I//"| gawk -F " " '{print $1}' | xargs -n 1 -r kill -9

echo *** %REMOVE% %SERVICES%:
echo %CYGWIN_ROOT%\bin\bash.exe --login -i "%WINROLL_SRV% -r"
%CYGWIN_ROOT%\bin\bash.exe --login -i "%WINROLL_SRV%" -r 


echo *** %REMOVE% /var/cron:
rm -rf /usr/sbin/sendmail
%CYGWIN_ROOT%\bin\bash.exe --login -c "rm -rf /var/cron" 
%CYGWIN_ROOT%\bin\bash.exe --login -c "rm -R /home/* /var/log/*" 

echo ============================================

echo.
echo *** %REMOVE_REGISTRY%
echo regedit.exe /s %WINROLL_UNINSTALL_FOLDER%\UninstallCygwin.reg
regedit.exe /s %WINROLL_UNINSTALL_FOLDER%\UninstallCygwin.reg

REM # win2000 has no "reg" command
REM reg DELETE "HKEY_LOCAL_MACHINE\Software\Cygnus Solutions" /f 
REM reg DELETE "HKEY_CURRENT_USER\Software\Cygnus Solutions" /f 
REM reg DELETE "HKEY_USERS\.DEFAULT\Software\Cygnus Solutions" /f 
echo ============================================

set MONITOR_UNINSTALLER=%STARTMENU_PATH%\Cygwin\Munin Node for Windows\Uninstall.lnk
IF NOT EXIST "%MONITOR_UNINSTALLER%" (
	goto :END_OF_REMOVE_MONITOR
)
echo .
echo *** %REMOVE% Monitor Service

echo ... %RUN_UNINSTALLER% : %MONITOR_UNINSTALLER%
"%MONITOR_UNINSTALLER%"
echo ============================================
:END_OF_REMOVE_MONITOR

echo .
echo *** %REMOVE% CYGWIN %STARTMENU%
echo rd /Q /S "%STARTMENU_PATH%"
rd /Q /S "%STARTMENU_PATH%"
echo ============================================

echo .
echo *** %REMOVE% CYGWIN %DIRECTORY%
rd /Q /S "%CYGWIN_ROOT%" 2>NUL
@ping 127.0.0.1 -n 5 -w 1000 > NUL
rd /Q /S "%CYGWIN_ROOT%" 2>NUL
echo ============================================

echo ****** %UNINSTALL_COMPLETED% ******
echo [%ANY_KEY_TO_EXIT%]
pause

REM 
del /Q /F "%APPDATA%\drbl_winroll-uninstall*.*"


REM #####################################
REM # Sub function
REM #####################################

:CHECK_IF_WINADMIN
	IF "%USERNAME%" == "%ADMIN%" (
	 REM Dummy line
	) ELSE (
	  echo ~~~ %YOUR_CURRENT_ACCOUNT_IS% : "%USERNAME%"
	  echo .
	  echo %PLZ_CONFIRM_ADMIN_ACCOUNT%
	  echo !!! %IF_KEEP_GO%
	  echo.
	  pause
	)

goto :EOF

:EOF

exit 0
