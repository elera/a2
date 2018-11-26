{-------------------------------------------------------------------------------

  Dosya: paylasim.pas

  İşlev: tüm birimlerin kullandığı sabit, değişken ve yapıları içerir

  Güncelleme Tarihi: 15/09/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit paylasim;

interface

type
  // program dosyasının derleme mimarisi
  TMimari = (mim16Bit, mim32Bit, mim64Bit);

  // oluşturulacak dosya biçimleri
  TDosyaBicim = (dbBilinmiyor, dbIkili, dbPE64);

  TVeriDurum = (vdBaslamadi, vdBasladi, vdTamamlandi);

  // dosya durumları:
  // ddYeni, ddKaydedildi, ddDegistirildi durumları düzenleyicideki durumlardır
  // ddBellekte ise dosyanın düzenleyicide olmadığı durumdur
  TDosyaDurum = (ddYeni, ddKaydedildi, ddDegistirildi, ddBellekte);

  // her bir satırdaki her bir parçanın parça tipi
  TParcaTipi = (ptYok, ptTanimsiz, ptKomut, ptVeri, ptIslem);

  // her bir komut parçasının komut tipi
  // kTanimsiz = komutun ilk halini; kTanimlanacak ise, kTanim gibi 1. aşamada
  //   tanımlanamayan ama 2. aşamada tanımlanacak veriyi tanımlar
  TKomutTipi = (kTanimsiz, kTanimlanacak, kIslemKodu, kDegisken, kTanim, kBildirim);

  // her bir veri parçasının veri tipi
  TVeriTipleri = (vTanimsiz, vYazmac, vKarakterDizisi, vSayi, vKayanNokta,
    vMakroDeger, vOnEk, vOlcek, vAciklama);

  // her bir işlem parçasının işlem tipi
  TIslemTipleri = (iBelirsiz, iTopla, iCikart, iCarp, iBol, iVirgul, iEsittir,
    iBosluk, iKPAc, iKPKapat, iPAc, iPKapat);

type
  TDigerVeriler = (dvEtiket, dvAciklama);
  TDigerVeri = set of TDigerVeriler;

  // bir işlem kodunda öndeğerler
  // ya     ret         gibi batYok'tur
  // ya     push 1      gibi batSayisalDeger'dir
  // ya     push eax    gibi batYazmac'tır
  // ya da  push [eax]  gibi batBellek'tir
  TBolumAnaTip = (batYok, batSayisalDeger, batYazmac, batBellek);

type
  TBellekIcerikler = (biYazmac1, biYazmac2, biOlcek, biSabitDeger);
  TBellekIcerik = set of TBellekIcerikler;

type
  TBildirim = record
    SiraNo,                   // bildirim sıra numarası
    GrupNo: Integer;          // komut grup numarası
    Ad: string;               // bildirim adı
    Esittir: Boolean;         // bildirim eşittir işleminin kullanılıp kullanılmadığı
    VeriTipi: TVeriTipleri;   // bildirim veri tipi
    VeriKK: string;           // Karakter Katarı veri değeri
    VeriSD: QWord;            // Sayısal Değer karater katarı
  end;

type
  TKomut = record
    Ad: string[15];
    SNo: Integer;       // komut sıra no
    GNo: Integer;       // komut grup no
    Tip: TKomutTipi;
  end;

type
  PBolumTip = ^TBolumTip;
  TBolumTip = record
    BolumAnaTip: TBolumAnaTip;
    BellekIcerik: TBellekIcerik;
    Yazmac,                       // işlem kodunun bölümde kullanacağı yazmaç
    YazmacB1, YazmacB2,           // işlem kodunun bölümde kullanacağı 2 bellek yazmaç
    SabitDeger,                   // işlem kodunun bölümde kullanacağı sabit değer
    OlcekDeger: Integer;          // işlem kodunun bölümde kullanacağı ölçek değer
  end;

type
  TSatirIcerik = record
    Komut: TKomut;
    BolumNo: Integer;
    B1: TBolumTip;
    B2: TBolumTip;
    B3: TBolumTip;
    DigerVeri: TDigerVeri;
    VeriKK: string;
    VeriSD: Integer;
    Etiket, Aciklama: string;
  end;

type
  TParcaSonuc = record
    ParcaTipi: TParcaTipi;
    VeriTipi: TVeriTipleri;
    IslemTipi: TIslemTipleri;
    Komut: TKomut;            // veri bir komut ise, komut bilgileri
    SiraNo: Integer;          // komut, yazmaç vb. sıra no
    HamVeri,                  // verinin ilk işlendiği işlevdeki durumu
    VeriKK: string;           // Karakter Katarı veri değeri
    VeriSD: QWord;            // Sayısal Değer karater katarı
  end;

implementation

end.
