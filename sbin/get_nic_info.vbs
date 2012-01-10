' 
' How to use :cscript //Nologo get_os_nic_info.vbs
' http://msdn.microsoft.com/en-us/library/Aa394217


Print_OnlyEnabled_NICAdapter_Information()

Function Print_OnlyEnabled_NICAdapter_information()
	strComputer = "." 
	Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2") 
	Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_NetworkAdapter WHERE NetConnectionId IS NOT NULL")
	i = 0
	For Each objItem in colItems 
        i = i + 1
		'strComputer = "."
		'Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2")
		'Wscript.Echo objItem.MACAddress & vbtab & objItem.NetConnectionId 
		Set devItems = objWMIService.ExecQuery("SELECT * FROM Win32_NetworkAdapterConfiguration where IPEnabled=TRUE AND MACAddress='" & objItem.MACAddress & "'" ,,48)
		j = 0
		For Each devItem in devItems
			j = j + 1
			'Wscript.Echo devItem.MACAddress
			strIPAddress = GetMultiString_FromArray(devItem.IPAddress, ",")
			strIPSubnet = GetMultiString_FromArray(devItem.IPSubnet, ",")
			Wscript.Echo Replace(objItem.MACAddress, ":", "-") & vbtab & objItem.NetConnectionId & vbtab & strIPAddress & vbtab & strIPSubnet
		Next
	Next
End Function ' Function PrintOnlyEnabled_NICAdapter_Information()

Function GetMultiString_FromArray( ArrayString, Seprator)
    If IsNull ( ArrayString ) Then
        StrMultiArray = ArrayString
    else
        StrMultiArray = Join( ArrayString, Seprator )
   end if
   GetMultiString_FromArray = StrMultiArray
  
End Function