;***************  drbl-winRoll NSIS script **************
;
;     國網中心自由軟體實驗室  , NCHC ,Taiwan
;     License	:	GPL      
;     Author	:	ceasar at nchc_org_tw , steven at nchc_org_tw
;
;    Note: Please put the file and drbl-winroll root dircetory on same path
;*********************************************************

;宣告軟體名稱，後面可以利用 ${NAME} 調用這個名字
!define NAME "drbl-winroll"

;設定字型
SetFont 新細明體 9

;使用 WindowsXP 視覺樣式
XPstyle on

; 用到的 MSIS-plugin dll 目錄
!addplugindir .\nsis-plugin
!include LogicLib.nsh
!include ".\nsis-plugin\UAC.nsh"

RequestExecutionLevel user

;安裝視窗的標題名稱
;Caption  "安裝 drbl-winRoll 功能"
Caption  "Install drbl-winroll package"

;替換預設的按鈕文字
;MiscButtonText "< 上一步" "下一步 >" "取消" "關閉"
MiscButtonText "< Last" "Next >" "Cancel" "Close"

;替換預設的按鈕文字
InstallButtonText "安裝"

;替換預設的按鈕文字
UninstallButtonText "反安裝"

;替換反安裝程序的文字
;DirText "歡迎您安裝 ${NAME} 這是個" "請選擇欲安裝 ${NAME} 的目錄：" "瀏覽..."

;替換反安裝程序的文字
UninstallText "現在將從你的系統中反安裝 ${NAME} 。"

;替換反安裝程序標題的文字
UninstallCaption "反安裝 ${NAME}"

;替換反安裝程序的文字
;DetailsButtonText "顯示詳細過程"
DetailsButtonText "Show detail"

;替換反安裝按鈕的文字
UninstallButtonText "反安裝"

;反安裝程序顯示方式 預設是隱藏
ShowUninstDetails hide

;替換空間的文字
SpaceTexts "所需的空間 " "可用的空間 "

;這個安裝程式的名稱
Name "DRBL-winroll-setup"

;輸出製作完成的安裝程式檔案
OutFile "..\..\drbl-winroll-setup.exe"

; 需要管理者權限
RequestExecutionLevel user

;預設的安裝程式目錄在 Program Files 裡
InstallDir "$TEMP"
;InstallDir "c:\.tmp.winroll"

!macro Init thing
uac_tryagain:
!insertmacro UAC_RunElevated
${Switch} $0
${Case} 0
	${IfThen} $1 = 1 ${|} Quit ${|} ;we are the outer process, the inner process has done its work, we are done
	${IfThen} $3 <> 0 ${|} MessageBox MB_OK "Shloud not be here :'$0'" ${Break} ${|} ;we are admin, let the show go on
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

; End here
!macro Quit thing
	Quit
!macroend


;底下開始是安裝程式所要執行的
Section "Install"

;設定輸出的路徑在安裝程式的目錄
SetOutPath $INSTDIR

;貼上你所要包裝在安裝程式裡的檔案
File /r "..\..\drbl-winroll\*"

;!insertmacro UAC_RunElevated
ExecWait '"$INSTDIR\winroll-setup.bat"'

SectionEnd
;安裝程式過程到此結束

; 開啟 TCP 22 for sshd at personal firewall
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
; eof

