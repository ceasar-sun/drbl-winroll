@echo off

REM ############################
REM # Global parameter
REM ############################

REM ############################
REM # Language descripation

set YOUR_LANGUAGE_IS=Your language is
set LANGUAGE_DESC=Svenska
set TRANSLATOR=Yngve Sp�ng (yngve.spang@smart-lab.se)

REM ############################
set HEAD01=*********   Welcome to use drbl-winRoll Installation  ******************
set HEAD02=*
set HEAD03=*  NCHC Free Software Labs  , NCHC ,Taiwan
set HEAD04=*  License: GPL      
set HEAD05=*
set HEAD06=*  This program will install software to solve windows hostname duplication 
set HEAD07=*  for clone Win OS, and it sopport needed function in DRBL environment   
set HEAD08=*  Note :
set HEAD09=*  1. Suggest to use Administrator(s) to install this package
set HEAD10=*  2. Please remove cygwin if you have installed it before
set HEAD11=*  3. The installation can work on Windows 2000, XP, 2003, Vista, Windows 7 serial edition
set HEAD12=*
set HEAD13=*    Translator : 
set HEAD14=*        %LANGUAGE_DESC%  :  %TRANSLATOR%
set HEAD15=*********************************************************

set HR====================================================
set NEXT_STEP=Next step

set YOUR_CURRENT_ACCOUNT_IS=Current account is
set PLZ_CONFIRM_ADMIN_ACCOUNT=Please confirm your Administration privilege at present
set IF_KEEP_GO=Use [Ctrl+c] to exit, or press any key to continue
set YOUR_OS_VERSION_IS=Current operation system is
set START_TO=Start to
set INSTALL=install
set INSTALLED=Installed
set REINSTALL=Reinstall
set UNINSTALL=Uninstall
set REMOVE=Remove

set PLZ_CHOOSE=Please select
set DIRECTORY=directory
set STARTMENU=Start Menu
set LOCAL_REPOSITORY_DIRECTORY=Local repository path
set CREATE_WINROLL_CONFIG=Create drbl-winRoll configuartion file

REM ############################
REM # Messages for cygwin installation error

set ERR_DIR_DONT_EXIST=ERROR: Local repository does not exists: 
set ERR_REP_DONT_EXIST=ERROR: Invalid local repository. Missing directory:
set ERR_FIL_DONT_EXIST=ERROR: Invalid local repository. Missing file:
set ERR_CYGWIN_SETUP_DONT_EXIST=ERROR: Could not find Cygwin setup.exe in the cygwin_mirror\ directory of the local repository:
set INSTALL_WINROLL_SERVICE=Install drbl-winroll master service

set IF_INSTALL_AUTOHOSTNAME=If intall auto-hostname function
set SELECT_HOSTNAME_FORMAT%=Select the hostname format as you want
set BY_IP=IP  (Use the last 6 characters, ex: XXX-001-001)
set BY_MAC=Mac address (Use the last 6 characters, ex: XXX-3D9C51)
set BY_HOSTS_FILE=Determine hostname by local file
set MORE_DETAIIL_TO_REFER=More detail please read 
set SET_HOSTNAME_PREFIX=Setup hostname prefix(No effect if you select 3 in advance, and the total size can't be over 15 characters)

set IF_INSTALL_AUTOWG=If startup Auto Workgroup Name
set SHOW_HOSTNAME_FORMAT=The "hostname" parameter is
set SET_WG_PREFIX=Setup work group prefix
set SELECT_WORKGROUP_FORMAT=Please select the format of Windows workgroup
set FIXED=Fixed string
set SHOW_WORKGROUP_FORMAT=The "workgroup" parameter is
set DNS_SUFFIX=Assigned via DNS suffix

set INSTALL_AUTONEWSID_SERVICE=Setup  SID-Check service
set PLZ_READ_LICENSE=Because the function need the Sysinternals (http://www.sysinternals.com) program. In order to respect Sysinternals software license, you must read the license carefully. If you agree, then you can continue, if disagree, we will quit this part of installation.
set ANS_IF_AGREE=Do you agree the lincese
set NOT_AGREE_EXIT=Don't agree, exit this session instalation. Go no the other parts of drbl-winroll 
set SHOW_URL=Please view the lincese web page
set SETUP_AUTONEWSID_SERVICE=Setup SID-check service
set REMOV_AUTONEWSID_SERVICE=Remove SID-check service
set IF_INSTALL_AUTONEWSID=If intall SID-check service
set FIRST_USE_NEWSID=Because you install autonewsid service, we really suggest to run the service right now. 
set ACCEPT_LICENCE=Please accept the licence when the service be started, and system will reboot after service finished...

set NO_ANY_ATTENDED=You don't need to do anything during installing
set SETUP_AUTOHOSTNAME_SERVICE=Setup Hostname-check service
set REMOV_AUTOHOSTNAME_SERVICE=Remove Hostname-check service
set REMOV_WINROLL_SERVICE=Remove drbl-winroll master service
set REMOVE_REGISTRY=Delete Windows registry
set COPY_NEEDED_FILES=Copy need files
set REMOVE_NEEDED_FILES=Remove need files
set INSTALL_AUTOHOSTNAME_SERVICE=Install Hostname-check service
set FORCE_TO_NIC_AS_DHCP=Program will set as DHCP for your NIC

set IF_INSTALL_SSH_SERVICE=If install sshd service
set SETUP_SSHD_SERVICE=Setup sshd service and start it right away
set REMOVE_SSHD_SERVICE=Stop and remove sshd service
set CREATE_ADMIN_SSH_FOLDER=Create the directory for admin's ssh public key 
set OPEN_SSHD_PORTON_FIREWALL=Program will open a listening port 22 for ssh connection in windows
set NON_DRBL_COMMAND_IF_REMOVE=Windows can't accept the command from DRBL server if you remove it
set UNINSTALL_COMPLETED=Uninstall finished
set REMOVE_SSHD_PORTON_FIREWALL=Program will remove the listening port 22 for ssh connection in windows
set FIND_SSH_KEY_IF_IMPORT=Find backuped ssh key, if need to import it  
set FIND_SSH_KEY_AND_MOVE=Find the ssh key, program will backup it to 
set PLZ_WAIT_TO_REBOOT=it would do lots of HD access, please wait until system reboot automatically

set FOOTER01=************         !!   Congratulation  !!         ****************
set FOOTER02=* 
set FOOTER03=*  You completed drbl-winRoll's  installation and configuration in  windows !
set FOOTER04=*
set FOOTER05=*  1. If you want to let windows can accept DRBL server command automatically
set FOOTER06=*  Please refer to item 5 in ~/doc/FAQ.*.txt to prepare need files for windows.
set FOOTER07=*
set FOOTER08=*   2. If you need to re-deploy Windows (modify serial number or Windows SID)
set FOOTER09=*    �APlease refer to item 5 in ~/doc/FAQ.*.txt 
set FOOTER10=*
set FOOTER11=*
set FOOTER12=*  Contact with us if any problem
set FOOTER13=*  Email�Gceasar@nchc.org.tw, steven@nchc.org.tw
set FOOTER14=*
set FOOTER15=********  NCHC Free Software Labs  , NCHC ,Taiwan  *********

REM # new add for drbl_winroll-uninstall.bat
set WRONG_OS_VERSION=No support MS Windows version
set PROGRAM_ABORTED=Program aborted
set SURE_TO=Are you sure to
set WARNING=WARNING
set SERVICES=services
set ANY_KEY_TO_EXIT=Any key to exit

REM # Add form v1.2.0-2, 20090909
set SETUP_NETWORK_MODE=Setup network mode
set SELECT_NETWORK_MODE=Select network mode
set BY_FILE=By local file
set SKIP=skip
set DO_NOTHIMG_FOR_NETWORK=Do nothing for network configuration
set USE_NETWORK_MODE_IS=network mode is
set FORCE_INSTALL=Install over(For that cygwin environment installed already, but maybe affect the original)
set RUNSHELL=running cygwin shell


REM # Add from v1.2.2 , 20100315
set PLEASE_INPUT_NEWSID_PROGRAM_PATH=Please input full path of renew SID tool
set PROGRAM_NOT_FOUND=Program not found
set PLEASE_INPUT_NEWSID_PROGRAM_PARAMS=Input parameters for SID tool if it needs, ex: '/a /n'. 
set FULL_NEW_SID_COMMAND=Full command for renew Windows SID

REM # Add from v1.2.3 , 20111031
set SETUP_AUTO_ADD2AD_SERVICE=Setup auto-add to AD domain service
set IF_INSTALL_ADD2AD=If install auto-add to AD domain service
set SET_DEFAULT_AD_DOMAIN=Please input AD domain anme
set SET_DEFAULT_AD_USERD=Please input the available user account of AD
set SET_DEFAULT_AD_PASSWORDD=Please input the passowrd for te account
set SHOW_ADD2AD_RUN_SCRIPT=Full batch command for add-to AD 
set NOTE_NETDOM_NECESSITY=Please make sure netdom.exe does exist in system

REM # Add from v1.3.0 , 20111108
set _PASSWORD_OF_SYG_SERVER_STORED=The password of sshd runner 'cyg_server' is stored
set _DO_NOT_CHANGE_PASSWORD_OF_CYG_SERVER=Do not change cyg_server's password or disable it. That would lead to sshd be out of service .

REM # Add from v1.3.1, 20111226
set REMOVE_ADD2AD_SERVICE=Remove Auto add-to-AD service
set SETUP_MONITOR_SERVICE=Setup Windows clients monitor service
set RUN_INSTALLER=Run installer :
set RUN_UNINSTALLER=Run uninstaller :
set REMOVE_MONITOR_SERVICE=Remove Windows clients monitor service
set PLEASE_INSTALL_MUNIN_AT_SERVER=You have to configure Munin correctly in server. Please refer to DRBL-winroll web site for details.
set IF_INSTALL_MONITOR=If install system monitor daemon (via Munin Node)

REM # Add from v1.6.1, 20140314
set IF_INSTALL_AS_TEMPLETE=Set as templete mode (auto-add2ad function wouold be skip)
