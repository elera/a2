{-------------------------------------------------------------------------------

  Dosya: genel.pas

  İşlev: genel sabit, değişken, yapı ve işlevleri içerir

  Güncelleme Tarihi: 31/03/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit genel;

interface

uses Classes, SysUtils, Forms, asm2, ayarlar, paylasim;

const
  ProgramAdi = 'Assembler 2 (a2)';
  ProgramSurum = '0.0.11.2018';
  SurumTarihi = '31.03.2018';

type
  TBilgiTipleri = (btBilgi, btUyari, btHata);
  TBilgi = record
    Tip: TBilgiTipleri;
    Kod: Integer;
    Aciklama: string;
  end;

const
  // 0 numaralı hata kodu, HataKodunuAl işlevinin kendisi için tanımlanmıştır.
  TOPLAM_HATA_BILGI_UYARI = 26;

  HATA_YOK = 0;
  HATA_BILINMEYEN_HATA            = HATA_YOK + 1;
  HATA_BILINMEYEN_KOMUT           = HATA_BILINMEYEN_HATA + 1;
  HATA_BILINMEYEN_BILDIRIM        = HATA_BILINMEYEN_KOMUT + 1;
  HATA_BEKLENMEYEN_IFADE          = HATA_BILINMEYEN_BILDIRIM + 1;
  HATA_SAYISAL_DEGER_GEREKLI      = HATA_BEKLENMEYEN_IFADE + 1;
  HATA_ETIKET_TANIMLANMIS         = HATA_SAYISAL_DEGER_GEREKLI + 1;
  HATA_ETIKET_TANIMLANMAMIS       = HATA_ETIKET_TANIMLANMIS + 1;
  HATA_ETIKET_TANIM               = HATA_ETIKET_TANIMLANMAMIS + 1;
  HATA_BIRDEN_FAZLA_ETIKET        = HATA_ETIKET_TANIM + 1;
  HATA_KAPATMA_PAR_GEREKLI        = HATA_BIRDEN_FAZLA_ETIKET + 1;
  HATA_PAR_ONC_SAYISAL_DEGER      = HATA_KAPATMA_PAR_GEREKLI + 1;
  HATA_ISL_KULLANIM               = HATA_PAR_ONC_SAYISAL_DEGER + 1;
  HATA_YAZMAC_GEREKLI             = HATA_ISL_KULLANIM + 1;
  HATA_OLCEK_ZATEN_KULLANILMIS    = HATA_YAZMAC_GEREKLI + 1;
  HATA_OLCEK_DEGER                = HATA_OLCEK_ZATEN_KULLANILMIS + 1;
  HATA_OLCEK_DEGER_GEREKLI        = HATA_OLCEK_DEGER + 1;
  HATA_ISL_KOD_KULLANIM           = HATA_OLCEK_DEGER_GEREKLI + 1;
  HATA_BELLEKTEN_BELLEGE          = HATA_ISL_KOD_KULLANIM + 1;
  HATA_SAYISAL_DEGER              = HATA_BELLEKTEN_BELLEGE + 1;
  HATA_VERI_TIPI                  = HATA_SAYISAL_DEGER + 1;
  HATA_BILINMEYEN_MIMARI          = HATA_VERI_TIPI + 1;
  HATA_HATALI_MIMARI64            = HATA_BILINMEYEN_MIMARI + 1;
  HATA_64BIT_MIMARI_GEREKLI       = HATA_HATALI_MIMARI64 + 1;
  HATA_BILD_KULLANIM              = HATA_64BIT_MIMARI_GEREKLI + 1;
  HATA_TANIM_KULLANIM             = HATA_BILD_KULLANIM + 1;
  HATA_TANIMLAMA                  = HATA_TANIM_KULLANIM + 1;
  HATA_DEVAM_EDEN_CALISMA         = HATA_TANIMLAMA + 1;

  sHATA_BILINMEYEN_HATA           = 'Bilinmeyen hata';
  sHATA_BILINMEYEN_KOMUT          = 'Bilinmeyen komut';
  sHATA_BILINMEYEN_BILDIRIM       = 'Bilinmeyen bildirim';
  sHATA_BEKLENMEYEN_IFADE         = 'Beklenmeyen ifade';
  sHATA_SAYISAL_DEGER_GEREKLI     = 'Sayısal değer gerekli';
  sHATA_ETIKET_TANIMLANMIS        = 'Etiket daha önce tanımlanmış';
  sHATA_ETIKET_TANIMLANMAMIS      = 'Etiket tanımlanmamış';
  sHATA_ETIKET_TANIM              = 'Etiket, etiket tanımlama kurallarına uygun değil';
  sHATA_BIRDEN_FAZLA_ETIKET       = 'Aynı satırda birden fazla etiket tanımlayamazsınız';
  sHATA_KAPATMA_PAR_GEREKLI       = 'Kapatma '')'' parantezi gerekli';
  sHATA_PAR_ONC_SAYISAL_DEGER     = 'Parantez öncesi sayısal değer hatası';
  sHATA_ISL_KULLANIM              = 'Hatalı işleyici kullanımı';
  sHATA_YAZMAC_GEREKLI            = 'Yazmaç gerekli';
  sHATA_OLCEK_ZATEN_KULLANILMIS   = 'Ölçek değer zaten kullanılmış';
  sHATA_OLCEK_DEGER               = 'Hatalı ölçek değer';
  sHATA_OLCEK_DEGER_GEREKLI       = 'Ölçek değer gerekli';
  sHATA_ISL_KOD_KULLANIM          = 'İşlem kodu hatalı kullanılmakta';
  sHATA_BELLEKTEN_BELLEGE         = 'Bellek bölgesinde diğer bellek bölgesine atama yapamazsınız';
  sHATA_SAYISAL_DEGER             = 'Hatalı sayısal değer';
  sHATA_VERI_TIPI                 = 'Veri tipi hatalı';
  sHATA_BILINMEYEN_MIMARI         = 'Bilinmeyen mimari';
  sHATA_HATALI_MIMARI64           = 'Bu işlem kodunu 64 bitlik mimaride kullanamazsınız';
  sHATA_64BIT_MIMARI_GEREKLI      = 'Bu komut SADECE 64 bitlik mimaride kullanılabilir';
  sHATA_BILD_KULLANIM             = 'Hatalı bildirim kullanımı';
  sHATA_TANIM_KULLANIM            = 'Hatalı tanım kullanımı';
  sHATA_TANIMLAMA                 = 'Hatalı tanımlama';
  sHATA_DEVAM_EDEN_CALISMA        = 'Çalışmalar devam etmekte...';

const
  BilgiDizisi: array[1..TOPLAM_HATA_BILGI_UYARI] of TBilgi = (
    (Tip: btHata;   Kod: HATA_BILINMEYEN_HATA;        Aciklama: sHATA_BILINMEYEN_HATA),
    (Tip: btHata;   Kod: HATA_BILINMEYEN_KOMUT;       Aciklama: sHATA_BILINMEYEN_KOMUT),
    (Tip: btHata;   Kod: HATA_BILINMEYEN_BILDIRIM;    Aciklama: sHATA_BILINMEYEN_BILDIRIM),
    (Tip: btHata;   Kod: HATA_BEKLENMEYEN_IFADE;      Aciklama: sHATA_BEKLENMEYEN_IFADE),
    (Tip: btHata;   Kod: HATA_SAYISAL_DEGER_GEREKLI;  Aciklama: sHATA_SAYISAL_DEGER_GEREKLI),
    (Tip: btHata;   Kod: HATA_ETIKET_TANIMLANMIS;     Aciklama: sHATA_ETIKET_TANIMLANMIS),
    (Tip: btHata;   Kod: HATA_ETIKET_TANIMLANMAMIS;   Aciklama: sHATA_ETIKET_TANIMLANMAMIS),
    (Tip: btHata;   Kod: HATA_ETIKET_TANIM;           Aciklama: sHATA_ETIKET_TANIM),
    (Tip: btHata;   Kod: HATA_BIRDEN_FAZLA_ETIKET;    Aciklama: sHATA_BIRDEN_FAZLA_ETIKET),
    (Tip: btHata;   Kod: HATA_KAPATMA_PAR_GEREKLI;    Aciklama: sHATA_KAPATMA_PAR_GEREKLI),
    (Tip: btHata;   Kod: HATA_PAR_ONC_SAYISAL_DEGER;  Aciklama: sHATA_PAR_ONC_SAYISAL_DEGER),
    (Tip: btHata;   Kod: HATA_ISL_KULLANIM;           Aciklama: sHATA_ISL_KULLANIM),
    (Tip: btHata;   Kod: HATA_YAZMAC_GEREKLI;         Aciklama: sHATA_YAZMAC_GEREKLI),
    (Tip: btHata;   Kod: HATA_OLCEK_ZATEN_KULLANILMIS;Aciklama: sHATA_OLCEK_ZATEN_KULLANILMIS),
    (Tip: btHata;   Kod: HATA_OLCEK_DEGER;            Aciklama: sHATA_OLCEK_DEGER),
    (Tip: btHata;   Kod: HATA_OLCEK_DEGER_GEREKLI;    Aciklama: sHATA_OLCEK_DEGER_GEREKLI),
    (Tip: btHata;   Kod: HATA_ISL_KOD_KULLANIM;       Aciklama: sHATA_ISL_KOD_KULLANIM),
    (Tip: btHata;   Kod: HATA_BELLEKTEN_BELLEGE;      Aciklama: sHATA_BELLEKTEN_BELLEGE),
    (Tip: btHata;   Kod: HATA_SAYISAL_DEGER;          Aciklama: sHATA_SAYISAL_DEGER),
    (Tip: btHata;   Kod: HATA_VERI_TIPI;              Aciklama: sHATA_VERI_TIPI),
    (Tip: btHata;   Kod: HATA_BILINMEYEN_MIMARI;      Aciklama: sHATA_BILINMEYEN_MIMARI),
    (Tip: btHata;   Kod: HATA_HATALI_MIMARI64;        Aciklama: sHATA_HATALI_MIMARI64),
    (Tip: btHata;   Kod: HATA_64BIT_MIMARI_GEREKLI;   Aciklama: sHATA_64BIT_MIMARI_GEREKLI),
    (Tip: btHata;   Kod: HATA_BILD_KULLANIM;          Aciklama: sHATA_BILD_KULLANIM),
    (Tip: btHata;   Kod: HATA_TANIM_KULLANIM;         Aciklama: sHATA_TANIM_KULLANIM),
    (Tip: btHata;   Kod: HATA_TANIMLAMA;              Aciklama: sHATA_TANIMLAMA)
  );

var
  GAsm2: TAsm2;                             // derleyici ana nesnesi
  GProgramAyarDizin: string;                // program ayar dizinini içerir
  GProgramCalismaDizin: string;             // programın çalıştığı dizin
  GProgramAyarlari: TProgramAyarlari;       // program ayar değerlerini içerir
  MevcutBellekAdresi: Integer;
  KodBellek: array[0..4095] of Byte;
  KodBellekU: Integer;
  GAciklama,                                // her bir satır için tanımlanan açıklama
  GEtiket,                                  // her bir satır için tanımlanan etiket
  // ("bellek db 10" örneğinde bellek değeri) değişken ilk değeri veya
  // ("bellek = 10" örneğinde bellek değeri) tanım ilk değeri
  GTanimlanacakVeri: string;
  GHataKodu: Integer;
  GHataAciklama: string;

  // tüm satır verilerini içerecek ana değer
  SatirIcerik: TSatirIcerik;

  // GENEL BİLGİ:
  // 1. her bir kod satırı, 2 öndeğeri (parametre) işleyecek şekilde yapılandırılmıştır
  //   bunlar; GParametreTip1 ve GParametreTip2 değişkenleri tarafından yönetilir
  // 2. her bir komut satırının (opcode) GIslemKodu değişkeni ile ifade edilen sıra numarası vardır
  // 3. her 2 öndeğerin yazmaç olması halinde GYazmac1 ve GYazmac2 değişkenleri kullanılırken;
  //   adresleme işleminin olması durumunda GYazmac1, GYazmacB1 ve GYazmacB2 kullanımaktadır
  GYazmac1,                                 // birinci yazmaç değeri
  GYazmac2,                                 // ikinci yazmaç değeri
  GYazmacB1,                                // birinci bellek yazmaç değeri
  GYazmacB2,                                // ikinci bellek yazmaç değeri
  GOlcek,                                   // bellek adreslemede kullanılan ölçek değer
  GBellekSabitDeger,                        // bellek adresleme sabit değeri (yeni, ilgili kısımlara uygulansın)
  GSabitDeger: Integer;                     // bellek / yazmaç için sayısal değer
  GYazmacB1OlcekM, GYazmacB2OlcekM: Boolean;// bellek yazmaçlarının ölçek değerleri var mı?

  // -------------------------------------------------------------------------->
  // etiket veya tanım ataması yapılırken işleme dahil olunan etiket ve / veya tanım
  // olmaması durumunda, öndeğer sayısal değer kullanımında bu değişken aktifleştirilerek
  // tekrarlı döngülerin sağlanması amaçlanmaktadır
  GEtiketHatasiMevcut: Boolean;
  // bir çevrim döngüsü içerisinde, o anda karşılığı olmayan etiket sayısı
  // birden fazla çevrimleri kontrol edilmesi amacıyla tasarlanmıştır.
  GEtiketHataSayisi: Integer;
  // <--------------------------------------------------------------------------

function HataKodunuAl(HataKodu: Integer): string;

implementation

uses kodlama;

// hata kodunun karakter dizi karşılığını geri döndürür
function HataKodunuAl(HataKodu: Integer): string;
begin

  if(HataKodu > TOPLAM_HATA_BILGI_UYARI) then HataKodu := HATA_BILINMEYEN_HATA;
  Result := BilgiDizisi[HataKodu].Aciklama;
end;

end.
