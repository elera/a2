{-------------------------------------------------------------------------------

  Dosya: g13islev.pas

  İşlev: 13. grup kodlama işlevlerini gerçekleştirir

  13. grup kodlama işlevi; üç parametreli, yazmaç / sabit değer / bellek
    bölgesi ataması kombinasyonlarından oluşan komutlardır

  Güncelleme Tarihi: 04/10/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit g13islev;

interface

uses Classes, SysUtils, paylasim, onekler, hataayiklama;

function Grup13Islev: Integer;

implementation

uses yazmaclar, kodlama, komutlar, asm2, genel, donusum, dosya;

function Grup13Islev: Integer;
var
  VG: TVeriGenisligi;
begin

  Result := HATA_YOK;
  Exit;

  if(SI.Komut.GNo = GRUP13_SHLD) or
    (SI.Komut.GNo = GRUP13_SHRD) then
  begin

    if(SI.B3.BolumAnaTip = batSayisalDeger) then
    begin

      VG := SayiTipiniAl(SI.B3.SabitDeger);
      if(VG = vgB1) then
      begin

        if(SI.B1.BolumAnaTip = batYazmac) and
          (SI.B2.BolumAnaTip = batYazmac) then
        begin

          if(YazmacListesi[SI.B1.Yazmac].Uzunluk = YazmacListesi[SI.B2.Yazmac].Uzunluk) and
            (YazmacListesi[SI.B1.Yazmac].Deger < 8) and (YazmacListesi[SI.B2.Yazmac].Deger < 8) then
          begin

            if(YazmacListesi[SI.B1.Yazmac].Uzunluk = yu64bGY) and
              (GAsm2.Derleyici.Mimari <> mim64Bit) then
            begin

              Result := HATA_64BIT_MIMARI_GEREKLI;
              Exit;
            end;

            if(YazmacListesi[SI.B1.Yazmac].Uzunluk = yu64bGY) and
              (GAsm2.Derleyici.Mimari = mim64Bit) then

              KodEkle($48)
            else if(((YazmacListesi[SI.B1.Yazmac].Uzunluk = yu16bGY) and
              (GAsm2.Derleyici.Mimari = mim32Bit)) or
              ((YazmacListesi[SI.B1.Yazmac].Uzunluk = yu32bGY) and
              (GAsm2.Derleyici.Mimari = mim16Bit))) then KodEkle($66);

            KodEkle($0F);

            if(SI.Komut.GNo = GRUP13_SHLD) then
              KodEkle($A4)
            else KodEkle($AC);    // GRUP13_SHRD

            KodEkle($C0 or ((YazmacListesi[SI.B2.Yazmac].Deger and 7) shl 3) or
              (YazmacListesi[SI.B1.Yazmac].Deger and 7));
            KodEkle(Byte(SI.B3.SabitDeger));

            Result := HATA_YOK;

          end else Result := HATA_ISL_KOD_KULLANIM;
        end else Result := HATA_ISL_KOD_KULLANIM;
      end else Result := HATA_ISL_KOD_KULLANIM;
    end
    else if(SI.B3.BolumAnaTip = batYazmac) then
    begin

      if(YazmacListesi[SI.B3.Yazmac].Ad = 'cl') then
      begin

        if(SI.B1.BolumAnaTip = batYazmac) and
          (SI.B2.BolumAnaTip = batYazmac) then
        begin

          if(YazmacListesi[SI.B1.Yazmac].Uzunluk = YazmacListesi[SI.B2.Yazmac].Uzunluk) and
            (YazmacListesi[SI.B1.Yazmac].Deger < 8) and (YazmacListesi[SI.B2.Yazmac].Deger < 8) then
          begin

            if(YazmacListesi[SI.B1.Yazmac].Uzunluk = yu64bGY) and
              (GAsm2.Derleyici.Mimari <> mim64Bit) then
            begin

              Result := HATA_64BIT_MIMARI_GEREKLI;
              Exit;
            end;

            if(YazmacListesi[SI.B1.Yazmac].Uzunluk = yu64bGY) and
              (GAsm2.Derleyici.Mimari = mim64Bit) then

              KodEkle($48)
            else if(((YazmacListesi[SI.B1.Yazmac].Uzunluk = yu16bGY) and
              (GAsm2.Derleyici.Mimari = mim32Bit)) or
              ((YazmacListesi[SI.B1.Yazmac].Uzunluk = yu32bGY) and
              (GAsm2.Derleyici.Mimari = mim16Bit))) then KodEkle($66);

            KodEkle($0F);

            if(SI.Komut.GNo = GRUP13_SHLD) then
              KodEkle($A5)
            else KodEkle($AD);      // GRUP13_SHRD

            KodEkle($C0 or ((YazmacListesi[SI.B2.Yazmac].Deger and 7) shl 3) or
              (YazmacListesi[SI.B1.Yazmac].Deger and 7));

            Result := HATA_YOK;

          end else Result := HATA_ISL_KOD_KULLANIM;
        end else Result := HATA_ISL_KOD_KULLANIM;
      end else Result := HATA_ISL_KOD_KULLANIM;
    end else Result := HATA_ISL_KOD_KULLANIM;
  end;
end;

end.
