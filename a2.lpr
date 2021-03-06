program a2;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, anasayfaform, atamalarform, derlemebilgisiform, LConvEncoding,
  sysutils, genel, paylasim, g11islev, onekler, ayarlarform, araclar, g13islev,
  derleyici, hataayiklama, aramaform;

{$R *.res}

begin

  // işletim sisteminin ayarları kaydettiği dizini al
  GProgramAyarDizin := CP1254ToUTF8(GetAppConfigDir(False));

  // programın dosya açma / kaydetme için kullandığı en son dizin
  GSonKullanilanDizin := CP1254ToUTF8(ExtractFileDir(Application.ExeName));

  Application.Title:='Assembler 2 (a2)';
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TfrmAnaSayfa, frmAnaSayfa);
  Application.CreateForm(TfrmDerlemeBilgisi, frmDerlemeBilgisi);
  Application.CreateForm(TfrmAtamalar, frmAtamalar);
  Application.CreateForm(TfrmAyarlar, frmAyarlar);
  Application.CreateForm(TfrmAra, frmAra);
  Application.Run;
end.
