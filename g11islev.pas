{-------------------------------------------------------------------------------

  Dosya: g11islev.pas

  İşlev: 11. grup kodlama işlevlerini gerçekleştirir

  11. grup kodlama işlevi, tek parametreli yazmaç, sabit değer ve segment
    değerlerinin işlendiği komutlardır

  Güncelleme Tarihi: 02/10/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit g11islev;

interface

uses Classes, SysUtils, genel, paylasim;

function Grup11Islev: Integer;

implementation

uses kodlama, komutlar, yazmaclar, donusum, onekler, hataayiklama;

function Grup11Islev: Integer;
var
  SayiTipi: TVeriGenisligi;
  SayisalVeri, VeriGenisligi, i: Integer;
  ii: Byte;
  i4: Integer;
begin

  Result := HATA_YOK;
  Exit;

  if(SI.Komut.GNo = GRUP11_BSWAP) then
  begin

    if(SI.B1.BolumAnaTip = batYazmac) then
    begin

      // 1. yazmaç, 32 bitlik ise
      if(YazmacListesi[SI.B1.Yazmac].Uzunluk = yu32bGY) then
      begin

        KodEkle($0F);

        // 1.1. yazmaç, 32 bitlik mimaride tanımlanan 32 bitlik yazmaç ise (ör: eax)
        if(YazmacListesi[SI.B1.Yazmac].DesMim = dmTum) then
        begin

          KodEkle($C8 + YazmacListesi[SI.B1.Yazmac].Deger);
          Result := HATA_YOK;
        end
        // 1.1. yazmaç, 64 bitlik mimaride tanımlanan 32 bitlik yazmaç ise (ör: r8d)
        else if(YazmacListesi[SI.B1.Yazmac].DesMim = dm64Bit) then
        begin

          // 1.1.1 64 bitlik yazmaç 64 bitlik mimaride kullanılıyorsa
          if(GAsm2.Derleyici.Mimari = mim64Bit) then
          begin

            KodEkle($41);
            KodEkle($C8 + (YazmacListesi[SI.B1.Yazmac].Deger - 8));
            Result := HATA_YOK;
          end else Result := HATA_64BIT_MIMARI_GEREKLI;
        end;
      end
      // 2. yazmaç, 64 bitlik ise
      else if(YazmacListesi[SI.B1.Yazmac].Uzunluk = yu64bGY) then
      begin

        // 64 bitlik yazmaç 64 bitlik mimaride kullanılıyorsa
        if(GAsm2.Derleyici.Mimari = mim64Bit) then
        begin

          // 2.1. yazmaç, 64 bitlik yazmacın ilk 8 yazmacın haricinde ise
          if(YazmacListesi[SI.B1.Yazmac].Deger > 7) then
          begin

            KodEkle($49);
            KodEkle($0F);
            KodEkle($C8 + (8 - YazmacListesi[SI.B1.Yazmac].Deger));
            Result := HATA_YOK;
          end
          // 2.2. yazmaç, 64 bitlik yazmacın ilk 8 yazmaçtan biri ise
          else
          begin

            KodEkle($48);
            KodEkle($0F);
            KodEkle($C8 + YazmacListesi[SI.B1.Yazmac].Deger);
            Result := HATA_YOK;
          end;
        end else Result := HATA_64BIT_MIMARI_GEREKLI;
      end else Result := HATA_ISL_KOD_KULLANIM;
    end else Result := HATA_YAZMAC_GEREKLI;
  end
  else if(SI.Komut.GNo = GRUP11_NOT) then
  begin

    if(SI.B1.BolumAnaTip = batYazmac) then
    begin

      Result := YazmacKodla($F6, $F7, SI.B1.Yazmac, 2, SI);
    end else Result := HATA_DEVAM_EDEN_CALISMA;
  end
  else if(SI.Komut.GNo = GRUP11_POP) then
  begin

    if(SI.B1.BolumAnaTip = batYazmac) then
    begin

      if((YazmacListesi[SI.B1.Yazmac].Uzunluk = yu16bGY) or
        ((YazmacListesi[SI.B1.Yazmac].Uzunluk = yu32bGY) and (GAsm2.Derleyici.Mimari <> mim64Bit)) or
        ((YazmacListesi[SI.B1.Yazmac].Uzunluk = yu64bGY) and (GAsm2.Derleyici.Mimari = mim64Bit))) then
      begin

        Result := IslemKoduIleYazmacDegeriniBirlestir($58, $58, SI.B1.Yazmac);

      end else Result := HATA_ISL_KOD_KULLANIM;
    end
    { TODO : bu aşamadaki çalışma g12islev bellek çalışmasıyla birleştirilecek }
    { TODO : bu kısımdaki bellek çalışması diğer bellek çalışmalarının da öncüsü olacak }
    else if(SI.B1.BolumAnaTip = batBellek) then
    begin

      if(YazmacListesi[SI.B1.Yazmac].Uzunluk = yu32bGY) then
      begin

        KodEkle($8F);
        KodEkle(YazmacListesi[SI.B1.Yazmac].Deger);
        Result := HATA_YOK;
      end else Result := HATA_DEVAM_EDEN_CALISMA;
    end else Result := HATA_DEVAM_EDEN_CALISMA;

    {if(SI.BolumTip1.BolumAnaTip = batBellek) then
    begin

      i4 := GBellekSabitDeger;

      KodEkle($D9);
      KodEkle($05);

      for i := 1 to 4 do
      begin

        KodEkle(Byte(i4));
        i4 := i4 shr 8;
      end;

      Result := HATA_YOK;
    end else Result := HATA_DEVAM_EDEN_CALISMA;}
  end
  else if(SI.Komut.GNo = GRUP11_PUSH) then
  begin

    if(SI.B1.BolumAnaTip = batYazmac) then
    begin

      // 16 bitlik bölüm (segment) yazmacı ise
      if(YazmacListesi[SI.B1.Yazmac].Uzunluk = yu16bBY) then
      begin

        // fs ve gs bölüm yazmacı her mimaride kullanılabilir
        if(YazmacListesi[SI.B1.Yazmac].Ad = 'fs') then
        begin

          KodEkle($0F);
          KodEkle($A0);
          Result := HATA_YOK;
        end
        else if(YazmacListesi[SI.B1.Yazmac].Ad = 'gs') then
        begin

          KodEkle($0F);
          KodEkle($A8);
          Result := HATA_YOK;
        end
        else
        begin

          // aşağıdaki 4 yazmaç 64 mimari haricinde kullanılabilir
          if(GAsm2.Derleyici.Mimari = mim64Bit) then

            Result := HATA_HATALI_MIMARI64
          else
          begin

            case YazmacListesi[SI.B1.Yazmac].Ad of
              'cs': begin KodEkle($0E); Result := HATA_YOK; end;
              'ss': begin KodEkle($16); Result := HATA_YOK; end;
              'ds': begin KodEkle($1E); Result := HATA_YOK; end;
              'es': begin KodEkle($06); Result := HATA_YOK; end;
              else Result := HATA_ISL_KULLANIM;
            end;
          end;
        end;
      end
      else
      begin

        if((YazmacListesi[SI.B1.Yazmac].Uzunluk = yu16bGY) or
          ((YazmacListesi[SI.B1.Yazmac].Uzunluk = yu32bGY) and (GAsm2.Derleyici.Mimari <> mim64Bit)) or
          ((YazmacListesi[SI.B1.Yazmac].Uzunluk = yu64bGY) and (GAsm2.Derleyici.Mimari = mim64Bit))) then
        begin

          Result := IslemKoduIleYazmacDegeriniBirlestir($50, $50, SI.B1.Yazmac);

        end else Result := HATA_ISL_KOD_KULLANIM;
      end;
    end
    { TODO : test edilecek }
    else if(SI.B1.BolumAnaTip = batSayisalDeger) then
    begin

      i4 := SI.B1.SabitDeger;
      SayiTipi := SayiTipiniAl(i4);

      // eğer önek sayı değerinden büyükse sayı değerinin veri
      // genişliğini önek olarak ayarla
      if(GSabitDegerVG > SayiTipi) then SayiTipi := GSabitDegerVG;

      // 64 bitlik sayıyı hiçbir mimari desteklememektedir
      if(SayiTipi = vgB8) then

        Result := HATA_ISL_KOD_KULLANIM
      // 32 bitlik sayıyı 16 bitlik mimari desteklememektedir
      else if(SayiTipi = vgB4) and (GAsm2.Derleyici.Mimari = mim16Bit) then

        Result := HATA_ISL_KOD_KULLANIM
      else
      begin

        case SayiTipi of
          //stHatali: // şu aşamada değerlendirilmesi gereksiz
          vgB1: begin KodEkle($6A); VeriGenisligi := 1; end;
          vgB2: begin KodEkle($68); VeriGenisligi := 2; end;
          vgB4: begin KodEkle($68); VeriGenisligi := 4; end;
          // 64 bitlik sayı değeri geçerli değildir
        end;

        // sayısal veriyi belleğe yaz
        SayisalVeri := i4;
        for i := 1 to VeriGenisligi do
        begin

          KodEkle(Byte(SayisalVeri));
          SayisalVeri := SayisalVeri shr 8;
        end;
        Result := HATA_YOK;
      end;
    end
    { TODO : bu aşamadaki çalışma g12islev bellek çalışmasıyla birleştirilecek }
    { TODO : bu kısımdaki bellek çalışması diğer bellek çalışmalarının da öncüsü olacak }
    else if(SI.B1.BolumAnaTip = batBellek) then
    begin

      if(YazmacListesi[SI.B1.YazmacB1].Uzunluk = yu32bGY) then
      begin

        KodEkle($FF);
        KodEkle((6 shl 3) + YazmacListesi[SI.B1.YazmacB1].Deger);
        Result := HATA_YOK;
      end else Result := HATA_DEVAM_EDEN_CALISMA;
    end else Result := HATA_DEVAM_EDEN_CALISMA;
  end
  { TODO : test edilecek }
  else if(SI.Komut.GNo = GRUP11_FLD) then
  begin

    if(SI.B1.BolumAnaTip = batBellek) then
    begin

      if(GSabitDegerVG = vgB4) or (GSabitDegerVG = vgB8) or
        (GSabitDegerVG = vgB10) then
      begin

        if(GSabitDegerVG = vgB4) then
        begin

          KodEkle($D9);
          KodEkle($05);
        end
        else if(GSabitDegerVG = vgB8) then
        begin

          KodEkle($DD);
          KodEkle($05);
        end
        else if(GSabitDegerVG = vgB10) then
        begin

          KodEkle($DB);
          KodEkle($2D);
        end;

        Result := SayisalDegerEkle(SI.B1.SabitDeger, vgB4);
      end else Result := HATA_VERI_GENISLIGI;
    end
    else if(SI.B1.BolumAnaTip = batYazmac) then
    begin

      if(YazmacListesi[SI.B1.Yazmac].Uzunluk = yu80bYN) then
      begin

        KodEkle($D9);
        KodEkle($C0 + YazmacListesi[SI.B1.Yazmac].Deger);
        Result := HATA_YOK;
      end else Result := HATA_ISL_KOD_KULLANIM;
    end else Result := HATA_ISL_KOD_KULLANIM;
  end
  else if(SI.Komut.GNo = GRUP11_FXCH) then
  begin

    if(SI.B1.BolumAnaTip = batYok) then
    begin

      KodEkle($D9);
      KodEkle($C9);
      Result := HATA_YOK;
    end
    else if(SI.B1.BolumAnaTip = batYazmac) then
    begin

      if(YazmacListesi[SI.B1.Yazmac].Uzunluk = yu80bYN) then
      begin

        KodEkle($D9);
        KodEkle($C8 + YazmacListesi[SI.B1.Yazmac].Deger);
        Result := HATA_YOK;
      end else Result := HATA_ISL_KOD_KULLANIM;
    end else Result := HATA_ISL_KOD_KULLANIM;
  end
  // sgdt ve sidt işlem kodlarına yazmaç bellek adresleme eklenecek
  // ve ortak noktada birleştirilecek
  { TODO : test edilecek }
  else if(SI.Komut.GNo = GRUP11_SGDT) then
  begin

    if(SI.B1.BolumAnaTip = batBellek) then
    begin

      KodEkle($0F);
      KodEkle($01);
      KodEkle($05);

      i4 := SI.B1.SabitDeger;

      for i := 1 to 4 do
      begin

        KodEkle(Byte(i4));
        i4 := i4 shr 8;
      end;

      Result := HATA_YOK;
    end else Result := HATA_ISL_KULLANIM;
  end
  { TODO : test edilecek }
  else if(SI.Komut.GNo = GRUP11_SIDT) then
  begin

    if(SI.B1.BolumAnaTip = batBellek) then
    begin

      KodEkle($0F);
      KodEkle($01);
      KodEkle((1 shl 3) or 5);

      i4 := SI.B1.SabitDeger;

      for i := 1 to 4 do
      begin

        KodEkle(Byte(i4));
        i4 := i4 shr 8;
      end;

      Result := HATA_YOK;
    end else Result := HATA_ISL_KULLANIM;
  end
  { TODO : test edilecek }
  else if(SI.Komut.GNo = GRUP11_FSTP) then
  begin

    if(SI.B1.BolumAnaTip = batBellek) then
    begin

      i4 := SI.B1.SabitDeger;

      KodEkle($D9);
      KodEkle($1D);

      for i := 1 to 4 do
      begin

        KodEkle(Byte(i4));
        i4 := i4 shr 8;
      end;

      Result := HATA_YOK;
    end else Result := HATA_DEVAM_EDEN_CALISMA;
  end
  // int komutu
  else if(SI.Komut.GNo = GRUP11_INT) then
  begin

    // int 03
    if(SI.B1.SabitDeger = 3) then

      KodEkle($CC)
    else
    // int xx
    begin

      KodEkle($CD);
      KodEkle(SI.B1.SabitDeger);
    end;

    Result := HATA_YOK;
  end
  // ret komutu
  else if(SI.Komut.GNo = GRUP11_RET) or
    (SI.Komut.GNo = GRUP11_RETF) or
    (SI.Komut.GNo = GRUP11_RETN) then
  begin

    if(SI.B1.BolumAnaTip = batSayisalDeger) then
    begin

      i4 := SI.B1.SabitDeger;
      SayiTipi := SayiTipiniAl(i4);

      // 16 bit öndeğere sahip ret / retn komutu
      if(SayiTipi = vgB1) or (SayiTipi = vgB2) then
      begin

        if(SI.Komut.GNo = GRUP11_RET) or
          (SI.Komut.GNo = GRUP11_RETN) then
        begin

          KodEkle($C2);
          KodEkle(Byte(i4));
          i4 := i4 shr 8;
          KodEkle(Byte(i4));
        end
        else if(SI.Komut.GNo = GRUP11_RETF) then
        begin

          KodEkle($CA);
          KodEkle(Byte(i4));
          i4 := i4 shr 8;
          KodEkle(Byte(i4));
        end;

        Result := HATA_YOK;
      end else Result := HATA_ISL_KOD_KULLANIM;
    end
    else if(SI.B1.BolumAnaTip = batYok) then
    begin

      if(SI.Komut.GNo = GRUP11_RET) or
        (SI.Komut.GNo = GRUP11_RETN) then

        KodEkle($C3)
      else if(SI.Komut.GNo = GRUP11_RETF) then

        KodEkle($CB);

      Result := HATA_YOK;
    end;
  end
  // call komutu
  // FF /2
  // = $FF + 00 010 101 (101 = displacement)
  { TODO : test edilecek }
  else if(SI.Komut.GNo = GRUP11_CALL) then
  begin

    // call [bellek_adresi] ; bellek adresine direkt adres çağrısı
    if(SI.B1.BolumAnaTip = batBellek) then
    begin

      KodEkle($FF);
      KodEkle($10 + $5);

      if(biSabitDeger in SI.B1.BellekIcerik) then
      begin

        Result := SayisalDegerEkle(SI.B1.SabitDeger, vgB4);
      end;
    end
    // call bellek_adresi  ; komut sonrasından itibaren ilgili noktaya göreceli çağrı
    else if(SI.B1.BolumAnaTip = batSayisalDeger) then
    begin

      KodEkle($E8);

      i4 := (SI.B1.SabitDeger - MevcutBellekAdresi);
      i4 := i4 - 5 + 1;

      for i := 1 to 4 do
      begin

        KodEkle(Byte(i4));
        i4 := i4 shr 8;
      end;

      Result := HATA_YOK;
    end;
  end
  else if(SI.Komut.GNo = GRUP11_DEC) or
    (SI.Komut.GNo = GRUP11_INC) then
  begin

    if(SI.B1.BolumAnaTip = batYazmac) then
    begin

      if(SI.Komut.GNo = GRUP11_DEC) then
      begin

        if(GAsm2.Derleyici.Mimari = mim16Bit) or (GAsm2.Derleyici.Mimari = mim32Bit) then
        begin

          if(YazmacListesi[SI.B1.Yazmac].Uzunluk = yu16bGY) or
            (YazmacListesi[SI.B1.Yazmac].Uzunluk = yu32bGY) then
            Result := IslemKoduIleYazmacDegeriniBirlestir($48, $48, SI.B1.Yazmac)
          else Result := YazmacKodla($FE, $FF, SI.B1.Yazmac, 1, SI);
        end else Result := YazmacKodla($FE, $FF, SI.B1.Yazmac, 1, SI);
      end
      else // if(SI.Komut.GrupNo = GRUP11_INC) then
      begin

        if(GAsm2.Derleyici.Mimari = mim16Bit) or (GAsm2.Derleyici.Mimari = mim32Bit) then
        begin

          if(YazmacListesi[SI.B1.Yazmac].Uzunluk = yu16bGY) or
            (YazmacListesi[SI.B1.Yazmac].Uzunluk = yu32bGY) then
            Result := IslemKoduIleYazmacDegeriniBirlestir($40, $40, SI.B1.Yazmac)
          else Result := YazmacKodla($FE, $FF, SI.B1.Yazmac, 0, SI);
        end else Result := YazmacKodla($FE, $FF, SI.B1.Yazmac, 0, SI);
      end;
    end
    else if(SI.B1.BolumAnaTip = batBellek) then
    begin

      BellekIcerikVerileriniGoruntule(SI.B1);

      if(SI.Komut.GNo = GRUP11_DEC) then
      begin

        Result := BellekAdresle($FE, $FF, 1, SI);
      end
      else // if(SI.Komut.GrupNo = GRUP11_INC) then
      begin

        Result := BellekAdresle($FE, $FF, 0, SI);
      end;
    end else Result := HATA_DEVAM_EDEN_CALISMA;
  end
  // div komutu
  // F7 /6
  // = $F7 + 00 110 000
  else if(SI.Komut.GNo = GRUP11_DIV) then
  begin

    Result := YazmacKodla($F6, $F7, SI.B1.Yazmac, 6, SI);
  end
  else if(SI.Komut.GNo = GRUP11_JMP) then
  begin

    // GSabitDeger verisi byte olarak değerlendirildi.
    // diğer (16 / 32 / 64 bit) veriler de değerlendiirlecek
    if(SI.B1.SabitDeger < (MevcutBellekAdresi + 2)) then
      ii := -((MevcutBellekAdresi + 2) - SI.B1.SabitDeger)
    else ii := SI.B1.SabitDeger - (MevcutBellekAdresi + 2);

    KodEkle($EB);

    KodEkle(ii);
    Result := HATA_YOK;
  end
  // jcc komutları
  else
  begin

    case SI.Komut.GNo of
      GRUP11_JA     : Result := GoreceliDegerEkle(GRUP11_JA, $77);
      GRUP11_JAE    : Result := GoreceliDegerEkle(GRUP11_JAE, $73);
      GRUP11_JB     : Result := GoreceliDegerEkle(GRUP11_JB, $72);
      GRUP11_JBE    : Result := GoreceliDegerEkle(GRUP11_JBE, $76);
      GRUP11_JC     : Result := GoreceliDegerEkle(GRUP11_JC, $72);
      GRUP11_JCXZ   : Result := GoreceliDegerEkle(GRUP11_JCXZ, $E3);
      GRUP11_JECXZ  : Result := GoreceliDegerEkle(GRUP11_JECXZ, $E3);
      GRUP11_JRCXZ  : Result := GoreceliDegerEkle(GRUP11_JRCXZ, $E3);
      GRUP11_JE     : Result := GoreceliDegerEkle(GRUP11_JE, $74);
      GRUP11_JG     : Result := GoreceliDegerEkle(GRUP11_JG, $7F);
      GRUP11_JGE    : Result := GoreceliDegerEkle(GRUP11_JGE, $7D);
      GRUP11_JL     : Result := GoreceliDegerEkle(GRUP11_JL, $7C);
      GRUP11_JLE    : Result := GoreceliDegerEkle(GRUP11_JLE, $7E);
      GRUP11_JNA    : Result := GoreceliDegerEkle(GRUP11_JNA, $77);
      GRUP11_JNAE   : Result := GoreceliDegerEkle(GRUP11_JNAE, $76);
      GRUP11_JNB    : Result := GoreceliDegerEkle(GRUP11_JNB, $73);
      GRUP11_JNBE   : Result := GoreceliDegerEkle(GRUP11_JNBE, $77);
      GRUP11_JNC    : Result := GoreceliDegerEkle(GRUP11_JNC, $73);
      GRUP11_JNE    : Result := GoreceliDegerEkle(GRUP11_JNE, $75);
      GRUP11_JNG    : Result := GoreceliDegerEkle(GRUP11_JNG, $7E);
      GRUP11_JNGE   : Result := GoreceliDegerEkle(GRUP11_JNGE, $7C);
      GRUP11_JNL    : Result := GoreceliDegerEkle(GRUP11_JNL, $7D);
      GRUP11_JNLE   : Result := GoreceliDegerEkle(GRUP11_JNLE, $7F);
      GRUP11_JNO    : Result := GoreceliDegerEkle(GRUP11_JNO, $71);
      GRUP11_JNP    : Result := GoreceliDegerEkle(GRUP11_JNP, $7B);
      GRUP11_JNS    : Result := GoreceliDegerEkle(GRUP11_JNS, $79);
      GRUP11_JNZ    : Result := GoreceliDegerEkle(GRUP11_JNZ, $75);
      GRUP11_JO     : Result := GoreceliDegerEkle(GRUP11_JO, $70);
      GRUP11_JP     : Result := GoreceliDegerEkle(GRUP11_JP, $7A);
      GRUP11_JPE    : Result := GoreceliDegerEkle(GRUP11_JPE, $7A);
      GRUP11_JPO    : Result := GoreceliDegerEkle(GRUP11_JPO, $7B);
      GRUP11_JS     : Result := GoreceliDegerEkle(GRUP11_JS, $78);
      GRUP11_JZ     : Result := GoreceliDegerEkle(GRUP11_JZ, $74);
      else Result := 1;
    end;
  end;
end;

// 5.2 - yazmaça sayısal değer ata
// REGDeger = MOD[7..6] + REG[5..3] + RM[2..0]
function SayisalDegerAta(IslemKodu, REGDeger: Byte; SI: TSatirIcerik;
  Yazmac, SabitDeger: Integer; SayisalDegerVar: Boolean): Integer;
begin

  // derlenecek kod mimarisi 64 bit ise...
  if(GAsm2.Derleyici.Mimari = mim64Bit) and (YazmacListesi[Yazmac].Uzunluk = yu64bGY) then

    // 0100W000 = W = 1 = 64 bit işlem kodu
    KodEkle($48)

  // derlenecek kod mimarisi 32 bit, yazmaç 32 bit değilse...
  // 66 ön ekini kodun başına ekle
  else if(GAsm2.Derleyici.Mimari = mim32Bit) and (YazmacListesi[Yazmac].Uzunluk <> yu32bGY) then

    KodEkle($66)

  // derlenecek kod mimarisi 16 bit, yazmaç 16 bit değilse...
  else if(GAsm2.Derleyici.Mimari = mim16Bit) and (YazmacListesi[Yazmac].Uzunluk <> yu16bGY) then

    KodEkle($66);

  // yazmacın 8 bit olması halinde "IslemKodu" kullanılacak
  // aksi durumda bir sonraki sıra değeri (IslemKodu + 1) kullanılacak
  if(YazmacListesi[Yazmac].Uzunluk = yu8bGY) then

    KodEkle(IslemKodu)
  else KodEkle(IslemKodu + 1);

  // İşlemKodu Hedef_Yazmaç, Kaynak_Yazmaç
  // 11_HY0_KY0 -> 11 = $C0, HY0 = Hedef Yazmaç, KY0 = Kaynak Yazmaç
  // -----------------------
  // $C0 = 11000000b = yazmaç adresleme modu
  KodEkle($C0 or (REGDeger shl 3) or (YazmacListesi[Yazmac].Deger and 7));

  if(SayisalDegerVar) then KodEkle(SabitDeger);

  Result := HATA_YOK;
end;

end.
