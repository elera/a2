{-------------------------------------------------------------------------------

  Dosya: g13islev.pas

  İşlev: 13. grup kodlama işlevlerini gerçekleştirir

  13. grup kodlama işlevi; üç parametreli, yazmaç / sabit değer / bellek
    bölgesi ataması kombinasyonlarından oluşan komutlardır

  Güncelleme Tarihi: 17/08/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit g13islev;

interface

uses Classes, SysUtils, paylasim, onekler;

function Grup13Islev(SatirNo: Integer; ParcaNo: Integer;
  VeriKontrolTip: TVeriKontrolTip; Veri1: string; Veri2: QWord): Integer;

implementation

uses dbugintf, yazmaclar, kodlama, komutlar, asm2, genel, donusum, dosya;

// ünite içi genel kullanımlık yerel değişkenler
var
  // ifadeyi yorumlayan işlevler tarafından kullanılan genel değişkenler
  VirgulKullanildi, ArtiIsleyiciKullanildi: Boolean;
  KoseliParantezSayisi: Integer;

function Grup13Islev(SatirNo: Integer; ParcaNo: Integer;
  VeriKontrolTip: TVeriKontrolTip; Veri1: string; Veri2: QWord): Integer;
var
  i, i4: Integer;
  VG: TVeriGenisligi;
  BT: PBolumTip;
begin

  // ilk parça = işlem kodu verisidir. (opcode)
  // ilk parça ile birlikte Veri2 değeri de komut sıra değerini içerir
  if(VeriKontrolTip = vktIlk) then
  begin

    // ilk değer atamaları
    SatirIcerik.Komut := KomutListesi[Veri2];
    VirgulKullanildi := False;
    ArtiIsleyiciKullanildi := False;
    KoseliParantezSayisi := 0;
    GYazmacB1OlcekM := False;
    GYazmacB2OlcekM := False;
    Result := HATA_YOK;
  end
  // ÖNEMLİ:
  // 1. .BolumTip1, .BolumTip2 ve .BolumTip3 alt yapılarına anasayfa'da batYok değeri atanmaktadır
  // 2. .BolumTip1, .BolumTip2 ve .BolumTip3 alt yapılarına vtKPAc kısmında batBellek tipi atanmaktadır
  // 3. Köşeli parantez kontrolü vtKPAc sorgulama kısmında gerçekleştiriliyor
  // 4. Sabit sayısal değer (imm) ve ölçek değeri (scale) diğer sorgu aşamalarında atanmaktadır
  else if(VeriKontrolTip = vktYazmac) then
  begin

    //  örnek: işlemkodu ParcaNo2, ParcaNo3, ParcaNo4
    if(ParcaNo > 2) and not(VirgulKullanildi) then
    begin

      Result := HATA_ISL_KULLANIM;
    end
    else
    begin

      VirgulKullanildi := False;

      case ParcaNo of
        2: BT := @SatirIcerik.BolumTip1;
        3: BT := @SatirIcerik.BolumTip2;
        4: BT := @SatirIcerik.BolumTip3;
      end;

      if(BT^.BolumAnaTip = batYok) then
      begin

        BT^.BolumAnaTip := batYazmac;
        case ParcaNo of
          2: GYazmac1 := Veri2;
          3: GYazmac2 := Veri2;
          4: GYazmac3 := Veri2;
        end;
        Result := HATA_YOK;
      end
      else if(BT^.BolumAnaTip = batYazmac) then
      begin

        Result := HATA_ISL_KULLANIM;
      end
      // bellek yazmaç bildirimlerinin hangi alana yapılacağı kontrolü
      // bu aşamada değil; son aşamada gerçekleştirilecektir
      else if(BT^.BolumAnaTip = batBellek) then
      begin

        if(baBellekYazmac1 in BT^.BolumAyrinti) then
        begin

          if(baBellekYazmac2 in BT^.BolumAyrinti) then
          begin

            Result := HATA_ISL_KOD_KULLANIM
          end
          else
          begin

            BT^.BolumAyrinti += [baBellekYazmac2];
            GYazmacB2 := Veri2;
            Result := HATA_YOK;
          end;
        end
        else
        begin

          GYazmacB1 := Veri2;
          BT^.BolumAyrinti += [baBellekYazmac1];
          Result := HATA_YOK;
        end;
      end;
    end;
  end
  else if(VeriKontrolTip = vktVirgul) then
  begin

    // üstüste birden fazla virgül kullanılmışsa
    if (VirgulKullanildi) then
    begin

      Result := HATA_ISL_KOD_KULLANIM;
    end
    else
    begin

      VirgulKullanildi := True;
      Result := HATA_YOK;
    end;
  end
  else if(VeriKontrolTip = vktKPAc) then
  begin

    // daha önce köşeli parantez kullanılmışsa
    if(KoseliParantezSayisi > 0) then

      Result := HATA_ISL_KOD_KULLANIM
    else
    begin

      case ParcaNo of
        2: SatirIcerik.BolumTip1.BolumAnaTip := batBellek;
        3: SatirIcerik.BolumTip2.BolumAnaTip := batBellek;
        4: SatirIcerik.BolumTip3.BolumAnaTip := batBellek;
      end;

      Inc(KoseliParantezSayisi);
      Result := HATA_YOK;
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
      Result := HATA_YOK;
    end;
  end
  else if(VeriKontrolTip = vktKarakterDizisi) then
  begin

    Result := HATA_DEVAM_EDEN_CALISMA;
  end
  else if(VeriKontrolTip = vktSayi) then
  begin

    case ParcaNo of
      2:
      begin

        SatirIcerik.BolumTip1.BolumAnaTip := batSayisalDeger;
        GSabitDeger1 := Veri2;
        Result := HATA_YOK;
      end;
      3:
      begin

        SatirIcerik.BolumTip2.BolumAnaTip := batSayisalDeger;
        GSabitDeger2 := Veri2;
        Result := HATA_YOK;
      end;
      4:
      begin

        SatirIcerik.BolumTip3.BolumAnaTip := batSayisalDeger;
        GSabitDeger3 := Veri2;
        Result := HATA_YOK;
      end;
      //else Result := HATA_ISL_KOD_KULLANIM;
    end;
  end
  // son kontroller bu aşamada gerçekleştirilecek
  else if(VeriKontrolTip = vktSon) then
  begin

    if(SatirIcerik.Komut.GrupNo = GRUP13_SHLD) or
      (SatirIcerik.Komut.GrupNo = GRUP13_SHRD) then
    begin

      if(SatirIcerik.BolumTip3.BolumAnaTip = batSayisalDeger) then
      begin

        VG := SayiTipiniAl(GSabitDeger3);
        if(VG = vgB1) then
        begin

          if(SatirIcerik.BolumTip1.BolumAnaTip = batYazmac) and
            (SatirIcerik.BolumTip2.BolumAnaTip = batYazmac) then
          begin

            if(YazmacListesi[GYazmac1].Uzunluk = YazmacListesi[GYazmac2].Uzunluk) and
              (YazmacListesi[GYazmac1].Deger < 8) and (YazmacListesi[GYazmac2].Deger < 8) then
            begin

              if(YazmacListesi[GYazmac1].Uzunluk = yu64bGY) and
                (GAktifDosya^.Mimari <> mim64Bit) then
              begin

                Result := HATA_64BIT_MIMARI_GEREKLI;
                Exit;
              end;

              if(YazmacListesi[GYazmac1].Uzunluk = yu64bGY) and
                (GAktifDosya^.Mimari = mim64Bit) then

                KodEkle($48)
              else if(((YazmacListesi[GYazmac1].Uzunluk = yu16bGY) and
                (GAktifDosya^.Mimari = mim32Bit)) or
                ((YazmacListesi[GYazmac1].Uzunluk = yu32bGY) and
                (GAktifDosya^.Mimari = mim16Bit))) then KodEkle($66);

              KodEkle($0F);

              if(SatirIcerik.Komut.GrupNo = GRUP13_SHLD) then
                KodEkle($A4)
              else KodEkle($AC);    // GRUP13_SHRD

              KodEkle($C0 or ((YazmacListesi[GYazmac2].Deger and 7) shl 3) or
                (YazmacListesi[GYazmac1].Deger and 7));
              KodEkle(Byte(GSabitDeger3));

              Result := HATA_YOK;

            end else Result := HATA_ISL_KOD_KULLANIM;
          end else Result := HATA_ISL_KOD_KULLANIM;
        end else Result := HATA_ISL_KOD_KULLANIM;
      end
      else if(SatirIcerik.BolumTip3.BolumAnaTip = batYazmac) then
      begin

        if(YazmacListesi[GYazmac3].Ad = 'cl') then
        begin

          if(SatirIcerik.BolumTip1.BolumAnaTip = batYazmac) and
            (SatirIcerik.BolumTip2.BolumAnaTip = batYazmac) then
          begin

            if(YazmacListesi[GYazmac1].Uzunluk = YazmacListesi[GYazmac2].Uzunluk) and
              (YazmacListesi[GYazmac1].Deger < 8) and (YazmacListesi[GYazmac2].Deger < 8) then
            begin

              if(YazmacListesi[GYazmac1].Uzunluk = yu64bGY) and
                (GAktifDosya^.Mimari <> mim64Bit) then
              begin

                Result := HATA_64BIT_MIMARI_GEREKLI;
                Exit;
              end;

              if(YazmacListesi[GYazmac1].Uzunluk = yu64bGY) and
                (GAktifDosya^.Mimari = mim64Bit) then

                KodEkle($48)
              else if(((YazmacListesi[GYazmac1].Uzunluk = yu16bGY) and
                (GAktifDosya^.Mimari = mim32Bit)) or
                ((YazmacListesi[GYazmac1].Uzunluk = yu32bGY) and
                (GAktifDosya^.Mimari = mim16Bit))) then KodEkle($66);

              KodEkle($0F);

              if(SatirIcerik.Komut.GrupNo = GRUP13_SHLD) then
                KodEkle($A5)
              else KodEkle($AD);      // GRUP13_SHRD

              KodEkle($C0 or ((YazmacListesi[GYazmac2].Deger and 7) shl 3) or
                (YazmacListesi[GYazmac1].Deger and 7));

              Result := HATA_YOK;

            end else Result := HATA_ISL_KOD_KULLANIM;
          end else Result := HATA_ISL_KOD_KULLANIM;
        end else Result := HATA_ISL_KOD_KULLANIM;
      end else Result := HATA_ISL_KOD_KULLANIM;
    end;
  end;
end;

end.
