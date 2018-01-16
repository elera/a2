{-------------------------------------------------------------------------------

  Dosya: anasayfa.pas
  İşlev: program ana sayfası
  Tarih: 13/01/2018
  Bilgi:

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit anasayfa;

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, Menus;

type
  TfrmAnaSayfa = class(TForm)
    gbAssembler: TGroupBox;
    gbDurumBilgisi: TGroupBox;
    ilAnaMenu16: TImageList;
    miKod: TMenuItem;
    miKodDerle: TMenuItem;
    mmAnaMenu: TMainMenu;
    mmAssembler: TMemo;
    mmDurumBilgisi: TMemo;
    spYatay: TSplitter;
    sbDurum: TStatusBar;
    tbAnaSayfa: TToolBar;
    tbDerle: TToolButton;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure miKodDerleClick(Sender: TObject);
  private
  public
  end;

var
  frmAnaSayfa: TfrmAnaSayfa;

implementation

{$R *.lfm}

uses tasnif, genel, yorumla, etiket;

procedure TfrmAnaSayfa.FormCreate(Sender: TObject);
begin

  GEtiketler := TEtiket.Create;
end;

procedure TfrmAnaSayfa.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin

  GEtiketler.Destroy;
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
  ToplamSatirSayisi := mmAssembler.Lines.Count;
  MevcutSatirSayisi := 0;
  IslevSonuc := 0;

  // son satıra gelinmediği ve hata olmadığı müddetçe devam et
  while (MevcutSatirSayisi < ToplamSatirSayisi) and (IslevSonuc = 0) do
  begin

    HamVeri := mmAssembler.Lines[MevcutSatirSayisi];
    if(Length(Trim(HamVeri)) > 0) then
    begin

      // assembler koduna çevrilecek satır numarasını durum bilgisinde görüntüle
      mmDurumBilgisi.Lines.Add(IntToStr(MevcutSatirSayisi + 1) + '. satır: ' + HamVeri);

      // ilgili satırın incelendiği / kodların üretildiği ana çağrı
      IslevSonuc := KodUret(HamVeri);

      // satırda hata olmaması durumunda ...
      if(IslevSonuc = 0) then
      begin

        case GKomutTipi of

          // eğer kod, işlem kodu (opcode) ise ...
          ktIslemKodu:
          begin

            // mevcut komut satırının etiket değeri var ise ...
            if(Length(GEtiket) > 0) then mmDurumBilgisi.Lines.Add('Etiket: ' + GEtiket);

            mmDurumBilgisi.Lines.Add('İşlem Kodu: ' + Komutlar[IslemKodu].Komut);
            if(ParametreTip1 = ptYazmac) then
            begin

              mmDurumBilgisi.Lines.Add('Hedef Yazmaç: ' + Yazmaclar[Yazmac1].Ad);
            end;
            if(ParametreTip2 = ptYazmac) then
            begin

              mmDurumBilgisi.Lines.Add('Kaynak Yazmaç: ' + Yazmaclar[Yazmac2].Ad);
            end;
          end;
          // açıklama satırı
          ktAciklama:
          begin

            // mevcut komut satırının etiket değeri var ise ...
            if(Length(GEtiket) > 0) then mmDurumBilgisi.Lines.Add('Etiket: ' + GEtiket);

            mmDurumBilgisi.Lines.Add('Açıklama: ' + GAciklama);
          end;
          // etiket satırı
          ktEtiket:
          begin

            // etiket değeri
            mmDurumBilgisi.Lines.Add('Etiket: ' + GEtiket);
          end;
        end;

        mmDurumBilgisi.Lines.Add('');
      end
      else
      // satırda hata olması durumunda
      begin

        mmDurumBilgisi.Lines.Add('Hata: ' + HataKodunuAl(IslevSonuc) + ' - ' + GHataAciklama);
      end;
    end;

    // bir sonraki satıra geçiş yap
    Inc(MevcutSatirSayisi);
  end;

  // durum bilgisini güncelle
  mmDurumBilgisi.Lines.EndUpdate;
end;

end.
