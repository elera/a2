{-------------------------------------------------------------------------------

  Dosya: atamalar.pas

  İşlev: proje içerisindeki etiket ve tanım değerlerini yönetir

  Güncelleme Tarihi: 24/09/2018

  Bilgi: etiket ve tanım işlemlerindeki isimlendirmenin tümü küçük harflerle yapılmaktadır.

  1. "büyük harf, küçük harf, büyük-küçük karışık harf, UTF-8 karakterlerin tümü",
    küçük harf olarak işlem görmektedir.
  2. isimlendirme mekanizması, türkçe harflerin rahatça kullanılabilmesi için tasarlanmıştır

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit atamalar;

interface

uses Classes, SysUtils, paylasim, dosya;

type
  // atEtiket->örnek   : etiket:
  // atDegisken->örnek : degisken  dd  40
  // atTanim->örnek    : SAYI_BES = 5
  TAtamaTipi = (atEtiket, atDegisken, atTanim);

type
  TAtama = class(TCollectionItem)
  private
    FAdi: string;
    FTip: TAtamaTipi;
    FDosyaAdi,
    FsDeger: string;
    FiDeger, FBellekAdresi: QWord;
    FVeriTipi: TVeriTipleri;
    FVeriUzunluk, FSatirNo: Integer;
    // FYenidenAtanabilir değeri, her bir çevrimde yeniden atamanın
    // gerçekleştirilebilmesi amacıyla tanımlanmıştır
    FYenidenAtanabilir: Boolean;
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
  published
    property Adi: string read FAdi write FAdi;
    property Tip: TAtamaTipi read FTip write FTip;
    property DosyaAdi: string read FDosyaAdi write FDosyaAdi;
    property BellekAdresi: QWord read FBellekAdresi write FBellekAdresi;
    property VeriTipi: TVeriTipleri read FVeriTipi write FVeriTipi;
    property VeriUzunluk: Integer read FVeriUzunluk write FVeriUzunluk;
    property sDeger: string read FsDeger write FsDeger;
    property iDeger: QWord read FiDeger write FiDeger;
    property SatirNo: Integer read FSatirNo write FSatirNo;
    property YenidenAtanabilir: Boolean read FYenidenAtanabilir write FYenidenAtanabilir;
  end;

  TAtamaListesi = class(TCollection)
  private
    function Al(ASiraNo: Integer): TAtama;
    procedure Ver(ASiraNo: Integer; AEtiket: TAtama);
    function GetToplam: Integer;
  public
    constructor Create;
    function Ekle(Dosya: TDosya; AtamaTipi: TAtamaTipi;
      EtiketVeyaAtananDeger: string; ParcaSonuc: TParcaSonuc): Integer;
    function Bul(Dosya: TDosya; EtiketVeyaAtananDeger: string): TAtama;
    procedure Temizle;
    procedure YeniCevrim;
    property Toplam: Integer read GetToplam;
    property Eleman[Sira: Integer]: TAtama read Al write Ver;
  end;

implementation

uses genel, donusum, yazmaclar, komutlar, onekler, dbugintf;

constructor TAtama.Create(ACollection: TCollection);
begin

  inherited Create(ACollection);
end;

destructor TAtama.Destroy;
begin

  inherited Destroy;
end;

constructor TAtamaListesi.Create;
begin

  inherited Create(TAtama);
end;

function TAtamaListesi.Ekle(Dosya: TDosya; AtamaTipi: TAtamaTipi;
  EtiketVeyaAtananDeger: string; ParcaSonuc: TParcaSonuc): Integer;
var
  PS: TParcaSonuc;
  DosyaAdUzanti, s: string;
  Etiket: TAtama;
  SayiTipi: TVeriGenisligi;
begin

  Result := HATA_YOK;

  s := KucukHarfeCevir(EtiketVeyaAtananDeger);

  // etiket, değişken ve tanım değeri bir sayı ile başlayamaz!
  if(s[1] in ['0'..'9']) then
  begin

    Result := HATA_ETIKET_TANIM;
    Exit;
  end;

  // etiket, değişken ve tanım değeri bir işlem kodu olamaz!
  if(DegerBirKomutMu(EtiketVeyaAtananDeger)) then
  begin

    Result := HATA_ETIKET_TANIM;
    Exit;
  end;

  // etiket, değişken ve tanım değeri bir yazmaç olamaz!
  PS.HamVeri := EtiketVeyaAtananDeger;
  PS := YazmacBilgisiAl(PS);
  if(PS.VeriTipi = vYazmac) then
  begin

    Result := HATA_ETIKET_TANIM;
    Exit;
  end;

  if(Length(Dosya.ProjeDosyaUzanti) > 0) then
    DosyaAdUzanti := Dosya.ProjeDosyaAdi + '.' + Dosya.ProjeDosyaUzanti
  else DosyaAdUzanti := Dosya.ProjeDosyaAdi;

  // etiket, değişken ve tanım değerini listeye ekle
  if(Toplam = 0) then
  begin

    Etiket := inherited Add as TAtama;
    Etiket.FYenidenAtanabilir := False;
    Etiket.Tip := AtamaTipi;
    Etiket.DosyaAdi := DosyaAdUzanti;
    Etiket.SatirNo := Dosya.IslenenToplamSatir;
    Etiket.Adi := s;

    if(AtamaTipi = atEtiket) or (AtamaTipi = atDegisken) then
    begin

      Etiket.VeriTipi := vSayi;
      Etiket.BellekAdresi := ParcaSonuc.VeriSD;
    end
    else
    begin

      Etiket.VeriTipi := ParcaSonuc.VeriTipi;

      if(ParcaSonuc.VeriTipi = vSayi) then
      begin

        SayiTipi := SayiTipiniAl(ParcaSonuc.VeriSD);
        case SayiTipi of
          //stHatali: Etiket.VeriUzunluk := 0;
          vgB1: Etiket.VeriUzunluk := 1;
          vgB2: Etiket.VeriUzunluk := 2;
          vgB4: Etiket.VeriUzunluk := 4;
          vgB8: Etiket.VeriUzunluk := 8;
        end;
        Etiket.iDeger := ParcaSonuc.VeriSD;
      end
      else if(ParcaSonuc.VeriTipi = vKarakterDizisi) then
      begin

        Etiket.VeriUzunluk := Length(ParcaSonuc.VeriKK);
        Etiket.sDeger := ParcaSonuc.VeriKK;
      end;
    end;
  end
  else
  begin

    Etiket := Bul(Dosya, s);
    // etiket değerinin "YenidenAtanabilir" OLMAMASI durumunda
    if not(Etiket = nil) and not(Etiket.FYenidenAtanabilir) then
    begin

      // farklı bir satırdaki etiket, tanımlanmış bir etiketi tekrar tanımlamaya
      // çalışırsa geriye hata kodu döndür
      if(Etiket.SatirNo <> Dosya.IslenenToplamSatir) then Result := HATA_ETIKET_TANIMLANMIS;
    end
    else
    begin

      // etiket daha önce tanımlanmamışsa, oluştur
      if(Etiket = nil) then
      begin

        Etiket := inherited Add as TAtama;
        Etiket.Tip := AtamaTipi;
        Etiket.DosyaAdi := DosyaAdUzanti;
        Etiket.SatirNo := Dosya.IslenenToplamSatir;
        Etiket.Adi := s;
      end;
      Etiket.FYenidenAtanabilir := False;

      // etiket oluşturulduktan sonra veya daha önce oluşturulmuşsa
      if(AtamaTipi = atEtiket) or (AtamaTipi = atDegisken) then
      begin

        Etiket.VeriTipi := vSayi;
        Etiket.BellekAdresi := ParcaSonuc.VeriSD;
      end
      else
      begin

        Etiket.VeriTipi := ParcaSonuc.VeriTipi;

        if(ParcaSonuc.VeriTipi = vSayi) then
        begin

          SayiTipi := SayiTipiniAl(ParcaSonuc.VeriSD);
          case SayiTipi of
            //stHatali: Etiket.VeriUzunluk := 0;
            vgB1: Etiket.VeriUzunluk := 1;
            vgB2: Etiket.VeriUzunluk := 2;
            vgB4: Etiket.VeriUzunluk := 4;
            vgB8: Etiket.VeriUzunluk := 8;
          end;
          Etiket.iDeger := ParcaSonuc.VeriSD;
        end
        else if(ParcaSonuc.VeriTipi = vKarakterDizisi) then
        begin

          Etiket.VeriUzunluk := Length(ParcaSonuc.VeriKK);
          Etiket.sDeger := ParcaSonuc.VeriKK;
        end;
      end;
    end;
  end;
end;

function TAtamaListesi.Bul(Dosya: TDosya; EtiketVeyaAtananDeger: string): TAtama;
var
  i: Integer;
  DosyaAdUzanti, s: string;
begin

  Result := nil;

  if(Toplam = 0) then Exit;

  s := KucukHarfeCevir(EtiketVeyaAtananDeger);

  if(Length(Dosya.ProjeDosyaUzanti) > 0) then
    DosyaAdUzanti := Dosya.ProjeDosyaAdi + '.' + Dosya.ProjeDosyaUzanti
  else DosyaAdUzanti := Dosya.ProjeDosyaAdi;

  for i := 0 to Toplam - 1 do
  begin

    if{(Eleman[i].DosyaAdi = DosyaAdUzanti) and} (Eleman[i].Adi = s) then
    begin

      Result := Eleman[i];
      Exit;
    end;
  end;
end;

procedure TAtamaListesi.Temizle;
begin

  inherited Clear;
end;

// yeni çevrim için mevcut veri tip tanımlamalarını tanımsız olarak atamalarını yapar
procedure TAtamaListesi.YeniCevrim;
var
  i: Integer;
begin

  if(Toplam > 0) then
  begin

    for i := 0 to Toplam - 1 do
    begin

      Eleman[i].FYenidenAtanabilir := True;
    end;
  end;
end;

function TAtamaListesi.Al(ASiraNo: Integer): TAtama;
begin

  Result := TAtama(inherited GetItem(ASiraNo));
end;

procedure TAtamaListesi.Ver(ASiraNo: Integer; AEtiket: TAtama);
begin

  inherited SetItem(ASiraNo, AEtiket);
end;

function TAtamaListesi.GetToplam: Integer;
begin

  Result := inherited Count;
end;

end.
