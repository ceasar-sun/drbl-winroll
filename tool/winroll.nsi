;***************  drbl-winroll NSIS script **************
;
;     國網中心自由軟體實驗室  , NCHC ,Taiwan
;     License	:	GPL      
;     Author	:	ceasar at nchc_org_tw , steven at nchc_org_tw
;
;    Note: Please put the file and drbl-winroll root dircetory on same path
;*********************************************************

; HM NIS Edit Wizard helper defines
!define PRODUCT_NAME "DRBL-Winroll"
!define PRODUCT_PACK_NAME "drbl-winroll"
!define PRODUCT_VERSION "ungit"
!define PRODUCT_PUBLISHER "Free Software Lab, NCHC"
!define PRODUCT_WEB_SITE "http://drbl-winroll.org/"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\cyg-setup.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

; 用到的 MSIS-plugin dll 目錄
!addplugindir ".\nsis-plugin"
;!include LogicLib.nsh
!include MUI2.nsh
; UAV Version: not 0.2.4c (20150526)
; Ref:http://nsis.sourceforge.net/UAC_plug-in
!include ".\nsis-plugin\UAC.nsh"

RequestExecutionLevel user ; << Required, you cannot use admin!

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\orange-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\orange-install-nsis.ico"

; Language Selection Dialog Settings
!define MUI_LANGDLL_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_LANGDLL_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_LANGDLL_REGISTRY_VALUENAME "NSIS:Language"


!macro Init thing
uac_tryagain:
!insertmacro UAC_RunElevated
;MessageBox MB_OK "UAC_RunElevated return :0=$0,1=$1,2=$3" 
${Switch} $0
${Case} 0
	${IfThen} $1 = 1 ${|} Quit ${|} ;we are the outer process, the inner process has done its work, we are done
	${IfThen} $3 <> 0 ${|} ${Break} ${|} ;we are admin, let the show go on
	${If} $1 = 3 ;RunAs completed successfully, but with a non-admin user
		MessageBox mb_YesNo|mb_IconExclamation|mb_TopMost|mb_SetForeground "This ${thing} requires admin privileges, try again" /SD IDNO IDYES uac_tryagain IDNO 0
	${EndIf}
	;fall-through and die
${Case} 1223
	MessageBox mb_IconStop|mb_TopMost|mb_SetForeground "This ${thing} requires admin privileges, aborting!"
	Quit
${Case} 1062
	MessageBox mb_IconStop|mb_TopMost|mb_SetForeground "Logon service not running, aborting!"
	Quit
${Default}
	MessageBox mb_IconStop|mb_TopMost|mb_SetForeground "Unable to elevate , error $0"
	Quit
${EndSwitch}

SetShellVarContext all
!macroend

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; License page
!insertmacro MUI_PAGE_LICENSE "..\..\drbl-winroll\doc\LICENSE.drbl-winroll"
; Components page
!insertmacro MUI_PAGE_COMPONENTS
; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_TEXT "Visit ${PRODUCT_NAME} web site "
!define MUI_FINISHPAGE_RUN_NOTCHECKED
!define MUI_FINISHPAGE_RUN_FUNCTION PageFinishRun
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
;!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "Dutch"
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "French"
!insertmacro MUI_LANGUAGE "Spanish"
!insertmacro MUI_LANGUAGE "Swedish"
!insertmacro MUI_LANGUAGE "TradChinese"
; MUI end ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "..\..\${PRODUCT_PACK_NAME}-${PRODUCT_VERSION}-setup.exe"
InstallDir "c:\cygwin"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails show
ShowUnInstDetails show

Function .onInit
	!insertmacro Init "installer"
	!insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

Function PageFinishRun
	; You would run "$InstDir\MyApp.exe" here but this example has no application to execute...
	!insertmacro UAC_AsUser_ExecShell "" "${PRODUCT_WEB_SITE}" "" "" ""
FunctionEnd

;底下開始是安裝程式所要執行的
Section "Main" SEC01
	SectionIn RO
	;設定輸出的路徑在安裝程式的目錄
	SetOutPath $TEMP

	;貼上你所要包裝在安裝程式裡的檔案
	File /r /x .git /x _dev  ..\..\drbl-winroll\*
	ExecWait '"$TEMP\winroll-setup.bat"'
	
	; to hide cyg_server account in x64 OS
	SetRegView 64
	WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" "cyg_server" 0
	
SectionEnd
;安裝程式過程到此結束

;  開啟 TCP 22 for sshd at personal firewall
; NSIS_Simple_Firewall_Plugin_1.20.zip
; SimpleFC::AddPort [port] [name] [protocol] [scope] [ip_version] [remote_addresses] [status]
; http://nsis.sourceforge.net/NSIS_Simple_Firewall_Plugin

Section "Add ssh exception at firewall" SEC02
	SimpleFC::AddPort 22 "Cygwin sshd" 6 0 2 "" 1
	Pop $0 ; return error(1)/success(0)
	${If} $0 == "0"
		MessageBox MB_OK "Add the port 22/TCP to the firewall exception list , Success: '$0'"
	${ElseIF} $0 == "1"
		MessageBox MB_OK "Add the port 22/TCP to the firewall exception list , Error: '$0'"
	${Else}
		MessageBox MB_OK "Shloud not be here :'$0'"
	${EndIf}
SectionEnd

; EOF
