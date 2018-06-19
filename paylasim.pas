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
  TTemelVeriTipi = (tvtTanimsiz, tvtKarakterDizisi,
    tvtSayi,                  // normal sayı
    tvtKayanNokta64,          // 64 bitlik kayan nokta (floating point)
    tvtYazmac, tvtMakro);

  // her bir satırın veri tipi.
  // not 1: abvtBuyukYapi (makrolar) ileride tanımlanabilir - 03.02.2018
  // not 2: tanım verileri sabit veri değildir. tanımlaması programcı
  //  tarafından gerçekleştirilir
  TKomutTipi = (ktBelirsiz, ktIslemKodu, ktDegisken, ktTanim, ktBildirim, ktMakro);

  // alt satırdaki veriler TAnaBolumVeriTipi içerisinde yok edilecek
  // işlem kod ana ve alt bölümleri
  TVeriKontrolTip = (vktYok, vktDegisken, vktKarakterDizisi,
    vktSayi,                  // normal sayı
    vktKayanNokta,            // 32 / 64 bitlik kayan nokta (floating point)
    vktYazmac, vktOnEk, vktBosluk, vktVirgul, vktEsittir, vktArti,
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
    Etiket, Aciklama: string;
  end;

implementation

end.
