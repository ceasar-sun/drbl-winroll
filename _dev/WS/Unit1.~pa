unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ShellApi, uWSName;

type
  TForm1 = class(TForm)
    butSetName: TButton;
    Edit1: TEdit;
    butExit: TButton;
    Label1: TLabel;
    lbleMailAddress: TLabel;
    lblVersionDate: TLabel;
    lblVersionNumber: TLabel;
    butShowHelp: TButton;
    lblCommentsto: TLabel;
    butMore: TButton;
    lblNoAdminRights: TLabel;
    procedure lbleMailAddressClick(Sender: TObject);
    procedure butSetNameClick(Sender: TObject);
    procedure butExitClick(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure butMoreClick(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure WndProc(var Message : TMessage); override;
    procedure ChangeColour(Sender : TObject; Msg : Integer);
    procedure butShowHelpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
      Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.butSetNameClick(Sender: TObject);
  begin
    AsEnteredComputerName:=Edit1.Text;
    Edit1.Text:=UpperCase(AsEnteredComputerName);
    if CheckValidityofCompterName(Edit1.Text) then begin;
      AppendToLogFile('Validity Test             : Passed - ok to rename');
      if not RenameComputer(Edit1.Text,False) then begin
        ShowMessage('Failed to set Computer name');
        exit;
      end;
      if not TaskNoReboot then begin
        if MessageDlg('The Computer Name has been sucessfully changed to ' + UpperCase(Edit1.Text) + '.' + CRLF + CRLF + 'This change will not take effect until the computer is restarted. Reboot now?', mtInformation, [mbYes, mbNo], 0) = mrYes then
          WinExit(EWX_REBOOT or EWX_FORCE);
      end
      else
        Application.Terminate;
    end
    else begin
      AppendToLogFile('Validity Test             : Failed');
      Edit1.Text:=ComputerName;
      MessageDlg('The Computer Name contains one or more illegal characters ' + CRLF + CRLF + 'For more information about valid computer names see More | Help', mtError, [mbCancel], 0)
    end;
  end;

procedure TForm1.butExitClick(Sender: TObject);
  // Graceful application termination
  begin
    AppendToLogFile('Termination               : WSName closed normally from the GUI');
    Application.Terminate;
  end;

procedure TForm1.Edit1Change(Sender: TObject);
  // Enables the SetName button if the text differs from the existing computer name
  begin
    if (UpperCase(ComputerName) <> UpperCase(Edit1.Text)) and LocalAdminRights and ((not bInDomain or bIgnoreDomainMemberShip)) then
      butSetName.Enabled:=True;
    if UpperCase(ComputerName) = UpperCase(Edit1.Text) then
      butSetName.Enabled:=False;
  end;

procedure TForm1.lbleMailAddressClick(Sender: TObject);
  //  Launches the default email application for user feedback
  begin
    ShellExecute(Handle,nil,PChar(WebPage),nil,nil,SW_SHOWNORMAL);
  end;

procedure TForm1.butMoreClick(Sender: TObject);
  var  objectTopPos : integer;
  begin
    lblNoAdminRights.Left:=butSetName.Left;

    objectTopPos:=FormTopMarginSize + (BorderAllowance * 2);

    if (not LocalAdminRights) or (bInDomain And (Not bIgnoreDomainMemberShip)) then begin
      objectTopPos:=objectTopPos + lblNoAdminRights.Height + BorderAllowance;;
    end;

    if butMore.Caption = FormMoreLabelSmall then begin
      lblCommentsto.Caption:='Web:';
      lblCommentsto.Top:=objectTopPos;
      lblCommentsto.Left:=butSetName.Left;
      lblCommentsto.Visible:=True;
      objectTopPos:=objectTopPos + lblCommentsto.Height + BorderAllowance;

      lbleMailAddress.Caption:=WebPage;
      lbleMailAddress.Top:=lblCommentsto.Top;
      lbleMailAddress.Visible:=True;

      lblVersionNumber.Caption:='Version ' + MyVersionNumber;
      lblVersionNumber.Top:=objectTopPos;
      lblVersionNumber.Left:=lblNoAdminRights.Left;
      lblVersionNumber.Visible:=True;
      objectTopPos:=objectTopPos + lblVersionNumber.Height + BorderAllowance;

      lblVersionDate.Caption:=MyVersionDate;
      lblVersionDate.Top:=lblVersionNumber.Top;
      lblVersionDate.Visible:=True;

      butShowHelp.Left:=butExit.Left;
      butShowHelp.Top:=objectTopPos;
      butShowHelp.Visible:=True;
      objectTopPos:=objectTopPos + butShowHelp.Height + BorderAllowance;

      butMore.Caption:=FormMoreLabelBig;
      butMore.Top:=objectTopPos;
      butSetName.Top:=butMore.Top;
      butExit.Top:=butMore.Top;
      objectTopPos:=objectTopPos + butExit.Height + BorderAllowance;

      Form1.ClientHeight:=objectTopPos
    end

    else begin
      Form1.ClientHeight:=FormHeightSmall;
      butMore.Caption:=FormMoreLabelSmall;
      butMore.Top:=form1.ClientHeight - butExit.Height - BorderAllowance;
      butSetName.Top:=butMore.Top;
      butExit.Top:=butMore.Top;
      lblVersionNumber.Visible:=False;
      lblVersionDate.Visible:=False;
      lbleMailAddress.Visible:=False;
      butShowHelp.Visible:=False;
      lblCommentsto.Visible:=False;
    end;
  end;


procedure TForm1.Edit1KeyPress(Sender: TObject; var Key: Char);
  // Restores the orginal computer name and sets the focus on the
  // text box if the escape key is pressed
  begin
    if Ord(key) = 27 then begin  //ESC pressed
      Edit1.text:=ComputerName;
      edit1.SelectAll;
    end;
  end;

procedure TForm1.FormCreate(Sender: TObject);
  begin
    FormHeightSmall:=DefaultFormHeightSmall - BorderAllowance;

    if (not LocalAdminRights) or (bInDomain and (Not bIgnoreDomainMemberShip)) then begin
      lblNoAdminRights.Left:=8;
      lblNoAdminRights.Width:=form1.Width-(3 * lblNoAdminRights.Left);
      if bInDomain and (Not bIgnoreDomainMemberShip) then
        lblNoAdminRights.Caption:='DISABLED: In Domain - see More | Help'
      else
        lblNoAdminRights.Caption:='Only Administrators can change names';
      lblNoAdminRights.Visible:=True;
      FormHeightSmall:=FormHeightSmall + lblNoAdminRights.Height + BorderAllowance;
    end;

    form1.ClientHeight:=FormHeightSmall;

    butMore.Top:=form1.ClientHeight - butExit.Height - BorderAllowance;
    butSetName.Top:=butMore.Top;
    butExit.Top:=butMore.Top;

    Edit1.Text:=ComputerName;
    butMore.Caption:=FormMoreLabelSmall;
    lblVersionNumber.Visible:=False;
    lblVersionDate.Visible:=False;
    lbleMailAddress.Visible:=False;
    butShowHelp.Visible:=False;
    lblCommentsto.Visible:=False;
  end;

procedure TForm1.WndProc(var Message : TMessage);
  // WndProc and ChangeColour are used to provide the "MouseOver" web highlight
  // when the mouse pointer passes over the email label
  // Here we see which component gets changed.
  // This bit here tells us which component the mouse is over
  begin
    if Message.LParam = Longint(lbleMailAddress) then
      ChangeColour(lbleMailAddress, Message.Msg);
    inherited WndProc(Message);
  end;

procedure TForm1.ChangeColour(Sender : TObject; Msg : Integer);
  // WndProc and ChangeColour are used to provide the "MouseOver" web highlight
  // when the mouse pointer passes over the email label
  // If a label is the one that the mouse is over then we
  // do this
  begin
    if Sender is TLabel then begin
      if (Msg = CM_MOUSELEAVE) then
        (Sender As TLabel).Font.Color := clWindowText;
      if (Msg = CM_MOUSEENTER) then
        (Sender As TLabel).Font.Color := clBlue;
    end;
  end;

procedure TForm1.butShowHelpClick(Sender: TObject);
  // Calls the ShowHelp procedure, this is done in the shared code unit as there
  // is also the requirment to show the Help information from the command line (/?)
  // without ever loading this form
  begin
    ShowHelpFile;
  end;

end.
