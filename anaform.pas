{-------------------------------------------------------------------------------

  Dosya: anasayfa.pas

  İşlev: program ana sayfası

  Güncelleme Tarihi: 11/02/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit anaform;

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, SynHighlighterAny, Forms, Controls,
  Graphics, Dialogs, StdCtrls, ComCtrls, ExtCtrls, Menus;

type
  TfrmAnaForm = class(TForm)
    ilAnaMenu16: TImageList;
    miKodEtiketListesi: TMenuItem;
    MenuItem2: TMenuItem;
    miYardim: TMenuItem;
    miYardimAssemblerBelge: TMenuItem;
    miKod: TMenuItem;
    miKodDerle: TMenuItem;
    mmAnaMenu: TMainMenu;
    sbDurum: TStatusBar;
    seAssembler: TSynEdit;
    SynAssemblerSyn: TSynAnySyn;
    tbAnaSayfa: TToolBar;
    tbDerle: TToolButton;
    tbAyrim0: TToolButton;
    tbAssemblerBelge: TToolButton;
    tbEtiketListesi: TToolButton;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure miKodEtiketListesiClick(Sender: TObject);
    procedure miYardimAssemblerBelgeClick(Sender: TObject);
    procedure miKodDerleClick(Sender: TObject);
    function FormuOrtala(GoruntulenecekForm: TForm; SonucuBekle: Boolean): Integer;
  private
  public
  end;

var
  frmAnaForm: TfrmAnaForm;

implementation

{$R *.lfm}

uses incele, genel, yorumla, etiket, matematik, donusum, dosya, derlemebilgisiform,
  etiketform, asm2, ayarlar, ShellApi, windows;

procedure TfrmAnaForm.FormCreate(Sender: TObject);
begin

  // çalışma zamanlı nesneler oluşturuluyor
  GAsm2 := TAsm2.Create;
  GMatematik := TMatematik.Create;

  // daha önce kaydedilen program ayarlarını oku
  GProgramAyarlari := GAsm2.ProgramAyarDosyasiniOku;

  // eğer program ilk kez çalıştırıldıysa
  if(GProgramAyarlari.PencereSol = -1) and (GProgramAyarlari.PencereUst = -1)
    and (GProgramAyarlari.PencereGenislik = -1)
    and (GProgramAyarlari.PencereYukseklik = -1) then
  begin

    GProgramAyarlari.PencereGenislik := 500;
    GProgramAyarlari.PencereYukseklik := 500;
    GProgramAyarlari.PencereSol := (Screen.Width - 500) div 2;
    GProgramAyarlari.PencereUst := (Screen.Height - 500) div 2;
  end;
end;

procedure TfrmAnaForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin

  // program ayarlarını ini dosyasına yaz
  GProgramAyarlari.PencereSol := frmAnaForm.Left;
  GProgramAyarlari.PencereUst := frmAnaForm.Top;
  GProgramAyarlari.PencereGenislik := frmAnaForm.Width;
  GProgramAyarlari.PencereYukseklik := frmAnaForm.Height;
  GProgramAyarlari.PencereDurum := frmAnaForm.WindowState;

  GAsm2.ProgramAyarDosyasinaYaz(GProgramAyarlari);

  // çalışma zamanlı oluşturulan nesneler yok ediliyor
  GMatematik.Destroy;
  GAsm2.Destroy;
end;

procedure TfrmAnaForm.FormShow(Sender: TObject);
var
  i: Integer;
begin

  SynAssemblerSyn.Objects.Clear;
  for i := 0 to TOPLAM_KOMUT - 1 do
    SynAssemblerSyn.Objects.Add(UpperCase(Komutlar[i].Komut));

  SynAssemblerSyn.KeyWords.Clear;
  for i := 0 to TOPLAM_YAZMAC - 1 do
    SynAssemblerSyn.KeyWords.Add(UpperCase(Yazmaclar[i].Ad));

  frmAnaForm.Left := GProgramAyarlari.PencereSol;
  frmAnaForm.Top := GProgramAyarlari.PencereUst;
  frmAnaForm.Width := GProgramAyarlari.PencereGenislik;
  frmAnaForm.Height := GProgramAyarlari.PencereYukseklik;
  frmAnaForm.WindowState := GProgramAyarlari.PencereDurum;
end;

procedure TfrmAnaForm.miKodEtiketListesiClick(Sender: TObject);
begin

  FormuOrtala(frmEtiketForm, True);
end;

// kod derleme menüsü
procedure TfrmAnaForm.miKodDerleClick(Sender: TObject);
var
  MevcutSatirSayisi, ToplamSatirSayisi,
  IslenenSatirSayisi: Integer;
  HamVeri: string;
  IslevSonuc: Integer;
begin

  MevcutBellekAdresi := 0;
  KodBellekU := 0;

  // mevcut etiketleri temizle
  GAsm2.Etiketler.Temizle;

  // ilk değer atamaları
  ToplamSatirSayisi := seAssembler.Lines.Count;
  MevcutSatirSayisi := 0;
  IslenenSatirSayisi := 0;
  IslevSonuc := HATA_YOK;

  // son satıra gelinmediği ve hata olmadığı müddetçe devam et
  while (MevcutSatirSayisi < ToplamSatirSayisi) and (IslevSonuc = HATA_YOK) do
  begin

    HamVeri := seAssembler.Lines[MevcutSatirSayisi];
    if(Length(Trim(HamVeri)) > 0) then
    begin

      // her 2 değişken tipi de burada yok olarak belirtiliyor
      GAnaBolumVeriTipi := abvtBelirsiz;
      GIslemKodAnaBolum := [];
      GIKABVeriTipi1 := vtYok;
      GIKABVeriTipi2 := vtYok;

      // ilgili satırın incelendiği / kodların üretildiği ana çağrı
      IslevSonuc := KodUret(HamVeri);

      // işlenen satır sayısını artır
      Inc(IslenenSatirSayisi);
    end;

    // bir sonraki satıra geçiş yap
    Inc(MevcutSatirSayisi);
  end;

  // kodların yorumlanması ve çevrilmesinde herhangi bir hata yoksa
  // ikili formatta (binary file) dosya oluştur
  { TODO : oluşturulacak dosya ilk aşamada saf assembler kodların makine dili karşılıklarıdır
    ileride PE / COFF ve diğer formatlarda program dosyaları oluşturulacaktır  }
  if(IslevSonuc = HATA_YOK) then
  begin

    if(ProgramDosyasiOlustur) then
    begin

      frmDerlemeBilgisi.DerlenenSatirSayisi := IslenenSatirSayisi;
      frmDerlemeBilgisi.IkiliDosyaUzunluk := KodBellekU;
      FormuOrtala(frmDerlemeBilgisi, True);
    end else ShowMessage('Hata: test.bin dosyası oluşturulamadı!')
  end
  else
  begin

    ShowMessage('Hata: ' + HataKodunuAl(IslevSonuc)); // + ' - ' + GHataAciklama);
    seAssembler.CaretX := 1;
    seAssembler.CaretY := MevcutSatirSayisi;
  end;
end;

function TfrmAnaForm.FormuOrtala(GoruntulenecekForm: TForm; SonucuBekle:
  Boolean): Integer;
var
  X, Y: Integer;
begin

  X := (frmAnaForm.Width - GoruntulenecekForm.Width) div 2;
  Y := (frmAnaForm.Height - GoruntulenecekForm.Height) div 2;
  GoruntulenecekForm.Left := frmAnaForm.Left + X;
  GoruntulenecekForm.Top := frmAnaForm.Top + Y;

  if(SonucuBekle) then
    Result := GoruntulenecekForm.ShowModal
  else GoruntulenecekForm.Show;
end;

procedure TfrmAnaForm.miYardimAssemblerBelgeClick(Sender: TObject);
begin

  if(ShellExecute(0, nil, PChar('notepad.exe'), PChar('assembler.txt'),
    nil, SW_SHOWNORMAL) < 33) then
  begin
       self.WindowState := wsMaximized;
    ShowMessage('Yardım dosyası açılırken hata oluştu!');
  end;
end;

end.
