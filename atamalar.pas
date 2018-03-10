{-------------------------------------------------------------------------------

  Dosya: atamalar.pas

  İşlev: proje içerisindeki etiket ve tanım değerlerini yönetir

  Güncelleme Tarihi: 08/03/2018

  Bilgi: etiket ve tanım işlemlerindeki isimlendirmenin tümü küçük harflerle yapılmaktadır.

  1. "büyük harf, küçük harf, büyük-küçük karışık harf, UTF-8 karakterlerin tümü",
    küçük harf olarak işlem görmektedir.
  2. isimlendirme mekanizması, türkçe harflerin rahatça kullanılabilmesi için tasarlanmıştır

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit atamalar;

interface

uses Classes, SysUtils, paylasim;

type
  TAtamaTipi = (etEtiket, etTanim);

type
  TAtama = class(TCollectionItem)
  private
    FAdi: string;
    FTip: TAtamaTipi;
    FsDeger: string;
    FiDeger, FBellekAdresi: QWord;
    FVeriTipi: TTemelVeriTipi;
    FVeriUzunluk, FSatirNo: Integer;
    FEtiketHatasiMevcut: Boolean;
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
  published
    property Adi: string read FAdi write FAdi;
    property Tip: TAtamaTipi read FTip write FTip;
    property BellekAdresi: QWord read FBellekAdresi write FBellekAdresi;
    property VeriTipi: TTemelVeriTipi read FVeriTipi write FVeriTipi;
    property VeriUzunluk: Integer read FVeriUzunluk write FVeriUzunluk;
    property sDeger: string read FsDeger write FsDeger;
    property iDeger: QWord read FiDeger write FiDeger;
    property SatirNo: Integer read FSatirNo write FSatirNo;
    property EtiketHatasiMevcut: Boolean read FEtiketHatasiMevcut
      write FEtiketHatasiMevcut;
  end;

  TAtamaListesi = class(TCollection)
  private
    function Al(ASiraNo: Integer): TAtama;
    procedure Ver(ASiraNo: Integer; AEtiket: TAtama);
    function GetToplam: Integer;
  public
    constructor Create;
    function Ekle(SatirNo: Integer; EtiketAdi: string; AtamaTipi: TAtamaTipi;
      BellekAdresi: QWord; VeriTipi: TTemelVeriTipi; VeriUzunlugu: Integer; sDeger: string;
      iDeger: QWord): Integer;
    function Bul(EtiketAdi: string): TAtama;
    procedure Temizle;
    function Temizle2: Integer;
    property Toplam: Integer read GetToplam;
    property Eleman[Sira: Integer]: TAtama read Al write Ver;
  end;

implementation

uses genel, donusum, yazmaclar, komutlar;

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

function TAtamaListesi.Ekle(SatirNo: Integer; EtiketAdi: string; AtamaTipi: TAtamaTipi;
  BellekAdresi: QWord; VeriTipi: TTemelVeriTipi; VeriUzunlugu: Integer; sDeger: string;
  iDeger: QWord): Integer;
var
  s: string;
  Etiket: TAtama;
  Komut: TKomutDurum;
  Yazmac: TYazmacDurum;
  SayiTipi: TSayiTipi;
begin

  Result := HATA_YOK;

  s := KucukHarfeCevir(EtiketAdi);

  // etiket, bir sayı ile başlayamaz!
  if(s[1] in ['0'..'9']) then
  begin

    Result := HATA_ETIKET_TANIM;
    Exit;
  end;

  // etiket, işlem kodu veya yazmaç olamaz!
  Komut := KomutBilgisiAl(EtiketAdi);
  Yazmac := YazmacBilgisiAl(EtiketAdi);
  if(Komut.SiraNo >= 0) or (Yazmac.Sonuc >= 0) then
  begin

    Result := HATA_ETIKET_TANIM;
    Exit;
  end;

  // değişken 2 tip veri kullanır.
  // 1 = tvtSayi, 2 = tvtKarakterDizisi
  if(Toplam = 0) then
  begin

    Etiket := inherited Add as TAtama;
    Etiket.Adi := s;
    Etiket.Tip := AtamaTipi;

    if(AtamaTipi = etEtiket) then Etiket.BellekAdresi := BellekAdresi;

    Etiket.VeriTipi := VeriTipi;

    if(VeriTipi = tvtSayi) then
    begin

      SayiTipi := SayiTipiniAl(iDeger);
      case SayiTipi of
        //stHatali: Etiket.VeriUzunluk := 0;
        st1B: Etiket.VeriUzunluk := 1;
        st2B: Etiket.VeriUzunluk := 2;
        st4B: Etiket.VeriUzunluk := 4;
        st8B: Etiket.VeriUzunluk := 8;
      end;
      Etiket.iDeger := iDeger;
    end
    else if(VeriTipi = tvtKarakterDizisi) then
    begin

      Etiket.VeriUzunluk := Length(sDeger);
      Etiket.sDeger := sDeger;
    end;

    Etiket.SatirNo := SatirNo;
    Etiket.EtiketHatasiMevcut := GEtiketHatasiMevcut;
  end
  else
  begin

    Etiket := Bul(s);
    if(Etiket = nil) then
    begin

      Etiket := inherited Add as TAtama;
      Etiket.Adi := s;
      Etiket.Tip := AtamaTipi;

      if(AtamaTipi = etEtiket) then Etiket.BellekAdresi := BellekAdresi;

      Etiket.VeriTipi := VeriTipi;

      if(VeriTipi = tvtSayi) then
      begin

        SayiTipi := SayiTipiniAl(iDeger);
        case SayiTipi of
          //stHatali: Etiket.VeriUzunluk := 0;
          st1B: Etiket.VeriUzunluk := 1;
          st2B: Etiket.VeriUzunluk := 2;
          st4B: Etiket.VeriUzunluk := 4;
          st8B: Etiket.VeriUzunluk := 8;
        end;
        Etiket.iDeger := iDeger;
      end
      else if(VeriTipi = tvtKarakterDizisi) then
      begin

        Etiket.VeriUzunluk := Length(sDeger);
        Etiket.sDeger := sDeger;
      end;

      Etiket.SatirNo := SatirNo;
      Etiket.EtiketHatasiMevcut := GEtiketHatasiMevcut;
    end
    else
    begin

      // farklı bir satırdaki etiket, tanımlanmış bir etiketi tekrar tanımlamaya
      // çalışırsa geriye hata kodu döndür
      if(Etiket.SatirNo <> SatirNo) then Result := HATA_ETIKET_TANIMLANMIS;
    end;
  end;
end;

function TAtamaListesi.Bul(EtiketAdi: string): TAtama;
var
  i: Integer;
  s: string;
begin

  Result := nil;

  if(Toplam = 0) then Exit;

  s := KucukHarfeCevir(EtiketAdi);

  for i := 0 to Toplam - 1 do
  begin

    if(Eleman[i].Adi = s) then
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

// etiket veya tanım ataması yapılırken işleme dahil olunan etiket ve / veya tanım
// olmaması durumunda öndeğer sayısal değer kullanan etiketler tanımlama listesinden
// çıkarılıyor
function TAtamaListesi.Temizle2: Integer;
var
  i: Integer;
begin

  Result := 0;

  if(Toplam > 0) then
  begin

    for i := Toplam - 1 downto 0 do
    begin

      if(Eleman[i].EtiketHatasiMevcut) then
      begin

        Delete(i);
        Inc(Result);
      end;
    end;
  end;

  // hatalı etiket sayısının olmaması durumunda hatalı toplam etiket sayısını geri döndür
  if(Result = 0) then Result := GEtiketHataSayisi;
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

  Result := Count;
end;

end.
