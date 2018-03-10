{-------------------------------------------------------------------------------

  Dosya: paylasim.pas

  İşlev: tüm birimlerin kullandığı sabit, değişken ve yapıları içerir

  Güncelleme Tarihi: 24/02/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit paylasim;

interface

type
  // bu tanım her bir alanda tanımlanabilinecek temel veri tipidir
  // tvtDiger; işlem kodu, yazmaç, değişken gibi veri tanımlamalarını içerir
  TTemelVeriTipi = (tvtTanimsiz = -1, tvtDiger = 1, tvtKarakterDizisi, tvtSayi);

  // her bir satırın veri tipi.
  // not 1: abvtBuyukYapi (makrolar) ileride tanımlanabilir - 03.02.2018
  // not 2: tanım verileri sabit veri değildir. tanımlaması programcı
  //  tarafından gerçekleştirilir
  TAnaBolumVeriTipi = (abvtBelirsiz, abvtIslemKodu, abvtDegisken,
    abvtTanim, abvtBildirim);

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
  TVeriKontrolTip = (vktYok, vktDegisken, vktKarakterDizisi, vktSayi, {vktIslemKodu, vktTanim,}
    vktYazmac, vktBosluk, vktVirgul, vktEsittir, vktArti, vktKPAc, vktKPKapat, vktOlcek, vktIlk, vktSon);

  // etiket kod ana ve alt bölümleri
  TTanimAnaBolumler = (tabEtiket, tabEtiketAdi, tabAciklama);
  TTanimAnaBolum = set of TTanimAnaBolumler;

  TSayiTipi = (stHatali, st1B, st2B, st4B, st8B);

implementation

end.
