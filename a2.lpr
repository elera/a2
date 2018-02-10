program a2;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, anaform, yorumla, donusum, matematik, takip, dosya, derlemebilgisiform,
  etiketform, asm2;

{$R *.res}

begin
  Application.Title:='Assembler 2 (a2)';
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TfrmAnaForm, frmAnaForm);
  Application.CreateForm(TfrmDerlemeBilgisi, frmDerlemeBilgisi);
  Application.CreateForm(TfrmEtiketForm, frmEtiketForm);
  Application.Run;
end.
