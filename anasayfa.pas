{-------------------------------------------------------------------------------

  Dosya: anasayfa.pas

  İşlev: program ana sayfası

  Güncelleme Tarihi: 30/01/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit anasayfa;

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, SynHighlighterAny, Forms, Controls,
  Graphics, Dialogs, StdCtrls, ComCtrls, ExtCtrls, Menus;

type

  { TfrmAnaSayfa }

  TfrmAnaSayfa = class(TForm)
    gbAssembler: TGroupBox;
    gbDurumBilgisi: TGroupBox;
    ilAnaMenu16: TImageList;
    miKod: TMenuItem;
    miKodDerle: TMenuItem;
    mmAnaMenu: TMainMenu;
    mmDurumBilgisi: TMemo;
    spYatay: TSplitter;
    sbDurum: TStatusBar;
    seAssembler: TSynEdit;
    SynAnySyn1: TSynAnySyn;
    tbAnaSayfa: TToolBar;
    tbDerle: TToolButton;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure miKodDerleClick(Sender: TObject);
  private
  public
  end;

var
  frmAnaSayfa: TfrmAnaSayfa;

implementation

{$R *.lfm}

uses incele, genel, yorumla, etiket, matematik, donusum, dosya;

procedure TfrmAnaSayfa.FormCreate(Sender: TObject);
begin

  // çalışma zamanlı nesneler oluşturuluyor
  GEtiketler := TEtiket.Create;
  GMatematik := TMatematik.Create;
end;

procedure TfrmAnaSayfa.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin

  // çalışma zamanlı oluşturulan nesneler yok ediliyor
  GMatematik.Destroy;
  GEtiketler.Destroy;
end;

procedure TfrmAnaSayfa.FormShow(Sender: TObject);
var
  i: Integer;
begin

  SynAnySyn1.Objects.Clear;
  for i := 0 to TOPLAM_KOMUT - 1 do
    SynAnySyn1.Objects.Add(UpperCase(Komutlar[i].Komut));

  SynAnySyn1.KeyWords.Clear;
  for i := 0 to TOPLAM_YAZMAC - 1 do
    SynAnySyn1.KeyWords.Add(UpperCase(Yazmaclar[i].Ad));
end;

// kod derleme menüsü
procedure TfrmAnaSayfa.miKodDerleClick(Sender: TObject);
var
  MevcutSatirSayisi, ToplamSatirSayisi: Integer;
  HamVeri: string;
  IslevSonuc: Integer;
begin

  // mevcut etiketleri temizle
  GEtiketler.Temizle;

  // durum nesne içeriğini temizle
  mmDurumBilgisi.Clear;
  mmDurumBilgisi.Lines.BeginUpdate;

  // ilk değer atamaları
  ToplamSatirSayisi := seAssembler.Lines.Count;
  MevcutSatirSayisi := 0;
  IslevSonuc := HATA_YOK;

  // son satıra gelinmediği ve hata olmadığı müddetçe devam et
  while (MevcutSatirSayisi < ToplamSatirSayisi) and (IslevSonuc = HATA_YOK) do
  begin

    HamVeri := seAssembler.Lines[MevcutSatirSayisi];
    if(Length(Trim(HamVeri)) > 0) then
    begin

      // assembler koduna çevrilecek satır numarasını durum bilgisinde görüntüle
      mmDurumBilgisi.Lines.Add(IntToStr(MevcutSatirSayisi + 1) + '. satır: ' + HamVeri);

      // her 2 değişken tipi de burada yok olarak belirtiliyor
      GAnaBolumVeriTipi := abvtBelirsiz;
      GIslemKodAnaBolum := [];
      GIKABVeriTipi1 := vtYok;
      GIKABVeriTipi2 := vtYok;

      // ilgili satırın incelendiği / kodların üretildiği ana çağrı
      IslevSonuc := KodUret(HamVeri);

      // hata olması durumunda
      if(IslevSonuc > HATA_YOK) then
        mmDurumBilgisi.Lines.Add('Hata: ' + HataKodunuAl(IslevSonuc) + ' - ' + GHataAciklama);
    end;

    // bir sonraki satıra geçiş yap
    Inc(MevcutSatirSayisi);
  end;

  // durum bilgisini güncelle
  mmDurumBilgisi.Lines.EndUpdate;

  // kodların yorumlanması ve çevrilmesinde herhangi bir hata yoksa
  // ikili formatta (binary file) dosya oluştur
  { TODO : oluşturulacak dosya ilk aşamada saf assembler kodların makine dili karşılıklarıdır
    ileride PE / COFF ve diğer formatlarda program dosyaları oluşturulacaktır  }
  if(IslevSonuc = HATA_YOK) then ProgramDosyasiOlustur;
end;

end.
