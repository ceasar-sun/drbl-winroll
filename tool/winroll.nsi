;***************  drbl-winRoll NSIS script **************
;
;     ������ߦۥѳn������  , NCHC ,Taiwan
;     License	:	GPL      
;     Author	:	ceasar at nchc_org_tw , steven at nchc_org_tw
;
;    Note: Please put the file and drbl-winroll root dircetory on same path
;*********************************************************

;�ŧi�n��W�١A�᭱�i�H�Q�� ${NAME} �եγo�ӦW�r
!define NAME "drbl-winroll"

;�]�w�r��
SetFont �s�ө��� 9

;�ϥ� WindowsXP ��ı�˦�
XPstyle on

; �Ψ쪺 MSIS-plugin dll �ؿ�
!addplugindir .\nsis-plugin
!include LogicLib.nsh
!include ".\nsis-plugin\UAC.nsh"

RequestExecutionLevel user

;�w�˵��������D�W��
;Caption  "�w�� drbl-winRoll �\��"
Caption  "Install drbl-winroll package"

;�����w�]�����s��r
;MiscButtonText "< �W�@�B" "�U�@�B >" "����" "����"
MiscButtonText "< Last" "Next >" "Cancel" "Close"

;�����w�]�����s��r
InstallButtonText "�w��"

;�����w�]�����s��r
UninstallButtonText "�Ϧw��"

;�����Ϧw�˵{�Ǫ���r
;DirText "�w��z�w�� ${NAME} �o�O��" "�п�ܱ��w�� ${NAME} ���ؿ��G" "�s��..."

;�����Ϧw�˵{�Ǫ���r
UninstallText "�{�b�N�q�A���t�Τ��Ϧw�� ${NAME} �C"

;�����Ϧw�˵{�Ǽ��D����r
UninstallCaption "�Ϧw�� ${NAME}"

;�����Ϧw�˵{�Ǫ���r
;DetailsButtonText "��ܸԲӹL�{"
DetailsButtonText "Show detail"

;�����Ϧw�˫��s����r
UninstallButtonText "�Ϧw��"

;�Ϧw�˵{����ܤ覡 �w�]�O����
ShowUninstDetails hide

;�����Ŷ�����r
SpaceTexts "�һݪ��Ŷ� " "�i�Ϊ��Ŷ� "

;�o�Ӧw�˵{�����W��
Name "DRBL-winroll-setup"

;��X�s�@�������w�˵{���ɮ�
OutFile "..\..\drbl-winroll-setup.exe"

; �ݭn�޲z���v��
RequestExecutionLevel user

;�w�]���w�˵{���ؿ��b Program Files ��
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


;���U�}�l�O�w�˵{���ҭn���檺
Section "Install"

;�]�w��X�����|�b�w�˵{�����ؿ�
SetOutPath $INSTDIR

;�K�W�A�ҭn�]�˦b�w�˵{���̪��ɮ�
File /r "..\..\drbl-winroll\*"

;!insertmacro UAC_RunElevated
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
; eof

