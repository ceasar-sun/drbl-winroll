program WSName;
                                    
uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  uWSName in 'uWSName.pas';

{ To install 'WbemScripting_TLB.dcu' install the type library
 <Windows System32>\wbem\wbemdisp.tlb type library using the "Project|Import type library" menu option.      }


{$R *.RES}

begin                      
  Application.Initialize;
  MainCodeBlock;                  { Call the Main block of code in uWSName}

  if NOT ShowGUI then
    exit;

  Application.Initialize;
  Application.Title := 'Set WorkStation Name';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.




