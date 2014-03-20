unit uWSName;

interface


uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,Registry, ShellApi, wsocket, extctrls, filectrl, DNSQuery, NB30,
  WinSvc,  IniFiles, ActiveX, WbemScripting_TLB, Variants, ClipBrd, DateUtils,
  NativeXML;

const
      WinNTHostNameRegKey            : string  = '\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\';
      Win9xHostNameRegKey            : string  = '\SYSTEM\CurrentControlSet\Services\VxD\MSTCP\';
      WinNTComputerDescriptionKey    : string  = '\SYSTEM\CurrentControlSet\Services\lanmanserver\parameters';
      Win9xComputerDescriptionKey    : string  = 'System\CurrentControlSet\Services\VxD\VNETSUP\';
      MyRegistryBaseKey                        =  HKey_Local_Machine;
      MyVersionNumber                : string  = '2.95';
      MyVersionDate                  : string  = '21 January 2012';
      CRLF                                     = ^M^J;
      MAX_LOG_FILE_SIZE                        = 512; //Size in K
      DOMAIN_RENAME_RETRIES                    = 5;
      DOMAIN_RENAME_RETRY_DELAY                = 5;   //seconds
      PostGhostSwitch                : string  = '/PG:';
      NameSyncSwitch                 : string  = '/NS';
      RebootSwitch                   : string  = '/REBOOT';
      NoRebootSwitch                 : string  = '/NOREBOOT';
      NEW_COMPUTERNAME_SWITCH        : string  = '/N:';
      TestOnlySwitch                 : string  = '/TEST';
      SetDiskLabelSwitch             : string  = '/SDL';
      SET_MY_COMPUTERNAME_SWITCH     : string  = '/MCN';
      SetMyComputerDescriptionSwitch : string  = '/SCD';
      SetLogOnToSwitch               : string  = '/LOT';
      ChangeHostNameOnlySwitch       : string  = '/CHO';
      AlwaysDoRenameSwitch           : string  = '/ADR';
      RenameComputerInDomainSwitch   : string  = '/RCID';
      DomainUserIDSwitch             : string  = '/USER:';
      DomainPasswordSwitch           : string  = '/PASS:';
      DomainPasswordMaskedSwitch     : string  = '/PASSM:';
      MASK_PASSWORD_SWITCH           : string  = '/MASKPASSWORD';
      ReadFromDataFileSwitch         : string  = '/RDF:';
      DataFileKeySwitch              : string  = '/DFK:';
      NETWORK_ADAPTERS_TO_IGNORE     : string  = '/EXCLUDEADAPTERS[';
      ALLOW_LONG_DNS_HOST_NAMES      : string  = '/LONGDNSHOST';
      IGNORE_DOMAIN_MEMBERSHIP_SWITCH: string  = '/IGNOREMEMBERSHIP';
      DELETE_EXISTING_ACCOUNT        : string  = '/DELETEEXISTING';
      NO_STRICT_NAME_CHECKING_SWITCH : string  = '/NOSTRICTNAMECHECKING';
      SetWorkGroupSwitch             : string  = '/WG:';
      LOGFILE_LOCATION_SWITCH        : string  = '/LOGFILE:';
      UNATTEND_MODE_SWITCH           : string  = '/UNATTEND:';
      REPLACE_SPACE_IN_NAME_SWITCH   : string  = '/REPSPACE';
      WRITE_NAME_TO_FILE_SWITCH      : string  = '/WRITEFILE';
      DEFAULT_DESKTOP_IDENTIFIER     : string  = 'D';
      DEFAULT_LAPTOP_IDENTIFIER      : string  = 'L';
      WebPage                        : string  = 'http://mystuff.clarke.co.nz';
      HELP_PAGE                      : string  = 'http://mystuff.clarke.co.nz/mystuff/wsname.asp';
      HelpFileName                   : string  = 'WSName.html';
      LogFileName                    : string  = 'WSName.Log';
      AmounttoGrowForm                         = 180;
      DefaultFormHeightSmall                   = 77;
      BorderAllowance                          = 5;
      FormTopMarginSize                        = 27;
      FormMoreLabelSmall             : string  = '&More >>';
      FormMoreLabelBig               : string  = '&Less <<';
      MaxPrefixLength                          = 3;
      DNS_TIMEOUT_INTERVAL                     = 5000; //5 Seconds
      MAX_LENGTH_NETBIOS_HOST_NAME             = 15;
      MAX_LENGTH_DNS_HOST_NAME                 = 63;
      OS_WIN95                       : string  = 'WIN95';
      OS_WIN98                       : string  = 'WIN98';
      OS_WINME                       : string  = 'WINME';
      OS_WINNT                       : string  = 'WINNT';
      OS_WIN2K                       : string  = 'WIN2K';
      OS_WINXP                       : string  = 'WINXP';
      OS_WIN2K3                      : string  = 'WIN2K3';
      OS_VISTA                       : string  = 'VISTA';
      OS_WIN2K8                      : string  = 'WIN2K8';
      OS_WIN7                        : string  = 'WIN7';
      SILENT_IP_ADDRESS              : string  = '$IP';
      SILENT_USER_NAME               : string  = '$USERID';
      SILENT_OS_TYPE                 : string  = '$OSVER';
      SILENT_MAC_ADDRESS             : string  = '$MAC';
      SILENT_MAC_ADDRESS_II          : string  = '$MAC2';
      SILENT_RANDOM_NAME             : string  = '$RANDOM';
      SILENT_RANDOM_NUMBER           : string  = '$RANDNUM';
      SILENT_REVERSE_DNS             : string  = '$DNS';
      SILENT_COMPUTER_MANUFACTURER   : string  = '$MAKE';
      SILENT_COMPUTER_MODEL          : string  = '$MODEL';
      SILENT_COMPUTER_SERIAL_NUMBER  : string  = '$SERIALNUM';
      SILENT_CURRENT_COMPUTER_NAME   : string  = '$CURRENTNAME';
      SILENT_COMPUTER_ASSET_TAG      : string  = '$ASSETTAG';
      SILENT_COMPUTER_CHASSIS_TYPE   : string  = '$CHASSIS';
      SILENT_DATE_DAY                : string  = '$DD';
      SILENT_DATE_MONTH              : string  = '$MM';
      SILENT_DATE_YEAR               : string  = '$YYYY';
      SILENT_DATE_YEAR_SHORT         : string  = '$YY';

      MAX_HOSTNAME_LEN               = 128; { from IPTYPES.H }
      MAX_DOMAIN_NAME_LEN            = 128;
      MAX_SCOPE_ID_LEN               = 256;
      MAX_ADAPTER_NAME_LENGTH        = 256;
      MAX_ADAPTER_DESCRIPTION_LENGTH = 128;
      MAX_ADAPTER_ADDRESS_LENGTH     = 8;

      // For ExtractFromGetAdapterInformation
      ADAP_ADAPTER_NUMBER      =  0;
      ADAP_COMBOINDEX          =  1;
      ADAP_ADAPTER_NAME        =  2;
      ADAP_DESCRIPTION         =  3;
      ADAP_ADAPTER_ADDRESS     =  4;
      ADAP_INDEX               =  5;
      ADAP_TYPE                =  6;
      ADAP_DHCP                =  7;
      ADAP_CURRENT_IP          =  8;
      ADAP_IP_ADDRESSES        =  9;
      ADAP_GATEWAYS            = 10;
      ADAP_DHCP_SERVERS        = 11;
      ADAP_HAS_WINS            = 12;
      ADAP_PRIMARY_WINS        = 13;
      ADAP_SECONDARY_WINS      = 14;
      ADAP_LEASE_OBTAINED      = 15;
      ADAP_LEASE_EXPIRES       = 16;

      // For DWSplit
      qoPROCESS    = $0001;
      qoNOBEGINEND = $0002;
      qoNOCRLF     = $0004;

      // For MagicChango
      TRIM_LEFT             = 0;
      TRIM_RIGHT            = 1;
      TRIM_WHOLE_WORD_LEFT  = 2;
      TRIM_WHOLE_WORD_RIGHT = 3;

      // For Masking
      KEY_ARRAY           = #47#43#173#114#129#236#170#227#211#160#10#222#58#239#29#204#181#97#243#253#115#163#125#172#253#79#35#99#134#101#178#40#211#207#198#230#131#178#0#230#174#109#164#109#13#110#132#185#60#83#82#255#193#253#170#32#213#130#127#46#54#43#191#17#121#233#73#198#136#235#148#26#107#71#165#218#112#219#41#206#80#216#215#17#243#159#111#127#227#219#248#85#157#12#22#78#60#225#144#192#74#32#110#138#157#240#59#230#135#203#85#90#219#113#97#106#118#140#56#190#79#248#254#227#79#214#34#218#92#208#125#18#106#75#218#147#125#93#150#102#218#200#22#129#239#81#81#211#155#58#180#38#226#169#4#247#71#76#19#129#58#131#114#145#106#221#106#232#230#187#236#66#87#77#60#57#193#96#141#169#151#146#213#82#9#243#128#195#227#37#220#229#94#124#88#164#177#187#242#144#88#103#117#120#76#205#94#78#170#56#128#224#132#243#209#52#215#14#238#143#230#13#53#123#114#240#155#71#138#60#137#228#246#244#111#25#110#173#212#96#37#43#23#252#94#47#35#14#0#103#204#182#117#163#153;

Type
      TIPAddressString = Array[0..4*4-1] of Char;
      PIPAddrString = ^TIPAddrString;
      TIPAddrString = Record
      Next      : PIPAddrString;
      IPAddress : TIPAddressString;
      IPMask    : TIPAddressString;
      Context   : Integer;
      End;

      PFixedInfo = ^TFixedInfo;
      TFixedInfo = Record { FIXED_INFO }
      HostName         : Array[0..MAX_HOSTNAME_LEN+3] of Char;
      DomainName       : Array[0..MAX_DOMAIN_NAME_LEN+3] of Char;
      CurrentDNSServer : PIPAddrString;
      DNSServerList    : TIPAddrString;
      NodeType         : Integer;
      ScopeId          : Array[0..MAX_SCOPE_ID_LEN+3] of Char;
      EnableRouting    : Integer;
      EnableProxy      : Integer;
      EnableDNS        : Integer;
      End;

      PIPAdapterInfo = ^TIPAdapterInfo;
      TIPAdapterInfo = Record { IP_ADAPTER_INFO }
      Next                : PIPAdapterInfo;
      ComboIndex          : Integer;
      AdapterName         : Array[0..MAX_ADAPTER_NAME_LENGTH+3] of Char;
      Description         : Array[0..MAX_ADAPTER_DESCRIPTION_LENGTH+3] of Char;
      AddressLength       : Integer;
      Address             : Array[1..MAX_ADAPTER_ADDRESS_LENGTH] of Byte;
      Index               : Integer;
      _Type               : Integer;
      DHCPEnabled         : Integer;
      CurrentIPAddress    : PIPAddrString;
      IPAddressList       : TIPAddrString;
      GatewayList         : TIPAddrString;
      DHCPServer          : TIPAddrString;
      HaveWINS            : Bool;
      PrimaryWINSServer   : TIPAddrString;
      SecondaryWINSServer : TIPAddrString;
      LeaseObtained       : Integer;
      LeaseExpires        : Integer;
      End;

      OSVERSIONINFOEX = packed record
      dwOSVersionInfoSize: DWORD;
      dwMajorVersion: DWORD;
      dwMinorVersion: DWORD;
      dwBuildNumber: DWORD;
      dwPlatformId: DWORD;
      szCSDVersion: array[0..127] of Char;
      wServicePackMajor: WORD;
      wServicePackMinor: WORD;
      wSuiteMask: WORD;
      wProductType: BYTE;
      wReserved: BYTE;
      end;
      TOSVersionInfoEx = OSVERSIONINFOEX;
      POSVersionInfoEx = ^TOSVersionInfoEx;

      var
      ComputerName, OSVer, OSVerDetailed, UserName,
      NovellClientVersion, TempDirectory, LogFilePathandName, HostName,
      DNSServer, AsEnteredComputerName, sComputerDescription,
      strDomainUserID, strDomainPassword, strDataFileName, strDataFileKey,
      sLanGroupName, sWorkGroupName, sAlternateLogFileLocation,
      sWindowsDrive, sWindowsDriveFormat, sWindowsDriveLabel, sDomainControllerName,
      sDomainControllerAddress, sDomainName, sDnsForestName, sClientSiteName,
      sUnattendFile                                                                   : String;
      TaskHelpStuff, TaskPostGhost, TaskNameSync, TaskNoReboot,
      TaskReboot, TaskSilent, LocalAdminRights, ShowGUI, TaskTestOnly,
      TaskSetDiskLabel, TaskAlwaysDoRename,
      bTaskSetMyComputerName, TaskLogOnTo, TaskChangeHostNameOnly,
      TaskSetMyComputerDescription, TaskRenameComputerInDomain, TaskReadFromDataFile,
      UseAlternateMACAddressRoutine, blnNetWareClientInstalled, bInDomain,
      bTaskSetWorkGroup, bWindows2000orBetter, bIgnoreDomainMemberShip, bAllowLongDNSHostNames,
      bDeleteExistingComputerAccount, bNoStrictNameChecking, bUnattendFileMode,
      bDomainPasswordEncrypted, bTaskMaskPassword, bIsOS64Bit, bReplaceSpaceChars,
      bWriteNametoFile                                                                : Boolean;
      FormHeightSmall, iRetDSGetDCName                                                : Integer;
      tsNetworkAdapterExclusionList                                                   : TStrings;

function GetFileSizeEx( const filename: String ): int64;
function SetPrivilege(privilegeName: string; enable: boolean): boolean;
function WinExit(flags: integer): boolean;
function fSetComputerName(sNewName:String):Boolean;
function RunProcess(const AppPath, AppParams: string; Visibility: Word; MustWait: Boolean): DWord;
function CheckValidityofCompterName(ComputerNametoCheck:string):boolean;
function ReadAsStringFromRegistry(rootkey:HKEY;basekey,keyvalue:string):string;
function ReadNovellClientDetails:string;
function IsDLLOnSystem(DLLName:string):Boolean;
function CheckInTrim(targetstring : string;maxsize : integer):string;
function RenameComputer(newname:string; RebootOnCompletion : Boolean):Boolean;
function GetMACAddress(AdapterNumber:integer):String;
function IsValidIPAddress(address:string):Boolean;
function GetIPAddress(intIPAddressIndex : integer):string;
function GetServicePackVersion:string;
function InStrRev( Start:Integer; Const BigStr,SmallStr:String):Integer;
function OSVer_To_Friendly_Name(strOSVer : string) : string;
procedure SetLogOnTo(NewName : string);
procedure SetHostName(HostName : string);
procedure SetNVHostName(HostName : string);
procedure MainCodeBlock;
procedure ShowHelpFile;
procedure ExtractRes(ResType,ResName,ResNewName : String);
procedure AppendtoLogFile(s : string);
procedure ExitRoutine(exitcode:byte);
procedure SetWorkGroupName(sWorkGroupName : string);
procedure DW_Split(aValue : string; aDelimiter : Char; var Result : TStrings; Flag : Integer = $0001);
function GetAdapterInformation:TStringList;
function GetAdapterInformationII:TStringList;
function ExtractFromGetAdapterInformation(tlAdaperInfo : TStringList; intAdapterIndex, intDataIndex : Integer) : string;
function GetMACAddressLegacy(AdapterNumber : Integer):string;
function ReverseDNSLookup(strIPAddress, strDNSServer:string; intPTRTimeOut : integer; out strResult : string):Boolean;
function GetDNSUsingGetNetworkParams:String;
function GetDNSUsingScreenScraping:String;
function GetDNSServer:string;
function OSVersionToTLA:string;
function ReplacementStringSizeSpecified(strMarker, strInput : string; out intStringSize, intTruncateFrom : integer; out strOutput : string) : boolean;
function MagicChango(strInput,sID,strReplacementString : string):string;
function PadIPAddress(strIPAddress : string) : string;
function MyStrtoInt(x : string; blnStrict : boolean) : integer;
function PosX(Substr: string; S: string): Integer;
function GenerateRandomName(iLength : integer) : string;
function GenerateRandomNumber(iLength : integer) : string;
function IsWindows2000orBetter:Boolean;
function NetJoinDomainAPI(sNewWorkgroupName:string): LongInt;
function FreeBuffer(lpBuffer : Pointer):integer;
function GetLanGroupName(out sLanGroupName : string; out bInDomain : Boolean):integer;
function GetWindowsDrive: String;
function GetDriveLabel(sDrive : string):string;
function GetDriveFormat(sDrive : string):string;
function WMIByShellHack(sWMIClass, sWMIOption:string):String;
function WMIByShellHackCollectionofCollection(sWMIClass, sWMIOption:string):String;
function EvaluateString(sRawInputString:string):string;
function ADSIFindComputerByShellHack(sComputerName,sDomainController,sDomainName,strUserID,strPassword:string):String;
function ADSIDeleteComputerByShellHack(sComputerAdsPath,strUserID,strPassword:string):string;
function DSGetDCName(const sTargetDomainName: String; out sDomainControllerName : string; out sDomainControllerAddress : string; out sDomainName : string; out sDnsForestName : string; out sClientSiteName : string): integer;
function ConvertToExtendedDomainNameFormat(sName : string):String;
function IsStringinStringList(s : string; sl: TStrings):Boolean;
Function GetValueFromCommandLineString(sStr:PChar; sMarker:string):string;
Function CheckAccessToFile(fName:string; OUT sResultMessage : string):boolean;
Procedure WriteToUnattendFile(sComputerName,sFileName:string);    //Added 2.83
function GetWMIstring (wmiHost, wmiClass, wmiProperty : string):string;
procedure Bin2Hex(b: integer; var h: String);
function Hex2Bin(h: String; var b: integer): boolean;
function MaskString(string_clear:string):string;
function DemaskString(string_masked:string):string;
function LastPos(const SubStr: String; const S: String): Integer;
function Reverse(Line: string): string;
function Right(Source: string; Lengths: integer): string;
function Left(Source: string; Length: integer): string;


implementation

Type TInstance = Class( TObject )
    intPTRResult : integer;
    Timer1 : TTimer;
    DNSQuery1 : TDNSQuery;
    procedure PTRQueryOnTimeOut(Sender: Tobject);
    procedure DnsQuery1RequestDone(Sender: TObject; Error: Word);
End;


// ---------------------------------------------------------------------------

function IsWow64: Boolean;
type
  TIsWow64Process = function( // Type of IsWow64Process API fn
    Handle: Windows.THandle; var Res: Windows.BOOL
  ): Windows.BOOL; stdcall;
var
  IsWow64Result: Windows.BOOL;      // Result from IsWow64Process
  IsWow64Process: TIsWow64Process;  // IsWow64Process fn reference
begin
  // Try to load required function from kernel32
  IsWow64Process := Windows.GetProcAddress(
    Windows.GetModuleHandle('kernel32.dll'), 'IsWow64Process'
  );
  if Assigned(IsWow64Process) then
  begin
    // Function is implemented: call it
    if not IsWow64Process(
      Windows.GetCurrentProcess, IsWow64Result
    ) then
      raise SysUtils.Exception.Create('IsWow64: bad process handle');
    // Return result of function
    Result := IsWow64Result;
  end
  else
    // Function not implemented: can't be running on Wow64
    Result := False;
end;

// ---------------------------------------------------------------------------

Procedure Bin2Hex(b: integer; var h: String);
    (* Converts integer to 2-digit hex string *)
    var i,n: integer;
    begin
        h:='00';
        for i:=2 downto 1 do begin
            n:=b and $f; b:=b shr 4;
            if n<10 then
                h[i]:=Chr(n+48)
            else
                h[i]:=Chr(n+55);
        end;
    end (* of procedure Bin2Hex *);

// ---------------------------------------------------------------------------

Function Hex2Bin(h: String; var b: integer): boolean;
    (* Converts 2-digit hex string to integer *)
    var i: integer; c: char;
    begin
        b:=0;
        for i:=1 to 2 do begin
            c:=h[i];
            if (c>='0') and (c<='9') then
                b:=(b shl 4)+ord(c)-48
            else if (c>='A') and (c<='F') then
                b:=(b shl 4)+ord(c)-55;
        end;
        Result:=True;
    end (* of function Hex2Bin *);

// ---------------------------------------------------------------------------

Function MaskString(string_clear:string):string;
    var ch, swap_ch                                        : char;
        temp_string, string_masked, string_display,
        string_prepender, key_xor, key_transpose, username : string;
        i,j,string_length, array_pointer, prepender_length : integer;
    begin
        if string_clear = '' then
            Exit;
        string_masked:='';
        string_display:='';
        string_prepender:='';
        username:='';
        key_xor:='';
        key_transpose:='';
        string_length:=0;
        prepender_length:=1;
        array_pointer:=0;
        randomize;
        array_pointer:=random(255)+1;                                          // set truly random pointer between 1 and 255 into key_array for encryption
        for i:=1 to prepender_length do
            string_prepender:=string_prepender+chr(random(255)+1);             // set truly random string_prepender of prepender_length characters
        string_clear:=string_prepender+string_clear;                           // Prepend random string_prepender to user's cleartext string
        string_length:=length(string_clear);                                   // Determine string_length
        for i:=-1 to string_length-2 do                                        // Copy key_xor with same length as string_clear from key_array
            key_xor:=key_xor+chr(ord(key_array[(array_pointer+i) mod 255+1]));
       for i:=string_length-1 to (2*string_length)-2 do                        // Copy key_transpose with same length as string_clear from key_array
           key_transpose:=key_transpose+chr(ord(key_array[(array_pointer+i) mod 255+1]));
       for i:=1 to length(string_clear) do begin                               // XOR step w/feedback
         ch:=chr(ord(string_clear[i]) xor ord(key_xor[i]));
         key_xor[i+1]:=chr(ord(ord(key_xor[i+1]) xor ord(ch)));                // feedback
         string_masked:=string_masked + ch;
       end;
       for i:=1 to length(string_masked) do begin                              // Transpose step
           j:=ord(key_transpose[i]);
           swap_ch:=string_masked[i];
           string_masked[i]:=string_masked[j mod string_length +1];
           string_masked[j mod string_length +1]:=swap_ch;
       end;
       string_masked:=string_masked + chr(ord(array_pointer));                 // Add array_pointer to string_encrypted
       string_display:='H#';                                                   // Convert string_encrypted to HEX and display in friendly format
       for i:=1 to length(string_masked) do begin
            j:=ord(string_masked[i]);
            Bin2Hex(j,temp_string);
            string_display:=string_display+temp_string;
       end;
       Result:=string_display;
       string_clear:='Sorry*the*process*is*over*the*string*is*no*longer*here';
       string_masked:=string_clear;
       string_display:=string_clear;
       string_prepender:=string_clear;
       key_xor:=string_clear;
       key_transpose:=string_clear;
       username:=string_clear;
       string_length:=0;
       array_pointer:=0;
    end { of Function MaskString };

// ---------------------------------------------------------------------------

Function DemaskString(string_masked:string):string;
    var ch, swap_ch                                        : char;
        string_clear, string_display,
        string_prepender, key_xor, key_transpose, username : string;
        i,j,string_length, array_pointer, prepender_length : integer;

    begin
        if string_masked = '' then
            Exit;
        string_clear:='';
        string_display:='';
        string_prepender:='';
        username:='';
        key_xor:='';
        key_transpose:='';
        string_length:=0;
        prepender_length:=1;
        array_pointer:=0;
        randomize;
        array_pointer:=random(255)+1;                                          // set truly random pointer between 1 and 255 into key_array for encryption
        for i:=1 to prepender_length do
            string_prepender:=string_prepender+chr(random(255)+1);             // set truly random string_prepender of prepender_length characters
        for i:=1 to length(string_masked) do                                   // Convert to Uppercase
            string_masked[i]:=Upcase(string_masked[i]);
        i:=pos('#',string_masked);                                             // Extract hex numbers from string if # is present
        if i > 0 then
            string_masked:=copy(string_masked,i+1,length(string_masked));
        for i:=1 to length(string_masked) do begin                             //  Convert from hex to binary
            if odd(i) then begin
                Hex2Bin(copy(string_masked,i,2),j);
                string_clear:=string_clear+chr(j);
            end;
        end;
        string_length:=length(string_clear)-1;                                 // Determine string_length
        array_pointer:=ord(string_clear[string_length+1]);                     // Cut array_pointer from encrypted password
        string_clear:=copy(string_clear,1,length(string_clear)-1);
        for i:=-1 to string_length-2 do                                        // Copy key_xor with same length as string_clear from key_array
            key_xor:=key_xor+chr(ord(key_array[(array_pointer+i) mod 255+1]));
        for i:=string_length-1 to (2*string_length)-2 do                       // Copy key_transpose with same length as string_clear from key_array
            key_transpose:=key_transpose+chr(ord(key_array[(array_pointer+i) mod 255+1]));
        for i:=length(string_clear) downto 1 do begin                          // Transpose step
            j:=ord(key_transpose[i]);
            swap_ch:=string_clear[i];
            string_clear[i]:=string_clear[j mod string_length +1];
            string_clear[j mod string_length +1]:=swap_ch;
        end;
        for i:= length(string_clear) downto 1 do begin                         // XOR step w/feedback
            key_xor[i]:=chr(ord(ord(key_xor[i]) xor ord(string_clear[i])));    // undo feedback
            ch:=chr(ord(string_clear[i-1]) xor ord(key_xor[i]));
            string_display:=ch+string_display ;
        end;
       // Remove random prepended characters}
       string_display:=copy(string_display,prepender_length+1,length(string_clear)-prepender_length);
       Result:=string_display;
       string_clear:='Sorry*the*process*is*over*the*password*is*no*longer*here';;
       string_masked:=string_clear;
       string_display:=string_clear;
       string_prepender:=string_clear;
       key_xor:=string_clear;
       key_transpose:=string_clear;
       username:=string_clear;
       string_length:=0;
       array_pointer:=0;
    end {of function DemaskString };

// ---------------------------------------------------------------------------

Procedure ShowMaskedPassword;
    var sMasked : String;
    begin
        if strDomainPassword = '' then
            MessageBox(0, PChar('You need to provide the password to mask using the /PASS: switch' + #10+#13+#10+#13 + 'Please correct and rerun'), PChar('WSName: Password Mask Error'), MB_OK + MB_ICONEXCLAMATION)
        else begin
            sMasked:=MaskString(strDomainPassword);
            Clipboard.AsText:= sMasked;
            MessageBox(0, PChar('Masked Password is ' + sMasked + #10+#13+#10+#13 + 'The password has been pasted into the clipboard'), PChar('WSName: Password Mask'), MB_OK + MB_ICONINFORMATION);
            sMasked:='';
         end;
     end;



// ---------------------------------------------------------------------------

function Right(Source: string; Lengths: integer): string;
  begin
    Result := copy(source,Length(Source) - Lengths,Lengths);
  end;

// ---------------------------------------------------------------------------

function Left(Source: string; Length: integer): string;
  begin
	  Result := copy(Source,1,Length);
  end;

// ---------------------------------------------------------------------------

function Reverse(Line: string): string;
	var i: integer;
	var a: string;
begin
	For i := 1 To Length(Line) do
	begin
	a := Right(Line, i);
	Result := Result + Left(a, 1);
	end;
end;

// ---------------------------------------------------------------------------

function LastPos(const SubStr: String; const S: String): Integer;
begin
   result := Pos(Reverse(SubStr), Reverse(S)) ;

   if (result <> 0) then
     result := ((Length(S) - Length(SubStr)) + 1) - result + 1;
end;

// ---------------------------------------------------------------------------


function GetWMIstring (wmiHost, wmiClass, wmiProperty : string):string;
var  // These are all needed for the WMI querying process
  Locator        : ISWbemLocator;
  Services       : ISWbemServices;
  SObject        : ISWbemObject;
  ObjSet         : ISWbemObjectSet;
  SProp          : ISWbemProperty;
  Enum           : IEnumVariant;
  Value          : Cardinal;
  TempObj        : OleVariant;
  SN             : string;
  vLow, vHigh, i : integer;

begin
  try
  Locator := CoSWbemLocator.Create;  // Create the Location object
  // Connect to the WMI service, with the root\cimv2 namespace
  Services :=  Locator.ConnectServer(wmiHost, 'root\cimv2', '', '', '','', 0, nil);
  ObjSet := Services.ExecQuery('SELECT * FROM '+wmiClass, 'WQL', wbemFlagReturnImmediately and wbemFlagForwardOnly , nil);
  Enum :=  (ObjSet._NewEnum) as IEnumVariant;
  while (Enum.Next(1, TempObj, Value) = S_OK) do
  begin
    SObject := IUnknown(tempObj) as ISWBemObject;
    SProp := SObject.Properties_.Item(wmiProperty, 0);
    if VarIsNull(SProp.Get_Value) then
      result := ''
    else
    begin
      if VarArrayDimCount(SProp.Get_Value) = 0 then
        SN:=SProp.Get_Value
      else begin // Collection
        vLow := VarArrayLowBound(SProp.Get_Value, 1);
        vHigh := VarArrayHighBound(SProp.Get_Value, 1);
        for i := vLow to vHigh do
          SN:=(SProp.Get_Value[i]);
      end;
      result :=  Trim(SN);
    end;
  end;
  except // Trap any exceptions (Not having WMI installed will cause one!)
   on exception do
    result := '';
   end;
end;

// ---------------------------------------------------------------------------

function GetFileSizeEx( const filename: String ): int64;
 Var
   SRec: TSearchrec;
   converter: packed record
     case Boolean of
       false: ( n: int64 );
       true : ( low, high: DWORD );
     end;
 Begin
   If FindFirst( filename, faAnyfile, SRec ) = 0 Then Begin
     converter.low := SRec.FindData.nFileSizeLow;
     converter.high:= SRec.FindData.nFileSizeHigh;
     Result:= converter.n;
     FindClose( SRec );
   End
   Else
     Result := -1;
 End;

// ---------------------------------------------------------------------------

   function SetPrivilege(privilegeName: string; enable: boolean): boolean;
       var
           tpPrev, tp  : TTokenPrivileges;
                token  : THandle;
              dwRetLen : DWord;
       begin
           result := False;
           OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, token);
           tp.PrivilegeCount := 1;
           if LookupPrivilegeValue(nil, pchar(privilegeName), tp.Privileges[0].LUID) then begin
               if enable then
                   tp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED
               else
                   tp.Privileges[0].Attributes := 0;
               dwRetLen := 0;
               result := AdjustTokenPrivileges(token, False, tp, SizeOf(tpPrev), tpPrev, dwRetLen);
           end;
           CloseHandle(token);
       end;


// ---------------------------------------------------------------------------

function WinExit(flags: integer): boolean;
{   Call WinExit(flags)

   Where flags must be one of the following:

   EWX_LOGOFF     - Shuts down processes and logs user off
   EWX_REBOOT     - Shuts down the restarts the system
   EWX_SHUTDOWN   - Shuts down system

   The following attributes may be combined (OR'd) with above flags

   EWX_POWEROFF  - shuts down system and turns off the power.
   EWX_FORCE     - forces processes to terminate.

   Example:
           WinReboot1.WinExit(EWX_REBOOT or EWX_FORCE);      }

  begin
    Result := True;
    SetPrivilege('SeShutdownPrivilege', true);
    if not ExitWindowsEx(flags, 0) then
      Result := False;
    SetPrivilege('SeShutdownPrivilege', False);
  end;

// ---------------------------------------------------------------------------


{*****************************[ RUNPROCESS ] ***********************************
*
* Type: function
* Use: To launch an application and optionally wait until the launched
* Application is terminated before running the rest of the code.
*
* PARAMETERS:
*
* AppPath: The full path and Application Name to run ie. c:\winnt\notepad.exe
*
* AppParams: Commandline params to send to the app.
*
* Visibility:
* Can have any of the following values:
*   Value	Meaning
*   SW_HIDE	Hides the window and activates another window.
*   SW_MAXIMIZE	Maximizes the specified window.
*   SW_MINIMIZE	Minimizes the specified window and activates the next top-level
*     window in the Z order.
*   SW_RESTORE	Activates and displays the window. If the window is minimized or
*     maximized, Windows restores it to its original size and position. An
*     application should specify this flag when restoring a minimized window.
*   SW_SHOW	Activates the window and displays it in its current size and position.
*   SW_SHOWDEFAULT	Sets the show state based on the SW_ flag specified in the
*     STARTUPINFO structure passed to the CreateProcess function by the program
*     that started the application.
*   SW_SHOWMAXIMIZED	Activates the window and displays it as a maximized window.
*   SW_SHOWMINIMIZED	Activates the window and displays it as a minimized window.
*   SW_SHOWMINNOACTIVE	Displays the window as a minimized window. The active
*     window remains active.
*   SW_SHOWNA	Displays the window in its current state. The active window remains
*     active.
*   SW_SHOWNOACTIVATE	Displays a window in its most recent size and position.
*     The active window remains active.
*   SW_SHOWNORMAL	Activates and displays a window. If the window is minimized or
*     maximized, Windows restores it to its original size and position. An
*     application should specify this flag when displaying the window for the
*     first time.
*
* MustWait: true if the code must be paused until the termination of the launched
*   Application. false if the code must run directly after launching the app.
*
********************************************************************************}

function RunProcess(const AppPath, AppParams: string; Visibility: Word; MustWait: Boolean): DWord;
  var
    SI: TStartupInfo;
    PI: TProcessInformation;
    Proc: THandle;
  begin
    FillChar(SI, SizeOf(SI), 0);
    SI.cb := SizeOf(SI);
    SI.wShowWindow := Visibility;
    //if not CreateProcess(PChar(AppPath), PChar(AppParams), nil, nil, false, Normal_Priority_Class, nil, nil, SI, PI) then
    //  raise Exception.CreateFmt('Failed to excecute program. Error Code %d', [GetLastError]);
    // DJC - Above two lines remmed out following line added so no error is posted
    CreateProcess(PChar(AppPath), PChar(AppParams), nil, nil, false, Normal_Priority_Class, nil, nil, SI, PI);
    Proc := PI.hProcess;
    CloseHandle(PI.hThread);
    if MustWait then
      if WaitForSingleObject(Proc, Infinite) <> Wait_Failed then
        GetExitCodeProcess(Proc, Result);
    CloseHandle(Proc);
  end;

// ---------------------------------------------------------------------------

Function CheckAccessToFile(fName:string; OUT sResultMessage : string):boolean;
  var
    HFileRes : HFILE;
  begin
    Result:=false;
    sResultMessage:='';
    try
      if FileExists(fName) then
         HFileRes:=CreateFile(pchar(fName), GENERIC_READ or GENERIC_WRITE,0, nil, OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL, 0)
      else
         HFileRes:=CreateFile(pchar(fName), GENERIC_READ or GENERIC_WRITE,0, nil, CREATE_NEW,FILE_ATTRIBUTE_NORMAL, 0);
      sResultMessage:=SysErrorMessage(GetLastError);
      Result:=(HFileRes <> INVALID_HANDLE_VALUE);
      if Result then CloseHandle(HFileRes);
    except
      Result:=false;
    end;
  end;

// ---------------------------------------------------------------------------

function FindPathtoFile(Target : string):string;
const
  MAX_SIZE          = 500;
var
  PathandFileName   : array[0..MAX_SIZE] of Char;
  FileNamePart      : pchar;
  retcode           : integer;
begin
  result:='';
  retcode:=SearchPath(nil,pchar(Target),nil,MAX_SIZE,@PathandFileName,FileNamePart);
  if retcode <> 0 then
    result:=PathandFileName
end;

// ---------------------------------------------------------------------------

function InStrRev( Start:Integer; Const BigStr,SmallStr:String):Integer;
  Var
  L9, L8, P: Integer;
  BigL, SmallL: Integer;
  C : Char;
  Begin
  Result := 0; // Set Default

  // Take String Lengths
  BigL := Length( BigStr );
  SmallL := Length( SmallStr );

  // 0 Starts from end of String
  If Start <= 0 Then
     Start := BigL;

  If Start > BigL Then
     Start := BigL;

  // '' Target always returns 0
  If BigL = 0 Then
     Exit;

  // '' Convention returns Start
  If SmallL = 0 Then
     Begin
       Result := Start;
       Exit;
     End;

  // Take First Char of Search String
  C := SmallStr[1];

  // Run back if BigStr not long enough
  If (Start + SmallL - 1) > BigL Then
     Start := BigL - SmallL + 1;

  // Hunt Backwards for a match
  For L9 := Start DownTo 1 Do
      If BigStr[L9] = C Then  // If first Char Found
         Begin
           P := L9 + SmallL - 1;
           For L8 := SmallL DownTo 2 Do // Scan Backwards
               Begin
                 If BigStr[P] <> SmallStr[L8] Then
                    Break;
                 P := P - 1;
               End;
           // Success - we know first Char matches
           If P = L9 Then
              Begin
                Result := L9;
                Break;
              End;
         End;

End;{InStrRev}

// ---------------------------------------------------------------------------

function IsDLLOnSystem(DLLName:string):Boolean;
  var ret  : integer;
      good : boolean;
      //tmpstr: integer;
  begin
    ret:=LoadLibrary(pchar(DLLNAME));
    //tmpstr:=GetlastError();
    Good:=ret>0;
    if good then FreeLibrary(ret);
    result:=Good;
  end;

// ---------------------------------------------------------------------------

function IsAdmin: boolean;
var
  hSC: SC_HANDLE;
begin
  hSC := OpenSCManager(nil, nil, GENERIC_READ or GENERIC_WRITE or GENERIC_EXECUTE);
  Result := hSC <> 0;
  if Result then
    CloseServiceHandle(hSC);
end;

// ---------------------------------------------------------------------------

function IsAdminX: Boolean;
  // Returns TRUE if the user is an Administrator
  const
    SECURITY_NT_AUTHORITY: TSIDIdentifierAuthority = (Value: (0, 0, 0, 0, 0, 5));
    SECURITY_BUILTIN_DOMAIN_RID = $00000020;
    DOMAIN_ALIAS_RID_ADMINS    = $00000220;

  var
    hAccessToken: THandle;
    ptgGroups: PTokenGroups;
    dwInfoBufferSize: DWORD;
    psidAdministrators: PSID;
    x: Integer;
    bSuccess: Boolean;

  begin
    Result := False;
    bSuccess := OpenThreadToken(GetCurrentThread, TOKEN_QUERY, True,     hAccessToken);
    if not bSuccess then begin
      if GetLastError = ERROR_NO_TOKEN then
      bSuccess := OpenProcessToken(GetCurrentProcess, TOKEN_QUERY,       hAccessToken);
    end;
    if bSuccess then begin
      GetMem(ptgGroups, 1024);
      bSuccess := GetTokenInformation(hAccessToken, TokenGroups,ptgGroups, 1024, dwInfoBufferSize);
      CloseHandle(hAccessToken);
      if bSuccess then begin
        AllocateAndInitializeSid(SECURITY_NT_AUTHORITY, 2, SECURITY_BUILTIN_DOMAIN_RID, DOMAIN_ALIAS_RID_ADMINS,0, 0, 0, 0, 0, 0, psidAdministrators);
        for x := 0 to ptgGroups.GroupCount - 1 do
          if EqualSid(psidAdministrators, ptgGroups.Groups[x].Sid) then begin
            Result := True;
            Break;
          end;
        FreeSid(psidAdministrators);
      end;
      FreeMem(ptgGroups);
    end;
  end;

// ---------------------------------------------------------------------------

function GetOSVersion(blnDetailed : boolean):String;
  var
    VersionInfo: TOSVersionInfo;
  begin
    result:='Unknown';
    VersionInfo.dwOSVersionInfoSize := Sizeof(TOSVersionInfo);
    GetVersionEx(VersionInfo);
    case VersionInfo.dwPlatformID of
      VER_PLATFORM_WIN32S:        result:='WIN32';
      VER_PLATFORM_WIN32_WINDOWS: begin
          result:='WIN9X';
          if blnDetailed then begin
              if (VersionInfo.dwMinorVersion = 0) then
                  Result:= OS_WIN95
              else if (VersionInfo.dwMinorVersion = 10) then
                  Result:= OS_WIN98
              else if (VersionInfo.dwMinorVersion = 90) then
                  Result:= OS_WINME
              else
                  Result:= OS_WIN95;
          end;
      end;
      VER_PLATFORM_WIN32_NT: begin
          result:=OS_WINNT;
          if blnDetailed then begin
              if (VersionInfo.dwMajorVersion = 6)  and (VersionInfo.dwMinorVersion = 1) then
                   result:=OS_WIN7
              else if (VersionInfo.dwMajorVersion = 6)  and (VersionInfo.dwMinorVersion = 0) then
                   result:=OS_VISTA
              else if (VersionInfo.dwMajorVersion = 5)  and (VersionInfo.dwMinorVersion = 2) then
                  result:=OS_WIN2K3
              else if (VersionInfo.dwMajorVersion = 5)  and (VersionInfo.dwMinorVersion = 1) then
                  result:=OS_WINXP
              else if (VersionInfo.dwMajorVersion = 5) and (VersionInfo.dwMinorVersion = 0) then
                  result:=OS_WIN2K
              else
                  result:=OS_WINNT
          end;
      end;
    end;
  end;

// ---------------------------------------------------------------------------

function GetServicePackVersion:string;
var osvi : TOSVersionInfo;
begin
    osvi.dwOSVersionInfoSize := SizeOf(Osvi);
    if GetVersionEX(osvi) then
        Result:= osvi.szCSDVersion
    else Result:= '';
end;

// ---------------------------------------------------------------------------

function GetWorkstationName : String;
  var CompName :  pChar;
      BuffSize : Dword;
  begin
    Buffsize:=20;
    CompName := StrAlloc(Buffsize);
    GetComputerName(CompName, BuffSize);
    Result:=StrPas(CompName);
  end;

// ---------------------------------------------------------------------------

function fSetComputerName(sNewName : String):Boolean;
  var
    ComputerName: array[0..MAX_COMPUTERNAME_LENGTH+1] of char;  // holds the name
  begin
    {copy the specified name to the ComputerName buffer}
    StrPCopy(ComputerName, sNewName);
    if TaskTestOnly then
      result:=true
    else
      result:=SetComputerName(ComputerName);
  end;

// ---------------------------------------------------------------------------

function fSetComputerNameEx(strNewName:string):Boolean;
    //http://msdn.microsoft.com/library/default.asp?url=/library/en-us/sysinfo/sysinfo_84s8.asp
    type
       Type_SetComputerNameEx = function (nType : integer; newname : string) : LongInt stdcall;
    var
       _SetComputerNameEx             : Type_SetComputerNameEx;
       lngResultCode, lngModuleHandle :  LongInt;
   begin
       fSetComputerNameEx:=FALSE;
       lngModuleHandle:=LoadLibrary(pchar('kernel32.dll'));
       @_SetComputerNameEx:=GetProcAddress(lngModuleHandle,pchar('SetComputerNameExA'));
       lngResultCode:=_SetComputerNameEx(5,strNewName);
       FreeLibrary(lngModuleHandle);
       if lngResultCode <> 0 then
           fSetComputerNameEx:=True
   end;

// ---------------------------------------------------------------------------

function DSGetDCName(const sTargetDomainName: String; out sDomainControllerName : string; out sDomainControllerAddress : string; out sDomainName : string; out sDnsForestName : string; out sClientSiteName : string): integer;
Type
    TDomainControllerInfoA = record
        DomainControllerName: LPSTR;
        DomainControllerAddress: LPSTR;
        DomainControllerAddressType: ULONG;
        DomainGuid: TGUID;
        DomainName: LPSTR;
        DnsForestName: LPSTR;
        Flags: ULONG;
        DcSiteName: LPSTR;
        ClientSiteName: LPSTR;
    end;
    PDomainControllerInfoA = ^TDomainControllerInfoA;
    Type_DsGetDcName =  function(ComputerName, DomainName: PChar; DomainGuid: PGUID; SiteName: PChar; Flags: ULONG; var DomainControllerInfo: PDomainControllerInfoA): longint; stdcall;

const
    DS_IS_FLAT_NAME = $00010000;
    DS_RETURN_DNS_NAME  = $40000000;
var
    DomainControllerInfo: PDomainControllerInfoA;
    lngResultCode : LongInt;
    iResultCode : integer;
    _DsGetDcName : Type_DsGetDcName;
    pTargetDomain : PChar;

begin
    sDomainControllerName:='';
    sDomainControllerAddress:='';
    sDomainName:='';
    sDnsForestName:='';
    sClientSiteName:='';
    if sTargetDomainName = '' then
        pTargetDomain:=nil
    else
        pTargetDomain:=PChar(sTargetDomainName);
    try
        iResultCode:=LoadLibrary(pchar('NetAPI32.dll'));
        @_DsGetDcName:=GetProcAddress(iResultCode,pchar('DsGetDcNameA'));
        lngResultCode:=_DsGetDcName(nil,pTargetDomain , nil, nil, DS_IS_FLAT_NAME or DS_RETURN_DNS_NAME, DomainControllerInfo);
        FreeLibrary(iResultCode);
        if lngResultCode = NO_ERROR then begin
            sDomainControllerName:=DomainControllerInfo^.DomainControllerName;
            sDomainControllerAddress:=DomainControllerInfo^.DomainControllerAddress;
            sDomainName:=DomainControllerInfo^.DomainName;
            sDnsForestName:=DomainControllerInfo^.DnsForestName;
            sClientSiteName := DomainControllerInfo^.ClientSiteName;
            Result := 0;
            FreeBuffer(DomainControllerInfo);
        end;
    finally
    end;
    Result:=lngResultCode;
end;

// ---------------------------------------------------------------------------

function RenameComputerInDomain(strTargetComputer,strNewComputerName,strUserID,strPassword : string): Boolean;
   type
       Type_NetRenameMachineInDomain = function (lpserver, machinename, lpaccount, passwrd : PWideChar; foptions : LongInt) : LongInt stdcall;
    var
        pwcNewComputerName, pwcUserID, pwcPassword,
        pwcTargetComputer                           : PWideChar;
        lngResultCode                               : LongInt;
        intResultCode, iRetryCount                  : Integer;
        _NetRenameMachineInDomain                   : Type_NetRenameMachineInDomain;
        sPathtoExistingAccount, sRetCodeADSI        : String;
        bExit                                       : Boolean;
   begin
       iRetryCount:=0;
       Repeat
           bExit:=True;
           RenameComputerInDomain:=False;
           pwcNewComputerName:=Nil;
           pwcUserID:=Nil;
           pwcPassword:=Nil;
           pwcTargetComputer:=Nil;
           sPathtoExistingAccount:='';
           Try
               intResultCode:=LoadLibrary(pchar('netapi32.dll'));
               @_NetRenameMachineInDomain:=GetProcAddress(intResultCode,pchar('NetRenameMachineInDomain'));
               GetMem(pwcNewComputerName,2*Length(strNewComputerName)+2);
               GetMem(pwcUserID,2*Length(strUserID)+2);
               GetMem(pwcPassword,2*Length(strPassword)+2);
               GetMem(pwcTargetComputer,2*Length(strTargetComputer)+2);
               StringToWideChar(strNewComputerName,pwcNewComputerName,Length(strNewComputerName)+2);
               StringToWideChar(strUserID,pwcUserID,Length(strUserID)+2);
               StringToWideChar(strPassword,pwcPassword,Length(strPassword)+2);
               StringToWideChar(strTargetComputer,pwcTargetComputer,Length(strTargetComputer)+2);
               lngResultCode:= _NetRenameMachineInDomain(pwcTargetComputer,pwcNewComputerName,pwcUserID,pwcPassword,2);
               FreeLibrary(intResultCode);
           Finally
               FreeMem(pwcNewComputerName);
               FreeMem(pwcUserID);
               FreeMem(pwcPassword);
               FreeMem(pwcTargetComputer);
           end;
           if lngResultCode = 0 then
               RenameComputerInDomain:=TRUE
           else if lngResultCode = 1219 then begin
               AppendToLogFile('Call to Rename Computer in Domain returned error 1219 (session credential conflict)');
               AppendToLogFile('You have an exisitng connection to the server with a different username');
           end
           else if lngResultCode = 2224 then begin
               AppendToLogFile('Call to Rename Computer in Domain returned error 2224 (account already exists)');
               if (sDomainControllerName <> '') and (sDomainName <> '') then begin
                      AppendToLogFile('Domain Controller to ask  : ' + sDomainControllerName);
                      sPathtoExistingAccount:=ADSIFindComputerByShellHack(strNewComputerName,sDomainControllerName,sDomainName,strUserID,strPassword);
                      if sPathtoExistingAccount <> '' then
                          AppendToLogFile('Existing Account found at : ' + sPathtoExistingAccount)
                      else begin
                          AppendToLogFile('Failed to find existing account, ADSI processing error');
                          bDeleteExistingComputerAccount:=False;
                          bExit:=True;
                      end;
               end
               else begin
                   AppendToLogFile('Could not locate a Domain Controller or DNS resolution problem, processing terminated');
                   bExit:=True;
               end;
               if bDeleteExistingComputerAccount then begin
                   bExit:=False;
                   AppendToLogFile('Attempting to delete exisiting account');
                   sRetCodeADSI:= ADSIDeleteComputerByShellHack(sPathtoExistingAccount,strUserID,strPassword);
                   if sRetCodeADSI = '0' then
                       AppendToLogFile('Sucessfully deleted existing computer account')
                   else
                       AppendToLogFile('Attempt to delete computer account failed with error ' + sRetCodeADSI);
                   AppendToLogFile('Will retry rename in domain operation');
               end
           end
           else if lngResultCode = 8206 then begin
               bExit:=False;
               AppendToLogFile('Call to Rename Computer in Domain returned error 8206 (The directory service is busy)');
               AppendToLogFile('Will retry rename in domain operation');
           end
           else if lngResultCode = 5 then begin
               bExit:=True;
               AppendToLogFile('Call to Rename Computer in Domain returned error 5 (Access is Denied)');
               AppendToLogFile('Check your credentials have appropriate privileges to perform this operation');
           end
           else begin
               AppendToLogFile('Call to Rename Computer in Domain returned error : ' + inttostr(lngResultCode));
               AppendToLogFile('Refer to http://msdn.microsoft.com/library/default.asp?url=/library/en-us/netmgmt/netmgmt/network_management_error_codes.asp');
           end;
           if bExit=False then begin
               iRetryCount:=iRetryCount+1;
               if iRetryCount > DOMAIN_RENAME_RETRIES then begin
                   AppendToLogFile('Retry limit reached, giving up');
                   bExit:=True;
               end;
               if bExit = False then
                  Sleep(DOMAIN_RENAME_RETRY_DELAY * 1000);
           end
       Until bExit;
   end;

// ---------------------------------------------------------------------------

  function GetHostName:String;
  var
    Reg : TRegistry;
  begin
    Reg:=TRegistry.Create;
    Reg.RootKey:=HKey_Local_Machine;
    if GetOSVersion(False) = OS_WINNT then
        Reg.OpenKey(WinNTHostNameRegKey,True)
    else
        Reg.OpenKey(Win9xHostNameRegKey,True);
    result:=Reg.ReadString('Hostname');
    Reg.Free;
  end;

// ---------------------------------------------------------------------------

procedure SetHostName(HostName:string);
  var
    Reg: TRegistry;
  begin
    if not TaskTestOnly then begin
      Reg:=TRegistry.Create;
      Reg.RootKey:=HKey_Local_Machine;
      if GetOSVersion(False) = OS_WINNT then
          Reg.OpenKey(WinNTHostNameRegKey,True)
      else
          Reg.OpenKey(Win9xHostNameRegKey,True);
      Reg.WriteString('Hostname',HostName);
      Reg.Free;
    end;
  end;

// ---------------------------------------------------------------------------

procedure SetNVHostName(HostName:string);
  var
    Reg: TRegistry;
  begin
    if not TaskTestOnly then begin
      AppendToLogFile('SetNVHostName             : Setting "NV HostName" value for Novell Client');
      Reg:=TRegistry.Create;
      Reg.RootKey:=HKey_Local_Machine;
      if GetOSVersion(False) = OS_WINNT then
          Reg.OpenKey(WinNTHostNameRegKey,True)
      else
          Reg.OpenKey(Win9xHostNameRegKey,True);
      Reg.WriteString('NV Hostname',HostName);
      Reg.Free;
    end;
  end;

// ---------------------------------------------------------------------------

procedure SetLogOnTo(NewName:string);
  var
    Reg: TRegistry;
  begin
    AppendToLogFile('Set Log On To             : Setting default target for local logon to ' + NewName);

    if not TaskTestOnly then begin
      if GetOSVersion(False) = OS_WINNT then begin
        Reg:=TRegistry.Create;
        Reg.RootKey:=HKEY_LOCAL_MACHINE;
        Reg.OpenKey('SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon',True);
        Reg.WriteString('DefaultDomainName',NewName);
        Reg.Free;
      end
      else
         AppendToLogFile('Set Log On To             : This feature requires Windows NT or Windows 2000');
    end;
  end;

// ---------------------------------------------------------------------------

function GetExplorerVersion:String;
    var  Reg           : TRegistry;
         strExpVersion : string;
    begin
        strExpVersion:= '0';
        Reg:=TRegistry.Create;
        Reg.RootKey:=HKEY_LOCAL_MACHINE;
        Reg.OpenKey('\Software\Microsoft\Internet Explorer',True);
        strExpVersion:= Reg.ReadString('Version');
        Reg.Free;
        GetExplorerVersion:= strExpVersion;
    end;

// ---------------------------------------------------------------------------

function GetMajorExplorerVersionInt:Integer;
    var  strExpVersion : string;
    begin
        strExpVersion:='';
        strExpVersion:=GetExplorerVersion;
        if length(strExpVersion) < 1 then
            strExpVersion:='0';
        if Not (strExpVersion[1] in ['0'..'9']) then
            strExpVersion:='0';
        GetMajorExplorerVersionInt:= StrToInt(strExpVersion[1]);
    end;

// ---------------------------------------------------------------------------

function GetWindowsSystemDirectory: String;
var
  arrTemp: array [0..MAX_PATH+1] of Char;
begin
  Result := '';
  if (GetSystemDirectory(arrTemp,SizeOf(arrTemp)) > 0) then begin
    if (Copy(arrTemp,Length(arrTemp),1) <> '\') then StrCat(arrTemp,'\');
    Result := arrTemp;
  end;
end;

// ---------------------------------------------------------------------------

function GetWindowsDrive: String;
  var
    arrTemp : array [0..MAX_PATH+1] of Char;
    sResult : string;
  begin
    Result:= '';
    if (GetWindowsDirectory(arrTemp,SizeOf(arrTemp)) > 0) then begin
      if (Copy(arrTemp,Length(arrTemp),1) <> '\') then
        StrCat(arrTemp,'\');
      sResult:=arrTemp;
      if Length(arrTemp) > 2 then
        sResult:=Copy(sResult,1,2)
      else
        sResult:='';
      Result:=sResult;
    end;
  end;

// ---------------------------------------------------------------------------

procedure SetMyComputerName(NewName:string);
    var
        Reg                : TRegistry;
        IE6orBetter        : Boolean;
        strLocalizedString : string;
        intI               : integer;
    begin
        //http://www.jsifaq.com/SUBE/tip2000/rh2001.htm
        AppendToLogFile('Set My Computer Name      : Renaming "My Computer" on the desktop to ' + NewName);
        if not TaskTestOnly then begin
            Reg:=TRegistry.Create;
            if OSver = 'WIN9X' then begin
                AppendToLogFile('Set My Computer Name      : Updating HKLM\Software\Classes\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}');
                Reg.RootKey:=HKEY_LOCAL_MACHINE;
                Reg.OpenKey('Software\Classes\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}',True);
                Reg.WriteString('',NewName);
                AppendToLogFile('Set My Computer Name      : Updating HKCR\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}');
                Reg.RootKey:=HKEY_CLASSES_ROOT;
                Reg.OpenKey('CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}',True);
                Reg.WriteString('',NewName);
            end         //End of WIN9X section
            else begin  //Must be WinNT or better
                AppendToLogFile('Set My Computer Name      : Updating HKCR\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}');
                //AppendToLogFile('Set My Computer Name      : Refer http://www.jsifaq.com/SUBE/tip2000/rh2001.htm');
                Reg.RootKey:=HKEY_CLASSES_ROOT;
                Reg.OpenKey('\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}',True);
                Reg.WriteExpandString('','%ComputerName%');
                if (OSVerDetailed <> OS_WINNT) then begin
                    //Additional work required for W2K and above
                    IE6orBetter:=False;
                    if GetMajorExplorerVersionInt > 5 then
                        IE6orBetter:=True;
                    if (OSVerDetailed = OS_WIN2K) and NOT IE6orBetter then begin
                        strLocalizedString:=Reg.ReadString('LocalizedString');
                        AppendToLogFile('Set My Computer Name      : LocalizedString is ' + strLocalizedString);
                        intI:=InStrRev(0,strLocalizedString,',');
                        if intI <> 0 then begin
                            strLocalizedString:=Copy(strLocalizedString,1,intI) + '%ComputerName%';
                            AppendToLogFile('Set My Computer Name      : Setting LocalizedString to ' + strLocalizedString);
                            Reg.WriteExpandString('LocalizedString',strLocalizedString)
                        end
                        else
                            AppendToLogFile('Set My Computer Name      : Error! - LocalizedString contained an unexpected string');
                     end
                     else
                         Reg.WriteExpandString('LocalizedString','%ComputerName%');
                end;
            end;        //End of WinNT, 2K, XP
            Reg.Free;
        end;
    end;

// ---------------------------------------------------------------------------

procedure SetMyComputerDescription(NewName:string);
  var
    Reg: TRegistry;
  begin
    AppendToLogFile('Set Computer Description  : Setting computer description to "' + NewName + '" [' + inttostr(Length(NewName)) + ']');
    // -- Added version 2.88 - 14 Feb 2009 - will parse for variables in the description field)
    NewName:=EvaluateString(NewName);
    // -- End change
    if Length(NewName) > 256 then begin
        AppendToLogFile('Set Computer Description  : Truncating description to 256 characters');
        NewName:=Copy(NewName,1,256);
        AppendToLogFile('Set Computer Description  : Now Setting computer description to "' + NewName + '"');
    end;
    if not TaskTestOnly then begin
      if OSver = 'WIN9X' then begin
        Reg:=TRegistry.Create;
        Reg.RootKey:=HKEY_LOCAL_MACHINE;
        Reg.OpenKey(Win9xComputerDescriptionKey,True);
        Reg.WriteString('Comment',NewName);
        Reg.Free;
      end
      else begin
        Reg:=TRegistry.Create;
        Reg.RootKey:=HKEY_LOCAL_MACHINE;
        Reg.OpenKey(WinNTComputerDescriptionKey,True);
        Reg.WriteString('srvcomment',NewName);
        Reg.Free;
      end;
    end;
  end;

function GetCurrentUserName:string;
  var
    UserName : String;
    NameSize : DWORD;
  begin
    result:='';
    NameSize := 255;
    SetLength(UserName, 254);
    if GetUserName(pChar(UserName), NameSize) then begin
      SetLength(UserName, NameSize);
      result:=Trim(UserName);
   end;
  end;

// ---------------------------------------------------------------------------

function GenerateRandomName(iLength : integer) : string;
Const
 Codes64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';


var
  i, x: integer;
  s1, s2: string;
begin
  s1 := Codes64;
  s2 := '';
  Randomize;
  for i := 0 to iLength - 1 do begin
    x  := Random(Length(s1));
    x  := Length(s1) - x;
    s2 := s2 + s1[x];
    s1 := Copy(s1, 1,x - 1) + Copy(s1, x + 1,Length(s1));
  end;
  Result := s2;
end;

// ---------------------------------------------------------------------------

function GenerateRandomNumber(iLength : integer) : string;
Const
 Codes64 = '0123456789';

var
  i, x: integer;
  s1, s2: string;
begin
  s1 := Codes64;
  s2 := '';
  Randomize;
  for i := 0 to iLength - 1 do begin
    x  := Random(Length(s1));
    x  := Length(s1) - x;
    s2 := s2 + s1[x];
  end;
  Result := s2;
end;

// ---------------------------------------------------------------------------

function GetTempDirectory:string;
  var TempDirectory : pChar;
      BuffSize      : Dword;
      s             : string;
  begin
    Buffsize:=255;
    TempDirectory := StrAlloc(Buffsize);
    GetTempPath(BuffSize,TempDirectory);
    s:=StrPas(TempDirectory);
    if s[length(s)] <> '\' then
      s:=s+'\';
    Result:=s;
  end;

// ---------------------------------------------------------------------------

procedure AppendtoLogFile(s : string);
  var f: textfile;
  begin
    assignfile(f,LogFilePathandName);
    if fileexists(LogFilePathandName) then
      append(f)
    else
      rewrite(f);
    writeln(f,DateTimetoStr(Now) + ' : ' + s);
    flush(f);
    closefile(f);
  end;

// ---------------------------------------------------------------------------

function ReadAsStringFromRegistry(rootkey:HKEY;basekey,keyvalue:string):string;
  var
    reg           : TRegistry;
    keytype       : TRegDataType;

  begin
    Reg:=TRegistry.Create;
    Reg.RootKey:=rootkey;
    Reg.OpenKey(basekey,True);
    result:='';
    if Reg.ValueExists(keyvalue) then begin           // Check key exists first to avoid errors
      keytype:=Reg.GetDataType(keyvalue);
      if keytype = rdInteger then
        result:=inttostr(Reg.ReadInteger(keyvalue))
      else if keytype = rdString then
        result:=Reg.Readstring(keyvalue);
    end;
    Reg.Free
  end;

// ---------------------------------------------------------------------------

procedure CheckCommandLine;
  var intI    : integer;
      strTEMP : string;
  begin
    TaskHelpStuff:=False;
    TaskPostGhost:=False;
    TaskNameSync:=False;
    TaskReboot:=False;
    TaskNoReboot:=False;
    UseAlternateMACAddressRoutine:=False;
    TaskTestOnly:=False;
    TaskSetDiskLabel:=False;
    bTaskSetMyComputerName:=False;
    TaskLogOnTo:=False;
    TaskChangeHostNameOnly:=False;
    TaskAlwaysDoRename:=False;
    TaskSetMyComputerDescription:=False;
    TaskRenameComputerInDomain:=False;
    TaskReadFromDataFile:=False;
    bTaskSetWorkGroup:=False;
    bAllowLongDNSHostNames:=False;
    bNoStrictNameChecking:=False;
    bUnattendFileMode:=False;
    bTaskMaskPassword:=False;
    AsEnteredComputerName:='';
    sComputerDescription:='';
    sWorkGroupName:='';
    sAlternateLogFileLocation:='';

    if (Pos(UpperCase('/H'),UpperCase(strPas(cmdline))) <> 0) or (Pos(UpperCase('/?'),UpperCase(strPas(cmdline))) <> 0) then
      TaskHelpStuff:=True;
    if (Pos(UpperCase(PostGhostSwitch),UpperCase(strPas(cmdline))) <> 0) then
      TaskPostGhost:=True;
    if (Pos(UpperCase(NameSyncSwitch),UpperCase(strPas(cmdline))) <> 0) then
      TaskNameSync:=True;
    if (Pos(UpperCase(RebootSwitch),UpperCase(strPas(cmdline))) <> 0) then
      TaskReboot:=True;
    if (Pos(UpperCase(NoRebootSwitch),UpperCase(strPas(cmdline))) <> 0) then
      TaskNoReboot:=True;
    if (Pos(UpperCase(NEW_COMPUTERNAME_SWITCH),UpperCase(strPas(cmdline))) <> 0) then
      TaskSilent:=True;
    if (Pos(UpperCase(TestOnlySwitch),UpperCase(strPas(cmdline))) <> 0) then
      TaskTestOnly:=True;
    if (Pos(UpperCase(SetDiskLabelSwitch),UpperCase(strPas(cmdline))) <> 0) then
      TaskSetDiskLabel:=True;
    if (Pos(UpperCase(SET_MY_COMPUTERNAME_SWITCH),UpperCase(strPas(cmdline))) <> 0) then
      bTaskSetMyComputerName:=True;
    if (Pos(UpperCase(SetLogOnToSwitch),UpperCase(strPas(cmdline))) <> 0) then
      TaskLogOnTo:=True;
    if (Pos(UpperCase(ChangeHostNameOnlySwitch),UpperCase(strPas(cmdline))) <> 0) then
      TaskChangeHostNameOnly:=True;
    if (Pos(UpperCase(AlwaysDoRenameSwitch),UpperCase(strPas(cmdline))) <> 0) then
      TaskAlwaysDoRename:=True;
    if (Pos(UpperCase(IGNORE_DOMAIN_MEMBERSHIP_SWITCH),UpperCase(strPas(cmdline))) <> 0) then
      bIgnoreDomainMemberShip:=True;
    if (Pos(UpperCase(NO_STRICT_NAME_CHECKING_SWITCH),UpperCase(strPas(cmdline))) <> 0) then
      bNoStrictNameChecking:=True;
    if (Pos(UpperCase(DELETE_EXISTING_ACCOUNT),UpperCase(strPas(cmdline))) <> 0) then
      bDeleteExistingComputerAccount:=True;
    if (Pos(UpperCase(MASK_PASSWORD_SWITCH),UpperCase(strPas(cmdline))) <> 0) then
      bTaskMaskPassword:=True;

    if (Pos(UpperCase(REPLACE_SPACE_IN_NAME_SWITCH),UpperCase(strPas(cmdline))) <> 0) then  // ver 2.91
      bReplaceSpaceChars:=True;

    if (Pos(UpperCase(WRITE_NAME_TO_FILE_SWITCH),UpperCase(strPas(cmdline))) <> 0) then  // ver 2.92
      bWriteNametoFile:=True;

    if (Pos(UpperCase(ALLOW_LONG_DNS_HOST_NAMES),UpperCase(strPas(cmdline))) <> 0) then
      bAllowLongDNSHostNames:=True;

    if (Pos(UpperCase(SetMyComputerDescriptionSwitch),UpperCase(strPas(cmdline))) <> 0) then
      TaskSetMyComputerDescription:=True;

    if (Pos(UpperCase(SetMyComputerDescriptionSwitch)+':',UpperCase(strPas(cmdline))) <> 0) then
      sComputerDescription:=GetValueFromCommandLineString(cmdline,SetMyComputerDescriptionSwitch+':');

    if (Pos(UpperCase(RenameComputerInDomainSwitch),UpperCase(strPas(cmdline))) <> 0) then
      TaskRenameComputerInDomain:=True;

    // ------- Updated 30th March 2007 (2.82) to add support for User ID's and passwords with spaces in them

    if (Pos(UpperCase(DomainUserIDSwitch),UpperCase(strPas(cmdline))) <> 0) then
      strDomainUserID:=GetValueFromCommandLineString(cmdline,DomainUserIDSwitch);

    if (Pos(UpperCase(DomainPasswordSwitch),UpperCase(strPas(cmdline))) <> 0) then
      strDomainPassword:=GetValueFromCommandLineString(cmdline,DomainPasswordSwitch);

    // ------- Updated 16th March 2008 (2.86) to add support for encrypted passwords

    if (Pos(UpperCase(DomainPasswordMaskedSwitch),UpperCase(strPas(cmdline))) <> 0) then
      strDomainPassword:=DemaskString(GetValueFromCommandLineString(cmdline,DomainPasswordMaskedSwitch));

    // ---- Update to allow an alternate logfile location to be specified

    if (Pos(UpperCase(LOGFILE_LOCATION_SWITCH),UpperCase(strPas(cmdline))) <> 0) then
      sAlternateLogFileLocation:=GetValueFromCommandLineString(cmdline,LOGFILE_LOCATION_SWITCH);

    // ---- End Update 30th March 2007 (2.82)


     // ---- Start Update 20th June 2007 to allow Unattend Mode (2.83)

    if (Pos(UpperCase(UNATTEND_MODE_SWITCH),UpperCase(strPas(cmdline))) <> 0) then begin
      sUnattendFile:=GetValueFromCommandLineString(cmdline,UNATTEND_MODE_SWITCH);
      bUnattendFileMode:=True;
    end;

    // ---- End Update 2.83


    if (Pos(UpperCase(LOGFILE_LOCATION_SWITCH),UpperCase(strPas(cmdline))) <> 0) then
      sAlternateLogFileLocation:=GetValueFromCommandLineString(cmdline,LOGFILE_LOCATION_SWITCH);

    if (Pos(UpperCase(ReadFromDataFileSwitch),UpperCase(strPas(cmdline))) <> 0) then begin
      TaskReadFromDataFile:=TRUE;
      strDataFileName:=GetValueFromCommandLineString(cmdline,ReadFromDataFileSwitch);
    end;

    if (Pos(UpperCase(DataFileKeySwitch),UpperCase(strPas(cmdline))) <> 0) then
      strDataFileKey:=GetValueFromCommandLineString(cmdline,DataFileKeySwitch);

    if (Pos(UpperCase(SetWorkGroupSwitch),UpperCase(strPas(cmdline))) <> 0) then begin
        strTEMP:=strPas(cmdline);
        intI:= Pos(SetWorkGroupSwitch,UpperCase(strTEMP));
        strTEMP:=copy(strTEMP,intI+Length(SetWorkGroupSwitch),length(strTEMP)-intI-Length(SetWorkGroupSwitch)+1);
        if length(strTEMP) > 0 then begin    // Catch switch with no value
          if strTEMP[1] = '"' then begin   // Handle filenames with spaces in path
            strTEMP:=Copy(strTEMP,2,Length(strTEMP)-1);
            intI:= Pos('"',strTEMP);     //Find position of closing quote
            if intI <> 0 then
               strTEMP:=copy(strTEMP,1,intI-1)
            else begin
              //Add error handling for no closing quote here
            end;
          end
          else begin                       // No quotes to worry about
            intI:= Pos(' ',strTEMP);
            if intI <> 0 then
              strTEMP:=copy(strTEMP,1,intI-1);
          end;
          sWorkGroupName:=strTEMP;
          if sWorkGroupName <> '' then
            bTaskSetWorkGroup:=True;
         end;
      end;

      if (Pos(UpperCase(NETWORK_ADAPTERS_TO_IGNORE),UpperCase(strPas(cmdline))) <> 0) then begin
        strTEMP:=strPas(cmdline);
        intI:= Pos(NETWORK_ADAPTERS_TO_IGNORE,UpperCase(strTEMP));
        strTEMP:=copy(strTEMP,intI+Length(NETWORK_ADAPTERS_TO_IGNORE),length(strTEMP)-intI-Length(NETWORK_ADAPTERS_TO_IGNORE)+1);
        if length(strTEMP) > 0 then begin    // Catch switch with no value
            intI:= Pos(']',strTEMP);         //Find position of closing bracket
            if intI <> 0 then
               strTEMP:=copy(strTEMP,1,intI-1)
            else begin
              //Add error handling for no closing bracket here
            end;
            DW_Split(strTEMP,' ',TStrings(tsNetworkAdapterExclusionList),qoNOBEGINEND or qoNOCRLF or qoPROCESS);
        end;
      end;
  end;

// ---------------------------------------------------------------------------

Function GetValueFromCommandLineString(sStr:PChar; sMarker:string):string;
  // Added version 2.82 - 31st March 2007
  Var sTempStr : string;
      iI       : integer;
  begin
    result:='';
    sTempStr:=strPas(sStr);
    if (Pos(UpperCase(sMarker),UpperCase(sTempStr)) <> 0) then begin
       iI:= Pos(sMarker,UpperCase(sTempStr));
      sTempStr:=copy(sTempStr,iI+Length(sMarker),length(sTempStr)-iI-Length(sMarker)+1);
      if length(sTempStr) > 0 then begin      // Catch switch with no value
        if sTempStr[1] = '"' then begin       // Handle values with spaces in path
          sTempStr:=Copy(sTempStr,2,Length(sTempStr)-1);
          iI:= Pos('"',sTempStr);             // Find position of closing quote
          if iI <> 0 then
            sTempStr:=copy(sTempStr,1,iI-1)
          else begin
                                              // Add error handling for no closing quote here
          end;
        end
        else begin                            // No quotes to worry about
          iI:= Pos(' ',sTempStr);
          if iI <> 0 then
            sTempStr:=copy(sTempStr,1,iI-1);
        end;
        result:=sTempStr;
      end;
    end;
  end;

// ---------------------------------------------------------------------------


  function NumberofSubStringsInString(strTMP:string; strSUBTMP:char):integer;
  var i, count : integer;
  begin
      count:=0;
      if length(strTMP) = 0 then begin
          result:=0;
          exit;
      end;
      i:=Pos(strSUBTMP, strTMP);
      While i <> 0 do begin
           count:=count + 1;
           delete(strTMP,1,i);
           i:=Pos(strSUBTMP, strTMP);
      end;
      result:=count;
   end;

// ---------------------------------------------------------------------------

  function IsValidIPAddress(address:string):Boolean;
   var IPOctet : array[1..4] of string;
          i, j : integer;
   begin
      if NumberofSubStringsInString(address,'.') = 3 then begin
           i:=pos('.',address);
           IPOctet[1]:=copy(address,1,i-1);
           delete(address,1,i);
           i:=pos('.',address);
           IPOctet[2]:=copy(address,1,i-1);
           delete(address,1,i);
           i:=pos('.',address);
           IPOctet[3]:=copy(address,1,i-1);
           delete(address,1,i);
           IPOctet[4]:=address;
           if (length(IPOctet[1]) = 0) or (length(IPOctet[2]) = 0) or (length(IPOctet[3]) = 0) or (length(IPOctet[4]) = 0) or
              (length(IPOctet[1]) > 3) or (length(IPOctet[2]) > 3) or (length(IPOctet[3]) > 3) or (length(IPOctet[4]) > 3) then begin
               result:=false;
               exit;
           end;
           for i:=1 to 4 do begin
              for j:=1 to length(IPOctet[i]) do begin
                 if not (IPOctet[i,j] in ['0'..'9']) then begin
                     result:=false;
                     exit;
                 end;
              end;
           end;
           for i:=1 to 4 do begin
               j:=StrToInt(IPOctet[i]);
               if j > 254 then begin
                   result:=false;
                   exit;
               end;
           end;
           result:=true;
      end
      else
           result:=false;
           exit;
     end;

// ---------------------------------------------------------------------------

  function GetValueFromFile(strDataFileName : string; strKeyString : string) : string;
    var
       tfDataFile                             : TextFile;
       strBuffer, strKey, strValue, strResult : string;
       intIndex                               : integer;
       blnExit                                : boolean;

    begin
       strValue:='';
       strKey:='';
       strBuffer:='';
       strResult:='';
       blnExit:=False;
       strDataFileName:=Trim(strDataFileName);
       strKeyString:=Trim(strKeyString);
       if not FileExists(strDataFileName) then
           Exit;
       try
           AssignFile(tfDataFile, strDataFileName);
           Reset(tfDataFile);
           while (not EOF(tfDataFile)) and (not blnExit) do begin
               ReadLn(tfDataFile, strBuffer);
               intIndex:=Pos('=',strBuffer);
               if intIndex <> 0 then begin
                   strKey:=Trim(Copy(strBuffer,1,intIndex-1));
                   strValue:=Trim(Copy(strBuffer,intIndex+1,length(strBuffer)-intIndex+1));
                   if UpperCase(strKey) = UpperCase(strKeyString) then begin
                       strResult:=strValue;
                       blnExit:=True;
                   end;
               end;
           end;
       finally
           CloseFile(tfDataFile);
       end;
       GetValueFromFile:=strResult;
  end;

// ---------------------------------------------------------------------------

  procedure ExitRoutine(exitcode:byte);
    begin
      AppendToLogFile('Terminate                 : Exit code ' + inttostr(exitcode));
       Case exitcode of
        18 : Halt(exitcode);  // XML Unattend Mode option selected but error updating file
        17 : Halt(exitcode);  // XML Unattend Mode option selected but file not found
        16 : Halt(exitcode);  // Unattend Mode option selected but path to file invalid
        15 : Halt(exitcode);  // Rename was attempted on Domain member without using /RCID
        14 : Halt(exitcode);  // Search Key not found in Data File
        13 : Halt(exitcode);  // Filename specified in /RDF not found
        12 : Halt(exitcode);  // Search key for /RDF mode not passed
        11 : Halt(exitcode);  // RenameinDomain on unsupported OS
        10 : Halt(exitcode);  // Request to Reboot Failed
         9 : Halt(exitcode);  // No local Admin Rights
         8 : Halt(exitcode);  // New name validity check failed
         7 : Halt(exitcode);  // Computer is already named "newname"
         6 : Halt(exitcode);  // Rename failed - cause unknown
         5 : Halt(exitcode);  // Can't read MAC Address
         4 : Halt(exitcode);  // Could not determine local IP address
         3 : Halt(exitcode);  // Reverse Lookup Failed

      else
        Application.Terminate;
      end;


    end;

// ---------------------------------------------------------------------------

  procedure NameSync;
    begin
      if UpperCase(HostName) <> UpperCase(ComputerName) then begin
        AppendToLogFile('Name Sync                 : Computer and Host Names Do Not Match - setting hostname to ' + ComputerName);
        SetHostName(ComputerName);
        //if blnNetWareClientInstalled then
           SetNVHostName(ComputerName);
        if TaskReboot then begin
            if Not WinExit(EWX_REBOOT or EWX_FORCE) then begin
               AppendToLogFile('ERROR - Reboot request failed, WSName terminating');
               ExitRoutine(10)
            end;
        end;
      end
      else
        AppendToLogFile('Name Sync                 : Computer and Host Names Match - no action required');
   end;

// ---------------------------------------------------------------------------

  function PostGhostNameMatch:Boolean;
  // Returns TRUE if names match
    var tmpstr : string;
         i     : integer;
    begin
      AppendToLogFile('Operation                 : Post Ghost Mode');
      result:=false;
      tmpstr:=UpperCase(strPas(cmdline));
      i:= Pos('/PG:',tmpstr);
      tmpstr:=copy(tmpstr,i+4,length(tmpstr)-i-3);
      i:= Pos(' ',tmpstr);
      if i <> 0 then
        tmpstr:=copy(tmpstr,1,i-1);
      if UpperCase(ComputerName) = tmpstr then begin
         AppendToLogFile('Post Ghost                : Names Match - I''ve got work to do!');
         result:=true;
      end
      else
        AppendToLogFile('Post Ghost                : No Name Match - no action required');
  end;

// ---------------------------------------------------------------------------

  procedure ExtractRes(ResType,ResName,ResNewName : String);
    var
      Res:TResourceStream;
    begin
      Res:=TResourceStream.Create( hInstance,ResName,pChar(ResType));
      Res.SaveToFile(ResNewName);
      Res.Free;
    end;

// ---------------------------------------------------------------------------

  function CheckValidityofCompterName(ComputerNametoCheck:string):boolean;
    const
      LEGACY_VALID_CHARS = ['a'..'z','A'..'Z','0'..'9','!','@','#','%','$','^','&','(',')','-','_','''','{','}','~']; //removed '.'
             VALID_CHARS = ['a'..'z','A'..'Z','0'..'9','-'];

    var
                    i : integer;
        blnAllNumeric : Boolean;

    begin
      AppendToLogFile('Name Validity Check       : Proposed name is "' + ComputerNametoCheck + '"');
      result:=True;
      if IsWindows2000orBetter then begin
         // Only want to check for numeric names on Windows 2000 or above
         blnAllNumeric:= True;
         for i:=1 to length(ComputerNametoCheck) do begin
             if not (ComputerNametoCheck[i] in ['0'..'9']) then begin
                blnAllNumeric:=False;
                Break;
             end;
         end;
         if blnAllNumeric then begin
             AppendToLogFile('Name Validity Check       : FAILED - All numeric name not permitted under ' + GetOSVersion(true));
             result:=False;
             Exit;
         end;
      end;

      // ---------- This bit updated 20/11/2005 to allow long Host Names ----------------------
      if (length(ComputerNametoCheck) > MAX_LENGTH_NETBIOS_HOST_NAME) then begin
         if bAllowLongDNSHostNames = False then begin
            AppendToLogFile('Name Validity Check       : FAILED - Name too long (Max: ' + IntToStr(MAX_LENGTH_NETBIOS_HOST_NAME) + ')');
            result:=False;
            Exit;
         end
         else begin
              if length(ComputerNametoCheck) > MAX_LENGTH_DNS_HOST_NAME then begin
                 AppendToLogFile('Name Validity Check       : FAILED - Name too long (Max: ' + IntToStr(MAX_LENGTH_DNS_HOST_NAME) + ')');
                 result:=False;
                 Exit;
              end
              else
                 AppendToLogFile('Name Validity Check       : Note: NetBIOS Name for this computer will be truncated to "' + Copy(ComputerNametoCheck,1,MAX_LENGTH_NETBIOS_HOST_NAME) + '"');
         end;
      end;
      // --------------------------------------------------------------------------------------

      if ComputerNametoCheck[1]= '-' then begin
          AppendToLogFile('Name Validity Check       : FAILED - Name starts with "-"');
          result:=False;
          Exit;
      end;

      if IsWindows2000orBetter and (bNoStrictNameChecking = False) then begin
         for i:=1 to length(ComputerNametoCheck) do begin
              if not (ComputerNametoCheck[i] in VALID_CHARS) then begin
                  AppendToLogFile('Name Validity Check       : FAILED - Contains one of more invalid characters ("' + ComputerNametoCheck[i] + '")');
                  result:=False;
                  Break;
              end;
          end;
      end
      else begin
          for i:=1 to length(ComputerNametoCheck) do begin
              if not (ComputerNametoCheck[i] in LEGACY_VALID_CHARS) then begin
                  AppendToLogFile('Name Validity Check       : FAILED - Contains one of more invalid characters ("' + ComputerNametoCheck[i] + '")');
                  result:=False;
                  Break;
              end;
          end;
      end;
    end;

// ---------------------------------------------------------------------------

function CheckInTrim(targetstring : string;maxsize : integer):string;
  // Trims strings to a maximum length, over size strings are cut down to
  // "maxsize" - 3 and have '...' appended to them
  begin
    trim(targetstring);
    if length(targetstring) > maxsize then
      targetstring:=copy(targetstring,1,maxsize-3) + '...';
    result:=targetstring;
  end;

// ---------------------------------------------------------------------------

function IncludeTrailingBackslash(S: string):string;
  begin
    if not (s[length(s)] = '\') then
      result:=S+'\'
    else
      result:=S;
  end;

// ---------------------------------------------------------------------------

function SetDiskLabel(targetdrive, newname:string) : Boolean;
  begin
    if not TaskTestOnly then
      result:=SetVolumeLabel(pchar(IncludeTrailingBackslash(targetdrive)),pchar(newname))
    else
      result:=true;
  end;

// ---------------------------------------------------------------------------

function RenameComputer(newname:string; RebootOnCompletion : Boolean):Boolean;
  var tmpstr, OSVer : string;
      res           : boolean;

  begin
    // --- Added in ver 2.85 to fix issue if this is not set ---
    if AsEnteredComputerName = '' then
        AsEnteredComputerName:=newname;
    // --- End ver 2.85 version changes                      ---

    OSVer:=GetOSVersion(True);
    AppendToLogFile('Operation                 : Rename Computer to ' + newname);
    if not (CheckValidityofCompterName(newname)) then begin
      AppendToLogFile('New name validity check   : Failed - Rename request aborted!');
      ExitRoutine(8);
    end
    else
      AppendToLogFile('New name validity check   : Passed');
      if (UpperCase(ComputerName) = UpperCase(newname)) then begin
          if not TaskAlwaysDoRename then begin
              AppendToLogFile('Computer is already named ' + newname + '. - Rename request aborted!');
              ExitRoutine(7);
          end
          else
              AppendToLogFile('Computer is already named ' + newname + ' but processing continuing due to /ACN switch');
      end;

    if not TaskChangeHostNameOnly then begin
      if bWindows2000orBetter and (TaskRenameComputerInDomain = FALSE) then begin
          AppendToLogFile('Rename Method             : SetComputerNameEx');
          if bInDomain and (bIgnoreDomainMemberShip = FALSE) then begin
            AppendToLogFile('ERROR                     : This device is joined to a Domain, please use the /RCID option.');
            AppendToLogFile('ERROR                       Rename request aborted!');
            ExitRoutine(15);
          end
          else
            result:=fSetComputerNameEx(newname);    //SetComputerNameEx - W2K or later
      end
      else if bWindows2000orBetter and (TaskRenameComputerInDomain = TRUE) then begin
          AppendToLogFile('Rename Method             : NetRenameMachineInDomain');
          AppendToLogFile('User ID                   : ' + strDomainUserID);
          result:=RenameComputerInDomain('',newname,strDomainUserID,strDomainPassword);  //NetRenameMachineInDomain - W2K and newer only
      end
      else begin
          AppendToLogFile('Rename Method             : SetComputerName');
          result:=fSetComputerName(newname)       //Standard old rename for Win9x and WinNT4
      end;
    end
    else begin
      result:=TRUE;
      AppendToLogFile('Change HostName Only option selected (/CHO) NetBIOS name not changed ');
    end;

    if result then begin
      if not TaskChangeHostNameOnly then
        AppendToLogFile('Rename Operation          : SUCCESS - reboot required to take effect');
      //Set Host name happens here - only required for Win9x and NT 4
      if Not bWindows2000orBetter then
          SetHostName(newname);
      // Added in ver 2.66e - Set NV hostname
      if blnNetWareClientInstalled then
          SetNVHostName(newname);
      //
      // ------ Start Set Disk Label ------
      //
      if TaskSetDiskLabel then begin
        tmpstr:=newname;
        if (sWindowsDriveFormat <> 'NTFS') and (length(tmpstr) > 11) then
          tmpstr:=copy(newname,1,11);
        res:=SetDiskLabel(sWindowsDrive,tmpstr);
        if res then
          AppendToLogFile(Copy(sWindowsDrive,1,2) + ' Drive Name set to      : '+ tmpstr)
        else
          AppendToLogFile('Failed to set Drv Name to : '+ tmpstr)
      end;
      //
      // ------- End Set Disk Label -------
      //

      if TaskSetMyComputerDescription then begin
          if sComputerDescription = '' then
             SetMyComputerDescription(AsEnteredComputerName)
          else
             SetMyComputerDescription(sComputerDescription);
       end;

      //
      // ----- Start Set My Computer Name -----
      //

      if bTaskSetMyComputerName then
          SetMyComputerName(AsEnteredComputerName);

      //
      // ----- End Set My Computer Name ------
      //

      if TaskLogOnTo then
         SetLogOnTo(newname);

      if RebootOnCompletion then begin
        AppendToLogFile('Rebooting');
        if Not WinExit(EWX_REBOOT or EWX_FORCE) then begin
            AppendToLogFile('ERROR - Reboot request failed, WSName terminating');
            ExitRoutine(10)
        end;
      end;
    end
    else begin
      AppendToLogFile('Rename Failed');
      ExitRoutine(6);
    end;
  end;

// ---------------------------------------------------------------------------

function PosX(Substr: string; S: string): Integer;
    //Case Insensitive Pos
begin
    Result:=Pos(UpperCase(Substr),UpperCase(S));
end;

// ---------------------------------------------------------------------------

function EvaluateString(sRawInputString:string):string;

const
  sFORM_FACTOR_SEP_CHAR : string = ';';

var
  sTempStr, sStr, sDNSServer, sIPaddress,
  sDesktopIdentifier, sLaptopIdentifier  : string;
  iI, iJ, iP                             : integer;
  bBreak                                 : boolean;
begin
  sDesktopIdentifier:=DEFAULT_DESKTOP_IDENTIFIER;
  sLaptopIdentifier:=DEFAULT_LAPTOP_IDENTIFIER;
  sTempStr:=sRawInputString;

  // ----- IP Address -----
  if PosX(SILENT_IP_ADDRESS,sTempStr) <> 0 then begin
    AppendToLogFile('Parameter Evaluation      : Evaluating ' + SILENT_IP_ADDRESS);
    sStr:=GetIPAddress(0);
    if sStr = '' then begin
      AppendToLogFile('Could not determine local IP address. - Rename request aborted!');
      ExitRoutine(4);
    end;
    //sStr:=PadIPAddress(sStr);
    AppendToLogFile('Parameter Evaluation      : IP Address  : "' + sStr + '"');
    sStr:=StringReplace(sStr,'.','-',[rfReplaceAll, rfIgnoreCase]);
    AppendToLogFile('Parameter Evaluation      : Fix for DNS : "' + sStr + '"');
    sTempStr:=MagicChango(sTempStr,SILENT_IP_ADDRESS,sStr);
    AppendToLogFile('Parameter Evaluation      : Updated input parameter is ' + NEW_COMPUTERNAME_SWITCH + sTempStr);
  end;
 // ----- Date Options -----    added v2.90
  if PosX(SILENT_DATE_DAY,sTempStr) <> 0 then begin
    AppendToLogFile('Parameter Evaluation      : Evaluating ' + SILENT_DATE_DAY);
    sStr:=IntToStr(Integer(DayOf(Now)));
    if length(sStr) = 1 then
      sStr:='0'+sStr;
    AppendToLogFile('Parameter Evaluation      : Day is "' + sStr + '"');
    sTempStr:=MagicChango(sTempStr,SILENT_DATE_DAY,sStr);
    AppendToLogFile('Parameter Evaluation      : Updated input parameter is ' + NEW_COMPUTERNAME_SWITCH + sTempStr);
  end;
  if PosX(SILENT_DATE_MONTH,sTempStr) <> 0 then begin
    AppendToLogFile('Parameter Evaluation      : Evaluating ' + SILENT_DATE_MONTH);
    sStr:=IntToStr(Integer(MonthOf(Now)));
    if length(sStr) = 1 then
      sStr:='0'+sStr;
    AppendToLogFile('Parameter Evaluation      : Month is "' + sStr + '"');
    sTempStr:=MagicChango(sTempStr,SILENT_DATE_MONTH,sStr);
    AppendToLogFile('Parameter Evaluation      : Updated input parameter is ' + NEW_COMPUTERNAME_SWITCH + sTempStr);
  end;
  if PosX(SILENT_DATE_YEAR,sTempStr) <> 0 then begin
    AppendToLogFile('Parameter Evaluation      : Evaluating ' + SILENT_DATE_YEAR);
    sStr:=IntToStr(Integer(YearOf(Now)));
    AppendToLogFile('Parameter Evaluation      : Year is "' + sStr + '"');
    sTempStr:=MagicChango(sTempStr,SILENT_DATE_YEAR,sStr);
    AppendToLogFile('Parameter Evaluation      : Updated input parameter is ' + NEW_COMPUTERNAME_SWITCH + sTempStr);
  end;
  if PosX(SILENT_DATE_YEAR_SHORT,sTempStr) <> 0 then begin
    AppendToLogFile('Parameter Evaluation      : Evaluating ' + SILENT_DATE_YEAR_SHORT);
    sStr:=IntToStr(Integer(YearOf(Now))-2000);
    AppendToLogFile('Parameter Evaluation      : Year is "' + sStr + '"');
    sTempStr:=MagicChango(sTempStr,SILENT_DATE_YEAR_SHORT,sStr);
    AppendToLogFile('Parameter Evaluation      : Updated input parameter is ' + NEW_COMPUTERNAME_SWITCH + sTempStr);
  end;
  // ----- User ID -----
  if PosX(SILENT_USER_NAME,sTempStr) <> 0 then begin
    AppendToLogFile('Parameter Evaluation      : Evaluating ' + SILENT_USER_NAME);
    AppendToLogFile('Parameter Evaluation      : Username is "' + UserName + '"');
    sTempStr:=MagicChango(sTempStr,SILENT_USER_NAME,UserName);
    AppendToLogFile('Parameter Evaluation      : Updated input parameter is ' + NEW_COMPUTERNAME_SWITCH + sTempStr);
  end;
  // ----- Current Computer Name -----
  if PosX(SILENT_CURRENT_COMPUTER_NAME,sTempStr) <> 0 then begin
    AppendToLogFile('Parameter Evaluation      : Evaluating ' + SILENT_CURRENT_COMPUTER_NAME);
    AppendToLogFile('Parameter Evaluation      : Current Name is "' + ComputerName + '"');
    sTempStr:=MagicChango(sTempStr,SILENT_CURRENT_COMPUTER_NAME,ComputerName);
    AppendToLogFile('Parameter Evaluation      : Updated input parameter is ' + NEW_COMPUTERNAME_SWITCH + sTempStr);
  end;
  // ----- Random String -----
  if PosX(SILENT_RANDOM_NAME,sTempStr) <> 0 then begin
    AppendToLogFile('Parameter Evaluation      : Evaluating ' + SILENT_RANDOM_NAME);
    sStr:=GenerateRandomName(15);
    AppendToLogFile('Parameter Evaluation      : Generated Name is "' + sStr + '"');
    sTempStr:=MagicChango(sTempStr,SILENT_RANDOM_NAME,sStr);
    AppendToLogFile('Parameter Evaluation      : Updated input parameter is ' + NEW_COMPUTERNAME_SWITCH + sTempStr);
  end;
  // ----- Random Number -----   2.95 Jun 2012
  if PosX(SILENT_RANDOM_NUMBER,sTempStr) <> 0 then begin
    AppendToLogFile('Parameter Evaluation      : Evaluating ' + SILENT_RANDOM_NUMBER);
    sStr:=GenerateRandomNumber(15);
    AppendToLogFile('Parameter Evaluation      : Generated Name is "' + sStr + '"');
    sTempStr:=MagicChango(sTempStr,SILENT_RANDOM_NUMBER,sStr);
    AppendToLogFile('Parameter Evaluation      : Updated input parameter is ' + NEW_COMPUTERNAME_SWITCH + sTempStr);
  end;
  // ----- OS Type String -----
  if PosX(SILENT_OS_TYPE,sTempStr) <> 0 then begin
    AppendToLogFile('Parameter Evaluation      : Evaluating ' + SILENT_OS_TYPE);
    sStr:=OSVersionToTLA;
    AppendToLogFile('Parameter Evaluation      : OS Shortname is "' + sStr + '"');
    sTempStr:=MagicChango(sTempStr,SILENT_OS_TYPE,sStr);
    AppendToLogFile('Parameter Evaluation      : Updated input parameter is ' + NEW_COMPUTERNAME_SWITCH + sTempStr);
  end;
  // ----- MAC Address String (old style) -----
  if PosX(SILENT_MAC_ADDRESS_II,sTempStr) <> 0 then begin
    AppendToLogFile('Parameter Evaluation      : Evaluating ' + SILENT_MAC_ADDRESS_II);
    UseAlternateMACAddressRoutine:=True;
    sStr:=GetMACAddress(0);
    if UpperCase(sStr) = UpperCase('ERROR') then begin
      AppendToLogFile('Can''t read MAC Address - Rename request aborted!');
      ExitRoutine(5);
    end;
    AppendToLogFile('Parameter Evaluation      : MAC Address  : "' + sStr + '"');
    sTempStr:=MagicChango(sTempStr,SILENT_MAC_ADDRESS_II,sStr);
    AppendToLogFile('Parameter Evaluation      : Updated input parameter is ' + NEW_COMPUTERNAME_SWITCH + sTempStr);
  end;

  // ----- MAC Address String (new style) -----
  if PosX(SILENT_MAC_ADDRESS,sTempStr) <> 0 then begin
    AppendToLogFile('Parameter Evaluation      : Evaluating ' + SILENT_MAC_ADDRESS);
    sStr:=GetMACAddress(0);
    if UpperCase(sStr) = UpperCase('ERROR') then begin
      AppendToLogFile('Can''t read MAC Address - Rename request aborted!');
      ExitRoutine(5);
    end;
    AppendToLogFile('Parameter Evaluation      : MAC Address  : "' + sStr + '"');
    sTempStr:=MagicChango(sTempStr,SILENT_MAC_ADDRESS,sStr);
    AppendToLogFile('Parameter Evaluation      : Updated input parameter is ' + NEW_COMPUTERNAME_SWITCH + sTempStr);
  end;
  // -----   WMI - Get Computer Asset Tag  -----
  if PosX(SILENT_COMPUTER_ASSET_TAG,sTempStr) <> 0 then begin
    AppendToLogFile('Parameter Evaluation      : Evaluating ' + SILENT_COMPUTER_ASSET_TAG);
    if bWindows2000orBetter then begin
      // sStr:=WMIByShellHack('Win32_SystemEnclosure','SMBIOSAssetTag');  ***** replaced with true WMI call 5th Feb 2008 - ver 2.84
      sStr:=getWMIstring('','Win32_SystemEnclosure','SMBIOSAssetTag');
      AppendToLogFile('Parameter Evaluation      : Generated Name is "' + sStr + '"');
    end
    else begin
      sStr:='';
      AppendToLogFile('Get Computer Asset Tag    : This option is only available on Window 2000 or better');
    end;
    sTempStr:=MagicChango(sTempStr,SILENT_COMPUTER_ASSET_TAG,sStr);
    AppendToLogFile('Parameter Evaluation      : Updated input parameter is ' + NEW_COMPUTERNAME_SWITCH + sTempStr);
  end;
  // ----- WMI - Get Computer Manufacturer -----
  if PosX(SILENT_COMPUTER_MANUFACTURER,sTempStr) <> 0 then begin
    AppendToLogFile('Parameter Evaluation      : Evaluating ' + SILENT_COMPUTER_MANUFACTURER);
    if bWindows2000orBetter then begin
      // sStr:=WMIByShellHack('Win32_ComputerSystem','Manufacturer');   ***** replaced with true WMI call 5th Feb 2008 - ver 2.84
      sStr:=getWMIstring('','Win32_ComputerSystem','Manufacturer');
      AppendToLogFile('Parameter Evaluation      : Generated Name is "' + sStr + '"');
    end
    else begin
      sStr:='';
      AppendToLogFile('Get Computer Manufacturer : This option is only available on Window 2000 or better');
    end;
    sTempStr:=MagicChango(sTempStr,SILENT_COMPUTER_MANUFACTURER,sStr);
    AppendToLogFile('Parameter Evaluation      : Updated input parameter is ' + NEW_COMPUTERNAME_SWITCH + sTempStr);
  end;
  // ----- WMI - Get Computer Model -----
  if PosX(SILENT_COMPUTER_MODEL,sTempStr) <> 0 then begin
    AppendToLogFile('Parameter Evaluation      : Evaluating ' + SILENT_COMPUTER_MODEL);
    if bWindows2000orBetter then begin
      // sStr:=WMIByShellHack('Win32_ComputerSystem','Model');   ***** replaced with true WMI call 5th Feb 2008 - ver 2.84
      sStr:=getWMIstring('','Win32_ComputerSystem','Model');
      AppendToLogFile('Parameter Evaluation      : Generated Name is "' + sStr + '"');
    end
    else begin
      sStr:='';
      AppendToLogFile('Get Computer Model        : This option is only available on Window 2000 or better');
    end;
    sTempStr:=MagicChango(sTempStr,SILENT_COMPUTER_MODEL,sStr);
    AppendToLogFile('Parameter Evaluation      : Updated input parameter is ' + NEW_COMPUTERNAME_SWITCH + sTempStr);
  end;
  // ----- WMI - Get Computer Serial Number -----
  if PosX(SILENT_COMPUTER_SERIAL_NUMBER,sTempStr) <> 0 then begin
    AppendToLogFile('Parameter Evaluation      : Evaluating ' + SILENT_COMPUTER_SERIAL_NUMBER);
    if bWindows2000orBetter then begin
      // sStr:=WMIByShellHack('Win32_BIOS','SerialNumber');   ***** replaced with true WMI call 5th Feb 2008 - ver 2.84
      sStr:=getWMIstring('','Win32_BIOS','SerialNumber');
      if sStr = '' then begin
        AppendToLogFile('Parameter Evaluation      : No serial number found using WIN32_BIOS, trying WIN32_SystemEnclosure');
        // sStr:=WMIByShellHack('Win32_SystemEnclosure','SerialNumber');   ***** replaced with true WMI call 5th Feb 2008 - ver 2.84
        sStr:=getWMIstring('','Win32_SystemEnclosure','SerialNumber');
      end;
      AppendToLogFile('Parameter Evaluation      : Generated Name is "' + sStr + '"');
    end
    else begin
      sStr:='';
      AppendToLogFile('Get Computer Serial Number: This option is only available on Window 2000 or better');
    end;
    sTempStr:=MagicChango(sTempStr,SILENT_COMPUTER_SERIAL_NUMBER,sStr);
    AppendToLogFile('Parameter Evaluation      : Updated input parameter is ' + NEW_COMPUTERNAME_SWITCH + sTempStr);
  end;

  // ----- WMI - Get Chassis Type - added 18/03/2007 -----
  // 1 Other
  // 2 Unknown
  // 3 Desktop
  // 4 Low Profile Desktop
  // 5 Pizza Box
  // 6 Mini Tower
  // 7 Tower
  // 8 Portable
  // 9 Laptop
  // 10 Notebook
  // 11 Hand Held
  // 12 Docking Station
  // 13 All in One
  // 14 Sub Notebook
  // 15 Space-Saving
  // 16 Lunch Box
  // 17 Main System Chassis
  // 18 Expansion Chassis
  // 19 Sub Chassis
  // 20 Bus Expansion Chassis
  // 21 Peripheral Chassis
  // 22 Storage Chassis
  // 23 Rack Mount Chassis
  // 24 Sealed-Case PC

  if PosX(SILENT_COMPUTER_CHASSIS_TYPE,sTempStr) <> 0 then begin
    AppendToLogFile('Parameter Evaluation      : Evaluating ' + SILENT_COMPUTER_CHASSIS_TYPE);
    if Copy(sTempStr,PosX(SILENT_COMPUTER_CHASSIS_TYPE,sTempStr) + length(SILENT_COMPUTER_CHASSIS_TYPE),1) = '[' then begin       // added 2.93
        AppendToLogFile('Parameter Evaluation      : Extracting chassis identification strings');
        iI:=Pos(SILENT_COMPUTER_CHASSIS_TYPE,sTempStr) + length(SILENT_COMPUTER_CHASSIS_TYPE) + 1;
        iJ:=iI;
        bBreak:=False;
        Repeat
           if sTempStr[iJ] = ']' then
              bBreak:=True;
          iJ:=iJ+1;
        Until (iJ > Length(sTempStr)) or bBreak;
        sStr:=Copy(sTempStr,iI,iJ-iI-1);
        sStr:=Trim(sStr);
        if length(sStr) <> 0 then begin
            if sStr[Length(sStr)] = ']' then
                sStr:=Copy(sStr,0,Length(sStr)-1);
        end;
        iP:=Pos(sFORM_FACTOR_SEP_CHAR,sStr);
        if iP = 0 then
            AppendToLogFile('ERROR                     : Form factor seperator character missing, was expecting to see "' + sFORM_FACTOR_SEP_CHAR + '"')
        Else Begin
            sDesktopIdentifier:=Copy(sStr,0,iP-1);
            if sDesktopIdentifier = '' then
                sDesktopIdentifier:=DEFAULT_DESKTOP_IDENTIFIER;
            sLaptopIdentifier:=Copy(sStr,iP+1,Length(sStr)-iP);
            if sLaptopIdentifier = '' then
                sLaptopIdentifier:=DEFAULT_LAPTOP_IDENTIFIER;
            AppendToLogFile('Parameter Evaluation      : Extracted chassis identification string for Desktops is now "' + sDesktopIdentifier + '"');
            AppendToLogFile('Parameter Evaluation      : Extracted chassis identification string for Laptops is now  "' + sLaptopIdentifier + '"');
            Delete(sTempStr,iI-1,iJ-iI+1);
            AppendToLogFile('Parameter Evaluation      : Updated input parameter is ' + sTempStr);
        End;
    end;

    if bWindows2000orBetter then begin
      // sStr:=WMIByShellHackCollectionofCollection('Win32_SystemEnclosure','ChassisTypes');   ***** replaced with true WMI call 5th Feb 2008 - ver 2.84
      sStr:=getWMIstring('','Win32_SystemEnclosure','ChassisTypes');
      if (sStr = '8') or (sStr = '9') or (sStr = '10') or (sStr = '12') then
          sStr:=sLaptopIdentifier
      else
          sStr:=sDesktopIdentifier;
      AppendToLogFile('Parameter Evaluation      : Generated Name is "' + sStr + '"');
    end
    else begin
      sStr:='';
      AppendToLogFile('Get Chassis Type          : This option is only available on Window 2000 or better');
    end;
    sTempStr:=MagicChango(sTempStr,SILENT_COMPUTER_CHASSIS_TYPE,sStr);
    AppendToLogFile('Parameter Evaluation      : Updated input parameter is ' + NEW_COMPUTERNAME_SWITCH + sTempStr);
  end;

  // ----- Reverse DNS -----
  if PosX(SILENT_REVERSE_DNS,sTempStr) <> 0 then begin
    AppendToLogFile('Parameter Evaluation      : Evaluating ' + SILENT_REVERSE_DNS);
    if Copy(sTempStr,PosX(SILENT_REVERSE_DNS,sTempStr) + length(SILENT_REVERSE_DNS),1) = ':' then begin
      AppendToLogFile('Parameter Evaluation      : Extracting DNS Server Address');
      iI:=Pos(SILENT_REVERSE_DNS,sTempStr) + length(SILENT_REVERSE_DNS) + 1;
      iJ:=iI;
      iP:=iI;
      bBreak:=False;
      Repeat
        if sTempStr[iJ] = '.' then
          iP:=iJ;
        if (iJ > iP+3) or (not (sTempStr[iJ] in ['0'..'9','.'])) then
          bBreak:=True;
        iJ:=iJ+1;
      Until (iJ > (iI + 15)) or (iJ > Length(sTempStr)) or bBreak;
      sDNSServer:=Copy(sTempStr,iI,iJ-iI);
      AppendToLogFile('Parameter Evaluation      : Extracted DNS Server address is ' + sDNSServer);
      Delete(sTempStr,iI-1,iJ-iI+1);
      AppendToLogFile('Parameter Evaluation      : Updated input parameter is ' + sTempStr);
    end
    else
      sDNSServer:=GetDNSServer;
    if not IsValidIPAddress(sDNSServer) then begin
      AppendToLogFile('Invalid Address for DNS Server (' + sDNSServer + ') - Rename request aborted!');
      ExitRoutine(3);
    end;
    if LocalIPList.count < 1 then begin
      AppendToLogFile('Could not determine local IP address. - Rename request aborted!');
      ExitRoutine(4);
    end;
    sIPaddress:=LocalIPList.Strings[0];
    if sIPaddress = '127.0.0.1' then  // Avoid returning localhost
      sIPaddress:='';
    if sIPaddress = '' then begin
      AppendToLogFile('Could not determine local IP address. - Rename request aborted!');
      ExitRoutine(4);
    end;
    AppendToLogFile('IP Address                : ' + sIPaddress);
    AppendToLogFile('DNS Server IP Address     : ' + sDNSServer);
    if ReverseDNSLookup(sIPAddress, sDNSServer,DNS_TIMEOUT_INTERVAL,sStr) then begin
      AppendToLogFile('Reverse Lookup Returned   : ' + sStr);
      iI:=PosX('.',sStr);
      if iI <> 0 then
        sStr:=Trim(Copy(sStr,1,iI - 1));
        AppendToLogFile('Reverse Lookup Shortname  : ' + sStr);
    end
    else begin
      AppendToLogFile(sStr + ' - Script Terminating');
      ExitRoutine(3);
    end;
    sTempStr:=MagicChango(sTempStr,SILENT_REVERSE_DNS,sStr);
    AppendToLogFile('Parameter Evaluation      : Updated input parameter is ' + NEW_COMPUTERNAME_SWITCH + sTempStr);
  end;

  result:=sTempStr;
end;

// ---------------------------------------------------------------------------

procedure SilentMode;
  var sTempStr : string;
      iI       : integer;
  begin
    AppendToLogFile('Silent Mode               : Starting (' + NEW_COMPUTERNAME_SWITCH + '<name>)');
    sTempStr:=strPas(cmdline);
    iI:= PosX(NEW_COMPUTERNAME_SWITCH,sTempStr);
    sTempStr:=copy(sTempStr,iI+Length(NEW_COMPUTERNAME_SWITCH),length(sTempStr)-iI-2);
    iI:= PosX(' ',sTempStr);
    if iI <> 0 then
      sTempStr:=copy(sTempStr,1,iI-1);
    sTempStr:=EvaluateString(sTempStr);;

    if bReplaceSpaceChars and (Pos(' ',sTempStr) <> 0) then begin       // version 2.91
      AppendToLogFile('Parameter Evaluation      : Name contains spaces (" "), remediating');
      sTempStr:=StringReplace(sTempStr,' ','-',[rfReplaceAll, rfIgnoreCase]);
      AppendToLogFile('Parameter Evaluation      : Modified name is "' +  sTempStr + '"');
    end;

    AsEnteredComputerName:=sTempStr;

    // --------- 2.83 ----------------
    if bUnattendFileMode then begin
      WriteToUnattendFile(AsEnteredComputerName,sUnattendFile);
    end
    // -------------------------------
    else if not TaskTestOnly then
      RenameComputer(sTempStr,TaskReboot);
  end;

// ---------------------------------------------------------------------------

Procedure WriteToUnattendFile(sComputerName,sFileName:string);
  var
    fUnattend : TIniFile;
    oXML      : TNativeXml;
  begin
      if UpperCase(ExtractFileExt(sFileName)) = '.XML' then begin
        AppendToLogFile('Unattend File Mode        : Writing to XML File');
        oXML:=TNativeXml.Create(nil);
        try
          oXML.LoadFromFile(sFileName);
          oXML.Root.FindNode('/unattend/settings/component/ComputerName').Value:= sComputerName;
          oXML.XmlFormat := xfPreserve;
          oXML.SaveToFile(sFileName);
        except
          AppendToLogFile('ERROR                     : Could not update XML file, please verify XML data structure');
          ExitRoutine(18);
        end;
        oXML.Free;
        AppendToLogFile('Termination               : WSName closed normally');
        Application.Terminate;
     end
     else begin
        fUnattend:= TIniFile.Create(sFileName);
        AppendToLogFile('Unattend File Mode        : Writing to INI File');
        fUnattend.WriteString('UserData', 'ComputerName', sComputerName);
        fUnattend.Free;
        AppendToLogFile('Termination               : WSName closed normally');
        Application.Terminate;
     end;
  end;

// ---------------------------------------------------------------------------

Procedure ReadNameFromDataFile;
    var strNameFromFile  : string;
    begin
        strNameFromFile:='';
        AppendToLogFile('Starting Data File Mode Processing (/RDF)');
        AppendToLogFile('Data File Name            : ' + strDataFileName);
        AppendToLogFile('Search Key                : ' + strDataFileKey);
        if strDataFileKey = '' then begin
            AppendToLogFile('No search key passed (/DFK) - Rename request aborted!');
            ExitRoutine(12);
        end;
        if not FileExists(strDataFileName) then begin
            AppendToLogFile('Can''t find data file "' + strDataFileName + '" - Rename request aborted!');
            ExitRoutine(13);
        end;
        strDataFileKey:=EvaluateString(strDataFileKey);
        AppendToLogFile('Data File Mode            : Reading Data File');
        strNameFromFile:=GetValueFromFile(strDataFileName,strDataFileKey);
        if strNameFromFile = '' then begin
            AppendToLogFile('Search Key not found in Data File - Rename request aborted!');
            ExitRoutine(14);
        end
        else
            AppendToLogFile('New Name From Data File   : ' + strNameFromFile);
        // --------- 2.83 ----------------
        if bUnattendFileMode then
          WriteToUnattendFile(strNameFromFile,sUnattendFile)
        // -------------------------------
        else if not TaskTestOnly then
          RenameComputer(strNameFromFile,TaskReboot);
    end;

// ---------------------------------------------------------------------------

Function ReadNovellClientDetails:string;
  const
    NTBaseKey : string = '\SOFTWARE\Novell\NetWareWorkstation\CurrentVersion';
    W9BaseKey : string = '\Network\Novell\System Config\Install\Client Version';

  var
    NetWareClientVersion, Basekey, gsClientTitle, gsClientBuild, gsClientMajorVersion, gsClientMinorVersion, gsClientACUVersionMajor, gsClientACUVersionMinor, gsClientServicePack : string;

  begin
    Result:='';
    NetWareClientVersion:='';

    if OSVer = 'WIN9X' then
      Basekey:=W9BaseKey
    else
      Basekey:=NTBaseKey;

    gsClientTitle:=ReadAsStringFromRegistry(HKEY_LOCAL_MACHINE,Basekey,'Title');
    gsClientBuild:=ReadAsStringFromRegistry(HKEY_LOCAL_MACHINE,BaseKey,'BuildNumber');

    if OSVer = 'WIN9X' then begin
      gsClientMajorVersion:=ReadAsStringFromRegistry(HKEY_LOCAL_MACHINE,BaseKey,'Major Version');
      gsClientMinorVersion:=ReadAsStringFromRegistry(HKEY_LOCAL_MACHINE,BaseKey,'Minor Version');
    end
    else begin
      gsClientMajorVersion:=ReadAsStringFromRegistry(HKEY_LOCAL_MACHINE,BaseKey,'MajorVersion');
      gsClientMinorVersion:=ReadAsStringFromRegistry(HKEY_LOCAL_MACHINE,BaseKey,'MinorVersion');
    end;

    gsClientACUVersionMajor:= ReadAsStringFromRegistry(HKEY_LOCAL_MACHINE,BaseKey,'Revision');
    gsClientACUVersionMinor:= ReadAsStringFromRegistry(HKEY_LOCAL_MACHINE,BaseKey,'Level');
    gsClientServicePack:= ReadAsStringFromRegistry(HKEY_LOCAL_MACHINE,BaseKey,'Service Pack');

    if gsClientACUVersionMajor = '' then
      gsClientACUVersionMajor:='0';

    if gsClientACUVersionMinor = '' then
      gsClientACUVersionMinor:='0';

    NetWareClientVersion:=gsClientMajorVersion + '.' + gsClientMinorVersion + '.' + gsClientACUVersionMajor + '.' + gsClientACUVersionMinor;

    if gsClientBuild <> '' then
      NetWareClientVersion:=NetWareClientVersion + '.' + gsClientBuild;

     Result:=NetWareClientVersion + ' ' + gsClientServicePack;
  end;


// ---------------------------------------------------------------------------

procedure ShowHelpFile;
   begin
    ShellExecute(Application.handle,nil,PChar(HELP_PAGE),nil,nil,SW_SHOWNORMAL);
  end;

// ---------------------------------------------------------------------------

function GetMACAddress(AdapterNumber : Integer):string;
    var slAdapter                              : TStringList;
        strMACAddress, strAdapterDescription,
        sUpperAdapterDescription               : String;
        intAdaptertoReadFrom                   : integer;
        bFoundOne                              : Boolean;

    begin
        strMACAddress:='';
        intAdaptertoReadFrom:=0;
        if UseAlternateMACAddressRoutine then begin
            AppendToLogFile('GETMACAddress             : Using alternative MAC Address routine');
            slAdapter:=GetAdapterInformationII;
        end
        else If (IsDLLOnSystem('iphlpapi.dll')) and (GetOSVersion(true) <> OS_WIN95) and (GetOSVersion(true) <> OS_WINNT) then begin
            AppendToLogFile('GETMACAddress             : IPHLPAPI.DLL found using GetAdaptersInfo API');
            slAdapter:=GetAdapterInformation;
        end
        else begin
            AppendToLogFile('GETMACAddress             : IPHLPAPI.DLL NOT found (Win95/NT4), using old NetBIOS method');
            strMACAddress:=GetMACAddressLegacy(AdapterNumber);
            if UpperCase(strMACAddress) = UpperCase('Error') then begin
                AppendToLogFile('GETMACAddress             : NetBIOS method returned Error');
                AppendToLogFile('GETMACAddress             : Using alternative MAC Address routine');
                strMACAddress:='';
                slAdapter:=GetAdapterInformationII;
            end;
        end;
        if strMACAddress = '' then begin  //Need to extract Adapter from list of Adapters
           Repeat
              bFoundOne:=True;
              strAdapterDescription:=Trim(ExtractFromGetAdapterInformation(slAdapter,intAdaptertoReadFrom,ADAP_DESCRIPTION));
              sUpperAdapterDescription:= UpperCase(strAdapterDescription);

              //   Change in version 2.8 - 24 August 2006
              //   Did check for these strings WIRELESS WLAN BLUETOOTH PPP VMWARE IPSEC
              //   user must now specify these using the following commandline
              //   /excludeadapter[WIRELESS WLAN BLUETOOTH PPP VMWARE IPSEC]

              if IsStringinStringList(sUpperAdapterDescription,tsNetworkAdapterExclusionList) then begin
                 AppendToLogFile('GETMACAddress             : Adapter ' + InttoStr(intAdaptertoReadFrom) + ' is on the exclusion list, I''ll try the next one (this one is "' + strAdapterDescription + '")');
                 bFoundOne:=False;
              end;

              //  End of new bit

               intAdaptertoReadFrom:=intAdaptertoReadFrom+1;
           Until bFoundOne or (intAdaptertoReadFrom > slAdapter.Count);
           if intAdaptertoReadFrom > slAdapter.Count then begin
              AppendToLogFile('ERROR                     : Could not determine correct network adapter');
              ExitRoutine(5)
           end;
           AppendToLogFile('GETMACAddress             : Reading MAC Address from "' + strAdapterDescription + '"  (Adapter ' + IntToStr(intAdaptertoReadFrom - 1) + ')');
           strMACAddress:=ExtractFromGetAdapterInformation(slAdapter,intAdaptertoReadFrom - 1,ADAP_ADAPTER_ADDRESS);
           slAdapter.Free;
        end;
        AppendToLogFile('GETMACAddress             : Returned ' + strMACAddress);
        Result:=strMACAddress;
    end;

// ---------------------------------------------------------------------------

function IsStringinStringList(s : string; sl: TStrings):Boolean;
    var iI : Integer;
    begin
        Result:=False;
        for iI:= 0 to sl.Count -1 do begin
            if Pos(UpperCase(sl[iI]),UpperCase(s)) <> 0 then
                Result:=True;
        end;
    end;

// ---------------------------------------------------------------------------

function GetIPAddress(intIPAddressIndex : integer):string;
    var strTEMP : string;
    begin
        strTEMP:=LocalIPList.Strings[intIPAddressIndex];
            if strTEMP = '127.0.0.1' then  // Avoid returning localhost
                strTEMP:='';
        result:=strTEMP;
    end;

// ---------------------------------------------------------------------------

function ConvertToExtendedDomainNameFormat(sName : string):String;
    var iI : integer;
        sl : TStringList;
        sR : String;
    begin
        Result:='';
        if Pos('.',sName) <> 0 then begin
            sl:=TStringList.Create;
            DW_Split(sName,'.',TStrings(sl),qoNOBEGINEND or qoNOCRLF or qoPROCESS);
            for iI:= 0 to sl.Count -1 do
                sR:=sR + ',dc=' + sl.Strings[iI];
            Result:=Copy(sR,2,Length(sR));
        end;
    end;

// ---------------------------------------------------------------------------

procedure WritetoLogFile;
  var                           f : textfile;
                             intI : integer;
                       bLogRolled : Boolean;
      strTEMP, strLeft, strPassWd : string;
  begin
    bLogRolled:=False;
    if fileexists(LogFilePathandName) then begin    // Start check on log file to ensure it doesn't get too big
       if GetFilesizeEx(LogFilePathandName) > (MAX_LOG_FILE_SIZE * 1024) then begin  //Convert Meg to Bytes
          DeleteFile(LogFilePathandName);
          bLogRolled:=True;
       end;
    end;
    assignfile(f,LogFilePathandName);
    if fileexists(LogFilePathandName) then
      append(f)
    else
        rewrite(f);
    writeln(f,'');
    writeln(f,'');
    writeln(f,DateTimetoStr(Now) + ' : Version                   : ' + MyVersionNumber);
    writeln(f,DateTimetoStr(Now) + ' : Release Date              : ' + MyVersionDate);
    strTEMP:=OSVer_To_Friendly_Name(GetOSVersion(True));
    if GetOSVersion(False) = OS_WINNT then begin
        bIsOS64Bit:=IsWow64;
        if GetServicePackVersion <> '' then
           strTEMP:=strTEMP + ' (' + GetServicePackVersion + ')';
    end;
    writeln(f,DateTimetoStr(Now) + ' : Operating System          : ' + strTEMP);
    if bIsOS64Bit then
        writeln(f,DateTimetoStr(Now) + ' :                           : 64 bit');
    writeln(f,DateTimetoStr(Now) + ' : Temporary Directory       : ' + TempDirectory);
    if not Directoryexists(TempDirectory) then
    writeln(f,DateTimetoStr(Now) + ' :                           : NOTE: This directory does not exist Log File set to C:\');
    writeln(f,DateTimetoStr(Now) + ' : Log File                  : ' + LogFilePathandName);
    if bLogRolled then
       writeln(f,DateTimetoStr(Now) + '                               Logfile has been rolled as it exceeded ' + InttoStr(MAX_LOG_FILE_SIZE) + ' KByte(s)');
    writeln(f,DateTimetoStr(Now) + ' : User Name                 : ' + UserName);
    writeln(f,DateTimetoStr(Now) + ' : Computer Name (NetBIOS)   : ' + ComputerName);
    writeln(f,DateTimetoStr(Now) + ' : Host Name (IP)            : ' + HostName);

    if LocalAdminRights then
      writeln(f,DateTimetoStr(Now) + ' : Operator Rights           : Administrator')
    else
     writeln(f,DateTimetoStr(Now) + ' : Operator Rights           : User');

    if NovellClientVersion[1] <> '.' then
      writeln(f,DateTimetoStr(Now) + ' : Novell Client Version     : ' + NovellClientVersion);

    if sLanGroupName <> '' then begin
      if bInDomain then begin
        writeln(f,DateTimetoStr(Now) + ' : Member of Domain          : ' + sLanGroupName);
        if (iRetDSGetDCName <> 0) then
            writeln(f,'WARNING! DSGetDCName returned an error code of ' + InttoStr(iRetDSGetDCName));
        if sDomainName <> '' then
            writeln(f,DateTimetoStr(Now) + ' :                           : ' + sDomainName)
        end
      else
        writeln(f,DateTimetoStr(Now) + ' : Member of Workgroup       : ' + sLanGroupName)
    end;

    if sWindowsDrive <> '' then
      writeln(f,DateTimetoStr(Now) + ' : Windows is on Drive       : ' + sWindowsDrive);
    if sWindowsDriveFormat <> '' then
      writeln(f,DateTimetoStr(Now) + ' : Windows Drive Format      : ' + sWindowsDriveFormat);
    writeln(f,DateTimetoStr(Now) + ' : Windows Drive Label       : "' + sWindowsDriveLabel + '"');

    //  Added logic to avoid domain password appearing in the log file
    strTEMP:=strPas(cmdline);

    if Pos(UpperCase(DomainPasswordSwitch),UpperCase(strPas(cmdline))) <> 0 then begin
        intI:=Pos(UpperCase(DomainPasswordSwitch),UpperCase(strPas(cmdline)));
        strLeft:=Copy(strTEMP,1,intI+Length(DomainPasswordSwitch)-1);
        strTemp:=Copy(strTEMP,intI+Length(DomainPasswordSwitch),length(strTEMP)-intI-Length(DomainPasswordSwitch)+1);
        strPassWd:=strTEMP;
        intI:= Pos(' ',strTemp);
        if intI <> 0 then begin
            strPassWd:=copy(strTemp,1,intI-1);
            strTEMP:=copy(strTEMP,intI,length(strTEMP)-intI+1);
        end
        else
            strTEMP:='';
        strTEMP:=strLeft + '##########' + strTEMP;
        writeln(f,DateTimetoStr(Now) + ' : Command Line              : ', strTemp)
    end
    else if Pos(UpperCase(DomainPasswordMaskedSwitch),UpperCase(strPas(cmdline))) <> 0 then begin
        intI:=Pos(UpperCase(DomainPasswordMaskedSwitch),UpperCase(strPas(cmdline)));
        strLeft:=Copy(strTEMP,1,intI+Length(DomainPasswordMaskedSwitch)-1);
        strTemp:=Copy(strTEMP,intI+Length(DomainPasswordMaskedSwitch),length(strTEMP)-intI-Length(DomainPasswordMaskedSwitch)+1);
        strPassWd:=strTEMP;
        intI:= Pos(' ',strTemp);
        if intI <> 0 then begin
            strPassWd:=copy(strTemp,1,intI-1);
            strTEMP:=copy(strTEMP,intI,length(strTEMP)-intI+1);
        end
        else
            strTEMP:='';
        strTEMP:=strLeft + '##########' + strTEMP;
        writeln(f,DateTimetoStr(Now) + ' : Command Line              : ', strTemp)
    end
    else
        writeln(f,DateTimetoStr(Now) + ' : Command Line              : ', strTEMP);
    flush(f);
    closefile(f);
  end;

// ---------------------------------------------------------------------------

procedure MainCodeBlock;
  var
    iRet  : integer;
    sTemp : string;

  begin
    ShowGUI:=True;
    LocalAdminRights:=False;
    OSVer:=GetOSVersion(False);
    OSVerDetailed:=GetOSVersion(True);
    bWindows2000orBetter:=False;
    TempDirectory:=GetTempDirectory;
    strDomainUserID:='';
    strDomainPassword:='';
    AsEnteredComputerName:='';
    blnNetWareClientInstalled:=False;
    bInDomain:=False;
    bIgnoreDomainMemberShip:=False;
    bDeleteExistingComputerAccount:=False;
    bDomainPasswordEncrypted:=False;
    bIsOS64Bit:=False;
    bReplaceSpaceChars:=False;
    bWriteNametoFile:=False;
    sLanGroupName:='';
    sWindowsDrive:='';
    sWindowsDriveFormat:='';
    sWindowsDriveLabel:='';
    sDomainControllerName:='';
    sDomainControllerAddress:='';
    sDomainName:='';
    sDnsForestName:='';
    sClientSiteName:='';
    sUnattendFile:='';
    tsNetworkAdapterExclusionList:=TStringList.Create;
    bWindows2000orBetter:=IsWindows2000orBetter;

    if IsWindows2000orBetter then
        iRet:=GetLanGroupName(sLanGroupName,bInDomain);

    if bInDomain then
        iRetDSGetDCName:=DSGetDCName('', sDomainControllerName, sDomainControllerAddress, sDomainName, sDnsForestName, sClientSiteName);

    if sDomainControllerName <> '' then
        sDomainControllerName:=Copy(sDomainControllerName,3,Length(sDomainControllerName)-2);

    if sDomainName <> '' then
        sDomainName:=ConvertToExtendedDomainNameFormat(sDomainName);

    if DirectoryExists(TempDirectory) then
         LogFilePathandName:=TempDirectory + LogFileName
    else
         LogFilePathandName:='C:\' + LogFileName;

    if (IsAdmin) or (OSVer='WIN9X') then
      LocalAdminRights:=True;

    UserName:=GetCurrentUserName;
    ComputerName:=UpperCase(GetWorkstationName);
    HostName:=GetHostName;

    NovellClientVersion:=ReadNovellClientDetails;
    if NovellClientVersion[1] <> '.' then
       blnNetWareClientInstalled:=True;
    sWindowsDrive:=UpperCase(GetWindowsDrive);
    sWindowsDriveFormat:=UpperCase(GetDriveFormat(sWindowsDrive));
    sWindowsDriveLabel:=GetDriveLabel(sWindowsDrive);

    WritetoLogFile;

    CheckCommandLine;           //  Any thing special to do?

    // -------------------------------------------------------------------------

    if sAlternateLogFileLocation <> '' then begin
      AppendToLogFile('Alternate Log File        : ' + sAlternateLogFileLocation);
      AppendToLogFile('Alternate Log File        : Checking Path');
      if CheckAccessToFile(sAlternateLogFileLocation,sTemp) = True then begin
        AppendToLogFile('Alternate Log File        : Verified');
        AppendToLogFile('Alternate Log File        : Moving logging to new location');
        LogFilePathandName:=sAlternateLogFileLocation;
        WritetoLogFile;
      end
      else
        AppendToLogFile('Alternate Log File        : Alternate path is invalid, ignoring (' + sTemp + ')');
    end;

    // -------------------------------------------------------------------------

    // ----- Start  2.83 -------------------------------------------------------

    if bUnattendFileMode then begin
      AppendToLogFile('Unattend File Mode        : True');
      AppendToLogFile('Unattend File Location    : ' + sUnattendFile);
      if (UpperCase(ExtractFileExt(sUnattendFile)) = '.XML') and (not FileExists(sUnattendFile)) then begin
         AppendToLogFile('ERROR                     : Answer file must exist when using XML file');
         ExitRoutine(17);
      end;
      AppendToLogFile('Unattend File Mode        : Checking Path to  "' + sUnattendFile + '"');
      if CheckAccessToFile(sUnattendFile,sTemp) = True then
        AppendToLogFile('Unattend File Location    : Path Verified')
      else begin
        AppendToLogFile('Unattend File Mode        : Path is invalid (' + sTemp + ')');
        AppendToLogFile('Unattend File Mode        : Process Terminating');
        ExitRoutine(16);
      end
    end;

    // ----- End 2.83 ----------------------------------------------------------

    if bReplaceSpaceChars then                 //2.91
     AppendToLogFile('Auto replace space chars  : Enabled');

      if bAllowLongDNSHostNames then begin
       if IsWindows2000orBetter then
          AppendToLogFile('Allow Long DNS Host Names : True')
       else begin
          AppendToLogFile('Allow Long DNS Host Names : Not supported on this OS, ignoring');
          bAllowLongDNSHostNames:=False;
       end;
    end;

    if TaskHelpStuff then begin
       AppendToLogFile('Operation               : Show Help File');
       ShowGUI:=False;
       ShowHelpFile;            //  Show the help file in the default browser
       Exit;
    end;

    if bTaskMaskPassword then begin
       AppendToLogFile('Operation                 : Mask Password');
       ShowGUI:=False;
       ShowMaskedPassword;
       Exit;
    end;

    if TaskRenameComputerInDomain then begin
       AppendToLogFile('Option                    : Rename Computer in Domain');
       if Not IsWindows2000orBetter then begin
            AppendToLogFile('Rename in Domain        : Operation not supported on this OS');
            ExitRoutine(11);
       end;
       if bInDomain = False then begin
         AppendToLogFile('Rename in Domain        : Not joined to a Domain');
         ExitRoutine(15);
       end;
    end;

    if bTaskSetWorkGroup then begin
      ShowGUI:=False;
      SetWorkGroupName(sWorkGroupName);
    end;

    if TaskNameSync then begin
      AppendToLogFile('Operation                 : Name Sync Mode');
      ShowGUI:=False;
      if LocalAdminRights then //  Can't change the names without administrator rights
        NameSync               //  Set host name the same as the netBIOS name
      else begin
        AppendToLogFile('Name Sync               : Can''t Proceed - No Administrator Rights');
        ExitRoutine(9);
      end;
      Exit;
    end;

    if TaskSilent then begin
      AppendToLogFile('Operation                 : Silent (scripted) Mode');
      ShowGUI:=False;
      if LocalAdminRights then //  Can't change the names without administrator rights
        SilentMode             //  Set the host and netBIOS name as specified on the command line
      else begin
        AppendToLogFile('Silent Mode               : Can''t Proceed - No Administrator Rights');
        ExitRoutine(9);
      end;
      Exit;
    end;

    if TaskPostGhost and not (PostGhostNameMatch) then
        ShowGUI:=False;

    if TaskReadFromDataFile then begin
      AppendToLogFile('Operation                 : Read Name From File');
      ShowGUI:=False;
      if LocalAdminRights then       //  Can't change the names without administrator rights
        ReadNameFromDataFile         //  Get new name from datafile
      else begin
        AppendToLogFile('Read Name From File       : Can''t Proceed - No Administrator Rights');
        ExitRoutine(9);
      end;
      Exit;
    end;

    if bTaskSetMyComputerName then begin
      ShowGUI:=False;
      SetMyComputerName(ComputerName);
    end;
   end;  // - MainCodeBlock

// ---------------------------------------------------------------------------

  function OSVer_To_Friendly_Name(strOSVer : string) : string;
  begin
      if strOSVer = OS_WIN95 then
         Result:='Microsoft Windows 95'
      else if strOSVer = OS_WIN98 then
         Result:='Microsoft Windows 98'
      else if strOSVer = OS_WINME then
         Result:='Microsoft Windows ME'
      else if strOSVer = OS_WINNT then
         Result:='Microsoft Windows NT 4.0'
      else if strOSVer = OS_WIN2K then
         Result:='Microsoft Windows 2000'
      else if strOSVer = OS_WINXP then
         Result:='Microsoft Windows XP'
      else if strOSVer = OS_WIN2K3 then
         Result:='Microsoft Windows 2003'
      else if strOSVer = OS_VISTA then
         Result:='Microsoft Windows Vista'
      else if strOSVer = OS_WIN7 then
         Result:='Microsoft Windows 7'
       else
         Result:=strOSVer;
  end;

// ---------------------------------------------------------------------------

  function OSVersionToTLA:string;
  Var strOSVer : string;
  begin
      strOSVer:=GetOSVersion(True);
      if strOSVer = OS_WIN95 then
         Result:='W95'
      else if strOSVer = OS_WIN98 then
         Result:='W98'
      else if strOSVer = OS_WINME then
         Result:='WME'
      else if strOSVer = OS_WINNT then
         Result:='WNT'
      else if strOSVer = OS_WIN2K then
         Result:='W2K'
      else if strOSVer = OS_WINXP then
         Result:='WXP'
      else if strOSVer = OS_WIN2K3 then
         Result:='WK3'
     else if strOSVer = OS_VISTA then
         Result:='VTA'
     else if strOSVer = OS_WIN7 then
         Result:='MW7'
      else
         Result:='UKN';
  end;

// ---------------------------------------------------------------------------

function Replace(Instring, SearchStr, NewStr : string) : string;
var
  place     : integer;
   s1       : string;

begin
    s1 := Instring;
    Repeat
      Place := pos(SearchStr, s1);
      if place > 0 then begin
        Delete(s1, Place, Length(SearchStr));
        Insert(NewStr, s1, Place);
      end;
    until place = 0;
    result := s1;
end;

// ---------------------------------------------------------------------------

Procedure RunBatchFileandWait(ExecuteFile,ParamString,StartInString : string);
var
  SEInfo: TShellExecuteInfo;
  ExitCode: DWORD;
begin
  FillChar(SEInfo, SizeOf(SEInfo), 0);
  SEInfo.cbSize := SizeOf(TShellExecuteInfo);
  with SEInfo do begin
    fMask := SEE_MASK_NOCLOSEPROCESS;
    Wnd := Application.Handle;
    lpFile := PChar(ExecuteFile);
    // ParamString can contain the application parameters.
    lpParameters := PChar(ParamString);
    // StartInString specifies the name of the working directory.
    // If ommited, the current directory is used.
    lpDirectory := PChar(StartInString);
    nShow := SW_HIDE;
  end;
  if ShellExecuteEx(@SEInfo) then begin
    repeat
      Application.ProcessMessages;
      GetExitCodeProcess(SEInfo.hProcess, ExitCode);
    until (ExitCode <> STILL_ACTIVE) or
	   Application.Terminated;
  end
end;

// ---------------------------------------------------------------------------

function GetDNSServer:string;
var strDNSServers : String;
    sl : TStringList;
begin
    sl:=TStringList.Create;
    AppendToLogFile('Get DNS Server Address    : Checking OS support');
    If (IsDLLOnSystem('iphlpapi.dll')) and (GetOSVersion(true) <> 'WIN95') and (GetOSVersion(true) <> 'WINNT') then begin
        AppendToLogFile('Get DNS Server Address    : IPHLPAPI.DLL found using GetNetworkParams API');
        strDNSServers:=GetDNSUsingGetNetworkParams;
    end
    else begin
        AppendToLogFile('Get DNS Server Address    : IPHLPAPI.DLL NOT found (or Win95/NT4) using alternative DNS address routine');
        strDNSServers:=GetDNSUsingScreenScraping;
    end;
    DW_SPlit(strDNSServers,';',TStrings(sl),qoNOBEGINEND or qoNOCRLF or qoPROCESS);
    AppendToLogFile('Get DNS Server Address    : Returned ' + strDNSServers);
    AppendToLogFile('Get DNS Server Address    : Primary is ' + sl[0]);
    result:=sl[0];
end;

// ---------------------------------------------------------------------------

function CreateTempFileName(aPrefix: string): string;
var
  Buf: array[0..MAX_PATH] of char;
  Temp: array[0..MAX_PATH] of char;
begin
  GetTempPath(MAX_PATH, Buf);
  GetTempFilename(Buf, PChar(aPrefix), 0, Temp);
  Result := String(Temp);
end;

// ---------------------------------------------------------------------------

function GetDNSUsingScreenScraping:string;
var OSVersion, strTempDirectory, strTempFile, strPathtoIPConfig, strCmdLine,
    strPathtoComSpec, strLineofText : string;
    blnGotOne                       : Boolean;
    intPos                          : integer;
    f :  textfile;
begin
    result:='';
    blnGotOne:=False;
    OSVersion:=GetOSVersion(false);
    strTempDirectory:=GetTempDirectory;
    strTempFile:= CreateTempFileName('IPC');

   if FileExists(strTempFile) then
      DeleteFile(strTempFile);

   if OSVersion = 'WIN9X' then begin
      strPathtoIPConfig:=FindPathToFile('WINIPCFG.EXE');
      strCmdLine:= '/ALL /BATCH ' + strTempFile;
      strPathtoComSpec:=FindPathToFile('command.com');
      RunBatchFileandWait(strPathtoIPConfig,strCmdLine,strTempDirectory);
   end
   else begin
     strPathtoIPConfig:=FindPathToFile('IPCONFIG.EXE');
     strCmdLine:= strPathtoIPConfig + ' /ALL > ' + strTempFile;
     strPathtoComSpec:=FindPathToFile('cmd.exe');
     RunBatchFileandWait(strPathtoComSpec,'/c ' + strCmdLine,strTempDirectory);
   end;
   assignfile(f,strTempFile);
   reset(f);
   repeat
       ReadLn(f,strLineofText);
       strLineofText:=Trim(strLineofText);
       intPos:=Pos(':',strLineofText);
       if (Pos(UpperCase('DNS Servers'),UpperCase(strLineofText)) <> 0) and (intPos <> 0) then begin
          blnGotOne:=True;
          result:= result + Trim(Copy(strLineofText,intPos+1,length(strLineofText)-intPos+1)) + ';'
       end
       else if (intPos = 0) and (blnGotOne = True) then begin
          if IsValidIPAddress(strLineofText) = True then
              result:=result + strLineofText + ';';
       end
       else
           blnGotOne:=False;
   until EOF(f);
   close(f);
   if FileExists(strTempFile) then
       DeleteFile(strTempFile);
end;

// ---------------------------------------------------------------------------

function GetDNSUsingGetNetworkParams:string;
   type
         Type_GetNetworkParams = function (FI : PFixedInfo; Var BufLen : Integer) : Integer; StdCall;
   Var
       FI                : PFixedInfo;
       Size              : Integer;
       Res               : Integer;
       intResultCode     : integer;
       DNS               : PIPAddrString;
       _GetNetworkParams :  Type_GetNetworkParams;

Begin
    Result:='';
     Size := 1024;
    GetMem(FI,Size);
    intResultCode:=LoadLibrary(pchar('iphlpapi.dll'));
    @_GetNetworkParams:=GetProcAddress(intResultCode,pchar('GetNetworkParams'));
    Res := _GetNetworkParams(FI,Size);
    FreeLibrary(intResultCode);
    If (Res <> ERROR_SUCCESS) Then Begin
        SetLastError(Res);
        RaiseLastWin32Error;
    End;
    DNS := @FI^.DNSServerList;
    Repeat
      Result:= Result + DNS^.IPAddress + ';';
      DNS := DNS^.Next;
    Until (DNS = nil);
    FreeMem(FI);
End;

// ---------------------------------------------------------------------------

function GetAdapterInformation:TStringList;
  type
    Type_GetAdaptersInfo = function (AI : PIPAdapterInfo; Var BufLen : Integer) : Integer StdCall;
  const
    ERROR_NO_DATA = 232;
  var
  AI,Work            : PIPAdapterInfo;
  Size               : Integer;
  Res                : Integer;
  I                  : Integer;
  intResultCode      : Integer;
  _GetAdaptersInfo   : Type_GetAdaptersInfo;

  function MACToStr(ByteArr : PByte; Len : Integer) : String;
  Begin
    Result := '';
    While (Len > 0) do Begin
      Result := Result+IntToHex(ByteArr^,2); //+'-';
      ByteArr := Pointer(Integer(ByteArr)+SizeOf(Byte));
      Dec(Len);
    End;
    //SetLength(Result,Length(Result)-1); { remove last dash }
  End;

  function GetAddrString(Addr : PIPAddrString) : String;
  Begin
    Result := '';
    While (Addr <> nil) do Begin
      Result := Result+'A: '+Addr^.IPAddress+' M: '+Addr^.IPMask+#13;
      Addr := Addr^.Next;
    End;
  End;

// ---------------------------------------------------------------------------

  function TimeTToDateTimeStr(TimeT : Integer) : String;
  Const UnixDateDelta = 25569; { days between 12/31/1899 and 1/1/1970 }
  Var
    DT  : TDateTime;
    TZ  : TTimeZoneInformation;
    Res : DWord;

  Begin
    If (TimeT = 0) Then Result := ''
    Else Begin
      { Unix TIME_T is secs since 1/1/1970 }
      DT := UnixDateDelta+(TimeT / (24*60*60)); { in UTC }
      { calculate bias }
      Res := GetTimeZoneInformation(TZ);
      If (Res = TIME_ZONE_ID_INVALID) Then RaiseLastWin32Error;
      If (Res = TIME_ZONE_ID_STANDARD) Then Begin
        DT := DT-((TZ.Bias+TZ.StandardBias) / (24*60));
        Result := DateTimeToStr(DT)+' '+WideCharToString(TZ.StandardName);
      End
      Else Begin { daylight saving time }
        DT := DT-((TZ.Bias+TZ.DaylightBias) / (24*60));
        Result := DateTimeToStr(DT)+' '+WideCharToString(TZ.DaylightName);
      End;
    End;
  End;

begin
  Result:= TStringList.Create;
  Size := 5120;
  GetMem(AI,Size);

  intResultCode:=LoadLibrary(pchar('iphlpapi.dll'));
  Try
    @_GetAdaptersInfo:=GetProcAddress(intResultCode,pchar('GetAdaptersInfo'));
    Res := _GetAdaptersInfo(AI,Size);
    FreeLibrary(intResultCode);
  Finally
  End;
  If (Res <> ERROR_SUCCESS) Then Begin
    if res = ERROR_NO_DATA then
      AppendToLogFile('GETMACAddress             : Failed - No adapter information exists for the local computer (' + inttostr(ERROR_NO_DATA) + ')')
    else
      AppendToLogFile('GETMACAddress             : Failed with code ' + inttostr(res));
    ExitRoutine(5);
  End
  Else Begin
    Work := AI;
    I := 1;
    Repeat
      //Adapter Number;ComboIndex;Adapter name;Description;Adapter address; Index; Type; DHCP;
      //Current IP; IP addresses; Gateways; DHCP servers; Has WINS; Primary WINS; Secondary WINS;
      //Lease obtained; Lease expires
      Result.Add(IntToStr(I) + ';' + IntToStr(Work^.ComboIndex) + ';' + Work^.AdapterName + ';' +
               Work^.Description + ';' + MACToStr(@Work^.Address,Work^.AddressLength) + ';'   +
               IntToStr(Work^.Index) + ';' + IntToStr(Work^._Type) + ';' + IntToStr(Work^.DHCPEnabled) +
               ';' + GetAddrString(Work^.CurrentIPAddress) + ';' + GetAddrString(@Work^.IPAddressList) +
               ';' + GetAddrString(@Work^.GatewayList) + ';' + GetAddrString(@Work^.DHCPServer) +
               ';' + IntToStr(Integer(Work^.HaveWINS)) + ';' + GetAddrString(@Work^.PrimaryWINSServer) +
               ';' + GetAddrString(@Work^.SecondaryWINSServer) + ';' + TimeTToDateTimeStr(Work^.LeaseObtained) +
               ';' + TimeTToDateTimeStr(Work^.LeaseExpires));

      Inc(I);
      Work := Work^.Next;
    Until (Work = nil);
    FreeMem(AI);
  end;
end;

// ---------------------------------------------------------------------------

// Split a given string into TStrings with given delimiter character
// Author:       xpcoder
// Version:      1.10
// Date:         5.Mar.2002
// Parameter:
//   aValue => aDelimiter separated string
//   aDelimiter => a character to split the string apart
//   Result => a provided TStrings to store split string,
//             remember to typecast to TStrings(x) if x
//             derivative type of TStrings (e.g. TStringList)
//             Will be created if one is not assigned
//   Flag =>
//        qoPROCESS.....Process quoted string
//        qoNOBEGINEND..Remove heading and trailing quote
//        qoNOCRLF......Remove carriage return and line feed characters
// Limitation:   No unicode support
//               one and only one character delimiter
// Usage:
//   DW_Split( txtInput.Text, ',', TStrings(sl), qoNOBEGINEND or qoNOCRLF or qoPROCESS );

procedure DW_Split(aValue : string; aDelimiter : Char; var Result : TStrings; Flag : Integer = $0001);
var
  i       : integer;
  S, sIn  : string;
  q       : boolean;
  canadd  : boolean;
  l       : Integer;
  c, qc   : char;
  beqc    : char;
begin
  sIn  := trim(aValue);
  l    := Length(sIn);
  if ( l < 1 ) then exit;
  if (Not Assigned(Result)) then Result := TStringList.Create;
  Result.Clear;
  S    := '';
  q    := false;
  qc   := #00;
  beqc := #00;
  i    := 1;
  if ( (pos(sIn[1],#34#39) <> 0) ) then beqc := sIn[1];

  while (i <= l) do begin
    canadd := true;
    c      := sIn[i];
    if ( (c <> aDelimiter) or (q) ) then
      begin
        if ( (Flag and qoPROCESS) = qoPROCESS ) then
          if ( (pos(c,#34#39) <> 0) and (not q)) then
            qc := c;

        if ( (Flag and qoNOBEGINEND) = qoNOBEGINEND ) then
          if ( (c = beqc) and ((i=1) or (i=l)) ) then
            canadd := false;

        if ( (Flag and qoNOCRLF) = qoNOCRLF ) then
          if ( (c = #13) or (c = #10) ) then
            canadd := false;

        if ( canadd ) then
          S := S + c;

        if ( c = qc ) then
          begin
            if ( i < l ) then
              if ( sIn[i+1] = qc ) then
                begin
                  Inc(i,2);
                  continue;
                end;
            q := not q;
          end;
      end
    else
      begin
        Result.Add(S);
        S := '';
      end;
    Inc(i);
  end;
  if S <> '' then Result.Add(S);
end;

// ---------------------------------------------------------------------------

function ExtractFromGetAdapterInformation(tlAdaperInfo : TStringList; intAdapterIndex, intDataIndex : Integer) : string;
    var intI : Integer;
        slSL : TStringList;
    begin
        Result:='';
        for intI:=0 to tlAdaperInfo.Count -1 do begin
            //showmessage(tlAdaperInfo[intI]);
            if intI = intAdapterIndex then begin
                slSL:=TStringList.Create;
                DW_Split(tlAdaperInfo[intAdapterIndex],';',TStrings(slSL),qoNOCRLF);
                Result:=slSL[intDataIndex];
                slSL.Free;
                Exit;
            end;
        end;
    end;

// ---------------------------------------------------------------------------

function GetMACAddressLegacy(AdapterNumber : Integer):string;
type
 TNBLanaResources = (lrAlloc, lrFree);
 PMACAddress = ^TMACAddress;
 TMACAddress = array[0..5] of Byte;

var
  LanaNum: Byte;
  MACAddress: PMACAddress;
  retCode: Byte;
  ResetNCB, StatNCB : PNCB;
  AdapterStatus: PAdapterStatus;

begin
  LanaNum := 0;
  retcode:=0;

  // ------------------ Reset Procedure ------------------
  New(ResetNCB);
  ZeroMemory(ResetNCB, SizeOf(TNCB));
  try
    with ResetNCB^ do begin
      ncb_lana_num := Char(LanaNum);        // Set Lana_Num
      ncb_lsn := Char(lrAlloc);             // Allocation of new resources
      ncb_callname[0] := Char(0);           // Query of max sessions
      ncb_callname[1] := #0;                // Query of max NCBs (default)
      ncb_callname[2] := Char(0);           // Query of max names
      ncb_callname[3] := #0;                // Query of use NAME_NUMBER_1
      ncb_command  := Char(NCBRESET);
      NetBios(ResetNCB);
      if Byte(ncb_cmd_cplt) <> NRC_GOODRET then begin
        Beep;
        ////////////////////AppendToLogFile('MAC Address             : Reset Error! RetCode = $' + IntToHex(RetCode, 2));
      end;
    end;
  finally
    Dispose(ResetNCB);
  end;
  // ----------------------------------------------

  New(MACAddress);
  try
    New(StatNCB);
    ZeroMemory(StatNCB, SizeOf(TNCB));
    StatNCB.ncb_length := SizeOf(TAdapterStatus) +  255 * SizeOf(TNameBuffer);
    GetMem(AdapterStatus, StatNCB.ncb_length);
    try
      with StatNCB^ do begin
        ZeroMemory(MACAddress, SizeOf(TMACAddress));
        ncb_buffer := PChar(AdapterStatus);
        ncb_callname := '*              ' + #0;
        ncb_lana_num := Char(LanaNum);
        ncb_command  := Char(NCBASTAT);
        NetBios(StatNCB);
        retcode := Byte(ncb_cmd_cplt);
        if retcode = NRC_GOODRET then
          MoveMemory(MACAddress, AdapterStatus, SizeOf(TMACAddress));
      end;
    finally
      FreeMem(AdapterStatus);
      Dispose(StatNCB);
    end;

    if RetCode = NRC_GOODRET then begin
      result:= Format('%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x',
      [MACAddress[0], MACAddress[1], MACAddress[2], MACAddress[3], MACAddress[4], MACAddress[5]]);
    end
    else begin
      Beep;
      result:='Error';
    end;
  finally
    Dispose(MACAddress);
  end;
end;

// ---------------------------------------------------------------------------

function WMIByShellHack(sWMIClass, sWMIOption:string):String;
  var
   sTempFile, sPathtoScriptEngine, sPathtoComSpec, sTempDirectory, sCMDFile, sLineofText : string;
   f : textfile;
begin
  result:='';
  sTempFile:= CreateTempFileName('WMI');
  sPathtoScriptEngine:=FindPathToFile('CSCRIPT.EXE');
  sPathtoComSpec:=FindPathToFile('cmd.exe');
  sTempDirectory:=GetTempDirectory;
  sCMDFile:=IncludeTrailingBackSlash(sTempDirectory) + '~tempgetmanf~.vbs';
  if FileExists(sTempFile) then
    DeleteFile(sTempFile);
  if FileExists(sCMDFile) then
    DeleteFile(sCMDFile);
  assignfile(f,sCMDFile);
  rewrite(f);
  writeln(f,'Dim objColl, obj, sResult, f, fso');
  writeln(f,'Set fso = CreateObject("Scripting.FileSystemObject")');
  writeln(f,'sResult=""');
  writeln(f,'Set objColl = GetObject("winmgmts:").ExecQuery("SELECT * FROM ' + sWMIClass + '")');
  writeln(f,'For each obj in objColl');
  writeln(f,'  sResult = obj.' + sWMIOption);
  writeln(f,'Next');
  writeln(f,'Set f = fso.OpenTextFile("' + sTempFile + '", 2, True)');
  writeln(f,'f.Writeline sResult');
  writeln(f,'f.Close');
  flush(f);
  closefile(f);
  RunBatchFileandWait(sPathtoComSpec,'/c ' + sPathtoScriptEngine + ' ' + sCMDFile,sTempDirectory);
  if FileExists(sTempFile) Then Begin
     assignfile(f,sTempFile);
     reset(f);
     ReadLn(f,sLineofText);
     closefile(f);
     sLineofText:=Trim(sLineofText);
     sLineofText:=Replace(sLineofText,' ','');
     result:=sLineofText;
     DeleteFile(sTempFile);
  End;
  if FileExists(sCMDFile) then
    DeleteFile(sCMDFile);
end;

// ---------------------------------------------------------------------------

function WMIByShellHackCollectionofCollection(sWMIClass, sWMIOption:string):String;
  var
   sTempFile, sPathtoScriptEngine, sPathtoComSpec, sTempDirectory, sCMDFile, sLineofText : string;
   f : textfile;
begin
  result:='';
  sTempFile:= CreateTempFileName('WMI');
  sPathtoScriptEngine:=FindPathToFile('CSCRIPT.EXE');
  sPathtoComSpec:=FindPathToFile('cmd.exe');
  sTempDirectory:=GetTempDirectory;
  sCMDFile:=IncludeTrailingBackSlash(sTempDirectory) + '~tempgetmanf~.vbs';
  if FileExists(sTempFile) then
    DeleteFile(sTempFile);
  if FileExists(sCMDFile) then
    DeleteFile(sCMDFile);
  assignfile(f,sCMDFile);
  rewrite(f);
  writeln(f,'Dim objColl, o, obj, sResult, f, fso');
  writeln(f,'Set fso = CreateObject("Scripting.FileSystemObject")');
  writeln(f,'sResult=""');
  writeln(f,'Set objColl = GetObject("winmgmts:").ExecQuery("SELECT * FROM ' + sWMIClass + '")');
  writeln(f,'For each obj in objColl');
  writeln(f,'  For each o in obj.' + sWMIOption);
  writeln(f,'    sResult = o');
  writeln(f,'  Next');
  writeln(f,'Next');
  writeln(f,'Set f = fso.OpenTextFile("' + sTempFile + '", 2, True)');
  writeln(f,'f.Writeline sResult');
  writeln(f,'f.Close');
  flush(f);
  closefile(f);
  RunBatchFileandWait(sPathtoComSpec,'/c ' + sPathtoScriptEngine + ' ' + sCMDFile,sTempDirectory);
  if FileExists(sTempFile) Then Begin
     assignfile(f,sTempFile);
     reset(f);
     ReadLn(f,sLineofText);
     closefile(f);
     sLineofText:=Trim(sLineofText);
     sLineofText:=Replace(sLineofText,' ','');
     result:=sLineofText;
     DeleteFile(sTempFile);
  End;
  if FileExists(sCMDFile) then
    DeleteFile(sCMDFile);
end;

// ---------------------------------------------------------------------------

function ADSIFindComputerByShellHack(sComputerName,sDomainController,sDomainName,strUserID,strPassword:string):String;
  var
   sTempFile, sPathtoScriptEngine, sPathtoComSpec, sTempDirectory, sCMDFile, sLineofText : string;
   f : textfile;
begin
  result:='';
  sTempFile:= CreateTempFileName('ADSI');
  sPathtoScriptEngine:=FindPathToFile('CSCRIPT.EXE');
  if sPathtoScriptEngine = '' then
     AppendToLogFile('Could not find cscript.exe - unable to run ADSI hack')
  else begin
	  sPathtoComSpec:=FindPathToFile('cmd.exe');
	  sTempDirectory:=GetTempDirectory;
	  sCMDFile:=IncludeTrailingBackSlash(sTempDirectory) + '~tempadsi~.vbs';
	  if FileExists(sTempFile) then
	    DeleteFile(sTempFile);
	  if FileExists(sCMDFile) then
	    DeleteFile(sCMDFile);
	  assignfile(f,sCMDFile);
	  rewrite(f);
	  writeln(f,'Dim objColl, obj, sResult, f, fso, oConnection, oCommand, oRoot, sDNSDomain, sQuery, sFilter, oResults');
	  writeln(f,'Set fso = CreateObject("Scripting.FileSystemObject")');
	  writeln(f,'sResult=""');
	  writeln(f,'On Error Resume Next');
	  writeln(f,'Set oConnection = CreateObject("ADODB.Connection")');
	  writeln(f,'Set oCommand = CreateObject("ADODB.Command")');
	  writeln(f,'oConnection.Provider = "ADsDSOOBject"');
          writeln(f,'oConnection.Properties("User ID")="' + strUserID + '"');
          writeln(f,'oConnection.Properties("Password")="' + strPassword + '"');
	  writeln(f,'oConnection.Open "Active Directory Provider"');
	  writeln(f,'Set oCommand.ActiveConnection = oConnection');
	  writeln(f,'sFilter = "(&(ObjectClass=user)(ObjectCategory=computer)(Name=' + sComputerName + '))"');
	  writeln(f,'sQuery = "<LDAP://' + sDomainController + '/' + sDomainName + '>;" & sFilter & ";adsPath;subtree"');
	  writeln(f,'oCommand.CommandText = sQuery');
	  writeln(f,'oCommand.Properties("Page Size") = 100');
	  writeln(f,'oCommand.Properties("Timeout") = 30');
	  writeln(f,'oCommand.Properties("Cache Results") = False');
	  writeln(f,'Set oResults = oCommand.Execute');
	  writeln(f,'Do Until oResults.EOF');
	  writeln(f,'    if oResults.Fields("adsPath") <> "" then');
	  writeln(f,'        sResult = oResults.Fields("adsPath")');
	  writeln(f,'    End if');
	  writeln(f,'    oResults.MoveNext');
	  writeln(f,'Loop');
	  writeln(f,'Set f = fso.OpenTextFile("' + sTempFile + '", 2, True)');
	  writeln(f,'f.Writeline sResult');
	  writeln(f,'f.Close');
	  flush(f);
	  closefile(f);
	  RunBatchFileandWait(sPathtoComSpec,'/c ' + sPathtoScriptEngine + ' ' + sCMDFile,sTempDirectory);
	  if FileExists(sTempFile) Then Begin
	     assignfile(f,sTempFile);
	     reset(f);
	     ReadLn(f,sLineofText);
	     closefile(f);
	     sLineofText:=Trim(sLineofText);
	     //sLineofText:=Replace(sLineofText,' ','');
	     result:=sLineofText;
	     DeleteFile(sTempFile);
	  End;
	  if FileExists(sCMDFile) then
	    DeleteFile(sCMDFile);
  end;
end;

// ---------------------------------------------------------------------------

function ADSIDeleteComputerByShellHack(sComputerAdsPath,strUserID,strPassword:string):String;
  var
   sTempFile, sPathtoScriptEngine, sPathtoComSpec, sTempDirectory, sCMDFile, sLineofText : string;
   f : textfile;
begin
  result:='-1';
  sTempFile:= CreateTempFileName('ADSI');
  sPathtoScriptEngine:=FindPathToFile('CSCRIPT.EXE');
  if sPathtoScriptEngine = '' then
      AppendToLogFile('Could not find cscript.exe - unable to run ADSI hack')
  else begin
	  sPathtoComSpec:=FindPathToFile('cmd.exe');
	  sTempDirectory:=GetTempDirectory;
	  sCMDFile:=IncludeTrailingBackSlash(sTempDirectory) + '~tempadsi~.vbs';
	  if FileExists(sTempFile) then
	    DeleteFile(sTempFile);
	  if FileExists(sCMDFile) then
	    DeleteFile(sCMDFile);
	  assignfile(f,sCMDFile);
	  rewrite(f);
          writeln(f,'Option Explicit');
          writeln(f,'Const               USER_ID = "' + strUserID + '"');
          writeln(f,'Const              PASSWORD = "' + strPassword + '"');
          writeln(f,'Const LDAP_PATH_TO_COMPUTER = "' + sComputerAdsPath + '"');
          writeln(f,'Dim oOU, oObject, sCN, sResult, oNamespaceLDAP, iResult');
          writeln(f,'iResult = -1');
          writeln(f,'On Error Resume Next');
          writeln(f,'Err.Clear');
          writeln(f,'Set oNamespaceLDAP = GetObject("LDAP:")');
          writeln(f,'If Err.Number <> 0 Then : ReportResult("GetObject(""LDAP:"") 0x" & Hex(Err.Number))');
          writeln(f,'Set oObject = oNamespaceLDAP.OpenDSObject(LDAP_PATH_TO_COMPUTER,USER_ID,PASSWORD,0)');
          writeln(f,'If Err.Number <> 0 Then : ReportResult("OpenDSObject (object) 0x" & Hex(Err.Number) & " " & Err.Description)');
          writeln(f,'sCN = oObject.CN');
          writeln(f,'sCN = Replace(sCN,",","\,")');
          writeln(f,'Set oOU = oNamespaceLDAP.OpenDSObject(oObject.Parent,USER_ID,PASSWORD,0)');
          writeln(f,'If Err.Number <> 0 Then : ReportResult("OpenDSObject (parent) 0x" & Hex(Err.Number) & " " & Err.Description)');
          writeln(f,'Set oObject = Nothing');
          writeln(f,'Err.Clear');
          writeln(f,'oOU.Delete "Computer", "cn=" & sCN');
          writeln(f,'If Err.Number <> 0 Then : ReportResult("Delete 0x" & Hex(Err.Number) & " " & Err.Description)');
          writeln(f,'iResult = Err.Number');
          writeln(f,'Set oOU = Nothing');
          writeln(f,'On Error Goto 0');
          writeln(f,'ReportResult(iResult)');
          writeln(f);
          writeln(f,'Function ReportResult(str)');
          writeln(f,'    Dim f, fso');
	  writeln(f,'    Set fso = CreateObject("Scripting.FileSystemObject")');
          writeln(f,'    Set f = fso.OpenTextFile("' + sTempFile + '", 2, True)');
          writeln(f,'    f.Writeline str');
          writeln(f,'    f.Close');
          writeln(f,'End Function');
	  flush(f);
	  closefile(f);
	  RunBatchFileandWait(sPathtoComSpec,'/c ' + sPathtoScriptEngine + ' ' + sCMDFile,sTempDirectory);
	  if FileExists(sTempFile) Then Begin
	     assignfile(f,sTempFile);
	     reset(f);
	     ReadLn(f,sLineofText);
	     closefile(f);
	     DeleteFile(sTempFile);
	     result:=Trim(sLineofText);
	  End;
	  if FileExists(sCMDFile) then
	    DeleteFile(sCMDFile);
  end;
end;

// ---------------------------------------------------------------------------

function GetAdapterInformationII:TStringList;
var OSVersion, strCmdLine, strTempFile, strPathtoIPConfig, strTempDirectory, strLineofText, strPathtoComSpec,
    strMACAddress, strDescription, strDCHPEnabled, strIPAddress, strSubNetMask, strDefaultGateway, strDHCPServer, strTEMP,
    strDHCPLeaseObtained, strDHCPLeaseExpires, strPrimaryWINSServer, strSecondaryWINSServer, strPrimaryDNSServer,
    strSecondaryDNSServer  : string;
    f :  textfile;
    intPos : integer;
begin
   Result:= TStringList.Create;
   OSVersion:=GetOSVersion(false);
   strTempDirectory:=GetTempDirectory;
   strTempFile:= CreateTempFileName('IPC');

   if FileExists(strTempFile) then
      DeleteFile(strTempFile);

   if OSVersion = 'WIN9X' then begin
      strPathtoIPConfig:=FindPathToFile('WINIPCFG.EXE');
      strCmdLine:= '/ALL /BATCH ' + strTempFile;
      strPathtoComSpec:=FindPathToFile('command.com');
      RunBatchFileandWait(strPathtoIPConfig,strCmdLine,strTempDirectory);
   end
   else begin
     strPathtoIPConfig:=FindPathToFile('IPCONFIG.EXE');
     strCmdLine:= strPathtoIPConfig + ' /ALL > ' + strTempFile;
     strPathtoComSpec:=FindPathToFile('cmd.exe');
     RunBatchFileandWait(strPathtoComSpec,'/c ' + strCmdLine,strTempDirectory);
   end;
   //if Not FileExists(strTempFile) then
      //Post Error Here
   assignfile(f,strTempFile);
   reset(f);
   strDescription:='';
   strMACAddress:='';
   strDCHPEnabled:='';
   strIPAddress:='';
   strSubNetMask:='';
   strDefaultGateway:='';
   strDHCPServer:='';
   strDHCPLeaseObtained:='';
   strDHCPLeaseExpires:='';
   strPrimaryWINSServer:='';
   strSecondaryWINSServer:='';
   strPrimaryDNSServer:='';
   strSecondaryDNSServer:='';
   repeat
       ReadLn(f,strLineofText);
       strLineofText:=Trim(strLineofText);
       intPos:=Pos(':',strLineofText);
       if intPos <> 0 then
           strTEMP:=Trim(Copy(strLineofText,intPos+1,length(strLineofText)-intPos+1));
       if (Pos(UpperCase('Description'),UpperCase(strLineofText)) <> 0) then begin
          if strDescription <> '' then begin
             Result.Add('Adapter Number;ComboIndex;AdapterName;' + strDescription + ';' + strMACAddress + ';Index;Type;' + strDCHPEnabled + ';CurrentIPAddress;' + strIPAddress + ';' + strSubNetMask + ';' + strDefaultGateway + ';' + strDHCPServer + ';HaveWINS' + ';' + strPrimaryWINSServer + ';' + strSecondaryWINSServer + ';' + strDHCPLeaseObtained + ';' + strDHCPLeaseExpires + ';' + strPrimaryDNSServer + ';' + strSecondaryDNSServer);
             strMACAddress:='';
             strDescription:='';
             strDCHPEnabled:='';
             strIPAddress:='';
             strSubNetMask:='';
             strDefaultGateway:='';
             strDHCPServer:='';
             strDHCPLeaseObtained:='';
             strDHCPLeaseExpires:='';
             strPrimaryWINSServer:='';
             strSecondaryWINSServer:='';
             strPrimaryDNSServer:='';
             strSecondaryDNSServer:='';
          end;
          strDescription:=strTEMP;
       end
       else if (Pos(UpperCase('Physical Address'),UpperCase(strLineofText)) <> 0) then
           strMACAddress:=Replace(strTEMP,'-','')
       else if (Pos(UpperCase('Dhcp Enabled'),UpperCase(strLineofText)) <> 0) then
           strDCHPEnabled:=strTEMP
       else if (Pos(UpperCase('IP Address'),UpperCase(strLineofText)) <> 0) then
           strIPAddress:=strTEMP
       else if (Pos(UpperCase('Subnet Mask'),UpperCase(strLineofText)) <> 0) then
           strSubNetMask:=strTEMP
       else if (Pos(UpperCase('Default Gateway'),UpperCase(strLineofText)) <> 0) then
           strDefaultGateway:=strTEMP
       else if (Pos(UpperCase('DHCP Server'),UpperCase(strLineofText)) <> 0) then
           strDHCPServer:=strTEMP
       else if (Pos(UpperCase('Lease Obtained'),UpperCase(strLineofText)) <> 0) then
           strDHCPLeaseObtained:=strTEMP
       else if (Pos(UpperCase('Lease Expires'),UpperCase(strLineofText)) <> 0) then
           strDHCPLeaseExpires:=strTEMP
       else if (Pos(UpperCase('Primary WINS Server'),UpperCase(strLineofText)) <> 0) then
           strPrimaryWINSServer:=strTEMP
       else if (Pos(UpperCase('Secondary WINS Server'),UpperCase(strLineofText)) <> 0) then
           strSecondaryWINSServer:=strTEMP
       else if (Pos(UpperCase('DNS Servers'),UpperCase(strLineofText)) <> 0) then
           strPrimaryDNSServer:=strTEMP
   until EOF(f);
   if strDescription <> '' then begin
      Result.Add('Adapter Number;ComboIndex;AdapterName;' + strDescription + ';' + strMACAddress + ';Index;Type;' + strDCHPEnabled + ';CurrentIPAddress;' + strIPAddress + ';' + strSubNetMask + ';' + strDefaultGateway + ';' + strDHCPServer + ';HaveWINS' + ';' + strPrimaryWINSServer + ';' + strSecondaryWINSServer + ';' + strDHCPLeaseObtained + ';' + strDHCPLeaseExpires + ';' + strPrimaryDNSServer + ';' + strSecondaryDNSServer);
   end;
   closefile(f);
   if FileExists(strTempFile) then
      DeleteFile(strTempFile);
end;

// ---------------------------------------------------------------------------

function ReverseDNSLookup(strIPAddress, strDNSServer:string; intPTRTimeOut : integer; out strResult : string):Boolean;
var frmPTRQuery : TForm;
    Inst        : TInstance;
begin
    Inst := TInstance.Create;
    Inst.intPTRResult:=-99;
    frmPTRQuery:=TForm.Create(Application); // Create frmPTRQuery
    Inst.Timer1:=TTimer.Create(frmPTRQuery);
    Inst.DNSQuery1:=TDNSQuery.Create(frmPTRQuery);
    Inst.Timer1.Enabled:=False;
    Inst.Timer1.Interval:=intPTRTimeOut;
    Inst.Timer1.OnTimer:=Inst.PTRQueryOnTimeOut;
    Inst.DnsQuery1.OnRequestDone:=Inst.DnsQuery1RequestDone;
    Inst.DnsQuery1.Addr:=strDNSServer; //DNS Server
    try
        Inst.DnsQuery1.PTRLookup(strIPAddress);
    except
        Inst.intPTRResult:=-1;
    end;
    Inst.Timer1.Enabled:=True;
    repeat
          Application.ProcessMessages;
    until Inst.intPTRResult <> -99;
    Inst.Timer1.Enabled:=False;
    Case Inst.intPTRResult of
       -1 :  begin
                 result:=False;
                 strResult:='Reverse Lookup Failed. (IP Transport Failure)';
             end;
        0 :  begin
                 result:=True;
                 strResult:=Inst.DnsQuery1.Hostname[0];
             end;
        1 :  begin
                 result:=False;
                 strResult:='Reverse Lookup Failed. (DNS TimeOut)';
             end;
        else begin
                 result:=False;
                 strResult:='Reverse Lookup Failed. (error = ' + inttostr(Inst.intPTRResult) + ')';
             end;

    end; //Case
    Inst.DNSQuery1.Free;
    Inst.Timer1.Free;
    Inst.Free;
    frmPTRQuery.Free;
end;

// ---------------------------------------------------------------------------

procedure TInstance.PTRQueryOnTimeOut(Sender: Tobject);
begin
   intPTRResult:=1; //Time Out
end;

// ---------------------------------------------------------------------------

procedure TInstance.DnsQuery1RequestDone(Sender: TObject; Error: Word);
begin
   Timer1.Enabled:= false;
   intPTRResult:=Error;
end;

/// ---------------------------------------------------------------------------

function MagicChango(strInput,sID,strReplacementString : string):string;
Var intI, iTruncateSide                       : integer;
    strInputModified, sScratch, sNewString    : string;
begin
    sScratch:=strInput;
    Repeat
      sNewString:=strReplacementString;
      if ReplacementStringSizeSpecified(sID,sScratch,intI,iTruncateSide,strInputModified) then begin
          if iTruncateSide = TRIM_LEFT then
              sNewString:=Copy(strReplacementString,1,intI)                                               // Copy from Left
          else if iTruncateSide = TRIM_WHOLE_WORD_LEFT then begin                                         // Copy whole word from Left
              if Pos(' ',strReplacementString) <> 0 then
                sNewString:=Trim(Left(strReplacementString,Pos(' ',strReplacementString)))
          end
          else if iTruncateSide = TRIM_WHOLE_WORD_RIGHT then begin                                        // Copy whole word from Right
              if Pos(' ',strReplacementString) <> 0 then
                sNewString:= copy(strReplacementString,LastPos(' ',strReplacementString),Length(strReplacementString) - LastPos(' ',strReplacementString)+1)
          end
          else
              sNewString:=Copy(strReplacementString,length(strReplacementString) - intI + 1,intI + 1);    // Copy from Right
          sScratch:=strInputModified;
      end;
      sScratch:=StringReplace(sScratch,sID,sNewString,[rfIgnoreCase]); //rfReplaceAll
    Until PosX(sID,sScratch) = 0;
    Result:=sScratch;
end;

// ---------------------------------------------------------------------------

function ReplacementStringSizeSpecified(strMarker, strInput : string; out intStringSize, intTruncateFrom : integer; out strOutput : string) : boolean;
var intI, intJ : integer;
    strScratch : string;
begin
    ReplacementStringSizeSpecified:=False;
    intI:=pos(UpperCase(strMarker),UpperCase(strInput)) + Length(strMarker);
    intTruncateFrom:=TRIM_LEFT;
    if intI + 1 < length(strInput) then begin
        if strInput[IntI] = '[' then begin
            strScratch:=Copy(strInput,intI,Length(strInput) - intI + 1);
            intJ:=pos(']',strScratch);
            if intJ <> 0 then begin
                strScratch:=Copy(strScratch,2,intJ - 2);
                strScratch:=Trim(strScratch);
                if Copy(strScratch,1,1) = '+' then
                   strScratch:=Copy(strScratch,2,Length(strScratch) - 1);
                if Copy(strScratch,Length(strScratch),1) = '+' then begin
                   intTruncateFrom:=TRIM_RIGHT;
                   strScratch:=Copy(strScratch,1,Length(strScratch) - 1);
                end;
                Delete(strInput,intI,intJ);
                intStringSize:=MyStrtoInt(strScratch,True);
                strOutput:=strInput;
                if length(strScratch) > 0 then begin
                  if UpperCase(strScratch) = 'L' then
                     intTruncateFrom:=TRIM_WHOLE_WORD_LEFT
                  else if UpperCase(strScratch) = 'R' then
                    intTruncateFrom:=TRIM_WHOLE_WORD_RIGHT;
                end;
                ReplacementStringSizeSpecified:=True;
            end;
        end;
    end;
end;

// ---------------------------------------------------------------------------

function PadIPAddress(strIPAddress : string) : string;
var IPOctet     : array[1..4] of string;
    strPad      : string;
    intI, intJ  : integer;
begin
    //Add test for valid IP address here!
    intI:=pos('.',strIPAddress);
    IPOctet[1]:=copy(strIPAddress,1,intI-1);
    delete(strIPAddress,1,intI);
    intI:=pos('.',strIPAddress);
    IPOctet[2]:=copy(strIPAddress,1,intI-1);
    delete(strIPAddress,1,intI);
    intI:=pos('.',strIPAddress);
    IPOctet[3]:=copy(strIPAddress,1,intI-1);
    delete(strIPAddress,1,intI);
    IPOctet[4]:=strIPAddress;
    for intI:=1 to 4 do begin
        strPad:='';
        for intJ:=Length(IPOctet[intI]) + 1 to 3 do
            strPad:=strPad + '0';
        IPOctet[intI]:=strPad + IPOctet[intI];
    end;
    result:=IPOctet[1] + '.' + IPOctet[2] + '.' + IPOctet[3] + '.' + IPOctet[4];
end;

// ---------------------------------------------------------------------------

function MyStrtoInt(x : string; blnStrict : boolean) : integer;
var i       : integer;
    badchar : boolean;
begin
  badchar:=false;
  for i:=1 to length(x) do begin
    if not (x[i] in ['0'..'9']) then begin
       badchar:=true;
       Break;
    end;
  end;
  if badchar and Not blnStrict then
    x:=copy(x,1,i-1)
  else if badchar and blnStrict then
    x:='0'
  else if length(x) = 0 then
    x:='0';
  result:=strtoint(x);
end;

// ---------------------------------------------------------------------------


Procedure SetWorkGroupName(sWorkGroupName : string);
  var
    lResult : LongInt;
  begin
    AppendToLogFile('Option                    : Set Workgroup Name');
    if Not IsWindows2000orBetter then
      AppendToLogFile('Set WorkGroup Name        : Operation not supported on this OS (Windows 2000 or better required)')
    else if (bInDomain = False) AND (UpperCase(sLanGroupName) =UpperCase(sWorkGroupName)) then
      AppendToLogFile('Set WorkGroup Name        : Workgroup and is already set to "' + sWorkGroupName + '"')
    else if Not LocalAdminRights then
      AppendToLogFile('Set WorkGroup Name        : Can''t Proceed - No Administrator Rights')
    else begin
      AppendToLogFile('Set WorkGroup Name        : Setting Workgroup to "' + sWorkGroupName + '"');
      lResult:= NetJoinDomainAPI(sWorkGroupName);
      if lResult = 0 then
        AppendToLogFile('Set WorkGroup Name        : Workgroup Name set successfully')
      else begin
        AppendToLogFile('Set WorkGroup Name        : Call to NetJoinDomainAPI failed with result code of ' + inttostr(lResult));
        AppendToLogFile('Set WorkGroup Name        : Check error code against reference at http://msdn.microsoft.com/library/default.asp?url=/library/en-us/netmgmt/netmgmt/netjoindomain.asp');
      end;
    end;
  end;

// ------------------------ ---------------------------------------------------

function NetJoinDomainAPI(sNewWorkgroupName:string): LongInt;
  type
    Type_NetJoinDomain = function(lpServer, lpDomain, lpAccountOU, lpAccount,  lpPassword: LPCWSTR; fJoinOptions: DWORD): integer; stdcall;
  var
    lngResultCode                               : LongInt;
    iResultCode                                 : Integer;
    _NetJoinDomain                              : Type_NetJoinDomain;
    lpNewWorkgroupName                          : LPCWSTR;
  begin
    GetMem(lpNewWorkgroupName,Length(sNewWorkgroupName)*2+1);
    stringtowidechar(sNewWorkgroupName,lpNewWorkgroupName,Length(sNewWorkgroupName)*2+1);
    try
      iResultCode:=LoadLibrary(pchar('NetAPI32.dll'));
      @_NetJoinDomain:=GetProcAddress(iResultCode,pchar('NetJoinDomain'));
      lngResultCode:= _NetJoinDomain(nil,lpNewWorkgroupName,nil,nil,nil,0);
      FreeLibrary(iResultCode);
    finally
    end;
    NetJoinDomainAPI:=lngResultCode;
   end;

// ---------------------------------------------------------------------------

function IsWindows2000orBetter:Boolean;
  var
    VersionInfo: TOSVersionInfo;
  begin
    result:=False;
    VersionInfo.dwOSVersionInfoSize := Sizeof(TOSVersionInfo);
    GetVersionEx(VersionInfo);
    if (VersionInfo.dwPlatformID = VER_PLATFORM_WIN32_NT) and (VersionInfo.dwMajorVersion >= 5) then
      result:=True;
  end;

// ---------------------------------------------------------------------------

function FreeBuffer(lpBuffer : Pointer):integer;
  Type
    Type_NetApiBufferFree = function(Buffer: Pointer): integer; stdcall;
  var
     iResultCode       : integer;
     lngResultCode     : LongInt;
     _NetApiBufferFree : Type_NetApiBufferFree;
  begin
    Try
      iResultCode:=LoadLibrary(pchar('NetAPI32.dll'));
      @_NetApiBufferFree:=GetProcAddress(iResultCode,pchar('NetApiBufferFree'));
      lngResultCode:= _NetApiBufferFree(lpBuffer);
      FreeLibrary(iResultCode);
      Result:=lngResultCode;
  Finally
  end;
end;

// ---------------------------------------------------------------------------

function GetLanGroupName(out sLanGroupName : string; out bInDomain : Boolean):integer;
  type
    Type_NetGetJoinInformation = function(lpServer: LPCWSTR; lpNameBuffer: LPWSTR; BufferType: pointer): longint; stdcall;
  var
    b                      : longint;
    d                      : LPWSTR;
    iResultCode            : integer;
    lngResultCode          : LongInt;
    _NetGetJoinInformation : Type_NetGetJoinInformation;
  begin
    bInDomain:=False;
    try
      iResultCode:=LoadLibrary(pchar('NetAPI32.dll'));
      @_NetGetJoinInformation:=GetProcAddress(iResultCode,pchar('NetGetJoinInformation'));
      lngResultCode:= _NetGetJoinInformation(nil, @d,  @b);
      FreeLibrary(iResultCode);
      sLanGroupName:=(WideCharToString(d));
      if b = 3 then
        bInDomain:=True;
      FreeBuffer(d);
      Result:= lngResultCode;
    finally
    end;
  end;

// ---------------------------------------------------------------------------

function GetDriveFormat(sDrive : string):string;
var
  pFSBuf, pVolName        : PChar;
  nVNameSer               : PDWORD;
  FSSysFlags, maxCmpLen   : DWord;

begin
  result:='';
  GetMem(pVolName, MAX_PATH);
  GetMem(pFSBuf, MAX_PATH);
  GetMem(nVNameSer, MAX_PATH);
  Try
    GetVolumeInformation(PChar(Copy(sDrive,1,1) + ':\'), pVolName, MAX_PATH, nVNameSer,maxCmpLen, FSSysFlags, pFSBuf, MAX_PATH);
    result:=StrPas(pFSBuf);
  Finally
  End;
  FreeMem(pVolName, MAX_PATH);
  FreeMem(pFSBuf, MAX_PATH);
  FreeMem(nVNameSer, MAX_PATH);
end;

// ---------------------------------------------------------------------------

function GetDriveLabel(sDrive : string):string;
var
  pFSBuf, pVolName        : PChar;
  nVNameSer               : PDWORD;
  FSSysFlags, maxCmpLen   : DWord;

begin
  result:='';
  GetMem(pVolName, MAX_PATH);
  GetMem(pFSBuf, MAX_PATH);
  GetMem(nVNameSer, MAX_PATH);
  Try
    GetVolumeInformation(PChar(Copy(sDrive,1,1) + ':\'), pVolName, MAX_PATH, nVNameSer,maxCmpLen, FSSysFlags, pFSBuf, MAX_PATH);
    result:=StrPas(pVolName);
  Finally
  End;
  FreeMem(pVolName, MAX_PATH);
  FreeMem(pFSBuf, MAX_PATH);
  FreeMem(nVNameSer, MAX_PATH);
end;

// ---------------------------------------------------------------------------

end.
