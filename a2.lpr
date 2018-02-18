program a2;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, anaform, etiketform, derlemebilgisiform, LConvEncoding, sysutils,
  genel, g01islev, oneriler, g02islev, komutlar;

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
