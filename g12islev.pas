{-------------------------------------------------------------------------------

  Dosya: g12islev.pas

  İşlev: 12. grup kodlama işlevlerini gerçekleştirir

  12. grup kodlama işlevi; iki parametreli, yazmaç / sabit değer / bellek
    bölgesi ataması kombinasyonlarından oluşan komutlardır

  Güncelleme Tarihi: 14/04/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit g12islev;

interface

uses Classes, SysUtils, paylasim, onekler;

function Grup12Islev(SatirNo: Integer; ParcaNo: Integer;
  VeriKontrolTip: TVeriKontrolTip; Veri1: string; Veri2: QWord): Integer;
function BellekBolgesineYazmacAta(SatirIcerik: TSatirIcerik; Yazmac1,
  Yazmac2: Integer): Integer;
function BellekBolgesineSayisalDegerAta(SatirIcerik: TSatirIcerik; Yazmac1,
  Yazmac2: Integer): Integer;

implementation

uses dbugintf, yazmaclar, kodlama, komutlar, asm2, genel, donusum, dosya;

// ünite içi genel kullanımlık yerel değişkenler
var
  // ifadeyi yorumlayan işlevler tarafından kullanılan genel değişkenler
  VirgulKullanildi, ArtiIsleyiciKullanildi: Boolean;
  KoseliParantezSayisi: Integer;

// mov komutu ve diğer ilgili en karmaşık komutların prototipi
function Grup12Islev(SatirNo: Integer; ParcaNo: Integer;
  VeriKontrolTip: TVeriKontrolTip; Veri1: string; Veri2: QWord): Integer;
var
  i, i4: Integer;
  DegerVG: TVeriGenisligi;
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

    //  "işlemkodu hedef, kaynak"
    // virgülden önceki hedef alan değerlendirilmeye alınıyor
    if(ParcaNo = 2) then
    begin

      // hedef alan öndeğer tipi daha önce belirlenmemişse
      if(SatirIcerik.BolumTip1.BolumAnaTip = batYok) then
      begin

        SatirIcerik.BolumTip1.BolumAnaTip := batYazmac;
        SatirIcerik.BolumTip1.BolumAyrinti += [baHedefYazmac];
        GYazmac1 := Veri2;
        Result := HATA_YOK;
      end
      // yazmaç olan bölgeye yeniden değer ataması yapılıyorsa
      else if(SatirIcerik.BolumTip1.BolumAnaTip = batYazmac) then
      begin

        Result := HATA_ISL_KULLANIM;
      end
      else //if(SatirIcerik.BolumTip1.BolumAnaTip = batBellek) then
      begin

        // sorgulanan durum -> işlemkodu [baBellekYazmac1 + baBellekYazmac2], xyz
        if(baBellekYazmac1 in SatirIcerik.BolumTip1.BolumAyrinti) then
        begin

          if(baBellekYazmac2 in SatirIcerik.BolumTip1.BolumAyrinti) then
          begin

            Result := HATA_ISL_KOD_KULLANIM
          end
          else
          begin

            SatirIcerik.BolumTip1.BolumAyrinti += [baBellekYazmac2];
            GYazmacB2 := Veri2;
            Result := HATA_YOK;
          end;
        end
        else
        begin

          GYazmacB1 := Veri2;
          SatirIcerik.BolumTip1.BolumAyrinti += [baBellekYazmac1];
          Result := HATA_YOK;
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

        // her iki alan bellek bölgesi ataması olamaz
        if(SatirIcerik.BolumTip1.BolumAnaTip = batBellek) and
          (SatirIcerik.BolumTip2.BolumAnaTip = batBellek) then
        begin

          Result := HATA_BELLEKTEN_BELLEGE;
        end
        // sorgulanan durum -> işlemkodu xyz, [baBellekYazmac1 + baBellekYazmac2]
        else if(SatirIcerik.BolumTip2.BolumAnaTip = batYok) then
        begin

          SatirIcerik.BolumTip2.BolumAnaTip := batYazmac;
          SatirIcerik.BolumTip2.BolumAyrinti += [baKaynakYazmac];
          GYazmac2 := Veri2;
          Result := HATA_YOK;
        end

        else //if(SatirIcerik.BolumTip1.BolumAnaTip = batBellek) then
        begin

          // sorgulanan durum -> işlemkodu [baBellekYazmac1 + baBellekYazmac2], xyz
          if(baBellekYazmac1 in SatirIcerik.BolumTip2.BolumAyrinti) then
          begin

            if(baBellekYazmac2 in SatirIcerik.BolumTip2.BolumAyrinti) then
            begin

              Result := HATA_ISL_KOD_KULLANIM
            end
            else
            begin

              SatirIcerik.BolumTip2.BolumAyrinti += [baBellekYazmac2];
              GYazmacB2 := Veri2;
              Result := HATA_YOK;
            end;
          end
          else
          begin

            GYazmacB1 := Veri2;
            SatirIcerik.BolumTip2.BolumAyrinti += [baBellekYazmac1];
            Result := HATA_YOK;
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
    {if not((baHedefYazmac in SatirIcerik.BolumTip1.BolumAyrinti) or
      (baBellekYazmac1 in SatirIcerik.BolumTip1.BolumAyrinti) or
      (baBellekSabitDeger in SatirIcerik.BolumTip1.BolumAyrinti)) then

      Result := HATA_YAZMAC_GEREKLI
    else} if (VirgulKullanildi) then
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
    // daha önce bellek adreslemede yazmaç veya bellek sabit değeri kullanılmışsa
    else if(baBellekYazmac1 in SatirIcerik.BolumTip1.BolumAyrinti) or
      (baBellekSabitDeger in SatirIcerik.BolumTip1.BolumAyrinti) then

      Result := HATA_BELLEKTEN_BELLEGE
    else
    begin

      // ParcaNo = 2 = hedef alan, ParcaNo = 3 = kaynak alan
      if(ParcaNo = 2) then
        SatirIcerik.BolumTip1.BolumAnaTip := batBellek
      else if(ParcaNo = 3) then SatirIcerik.BolumTip2.BolumAnaTip := batBellek;

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
  // ÖNEMLİ: vktArti iptal edilerek; bellek değeri içerisinde + kullanımının
  // kontrolü sağlanacak. yazmaçtan veya ölçekten sonra + kullanımı sayısal işleme
  // tabi tutulmadan önce bu değerin bellek bölgesi disp olduğu vurgulanacaktır

  {else if(VeriKontrolTip = vktArti) then
  begin

    // artı toplam değerinin kullanılması için tek bir köşeli parantez
    // açılması gerekmekte (bellek adresleme)
    if(KoseliParantezSayisi <> 1) then

      Result := HATA_ISL_KULLANIM
    else
    begin

      ArtiIsleyiciKullanildi := True;
      Result := HATA_YOK;
    end;
  end}
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
        Result := HATA_YOK;
      end
      else
      begin

        Result := HATA_OLCEK_DEGER;
      end;
    end;
  end
  // şu anda bu veri tipi uygulanamaıyor
  else if(VeriKontrolTip = vktKarakterDizisi) then
  begin

    //SendDebug('G12_KarakterKatarı: ' + Veri1);
  end
  else if(VeriKontrolTip = vktSayi) then
  begin

    SendDebug('G12_vktSayi1');

    // ParcaNo 2'de (ilk öndeğer) sayısal değer
    // 1. bellek atama işlemi için
    // 2. in ve out komutunda kullanılır
    if(ParcaNo = 2) then
    begin

      // bellek ataması gerçekleştirilecekse
      if(SatirIcerik.BolumTip1.BolumAnaTip = batBellek) then
      begin

        // daha önce bellek ataması gerçekleştirilmişse
        if(baBellekSabitDeger in SatirIcerik.BolumTip1.BolumAyrinti) then
        begin

          Result := HATA_ISL_KOD_KULLANIM;
        end
        else
        begin

          SatirIcerik.BolumTip1.BolumAyrinti += [baBellekSabitDeger];
          GBellekSabitDeger := Veri2;
          Result := HATA_YOK;
        end;
      end
      else if(SatirIcerik.BolumTip1.BolumAnaTip = batYok) then
      begin

        SatirIcerik.BolumTip1.BolumAnaTip := batSayisalDeger;
        SatirIcerik.BolumTip1.BolumAyrinti += [baSabitDeger];
        GSabitDeger1 := Veri2;
        Result := HATA_YOK;
      end else Result := HATA_ISL_KOD_KULLANIM;
    end
    else if(ParcaNo = 3) then
    begin

      // bellek ataması gerçekleştirilecekse
      if(SatirIcerik.BolumTip2.BolumAnaTip = batBellek) then
      begin

        // bellek atamasına bellek ataması gerçekleştirilmeye
        // çalışılıyorsa ...
        if(SatirIcerik.BolumTip1.BolumAnaTip = batBellek) then
        begin

          Result := HATA_ISL_KOD_KULLANIM;
        end
        else
        begin

          SatirIcerik.BolumTip2.BolumAyrinti += [baBellekSabitDeger];
          GBellekSabitDeger := Veri2;
          Result := HATA_YOK;
        end;
      end
      else if(SatirIcerik.BolumTip2.BolumAnaTip = batYok) then
      begin

        SatirIcerik.BolumTip2.BolumAnaTip := batSayisalDeger;
        SatirIcerik.BolumTip2.BolumAyrinti += [baSabitDeger];
        GSabitDeger1 := Veri2;
        Result := HATA_YOK;
      end else Result := HATA_ISL_KOD_KULLANIM;
    end;
  end
  // son kontroller bu aşamada gerçekleştirilecek
  else if(VeriKontrolTip = vktSon) then
  begin

    if(SatirIcerik.Komut.GrupNo = GRUP12_IN) then
    begin

      if(SatirIcerik.BolumTip2.BolumAnaTip = batSayisalDeger) then
      begin

        DegerVG := SayiTipiniAl(GSabitDeger1);
        if(DegerVG = vgB1) then
        begin

          if(SatirIcerik.BolumTip1.BolumAnaTip = batYazmac) then
          begin

            if(YazmacListesi[GYazmac1].Ad = 'al') then
            begin

              KodEkle($E4);
              Result := SayisalDegerEkle(GSabitDeger1, vgB1);
            end
            else if(YazmacListesi[GYazmac1].Ad = 'ax') then
            begin

              if(GAktifDosya.Mimari <> mim16Bit) then KodEkle($66);
              KodEkle($E5);
              Result := SayisalDegerEkle(GSabitDeger1, vgB1);
            end
            else if(YazmacListesi[GYazmac1].Ad = 'eax') then
            begin

              if(GAktifDosya.Mimari =  mim16Bit) then KodEkle($66);
              KodEkle($E5);
              Result := SayisalDegerEkle(GSabitDeger1, vgB1);
            end else Result := HATA_ISL_KOD_KULLANIM;
          end else Result := HATA_ISL_KOD_KULLANIM;
        end else Result := HATA_VERI_GENISLIGI;
      end
      else if(SatirIcerik.BolumTip2.BolumAnaTip = batYazmac) then
      begin

        if(YazmacListesi[GYazmac2].Ad = 'dx') then
        begin

          if(SatirIcerik.BolumTip1.BolumAnaTip = batYazmac) then
          begin

            if(YazmacListesi[GYazmac1].Ad = 'al') then
            begin

              KodEkle($EC);
              Result := HATA_YOK;
            end
            else if(YazmacListesi[GYazmac1].Ad = 'ax') then
            begin

              if(GAktifDosya.Mimari <> mim16Bit) then KodEkle($66);
              KodEkle($ED);
              Result := HATA_YOK;
            end
            else if(YazmacListesi[GYazmac1].Ad = 'eax') then
            begin

              if(GAktifDosya.Mimari =  mim16Bit) then KodEkle($66);
              KodEkle($ED);
              Result := HATA_YOK;
            end else Result := HATA_ISL_KOD_KULLANIM;
          end else Result := HATA_ISL_KOD_KULLANIM;
        end else Result := HATA_ISL_KOD_KULLANIM;
      end else Result := HATA_ISL_KOD_KULLANIM;
    end
    else if(SatirIcerik.Komut.GrupNo = GRUP12_OUT) then
    begin

      if(SatirIcerik.BolumTip1.BolumAnaTip = batSayisalDeger) then
      begin

        DegerVG := SayiTipiniAl(GSabitDeger1);
        if(DegerVG = vgB1) then
        begin

          if(SatirIcerik.BolumTip2.BolumAnaTip = batYazmac) then
          begin

            if(YazmacListesi[GYazmac2].Ad = 'al') then
            begin

              KodEkle($E6);
              Result := SayisalDegerEkle(GSabitDeger1, vgB1);
            end
            else if(YazmacListesi[GYazmac2].Ad = 'ax') then
            begin

              if(GAktifDosya.Mimari <> mim16Bit) then KodEkle($66);
              KodEkle($E7);
              Result := SayisalDegerEkle(GSabitDeger1, vgB1);
            end
            else if(YazmacListesi[GYazmac2].Ad = 'eax') then
            begin

              if(GAktifDosya.Mimari =  mim16Bit) then KodEkle($66);
              KodEkle($E7);
              Result := SayisalDegerEkle(GSabitDeger1, vgB1);
            end else Result := HATA_ISL_KOD_KULLANIM;
          end else Result := HATA_ISL_KOD_KULLANIM;
        end else Result := HATA_VERI_GENISLIGI;
      end
      else if(SatirIcerik.BolumTip1.BolumAnaTip = batYazmac) then
      begin

        if(YazmacListesi[GYazmac1].Ad = 'dx') then
        begin

          if(SatirIcerik.BolumTip2.BolumAnaTip = batYazmac) then
          begin

            if(YazmacListesi[GYazmac2].Ad = 'al') then
            begin

              KodEkle($EE);
              Result := HATA_YOK;
            end
            else if(YazmacListesi[GYazmac2].Ad = 'ax') then
            begin

              if(GAktifDosya.Mimari <> mim16Bit) then KodEkle($66);
              KodEkle($EF);
              Result := HATA_YOK;
            end
            else if(YazmacListesi[GYazmac2].Ad = 'eax') then
            begin

              if(GAktifDosya.Mimari =  mim16Bit) then KodEkle($66);
              KodEkle($EF);
              Result := HATA_YOK;
            end else Result := HATA_ISL_KOD_KULLANIM;
          end else Result := HATA_ISL_KOD_KULLANIM;
        end else Result := HATA_ISL_KOD_KULLANIM;
      end else Result := HATA_ISL_KOD_KULLANIM;
    end
    else
    begin

      case SatirIcerik.Komut.GrupNo of
        GRUP12_ADC:   begin Result := HATA_DEVAM_EDEN_CALISMA; Exit; end;
        GRUP12_IMUL:  begin Result := HATA_DEVAM_EDEN_CALISMA; Exit; end;
        GRUP12_MOVSX: begin Result := HATA_DEVAM_EDEN_CALISMA; Exit; end;
        GRUP12_MOVZX: begin Result := HATA_DEVAM_EDEN_CALISMA; Exit; end;
        GRUP12_SBB:   begin Result := HATA_DEVAM_EDEN_CALISMA; Exit; end;
        GRUP12_TEST:  begin Result := HATA_DEVAM_EDEN_CALISMA; Exit; end;
      end;

      // yazmaçtan yazmaca koşulsuz atamalar buraya eklenecek
      if(SatirIcerik.BolumTip1.BolumAnaTip = batYazmac) and
        (SatirIcerik.BolumTip2.BolumAnaTip = batYazmac) then
      begin

        // RCL ve diğer komutlar tamamlanmadı!
        case SatirIcerik.Komut.GrupNo of
          {YazmacYazmacKodla işlevleri YazmacKodla olarak değiştirilecek
          GRUP12_RCL: Result := YazmacYazmacKodla($D2, $02, SatirIcerik,
            GYazmac1, GYazmac2);
          GRUP12_RCR: Result := YazmacYazmacKodla($D2, $03, SatirIcerik,
            GYazmac1, GYazmac2);
          GRUP12_ROL: Result := YazmacYazmacKodla($D2, $00, SatirIcerik,
            GYazmac1, GYazmac2);
          GRUP12_ROR: Result := YazmacYazmacKodla($D2, $01, SatirIcerik,
            GYazmac1, GYazmac2);
          // 2 işlem kodu da aynı. merak etme, hata yok!
          GRUP12_SAL,
          GRUP12_SHL: Result := YazmacYazmacKodla($D2, $04, SatirIcerik,
            GYazmac1, GYazmac2);
          GRUP12_SAR: Result := YazmacYazmacKodla($D2, $07, SatirIcerik,
            GYazmac1, GYazmac2);
          GRUP12_SHR: Result := YazmacYazmacKodla($D2, $05, SatirIcerik,
            GYazmac1, GYazmac2);}

          GRUP12_ADD:   Result := YazmacKodla($00, $01, GYazmac1, GYazmac2, SatirIcerik);
          GRUP12_AND:   Result := YazmacKodla($20, $21, GYazmac1, GYazmac2, SatirIcerik);
          GRUP12_CMP:   Result := YazmacKodla($38, $39, GYazmac1, GYazmac2, SatirIcerik);
          // GRUP12_LEA: bu komutun yazmaçtan yazmaça ataması yok
          GRUP12_MOV:   Result := YazmacKodla($88, $89, GYazmac1, GYazmac2, SatirIcerik);
          GRUP12_OR:    Result := YazmacKodla($08, $09, GYazmac1, GYazmac2, SatirIcerik);
          GRUP12_SUB:   Result := YazmacKodla($28, $29, GYazmac1, GYazmac2, SatirIcerik);
          GRUP12_XCHG:  Result := YazmacKodla($86, $87, GYazmac1, GYazmac2, SatirIcerik);
          GRUP12_XOR:   Result := YazmacKodla($30, $31, GYazmac1, GYazmac2, SatirIcerik);
          else Result := HATA_ISL_KOD_KULLANIM;
        end;
      end
      // İşlemKodu Yazmaç,[Bellek] atamaları buraya eklenecek
      else if(SatirIcerik.BolumTip1.BolumAnaTip = batYazmac) and
        (SatirIcerik.BolumTip2.BolumAnaTip = batBellek) then
      begin

        case SatirIcerik.Komut.GrupNo of

          GRUP12_MOV:   Result := YazmacaBellekBolgesiAta(True, $8A, $8B);
          else Result := HATA_ISL_KOD_KULLANIM;
        end;
      end
      // İşlemKodu Yazmaç,[Bellek] atamaları buraya eklenecek
      else if(SatirIcerik.BolumTip1.BolumAnaTip = batBellek) and
        (SatirIcerik.BolumTip2.BolumAnaTip = batYazmac) then
      begin

        case SatirIcerik.Komut.GrupNo of

          GRUP12_MOV:   Result := YazmacaBellekBolgesiAta(False, $88, $89);
          else Result := HATA_ISL_KOD_KULLANIM;
        end;
      end
      // yazmaça sayısal değer aktarma işlemi olarak geliştirilecek.
      // dönüşüm aşamalı olarak gerçekleştirilecek.
      // bunun için alt satırdaki kodların toparlanmaları gerekmektedir.
      else if((SatirIcerik.Komut.GrupNo = GRUP12_RCL) or
        (SatirIcerik.Komut.GrupNo = GRUP12_RCR) or
        (SatirIcerik.Komut.GrupNo = GRUP12_ROL) or
        (SatirIcerik.Komut.GrupNo = GRUP12_ROR) or
        (SatirIcerik.Komut.GrupNo = GRUP12_SAL) or
        (SatirIcerik.Komut.GrupNo = GRUP12_SAR) or
        (SatirIcerik.Komut.GrupNo = GRUP12_SHL) or
        (SatirIcerik.Komut.GrupNo = GRUP12_SHR)) then
      begin

        DegerVG := SayiTipiniAl(GSabitDeger1);
        if(DegerVG < GSabitDegerVG) then DegerVG := GSabitDegerVG;

        // sabit değer 1 değerinin değerlendirilmesi
        if(DegerVG = vgB1) and (GSabitDeger1 = 1) then
        begin

          case SatirIcerik.Komut.GrupNo of
            GRUP12_RCL: Result := YazmacKodla($D0, $D1, GYazmac1, 2, SatirIcerik);
            GRUP12_RCR: Result := YazmacKodla($D0, $D1, GYazmac1, 3, SatirIcerik);
            GRUP12_ROL: Result := YazmacKodla($D0, $D1, GYazmac1, 0, SatirIcerik);
            GRUP12_ROR: Result := YazmacKodla($D0, $D1, GYazmac1, 1, SatirIcerik);
            GRUP12_SAL, // SAL ve SHL işlem kodları aynı. merak etme, hata yok!
            GRUP12_SHL: Result := YazmacKodla($D0, $D1, GYazmac1, 4, SatirIcerik);
            GRUP12_SAR: Result := YazmacKodla($D0, $D1, GYazmac1, 7, SatirIcerik);
            GRUP12_SHR: Result := YazmacKodla($D0, $D1, GYazmac1, 5, SatirIcerik);
          end;
        end
        // sabit değer 1 byte değerinin değerlendirilmesi
        else if(DegerVG = vgB1) then
        begin

          case SatirIcerik.Komut.GrupNo of
            GRUP12_RCL: Result := YazmacKodla($C0, $C1, GYazmac1, 2, SatirIcerik);
            GRUP12_RCR: Result := YazmacKodla($C0, $C1, GYazmac1, 3, SatirIcerik);
            GRUP12_ROL: Result := YazmacKodla($C0, $C1, GYazmac1, 0, SatirIcerik);
            GRUP12_ROR: Result := YazmacKodla($C0, $C1, GYazmac1, 1, SatirIcerik);
            GRUP12_SAL, // SAL ve SHL işlem kodları aynı. merak etme, hata yok!
            GRUP12_SHL: Result := YazmacKodla($C0, $C1, GYazmac1, 4, SatirIcerik);
            GRUP12_SAR: Result := YazmacKodla($C0, $C1, GYazmac1, 7, SatirIcerik);
            GRUP12_SHR: Result := YazmacKodla($C0, $C1, GYazmac1, 5, SatirIcerik);
          end;

          if(Result = HATA_YOK) then Result := SayisalDegerEkle(GSabitDeger1, vgB1);
        end
      end
      // uygulanan komut
      // cmp     eax,1
      // db      83h, 0F8h, 00h
      else if(SatirIcerik.Komut.GrupNo = GRUP12_CMP) then
      begin

        // 32 bitlik yazmaca 8 bitlik veri aktarılıyor
        if(YazmacListesi[GYazmac1].Uzunluk = yu32bGY) then
        begin

          KodEkle($83);
          KodEkle($C0 + (7 shl 3) + (YazmacListesi[GYazmac1].Deger and 7));
          KodEkle(GSabitDeger1);
          Result := HATA_YOK;
        end else Result := HATA_BILINMEYEN_HATA;
      end
      else if(SatirIcerik.Komut.GrupNo = GRUP12_ADD) then
      begin

        if(SatirIcerik.BolumTip1.BolumAnaTip = batYazmac) and
          (SatirIcerik.BolumTip2.BolumAnaTip = batSayisalDeger) then
        begin

          if(YazmacListesi[GYazmac1].Uzunluk = yu8bGY) then
          begin

            Result := YazmacKodla($80, $81, GYazmac1, 0, SatirIcerik);
            if(Result = HATA_YOK) then Result := SayisalDegerEkle(GSabitDeger1, vgB1);
          end
          else if(YazmacListesi[GYazmac1].Uzunluk = yu16bGY) then
          begin

            Result := YazmacKodla($80, $81, GYazmac1, 0, SatirIcerik);
            if(Result = HATA_YOK) then Result := SayisalDegerEkle(GSabitDeger1, vgB2);
          end
          // 32 ve 64 bitlik yazmaç 32 bitlik değer kullanıyor
          else if(YazmacListesi[GYazmac1].Uzunluk = yu16bGY) then
          begin

            Result := YazmacKodla($80, $81, GYazmac1, 0, SatirIcerik);
            if(Result = HATA_YOK) then Result := SayisalDegerEkle(GSabitDeger1, vgB4);
          end
        end else Result := HATA_BILINMEYEN_HATA;
      end
      else
      begin

        if(SatirIcerik.Komut.GrupNo = GRUP12_MOV) or
          (SatirIcerik.Komut.GrupNo = GRUP12_SUB) or
          (SatirIcerik.Komut.GrupNo = GRUP12_LEA) then
        begin

          // bu kısımdaki veriler yazmaçlara sabir veri aktarma şeklindedir
          // 8 bitlik veri
          if(YazmacListesi[GYazmac1].Uzunluk = yu8bGY) then
          begin

            Result := IslemKoduIleYazmacDegeriniBirlestir2($B0, $B8, 0, SatirIcerik);
            if(Result = HATA_YOK) then SayisalDegerEkle(GSabitDeger1, vgB1);
          end
          // 16 bitlik veri
          else if(YazmacListesi[GYazmac1].Uzunluk = yu16bGY) then
          begin

            Result := IslemKoduIleYazmacDegeriniBirlestir2($B0, $B8, 0, SatirIcerik);
            if(Result = HATA_YOK) then SayisalDegerEkle(GSabitDeger1, vgB2);
          end
          // 32 bitlik veri
          else if(YazmacListesi[GYazmac1].Uzunluk = yu32bGY) then
          begin

            // 32 bitlik bellek alanına bellek değeri aktarılacaksa
            if(SatirIcerik.BolumTip2.BolumAnaTip = batBellek) then
            begin

              { TODO : mov  eax,[bellek_adresi] için geçici olarak eklendi. genişletilecek }
              KodEkle($A1);
              for i := 1 to 4 do
              begin

                KodEkle(Byte(GBellekSabitDeger));
                GBellekSabitDeger := GBellekSabitDeger shr 8;
              end;
              Result := HATA_YOK;
            end
            else
            begin

              Result := IslemKoduIleYazmacDegeriniBirlestir2($B0, $B8, 0, SatirIcerik);
              if(Result = HATA_YOK) then SayisalDegerEkle(GSabitDeger1, vgB4);
            end;
          end
          // 64 bitlik yazmaça sabit değer aktarma işlemi
          else if(YazmacListesi[GYazmac1].Uzunluk = yu64bGY) then
          begin

            if(GAktifDosya.Mimari = mim64Bit) then
            begin

              if(SatirIcerik.Komut.GrupNo = GRUP12_LEA) then
              begin

                if(SatirIcerik.BolumTip2.BolumAnaTip = batBellek) then
                begin

                  KodEkle($8D);
                  KodEkle(((YazmacListesi[GYazmac1].Deger and 7) shl 3) or 5);

                  i4 := GBellekSabitDeger - MevcutBellekAdresi;
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
              else if(SatirIcerik.Komut.GrupNo = GRUP12_MOV) then
              begin

                // 64 bitlik başvuru hatalı olabilir. test edilecek
                Result := IslemKoduIleYazmacDegeriniBirlestir2($C6, $C7,  0, SatirIcerik);

                for i := 1 to 4 do
                begin

                  KodEkle(Byte(GSabitDeger1));
                  GSabitDeger1 := GSabitDeger1 shr 8;
                end;
                Result := HATA_YOK;
              end
              // sub     rsp,8*5 -> 64 bitlik yazmaça 8 bit değer atama
              else if(SatirIcerik.Komut.GrupNo = GRUP12_SUB) then
              begin

                Result := YazmacKodla($80, $83, GYazmac1, 5, SatirIcerik);
                KodEkle(Byte(GSabitDeger1));
                Result := HATA_YOK;
              end;
            end else Result := HATA_64BIT_MIMARI_GEREKLI;
          end else Result := HATA_BILINMEYEN_HATA;
        end
        else if(SatirIcerik.Komut.GrupNo = GRUP12_XOR) then
        begin

          Result := HATA_DEVAM_EDEN_CALISMA;
        end
        else if(SatirIcerik.Komut.GrupNo = GRUP12_OR) then
        begin

          Result := HATA_DEVAM_EDEN_CALISMA;
        end else Result := 1;
      end;
    end;
  end;
end;

// 5.4 - bellek bölgesine yazmaç ata
function BellekBolgesineYazmacAta(SatirIcerik: TSatirIcerik; Yazmac1,
  Yazmac2: Integer): Integer;
begin

end;

// 5.5 - bellek bölgesine sayısal değer ata
function BellekBolgesineSayisalDegerAta(SatirIcerik: TSatirIcerik; Yazmac1,
  Yazmac2: Integer): Integer;
begin

end;

end.
