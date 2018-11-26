{-------------------------------------------------------------------------------

  Dosya: g12islev.pas

  İşlev: 12. grup kodlama işlevlerini gerçekleştirir

  12. grup kodlama işlevi; iki parametreli, yazmaç / sabit değer / bellek
    bölgesi ataması kombinasyonlarından oluşan komutlardır

  Güncelleme Tarihi: 03/10/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit g12islev;

interface

uses Classes, SysUtils, paylasim, onekler;

function Grup12Islev: Integer;

implementation

uses yazmaclar, kodlama, komutlar, genel, donusum;

function Grup12Islev: Integer;
var
  i, i4: Integer;
  DegerVG: TVeriGenisligi;
begin

  Result := HATA_YOK;
  Exit;


  if(SI.Komut.GNo = GRUP12_IN) then
  begin

    if(SI.B2.BolumAnaTip = batSayisalDeger) then
    begin

      DegerVG := SayiTipiniAl(SI.B1.SabitDeger);
      if(DegerVG = vgB1) then
      begin

        if(SI.B1.BolumAnaTip = batYazmac) then
        begin

          if(YazmacListesi[SI.B1.Yazmac].Ad = 'al') then
          begin

            KodEkle($E4);
            Result := SayisalDegerEkle(SI.B1.SabitDeger, vgB1);
          end
          else if(YazmacListesi[SI.B1.Yazmac].Ad = 'ax') then
          begin

            if(GAsm2.Derleyici.Mimari <> mim16Bit) then KodEkle($66);
            KodEkle($E5);
            Result := SayisalDegerEkle(SI.B1.SabitDeger, vgB1);
          end
          else if(YazmacListesi[SI.B1.Yazmac].Ad = 'eax') then
          begin

            if(GAsm2.Derleyici.Mimari =  mim16Bit) then KodEkle($66);
            KodEkle($E5);
            Result := SayisalDegerEkle(SI.B1.SabitDeger, vgB1);
          end else Result := HATA_ISL_KOD_KULLANIM;
        end else Result := HATA_ISL_KOD_KULLANIM;
      end else Result := HATA_VERI_GENISLIGI;
    end
    else if(SI.B2.BolumAnaTip = batYazmac) then
    begin

      if(YazmacListesi[SI.B2.Yazmac].Ad = 'dx') then
      begin

        if(SI.B1.BolumAnaTip = batYazmac) then
        begin

          if(YazmacListesi[SI.B1.Yazmac].Ad = 'al') then
          begin

            KodEkle($EC);
            Result := HATA_YOK;
          end
          else if(YazmacListesi[SI.B1.Yazmac].Ad = 'ax') then
          begin

            if(GAsm2.Derleyici.Mimari <> mim16Bit) then KodEkle($66);
            KodEkle($ED);
            Result := HATA_YOK;
          end
          else if(YazmacListesi[SI.B1.Yazmac].Ad = 'eax') then
          begin

            if(GAsm2.Derleyici.Mimari =  mim16Bit) then KodEkle($66);
            KodEkle($ED);
            Result := HATA_YOK;
          end else Result := HATA_ISL_KOD_KULLANIM;
        end else Result := HATA_ISL_KOD_KULLANIM;
      end else Result := HATA_ISL_KOD_KULLANIM;
    end else Result := HATA_ISL_KOD_KULLANIM;
  end
  else if(SI.Komut.GNo = GRUP12_OUT) then
  begin

    if(SI.B1.BolumAnaTip = batSayisalDeger) then
    begin

      DegerVG := SayiTipiniAl(SI.B1.SabitDeger);
      if(DegerVG = vgB1) then
      begin

        if(SI.B2.BolumAnaTip = batYazmac) then
        begin

          if(YazmacListesi[SI.B2.Yazmac].Ad = 'al') then
          begin

            KodEkle($E6);
            Result := SayisalDegerEkle(SI.B1.SabitDeger, vgB1);
          end
          else if(YazmacListesi[SI.B2.Yazmac].Ad = 'ax') then
          begin

            if(GAsm2.Derleyici.Mimari <> mim16Bit) then KodEkle($66);
            KodEkle($E7);
            Result := SayisalDegerEkle(SI.B1.SabitDeger, vgB1);
          end
          else if(YazmacListesi[SI.B2.Yazmac].Ad = 'eax') then
          begin

            if(GAsm2.Derleyici.Mimari =  mim16Bit) then KodEkle($66);
            KodEkle($E7);
            Result := SayisalDegerEkle(SI.B1.SabitDeger, vgB1);
          end else Result := HATA_ISL_KOD_KULLANIM;
        end else Result := HATA_ISL_KOD_KULLANIM;
      end else Result := HATA_VERI_GENISLIGI;
    end
    else if(SI.B1.BolumAnaTip = batYazmac) then
    begin

      if(YazmacListesi[SI.B1.Yazmac].Ad = 'dx') then
      begin

        if(SI.B2.BolumAnaTip = batYazmac) then
        begin

          if(YazmacListesi[SI.B2.Yazmac].Ad = 'al') then
          begin

            KodEkle($EE);
            Result := HATA_YOK;
          end
          else if(YazmacListesi[SI.B2.Yazmac].Ad = 'ax') then
          begin

            if(GAsm2.Derleyici.Mimari <> mim16Bit) then KodEkle($66);
            KodEkle($EF);
            Result := HATA_YOK;
          end
          else if(YazmacListesi[SI.B2.Yazmac].Ad = 'eax') then
          begin

            if(GAsm2.Derleyici.Mimari =  mim16Bit) then KodEkle($66);
            KodEkle($EF);
            Result := HATA_YOK;
          end else Result := HATA_ISL_KOD_KULLANIM;
        end else Result := HATA_ISL_KOD_KULLANIM;
      end else Result := HATA_ISL_KOD_KULLANIM;
    end else Result := HATA_ISL_KOD_KULLANIM;
  end
  else
  begin

    case SI.Komut.GNo of
      GRUP12_ADC:   begin Result := HATA_DEVAM_EDEN_CALISMA; Exit; end;
      GRUP12_IMUL:  begin Result := HATA_DEVAM_EDEN_CALISMA; Exit; end;
      GRUP12_MOVSX: begin Result := HATA_DEVAM_EDEN_CALISMA; Exit; end;
      GRUP12_MOVZX: begin Result := HATA_DEVAM_EDEN_CALISMA; Exit; end;
      GRUP12_SBB:   begin Result := HATA_DEVAM_EDEN_CALISMA; Exit; end;
      GRUP12_TEST:  begin Result := HATA_DEVAM_EDEN_CALISMA; Exit; end;
    end;

    // yazmaçtan yazmaca koşulsuz atamalar buraya eklenecek
    if(SI.B1.BolumAnaTip = batYazmac) and
      (SI.B2.BolumAnaTip = batYazmac) then
    begin

      // RCL ve diğer komutlar tamamlanmadı!
      case SI.Komut.GNo of
        {YazmacYazmacKodla işlevleri YazmacKodla olarak değiştirilecek
        GRUP12_RCL: Result := YazmacYazmacKodla($D2, $02, SI,
          GYazmac1, GYazmac2);
        GRUP12_RCR: Result := YazmacYazmacKodla($D2, $03, SI,
          GYazmac1, GYazmac2);
        GRUP12_ROL: Result := YazmacYazmacKodla($D2, $00, SI,
          GYazmac1, GYazmac2);
        GRUP12_ROR: Result := YazmacYazmacKodla($D2, $01, SI,
          GYazmac1, GYazmac2);
        // 2 işlem kodu da aynı. merak etme, hata yok!
        GRUP12_SAL,
        GRUP12_SHL: Result := YazmacYazmacKodla($D2, $04, SI,
          GYazmac1, GYazmac2);
        GRUP12_SAR: Result := YazmacYazmacKodla($D2, $07, SI,
          GYazmac1, GYazmac2);
        GRUP12_SHR: Result := YazmacYazmacKodla($D2, $05, SI,
          GYazmac1, GYazmac2);}

        GRUP12_ADD:   Result := YazmacKodla($00, $01, SI.B1.Yazmac, SI.B2.Yazmac, SI);
        GRUP12_AND:   Result := YazmacKodla($20, $21, SI.B1.Yazmac, SI.B2.Yazmac, SI);
        GRUP12_CMP:   Result := YazmacKodla($38, $39, SI.B1.Yazmac, SI.B2.Yazmac, SI);
        // GRUP12_LEA: bu komutun yazmaçtan yazmaça ataması yok
        GRUP12_MOV:   Result := YazmacKodla($88, $89, SI.B1.Yazmac, SI.B2.Yazmac, SI);
        GRUP12_OR:    Result := YazmacKodla($08, $09, SI.B1.Yazmac, SI.B2.Yazmac, SI);
        GRUP12_SUB:   Result := YazmacKodla($28, $29, SI.B1.Yazmac, SI.B2.Yazmac, SI);
        GRUP12_XCHG:  Result := YazmacKodla($86, $87, SI.B1.Yazmac, SI.B2.Yazmac, SI);
        GRUP12_XOR:   Result := YazmacKodla($30, $31, SI.B1.Yazmac, SI.B2.Yazmac, SI);
        else Result := HATA_ISL_KOD_KULLANIM;
      end;
    end
    // İşlemKodu Yazmaç,[Bellek] atamaları buraya eklenecek
    else if(SI.B1.BolumAnaTip = batYazmac) and
      (SI.B2.BolumAnaTip = batBellek) then
    begin

      case SI.Komut.GNo of

        GRUP12_MOV:   Result := YazmacaBellekBolgesiAta(True, $8A, $8B);
        else Result := HATA_ISL_KOD_KULLANIM;
      end;
    end
    // İşlemKodu Yazmaç,[Bellek] atamaları buraya eklenecek
    else if(SI.B1.BolumAnaTip = batBellek) and
      (SI.B2.BolumAnaTip = batYazmac) then
    begin

      case SI.Komut.GNo of

        GRUP12_MOV:   Result := YazmacaBellekBolgesiAta(False, $88, $89);
        else Result := HATA_ISL_KOD_KULLANIM;
      end;
    end
    // yazmaça sayısal değer aktarma işlemi olarak geliştirilecek.
    // dönüşüm aşamalı olarak gerçekleştirilecek.
    // bunun için alt satırdaki kodların toparlanmaları gerekmektedir.
    else if((SI.Komut.GNo = GRUP12_RCL) or
      (SI.Komut.GNo = GRUP12_RCR) or
      (SI.Komut.GNo = GRUP12_ROL) or
      (SI.Komut.GNo = GRUP12_ROR) or
      (SI.Komut.GNo = GRUP12_SAL) or
      (SI.Komut.GNo = GRUP12_SAR) or
      (SI.Komut.GNo = GRUP12_SHL) or
      (SI.Komut.GNo = GRUP12_SHR)) then
    begin

      DegerVG := SayiTipiniAl(SI.B1.SabitDeger);
      if(DegerVG < GSabitDegerVG) then DegerVG := GSabitDegerVG;

      // sabit değer 1 değerinin değerlendirilmesi
      if(DegerVG = vgB1) and (SI.B1.SabitDeger= 1) then
      begin

        case SI.Komut.GNo of
          GRUP12_RCL: Result := YazmacKodla($D0, $D1, SI.B1.Yazmac, 2, SI);
          GRUP12_RCR: Result := YazmacKodla($D0, $D1, SI.B1.Yazmac, 3, SI);
          GRUP12_ROL: Result := YazmacKodla($D0, $D1, SI.B1.Yazmac, 0, SI);
          GRUP12_ROR: Result := YazmacKodla($D0, $D1, SI.B1.Yazmac, 1, SI);
          GRUP12_SAL, // SAL ve SHL işlem kodları aynı. merak etme, hata yok!
          GRUP12_SHL: Result := YazmacKodla($D0, $D1, SI.B1.Yazmac, 4, SI);
          GRUP12_SAR: Result := YazmacKodla($D0, $D1, SI.B1.Yazmac, 7, SI);
          GRUP12_SHR: Result := YazmacKodla($D0, $D1, SI.B1.Yazmac, 5, SI);
        end;
      end
      // sabit değer 1 byte değerinin değerlendirilmesi
      else if(DegerVG = vgB1) then
      begin

        case SI.Komut.GNo of
          GRUP12_RCL: Result := YazmacKodla($C0, $C1, SI.B1.Yazmac, 2, SI);
          GRUP12_RCR: Result := YazmacKodla($C0, $C1, SI.B1.Yazmac, 3, SI);
          GRUP12_ROL: Result := YazmacKodla($C0, $C1, SI.B1.Yazmac, 0, SI);
          GRUP12_ROR: Result := YazmacKodla($C0, $C1, SI.B1.Yazmac, 1, SI);
          GRUP12_SAL, // SAL ve SHL işlem kodları aynı. merak etme, hata yok!
          GRUP12_SHL: Result := YazmacKodla($C0, $C1, SI.B1.Yazmac, 4, SI);
          GRUP12_SAR: Result := YazmacKodla($C0, $C1, SI.B1.Yazmac, 7, SI);
          GRUP12_SHR: Result := YazmacKodla($C0, $C1, SI.B1.Yazmac, 5, SI);
        end;

        if(Result = HATA_YOK) then Result := SayisalDegerEkle(SI.B1.SabitDeger, vgB1);
      end
    end
    // uygulanan komut
    // cmp     eax,1
    // db      83h, 0F8h, 00h
    else if(SI.Komut.GNo = GRUP12_CMP) then
    begin

      // 32 bitlik yazmaca 8 bitlik veri aktarılıyor
      if(YazmacListesi[SI.B1.Yazmac].Uzunluk = yu32bGY) then
      begin

        KodEkle($83);
        KodEkle($C0 + (7 shl 3) + (YazmacListesi[SI.B1.Yazmac].Deger and 7));
        KodEkle(SI.B1.SabitDeger);
        Result := HATA_YOK;
      end else Result := HATA_BILINMEYEN_HATA;
    end
    else if(SI.Komut.GNo = GRUP12_ADD) then
    begin

      if(SI.B1.BolumAnaTip = batYazmac) and
        (SI.B2.BolumAnaTip = batSayisalDeger) then
      begin

        if(YazmacListesi[SI.B1.Yazmac].Uzunluk = yu8bGY) then
        begin

          Result := YazmacKodla($80, $81, SI.B1.Yazmac, 0, SI);
          if(Result = HATA_YOK) then Result := SayisalDegerEkle(SI.B1.SabitDeger, vgB1);
        end
        else if(YazmacListesi[SI.B1.Yazmac].Uzunluk = yu16bGY) then
        begin

          Result := YazmacKodla($80, $81, SI.B1.Yazmac, 0, SI);
          if(Result = HATA_YOK) then Result := SayisalDegerEkle(SI.B1.SabitDeger, vgB2);
        end
        // 32 ve 64 bitlik yazmaç 32 bitlik değer kullanıyor
        else if(YazmacListesi[SI.B1.Yazmac].Uzunluk = yu16bGY) then
        begin

          Result := YazmacKodla($80, $81, SI.B1.Yazmac, 0, SI);
          if(Result = HATA_YOK) then Result := SayisalDegerEkle(SI.B1.SabitDeger, vgB4);
        end
      end else Result := HATA_BILINMEYEN_HATA;
    end
    else
    begin

      if(SI.Komut.GNo = GRUP12_MOV) or
        (SI.Komut.GNo = GRUP12_SUB) or
        (SI.Komut.GNo = GRUP12_LEA) then
      begin

        // bu kısımdaki veriler yazmaçlara sabir veri aktarma şeklindedir
        // 8 bitlik veri
        if(YazmacListesi[SI.B1.Yazmac].Uzunluk = yu8bGY) then
        begin

          Result := IslemKoduIleYazmacDegeriniBirlestir2($B0, $B8, 0, SI);
          if(Result = HATA_YOK) then SayisalDegerEkle(SI.B1.SabitDeger, vgB1);
        end
        // 16 bitlik veri
        else if(YazmacListesi[SI.B1.Yazmac].Uzunluk = yu16bGY) then
        begin

          Result := IslemKoduIleYazmacDegeriniBirlestir2($B0, $B8, 0, SI);
          if(Result = HATA_YOK) then SayisalDegerEkle(SI.B1.SabitDeger, vgB2);
        end
        // 32 bitlik veri
        else if(YazmacListesi[SI.B1.Yazmac].Uzunluk = yu32bGY) then
        begin

          // 32 bitlik bellek alanına bellek değeri aktarılacaksa
          if(SI.B2.BolumAnaTip = batBellek) then
          begin

            { TODO : mov  eax,[bellek_adresi] için geçici olarak eklendi. genişletilecek }
            KodEkle($A1);
            for i := 1 to 4 do
            begin

              KodEkle(Byte(SI.B2.SabitDeger));
              SI.B2.SabitDeger := SI.B2.SabitDeger shr 8;
            end;
            Result := HATA_YOK;
          end
          else
          begin

            Result := IslemKoduIleYazmacDegeriniBirlestir2($B0, $B8, 0, SI);
            if(Result = HATA_YOK) then SayisalDegerEkle(SI.B1.SabitDeger, vgB4);
          end;
        end
        // 64 bitlik yazmaça sabit değer aktarma işlemi
        else if(YazmacListesi[SI.B1.Yazmac].Uzunluk = yu64bGY) then
        begin

          if(GAsm2.Derleyici.Mimari = mim64Bit) then
          begin

            if(SI.Komut.GNo = GRUP12_LEA) then
            begin

              if(SI.B2.BolumAnaTip = batBellek) then
              begin

                KodEkle($8D);
                KodEkle(((YazmacListesi[SI.B1.Yazmac].Deger and 7) shl 3) or 5);

                i4 := SI.B2.SabitDeger - MevcutBellekAdresi;
                i4 := i4 - 6 + 2;

                for i := 1 to 4 do
                begin

                  KodEkle(Byte(i4));
                  i4 := i4 shr 8;
                end;
                Result := HATA_YOK;

              end else Result := HATA_ISL_KOD_KULLANIM;
            end
            // İşlem Kodu
            else if(SI.Komut.GNo = GRUP12_MOV) then
            begin

              // 64 bitlik başvuru hatalı olabilir. test edilecek
              Result := IslemKoduIleYazmacDegeriniBirlestir2($C6, $C7,  0, SI);

              for i := 1 to 4 do
              begin

                KodEkle(Byte(SI.B1.SabitDeger));
                SI.B1.SabitDeger := SI.B1.SabitDeger shr 8;
              end;
              Result := HATA_YOK;
            end
            // sub     rsp,8*5 -> 64 bitlik yazmaça 8 bit değer atama
            else if(SI.Komut.GNo = GRUP12_SUB) then
            begin

              Result := YazmacKodla($80, $83, SI.B1.Yazmac, 5, SI);
              KodEkle(Byte(SI.B1.SabitDeger));
              Result := HATA_YOK;
            end;
          end else Result := HATA_64BIT_MIMARI_GEREKLI;
        end else Result := HATA_BILINMEYEN_HATA;
      end
      else if(SI.Komut.GNo = GRUP12_XOR) then
      begin

        Result := HATA_DEVAM_EDEN_CALISMA;
      end
      else if(SI.Komut.GNo = GRUP12_OR) then
      begin

        Result := HATA_DEVAM_EDEN_CALISMA;
      end else Result := 1;
    end;
  end;
end;

end.
