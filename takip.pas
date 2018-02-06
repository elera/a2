{-------------------------------------------------------------------------------

  Dosya: takip.pas

  İşlev: hata, veri takip işlevlerini gerçekleştiren işlevleri içerir

  Güncelleme Tarihi: 30/01/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit takip;

interface

uses Classes, SysUtils;

procedure VerileriGoruntule;

implementation

uses anasayfa, yorumla, genel;

// işlem koduna sahip satırların veri içeriklerini görüntüler
procedure VerileriGoruntule;
begin

  // etiket değeri var ise ...
  if(ikabEtiket in GIslemKodAnaBolum) then frmAnaSayfa.mmDurumBilgisi.Lines.Add('Etiket: ' + GEtiket);

  if(ikabIslemKodu in GIslemKodAnaBolum) then
  begin

    // işlem kodu
    frmAnaSayfa.mmDurumBilgisi.Lines.Add('İşlem Kodu: ' + Komutlar[GIslemKodu].Komut);

    // ilk parametre değerleri
    // ---------------------------------------------------------------------------

    // ilk parametre yazmaç ise
    if(GIKABVeriTipi1 = vtYazmac) then
    begin

      frmAnaSayfa.mmDurumBilgisi.Lines.Add('Hedef Yazmaç: ' + Yazmaclar[GYazmac1].Ad);
    end
    // ilk parametre bellek adresleme ise
    else if(GIKABVeriTipi1 = vtBellek) then
    begin

      // 1. bellek içerik ve ölçek değerleri
      if(ikaIslemKodB1 in GIslemKodAyrinti) then
      begin

        frmAnaSayfa.mmDurumBilgisi.Lines.Add('1. Hedef Bellek Yazmaç: ' +
          Yazmaclar[GYazmacB1].Ad);
      end;

      if(ikaOlcek in GIslemKodAyrinti) and (GYazmacB1OlcekM) then
        frmAnaSayfa.mmDurumBilgisi.Lines.Add('Ölçek Değeri: ' + IntToStr(GOlcek));

      // 2. bellek içerik ve ölçek değerleri
      if(ikaIslemKodB2 in GIslemKodAyrinti) then
      begin

        frmAnaSayfa.mmDurumBilgisi.Lines.Add('2. Hedef Bellek Yazmaç: ' +
          Yazmaclar[GYazmacB2].Ad);
      end;

      if(ikaOlcek in GIslemKodAyrinti) and (GYazmacB2OlcekM) then
        frmAnaSayfa.mmDurumBilgisi.Lines.Add('Ölçek Değeri: ' + IntToStr(GOlcek));

      // bellek adresleme sabit değeri
      if(ikaSabitDegerB in GIslemKodAyrinti) then
        frmAnaSayfa.mmDurumBilgisi.Lines.Add('Sabit Değer: ' + IntToStr(GSabitDeger));
    end
    // ilk parametre sayısal sabit değer ise
    else if(GIKABVeriTipi1 = vtSayisalDeger) then
    begin

      frmAnaSayfa.mmDurumBilgisi.Lines.Add('Sabit Değer: ' + IntToStr(GSabitDeger));
    end;

    // ikinci parametre değerleri
    // ---------------------------------------------------------------------------

    // ikinci parametre yazmaç ise
    if(GIKABVeriTipi2 = vtYazmac) then
    begin

      frmAnaSayfa.mmDurumBilgisi.Lines.Add('Kaynak Yazmaç: ' + Yazmaclar[GYazmac2].Ad);
    end
    // ikinci parametre bellek adresleme ise
    else if(GIKABVeriTipi2 = vtBellek) then
    begin

      // 1. bellek içerik ve ölçek değerleri
      if(ikaIslemKodB1 in GIslemKodAyrinti) then
      begin

        frmAnaSayfa.mmDurumBilgisi.Lines.Add('1. Kaynak Bellek Yazmaç: ' +
          Yazmaclar[GYazmacB1].Ad);
      end;

      if(ikaOlcek in GIslemKodAyrinti) and (GYazmacB1OlcekM) then
        frmAnaSayfa.mmDurumBilgisi.Lines.Add('Ölçek Değeri: ' + IntToStr(GOlcek));

      // 2. bellek içerik ve ölçek değerleri
      if(ikaIslemKodB2 in GIslemKodAyrinti) then
      begin

        frmAnaSayfa.mmDurumBilgisi.Lines.Add('2. Kaynak Bellek Yazmaç: ' +
          Yazmaclar[GYazmacB2].Ad);
      end;

      if(ikaOlcek in GIslemKodAyrinti) and (GYazmacB2OlcekM) then
        frmAnaSayfa.mmDurumBilgisi.Lines.Add('Ölçek Değeri: ' + IntToStr(GOlcek));

      // bellek adresleme sabit değeri
      if(ikaSabitDegerB in GIslemKodAyrinti) then
        frmAnaSayfa.mmDurumBilgisi.Lines.Add('Sabit Değer: ' + IntToStr(GSabitDeger));
    end
    // ikinci parametre sayısal sabit değer ise
    else if(GIKABVeriTipi2 = vtSayisalDeger) then
    begin

      frmAnaSayfa.mmDurumBilgisi.Lines.Add('Sabit Değer: ' + IntToStr(GSabitDeger));
    end;
  end;

  // açıklama değeri var ise ...
  if(ikabAciklama in GIslemKodAnaBolum) then frmAnaSayfa.mmDurumBilgisi.Lines.Add('Açıklama: ' + GAciklama);

  // ve bir satır boşluk
  frmAnaSayfa.mmDurumBilgisi.Lines.Add('');
end;

end.
