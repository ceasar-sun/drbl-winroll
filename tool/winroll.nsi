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
OutFile "drbl-winroll-setup.exe"

;�w�]���w�˵{���ؿ��b Program Files ��
InstallDir "$TEMP"
;InstallDir "c:\.tmp.winroll"

;���U�}�l�O�w�˵{���ҭn���檺
Section "Install"

;�]�w��X�����|�b�w�˵{�����ؿ�
SetOutPath $INSTDIR

;�K�W�A�ҭn�]�˦b�w�˵{���̪��ɮ�
File /r ".\drbl-winroll\*"

Exec '"$INSTDIR\winroll-setup.bat"'

SectionEnd
;�w�˵{���L�{�즹����


; eof

