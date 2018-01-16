{-------------------------------------------------------------------------------

  Dosya: genel.pas
  İşlev: genel sabit, değişken, yapı ve işlevleri içerir
  Tarih: 13/01/2018
  Bilgi:

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit genel;

interface

uses Classes, SysUtils, etiket;

type
  TKomutTipi = (ktBilinmiyor, ktIslemKodu, ktAciklama, ktEtiket);

type
  TParametreTipi = (ptYok, ptYazmac, ptBellek);

type
  TBilgiTipleri = (btBilgi, btUyari, btHata);
  TBilgi = record
    Tip: TBilgiTipleri;
    Kod: Integer;
    Aciklama: string;
  end;

const
  // 0 numaralı hata kodu, HataKodunuAl işlevinin kendisi için tanımlanmıştır.
  TOPLAM_BILGI = 4;
  HATA_BILINMEYEN_HATA_KODU = 0;
  HATA_BILINMEYEN_KOMUT = 1;
  HATA_BEKLENMEYEN_IFADE = 2;
  HATA_SAYISAL_DEGER_GEREKLI = 3;
  HATA_ETIKET_TANIMLANMIS = 4;

  sHATA_BILINMEYEN_HATA_KODU = 'Bilinmeyen hata kodu!';
  sHATA_BILINMEYEN_KOMUT = 'Bilinmeyen komut!';
  sHATA_BEKLENMEYEN_IFADE = 'Beklenmeyen ifade!';
  sHATA_SAYISAL_DEGER_GEREKLI = 'Sayısal değer gerekli!';
  sHATA_ETIKET_TANIMLANMIS = 'Etiket daha önce tanımlanmış!';

  BilgiDizisi: array[0..TOPLAM_BILGI] of TBilgi = (
    (Tip: btHata;   Kod: HATA_BILINMEYEN_HATA_KODU;   Aciklama: sHATA_BILINMEYEN_HATA_KODU),
    (Tip: btHata;   Kod: HATA_BILINMEYEN_KOMUT;       Aciklama: sHATA_BILINMEYEN_KOMUT),
    (Tip: btHata;   Kod: HATA_BEKLENMEYEN_IFADE;      Aciklama: sHATA_BEKLENMEYEN_IFADE),
    (Tip: btHata;   Kod: HATA_SAYISAL_DEGER_GEREKLI;  Aciklama: sHATA_SAYISAL_DEGER_GEREKLI),
    (Tip: btHata;   Kod: HATA_ETIKET_TANIMLANMIS;     Aciklama: sHATA_ETIKET_TANIMLANMIS));

var
  GEtiketler: TEtiket;
  GAciklama, GEtiket: string;
  GKomutTipi: TKomutTipi;
  GHataKodu: Integer;
  GHataAciklama: string;

function KucukHarfTR(s: string): string;
function HataKodunuAl(HataKodu: Integer): string;
function VeriSayiMi(Deger: string): Boolean;

implementation

// karakter dizisini türkçe küçük harfe çevirir
{ TODO : işlev henüz tamamlanmamıştır }
function KucukHarfTR(s: string): string;
begin

  Result := LowerCase(s);
end;

// hata kodunun karakter dizi karşılığını geri döndürür
function HataKodunuAl(HataKodu: Integer): string;
begin

  if(HataKodu > TOPLAM_BILGI) then HataKodu := HATA_BILINMEYEN_HATA_KODU;
  Result := BilgiDizisi[HataKodu].Aciklama;
end;

// karakter dizisinin sayısal bir değer olup olmadığını test eder
function VeriSayiMi(Deger: string): Boolean;
begin

  Result := True;
  try
    StrToInt(Deger);
  except
    Result := False;
  end;
end;

end.
