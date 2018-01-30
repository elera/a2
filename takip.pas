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

  // mevcut komut satırının etiket değeri var ise ...
  if(Length(GEtiket) > 0) then frmAnaSayfa.mmDurumBilgisi.Lines.Add('Etiket: ' + GEtiket);

  frmAnaSayfa.mmDurumBilgisi.Lines.Add('İşlem Kodu: ' + Komutlar[GIslemKodu].Komut);

  // ilk parametre değerleri
  // ---------------------------------------------------------------------------

  // ilk parametre yazmaç ise
  if(GParametreTip1 = ptYazmac) then
  begin

    frmAnaSayfa.mmDurumBilgisi.Lines.Add('Hedef Yazmaç: ' + Yazmaclar[GYazmac1].Ad);
  end
  // ilk parametre bellek adresleme ise
  else if(GParametreTip1 = ptBellek) then
  begin

    // 1. bellek içerik ve ölçek değerleri
    if(ikdIslemKodB1 in GIslemKodDegisken) then
    begin

      frmAnaSayfa.mmDurumBilgisi.Lines.Add('1. Hedef Bellek Yazmaç: ' +
        Yazmaclar[GYazmacB1].Ad);
    end;

    if(ikdOlcek in GIslemKodDegisken) and (GYazmacB1OlcekM) then
      frmAnaSayfa.mmDurumBilgisi.Lines.Add('Ölçek Değeri: ' + IntToStr(GOlcek));

    // 2. bellek içerik ve ölçek değerleri
    if(ikdIslemKodB2 in GIslemKodDegisken) then
    begin

      frmAnaSayfa.mmDurumBilgisi.Lines.Add('2. Hedef Bellek Yazmaç: ' +
        Yazmaclar[GYazmacB2].Ad);
    end;

    if(ikdOlcek in GIslemKodDegisken) and (GYazmacB2OlcekM) then
      frmAnaSayfa.mmDurumBilgisi.Lines.Add('Ölçek Değeri: ' + IntToStr(GOlcek));

    // bellek adresleme sabit değeri
    if(ikdSabitDegerB in GIslemKodDegisken) then
      frmAnaSayfa.mmDurumBilgisi.Lines.Add('Sabit Değer: ' + IntToStr(GSabitDeger));
  end
  // ilk parametre sayısal sabit değer ise
  else if(GParametreTip1 = ptSayisalDeger) then
  begin

    frmAnaSayfa.mmDurumBilgisi.Lines.Add('Sabit Değer: ' + IntToStr(GSabitDeger));
  end;

  // ikinci parametre değerleri
  // ---------------------------------------------------------------------------

  // ikinci parametre yazmaç ise
  if(GParametreTip2 = ptYazmac) then
  begin

    frmAnaSayfa.mmDurumBilgisi.Lines.Add('Kaynak Yazmaç: ' + Yazmaclar[GYazmac2].Ad);
  end
  // ikinci parametre bellek adresleme ise
  else if(GParametreTip2 = ptBellek) then
  begin

    // 1. bellek içerik ve ölçek değerleri
    if(ikdIslemKodB1 in GIslemKodDegisken) then
    begin

      frmAnaSayfa.mmDurumBilgisi.Lines.Add('1. Kaynak Bellek Yazmaç: ' +
        Yazmaclar[GYazmacB1].Ad);
    end;

    if(ikdOlcek in GIslemKodDegisken) and (GYazmacB1OlcekM) then
      frmAnaSayfa.mmDurumBilgisi.Lines.Add('Ölçek Değeri: ' + IntToStr(GOlcek));

    // 2. bellek içerik ve ölçek değerleri
    if(ikdIslemKodB2 in GIslemKodDegisken) then
    begin

      frmAnaSayfa.mmDurumBilgisi.Lines.Add('2. Kaynak Bellek Yazmaç: ' +
        Yazmaclar[GYazmacB2].Ad);
    end;

    if(ikdOlcek in GIslemKodDegisken) and (GYazmacB2OlcekM) then
      frmAnaSayfa.mmDurumBilgisi.Lines.Add('Ölçek Değeri: ' + IntToStr(GOlcek));

    // bellek adresleme sabit değeri
    if(ikdSabitDegerB in GIslemKodDegisken) then
      frmAnaSayfa.mmDurumBilgisi.Lines.Add('Sabit Değer: ' + IntToStr(GSabitDeger));
  end
  // ikinci parametre sayısal sabit değer ise
  else if(GParametreTip2 = ptSayisalDeger) then
  begin

    frmAnaSayfa.mmDurumBilgisi.Lines.Add('Sabit Değer: ' + IntToStr(GSabitDeger));
  end;
end;

end.
