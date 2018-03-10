{-------------------------------------------------------------------------------

  Dosya: anasayfaform.pas

  İşlev: program ana sayfası

  Güncelleme Tarihi: 07/03/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit anasayfaform;

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, SynHighlighterAny, SynCompletion, Forms,
  Controls, Graphics, Dialogs, StdCtrls, ComCtrls, ExtCtrls, Menus, Types, LCLType;

type

  { TfrmAnaSayfa }

  TfrmAnaSayfa = class(TForm)
    ilAnaMenu16: TImageList;
    miKodCalistir: TMenuItem;
    miKodEtiketListesi: TMenuItem;
    miAyrim0: TMenuItem;
    miYardim: TMenuItem;
    miYardimAssemblerBelge: TMenuItem;
    miKod: TMenuItem;
    miKodDerle: TMenuItem;
    mmAnaMenu: TMainMenu;
    sbDurum: TStatusBar;
    seAssembler: TSynEdit;
    SynAssemblerSyn: TSynAnySyn;
    SynCompletion1: TSynCompletion;
    tbAnaSayfa: TToolBar;
    tbDerle: TToolButton;
    tbAyrim0: TToolButton;
    tbAssemblerBelge: TToolButton;
    tbEtiketListesi: TToolButton;
    ToolButton1: TToolButton;
    tbAyrim1: TToolButton;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure miKodEtiketListesiClick(Sender: TObject);
    procedure miYardimAssemblerBelgeClick(Sender: TObject);
    procedure miKodDerleClick(Sender: TObject);
    function FormuOrtala(GoruntulenecekForm: TForm; SonucuBekle: Boolean): Integer;
    procedure miKodCalistirClick(Sender: TObject);
    procedure seAssemblerClick(Sender: TObject);
    procedure seAssemblerKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SynCompletion1Execute(Sender: TObject);
  private
    procedure ImleciGuncelle;
  public
  end;

var
  frmAnaSayfa: TfrmAnaSayfa;

implementation

{$R *.lfm}

uses incele, genel, atamalar, dosya, derlemebilgisiform, atamalarform, asm2,
  ayarlar, yazmaclar, windows, process, oneriler, komutlar, dbugintf,
  paylasim, donusum;

procedure TfrmAnaSayfa.FormCreate(Sender: TObject);
begin

  // çalışma zamanlı nesneler oluşturuluyor
  GAsm2 := TAsm2.Create;

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

procedure TfrmAnaSayfa.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin

  // program ayarlarını ini dosyasına yaz
  GProgramAyarlari.PencereSol := frmAnaSayfa.Left;
  GProgramAyarlari.PencereUst := frmAnaSayfa.Top;
  GProgramAyarlari.PencereGenislik := frmAnaSayfa.Width;
  GProgramAyarlari.PencereYukseklik := frmAnaSayfa.Height;
  GProgramAyarlari.PencereDurum := frmAnaSayfa.WindowState;

  GAsm2.ProgramAyarDosyasinaYaz(GProgramAyarlari);

  // çalışma zamanlı oluşturulan nesneler yok ediliyor
  GAsm2.Destroy;
end;

procedure TfrmAnaSayfa.FormShow(Sender: TObject);
var
  i: Integer;
begin

  sbDurum.Panels[2].Text := 'Sürüm: ' + ProgramSurum + ' - ' + SurumTarihi;

  SynAssemblerSyn.Objects.Clear;
  for i := 0 to TOPLAM_KOMUT - 1 do
    SynAssemblerSyn.Objects.Add(UpperCase(KomutListesi[i].Komut));

  SynAssemblerSyn.KeyWords.Clear;
  for i := 0 to TOPLAM_YAZMAC - 1 do
    SynAssemblerSyn.KeyWords.Add(UpperCase(YazmacListesi[i].Ad));

  frmAnaSayfa.Left := GProgramAyarlari.PencereSol;
  frmAnaSayfa.Top := GProgramAyarlari.PencereUst;
  frmAnaSayfa.Width := GProgramAyarlari.PencereGenislik;
  frmAnaSayfa.Height := GProgramAyarlari.PencereYukseklik;
  frmAnaSayfa.WindowState := GProgramAyarlari.PencereDurum;
end;

procedure TfrmAnaSayfa.miKodEtiketListesiClick(Sender: TObject);
begin

  FormuOrtala(frmAtamalar, True);
end;

// kod derleme menüsü
procedure TfrmAnaSayfa.miKodDerleClick(Sender: TObject);
var
  MevcutSatirSayisi, ToplamSatirSayisi,
  IslenenSatirSayisi: Integer;
  Dosya, HamVeri: string;
  IslevSonuc: Integer;
  DerlemeCevrimindenCik: Boolean;
begin

  DerlemeCevrimindenCik := False;

  // mevcut etiketleri temizle
  GAsm2.AtamaListesi.Temizle;

  // ilk değer atamaları
  GAsm2.DerlemeCevrimSayisi := 1;

  while (DerlemeCevrimindenCik = False) do
  begin

    IslevSonuc := HATA_YOK;

    GEtiketHataSayisi := 0;

    KodBellekU := 0;
    MevcutBellekAdresi := 0;

    ToplamSatirSayisi := seAssembler.Lines.Count;
    MevcutSatirSayisi := 0;
    IslenenSatirSayisi := 0;

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
        IslevSonuc := KodUret(MevcutSatirSayisi, HamVeri);

        // işlenen satır sayısını artır
        Inc(IslenenSatirSayisi);
      end;

      // bir sonraki satıra geçiş yap
      Inc(MevcutSatirSayisi);
      Application.ProcessMessages;
    end;

    // hata olduğu için çıkış yap
    if(IslevSonuc > HATA_YOK) then

      DerlemeCevrimindenCik := True

    // derleme başarılı olduğu için çıkış yap
    else if(IslevSonuc = HATA_YOK) and (GAsm2.AtamaListesi.Temizle2 = 0) then

      DerlemeCevrimindenCik := True

    else GAsm2.DerlemeCevrimSayisi := GAsm2.DerlemeCevrimSayisi + 1;

    Application.ProcessMessages;
  end;

  // derleme işleminin durumu, derleme sonrasında belirleniyor
  GAsm2.DerlemeBasarili := (IslevSonuc = HATA_YOK);

  // kodların yorumlanması ve çevrilmesinde herhangi bir hata yoksa
  // ikili formatta (binary file) dosya oluştur
  { TODO : oluşturulacak dosya ilk aşamada saf assembler kodların makine dili karşılıklarıdır
    ileride PE / COFF ve diğer formatlarda program dosyaları oluşturulacaktır  }
  if(GAsm2.DerlemeBasarili) then
  begin

    if(ProgramDosyasiOlustur) then
    begin

      Dosya := GAsm2.DosyaAdi + '.' + GAsm2.DosyaUzanti;
      frmDerlemeBilgisi.DerlenenDosya := Dosya;
      frmDerlemeBilgisi.DerlenenSatirSayisi := IslenenSatirSayisi;
      frmDerlemeBilgisi.IkiliDosyaUzunluk := KodBellekU;
      frmDerlemeBilgisi.DerlemeCevrimSayisi := GAsm2.DerlemeCevrimSayisi;
      FormuOrtala(frmDerlemeBilgisi, True);
    end else ShowMessage('Hata: ' + Dosya + ' dosyası oluşturulamadı!')
  end
  else
  begin

    ShowMessage('Hata: ' + HataKodunuAl(IslevSonuc)); // + ' - ' + GHataAciklama);
    seAssembler.CaretX := 1;
    seAssembler.CaretY := MevcutSatirSayisi;
  end;
end;

function TfrmAnaSayfa.FormuOrtala(GoruntulenecekForm: TForm; SonucuBekle:
  Boolean): Integer;
var
  X, Y: Integer;
begin

  X := (frmAnaSayfa.Width - GoruntulenecekForm.Width) div 2;
  Y := (frmAnaSayfa.Height - GoruntulenecekForm.Height) div 2;
  GoruntulenecekForm.Left := frmAnaSayfa.Left + X;
  GoruntulenecekForm.Top := frmAnaSayfa.Top + Y;

  if(SonucuBekle) then
    Result := GoruntulenecekForm.ShowModal
  else GoruntulenecekForm.Show;
end;

procedure TfrmAnaSayfa.miKodCalistirClick(Sender: TObject);
var
  Process: TProcess;
begin

  // program; exe olarak başarılı bir şekilde derlendiyse, çalıştır
  if(GAsm2.DerlemeBasarili) and (GAsm2.DosyaUzanti = 'exe') then
  begin

    Process := TProcess.Create(nil);
    try

      Process.Executable := GAsm2.DosyaAdi + '.' + GAsm2.DosyaUzanti;
      Process.Options := Process.Options + [poWaitOnExit];
      Process.Execute;
    except

      ShowMessage('Hata: program çalıştırılamıyor!');
    end;
    FreeAndNil(Process);

  end else ShowMessage('Lütfen ilk önce, programı çalıştırılabilir olarak derleyiniz!');
end;

procedure TfrmAnaSayfa.SynCompletion1Execute(Sender: TObject);
begin

  OnerileriListele(SynCompletion1.CurrentString, SynCompletion1.ItemList);
end;

procedure TfrmAnaSayfa.miYardimAssemblerBelgeClick(Sender: TObject);
begin

  if(ShellExecute(0, nil, PChar('notepad.exe'), PChar('assembler.txt'),
    nil, SW_SHOWNORMAL) < 33) then
  begin

    ShowMessage('Hata: yardım dosyası açılamadı!');
  end;
end;

procedure TfrmAnaSayfa.seAssemblerClick(Sender: TObject);
begin

  ImleciGuncelle;
end;

procedure TfrmAnaSayfa.seAssemblerKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

  ImleciGuncelle;
end;

procedure TfrmAnaSayfa.ImleciGuncelle;
begin

  sbDurum.Panels[1].Text := 'Satır: ' + IntToStr(seAssembler.CaretY) + ' - Sütun: ' +
    IntToStr(seAssembler.CaretX);
end;

end.
