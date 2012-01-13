@echo off

REM ############################
REM # Global parameter
REM ############################

REM ############################
REM # Language descripation

set YOUR_LANGUAGE_IS=您的系统语言是
set LANGUAGE_DESC=简体中文
set TRANSLATOR=ceasar@nchc.org.tw

REM ############################
set HEAD01=*********   欢迎使用 drbl-winroll 安装程式  ******************
set HEAD02=*
set HEAD03=*      国网中心自由软体实验室  , NCHC ,Taiwan
set HEAD04=*      License: GPL      
set HEAD05=*
set HEAD06=*     本程式会进行软体安装与系统设定以解决 clone windows 后 hostname 
set HEAD07=*     一样的问题，并提供 windows  在  drbl 环境下之相关功能  
set HEAD08=*     注意事项：
set HEAD09=*     1. 本程式建议以 Administrator 身份执行
set HEAD10=*     2. 若您之前已安装过 cygwin 于 c:\cygwin，建议先移除或选择[f](强制安装)
set HEAD11=*     3. 本程式适用于 Windows 2K,XP,Server(2003,2008),Vista,Win 7 等版本
set HEAD12=*
set HEAD13=*    译者 : 
set HEAD14=*        %LANGUAGE_DESC%  :  %TRANSLATOR%
set HEAD15=*********************************************************

set HR====================================================
set NEXT_STEP=下一步

set YOUR_CURRENT_ACCOUNT_IS=您目前的身份为
set PLZ_CONFIRM_ADMIN_ACCOUNT=请确地您目前有 Administrator 之权限
set IF_KEEP_GO=使用 [Ctrl+c] 离开 或按任意键继续
set YOUR_OS_VERSION_IS=您的作业系统版本为
set START_TO=开始进行
set INSTALL=安装
set INSTALLED=已经安装
set REINSTALL=重新安装
set UNINSTALL=解除安装
set REMOVE=解除

set PLZ_CHOOSE=请选择
set DIRECTORY=目录
set STARTMENU=程式集选单
set LOCAL_REPOSITORY_DIRECTORY=本地储藏库目录
set CREATE_WINROLL_CONFIG=建立 drbl-winroll 设定档

REM ############################
REM # Messages for cygwin installation error

set ERR_DIR_DONT_EXIST=ERROR: Local repository does not exists: 
set ERR_REP_DONT_EXIST=ERROR: Invalid local repository. Missing directory:
set ERR_FIL_DONT_EXIST=ERROR: Invalid local repository. Missing file:
set ERR_CYGWIN_SETUP_DONT_EXIST=ERROR: Could not find Cygwin setup.exe in the cygwin_mirror\ directory of the local repository:
set INSTALL_WINROLL_SERVICE=安装 drbl-winroll 主服务

set INSTALL_AUTOHOSTNAME_SERVICE=安装主机名称检查服务
set SETUP_AUTOHOSTNAME_SERVICE=配置主机名称检查服务
set REMOV_WINROLL_SERVICE=移除 drbl-winroll 主服务
set REMOV_AUTOHOSTNAME_SERVICE=移除主机名称检查服务
set IF_INSTALL_AUTOHOSTNAME=是否安装‘自动主机名称’服务
set SELECT_HOSTNAME_FORMAT%=请选择您想要主机名称样式
set BY_IP=ip (取后面6码数字, ex: XXX-001-001)
set BY_MAC=Mac address (取后面6码字元,  ex: XXX-3D9C51)
set BY_HOSTS_FILE=由本地端档案决定
set MORE_DETAIIL_TO_REFER=详细设定请参考
set SET_HOSTNAME_PREFIX=设定主机名称的前置字元(如果由本地端档案决定则不受影响，且全部字串不可超过 15个字元)

set IF_INSTALL_AUTOWG=是否也启动‘自动工作群组名称’
set SHOW_HOSTNAME_FORMAT=所使用的电脑主机名称参数为
set SELECT_WORKGROUP_FORMAT=请选择工作群组样式
set FIXED=固定字串
set DNS_SUFFIX=由DNS 指定
set SHOW_WORKGROUP_FORMAT=所使用的工作群组名称参数为
set SET_WG_PREFIX=设定群组名称的前置字元

set INSTALL_AUTONEWSID_SERVICE=安装主机 SID 检查服务
set PLZ_READ_LICENSE=由于此功能需要使用 Sysinternals (http://www.sysinternals.com) 程式,为尊重其软体授权模式,请详细阅读网页上之叙述,并回到本程式以便后续安装
set ANS_IF_AGREE=是否同意授权模式
set NOT_AGREE_EXIT=不同意授权,离开此部分. 将继续其他 drbl-winroll 相关服务安装 
set SHOW_URL=其授权网页请浏览
set SETUP_AUTONEWSID_SERVICE=配置主机 SID 检查服务
set REMOV_AUTONEWSID_SERVICE=移除主机 SID 检查服务
set IF_INSTALL_AUTONEWSID=是否安装‘自动主机 SID’服务
set FIRST_USE_NEWSID=由于您选择安装 autonewsid 服务, 建议您在此主机上先执行此服务, 以便复制后的主机群能顺利执行服务.
set ACCEPT_LICENCE=稍后请接受授权并开始第一次启动服务. 服务执行完后会重新启动电脑.

set NO_ANY_ATTENDED=过程中您无需做任何动作
set REMOVE_REGISTRY=删除注册机码
set COPY_NEEDED_FILES=复制所需档案
set REMOVE_NEEDED_FILES=移除所需档案
set FORCE_TO_NIC_AS_DHCP=程式强制将您的网路卡设定为 DHCP

set IF_INSTALL_SSH_SERVICE=是否配置 sshd 服务
set SETUP_SSHD_SERVICE=安装 sshd 服务并立即启动
set REMOVE_SSHD_SERVICE=停止并移除 sshd 服务
set CREATE_ADMIN_SSH_FOLDER=帮您新增管理者的 ssh 金钥存放路径 
set OPEN_SSHD_PORTON_FIREWALL=程式将帮您于防火墙设定中开启监听  TCP 22 port 给 sshd 连线使用
set NON_DRBL_COMMAND_IF_REMOVE=您如果移除此设定，windows 将无法接收来自 drbl 主机之命令
set UNINSTALL_COMPLETED=移除完成
set REMOVE_SSHD_PORTON_FIREWALL=程式将帮您移除防火墙之启监听 port TCP 22
set FIND_SSH_KEY_IF_IMPORT=发现备份的 ssh key, 需要汇入吗 
set FIND_SSH_KEY_AND_MOVE=发现 ssh key, 将备份至
set PLZ_WAIT_TO_REBOOT=此动作需要进行大量硬读写动作,请务必等待至自统自动重新开机

set FOOTER01=************   恭喜您完成 drbl-winroll 安装  ****************
set FOOTER02=*
set FOOTER03=*   您已经完成 drbl-winroll 的相关软体安装与系统设定！
set FOOTER04=*
set FOOTER05=*   1. 如果您要让您的 windows 能"自动"接受 drbl server 的命令，
set FOOTER06=*   请您参阅 FAQ 中第五项步骤，将您DRBL主机上的 SSH 公钥安装至 windows 。
set FOOTER07=*
set FOOTER08=*   2. 如果您要重新配置布署 Windows(更改序号或安全性识别码SID)
set FOOTER09=*    ，请您参阅 FAQ 中第六项说明
set FOOTER10=*
set FOOTER11=*
set FOOTER12=*   连系我们 :
set FOOTER13=*   Email：ceasar@nchc.org.tw, steven@nchc.org.tw
set FOOTER14=*
set FOOTER15=********  国网中心自由软体实验室  , NCHC ,Taiwan  *********

REM # new add for drbl_winroll-uninstall.bat
set WRONG_OS_VERSION=目前不支援您所使用的作业系统
set PROGRAM_ABORTED=程式中断
set SURE_TO=您确定要
set WARNING=警告
set SERVICES=相关服务
set ANY_KEY_TO_EXIT=任意键离开

REM # Add from v1.2.0-2, 20090909
set SETUP_NETWORK_MODE=设定网路模式
set SELECT_NETWORK_MODE=选择网路模式
set BY_FILE=由本地端档案决定
set SKIP=忽略
set DO_NOTHIMG_FOR_NETWORK=不处理网路设定
set USE_NETWORK_MODE_IS=网路设定模式为
set FORCE_INSTALL=强制安装(适合原先已有需要之 cygwin 环境, 但可能破坏原有之设定)
set RUNSHELL=有在执行中的程序

REM # Add from v1.2.2 , 20100315
set PLEASE_INPUT_NEWSID_PROGRAM_PATH=请输入用来变更 SID 工具的完整路径
set PROGRAM_NOT_FOUND=您所指定程式不存在
set PLEASE_INPUT_NEWSID_PROGRAM_PARAMS=请输入需要的参数, 如:'/a /n';若无则 [Enter] 跳过
set FULL_NEW_SID_COMMAND=完整变更 SID 的指令

REM # Add from v1.2.3 , 20111031
set SETUP_AUTO_ADD2AD_SERVICE=配置自动加入 AD 网域服务
set IF_INSTALL_ADD2AD=是否要配置自动加入 AD 网域服务
set SET_DEFAULT_AD_DOMAIN=请输入 AD 的网域名称
set SET_DEFAULT_AD_USERD=请输入 AD 的管理帐号
set SET_DEFAULT_AD_PASSWORDD=请输入 AD 管理帐号之密码
set SHOW_ADD2AD_RUN_SCRIPT=完整指令为
set NOTE_NETDOM_NECESSITY=请确认系统中有 netdom.exe 执行档

REM # Add from v1.3.0 , 20111108
set _PASSWORD_OF_SYG_SERVER_STORED=SSHD 服务所使用的帐号 cyg_server 之密码被存放在
set _DO_NOT_CHANGE_PASSWORD_OF_CYG_SERVER=请勿变更 cyg_server 帐号之密码或停用此帐号. 那会导致 ssh 服务启动失败

REM # Add from v1.3.1, 20111226
set REMOVE_ADD2AD_SERVICE=移除自动登入 AD 服务
set SETUP_MONITOR_SERVICE=设定 Windows 用户端系统监测服务
set RUN_INSTALLER=执行安装程式 :
set RUN_UNINSTALLER=执行移除程式 :
set REMOVE_MONITOR_SERVICE=移除 Windows 用户端系统监测服务
set PLEASE_INSTALL_MUNIN_AT_SERVER=您必须在监视主机上正确设定 Munin 用户端才能取得系统资讯. 细节请参考 DRBL-winroll 网页.
set IF_INSTALL_MONITOR=是否安装系统监测服务(由Munin Node提供)
