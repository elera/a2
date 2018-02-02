{-------------------------------------------------------------------------------

  Dosya: genel.pas

  İşlev: genel sabit, değişken, yapı ve işlevleri içerir

  Güncelleme Tarihi: 30/01/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit genel;

interface

uses Classes, SysUtils, etiket, matematik;

type
  TKomutTipi = (ktBilinmiyor, ktIslemKodu, ktAciklama, ktEtiket);
  TVeriTipi = (vtYok, vtBosluk, vtIslemKodu, vtSayi, vtYazmac, vtKarakterDizisi,
    vtVirgul, vtArti, vtKPAc, vtKPKapat, vtOlcek, vtSon);
  TIslemKodDegiskenler = (ikdIslemKodY1, ikdIslemKodY2, ikdIslemKodB1, ikdIslemKodB2,
    ikdOlcek, ikdSabitDegerB, ikdSabitDeger);
  TIslemKodDegisken = set of TIslemKodDegiskenler;

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
  TOPLAM_HATA_BILGI_UYARI = 15;
  HATA_YOK = 0;
  HATA_BILINMEYEN_HATA_KODU = 1;
  HATA_BILINMEYEN_KOMUT = 2;
  HATA_BEKLENMEYEN_IFADE = 3;
  HATA_SAYISAL_DEGER_GEREKLI = 4;
  HATA_ETIKET_TANIMLANMIS = 5;
  HATA_KAPATMA_PAR_GEREKLI = 6;
  HATA_PAR_ONC_SAYISAL_DEGER = 7;
  HATA_HATALI_ISL_KULLANIM = 8;
  HATA_YAZMAC_GEREKLI = 9;
  HATA_OLCEK_ZATEN_KULLANILMIS = 10;
  HATA_HATALI_OLCEK_DEGER = 11;
  HATA_OLCEK_DEGER_GEREKLI = 12;
  HATA_HATALI_KULLANIM = 13;
  HATA_BELLEKTEN_BELLEGE = 14;
  HATA_HATALI_SAYISAL_DEGER = 15;

  sHATA_BILINMEYEN_HATA_KODU = 'Bilinmeyen hata kodu!';
  sHATA_BILINMEYEN_KOMUT = 'Bilinmeyen komut!';
  sHATA_BEKLENMEYEN_IFADE = 'Beklenmeyen ifade!';
  sHATA_SAYISAL_DEGER_GEREKLI = 'Sayısal değer gerekli!';
  sHATA_ETIKET_TANIMLANMIS = 'Etiket daha önce tanımlanmış!';
  sHATA_KAPATMA_PAR_GEREKLI = 'Kapatma '')'' parantezi gerekli!';
  sHATA_PAR_ONC_SAYISAL_DEGER = 'Parantez öncesi sayısal değer hatası!';
  sHATA_HATALI_ISL_KULLANIM = 'Hatalı işleyici kullanımı!';
  sHATA_YAZMAC_GEREKLI = 'Yazmaç gerekli!';
  sHATA_OLCEK_ZATEN_KULLANILMIS = 'Ölçek değer zaten kullanılmış!';
  sHATA_HATALI_OLCEK_DEGER = 'Hatalı ölçek değer!';
  sHATA_OLCEK_DEGER_GEREKLI = 'Ölçek değer gerekli!';
  sHATA_HATALI_KULLANIM = 'İşlem kodu hatalı kullanılmakta!';
  sHATA_BELLEKTEN_BELLEGE = 'Bellek bölgesinde diğer bellek bölgesine atama yapamazsınız!';
  sHATA_HATALI_SAYISAL_DEGER = 'Hatalı sayısal değer!';

  BilgiDizisi: array[1..TOPLAM_HATA_BILGI_UYARI] of TBilgi = (
    (Tip: btHata;   Kod: HATA_BILINMEYEN_HATA_KODU;   Aciklama: sHATA_BILINMEYEN_HATA_KODU),
    (Tip: btHata;   Kod: HATA_BILINMEYEN_KOMUT;       Aciklama: sHATA_BILINMEYEN_KOMUT),
    (Tip: btHata;   Kod: HATA_BEKLENMEYEN_IFADE;      Aciklama: sHATA_BEKLENMEYEN_IFADE),
    (Tip: btHata;   Kod: HATA_SAYISAL_DEGER_GEREKLI;  Aciklama: sHATA_SAYISAL_DEGER_GEREKLI),
    (Tip: btHata;   Kod: HATA_ETIKET_TANIMLANMIS;     Aciklama: sHATA_ETIKET_TANIMLANMIS),
    (Tip: btHata;   Kod: HATA_KAPATMA_PAR_GEREKLI;    Aciklama: sHATA_KAPATMA_PAR_GEREKLI),
    (Tip: btHata;   Kod: HATA_PAR_ONC_SAYISAL_DEGER;  Aciklama: sHATA_PAR_ONC_SAYISAL_DEGER),
    (Tip: btHata;   Kod: HATA_HATALI_ISL_KULLANIM;    Aciklama: sHATA_HATALI_ISL_KULLANIM),
    (Tip: btHata;   Kod: HATA_YAZMAC_GEREKLI;         Aciklama: sHATA_YAZMAC_GEREKLI),
    (Tip: btHata;   Kod: HATA_OLCEK_ZATEN_KULLANILMIS;Aciklama: sHATA_OLCEK_ZATEN_KULLANILMIS),
    (Tip: btHata;   Kod: HATA_HATALI_OLCEK_DEGER;     Aciklama: sHATA_HATALI_OLCEK_DEGER),
    (Tip: btHata;   Kod: HATA_OLCEK_DEGER_GEREKLI;    Aciklama: sHATA_OLCEK_DEGER_GEREKLI),
    (Tip: btHata;   Kod: HATA_HATALI_KULLANIM;        Aciklama: sHATA_HATALI_KULLANIM),
    (Tip: btHata;   Kod: HATA_BELLEKTEN_BELLEGE;      Aciklama: sHATA_BELLEKTEN_BELLEGE),
    (Tip: btHata;   Kod: HATA_HATALI_SAYISAL_DEGER;   Aciklama: sHATA_HATALI_SAYISAL_DEGER)
  );

var
  GEtiketler: TEtiket;                      // derleme aşamasındaki tüm etiketleri yönetir
  GMatematik: TMatematik;                   // tüm çoklu matematiksel / mantıksal işlemleri yönetir
  GAciklama, GEtiket: string;
  GKomutTipi: TKomutTipi;
  GHataKodu: Integer;
  GHataAciklama: string;
  GIslemKodDegisken: TIslemKodDegisken;     // her bir satır içerisinde tanımlanan değişken değerleri
  GSonIslenenVeriTipi: TVeriTipi;           // en son işlenen veri tipini içerir

  // GENEL BİLGİ:
  // 1. her bir kod satırı, 2 öndeğeri (parametre) işleyecek şekilde yapılandırılmıştır
  //   bunlar; GParametreTip1 ve GParametreTip2 değişkenleri tarafından yönetilir
  // 2. her bir komut satırının (opcode) GIslemKodu değişkeni ile ifade edilen sıra numarası vardır
  // 3. her 2 öndeğerin yazmaç olması halinde GYazmac1 ve GYazmac2 değişkenleri kullanılırken;
  //   adresleme işleminin olması durumunda GYazmac1, GYazmacB1 ve GYazmacB2 kullanımaktadır
  GParametreTip1: TParametreTipi;           // komutun birinci parametre tipi
  GParametreTip2: TParametreTipi;           // komutun ikinci parametre tipi
  GIslemKodu,                               // işlem kodunun (opcode) sıra değer karşılığı
  GYazmac1,                                 // birinci yazmaç değeri
  GYazmac2,                                 // ikinci yazmaç değeri
  GYazmacB1,                                // birinci bellek yazmaç değeri
  GYazmacB2,                                // ikinci bellek yazmaç değeri
  GOlcek,                                   // bellek adreslemede kullanılan ölçek değer
  GSabitDeger: Integer;                     // bellek / yazmaç için sayısal değer
  GYazmacB1OlcekM, GYazmacB2OlcekM: Boolean;// bellek yazmaçlarının ölçek değerleri var mı?

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

  if(HataKodu > TOPLAM_HATA_BILGI_UYARI) then HataKodu := HATA_BILINMEYEN_HATA_KODU;
  Result := BilgiDizisi[HataKodu].Aciklama;
end;

end.
