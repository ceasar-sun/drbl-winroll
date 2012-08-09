;***************  drbl-winRoll NSIS script **************
;
;     ������ߦۥѳn������  , NCHC ,Taiwan
;     License	:	GPL      
;     Author	:	ceasar at nchc_org_tw , steven at nchc_org_tw
;
;    Note: Please put the file and drbl-winroll root dircetory on same path
;*********************************************************

; HM NIS Edit Wizard helper defines
!define PRODUCT_NAME "DRBL-Winroll"
!define PRODUCT_VERSION "2.0.0"
!define PRODUCT_PUBLISHER "Free Software Lab, NCHC"
!define PRODUCT_WEB_SITE "http://drbl-winroll.org/"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\cyg-setup.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

; �Ψ쪺 MSIS-plugin dll �ؿ�
!addplugindir ".\nsis-plugin"
!include LogicLib.nsh
!include MUI2.nsh
!include ".\nsis-plugin\UAC.nsh"

RequestExecutionLevel user ; << Required, you cannot use admin!

; MUI Settings
!define MUI_ABORTWARNING
;!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
;!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"
;�]�w�r��
SetFont �s�ө��� 9
;�ϥ� WindowsXP ��ı�˦�
XPstyle on

; Language Selection Dialog Settings
!define MUI_LANGDLL_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_LANGDLL_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_LANGDLL_REGISTRY_VALUENAME "NSIS:Language"


!macro Init thing
uac_tryagain:
!insertmacro UAC_RunElevated
MessageBox MB_OK "Shloud not be here :$0,$1,$3" 
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
!insertmacro MUI_PAGE_LICENSE "..\..\drbl-winroll\doc\LICENSE.cygwin"
; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
;!define MUI_FINISHPAGE_RUN "$INSTDIR\sbin\wsname.exe"
;!insertmacro MUI_PAGE_FINISH

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
OutFile "..\..\${PRODUCT_NAME}-${PRODUCT_VERSION}-setup.exe"
InstallDir "c:\cygwin"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails show
ShowUnInstDetails show


Function .onInit
!insertmacro Init "installer"
!insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

;�w�]���w�˵{���ؿ��b Program Files ��
InstallDir "$TEMP"
 
;���U�}�l�O�w�˵{���ҭn���檺
Section "Install" SEC01
	;�]�w��X�����|�b�w�˵{�����ؿ�
	SetOutPath $INSTDIR

	;�K�W�A�ҭn�]�˦b�w�˵{���̪��ɮ�
	File /r "..\..\drbl-winroll\*"

	ExecWait '"$INSTDIR\winroll-setup.bat"'
SectionEnd
;�w�˵{���L�{�즹����

; �}�� TCP 22 for sshd at personal firewall
Section "CheckFirewall" SEC02
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

; End here
!macro Quit thing
	Quit
!macroend

; EOF