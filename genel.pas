{-------------------------------------------------------------------------------

  Dosya: genel.pas

  İşlev: genel sabit, değişken, yapı ve işlevleri içerir

  Güncelleme Tarihi: 18/02/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit genel;

interface

uses Classes, SysUtils, Forms, etiket, matematik, asm2, ayarlar;

const
  ProgramAdi = 'Assembler 2 (a2)';
  ProgramSurum = '0.0.8.2018';
  SurumTarihi = '18.02.2018';

type
  // her bir satırın veri tipi.
  // not: abvtBuyukYapi (makrolar) ileride tanımlanabilir - 03.02.2018
  TAnaBolumVeriTipi = (abvtBelirsiz, abvtIslemKodu, abvtTanim, abvtBildirim);

  // alt satırdaki veriler TAnaBolumVeriTipi içerisinde yok edilecek
  // işlem kod ana ve alt bölümleri
  TIslemKodAnaBolumler = (ikabEtiket, ikabAciklama);
  TIslemKodAnaBolum = set of TIslemKodAnaBolumler;


  TIslemKodAyrintilar = (ikaIslemKodY1, ikaIslemKodY2, ikaIslemKodB1, ikaIslemKodB2,
    ikaOlcek, ikaSabitDegerB, ikaSabitDeger);
  TIslemKodAyrinti = set of TIslemKodAyrintilar;
  TIKABVeriTipi = (vtYok, vtYazmac, vtBellek, vtSayisalDeger);
  // vktKEKarakterDizisi = yazmaç, işlem kodu vb değerlerle kontrol edilecek karakter dizisi
  // vktKarakterDizisi = kontrole gerek olmayan karakter dizisi
  TVeriKontrolTip = (vktYok, vktKEKarakterDizisi, vktKarakterDizisi, vktSayi, {vktIslemKodu, vktTanim,}
    vktYazmac, vktBosluk, vktVirgul, vktEsittir, vktArti, vktKPAc, vktKPKapat, vktOlcek, vktIlk, vktSon);

  // etiket kod ana ve alt bölümleri
  TTanimAnaBolumler = (tabEtiket, tabEtiketAdi, tabAciklama);
  TTanimAnaBolum = set of TTanimAnaBolumler;

  TSayiTipi = (stHatali, st1B, st2B, st4B, st8B);

type
  TBilgiTipleri = (btBilgi, btUyari, btHata);
  TBilgi = record
    Tip: TBilgiTipleri;
    Kod: Integer;
    Aciklama: string;
  end;

const
  // 0 numaralı hata kodu, HataKodunuAl işlevinin kendisi için tanımlanmıştır.
  TOPLAM_HATA_BILGI_UYARI = 23;

  HATA_YOK = 0;
  HATA_BILINMEYEN_HATA = 1;
  HATA_BILINMEYEN_KOMUT = 2;
  HATA_BILINMEYEN_BILDIRIM = 3;
  HATA_BEKLENMEYEN_IFADE = 4;
  HATA_SAYISAL_DEGER_GEREKLI = 5;
  HATA_ETIKET_TANIMLANMIS = 6;
  HATA_ETIKET_TANIM = 7;
  HATA_BIRDEN_FAZLA_ETIKET = 8;
  HATA_KAPATMA_PAR_GEREKLI = 9;
  HATA_PAR_ONC_SAYISAL_DEGER = 10;
  HATA_ISL_KULLANIM = 11;
  HATA_YAZMAC_GEREKLI = 12;
  HATA_OLCEK_ZATEN_KULLANILMIS = 13;
  HATA_OLCEK_DEGER = 14;
  HATA_OLCEK_DEGER_GEREKLI = 15;
  HATA_ISL_KOD_KULLANIM = 16;
  HATA_BELLEKTEN_BELLEGE = 17;
  HATA_SAYISAL_DEGER = 18;
  HATA_VERI_TIPI = 19;
  HATA_BILINMEYEN_MIMARI = 20;
  HATA_HATALI_MIMARI64 = 21;
  HATA_BILDIRIM_KULLANIM = 22;
  HATA_TANIMLAMA = 23;

  sHATA_BILINMEYEN_HATA = 'Bilinmeyen hata';
  sHATA_BILINMEYEN_KOMUT = 'Bilinmeyen komut';
  sHATA_BILINMEYEN_BILDIRIM = 'Bilinmeyen bildirim';
  sHATA_BEKLENMEYEN_IFADE = 'Beklenmeyen ifade';
  sHATA_SAYISAL_DEGER_GEREKLI = 'Sayısal değer gerekli';
  sHATA_ETIKET_TANIMLANMIS = 'Etiket daha önce tanımlanmış';
  sHATA_ETIKET_TANIM = 'Etiket, etiket tanımlama kurallarına uygun değil';
  sHATA_BIRDEN_FAZLA_ETIKET = 'Aynı satırda birden fazla etiket tanımlayamazsınız';
  sHATA_KAPATMA_PAR_GEREKLI = 'Kapatma '')'' parantezi gerekli';
  sHATA_PAR_ONC_SAYISAL_DEGER = 'Parantez öncesi sayısal değer hatası';
  sHATA_ISL_KULLANIM = 'Hatalı işleyici kullanımı';
  sHATA_YAZMAC_GEREKLI = 'Yazmaç gerekli';
  sHATA_OLCEK_ZATEN_KULLANILMIS = 'Ölçek değer zaten kullanılmış';
  sHATA_OLCEK_DEGER = 'Hatalı ölçek değer';
  sHATA_OLCEK_DEGER_GEREKLI = 'Ölçek değer gerekli';
  sHATA_ISL_KOD_KULLANIM = 'İşlem kodu hatalı kullanılmakta';
  sHATA_BELLEKTEN_BELLEGE = 'Bellek bölgesinde diğer bellek bölgesine atama yapamazsınız';
  sHATA_SAYISAL_DEGER = 'Hatalı sayısal değer';
  sHATA_VERI_TIPI = 'Veri tipi hatalı';
  sHATA_BILINMEYEN_MIMARI = 'Bilinmeyen mimari';
  sHATA_HATALI_MIMARI64 = 'Bu işlem kodunu 64 bitlik mimaride kullanamazsınız';
  sHATA_BILDIRIM_KULLANIM = 'Hatalı bildirim kullanımı';
  sHATA_TANIMLAMA = 'Hatalı tanımlama';

  BilgiDizisi: array[1..TOPLAM_HATA_BILGI_UYARI] of TBilgi = (
    (Tip: btHata;   Kod: HATA_BILINMEYEN_HATA;        Aciklama: sHATA_BILINMEYEN_HATA),
    (Tip: btHata;   Kod: HATA_BILINMEYEN_KOMUT;       Aciklama: sHATA_BILINMEYEN_KOMUT),
    (Tip: btHata;   Kod: HATA_BILINMEYEN_BILDIRIM;    Aciklama: sHATA_BILINMEYEN_BILDIRIM),
    (Tip: btHata;   Kod: HATA_BEKLENMEYEN_IFADE;      Aciklama: sHATA_BEKLENMEYEN_IFADE),
    (Tip: btHata;   Kod: HATA_SAYISAL_DEGER_GEREKLI;  Aciklama: sHATA_SAYISAL_DEGER_GEREKLI),
    (Tip: btHata;   Kod: HATA_ETIKET_TANIMLANMIS;     Aciklama: sHATA_ETIKET_TANIMLANMIS),
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
    (Tip: btHata;   Kod: HATA_BILDIRIM_KULLANIM;      Aciklama: sHATA_BILDIRIM_KULLANIM),
    (Tip: btHata;   Kod: HATA_TANIMLAMA;              Aciklama: sHATA_TANIMLAMA)
  );

var
  GAsm2: TAsm2;                             // derleyici ana nesnesi
  GProgramAyarDizin: string;                // program ayar dizinini içerir
  GProgramAyarlari: TProgramAyarlari;       // program ayar değerlerini içerir
  MevcutBellekAdresi: Integer;
  KodBellek: array[0..4095] of Byte;
  KodBellekU: Integer;
  GMatematik: TMatematik;                   // tüm çoklu matematiksel / mantıksal işlemleri yönetir
  GAciklama,                                // her bir satır için tanımlanan açıklama
  GEtiket,                                  // her bir satır için tanımlanan etiket
  GTanimEtiket: string;                     // dx (db, dd..) veri öncesi için yapılan tanım etiketi
  GAnaBolumVeriTipi: TAnaBolumVeriTipi;     // her bir satırın veri tipi
  GIslemKodAnaBolum: TIslemKodAnaBolum;     // her bir işlem kodunun ana bölümleri
  GIslemKodAyrinti: TIslemKodAyrinti;       // her bir işlem kod içerisinde tanımlı diğer ayrıntılar
  GHataKodu: Integer;
  GHataAciklama: string;

  // GENEL BİLGİ:
  // 1. her bir kod satırı, 2 öndeğeri (parametre) işleyecek şekilde yapılandırılmıştır
  //   bunlar; GParametreTip1 ve GParametreTip2 değişkenleri tarafından yönetilir
  // 2. her bir komut satırının (opcode) GIslemKodu değişkeni ile ifade edilen sıra numarası vardır
  // 3. her 2 öndeğerin yazmaç olması halinde GYazmac1 ve GYazmac2 değişkenleri kullanılırken;
  //   adresleme işleminin olması durumunda GYazmac1, GYazmacB1 ve GYazmacB2 kullanımaktadır
  GIKABVeriTipi1: TIKABVeriTipi;            // işlem kodunun birinci parametre tipi
  GIKABVeriTipi2: TIKABVeriTipi;            // işlem kodunun ikinci parametre tipi
  GIslemKodu,                               // işlem kodunun (opcode) sıra değer karşılığı
  GYazmac1,                                 // birinci yazmaç değeri
  GYazmac2,                                 // ikinci yazmaç değeri
  GYazmacB1,                                // birinci bellek yazmaç değeri
  GYazmacB2,                                // ikinci bellek yazmaç değeri
  GOlcek,                                   // bellek adreslemede kullanılan ölçek değer
  GSabitDeger: Integer;                     // bellek / yazmaç için sayısal değer
  GYazmacB1OlcekM, GYazmacB2OlcekM: Boolean;// bellek yazmaçlarının ölçek değerleri var mı?

function HataKodunuAl(HataKodu: Integer): string;

implementation

// hata kodunun karakter dizi karşılığını geri döndürür
function HataKodunuAl(HataKodu: Integer): string;
begin

  if(HataKodu > TOPLAM_HATA_BILGI_UYARI) then HataKodu := HATA_BILINMEYEN_HATA;
  Result := BilgiDizisi[HataKodu].Aciklama;
end;

end.
