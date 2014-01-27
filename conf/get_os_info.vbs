' How to use :cscript //Nologo get_os_nic_info.vbs
' http://msdn.microsoft.com/en-us/library/Aa394217

Wscript.Echo "@echo off"
Wscript.Echo "REM # This cmd file is auto-generated by cscript //nologo gen_os_info.vbs "

Print_System_Startmenu_Path()
UserPerms("admin")
UACTurnedOn()
Print_System_Administrator_Account()
Print_System_Information()

'' Sub function ''
Function Print_System_Startmenu_Path()
	'Dim WshShell
	Set WshShell = WScript.CreateObject("WScript.Shell")
	Wscript.Echo "set STARTMENU_PATH=" & WshShell.SpecialFolders("AllUsersPrograms") & "\cygwin"
End Function ' Function Print_System_Startmenu_Path()

Function UserPerms (PermissionQuery)          
	UserPerms = False  ' False unless proven otherwise           
	Dim CheckFor, CmdToRun         

	Select Case Ucase(PermissionQuery)           
	'Setup aliases here           
	Case "ELEVATED"           
		CheckFor =  "S-1-16-12288"           
	Case "ADMIN"           
		CheckFor =  "S-1-5-32-544"           
	Case "ADMINISTRATOR"           
		CheckFor =  "S-1-5-32-544"           
	Case Else                  
		CheckFor = PermissionQuery                  
	End Select           

	CmdToRun = "%comspec% /c whoami /all | findstr /I /C:""" & CheckFor & """"
	Dim oShell, returnValue        
	Set oShell = CreateObject("WScript.Shell")  
	returnValue = oShell.Run(CmdToRun, 0, true)
	If returnValue = 0 Then UserPerms = True
	Wscript.Echo   "set UserPerms=" & UserPerms
End Function

Function UACTurnedOn ()
	On Error Resume Next

	Set oShell = CreateObject("WScript.Shell")
	If oShell.RegRead("HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System\EnableLUA") = 0 Then
		UACTurnedOn = false
	Else
		UACTurnedOn = true
	End If
	Wscript.Echo   "set UACTurnedOn=" & UACTurnedOn
End Function

Function Print_System_Administrator_Account()
	strComputer = "."

	Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
	Set colAccounts = objWMIService.ExecQuery ("Select * From Win32_UserAccount Where LocalAccount = TRUE")

	For Each objAccount in colAccounts
		If Left (objAccount.SID, 6) = "S-1-5-" and Right(objAccount.SID, 4) = "-500" Then
		    Wscript.Echo "set ROOT_NAME=" & objAccount.Name
		End If
	Next
End Function ' Function Print_System_Administrator_Account()

Function Print_System_Information()
	strComputer = "."
	Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2")  
	Set colOperatingSystems = objWMIService.ExecQuery ("Select * from Win32_OperatingSystem")
		
	For Each objOperatingSystem in colOperatingSystems		
		if ( Instr( objOperatingSystem.Caption, "Windows XP") > 0 ) then
			OS_VERSION = "WINXP"
		elseif ( Instr( objOperatingSystem.Caption, "2000") > 0 ) then
			OS_VERSION = "WIN2000"
		elseif ( Instr( objOperatingSystem.Caption, "2003") > 0 ) then
			OS_VERSION = "WIN2003"
		elseif ( Instr( objOperatingSystem.Caption, "2008") > 0 ) then
			OS_VERSION = "WIN2008"
		elseif ( Instr( objOperatingSystem.Caption, "Vista") > 0 ) then
			OS_VERSION = "Vista"
		elseif ( Instr( objOperatingSystem.Caption, "Windows 7") > 0 ) then
			OS_VERSION = "WIN7"
		elseif ( Instr( objOperatingSystem.Caption, "Developer Preview") > 0 ) then
			OS_VERSION = "WIN8"
		elseif ( Instr( objOperatingSystem.Caption, "Windows 8") > 0 ) then
			OS_VERSION = "WIN8"
		else
			OS_VERSION = "NONE"
		End If		
		Wscript.Echo  "set LOCALE_CODE=" & objOperatingSystem.Locale
		Wscript.Echo  "set OS_VERSION=" & OS_VERSION

		Wscript.Echo "REM Code Set: " & objOperatingSystem.CodeSet
		Wscript.Echo "REM OS Language: " & objOperatingSystem.OSLanguage
		Wscript.Echo "REM Version: " & objOperatingSystem.Version
		Wscript.Echo "REM OSArchitecture: " & objOperatingSystem.OSArchitecture
	Next
		
End Function  ' Function Print_System_Information()
