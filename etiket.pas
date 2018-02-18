{-------------------------------------------------------------------------------

  Dosya: etiket.pas

  İşlev: proje içerisindeki etiketleri (label) yönetir

  Güncelleme Tarihi: 09/02/2018

  Bilgi: etiket işlemlerinde etiketlerin isimlendirmesi, küçük harflerle yapılmaktadır.

  1. "büyük harf, küçük harf, büyük-küçük karışık harf, UTF-8 karakterlerin tümü",
    küçük harf olarak işlem görmektedir.
  2. isimlendirme mekanizması, türkçe harflerin rahatça kullanılabilmesi için tasarlanmıştır

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit etiket;

interface

uses Classes, SysUtils;

type
  TEtiket = class(TCollectionItem)
  private
    FAdi: string;
    FBellekAdresi: QWord;
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
  published
    property Adi: string read FAdi write FAdi;
    property BellekAdresi: QWord read FBellekAdresi write FBellekAdresi;
  end;

  TEtiketler = class(TCollection)
  private
    function Al(ASiraNo: Integer): TEtiket;
    procedure Ver(ASiraNo: Integer; AEtiket: TEtiket);
    function GetToplam: Integer;
  public
    constructor Create;
  public
    function Ekle(AEtiketAdi: string; ABellekAdresi: QWord): Integer;
    function Bul(AEtiketAdi: string; var ABellekAdresi: QWord): Boolean;
    procedure Temizle;
    property Toplam: Integer read GetToplam;
    property Eleman[Sira: Integer]: TEtiket read Al write Ver;
  end;

implementation

uses genel, donusum, yazmaclar, komutlar;

constructor TEtiket.Create(ACollection: TCollection);
begin

  inherited Create(ACollection);
end;

destructor TEtiket.Destroy;
begin

  inherited Destroy;
end;

constructor TEtiketler.Create;
begin

  inherited Create(TEtiket);
end;

function TEtiketler.Ekle(AEtiketAdi: string; ABellekAdresi: QWord): Integer;
var
  i: Integer;
  s: string;
  Etiket: TEtiket;
  Komut: TKomutDurum;
  Yazmac: TYazmacDurum;
begin

  Result := HATA_YOK;

  s := KucukHarfeCevir(AEtiketAdi);

  // etiket, bir sayı ile başlayamaz!
  if(s[1] in ['0'..'9']) then
  begin

    Result := HATA_ETIKET_TANIM;
    Exit;
  end;

  // etiket, işlem kodu veya yazmaç olamaz!
  Komut := KomutBilgisiAl(AEtiketAdi);
  Yazmac := YazmacBilgisiAl(AEtiketAdi);
  if(Komut.SiraNo >= 0) or (Yazmac.Sonuc >= 0) then
  begin

    Result := HATA_ETIKET_TANIM;
    Exit;
  end;

  if(Toplam = 0) then
  begin

    Etiket := inherited Add as TEtiket;
    Etiket.Adi := s;
    Etiket.BellekAdresi := ABellekAdresi;
  end
  else
  begin

    for i := 0 to Toplam - 1 do
    begin

      if(Eleman[i].Adi = s) then
      begin

        Result := HATA_ETIKET_TANIMLANMIS;
        Exit;
      end;
    end;

    Etiket := inherited Add as TEtiket;
    Etiket.Adi := s;
    Etiket.BellekAdresi := ABellekAdresi;
  end;
end;

function TEtiketler.Bul(AEtiketAdi: string; var ABellekAdresi: QWord): Boolean;
var
  i: Integer;
  s: string;
begin

  Result := False;

  s := KucukHarfeCevir(AEtiketAdi);

  for i := 0 to Toplam - 1 do
  begin

    if(Eleman[i].Adi = s) then
    begin

      ABellekAdresi := Eleman[i].BellekAdresi;
      Result := True;
      Exit;
    end;
  end;
end;

procedure TEtiketler.Temizle;
begin

  inherited Clear;
end;

function TEtiketler.Al(ASiraNo: Integer): TEtiket;
begin

  Result := TEtiket(inherited GetItem(ASiraNo));
end;

procedure TEtiketler.Ver(ASiraNo: Integer; AEtiket: TEtiket);
begin

  inherited SetItem(ASiraNo, AEtiket);
end;

function TEtiketler.GetToplam: Integer;
begin

  Result := Count;
end;

end.
