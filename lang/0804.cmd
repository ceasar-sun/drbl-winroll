@echo off

REM ############################
REM # Global parameter
REM ############################

REM ############################
REM # Language descripation

set YOUR_LANGUAGE_IS=����ϵͳ������
set LANGUAGE_DESC=��������
set TRANSLATOR=ceasar@nchc.org.tw

REM ############################
set HEAD01=*********   ��ӭʹ�� drbl-winroll ��װ��ʽ  ******************
set HEAD02=*
set HEAD03=*      ����������������ʵ����  , NCHC ,Taiwan
set HEAD04=*      License: GPL      
set HEAD05=*
set HEAD06=*     ����ʽ��������尲װ��ϵͳ�趨�Խ�� clone windows �� hostname 
set HEAD07=*     һ�������⣬���ṩ windows  ��  drbl ������֮��ع���  
set HEAD08=*     ע�����
set HEAD09=*     1. ����ʽ������ Administrator ���ִ��
set HEAD10=*     2. ����֮ǰ�Ѱ�װ�� cygwin �� c:\cygwin���������Ƴ���ѡ��[f](ǿ�ư�װ)
set HEAD11=*     3. ����ʽ������ Windows 2K,XP,Server(2003,2008),Vista,Win 7 �Ȱ汾
set HEAD12=*
set HEAD13=*    ���� : 
set HEAD14=*        %LANGUAGE_DESC%  :  %TRANSLATOR%
set HEAD15=*********************************************************

set HR====================================================
set NEXT_STEP=��һ��

set YOUR_CURRENT_ACCOUNT_IS=��Ŀǰ�����Ϊ
set PLZ_CONFIRM_ADMIN_ACCOUNT=��ȷ����Ŀǰ�� Administrator ֮Ȩ��
set IF_KEEP_GO=ʹ�� [Ctrl+c] �뿪 �����������
set YOUR_OS_VERSION_IS=������ҵϵͳ�汾Ϊ
set START_TO=��ʼ����
set INSTALL=��װ
set INSTALLED=�Ѿ���װ
set REINSTALL=���°�װ
set UNINSTALL=�����װ
set REMOVE=���

set PLZ_CHOOSE=��ѡ��
set DIRECTORY=Ŀ¼
set STARTMENU=��ʽ��ѡ��
set LOCAL_REPOSITORY_DIRECTORY=���ش��ؿ�Ŀ¼
set CREATE_WINROLL_CONFIG=���� drbl-winroll �趨��

REM ############################
REM # Messages for cygwin installation error

set ERR_DIR_DONT_EXIST=ERROR: Local repository does not exists: 
set ERR_REP_DONT_EXIST=ERROR: Invalid local repository. Missing directory:
set ERR_FIL_DONT_EXIST=ERROR: Invalid local repository. Missing file:
set ERR_CYGWIN_SETUP_DONT_EXIST=ERROR: Could not find Cygwin setup.exe in the cygwin_mirror\ directory of the local repository:
set INSTALL_WINROLL_SERVICE=��װ drbl-winroll ������

set INSTALL_AUTOHOSTNAME_SERVICE=��װ�������Ƽ�����
set SETUP_AUTOHOSTNAME_SERVICE=�����������Ƽ�����
set REMOV_WINROLL_SERVICE=�Ƴ� drbl-winroll ������
set REMOV_AUTOHOSTNAME_SERVICE=�Ƴ��������Ƽ�����
set IF_INSTALL_AUTOHOSTNAME=�Ƿ�װ���Զ��������ơ�����
set SELECT_HOSTNAME_FORMAT%=��ѡ������Ҫ����������ʽ
set BY_IP=ip (ȡ����6������, ex: XXX-001-001)
set BY_MAC=Mac address (ȡ����6����Ԫ,  ex: XXX-3D9C51)
set BY_HOSTS_FILE=�ɱ��ض˵�������
set MORE_DETAIIL_TO_REFER=��ϸ�趨��ο�
set SET_HOSTNAME_PREFIX=�趨�������Ƶ�ǰ����Ԫ(����ɱ��ض˵�����������Ӱ�죬��ȫ���ִ����ɳ��� 15����Ԫ)

set IF_INSTALL_AUTOWG=�Ƿ�Ҳ�������Զ�����Ⱥ�����ơ�
set SHOW_HOSTNAME_FORMAT=��ʹ�õĵ����������Ʋ���Ϊ
set SELECT_WORKGROUP_FORMAT=��ѡ����Ⱥ����ʽ
set FIXED=�̶��ִ�
set DNS_SUFFIX=��DNS ָ��
set SHOW_WORKGROUP_FORMAT=��ʹ�õĹ���Ⱥ�����Ʋ���Ϊ
set SET_WG_PREFIX=�趨Ⱥ�����Ƶ�ǰ����Ԫ

set INSTALL_AUTONEWSID_SERVICE=��װ���� SID ������
set PLZ_READ_LICENSE=���ڴ˹�����Ҫʹ�� Sysinternals (http://www.sysinternals.com) ��ʽ,Ϊ������������Ȩģʽ,����ϸ�Ķ���ҳ��֮����,���ص�����ʽ�Ա������װ
set ANS_IF_AGREE=�Ƿ�ͬ����Ȩģʽ
set NOT_AGREE_EXIT=��ͬ����Ȩ,�뿪�˲���. ���������� drbl-winroll ��ط���װ 
set SHOW_URL=����Ȩ��ҳ�����
set SETUP_AUTONEWSID_SERVICE=�������� SID ������
set REMOV_AUTONEWSID_SERVICE=�Ƴ����� SID ������
set IF_INSTALL_AUTONEWSID=�Ƿ�װ���Զ����� SID������
set FIRST_USE_NEWSID=������ѡ��װ autonewsid ����, �������ڴ���������ִ�д˷���, �Ա㸴�ƺ������Ⱥ��˳��ִ�з���.
set ACCEPT_LICENCE=�Ժ��������Ȩ����ʼ��һ����������. ����ִ������������������.

set NO_ANY_ATTENDED=���������������κζ���
set REMOVE_REGISTRY=ɾ��ע�����
set COPY_NEEDED_FILES=�������赵��
set REMOVE_NEEDED_FILES=�Ƴ����赵��
set FORCE_TO_NIC_AS_DHCP=��ʽǿ�ƽ�������·���趨Ϊ DHCP

set IF_INSTALL_SSH_SERVICE=�Ƿ����� sshd ����
set SETUP_SSHD_SERVICE=��װ sshd ������������
set REMOVE_SSHD_SERVICE=ֹͣ���Ƴ� sshd ����
set CREATE_ADMIN_SSH_FOLDER=�������������ߵ� ssh ��Կ���·�� 
set OPEN_SSHD_PORTON_FIREWALL=��ʽ�������ڷ���ǽ�趨�п�������  TCP 22 port �� sshd ����ʹ��
set NON_DRBL_COMMAND_IF_REMOVE=������Ƴ����趨��windows ���޷��������� drbl ����֮����
set UNINSTALL_COMPLETED=�Ƴ����
set REMOVE_SSHD_PORTON_FIREWALL=��ʽ�������Ƴ�����ǽ֮������ port TCP 22
set FIND_SSH_KEY_IF_IMPORT=���ֱ��ݵ� ssh key, ��Ҫ������ 
set FIND_SSH_KEY_AND_MOVE=���� ssh key, ��������
set PLZ_WAIT_TO_REBOOT=�˶�����Ҫ���д���Ӳ��д����,����صȴ�����ͳ�Զ����¿���

set FOOTER01=************   ��ϲ����� drbl-winroll ��װ  ****************
set FOOTER02=*
set FOOTER03=*   ���Ѿ���� drbl-winroll ��������尲װ��ϵͳ�趨��
set FOOTER04=*
set FOOTER05=*   1. �����Ҫ������ windows ��"�Զ�"���� drbl server �����
set FOOTER06=*   �������� FAQ �е�����裬����DRBL�����ϵ� SSH ��Կ��װ�� windows ��
set FOOTER07=*
set FOOTER08=*   2. �����Ҫ�������ò��� Windows(������Ż�ȫ��ʶ����SID)
set FOOTER09=*    ���������� FAQ �е�����˵��
set FOOTER10=*
set FOOTER11=*
set FOOTER12=*   ��ϵ���� :
set FOOTER13=*   Email��ceasar@nchc.org.tw, steven@nchc.org.tw
set FOOTER14=*
set FOOTER15=********  ����������������ʵ����  , NCHC ,Taiwan  *********

REM # new add for drbl_winroll-uninstall.bat
set WRONG_OS_VERSION=Ŀǰ��֧Ԯ����ʹ�õ���ҵϵͳ
set PROGRAM_ABORTED=��ʽ�ж�
set SURE_TO=��ȷ��Ҫ
set WARNING=����
set SERVICES=��ط���
set ANY_KEY_TO_EXIT=������뿪

REM # Add from v1.2.0-2, 20090909
set SETUP_NETWORK_MODE=�趨��·ģʽ
set SELECT_NETWORK_MODE=ѡ����·ģʽ
set BY_FILE=�ɱ��ض˵�������
set SKIP=����
set DO_NOTHIMG_FOR_NETWORK=��������·�趨
set USE_NETWORK_MODE_IS=��·�趨ģʽΪ
set FORCE_INSTALL=ǿ�ư�װ(�ʺ�ԭ��������Ҫ֮ cygwin ����, �������ƻ�ԭ��֮�趨)
set RUNSHELL=����ִ���еĳ���

REM # Add from v1.2.2 , 20100315
set PLEASE_INPUT_NEWSID_PROGRAM_PATH=������������� SID ���ߵ�����·��
set PROGRAM_NOT_FOUND=����ָ����ʽ������
set PLEASE_INPUT_NEWSID_PROGRAM_PARAMS=��������Ҫ�Ĳ���, ��:'/a /n';������ [Enter] ����
set FULL_NEW_SID_COMMAND=������� SID ��ָ��

REM # Add from v1.2.3 , 20111031
set SETUP_AUTO_ADD2AD_SERVICE=�����Զ����� AD �������
set IF_INSTALL_ADD2AD=�Ƿ�Ҫ�����Զ����� AD �������
set SET_DEFAULT_AD_DOMAIN=������ AD ����������
set SET_DEFAULT_AD_USERD=������ AD �Ĺ����ʺ�
set SET_DEFAULT_AD_PASSWORDD=������ AD �����ʺ�֮����
set SHOW_ADD2AD_RUN_SCRIPT=����ָ��Ϊ
set NOTE_NETDOM_NECESSITY=��ȷ��ϵͳ���� netdom.exe ִ�е�

REM # Add from v1.3.0 , 20111108
set _PASSWORD_OF_SYG_SERVER_STORED=SSHD ������ʹ�õ��ʺ� cyg_server ֮���뱻�����
set _DO_NOT_CHANGE_PASSWORD_OF_CYG_SERVER=������ cyg_server �ʺ�֮�����ͣ�ô��ʺ�. �ǻᵼ�� ssh ��������ʧ��

REM # Add from v1.3.1, 20111226
set REMOVE_ADD2AD_SERVICE=�Ƴ��Զ����� AD ����
set SETUP_MONITOR_SERVICE=�趨 Windows �û���ϵͳ������
set RUN_INSTALLER=ִ�а�װ��ʽ :
set RUN_UNINSTALLER=ִ���Ƴ���ʽ :
set REMOVE_MONITOR_SERVICE=�Ƴ� Windows �û���ϵͳ������
set PLEASE_INSTALL_MUNIN_AT_SERVER=�������ڼ�����������ȷ�趨 Munin �û��˲���ȡ��ϵͳ��Ѷ. ϸ����ο� DRBL-winroll ��ҳ.
set IF_INSTALL_MONITOR=�Ƿ�װϵͳ������(��Munin Node�ṩ)
