''' to query Windows registry key , use "cscript *.vbs" to get value to std out
''' Auther : Ceasar SUn

Dim WSHShell   		: Set WshShell = CreateObject("WScript.Shell")
Dim WshNetwork 		: Set WshNetwork = CreateObject("WScript.Network")
Dim oDic       		: Set oDic = CreateObject("Scripting.Dictionary")
Dim objArgs    		: Set objArgs = WScript.Arguments
Dim oSystemEnv 		: Set oSystemEnv = WshShell.Environment("SYSTEM")
Dim oProcessEnv   	: Set oProcessEnv = WshShell.Environment("PROCESS")	

If objArgs.Count > 0 Then ''若有參數
	sRegKey = objArgs(0) ''讀入參數
	''WScript.Echo sRegKey
	WScript.Echo WshShell.RegRead(sRegKey)
else 
	WScript.echo "Need to assign a registry key"
End If

