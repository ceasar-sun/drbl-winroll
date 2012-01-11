@echo off

REM ############################
REM # Global parameter
REM ############################

REM ############################
REM # Language descripation

set YOUR_LANGUAGE_IS=您的系統語言是
set LANGUAGE_DESC=繁體中文
set TRANSLATOR=ceasar@nchc.org.tw

REM ############################
set HEAD01=*********   歡迎使用 drbl-winroll 安裝程式  ******************
set HEAD02=*
set HEAD03=*      國網中心自由軟體實驗室  , NCHC ,Taiwan
set HEAD04=*      License: GPL      
set HEAD05=*
set HEAD06=*     本程式會進行軟體安裝與系統設定以解決 clone windows 後 hostname 
set HEAD07=*     一樣的問題，並提供 windows  在  drbl 環境下之相關功能  
set HEAD08=*     注意事項：
set HEAD09=*     1. 本程式建議以 Administrator 身份執行
set HEAD10=*     2. 若您之前已安裝過 cygwin 於 c:\cygwin，建議先移除或選擇[f](強制安裝)
set HEAD11=*     3. 本程式適用於 Windows 2K,XP,Server(2003,2008),Vista,Win 7 等版本
set HEAD12=*
set HEAD13=*    譯者 : 
set HEAD14=*        %LANGUAGE_DESC%  :  %TRANSLATOR%
set HEAD15=*********************************************************

set HR====================================================
set NEXT_STEP=下一步

set YOUR_CURRENT_ACCOUNT_IS=您目前的身份為
set PLZ_CONFIRM_ADMIN_ACCOUNT=請確地您目前有 Administrator 之權限
set IF_KEEP_GO=使用 [Ctrl+c] 離開 或按任意鍵繼續
set YOUR_OS_VERSION_IS=您的作業系統版本為
set START_TO=開始進行
set INSTALL=安裝
set INSTALLED=已經安裝
set REINSTALL=重新安裝
set UNINSTALL=解除安裝
set REMOVE=解除

set PLZ_CHOOSE=請選擇
set DIRECTORY=目錄
set STARTMENU=程式集選單
set LOCAL_REPOSITORY_DIRECTORY=本地儲藏庫目錄
set CREATE_WINROLL_CONFIG=建立 drbl-winroll 設定檔

REM ############################
REM # Messages for cygwin installation error

set ERR_DIR_DONT_EXIST=ERROR: Local repository does not exists: 
set ERR_REP_DONT_EXIST=ERROR: Invalid local repository. Missing directory:
set ERR_FIL_DONT_EXIST=ERROR: Invalid local repository. Missing file:
set ERR_CYGWIN_SETUP_DONT_EXIST=ERROR: Could not find Cygwin setup.exe in the cygwin_mirror\ directory of the local repository:
set INSTALL_WINROLL_SERVICE=安裝 drbl-winroll 主服務

set INSTALL_AUTOHOSTNAME_SERVICE=安裝主機名稱檢查服務
set SETUP_AUTOHOSTNAME_SERVICE=配置主機名稱檢查服務
set REMOV_WINROLL_SERVICE=移除 drbl-winroll 主服務
set REMOV_AUTOHOSTNAME_SERVICE=移除主機名稱檢查服務
set IF_INSTALL_AUTOHOSTNAME=是否安裝『自動主機名稱』服務
set SELECT_HOSTNAME_FORMAT%=請選擇您想要主機名稱樣式
set BY_IP=ip (取後面6碼數字, ex: XXX-001-001)
set BY_MAC=Mac address (取後面6碼字元,  ex: XXX-3D9C51)
set BY_HOSTS_FILE=由本地端檔案決定
set MORE_DETAIIL_TO_REFER=詳細設定請參考
set SET_HOSTNAME_PREFIX=設定主機名稱的前置字元(如果由本地端檔案決定則不受影響，且全部字串不可超過 15個字元)

set IF_INSTALL_AUTOWG=是否也啟動『自動工作群組名稱』
set SHOW_HOSTNAME_FORMAT=所使用的電腦主機名稱參數為
set SELECT_WORKGROUP_FORMAT=請選擇工作群組樣式
set FIXED=固定字串
set DNS_SUFFIX=由DNS 指定
set SHOW_WORKGROUP_FORMAT=所使用的工作群組名稱參數為
set SET_WG_PREFIX=設定群組名稱的前置字元

set INSTALL_AUTONEWSID_SERVICE=安裝主機 SID 檢查服務
set PLZ_READ_LICENSE=由於此功能需要使用 Sysinternals (http://www.sysinternals.com) 程式,為尊重其軟體授權模式,請詳細閱讀網頁上之敘述,並回到本程式以便後續安裝
set ANS_IF_AGREE=是否同意授權模式
set NOT_AGREE_EXIT=不同意授權,離開此部分. 將繼續其他 drbl-winroll 相關服務安裝 
set SHOW_URL=其授權網頁請瀏覽
set SETUP_AUTONEWSID_SERVICE=配置主機 SID 檢查服務
set REMOV_AUTONEWSID_SERVICE=移除主機 SID 檢查服務
set IF_INSTALL_AUTONEWSID=是否安裝『自動主機 SID』服務
set FIRST_USE_NEWSID=由於您選擇安裝 autonewsid 服務, 建議您在此主機上先執行此服務, 以便複製後的主機群能順利執行服務.
set ACCEPT_LICENCE=稍後請接受授權並開始第一次啟動服務. 服務執行完後會重新啟動電腦.

set NO_ANY_ATTENDED=過程中您無需做任何動作
set REMOVE_REGISTRY=刪除註冊機碼
set COPY_NEEDED_FILES=複製所需檔案
set REMOVE_NEEDED_FILES=移除所需檔案
set FORCE_TO_NIC_AS_DHCP=程式強制將您的網路卡設定為 DHCP

set IF_INSTALL_SSH_SERVICE=是否配置 sshd 服務
set SETUP_SSHD_SERVICE=安裝 sshd 服務並立即啟動
set REMOVE_SSHD_SERVICE=停止並移除 sshd 服務
set CREATE_ADMIN_SSH_FOLDER=幫您新增管理者的 ssh 金鑰存放路徑 
set OPEN_SSHD_PORTON_FIREWALL=程式將幫您於防火牆設定中開啟監聽  TCP 22 port 給 sshd 連線使用
set NON_DRBL_COMMAND_IF_REMOVE=您如果移除此設定，windows 將無法接收來自 drbl 主機之命令
set UNINSTALL_COMPLETED=移除完成
set REMOVE_SSHD_PORTON_FIREWALL=程式將幫您移除防火牆之啟監聽 port TCP 22
set FIND_SSH_KEY_IF_IMPORT=發現備份的 ssh key, 需要匯入嗎 
set FIND_SSH_KEY_AND_MOVE=發現 ssh key, 將備份至
set PLZ_WAIT_TO_REBOOT=此動作需要進行大量硬讀寫動作,請務必等待至自統自動重新開機

set FOOTER01=************   恭喜您完成 drbl-winroll 安裝  ****************
set FOOTER02=*
set FOOTER03=*   您已經完成 drbl-winroll 的相關軟體安裝與系統設定！
set FOOTER04=*
set FOOTER05=*   1. 如果您要讓您的 windows 能"自動"接受 drbl server 的命令，
set FOOTER06=*   請您參閱 FAQ 中第五項步驟，將您DRBL主機上的 SSH 公鑰安裝至 windows 。
set FOOTER07=*
set FOOTER08=*   2. 如果您要重新配置佈署 Windows(更改序號或安全性識別碼SID)
set FOOTER09=*    ，請您參閱 FAQ 中第六項說明
set FOOTER10=*
set FOOTER11=*
set FOOTER12=*   連繫我們 :
set FOOTER13=*   Email：ceasar@nchc.org.tw, steven@nchc.org.tw
set FOOTER14=*
set FOOTER15=********  國網中心自由軟體實驗室  , NCHC ,Taiwan  *********

REM # new add for drbl_winroll-uninstall.bat
set WRONG_OS_VERSION=目前不支援您所使用的作業系統
set PROGRAM_ABORTED=程式中斷
set SURE_TO=您確定要
set WARNING=警告
set SERVICES=相關服務
set ANY_KEY_TO_EXIT=任意鍵離開

REM # Add from v1.2.0-2, 20090909
set SETUP_NETWORK_MODE=設定網路模式
set SELECT_NETWORK_MODE=選擇網路模式
set BY_FILE=由本地端檔案決定
set SKIP=忽略
set DO_NOTHIMG_FOR_NETWORK=不處理網路設定
set USE_NETWORK_MODE_IS=網路設定模式為
set FORCE_INSTALL=強制安裝(適合原先已有需要之 cygwin 環境, 但可能破壞原有之設定)
set RUNSHELL=有在執行中的程序

REM # Add from v1.2.2 , 20100315
set PLEASE_INPUT_NEWSID_PROGRAM_PATH=請輸入用來變更 SID 工具的完整路徑
set PROGRAM_NOT_FOUND=您所指定程式不存在
set PLEASE_INPUT_NEWSID_PROGRAM_PARAMS=請輸入需要的參數, 如:'/a /n';若無則 [Enter] 跳過
set FULL_NEW_SID_COMMAND=完整變更 SID 的指令

REM # Add from v1.2.3 , 20111031
set SETUP_AUTO_ADD2AD_SERVICE=配置自動加入 AD 網域服務
set IF_INSTALL_ADD2AD=是否要配置自動加入 AD 網域服務
set SET_DEFAULT_AD_DOMAIN=請輸入 AD 的網域名稱
set SET_DEFAULT_AD_USERD=請輸入 AD 的管理帳號
set SET_DEFAULT_AD_PASSWORDD=請輸入 AD 管理帳號之密碼
set SHOW_ADD2AD_RUN_SCRIPT=完整指令為
set NOTE_NETDOM_NECESSITY=請確認系統中有 netdom.exe 執行檔

REM # Add from v1.3.0 , 20111108
set _PASSWORD_OF_SYG_SERVER_STORED=SSHD 服務所使用的帳號 cyg_server 之密碼被存放在
set _DO_NOT_CHANGE_PASSWORD_OF_CYG_SERVER=請勿變更 cyg_server 帳號之密碼或停用此帳號. 那會導致 ssh 服務啟動失敗

REM # Add from v1.3.1, 20111226
set REMOVE_ADD2AD_SERVICE=移除自動登入 AD 服務
set SETUP_MONITOR_SERVICE=設定 Windows 用戶端系統監測服務
set RUN_INSTALLER=執行安裝程式 :
set RUN_UNINSTALLER=執行移除程式 :
set REMOVE_MONITOR_SERVICE=移除 Windows 用戶端系統監測服務
set PLEASE_INSTALL_MUNIN_AT_SERVER=您必須在監視主機上正確設定 Munin 用戶端才能取得系統資訊. 細節請參考 DRBL-winroll 網頁.
set IF_INSTALL_MONITOR=是否安裝系統監測服務(由Munin Node提供)
