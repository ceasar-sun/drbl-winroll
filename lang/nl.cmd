@echo off

REM ############################
REM # Global parameter
REM ############################
set NIC_NAME=LAN-verbinding
set STARTMENU_PATH=%ALLUSERSPROFILE%\Menu Start\Programma's\Cygwin
set ROOT_PASSWORD=
set USER_NAME=
set USER_PASSWORD=
set ADMIN=Administrator
REM ############################
REM # TAAL OMSCHRIJVING

set YOUR_LANGUAGE_IS=UW TAAL IS ?
set LANGUAGE_DESC=Nederlands
set TRANSLATOR=Dave Haakenhout (Almere, Netherlands)

REM ############################
set HEAD01=*********   Welkom bij de installatie van drbl-winroll  ******************
set HEAD02=*
set HEAD03=*  NCHC Free Software Labs  , NCHC ,Taiwan
set HEAD04=*  License: GPL      
set HEAD05=*
set HEAD06=*  Dit programa zal software installeren om de computernaam dupplicatie te verkomen
set HEAD07=*  in windows omgevingen waar je het OS wilt klonen, and heeft diversen opties voor het goed functioneren van DRBL omgevingen   
set HEAD08=*  Nota :
set HEAD09=*  1. Aanbevolen is, dat Administrators dit programma zullen installeren
set HEAD10=*  2. Deinstalleer eerdere versies van Cygwin
set HEAD11=*  3. De installatie werkt op Windows 2000, XP, 2003, Vista, Windows 7
set HEAD12=*
set HEAD13=*    Translator : 
set HEAD14=*        %LANGUAGE_DESC%  :  %TRANSLATOR%
set HEAD15=*********************************************************

set HR====================================================
set NEXT_STEP=Volgende stap

set YOUR_CURRENT_ACCOUNT_IS=Huidige account is
set PLZ_CONFIRM_ADMIN_ACCOUNT=Controleer dat u Administrator privileges heeft !!!
set IF_KEEP_GO=Gebruik [Ctrl+c] om te stoppen, of druk op een toets om verder te gaan
set YOUR_OS_VERSION_IS=Huidig Operating Systeem is 
set START_TO=Begin met
set INSTALL=installeren
set INSTALLED=geinstalleerd
set REINSTALL=herinstalleren
set UNINSTALL=Deinstalleren
set REMOVE=Verwijderen

set PLZ_CHOOSE=Maak uw keuze
set DIRECTORY=Map
set STARTMENU=Menu Start
set LOCAL_REPOSITORY_DIRECTORY=Lokale Bewaarplaats Map
set CREATE_WINROLL_CONFIG=Creeren van een drbl-winroll configuratie bestand
REM ############################
REM # Meldingen voor eventuele cygwin installatie errors

set ERR_DIR_DONT_EXIST=ERROR: Lokale Bewaarplaats bestaat niet: 
set ERR_REP_DONT_EXIST=ERROR: Foutieve Lokale Bewaarplaats. Map bestaat niet:
set ERR_FIL_DONT_EXIST=ERROR: Foutive Lokale Bewaarplaats. Map bestaat niet:
set ERR_CYGWIN_SETUP_DONT_EXIST=ERROR: Kan de setup.exe van Cygwin niet vinden in de cygwin_mirror\ map van de lokale bewaarplaats:

set IF_INSTALL_AUTOHOSTNAME=Installeren van de auto-hostname functie
set SELECT_HOSTNAME_FORMAT%=Selecteer computernaam formaat
set BY_IP=IP  (Gebruik de laatste 6 karakters, voorbeeld: XXX-001-001)
set BY_MAC=Mac adres (Gebruik de laatste 6 karakters, voorbeeld: XXX-3D9C51)
set BY_HOSTS_FILE=Vaststellen computernaam door middel van lokaal bestand
set MORE_DETAIIL_TO_REFER=Meer details lees a.u.b 
set SET_HOSTNAME_PREFIX=Setup computernaam prefix(Geen effect als u 3 karakters vooraf selecteerd, en de totale grootte kan niet meer dan 15 karakters zijn)

set IF_INSTALL_AUTOWG=If startup Auto Workgroup Name
set SHOW_HOSTNAME_FORMAT=The hostname parameter would be assigned
set SET_WG_PREFIX=Setup work group prefix
set SELECT_WORKGROUP_FORMAT=Please select the format of Windows workgroup
set FIXED=Fixed string
set SHOW_WORKGROUP_FORMAT=The workgroup parameter would be assigned
set DNS_SUFFIX=Toegewezen via DNS suffix

set INSTALL_AUTONEWSID_SERVICE=Setup  SID-Controleer service
set PLZ_READ_LICENSE=De functies hebben het Sysinternals (http://www.sysinternals.com) programma nodig. Om Sysinternals softwarevergunning te eerbiedigen, u moet de vergunning zorgvuldig lezen. Als u akkoord gaat, dan kunt u verdergaan, als niet akkoord ga, wij zullen met dit deel van installatie ophouden.
set ANS_IF_AGREE=Keurt u de licentie overeenkomst goed ?
set NOT_AGREE_EXIT=Ga niet akkoord, stop deze sessie van de installatie. Ga niet door met andere onderdelen van drbl-winroll 
set SHOW_URL=Lees a.u.b de licentie web pagina
set SETUP_AUTONEWSID_SERVICE=Setup SID-Controleer service
set REMOV_AUTONEWSID_SERVICE=Verwijder SID-Controleer service
set IF_INSTALL_AUTONEWSID=Als de SID-Controleer service geinstalleerd moet worden
set FIRST_USE_NEWSID=Omdat u de autonewsid service installeerd, raden we echt aan dat de service nu gaat staren. 
set ACCEPT_LICENCE=Accepteer de licentie als de service gestard wordt, en het systeem zal herstarten als de service helemaal klaar is...

set NO_ANY_ATTENDED=U hoeft helemaal niks te doen tijdens de installatie ( onbeheerd )
set SETUP_AUTOHOSTNAME_SERVICE=Setup Hostname-Controleer service
set REMOV_AUTOHOSTNAME_SERVICE=Verwijder Hostname-check service
set REMOVE_REGISTRY=Verwijderen van het Windows register
set COPY_NEEDED_FILES=Kopieren van benodigde bestanden
set REMOVE_NEEDED_FILES=Verwijderen van benodigde bestanden
set INSTALL_AUTOHOSTNAME_SERVICE=Installeren van Computernaam-Controleer service
set FORCE_TO_NIC_AS_DHCP=Het programma zal DHCP voor uw Netwerkkaart instellen

set IF_INSTALL_SSH_SERVICE=Installeren van sshd service
set SETUP_SSHD_SERVICE=Setup sshd service en de service direct starten
set REMOVE_SSHD_SERVICE=Stoppen en verwijderen van de  sshd service
set CREATE_ADMIN_SSH_FOLDER=Map aanmeken voor de administrators ssh publieke key 
set OPEN_SSHD_PORTON_FIREWALL=Het programma zal luisterende poort 22 voor de ssh connectie in de windows firewall instellen
set NON_DRBL_COMMAND_IF_REMOVE=Windows kan de commando's niet goedkeuren van de DRBL server als u het verwijdert
set UNINSTALL_COMPLETED=Verwijdering compleet
set REMOVE_SSHD_PORTON_FIREWALL=Het programma zal luisterende poort 22 voor de ssh connectie in de windows firewall verwijderen
set FIND_SSH_KEY_IF_IMPORT=Vinden van opgeslagen ssh key, als het nodig is om te importeren  
set FIND_SSH_KEY_AND_MOVE=Vinden van de ssh key, het programma zal het backuppen en verplaatsen naar 
set PLZ_WAIT_TO_REBOOT=er zal veel harddisk activiteit zijn, wacht a.u.b tot het systeem automatisch zal herstarten

set FOOTER01=************         !!   Gefelicteerd  !!         ****************
set FOOTER02=* 
set FOOTER03=*  U heeft de installatie en configuratie van drbl-winRoll goed doorlopen in windows !
set FOOTER04=*
set FOOTER05=*  1. Als u wilt dat drbl-winroll commando's accepteerd
set FOOTER06=*  Lees a.u.b het item 5 in ~/doc/FAQ.*.txt om de benodigde bestanden voor windows te preparen.
set FOOTER07=*
set FOOTER08=*  2. Als het nodig is om de bestanden opnieuw te installeren in Windows (veranderen van serial number of Windows SID)
set FOOTER09=*  Lees a.u.b het item 5 in ~/doc/FAQ.*.txt 
set FOOTER10=*
set FOOTER11=*
set FOOTER12=*  Neem contact met ons op als er problemen onstaan
set FOOTER13=*  Email¡Gceasar@nchc.org.tw, steven@nchc.org.tw
set FOOTER14=*
set FOOTER15=********  NCHC Free Software Labs  , NCHC ,Taiwan  *********

REM# nieuwe optie voor uninstall.bat
set WRONG_OS_VERSION=Deze Windows versie wordt niet ondersteund
set PROGRAM_ABORTED=Programma is gestopt
set SURE_TO=Weet u het zeker
set WARNING=Waarschuwing
set SERVICES=services
set ANY_KEY_TO_EXIT=Druk op een willekeurige toets om te stoppen

set INSTALL_WINROLL_SERVICE=Install drbl-winroll master service
set REMOV_WINROLL_SERVICE=Remove drbl-winroll master service

REM # Add form v1.2.0-2, 20090909
set SETUP_NETWORK_MODE=Setup network mode
set SELECT_NETWORK_MODE=Select network mode
set BY_FILE=By local file
set SKIP=skip
set DO_NOTHIMG_FOR_NETWORK=Do nothing for network configuration
set USE_NETWORK_MODE_IS=network mode is
set FORCE_INSTALL=Install over(For that cygwin environment installed already, but maybe affect the original)
set RUNSHELL=running cygwin shell