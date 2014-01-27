Outfile nsDialogs.exe
Requestexecutionlevel user

!include nsDialogs.nsh

Page Custom mypagecreate mypageleave
Page Instfiles

Function mypagecreate
Var /Global MyTextbox
Var /Global MyTextbox2
nsDialogs::Create /NOUNLOAD 1018
Pop $0
${NSD_CreateText} 10% 20u 80% 12u "Hello World"
Pop $MyTextbox
${NSD_CreateText} 10% 30u 50% 12u "Hello World2"
Pop $MyTextbox2
nsDialogs::Show
FunctionEnd

Function mypageleave
${NSD_GetText} $MyTextbox $0
${NSD_GetText} $MyTextbox2 $1
MessageBox mb_ok $0,$1
Abort ;Don't move to next page (If the input was invalid etc)
FunctionEnd

Section
SectionEnd
