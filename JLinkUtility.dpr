program JLinkUtility;

uses
  Vcl.Forms,
  uMain in 'Source\uMain.pas' {MainForm},
  uJLinkUtility in 'Source\uJLinkUtility.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
