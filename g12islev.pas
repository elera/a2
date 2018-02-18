{-------------------------------------------------------------------------------

  Dosya: g03islev.pas

  İşlev: 3. grup kodlama işlevlerini gerçekleştirir

  Güncelleme Tarihi: 14/02/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit g12islev;

interface

uses Classes, SysUtils, genel;

function Grup12Islev(ParcaNo: Integer; VeriKontrolTip: TVeriKontrolTip; Veri1: string;
  Veri2: QWord): Integer;

implementation

uses dbugintf, yazmaclar, kodlama;

// ünite içi genel kullanımlık yerel değişkenler
var
  // ifadeyi yorumlayan işlevler tarafından kullanılan genel değişkenler
  VirgulKullanildi, ArtiIsleyiciKullanildi: Boolean;
  KoseliParantezSayisi: Integer;

// mov komutu ve diğer ilgili en karmaşık komutların prototipi
function Grup12Islev(ParcaNo: Integer; VeriKontrolTip: TVeriKontrolTip; Veri1: string;
  Veri2: QWord): Integer;
begin

  {frmAnaSayfa.mmDurumBilgisi.Lines.Add('Parça No: ' + IntToStr(ParcaNo));
  case VeriTipi of
    vtIslemKodu: frmAnaSayfa.mmDurumBilgisi.Lines.Add('VT IslemKodu: ' + Komutlar[Veri2].Komut);
    vtYazmac: frmAnaSayfa.mmDurumBilgisi.Lines.Add('VT Yazmaç: ' + Yazmaclar[Veri2].Ad);
    vtSayi: frmAnaSayfa.mmDurumBilgisi.Lines.Add('VT Sayı: ' + IntToStr(Veri2));
    vtVirgul: frmAnaSayfa.mmDurumBilgisi.Lines.Add('VT: vtVirgul');
    vtArti: frmAnaSayfa.mmDurumBilgisi.Lines.Add('VT: vtArti');
    vtKPAc: frmAnaSayfa.mmDurumBilgisi.Lines.Add('VT: vtKPAc');
    vtKPKapat: frmAnaSayfa.mmDurumBilgisi.Lines.Add('VT: vtKPKapat');
  end;}

  // ilk parça = işlem kodunun bulunduğu veri (opcode)
  // ilk parça ile birlikte Veri2 değeri de işlem kodunun sıra değerini içerir
  if(VeriKontrolTip = vktIlk) then
  begin

    // işlem kodunun (opcode) her zaman 1. değer olarak gelmesi gerekmektedir
    {if(ParcaNo <> 1) then

      Result := HATA_HATALI_KULLANIM
    else
    begin}

    // işlem kodu ile ilgili ilk değer atamaları burada gerçekleştirilir
    GIslemKodAyrinti := [];
    //GIslemKodAnaBolum += [ikabIslemKodu];
    GIslemKodu := Veri2;
    VirgulKullanildi := False;
    ArtiIsleyiciKullanildi := False;
    KoseliParantezSayisi := 0;
    GYazmacB1OlcekM := False;
    GYazmacB2OlcekM := False;
    Result := 0;
    //end;
  end
  // ÖNEMLİ:
  // 1. GParametreTip1 ve GParametreTip2 değişkenlerine anasayfa'da ptYok olarak ilk değer atanıyor
  // 2. GParametreTip1 ve GParametreTip2 değişkenleri vtKPAc kısmında ptBellek olarak atama yapılıyor
  // 3. Köşeli parantez kontrolü vtKPAc sorgulama kısmında gerçekleştiriliyor
  // 4. Sabit sayısal değer (imm) ve ölçek değeri (scale) diğer sorgu aşamalarında atanmaktadır
  else if(VeriKontrolTip = vktYazmac) then
  begin

    if(ParcaNo = 2) then
    begin

      if(GIKABVeriTipi1 = vtYok) then GIKABVeriTipi1 := vtYazmac;

      if(GIKABVeriTipi1 = vtYazmac) then
      begin

        GYazmac1 := Veri2;
        GIslemKodAyrinti += [ikaIslemKodY1];
        Result := 0;
      end
      else
      begin

        if(ikaIslemKodB1 in GIslemKodAyrinti) then
        begin

          if(ikaIslemKodB2 in GIslemKodAyrinti) then
          begin

            Result := HATA_ISL_KOD_KULLANIM
          end
          else
          begin

            GIslemKodAyrinti += [ikaIslemKodB2];
            GYazmacB2 := Veri2;
            Result := 0;
          end;
        end
        else
        begin

          GYazmacB1 := Veri2;
          GIslemKodAyrinti += [ikaIslemKodB1];
          Result := 0;
        end;
      end;
    end
    else if(ParcaNo = 3) then
    begin

      // 3. parça işlenmeden önce virgülün kullanılıp kullanılmadığı test edilmektedir
      if not VirgulKullanildi then
      begin

        Result := HATA_ISL_KULLANIM;
      end
      else
      begin

        if(GIKABVeriTipi2 = vtYok) then GIKABVeriTipi2 := vtYazmac;

        if(GIKABVeriTipi2 = vtYazmac) then
        begin

          GYazmac2 := Veri2;
          GIslemKodAyrinti += [ikaIslemKodY2];
          Result := 0;
        end
        else
        begin

          if(ikaIslemKodB1 in GIslemKodAyrinti) then
          begin

            if(ikaIslemKodB2 in GIslemKodAyrinti) then
            begin

              Result := HATA_ISL_KOD_KULLANIM
            end
            else
            begin

              GIslemKodAyrinti += [ikaIslemKodB2];
              GYazmacB2 := Veri2;
              Result := 0;
            end;
          end
          else
          begin

            GYazmacB1 := Veri2;
            GIslemKodAyrinti += [ikaIslemKodB1];
            Result := 0;
          end;
        end;
      end;
    end else Result := HATA_ISL_KOD_KULLANIM;
  end
  else if(VeriKontrolTip = vktVirgul) then
  begin

    // virgül kullanılmadan önce:
    // 1. yazmaç değeri kullanılmamışsa
    // 2. sabit bellek değeri kullanılmamışsa
    // 3. ikinci kez virgül kullanılmışsa
    if not((ikaIslemKodY1 in GIslemKodAyrinti) or (ikaIslemKodB1 in GIslemKodAyrinti) or
      (ikaSabitDegerB in GIslemKodAyrinti)) then

      Result := HATA_YAZMAC_GEREKLI
    else if (VirgulKullanildi) then

      Result := HATA_ISL_KOD_KULLANIM
    else
    begin

      VirgulKullanildi := True;
      Result := 0;
    end;
  end
  else if(VeriKontrolTip = vktKPAc) then
  begin

    // daha önce köşeli parantez kullanılmışsa
    if(KoseliParantezSayisi > 0) then

      Result := HATA_ISL_KOD_KULLANIM
    // daha önce bellek adreslemede yazmaç veya bellek sabit değeri kullanılmışsa
    else if(ikaIslemKodB1 in GIslemKodAyrinti) or (ikaSabitDegerB in GIslemKodAyrinti) then

      Result := HATA_BELLEKTEN_BELLEGE
    else
    begin

      // ParcaNo = 2 = hedef alan, ParcaNo = 3 = kaynak alan
      if(ParcaNo = 2) then
        GIKABVeriTipi1 := vtBellek
      else if(ParcaNo = 3) then GIKABVeriTipi2 := vtBellek;

      Inc(KoseliParantezSayisi);
      Result := 0;
    end;
  end
  else if(VeriKontrolTip = vktKPKapat) then
  begin

    // açılan parantez sayısı kadar parantez kapatılmalıdır
    if(KoseliParantezSayisi < 1) then

      Result := HATA_ISL_KOD_KULLANIM
    else
    begin

      Dec(KoseliParantezSayisi);
      Result := 0;
    end;
  end
  else if(VeriKontrolTip = vktArti) then
  begin

    // artı toplam değerinin kullanılması için tek bir köşeli parantez
    // açılması gerekmekte (bellek adresleme)
    if(KoseliParantezSayisi <> 1) then

      Result := HATA_ISL_KULLANIM
    else
    begin

      ArtiIsleyiciKullanildi := True;
      Result := 0;
    end;
  end
  // ölçek (scale) - bellek adreslemede yazmaç ölçek değeri
  else if(VeriKontrolTip = vktOlcek) then
  begin

    if(ikaOlcek in GIslemKodAyrinti) then
    begin

      Result := HATA_OLCEK_ZATEN_KULLANILMIS;
    end
    else
    begin

      if(Veri2 = 1) or (Veri2 = 2) or (Veri2 = 4) or (Veri2 = 8) then
      begin

        GIslemKodAyrinti += [ikaOlcek];
        if(ArtiIsleyiciKullanildi) then

          GYazmacB2OlcekM := True
        else GYazmacB1OlcekM := True;

        GOlcek := Veri2;
        Result := 0;
      end
      else
      begin

        Result := HATA_OLCEK_DEGER;
      end;
    end;
  end
  else if(VeriKontrolTip = vktSayi) then
  begin

    // ParcaNo 2 veya 3'ün bellek adreslemesi olması durumunda
    if(GIKABVeriTipi1 = vtBellek) or (GIKABVeriTipi2 = vtBellek) then
    begin

      if not(ikaSabitDegerB in GIslemKodAyrinti) then
      begin

        GIslemKodAyrinti += [ikaSabitDegerB];
        GSabitDeger := Veri2;
        Result := 0;
      end
      else
      begin

        Result := HATA_ISL_KOD_KULLANIM;
      end;
    end
    else if(GIKABVeriTipi2 = vtYok) and (ParcaNo = 3) then
    begin

      GIKABVeriTipi2 := vtSayisalDeger;
      GIslemKodAyrinti += [ikaSabitDeger];
      GSabitDeger := Veri2;
      Result := 0;
    end else Result := HATA_ISL_KOD_KULLANIM;
  end
  // son kontroller bu aşamada gerçekleştirilecek
  else if(VeriKontrolTip = vktSon) then
  begin

    // 8 bitlik veri
    if(YazmacListesi[GYazmac1].Uzunluk = yu8Bit) then
    begin

      KodEkle($B0 + YazmacListesi[GYazmac1].Deger);
      KodEkle(Byte(GSabitDeger));
      Result := HATA_YOK;
    end
    // 16 bitlik veri
    else if(YazmacListesi[GYazmac1].Uzunluk = yu16Bit) then
    begin

      KodEkle($B8 + YazmacListesi[GYazmac1].Deger);
      KodEkle(Byte(GSabitDeger));
      KodEkle(Byte(GSabitDeger shr 8));
      Result := HATA_YOK;
    end else Result := HATA_BILINMEYEN_HATA;

    //SendDebug('Yazmaç 1: ' + YazmacListesi[GYazmac1].Ad);
    //SendDebug('Sabit Değer: ' + IntToStr(GSabitDeger));
    //SendDebug('Yazmaç 2: ' + IntToStr(GYazmac2));
  end else Result := 1;
end;

end.
