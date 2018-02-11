program a2;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, anaform, yorumla, donusum, matematik, dosya, derlemebilgisiform,
  etiketform, asm2, ayarlar, genel, LConvEncoding, sysutils;

{$R *.res}

begin

  // işletim sisteminin ayarları kaydettiği dizini al
  GProgramAyarDizin := CP1254ToUTF8(GetAppConfigDir(False));

  Application.Title:='Assembler 2 (a2)';
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TfrmAnaForm, frmAnaForm);
  Application.CreateForm(TfrmDerlemeBilgisi, frmDerlemeBilgisi);
  Application.CreateForm(TfrmEtiketForm, frmEtiketForm);
  Application.Run;
end.
