@echo off

REM ############################
REM # Global parameter
REM ############################

REM ############################
REM # Language descripation

set YOUR_LANGUAGE_IS=�z���t�λy���O
set LANGUAGE_DESC=�c�餤��
set TRANSLATOR=ceasar@nchc.org.tw

REM ############################
set HEAD01=*********   �w��ϥ� drbl-winroll �w�˵{��  ******************
set HEAD02=*
set HEAD03=*      ������ߦۥѳn������  , NCHC ,Taiwan
set HEAD04=*      License: GPL      
set HEAD05=*
set HEAD06=*     ���{���|�i��n��w�˻P�t�γ]�w�H�ѨM clone windows �� hostname 
set HEAD07=*     �@�˪����D�A�ô��� windows  �b  drbl ���ҤU�������\��  
set HEAD08=*     �`�N�ƶ��G
set HEAD09=*     1. ���{����ĳ�H Administrator ��������
set HEAD10=*     2. �Y�z���e�w�w�˹L cygwin �� c:\cygwin�A��ĳ�������ο��[f](�j��w��)
set HEAD11=*     3. ���{���A�Ω� Windows 2K,XP,Server(2003,2008),Vista,Win 7 ������
set HEAD12=*
set HEAD13=*    Ķ�� : 
set HEAD14=*        %LANGUAGE_DESC%  :  %TRANSLATOR%
set HEAD15=*********************************************************

set HR====================================================
set NEXT_STEP=�U�@�B

set YOUR_CURRENT_ACCOUNT_IS=�z�ثe��������
set PLZ_CONFIRM_ADMIN_ACCOUNT=�нT�a�z�ثe�� Administrator ���v��
set IF_KEEP_GO=�ϥ� [Ctrl+c] ���} �Ϋ����N���~��
set YOUR_OS_VERSION_IS=�z���@�~�t�Ϊ�����
set START_TO=�}�l�i��
set INSTALL=�w��
set INSTALLED=�w�g�w��
set REINSTALL=���s�w��
set UNINSTALL=�Ѱ��w��
set REMOVE=�Ѱ�

set PLZ_CHOOSE=�п��
set DIRECTORY=�ؿ�
set STARTMENU=�{�������
set LOCAL_REPOSITORY_DIRECTORY=���a�x�îw�ؿ�
set CREATE_WINROLL_CONFIG=�إ� drbl-winroll �]�w��

REM ############################
REM # Messages for cygwin installation error

set ERR_DIR_DONT_EXIST=ERROR: Local repository does not exists: 
set ERR_REP_DONT_EXIST=ERROR: Invalid local repository. Missing directory:
set ERR_FIL_DONT_EXIST=ERROR: Invalid local repository. Missing file:
set ERR_CYGWIN_SETUP_DONT_EXIST=ERROR: Could not find Cygwin setup.exe in the cygwin_mirror\ directory of the local repository:
set INSTALL_WINROLL_SERVICE=�w�� drbl-winroll �D�A��

set INSTALL_AUTOHOSTNAME_SERVICE=�w�˥D���W���ˬd�A��
set SETUP_AUTOHOSTNAME_SERVICE=�t�m�D���W���ˬd�A��
set REMOV_WINROLL_SERVICE=���� drbl-winroll �D�A��
set REMOV_AUTOHOSTNAME_SERVICE=�����D���W���ˬd�A��
set IF_INSTALL_AUTOHOSTNAME=�O�_�w�ˡy�۰ʥD���W�١z�A��
set SELECT_HOSTNAME_FORMAT%=�п�ܱz�Q�n�D���W�ټ˦�
set BY_IP=ip (���᭱6�X�Ʀr, ex: XXX-001-001)
set BY_MAC=Mac address (���᭱6�X�r��,  ex: XXX-3D9C51)
set BY_HOSTS_FILE=�ѥ��a���ɮרM�w
set MORE_DETAIIL_TO_REFER=�Բӳ]�w�аѦ�
set SET_HOSTNAME_PREFIX=�]�w�D���W�٪��e�m�r��(�p�G�ѥ��a���ɮרM�w�h�����v�T�A�B�����r�ꤣ�i�W�L 15�Ӧr��)

set IF_INSTALL_AUTOWG=�O�_�]�Ұʡy�۰ʤu�@�s�զW�١z
set SHOW_HOSTNAME_FORMAT=�ҨϥΪ��q���D���W�ٰѼƬ�
set SELECT_WORKGROUP_FORMAT=�п�ܤu�@�s�ռ˦�
set FIXED=�T�w�r��
set DNS_SUFFIX=��DNS ���w
set SHOW_WORKGROUP_FORMAT=�ҨϥΪ��u�@�s�զW�ٰѼƬ�
set SET_WG_PREFIX=�]�w�s�զW�٪��e�m�r��

set INSTALL_AUTONEWSID_SERVICE=�w�˥D�� SID �ˬd�A��
set PLZ_READ_LICENSE=�ѩ󦹥\��ݭn�ϥ� Sysinternals (http://www.sysinternals.com) �{��,���L����n����v�Ҧ�,�иԲӾ\Ū�����W���ԭz,�æ^�쥻�{���H�K����w��
set ANS_IF_AGREE=�O�_�P�N���v�Ҧ�
set NOT_AGREE_EXIT=���P�N���v,���}������. �N�~���L drbl-winroll �����A�Ȧw�� 
set SHOW_URL=����v�������s��
set SETUP_AUTONEWSID_SERVICE=�t�m�D�� SID �ˬd�A��
set REMOV_AUTONEWSID_SERVICE=�����D�� SID �ˬd�A��
set IF_INSTALL_AUTONEWSID=�O�_�w�ˡy�۰ʥD�� SID�z�A��
set FIRST_USE_NEWSID=�ѩ�z��ܦw�� autonewsid �A��, ��ĳ�z�b���D���W�����榹�A��, �H�K�ƻs�᪺�D���s�බ�Q����A��.
set ACCEPT_LICENCE=�y��б������v�ö}�l�Ĥ@���ҰʪA��. �A�Ȱ��槹��|���s�Ұʹq��.

set NO_ANY_ATTENDED=�L�{���z�L�ݰ�����ʧ@
set REMOVE_REGISTRY=�R�����U���X
set COPY_NEEDED_FILES=�ƻs�һ��ɮ�
set REMOVE_NEEDED_FILES=�����һ��ɮ�
set FORCE_TO_NIC_AS_DHCP=�{���j��N�z�������d�]�w�� DHCP

set IF_INSTALL_SSH_SERVICE=�O�_�t�m sshd �A��
set SETUP_SSHD_SERVICE=�w�� sshd �A�ȨåߧY�Ұ�
set REMOVE_SSHD_SERVICE=����ò��� sshd �A��
set CREATE_ADMIN_SSH_FOLDER=���z�s�W�޲z�̪� ssh ���_�s����| 
set OPEN_SSHD_PORTON_FIREWALL=�{���N���z�󨾤���]�w���}�Һ�ť  TCP 22 port �� sshd �s�u�ϥ�
set NON_DRBL_COMMAND_IF_REMOVE=�z�p�G�������]�w�Awindows �N�L�k�����Ӧ� drbl �D�����R�O
set UNINSTALL_COMPLETED=��������
set REMOVE_SSHD_PORTON_FIREWALL=�{���N���z���������𤧱Һ�ť port TCP 22
set FIND_SSH_KEY_IF_IMPORT=�o�{�ƥ��� ssh key, �ݭn�פJ�� 
set FIND_SSH_KEY_AND_MOVE=�o�{ ssh key, �N�ƥ���
set PLZ_WAIT_TO_REBOOT=���ʧ@�ݭn�i��j�q�wŪ�g�ʧ@,�аȥ����ݦܦ۲Φ۰ʭ��s�}��

set FOOTER01=************   ���߱z���� drbl-winroll �w��  ****************
set FOOTER02=*
set FOOTER03=*   �z�w�g���� drbl-winroll �������n��w�˻P�t�γ]�w�I
set FOOTER04=*
set FOOTER05=*   1. �p�G�z�n���z�� windows ��"�۰�"���� drbl server ���R�O�A
set FOOTER06=*   �бz�Ѿ\ FAQ ���Ĥ����B�J�A�N�zDRBL�D���W�� SSH ���_�w�˦� windows �C
set FOOTER07=*
set FOOTER08=*   2. �p�G�z�n���s�t�m�G�p Windows(���Ǹ��Φw�����ѧO�XSID)
set FOOTER09=*    �A�бz�Ѿ\ FAQ ���Ĥ�������
set FOOTER10=*
set FOOTER11=*
set FOOTER12=*   �sô�ڭ� :
set FOOTER13=*   Email�Gceasar@nchc.org.tw, steven@nchc.org.tw
set FOOTER14=*
set FOOTER15=********  ������ߦۥѳn������  , NCHC ,Taiwan  *********

REM # new add for drbl_winroll-uninstall.bat
set WRONG_OS_VERSION=�ثe���䴩�z�ҨϥΪ��@�~�t��
set PROGRAM_ABORTED=�{�����_
set SURE_TO=�z�T�w�n
set WARNING=ĵ�i
set SERVICES=�����A��
set ANY_KEY_TO_EXIT=���N�����}

REM # Add from v1.2.0-2, 20090909
set SETUP_NETWORK_MODE=�]�w�����Ҧ�
set SELECT_NETWORK_MODE=��ܺ����Ҧ�
set BY_FILE=�ѥ��a���ɮרM�w
set SKIP=����
set DO_NOTHIMG_FOR_NETWORK=���B�z�����]�w
set USE_NETWORK_MODE_IS=�����]�w�Ҧ���
set FORCE_INSTALL=�j��w��(�A�X����w���ݭn�� cygwin ����, ���i��}�a�즳���]�w)
set RUNSHELL=���b���椤���{��

REM # Add from v1.2.2 , 20100315
set PLEASE_INPUT_NEWSID_PROGRAM_PATH=�п�J�Ψ��ܧ� SID �u�㪺������|
set PROGRAM_NOT_FOUND=�z�ҫ��w�{�����s�b
set PLEASE_INPUT_NEWSID_PROGRAM_PARAMS=�п�J�ݭn���Ѽ�, �p:'/a /n';�Y�L�h [Enter] ���L
set FULL_NEW_SID_COMMAND=�����ܧ� SID �����O

REM # Add from v1.2.3 , 20111031
set SETUP_AUTO_ADD2AD_SERVICE=�t�m�۰ʥ[�J AD ����A��
set IF_INSTALL_ADD2AD=�O�_�n�t�m�۰ʥ[�J AD ����A��
set SET_DEFAULT_AD_DOMAIN=�п�J AD ������W��
set SET_DEFAULT_AD_USERD=�п�J AD ���޲z�b��
set SET_DEFAULT_AD_PASSWORDD=�п�J AD �޲z�b�����K�X
set SHOW_ADD2AD_RUN_SCRIPT=������O��
set NOTE_NETDOM_NECESSITY=�нT�{�t�Τ��� netdom.exe ������

REM # Add from v1.3.0 , 20111108
set _PASSWORD_OF_SYG_SERVER_STORED=SSHD �A�ȩҨϥΪ��b�� cyg_server ���K�X�Q�s��b
set _DO_NOT_CHANGE_PASSWORD_OF_CYG_SERVER=�Ф��ܧ� cyg_server �b�����K�X�ΰ��Φ��b��. ���|�ɭP ssh �A�ȱҰʥ���

REM # Add from v1.3.1, 20111226
set REMOVE_ADD2AD_SERVICE=�����۰ʵn�J AD �A��
set SETUP_MONITOR_SERVICE=�]�w Windows �Τ�ݨt�κʴ��A��
set RUN_INSTALLER=����w�˵{�� :
set RUN_UNINSTALLER=���沾���{�� :
set REMOVE_MONITOR_SERVICE=���� Windows �Τ�ݨt�κʴ��A��
set PLEASE_INSTALL_MUNIN_AT_SERVER=�z�����b�ʵ��D���W���T�]�w Munin �Τ�ݤ~����o�t�θ�T. �Ӹ`�аѦ� DRBL-winroll ����.
set IF_INSTALL_MONITOR=�O�_�w�˨t�κʴ��A��(��Munin Node����)
