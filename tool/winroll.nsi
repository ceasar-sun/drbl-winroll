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
OutFile "drbl-winroll-setup.exe"

;預設的安裝程式目錄在 Program Files 裡
InstallDir "$TEMP"
;InstallDir "c:\.tmp.winroll"

;底下開始是安裝程式所要執行的
Section "Install"

;設定輸出的路徑在安裝程式的目錄
SetOutPath $INSTDIR

;貼上你所要包裝在安裝程式裡的檔案
File /r ".\drbl-winroll\*"

Exec '"$INSTDIR\winroll-setup.bat"'

SectionEnd
;安裝程式過程到此結束


; eof

