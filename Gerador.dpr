program Gerador;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {uGeradorTelas};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TuGeradorTelas, uGeradorTelas);
  Application.Run;
end.
