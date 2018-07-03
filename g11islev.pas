{-------------------------------------------------------------------------------

  Dosya: g11islev.pas

  İşlev: 11. grup kodlama işlevlerini gerçekleştirir

  11. grup kodlama işlevi, tek parametreli yazmaç, sabit değer ve segment
    değerlerinin işlendiği komutlardır

  Güncelleme Tarihi: 11/05/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit g11islev;

interface

uses Classes, SysUtils, genel, paylasim;

function Grup11Islev(SatirNo: Integer; ParcaNo: Integer; VeriKontrolTip:
  TVeriKontrolTip; Veri1: string; Veri2: QWord): Integer;
procedure GoreceliDegerEkle;
function IslemKodunaYazmacDegeriEkle(IslemKodu, Yazmac: Byte;
  SatirIcerik: TSatirIcerik): Integer;

implementation

uses kodlama, Dialogs, asm2, komutlar, yazmaclar, donusum, dbugintf, onekler,
  degerkodla;

  // ünite içi genel kullanımlık yerel değişkenler
var
  // ifadeyi yorumlayan işlevler tarafından kullanılan genel değişkenler
  ArtiIsleyiciKullanildi: Boolean;
  KoseliParantezSayisi: Integer;

function Grup11Islev(SatirNo: Integer; ParcaNo: Integer;
  VeriKontrolTip: TVeriKontrolTip; Veri1: string; Veri2: QWord): Integer;
var
  SayiTipi: TVeriGenisligi;
  SayisalVeri, VeriGenisligi, i: Integer;
  ii: Byte;
  i4: Integer;
begin

  // ilk parça = işlem kodu verisidir. (opcode)
  // ilk parça ile birlikte Veri2 değeri de komut sıra değerini içerir
  if(VeriKontrolTip = vktIlk) then
  begin

    SatirIcerik.Komut := KomutListesi[Veri2];
    ArtiIsleyiciKullanildi := False;
    KoseliParantezSayisi := 0;
    GYazmacB1OlcekM := False;
    GYazmacB2OlcekM := False;
    Result := HATA_YOK;
    //end;
  end
  // ÖNEMLİ:
  // 1. GParametreTip1 ve GParametreTip2 değişkenlerine anasayfa'da ptYok olarak ilk değer atanıyor
  // 2. GParametreTip1 ve GParametreTip2 değişkenleri vtKPAc kısmında ptBellek olarak atama yapılıyor
  // 3. Köşeli parantez kontrolü vtKPAc sorgulama kısmında gerçekleştiriliyor
  // 4. Sabit sayısal değer (imm) ve ölçek değeri (scale) diğer sorgu aşamalarında atanmaktadır
  else if(VeriKontrolTip = vktYazmac) then
  begin

    // örn: push eax
    if(SatirIcerik.BolumTip1.BolumAnaTip = batYok) then
    begin

      SatirIcerik.BolumTip1.BolumAnaTip := batYazmac;
      SatirIcerik.BolumTip1.BolumAyrinti += [baHedefYazmac];
      GYazmac1 := Veri2;
      Result := HATA_YOK;
    end
    else if(SatirIcerik.BolumTip1.BolumAnaTip = batBellek) then
    begin

      // örn: push [eax]
      if not(baBellekYazmac1 in SatirIcerik.BolumTip1.BolumAyrinti) then
      begin

        SatirIcerik.BolumTip1.BolumAyrinti += [baBellekYazmac1];
        GYazmac1 := Veri2;
        Result := HATA_YOK;
      end
      // örn: push [eax+ebx]
      else if not(baBellekYazmac2 in SatirIcerik.BolumTip1.BolumAyrinti) then
      begin

        SatirIcerik.BolumTip1.BolumAyrinti += [baBellekYazmac2];
        GYazmac2 := Veri2;
        Result := HATA_YOK;
      end else Result := HATA_ISL_KOD_KULLANIM;
    end;
  end
  else if(VeriKontrolTip = vktKPAc) then
  begin

    // daha önce köşeli parantez kullanılmışsa
    if(KoseliParantezSayisi > 0) then

      Result := HATA_ISL_KOD_KULLANIM
    else
    begin

      SatirIcerik.BolumTip1.BolumAnaTip := batBellek;

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

    if(baOlcek in SatirIcerik.BolumTip1.BolumAyrinti) then
    begin

      Result := HATA_OLCEK_ZATEN_KULLANILMIS;
    end
    else
    begin

      if(Veri2 = 1) or (Veri2 = 2) or (Veri2 = 4) or (Veri2 = 8) then
      begin

        SatirIcerik.BolumTip1.BolumAyrinti += [baOlcek];
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
    if(SatirIcerik.BolumTip1.BolumAnaTip = batYok) then
    begin

      SatirIcerik.BolumTip1.BolumAnaTip := batSayisalDeger;
      SatirIcerik.BolumTip1.BolumAyrinti += [baSabitDeger];
      GSabitDeger := Veri2;
      Result := HATA_YOK;
    end
    else if(SatirIcerik.BolumTip1.BolumAnaTip = batBellek) then
    begin

      SatirIcerik.BolumTip1.BolumAyrinti += [baBellekSabitDeger];
      GBellekSabitDeger := Veri2;
      Result := HATA_YOK;
    end else Result := HATA_ISL_KOD_KULLANIM; // geçici
  end
  // son kontroller bu aşamada gerçekleştirilecek
  else if(VeriKontrolTip = vktSon) then
  begin

    if(SatirIcerik.Komut.GrupNo = GRUP11_POP) then
    begin

      if(SatirIcerik.BolumTip1.BolumAnaTip = batYazmac) then
      begin

        // 64 bitlik yazmaçlar 64 bitlik ortamda kullanılıyorsa
        if(YazmacListesi[GYazmac1].Uzunluk = yu64bGY) and (GAsm2.Mimari = mim64Bit) then
        begin

          Result := IslemKodunaYazmacDegeriEkle($58, GYazmac1, SatirIcerik);
        end
        // 16 veya 32 bit genel yazmaç 64 bitlik ortam haricinde kullanılıyorsa
        else if(((YazmacListesi[GYazmac1].Uzunluk = yu16bGY) or
          (YazmacListesi[GYazmac1].Uzunluk = yu32bGY)) and (GAsm2.Mimari <> mim64Bit)) then
        begin

          Result := IslemKodunaYazmacDegeriEkle($58, GYazmac1, SatirIcerik);
        end else Result := HATA_ISL_KOD_KULLANIM;
      end
      { TODO : bu aşamadaki çalışma g12islev bellek çalışmasıyla birleştirilecek }
      { TODO : bu kısımdaki bellek çalışması diğer bellek çalışmalarının da öncüsü olacak }
      else if(SatirIcerik.BolumTip1.BolumAnaTip = batBellek) then
      begin

        if(YazmacListesi[GYazmac1].Uzunluk = yu32bGY) then
        begin

          KodEkle($8F);
          KodEkle(YazmacListesi[GYazmac1].Deger);
          Result := HATA_YOK;
        end else Result := HATA_DEVAM_EDEN_CALISMA;
      end else Result := HATA_DEVAM_EDEN_CALISMA;

      {if(SatirIcerik.BolumTip1.BolumAnaTip = batBellek) then
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
    else if(SatirIcerik.Komut.GrupNo = GRUP11_PUSH) then
    begin

      if(SatirIcerik.BolumTip1.BolumAnaTip = batYazmac) then
      begin

        // 16 bitlik bölüm (segment) yazmacı ise
        if(YazmacListesi[GYazmac1].Uzunluk = yu16bBY) then
        begin

          // fs ve gs bölüm yazmacı her mimaride kullanılabilir
          if(YazmacListesi[GYazmac1].Ad = 'fs') then
          begin

            KodEkle($0F);
            KodEkle($A0);
            Result := HATA_YOK;
          end
          else if(YazmacListesi[GYazmac1].Ad = 'gs') then
          begin

            KodEkle($0F);
            KodEkle($A8);
            Result := HATA_YOK;
          end
          else
          begin

            // aşağıdaki 4 yazmaç 64 mimari haricinde kullanılabilir
            if(GAsm2.Mimari = mim64Bit) then

              Result := HATA_HATALI_MIMARI64
            else
            begin

              case YazmacListesi[GYazmac1].Ad of
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

          // 64 bitlik yazmaçlar 64 bitlik ortamda kullanılıyorsa
          if(YazmacListesi[GYazmac1].Uzunluk = yu64bGY) and (GAsm2.Mimari = mim64Bit) then
          begin

            Result := IslemKodunaYazmacDegeriEkle($50, GYazmac1, SatirIcerik);
          end
          // 16 veya 32 bit genel yazmaç 64 bitlik ortam haricinde kullanılıyorsa
          else if(((YazmacListesi[GYazmac1].Uzunluk = yu16bGY) or
            (YazmacListesi[GYazmac1].Uzunluk = yu32bGY)) and (GAsm2.Mimari <> mim64Bit)) then
          begin

            Result := IslemKodunaYazmacDegeriEkle($50, GYazmac1, SatirIcerik);
          end else Result := HATA_ISL_KOD_KULLANIM;
        end;
      end
      else if(SatirIcerik.BolumTip1.BolumAnaTip = batSayisalDeger) then
      begin

        i4 := GSabitDeger;
        SayiTipi := SayiTipiniAl(i4);

        // eğer önek sayı değerinden büyükse sayı değerinin veri
        // genişliğini önek olarak ayarla
        if(GSabitDegerVG > SayiTipi) then SayiTipi := GSabitDegerVG;

        // 64 bitlik sayıyı hiçbir mimari desteklememektedir
        if(SayiTipi = vgB8) then

          Result := HATA_ISL_KOD_KULLANIM
        // 32 bitlik sayıyı 16 bitlik mimari desteklememektedir
        else if(SayiTipi = vgB4) and (GAsm2.Mimari = mim16Bit) then

          Result := HATA_ISL_KOD_KULLANIM
        else
        begin

          case SayiTipi of
            //stHatali: // şu aşamada değerlendirilmesi gereksiz
            vgB1: begin KodEkle($6A); end;
            vgB2: begin KodEkle($68); end;
            vgB4: begin KodEkle($68); end;
            // 64 bitlik sayı değeri geçerli değildir
          end;

          case SayiTipi of
            //stHatali: // şu aşamada değerlendirilmesi gereksiz
            vgB1: begin VeriGenisligi := 1; end;
            vgB2: begin VeriGenisligi := 2; end;
            vgB4: begin VeriGenisligi := 4; end;
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
      else if(SatirIcerik.BolumTip1.BolumAnaTip = batBellek) then
      begin

        if(YazmacListesi[GYazmac1].Uzunluk = yu32bGY) then
        begin

          KodEkle($FF);
          KodEkle((6 shl 3) + YazmacListesi[GYazmac1].Deger);
          Result := HATA_YOK;
        end else Result := HATA_DEVAM_EDEN_CALISMA;
      end else Result := HATA_DEVAM_EDEN_CALISMA;
    end
    else if(SatirIcerik.Komut.GrupNo = GRUP11_FLD) then
    begin

      if(SatirIcerik.BolumTip1.BolumAnaTip = batBellek) then
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
      end else Result := HATA_DEVAM_EDEN_CALISMA;
    end
    // sgdt ve sidt işlem kodlarına yazmaç bellek adresleme eklenecek
    // ve ortak noktada birleştirilecek
    else if(SatirIcerik.Komut.GrupNo = GRUP11_SGDT) then
    begin

      if(SatirIcerik.BolumTip1.BolumAnaTip = batBellek) then
      begin

        KodEkle($0F);
        KodEkle($01);
        KodEkle($05);

        i4 := GBellekSabitDeger;

        for i := 1 to 4 do
        begin

          KodEkle(Byte(i4));
          i4 := i4 shr 8;
        end;

        Result := HATA_YOK;
      end else Result := HATA_ISL_KULLANIM;
    end
    else if(SatirIcerik.Komut.GrupNo = GRUP11_SIDT) then
    begin

      if(SatirIcerik.BolumTip1.BolumAnaTip = batBellek) then
      begin

        KodEkle($0F);
        KodEkle($01);
        KodEkle((1 shl 3) or 5);

        i4 := GBellekSabitDeger;

        for i := 1 to 4 do
        begin

          KodEkle(Byte(i4));
          i4 := i4 shr 8;
        end;

        Result := HATA_YOK;
      end else Result := HATA_ISL_KULLANIM;
    end
    else if(SatirIcerik.Komut.GrupNo = GRUP11_FSTP) then
    begin

      if(SatirIcerik.BolumTip1.BolumAnaTip = batBellek) then
      begin

        i4 := GBellekSabitDeger;

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
    // lodsb / lodsw / lodsd komutları - (not: tamamlanmadı)
    else if(SatirIcerik.Komut.GrupNo = GRUP11_LODSB) or
      (SatirIcerik.Komut.GrupNo = GRUP11_LODSD) or
      (SatirIcerik.Komut.GrupNo = GRUP11_LODSW) then
    begin

      // herhangi bir öndeğer kullanılmamışsa
      if(SatirIcerik.BolumTip1.BolumAyrinti = []) and (SatirIcerik.BolumTip2.BolumAyrinti = []) then
      begin

        case SatirIcerik.Komut.GrupNo of
          GRUP11_LODSB: KodEkle($AC);

          // $66 önekinin 16 / 32 / 64 / bitlik ortamlarda kullanımı aşağıdaki gibidir.
          GRUP11_LODSD:
          begin

            if(GAsm2.Mimari = mim16Bit) then KodEkle($66);
            KodEkle($AD);
          end;
          GRUP11_LODSW:
          begin

            if(GAsm2.Mimari <> mim16Bit) then KodEkle($66);
            KodEkle($AD);
          end;
        end;

        Result := HATA_YOK;
      end else Result := HATA_DEVAM_EDEN_CALISMA;
    end
    // int komutu
    else if(SatirIcerik.Komut.GrupNo = GRUP11_INT) then
    begin

      // int 03
      if(GSabitDeger = 3) then

        KodEkle($CC)
      else
      // int xx
      begin

        KodEkle($CD);
        KodEkle(GSabitDeger);
      end;

      Result := HATA_YOK;
    end
    // int komutu
    else if(SatirIcerik.Komut.GrupNo = GRUP11_RET) or
      (SatirIcerik.Komut.GrupNo = GRUP11_RETF) or
      (SatirIcerik.Komut.GrupNo = GRUP11_RETN) then
    begin

      if(SatirIcerik.BolumTip1.BolumAnaTip = batSayisalDeger) then
      begin

        i4 := GSabitDeger;
        SayiTipi := SayiTipiniAl(i4);

        // 16 bit öndeğere sahip ret / retn komutu
        if(SayiTipi = vgB1) or (SayiTipi = vgB2) then
        begin

          if(SatirIcerik.Komut.GrupNo = GRUP11_RET) or
            (SatirIcerik.Komut.GrupNo = GRUP11_RETN) then
          begin

            KodEkle($C2);
            KodEkle(Byte(i4));
            i4 := i4 shr 8;
            KodEkle(Byte(i4));
          end
          else if(SatirIcerik.Komut.GrupNo = GRUP11_RETF) then
          begin

            KodEkle($CA);
            KodEkle(Byte(i4));
            i4 := i4 shr 8;
            KodEkle(Byte(i4));
          end;

          Result := HATA_YOK;
        end else Result := HATA_ISL_KOD_KULLANIM;
      end
      else if(SatirIcerik.BolumTip1.BolumAnaTip = batYok) then
      begin

        if(SatirIcerik.Komut.GrupNo = GRUP11_RET) or
          (SatirIcerik.Komut.GrupNo = GRUP11_RETN) then

          KodEkle($C3)
        else if(SatirIcerik.Komut.GrupNo = GRUP11_RETF) then

          KodEkle($CB);

        Result := HATA_YOK;
      end;
    end
    else if(SatirIcerik.Komut.GrupNo = GRUP11_JMP) then
    begin

      // GSabitDeger verisi byte olarak değerlendirildi.
      // diğer (16 / 32 / 64 bit) veriler de değerlendiirlecek
      if(GSabitDeger < (MevcutBellekAdresi + 2)) then
        ii := -((MevcutBellekAdresi + 2) - GSabitDeger)
      else ii := GSabitDeger - (MevcutBellekAdresi + 2);

      KodEkle($EB);

      KodEkle(ii);
      Result := HATA_YOK;
    end
    // jcc komutları
    else if(SatirIcerik.Komut.GrupNo = GRUP11_JNZ) or
      (SatirIcerik.Komut.GrupNo = GRUP11_JZ) then
    begin

      // ÖNEMLİ: tüm göreceli (relative) yönlendirmeler burada yapılacaktır.
      // işlem kodları en üst değer olmaktan çıkarılarak yerine
      // öndeğer (parametre) önceliği yerleştirilecektir

      {if(SatirIcerik.Komut.GrupNo = GRUP11_JNZ) then
        KodEkle($75)
      else if(SatirIcerik.Komut.GrupNo = GRUP11_JZ) then
        KodEkle($74);

      GoreceliDegerEkle;}


      // bu komutlar bir komut grubu olup, bulunulan konumdan kaç adım ileri veya
      // geri (relative) adrese dallanma yapılacağını bildirir
      // not: şu aşamada 8 bitlik katı kodlama uygulanmıştır
      if(GSabitDeger < (MevcutBellekAdresi + 2)) then
        ii := -((MevcutBellekAdresi + 2) - GSabitDeger)
      else ii := GSabitDeger - (MevcutBellekAdresi + 2);

      if(SatirIcerik.Komut.GrupNo = GRUP11_JNZ) then
        KodEkle($75)
      else if(SatirIcerik.Komut.GrupNo = GRUP11_JZ) then
        KodEkle($74);

      KodEkle(ii);
      Result := HATA_YOK;
    end
    // call komutu
    // FF /2
    // = $FF + 00 010 101 (101 = displacement)
    else if(SatirIcerik.Komut.GrupNo = GRUP11_CALL) then
    begin

      // call [bellek_adresi] ; bellek adresine direkt adres çağrısı
      if(SatirIcerik.BolumTip1.BolumAnaTip = batBellek) then
      begin

        KodEkle($FF);
        KodEkle($0 + $10 + $5);

        if(baBellekSabitDeger in SatirIcerik.BolumTip1.BolumAyrinti) then
        begin

          for i := 1 to 4 do
          begin

            KodEkle(Byte(GBellekSabitDeger));
            GBellekSabitDeger := GBellekSabitDeger shr 8;
          end;

          Result := HATA_YOK;
        end;
      end
      // call bellek_adresi  ; komut sonrasından itibaren ilgili noktaya göreceli çağrı
      else if(SatirIcerik.BolumTip1.BolumAnaTip = batSayisalDeger) then
      begin

        KodEkle($E8);

        i4 := (GSabitDeger - MevcutBellekAdresi);
        i4 := i4 - 5 + 1;

        for i := 1 to 4 do
        begin

          KodEkle(Byte(i4));
          i4 := i4 shr 8;
        end;

        Result := HATA_YOK;
      end;
    end
    else if(SatirIcerik.Komut.GrupNo = GRUP11_DEC) or
      (SatirIcerik.Komut.GrupNo = GRUP11_INC) then
    begin

      if(SatirIcerik.BolumTip1.BolumAnaTip = batYazmac) then
      begin

        if(SatirIcerik.Komut.GrupNo = GRUP11_DEC) then
        begin

          Result := IslemKodunaYazmacDegeriEkle($48, GYazmac1, SatirIcerik);
        end
        else if(SatirIcerik.Komut.GrupNo = GRUP11_INC) then
        begin

          Result := IslemKodunaYazmacDegeriEkle($40, GYazmac1, SatirIcerik);
        end;
      end
      else if(SatirIcerik.BolumTip1.BolumAnaTip = batBellek) then
      begin

        // 8 / 16 bitlik değerler de eklenecek
        if(YazmacListesi[GYazmac1].Uzunluk = yu32bGY) then
        begin

          KodEkle($FF);
          KodEkle(YazmacListesi[GYazmac1].Deger);
          Result := HATA_YOK;
        end else Result := HATA_DEVAM_EDEN_CALISMA;
      end else Result := HATA_DEVAM_EDEN_CALISMA;
    end
    // div komutu
    // F7 /6
    // = $F7 + 00 110 000
    else if(SatirIcerik.Komut.GrupNo = GRUP11_DIV) then
    begin

      //SendDebug('G13_Yazmaç: ' + YazmacListesi[GYazmac1].Ad);

      KodEkle($F7);
      KodEkle($C0 + $30 + (YazmacListesi[GYazmac1].Deger and 7));
      Result := HATA_YOK;
    end else Result := 1;
  end else Result := 1;
end;

// 5.2 - yazmaça sayısal değer ata
// REGDeger = MOD[7..6] + REG[5..3] + RM[2..0]
function SayisalDegerAta(IslemKodu, REGDeger: Byte; SatirIcerik: TSatirIcerik;
  Yazmac, SabitDeger: Integer; SayisalDegerVar: Boolean): Integer;
begin

  // derlenecek kod mimarisi 64 bit ise...
  if(GAsm2.Mimari = mim64Bit) and (YazmacListesi[Yazmac].Uzunluk = yu64bGY) then

    // 0100W000 = W = 1 = 64 bit işlem kodu
    KodEkle($48)

  // derlenecek kod mimarisi 32 bit, yazmaç 32 bit değilse...
  // 66 ön ekini kodun başına ekle
  else if(GAsm2.Mimari = mim32Bit) and (YazmacListesi[Yazmac].Uzunluk <> yu32bGY) then

    KodEkle($66)

  // derlenecek kod mimarisi 16 bit, yazmaç 16 bit değilse...
  else if(GAsm2.Mimari = mim16Bit) and (YazmacListesi[Yazmac].Uzunluk <> yu16bGY) then

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


// çok önemli: göreceli değerlerle işlem yapılırken ilgili komut bir sonraki
// adresi hesaplayamayacağından dolayı en az iki çevrim yapılması gerekmektedir
// kısaca: birinci aşamada sanal (ama gerçek uzunlukta) veri üretildikten sonra
// 2. aşamada gerçek kodlama gerçekleştirilecektir.
procedure GoreceliDegerEkle;
var
  SayiTipi: TVeriGenisligi;
  SayisalVeri, VeriGenisligi, i: Integer;
  ii: Byte;
  i4: Integer;
begin

  SayiTipi := SayiTipiniAl(SayisalVeri);

  // eğer önek sayı değerinden büyükse sayı değerinin veri
  // genişliğini önek olarak ayarla
  if(GSabitDegerVG > SayiTipi) then SayiTipi := GSabitDegerVG;

  case SayiTipi of
    vgB1: ii := 1;
    vgB2: ii := 2;
    vgB4: ii := 4;
    vgB8: ii := 8;
  end;

  // bu komutlar bir komut grubu olup, bulunulan konumdan kaç adım ileri veya
  // geri (relative) adrese dallanma yapılacağını bildirir
  // not: şu aşamada 8 bitlik katı kodlama uygulanmıştır
  if(GSabitDeger < (MevcutBellekAdresi - 1)) then
    SayisalVeri := -((MevcutBellekAdresi - 1) - GSabitDeger)
  else SayisalVeri := GSabitDeger - (MevcutBellekAdresi - 1);

  SayiTipi := SayiTipiniAl(SayisalVeri);

  // eğer önek sayı değerinden büyükse sayı değerinin veri
  // genişliğini önek olarak ayarla
  if(GSabitDegerVG > SayiTipi) then SayiTipi := GSabitDegerVG;

  case SayiTipi of
    vgB1: ii := 1;
    vgB2: ii := 2;
    vgB4: ii := 4;
    vgB8: ii := 8;
  end;

  for i := 1 to ii do
  begin

    KodEkle(Byte(SayisalVeri));
    SayisalVeri := SayisalVeri shr 8;
  end;
end;

// push r32 -> 50+rd kodlama işlemlerini yönetir
function IslemKodunaYazmacDegeriEkle(IslemKodu, Yazmac: Byte;
  SatirIcerik: TSatirIcerik): Integer;
var
  DesMim1, DesMim2: TDestekleyenMimari;
  i: Byte;
begin

  // 64 bitlik işlem kodları yalnızca 64 bitlik mimaride kullanılabilir
  if(GAsm2.Mimari <> mim64Bit) and (YazmacListesi[Yazmac].Uzunluk = yu64bGY) then
  begin

    Result := HATA_64BIT_MIMARI_GEREKLI;
    Exit;
  end;

  // derlenecek kod mimarisi 64 bit ise...
  {if(GAsm2.Mimari = mim64Bit) and (YazmacListesi[Yazmac].Uzunluk = yu64bGY) then

    // 0100W000 = W = 1 = 64 bit işlem kodu
    KodEkle($48)}

  // derlenecek kod mimarisi 32 bit, yazmaç 32 bit değilse...
  // 66 ön ekini kodun başına ekle
  if(GAsm2.Mimari = mim32Bit) and (YazmacListesi[Yazmac].Uzunluk <> yu32bGY) then

    KodEkle($66)

  // derlenecek kod mimarisi 16 bit, yazmaç 16 bit değilse...
  else if(GAsm2.Mimari = mim16Bit) and (YazmacListesi[Yazmac].Uzunluk <> yu16bGY) then

    KodEkle($66);

  DesMim1 := YazmacListesi[Yazmac].DesMim;

  KodEkle(IslemKodu + (YazmacListesi[Yazmac].Deger and 7));
  Result := HATA_YOK;
end;

end.
