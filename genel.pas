{-------------------------------------------------------------------------------

  Dosya: genel.pas

  İşlev: genel sabit, değişken, yapı ve işlevleri içerir

  Güncelleme Tarihi: 21/01/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit genel;

interface

uses Classes, SysUtils, etiket, matematik;

type
  TKomutTipi = (ktBilinmiyor, ktIslemKodu, ktAciklama, ktEtiket);
  TVeriTipi = (vtIslemKodu, vtSayi, vtVirgul);

type
  TParametreTipi = (ptYok, ptYazmac, ptBellek, ptSayisalDeger);

type
  TBilgiTipleri = (btBilgi, btUyari, btHata);
  TBilgi = record
    Tip: TBilgiTipleri;
    Kod: Integer;
    Aciklama: string;
  end;

const
  // 0 numaralı hata kodu, HataKodunuAl işlevinin kendisi için tanımlanmıştır.
  TOPLAM_BILGI = 6;
  HATA_BILINMEYEN_HATA_KODU = 0;
  HATA_BILINMEYEN_KOMUT = 1;
  HATA_BEKLENMEYEN_IFADE = 2;
  HATA_SAYISAL_DEGER_GEREKLI = 3;
  HATA_ETIKET_TANIMLANMIS = 4;
  HATA_KAPATMA_PAR_GEREKLI = 5;
  HATA_PAR_ONC_SAYISAL_DEGER = 6;

  sHATA_BILINMEYEN_HATA_KODU = 'Bilinmeyen hata kodu!';
  sHATA_BILINMEYEN_KOMUT = 'Bilinmeyen komut!';
  sHATA_BEKLENMEYEN_IFADE = 'Beklenmeyen ifade!';
  sHATA_SAYISAL_DEGER_GEREKLI = 'Sayısal değer gerekli!';
  sHATA_ETIKET_TANIMLANMIS = 'Etiket daha önce tanımlanmış!';
  sHATA_KAPATMA_PAR_GEREKLI = 'Kapatma '')'' parantezi gerekli!';
  sHATA_PAR_ONC_SAYISAL_DEGER = 'Parantez öncesi sayısal değer hatası!';

  BilgiDizisi: array[0..TOPLAM_BILGI] of TBilgi = (
    (Tip: btHata;   Kod: HATA_BILINMEYEN_HATA_KODU;   Aciklama: sHATA_BILINMEYEN_HATA_KODU),
    (Tip: btHata;   Kod: HATA_BILINMEYEN_KOMUT;       Aciklama: sHATA_BILINMEYEN_KOMUT),
    (Tip: btHata;   Kod: HATA_BEKLENMEYEN_IFADE;      Aciklama: sHATA_BEKLENMEYEN_IFADE),
    (Tip: btHata;   Kod: HATA_SAYISAL_DEGER_GEREKLI;  Aciklama: sHATA_SAYISAL_DEGER_GEREKLI),
    (Tip: btHata;   Kod: HATA_ETIKET_TANIMLANMIS;     Aciklama: sHATA_ETIKET_TANIMLANMIS),
    (Tip: btHata;   Kod: HATA_KAPATMA_PAR_GEREKLI;    Aciklama: sHATA_KAPATMA_PAR_GEREKLI),
    (Tip: btHata;   Kod: HATA_PAR_ONC_SAYISAL_DEGER;  Aciklama: sHATA_PAR_ONC_SAYISAL_DEGER)
  );

var
  GEtiketler: TEtiket;                // derleme aşamasındaki tüm etiketleri yönetir
  GMatematik: TMatematik;             // tüm çoklu matematiksel / mantıksal işlemleri yönetir
  GAciklama, GEtiket: string;
  GKomutTipi: TKomutTipi;
  GHataKodu: Integer;
  GHataAciklama: string;

  GParametreTip1: TParametreTipi;     // komutun birinci parametre tipi
  GParametreTip2: TParametreTipi;     // komutun ikinci parametre tipi
  GIslemKodu,                         // işlem kodunun (opcode) sıra değer karşılığı
  GYazmac1,                           // birinci yazmaç değeri
  GYazmac2,                           // ikinci yazmaç değeri
  GYazmac3,                           // üçüncü yazmaç değeri
  GBellekYazmacSayisi,                // bellek adresleyen yazmaç sayısı
  GOlcek,                             // bellek adreslemede kullanılan ölçek değer
  GSayisalDeger: Integer;             // bellek / yazmaç için sayısal değer
  P1, P2, P3: string;

function KucukHarfTR(s: string): string;
function HataKodunuAl(HataKodu: Integer): string;

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

end.
