;***************  drbl-winRoll NSIS script **************
;
;     國網中心自由軟體實驗室  , NCHC ,Taiwan
;     License	:	GPL      
;     Author	:	ceasar at nchc_org_tw , steven at nchc_org_tw
;
;    Note: Please put the file and drbl-winroll root dircetory on same path
;*********************************************************

;設定字型
SetFont 新細明體 9

;使用 WindowsXP 視覺樣式
XPstyle on

!define S_NAME "DRBL-Winroll"
Name "${S_NAME}"
OutFile "..\..\${S_NAME}-setup-new.exe"
RequestExecutionLevel user

; 用到的 MSIS-plugin dll 目錄
!addplugindir "./nsis-plugin"
!include MUI2.nsh
!include UAC.nsh

!macro Init thing
uac_tryagain:
!insertmacro UAC_RunElevated
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

;Function .onInit
;!insertmacro Init "installer"
;FunctionEnd

;Function un.onInit
;!insertmacro Init "uninstaller"
;FunctionEnd

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
;!define MUI_FINISHPAGE_RUN
;!define MUI_FINISHPAGE_RUN_FUNCTION PageFinishRun
;!insertmacro MUI_PAGE_FINISH

;!insertmacro MUI_UNPAGE_CONFIRM
;!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"


Function PageFinishRun
; You would run "$InstDir\MyApp.exe" here but this example has no application to execute...
!insertmacro UAC_AsUser_ExecShell "" "$WinDir\notepad.exe" "" "" ""
FunctionEnd

;預設的安裝程式目錄在 Program Files 裡
InstallDir "$TEMP"

Section
;SetOutPath $InstDir
# TODO: File "MyApp.exe"
;WriteUninstaller "$InstDir\Uninstall.exe"

;設定輸出的路徑在安裝程式的目錄
SetOutPath $TEMP

;貼上你所要包裝在安裝程式裡的檔案
File /r "..\..\drbl-winroll\*"

;!insertmacro UAC_RunElevated
Exec '"$INSTDIR\winroll-setup.bat"'

SectionEnd

Section Uninstall
SetOutPath $Temp ; Make sure $InstDir is not the current directory so we can remove it
# TODO: Delete "$InstDir\MyApp.exe"
;Delete "$InstDir\Uninstall.exe"
;RMDir "$InstDir"

Exec '"$APPDATA\drbl_winroll-uninstall.bat"'

SectionEnd