@echo off

REM ############################
REM # Global parameter
REM ############################
set NIC_NAME=Connexion au r‚seau local
set STARTMENU_PATH=%ALLUSERSPROFILE%\Menu D‚marrer\Programmes\Cygwin
set ROOT_PASSWORD=
set USER_NAME=
set USER_PASSWORD=
set ADMIN=Administrateur
REM ############################
REM # Language descripation

set YOUR_LANGUAGE_IS=Votre langue est le
set LANGUAGE_DESC=Fran‡ais
set TRANSLATOR=Joël Gondouin (joel@gondouin.net)

REM ############################
set HEAD01=*********   Bienvenue dans l'installation de drbl-winRoll   ******************
set HEAD02=*
set HEAD03=*  NCHC Free Software Labs  , NCHC ,Taiwan
set HEAD04=*  License: GPL      
set HEAD05=*
set HEAD06=*  Installation du programme de post-clonage pour environnemnet DRBL
set HEAD07=*  Mise … jour automatique du nom de machine, groupe de travail et SID 
set HEAD08=*  Note :
set HEAD09=*  1. Installez de pr‚f‚rence avec le compte "administrateur"
set HEAD10=*  2. D‚sinstallez cygwin s'il est d‚j… pr‚sent sur le systŠme
set HEAD11=*  3. Ce programme fonctionne sous Windows 2000, XP, Vista, Windows 7 et 2003 serial edition
set HEAD12=*
set HEAD13=*    Traducteur : 
set HEAD14=*        %LANGUAGE_DESC%  :  %TRANSLATOR%
set HEAD15=*********************************************************

set HR====================================================

set YOUR_CURRENT_ACCOUNT_IS=Votre compte actuel est
set PLZ_CONFIRM_ADMIN_ACCOUNT=Confirmez maintenant vos droits d'administration SVP
set IF_KEEP_GO=Utilisez [Ctrl+c] pour sortir, ou appuyez sur une touche pour continuer
set YOUR_OS_VERSION_IS=Votre systŠme d'exploitation est
set START_TO=D‚marrage de 
set INSTALL=Installation de
set INSTALLED=Install‚
set REINSTALL=R‚installation de
set UNINSTALL=D‚sinstallation de
set REMOVE=Suppression de

set PLZ_CHOOSE=Choisissez SVP
set DIRECTORY=R‚pertoire
set STARTMENU=Menu d‚marrer
set LOCAL_REPOSITORY_DIRECTORY=Chemin du r‚pertoire local
set CREATE_WINROLL_CONFIG=Cr‚ation du fichier de configuration drbl-winRoll

set IF_INSTALL_AUTOHOSTNAME=Installation de la fonction auto-hostname ?
set SELECT_HOSTNAME_FORMAT%=Choisissez le format de nom de machine d‚sir‚:
set BY_IP=Adresse IP (Utilise les 6 derniers caractŠres, ex: XXX-001-001)
set BY_MAC=Adresse MAC(Utilise les 6 derniers caractŠres, ex: XXX-3D9C51)
set BY_HOSTS_FILE=D‚termine le nom de machine par fichier local
set MORE_DETAIIL_TO_REFER=Pour plus de d‚tails lisez
set SET_HOSTNAME_PREFIX=Configuration du pr‚fixe pour le nom de machine (Aucun effet si vous avez d‚j… choisi 3. La taille totale ne peut exceder 15 caractŠres)

set IF_INSTALL_AUTOWG=D‚marrage automatique de l'attribution du groupe de travail ? 
set SHOW_HOSTNAME_FORMAT=Le paramètre pour "Nom de l'ordinateur" est
set SET_WG_PREFIX=Configuration du pr‚fixe pour le groupe de travail
set SELECT_WORKGROUP_FORMAT=SVP choisissez le format du groupe de travail Windows
set FIXED=Variable fixe
set SHOW_WORKGROUP_FORMAT=Le paramètre pour "Groupe de travail" est
set DNS_SUFFIX=Attribu‚ via le suffixe DNS

set INSTALL_AUTONEWSID_SERVICE=Configuration du service de modification du SID
set PLZ_READ_LICENSE=Etant donn‚ que cette fonction n‚cessite le programme Sysinternals (http://www.sysinternals.com). Afin de respecter la licence de Sysinternal, vous devez lire la licence attentivement. Si vous ˆtes d'accord, vous pouvez continuer, si vous ne l'ˆtes pas, nous arrˆtons cette partie de l'installation.
set ANS_IF_AGREE=Acceptez vous l'accord de licence ?
set NOT_AGREE_EXIT=Je n'accepte pas, j'arrˆte l'installation de cette partie. Va maintenant sur une autre partie de drbl-winroll 
set SHOW_URL=SVP, rendez vous sur la page de la licence
set SETUP_AUTONEWSID_SERVICE=Configuration du service de v‚rification du SID
set REMOV_AUTONEWSID_SERVICE=Suppression du service de v‚rification du SID
set IF_INSTALL_AUTONEWSID=Installation du service de v‚rification du SID ?
set FIRST_USE_NEWSID=Vu que vous avez install‚ le service autonewsid, nous vous recommandons fortemant de d‚marrer le service maintenant. 
set ACCEPT_LICENCE=SVP, acceptez la licence quand le service d‚marrera et le systŠme red‚marrera quand l'installation du service sera finie...

set NO_ANY_ATTENDED=Vous n'avez rien d'autre … faire pendant l'installation
set SETUP_AUTOHOSTNAME_SERVICE=Configuration de Hostname-check service
set REMOV_AUTOHOSTNAME_SERVICE=Suppression de Hostname-check service
set REMOVE_REGISTRY=Suppression de la base de registre Windows
set COPY_NEEDED_FILES=Copie des fichiers requis
set REMOVE_NEEDED_FILES=Suppression des fichiers requis
set INSTALL_AUTOHOSTNAME_SERVICE=Installation du service de v‚rification du nom de machine
set FORCE_TO_NIC_AS_DHCP=Le programme va r‚gler votre carte r‚seau  sur DHCP

set IF_INSTALL_SSH_SERVICE=Installation du service sshd ?
set SETUP_SSHD_SERVICE=Configuration et d‚marrage imm‚diat du service sshd
set REMOVE_SSHD_SERVICE=Arr‚t et suppression du service sshd 
set CREATE_ADMIN_SSH_FOLDER=Cr‚ation du r‚pertoire pour la cl‚ ssh publique de l'administrateur 
set OPEN_SSHD_PORTON_FIREWALL=Le programme va ouvrir le port d'‚coute 22 pour la connexion ssh dans windows
set NON_DRBL_COMMAND_IF_REMOVE=Windows n'acceptera pas de commandes du serveur DRBL si vous l'enlevez
set UNINSTALL_COMPLETED=Suppression termin‚e
set REMOVE_SSHD_PORTON_FIREWALL=Le programme va retirer le port d'‚coute 22 pour la connexion ssh dans Windows
set FIND_SSH_KEY_IF_IMPORT=Cl‚ ssh sauvegard‚e trouv‚e, si besoin, importation  
set FIND_SSH_KEY_AND_MOVE=Cl‚ ssh trouv‚e, le programme va la sauvegarder ici 
set PLZ_WAIT_TO_REBOOT=Il va y avoir un certain nombre d'acc‚s au Disque Dur, SVP, attendez que la machine red‚marre automatiquement

set FOOTER01=************         !!   F‚licitations  !!         ****************
set FOOTER02=* 
set FOOTER03=*  Vous avez termin‚ l'installation et la configuration de drbl-winRoll pour windows !
set FOOTER04=*
set FOOTER05=*  1. Pour accepter automatiquement les commandes du serveur DRBL
set FOOTER06=*     suivez le point 7 de ~/doc/FAQ.*.txt pour pr‚parer les fichiers.
set FOOTER07=*
set FOOTER08=*  2. Si vous devez red‚ployer Windows (modifier le nø de s‚rie ou le SID)
set FOOTER09=*     Reportez vous au point 8 de ~/doc/FAQ.*.txt 
set FOOTER10=*
set FOOTER11=*
set FOOTER12=*  Contactez nous pour tout problŠme (NDT : En anglais)
set FOOTER13=*  Email: ceasar@nchc.org.tw, steven@nchc.org.tw
set FOOTER14=*
set FOOTER15=********  NCHC Free Software Labs  , NCHC ,Taiwan  *********

REM ############################
REM # Messages d'erreur

set ERR_DIR_DONT_EXIST=ERREUR: D‚pot local non valide. R‚pertoire manquant :
set ERR_REP_DONT_EXIST=ERREUR: Le d‚pot local suivant n'existe pas :
set ERR_FIL_DONT_EXIST=ERREUR: D‚pot local non valide. Fichier manquant :
set ERR_CYGWIN_SETUP_DONT_EXIST=ERREUR: Impossible de trouver le setup.exe de Cygwin dans le r‚pertoire cygwin_mirror\ du d‚pot local :

REM ##############################
REM ### Etapes
set NEXT_STEP=Etape suivante

REM # new add for uninstal.bat
set WRONG_OS_VERSION=Version MS Windows non supportée
set PROGRAM_ABORTED=Programme interrompu
set SURE_TO=Etes-vous s–r de
set WARNING=ATTENTION
set SERVICES=Services
set ANY_KEY_TO_EXIT=N'importe quelle touche pour sortir

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