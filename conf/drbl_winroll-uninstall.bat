@echo off

REM ####################################################################
REM # Uninstall drbl-winRoll 
REM #
REM # License: GPL
REM # Author	: Ceasar Sun Chen-kai <ceasar@nchc.org.tw>
REM # Last update	: 2007/3/5
REM #
REM # Usage: uninstall-winroll.bat
REM #
REM ####################################################################

REM # Global parameter
set CYGWIN_ROOT=%SystemDrive%\cygwin
set WINROLL_SRV=%CYGWIN_ROOT%\bin\winrollsrv-controllor.sh
set WINROLL_UNINSTALL_FOLDER=%CYGWIN_ROOT%\drbl_winRoll-config\uninstall
set STARTMENU_PATH=
set SYSTEM_ADMIN=

REM #
REM # To identify your OS language and start menu path
REM # 
CALL "%APPDATA%\drbl_winroll-uninstall-para.cmd"

call :CHECK_IF_WINADMIN

echo ============================================
echo *** %UNINSTALL% drbl-winroll
echo ============================================
echo !!!
echo !!! %WARNING% : %SURE_TO% %UNINSTALL% drbl-winroll ?
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
echo %CYGWIN_ROOT%\bin\skill.exe -KILL -c bash
%CYGWIN_ROOT%\bin\skill.exe -KILL -c bash

echo *** %REMOVE% %SERVICES%:
echo %CYGWIN_ROOT%\bin\bash.exe --login -i "%WINROLL_SRV% -r"
%CYGWIN_ROOT%\bin\bash.exe --login -i "%WINROLL_SRV%" -r 


echo *** %REMOVE% /var/cron:
%CYGWIN_ROOT%\bin\bash.exe --login -c "rm -rf /var/cron" 
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

echo .
echo *** %REMOVE% CYGWIN %STARTMENU%
echo rd /Q /S "%STARTMENU_PATH%"
rd /Q /S "%STARTMENU_PATH%"
echo ============================================

echo .
echo *** %REMOVE% CYGWIN %DIRECTORY%
rd /Q /S "%CYGWIN_ROOT%"
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
