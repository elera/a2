{-------------------------------------------------------------------------------

  Dosya: paylasim.pas

  İşlev: tüm birimlerin kullandığı sabit, değişken ve yapıları içerir

  Güncelleme Tarihi: 19/03/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit paylasim;

interface

type
  // satır içerisinde kullanılan temel veri tipi
  TTemelVeriTipi = (tvtTanimsiz, tvtKarakterDizisi, tvtSayi, tvtYazmac);

  // her bir satırın veri tipi.
  // not 1: abvtBuyukYapi (makrolar) ileride tanımlanabilir - 03.02.2018
  // not 2: tanım verileri sabit veri değildir. tanımlaması programcı
  //  tarafından gerçekleştirilir
  TKomutTipi = (ktBelirsiz, ktIslemKodu, ktDegisken, ktTanim, ktBildirim);

  // alt satırdaki veriler TAnaBolumVeriTipi içerisinde yok edilecek
  // işlem kod ana ve alt bölümleri
  TVeriKontrolTip = (vktYok, vktDegisken, vktKarakterDizisi, vktSayi,
    vktYazmac, vktBosluk, vktVirgul, vktEsittir, vktArti,
    vktKPAc, vktKPKapat, vktOlcek, vktIlk, vktSon);

/////////////////////////
type
  TDigerVeriler = (dvEtiket, dvAciklama);
  TDigerVeri = set of TDigerVeriler;

  TBolumAnaTip = (batYok, batSayisalDeger, batYazmac, batBellek);

type
  TBolumAyrintilar = (baHedefYazmac, baKaynakYazmac, baBellekYazmac1, baBellekYazmac2,
    baOlcek, baSabitDeger, baBellekSabitDeger);
  TBolumAyrinti = set of TBolumAyrintilar;

type
  TBolumTip = record
    BolumAnaTip: TBolumAnaTip;
    BolumAyrinti: TBolumAyrinti;
  end;

type
  TKomut = record
    Komut: string[15];
    GrupNo: Integer;
    KomutTipi: TKomutTipi;
  end;

type
  TSatirIcerik = record
    Komut: TKomut;
    BolumTip1: TBolumTip;
    BolumTip2: TBolumTip;
    DigerVeri: TDigerVeri;
  end;

  TSayiTipi = (stHatali, st1B, st2B, st4B, st8B);

implementation

end.