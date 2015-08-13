' 
' How to use :cscript //Nologo get_os_nic_info.vbs
' http://msdn.microsoft.com/en-us/library/Aa394217

'Print_Registry_Value()
'Print_System_Administrator_Account()
Print_System_Information()
Print_OnlyEnabled_NICAdapter_Information()

'' Sub function ''
Function Print_Registry_Value()
	Dim WSHShell   		: Set WshShell = CreateObject("WScript.Shell")
	Dim objArgs    		: Set objArgs = WScript.Arguments

	If objArgs.Count > 0 Then ''若有參數
		sRegKey = objArgs(0) ''讀入參數
		WScript.Echo WshShell.RegRead(sRegKey)
	else 
		WScript.Echo WshShell.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProductName")
		WScript.Echo WshShell.RegRead("HKEY_CURRENT_USER\Control Panel\International\Locale")
		WScript.Echo WshShell.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\Common Programs")
	End If
End Function ' Print_Registry_Value()

Function Print_System_Administrator_Account()
	strComputer = "."

	Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")

	Set colAccounts = objWMIService.ExecQuery _
		("Select * From Win32_UserAccount Where LocalAccount = TRUE")

	For Each objAccount in colAccounts
		If Left (objAccount.SID, 6) = "S-1-5-" and Right(objAccount.SID, 4) = "-500" Then
		    Wscript.Echo objAccount.Name
		End If
	Next
End Function ' Function Print_System_Administrator_Account()

Function Print_System_Information()
	Set dtmConvertedDate = CreateObject("WbemScripting.SWbemDateTime")

	strComputer = "."
	Set objWMIService = GetObject("winmgmts:" _
		& "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")

	Set colOperatingSystems = objWMIService.ExecQuery _
		("Select * from Win32_OperatingSystem")

	For Each objOperatingSystem in colOperatingSystems
		Wscript.Echo "Boot Device: " & objOperatingSystem.BootDevice
		Wscript.Echo "Build Number: " & objOperatingSystem.BuildNumber
		Wscript.Echo "Build Type: " & objOperatingSystem.BuildType
		Wscript.Echo "Caption: " & objOperatingSystem.Caption
		Wscript.Echo "Code Set: " & objOperatingSystem.CodeSet
		Wscript.Echo "Locale: " & objOperatingSystem.Locale
		Wscript.Echo "Country Code: " & objOperatingSystem.CountryCode
		Wscript.Echo "Debug: " & objOperatingSystem.Debug
		Wscript.Echo "Encryption Level: " & objOperatingSystem.EncryptionLevel
		dtmConvertedDate.Value = objOperatingSystem.InstallDate
		dtmInstallDate = dtmConvertedDate.GetVarDate
		Wscript.Echo "Install Date: " & dtmInstallDate 
		Wscript.Echo "Licensed Users: " & objOperatingSystem.NumberOfLicensedUsers
		Wscript.Echo "Organization: " & objOperatingSystem.Organization
		Wscript.Echo "OS Language: " & objOperatingSystem.OSLanguage
		Wscript.Echo "OS Product Suite: " & objOperatingSystem.OSProductSuite
		Wscript.Echo "OS Type: " & objOperatingSystem.OSType
		'strMUILanguages = Join(objOperatingSystem.MUILanguages, ",")
		WScript.Echo "MUILanguages: " & strMUILanguages
		Wscript.Echo "Primary: " & objOperatingSystem.Primary
		Wscript.Echo "Registered User: " & objOperatingSystem.RegisteredUser
		Wscript.Echo "Serial Number: " & objOperatingSystem.SerialNumber
		Wscript.Echo "Version: " & objOperatingSystem.Version
		Next
End Function  ' Function Print_System_Information()

Function Print_OnlyEnabled_NICAdapter_information()

	strComputer = "." 
	Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2") 
	Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_NetworkAdapter WHERE NetConnectionId IS NOT NULL")
    i = 0

	For Each objItem in colItems 
        i = i + 1
        Wscript.Echo "-----------------------------------"
        Wscript.Echo "Win32_NetworkAdapter instance: " & i
        Wscript.Echo "-----------------------------------"
	    Wscript.Echo "Name: " & objItem.Name
	    Wscript.Echo "Description: " & objItem.Description
	    Wscript.Echo "NetConnectionId: " & objItem.NetConnectionId		
	    Wscript.Echo "AdapterType: " & objItem.AdapterType		
	    Wscript.Echo "AdapterTypeID: " & objItem.AdapterTypeID		
	    Wscript.Echo "Availability: " & objItem.Availability		
	    Wscript.Echo "Status: " & objItem.Status		
	    Wscript.Echo "StatusInfo: " & objItem.StatusInfo		
	    Wscript.Echo "MACAddress: " & objItem.MACAddress
        Wscript.Echo "Index:" & objItem.Index
        Wscript.Echo "DeviceID:" & objItem.DeviceID
		
	Next

	strComputer = "." 
	Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2") 
	Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_NetworkAdapter WHERE NetConnectionId IS NOT NULL")
    i = 0

	For Each objItem in colItems 
        i = i + 1
        Wscript.Echo "-----------------------------------"
        Wscript.Echo "Win32_NetworkAdapter instance: " & i
        Wscript.Echo "-----------------------------------"
	    Wscript.Echo "Name: " & objItem.Name
	    Wscript.Echo "Description: " & objItem.Description
	    Wscript.Echo "NetConnectionId: " & objItem.NetConnectionId		
	    Wscript.Echo "AdapterType: " & objItem.AdapterType		
	    Wscript.Echo "AdapterTypeID: " & objItem.AdapterTypeID		
	    Wscript.Echo "Availability: " & objItem.Availability		
	    Wscript.Echo "Status: " & objItem.Status		
	    Wscript.Echo "StatusInfo: " & objItem.StatusInfo		
	    Wscript.Echo "MACAddress: " & objItem.MACAddress
        Wscript.Echo "Index:" & objItem.Index
        Wscript.Echo "DeviceID:" & objItem.DeviceID
		
	Next

    strComputer = "."
    Set objWMIService = GetObject("winmgmts:\\" _
    & strComputer & "\root\CIMV2")

    Set colItems = objWMIService.ExecQuery( _
    "SELECT * FROM Win32_NetworkAdapterConfiguration where IPEnabled=TRUE",,48)

    i = 0
    For Each objItem in colItems
        i = i + 1
        Wscript.Echo "-----------------------------------"
        Wscript.Echo "Win32_NetworkAdapterConfiguration instance: " & i
        Wscript.Echo "-----------------------------------"
       
        strDefaultIPGateway = GetMultiString_FromArray(objitem.DefaultIPGateway, ", ")
        Wscript.Echo "MACAddress                  : " & vbtab & objItem.MACAddress
        Wscript.Echo "Description                 : " & vbtab & objItem.Description
        Wscript.Echo "Caption                     : " & vbtab & objItem.Caption
        Wscript.Echo "DHCPEnabled                 : " & vbtab & objItem.DHCPEnabled

        strIPAddress=GetMultiString_FromArray(objitem.IPAddress, ", ")
        Wscript.Echo "IPAddress                   : " & vbtab & strIPAddress
        strIPSubnet = GetMultiString_FromArray(objitem.IPSubnet, ", ")
        Wscript.Echo "IPSubnet                    : " & vbtab & strIPSubnet
        Wscript.Echo "IPConnectionMetric          : " & vbtab & objItem.IPConnectionMetric
        Wscript.Echo "DHCPLeaseExpires            : " & vbtab & objItem.DHCPLeaseExpires
        Wscript.Echo "DHCPLeaseObtained           : " & vbtab & objItem.DHCPLeaseObtained
        Wscript.Echo "DHCPServer                  : " & vbtab & objItem.DHCPServer
        Wscript.Echo "DNSDomain                   : " & vbtab & objItem.DNSDomain
        Wscript.Echo "IPEnabled                   : " & vbtab & objItem.IPEnabled
        Wscript.Echo "DefaultIPGateway            : " & vbtab & strDefaultIPGateway
        Wscript.Echo "GatewayCostMetric           : " & vbtab & strGatewayCostMetric
        Wscript.Echo "IPFilterSecurityEnabled     : " & vbtab & objItem.IPFilterSecurityEnabled
        Wscript.Echo "IPPortSecurityEnabled       : " & vbtab & objItem.IPPortSecurityEnabled

        strDNSDomainSuffixSearchOrder = GetMultiString_FromArray(objitem.DNSDomainSuffixSearchOrder, ", ")
        Wscript.Echo "DNSDomainSuffixSearchOrder  : " & vbtab & strDNSDomainSuffixSearchOrder
        Wscript.Echo "DNSEnabledForWINSResolution : " & vbtab & objItem.DNSEnabledForWINSResolution
        Wscript.Echo "DNSHostName                 : " & vbtab & objItem.DNSHostName
       
        strDNSServerSearchOrder = GetMultiString_FromArray(objitem.DNSServerSearchOrder, ", ")
        Wscript.Echo "DNSServerSearchOrder        : " & vbtab & strDNSServerSearchOrder
        Wscript.Echo "DomainDNSRegistrationEnabled: " & vbtab & objItem.DomainDNSRegistrationEnabled
        Wscript.Echo "ForwardBufferMemory         : " & vbtab & objItem.ForwardBufferMemory
        Wscript.Echo "FullDNSRegistrationEnabled  : " & vbtab & objItem.FullDNSRegistrationEnabled

        strGatewayCostMetric = GetMultiString_FromArray(objitem.GatewayCostMetric, ", ")
        Wscript.Echo "IGMPLevel                   : " & vbtab & objItem.IGMPLevel
        Wscript.Echo "Index                       : " & vbtab & objItem.Index

        strIPSecPermitIPProtocols = GetMultiString_FromArray(objitem.IPSecPermitIPProtocols, ", ")
        Wscript.Echo "IPSecPermitIPProtocols      : " & vbtab & strIPSecPermitIPProtocols

        strIPSecPermitTCPPorts =GetMultiString_FromArray(objitem.IPSecPermitTCPPorts, ", ")
        Wscript.Echo "IPSecPermitTCPPorts         : " & vbtab & strIPSecPermitTCPPorts

        strIPSecPermitUDPPorts = GetMultiString_FromArray(objitem.IPSecPermitUDPPorts, ", ")
        Wscript.Echo "IPSecPermitUDPPorts         : " & vbtab & strIPSecPermitUDPPorts

        Wscript.Echo "IPUseZeroBroadcast          : " & vbtab & objItem.IPUseZeroBroadcast
        Wscript.Echo "IPXAddress                  : " & vbtab & objItem.IPXAddress
        Wscript.Echo "IPXEnabled                  : " & vbtab & objItem.IPXEnabled

        strIPXFrameType=GetMultiString_FromArray(objitem.IPXFrameType, ", ")
        Wscript.Echo "IPXFrameType                : " & vbtab & strIPXFrameType

        strIPXNetworkNumber=GetMultiString_FromArray(objitem.IPXNetworkNumber, ", ")
        Wscript.Echo "IPXNetworkNumber            : " & vbtab & strIPXNetworkNumber
        Wscript.Echo "IPXVirtualNetNumber         : " & vbtab _
                & objItem.IPXVirtualNetNumber
        Wscript.Echo "KeepAliveInterval           : " & vbtab _
                & objItem.KeepAliveInterval
        Wscript.Echo "KeepAliveTime               : " & vbtab & objItem.KeepAliveTime
        Wscript.Echo "MTU                         : " & vbtab & objItem.MTU
        Wscript.Echo "NumForwardPackets           : " & vbtab & objItem.NumForwardPackets
        Wscript.Echo "PMTUBHDetectEnabled         : " & vbtab & objItem.PMTUBHDetectEnabled
        Wscript.Echo "PMTUDiscoveryEnabled        : " & vbtab & objItem.PMTUDiscoveryEnabled
        Wscript.Echo "ServiceName                 : " & vbtab & objItem.ServiceName
        Wscript.Echo "SettingID                   : " & vbtab & objItem.SettingID
        Wscript.Echo "TcpipNetbiosOptions         : " & vbtab & objItem.TcpipNetbiosOptions
        Wscript.Echo "TcpMaxConnectRetransmissions: " & vbtab & objItem.TcpMaxConnectRetransmissions
        Wscript.Echo "TcpMaxDataRetransmissions   : " & vbtab & objItem.TcpMaxDataRetransmissions
        Wscript.Echo "TcpNumConnections           : " & vbtab & objItem.TcpNumConnections
        Wscript.Echo "TcpUseRFC1122UrgentPointer  : " & vbtab & objItem.TcpUseRFC1122UrgentPointer
        Wscript.Echo "TcpWindowSize               : " & vbtab & objItem.TcpWindowSize
        Wscript.Echo "WINSEnableLMHostsLookup     : " & vbtab & objItem.WINSEnableLMHostsLookup
        Wscript.Echo "WINSHostLookupFile          : " & vbtab & objItem.WINSHostLookupFile
        Wscript.Echo "WINSPrimaryServer           : " & vbtab & objItem.WINSPrimaryServer
        Wscript.Echo "WINSScopeID                 : " & vbtab & objItem.WINSScopeID
        Wscript.Echo "WINSSecondaryServer         : " & vbtab & objItem.WINSSecondaryServer
        Wscript.Echo "ArpAlwaysSourceRoute        : " & vbtab & objItem.ArpAlwaysSourceRoute
        Wscript.Echo "ArpUseEtherSNAP             : " & vbtab & objItem.ArpUseEtherSNAP
        Wscript.Echo "DatabasePath                : " & vbtab & objItem.DatabasePath
        Wscript.Echo "DeadGWDetectEnabled         : " & vbtab & objItem.DeadGWDetectEnabled
        Wscript.Echo "DefaultTOS                  : " & vbtab & objItem.DefaultTOS
        Wscript.Echo "DefaultTTL                  : " & vbtab & objItem.DefaultTTL
       
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



