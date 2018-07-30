{-------------------------------------------------------------------------------

  Dosya: g12islev.pas

  İşlev: 12. grup kodlama işlevlerini gerçekleştirir

  Güncelleme Tarihi: 14/04/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit g12islev;

interface

uses Classes, SysUtils, paylasim, onekler;

function Grup12Islev(SatirNo: Integer; ParcaNo: Integer;
  VeriKontrolTip: TVeriKontrolTip; Veri1: string; Veri2: QWord): Integer;
function YazmacaYazmacAta(IslemKodu, REGDeger: Byte; SatirIcerik: TSatirIcerik; Yazmac1,
  Yazmac2: Integer): Integer;
function YazmacaSayisalDegerAta(IslemKodu, REGDeger: Byte; SatirIcerik: TSatirIcerik;
  Yazmac: Integer; SayisalDegerVar: Boolean; SabitDeger: Integer;
  SabitDegerVG: TVeriGenisligi): Integer;
function YazmacaBellekBolgesiAta(SatirIcerik: TSatirIcerik; Yazmac1,
  Yazmac2: Integer): Integer;
function BellekBolgesineYazmacAta(SatirIcerik: TSatirIcerik; Yazmac1,
  Yazmac2: Integer): Integer;
function BellekBolgesineSayisalDegerAta(SatirIcerik: TSatirIcerik; Yazmac1,
  Yazmac2: Integer): Integer;

implementation

uses dbugintf, yazmaclar, kodlama, komutlar, asm2, genel, donusum;

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
  // 1. GParametreTip1 ve GParametreTip2 değişkenlerine anasayfa'da ptYok olarak ilk değer atanıyor
  // 2. GParametreTip1 ve GParametreTip2 değişkenleri vtKPAc kısmında ptBellek olarak atama yapılıyor
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
    if not((baHedefYazmac in SatirIcerik.BolumTip1.BolumAyrinti) or
      (baBellekYazmac1 in SatirIcerik.BolumTip1.BolumAyrinti) or
      (baBellekSabitDeger in SatirIcerik.BolumTip1.BolumAyrinti)) then

      Result := HATA_YAZMAC_GEREKLI
    else if (VirgulKullanildi) then
    begin

      Result := HATA_ISL_KOD_KULLANIM;
      //SendDebug('G12_Hatalı kullanım!');
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

    //SendDebug('G12_vktSayi');

    // ParcaNo 2'de (ilk öndeğer) sayısal değer sadece bellek atama işlemi
    // için kullanılır
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
        GSabitDeger := Veri2;
        Result := HATA_YOK;
      end else Result := HATA_ISL_KOD_KULLANIM;
    end;
  end
  // son kontroller bu aşamada gerçekleştirilecek
  else if(VeriKontrolTip = vktSon) then
  begin

    case SatirIcerik.Komut.GrupNo of
      GRUP12_ADC:   begin Result := HATA_DEVAM_EDEN_CALISMA; Exit; end;
      GRUP12_IMUL:  begin Result := HATA_DEVAM_EDEN_CALISMA; Exit; end;
      GRUP12_MOVSX: begin Result := HATA_DEVAM_EDEN_CALISMA; Exit; end;
      GRUP12_MOVZX: begin Result := HATA_DEVAM_EDEN_CALISMA; Exit; end;
      GRUP12_SBB:   begin Result := HATA_DEVAM_EDEN_CALISMA; Exit; end;
      GRUP12_SHLD:  begin Result := HATA_DEVAM_EDEN_CALISMA; Exit; end;
      GRUP12_SHRD:  begin Result := HATA_DEVAM_EDEN_CALISMA; Exit; end;
      GRUP12_TEST:  begin Result := HATA_DEVAM_EDEN_CALISMA; Exit; end;
    end;

    // yazmaçtan yazmaca atama işlemi
    if(SatirIcerik.BolumTip1.BolumAnaTip = batYazmac) and
      (SatirIcerik.BolumTip2.BolumAnaTip = batYazmac) then
    begin

      case SatirIcerik.Komut.GrupNo of
        GRUP12_RCL: Result := YazmacaYazmacAta($D2, $02, SatirIcerik,
          GYazmac1, GYazmac2);
        GRUP12_RCR: Result := YazmacaYazmacAta($D2, $03, SatirIcerik,
          GYazmac1, GYazmac2);
        GRUP12_ROL: Result := YazmacaYazmacAta($D2, $00, SatirIcerik,
          GYazmac1, GYazmac2);
        GRUP12_ROR: Result := YazmacaYazmacAta($D2, $01, SatirIcerik,
          GYazmac1, GYazmac2);
        // 2 işlem kodu da aynı. merak etme, hata yok!
        GRUP12_SAL,
        GRUP12_SHL: Result := YazmacaYazmacAta($D2, $04, SatirIcerik,
          GYazmac1, GYazmac2);
        GRUP12_SAR: Result := YazmacaYazmacAta($D2, $07, SatirIcerik,
          GYazmac1, GYazmac2);
        GRUP12_SHR: Result := YazmacaYazmacAta($D2, $05, SatirIcerik,
          GYazmac1, GYazmac2);

        GRUP12_ADD:   Result := YazmacaYazmacAta($00, -1, SatirIcerik, GYazmac1, GYazmac2);
        GRUP12_AND:   Result := YazmacaYazmacAta($20, -1, SatirIcerik, GYazmac1, GYazmac2);
        GRUP12_CMP:   Result := YazmacaYazmacAta($38, -1, SatirIcerik, GYazmac1, GYazmac2);
        // GRUP12_LEA: bu komutun yazmaçtan yazmaça ataması yok
        GRUP12_MOV:   Result := YazmacaYazmacAta($88, -1, SatirIcerik, GYazmac1, GYazmac2);
        GRUP12_OR:    Result := YazmacaYazmacAta($08, -1, SatirIcerik, GYazmac1, GYazmac2);
        GRUP12_SUB:   Result := YazmacaYazmacAta($28, -1, SatirIcerik, GYazmac1, GYazmac2);
        // xchg çalışması devam etmekte
        //GRUP12_XCHG:  Result := YazmacaYazmacAta($86, SatirIcerik, GYazmac1, GYazmac2);
        GRUP12_XOR:   Result := YazmacaYazmacAta($30, -1, SatirIcerik, GYazmac1, GYazmac2);
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

      DegerVG := SayiTipiniAl(GSabitDeger);
      if(DegerVG < GSabitDegerVG) then DegerVG := GSabitDegerVG;

      // sabit değer 1 değerinin değerlendirilmesi
      if(DegerVG = vgB1) and (GSabitDeger = 1) then
      begin

        case SatirIcerik.Komut.GrupNo of
          GRUP12_RCL: Result := YazmacaSayisalDegerAta($D0, $02, SatirIcerik,
            GYazmac1, False, GSabitDeger, GSabitDegerVG);
          GRUP12_RCR: Result := YazmacaSayisalDegerAta($D0, $03, SatirIcerik,
            GYazmac1, False, GSabitDeger, GSabitDegerVG);
          GRUP12_ROL: Result := YazmacaSayisalDegerAta($D0, $00, SatirIcerik,
            GYazmac1, False, GSabitDeger, GSabitDegerVG);
          GRUP12_ROR: Result := YazmacaSayisalDegerAta($D0, $01, SatirIcerik,
            GYazmac1, False, GSabitDeger, GSabitDegerVG);
          // 2 işlem kodu da aynı. merak etme, hata yok!
          GRUP12_SAL,
          GRUP12_SHL: Result := YazmacaSayisalDegerAta($D0, $04, SatirIcerik,
            GYazmac1, False, GSabitDeger, GSabitDegerVG);
          GRUP12_SAR: Result := YazmacaSayisalDegerAta($D0, $07, SatirIcerik,
            GYazmac1, False, GSabitDeger, GSabitDegerVG);
          GRUP12_SHR: Result := YazmacaSayisalDegerAta($D0, $05, SatirIcerik,
            GYazmac1, False, GSabitDeger, GSabitDegerVG);
        end;
      end
      // sabit değer 1 byte değerinin değerlendirilmesi
      else if(DegerVG = vgB1) then
      begin

        case SatirIcerik.Komut.GrupNo of
          GRUP12_RCL: Result := YazmacaSayisalDegerAta($C0, $02, SatirIcerik,
            GYazmac1, True, GSabitDeger, GSabitDegerVG);
          GRUP12_RCR: Result := YazmacaSayisalDegerAta($C0, $03, SatirIcerik,
            GYazmac1, True, GSabitDeger, GSabitDegerVG);
          GRUP12_ROL: Result := YazmacaSayisalDegerAta($C0, $00, SatirIcerik,
            GYazmac1, True, GSabitDeger, GSabitDegerVG);
          GRUP12_ROR: Result := YazmacaSayisalDegerAta($C0, $01, SatirIcerik,
            GYazmac1, True, GSabitDeger, GSabitDegerVG);
          // 2 işlem kodu da aynı. merak etme, hata yok!
          GRUP12_SAL,
          GRUP12_SHL: Result := YazmacaSayisalDegerAta($C0, $04, SatirIcerik,
            GYazmac1, True, GSabitDeger, GSabitDegerVG);
          GRUP12_SAR: Result := YazmacaSayisalDegerAta($C0, $07, SatirIcerik,
            GYazmac1, True, GSabitDeger, GSabitDegerVG);
          GRUP12_SHR: Result := YazmacaSayisalDegerAta($C0, $05, SatirIcerik,
            GYazmac1, True, GSabitDeger, GSabitDegerVG);
        end;
      end

      //else Result := HATA_DEVAM_EDEN_CALISMA;
    end
    // uygulanan komut
    // add     dl,'0'
    // db      80h, 0C2h, 30h
    else if(SatirIcerik.Komut.GrupNo = GRUP12_ADD) then
    begin

      // 32 bitlik yazmaca 8 bitlik veri aktarılıyor
      // bu çalışma diğer veri tiplerine genişletilecek
      if(YazmacListesi[GYazmac1].Uzunluk = yu8bGY) then
      begin

        Result := YazmacaSayisalDegerAta($80, $00, SatirIcerik, GYazmac1,
          True, GSabitDeger, GSabitDegerVG);
        //Result := HATA_YOK;
      end else Result := HATA_BILINMEYEN_HATA;
    end
    else
    begin

      // uygulanan komut
      // cmp     eax,1
      // db      83h, 0F8h, 00h
      if(SatirIcerik.Komut.GrupNo = GRUP12_CMP) then
      begin

        // 32 bitlik yazmaca 8 bitlik veri aktarılıyor
        if(YazmacListesi[GYazmac1].Uzunluk = yu32bGY) then
        begin

          // buradaki istisna değerlendirilecek
          //Result := YazmacaSayisalDegerAta($80, SatirIcerik, GYazmac1, GSabitDeger);
          KodEkle($83);
          KodEkle($C0 + (7 shl 3) + (YazmacListesi[GYazmac1].Deger and 7));
          KodEkle(GSabitDeger);
          Result := HATA_YOK;
        end else Result := HATA_BILINMEYEN_HATA;
      end
      else if(SatirIcerik.Komut.GrupNo = GRUP12_MOV) or
        (SatirIcerik.Komut.GrupNo = GRUP12_SUB) or
        (SatirIcerik.Komut.GrupNo = GRUP12_LEA) then
      begin

        // bu kısımdaki veriler yazmaçlara sabir veri aktarma şeklindedir
        // 8 bitlik veri
        if(YazmacListesi[GYazmac1].Uzunluk = yu8bGY) then
        begin

          Result := IslemKoduIleYazmacDegeriniBirlestir($B0, $B8, 0, SatirIcerik);
          if(Result = HATA_YOK) then SayisalDegerEkle(GSabitDeger, vgB1);
        end
        // 16 bitlik veri
        else if(YazmacListesi[GYazmac1].Uzunluk = yu16bGY) then
        begin

          Result := IslemKoduIleYazmacDegeriniBirlestir($B0, $B8, 0, SatirIcerik);
          if(Result = HATA_YOK) then SayisalDegerEkle(GSabitDeger, vgB2);
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

            Result := IslemKoduIleYazmacDegeriniBirlestir($B0, $B8, 0, SatirIcerik);
            if(Result = HATA_YOK) then SayisalDegerEkle(GSabitDeger, vgB4);
          end;
        end
        // 64 bitlik yazmaça sabit değer aktarma işlemi
        else if(YazmacListesi[GYazmac1].Uzunluk = yu64bGY) then
        begin

          if(GAsm2.Mimari = mim64Bit) then
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
              Result := IslemKoduIleYazmacDegeriniBirlestir($C6, $C7,  0, SatirIcerik);

              for i := 1 to 4 do
              begin

                KodEkle(Byte(GSabitDeger));
                GSabitDeger := GSabitDeger shr 8;
              end;
              Result := HATA_YOK;
            end
            // sub     rsp,8*5 -> 64 bitlik yazmaça 8 bit değer atama
            else if(SatirIcerik.Komut.GrupNo = GRUP12_SUB) then
            begin

              Result := IslemKoduIleYazmacDegeriniBirlestir($80, $83, 5, SatirIcerik);
              KodEkle(Byte(GSabitDeger));
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

// 5 aşamalı işlem kodu atama işlevleri

// 5.1 - yazmaça yazmaç ata
// işlem kodunun "İşlemKodu Yazmaç1, Yazmaç2" olması halinde gerekli
// kodlar bu işlev tarafından oluşturulur.
// Yazmac1: adreslemede kullanılacak 1. yazmacın sıra değeri
// Yazmac2: adreslemede kullanılacak 2. yazmacın sıra değeri
function YazmacaYazmacAta(IslemKodu, REGDeger: Byte; SatirIcerik: TSatirIcerik; Yazmac1,
  Yazmac2: Integer): Integer;
var
  DesMim1, DesMim2: TDestekleyenMimari;
  i: Byte;
begin

  // 64 bitlik işlem kodları yalnızca 64 bitlik mimaride kullanılabilir
  if(GAsm2.Mimari <> mim64Bit) and (YazmacListesi[Yazmac1].Uzunluk = yu64bGY) then
  begin

    Result := HATA_64BIT_MIMARI_GEREKLI;
    Exit;
  end;

  // derlenecek kod mimarisi 64 bit ise...
  if(GAsm2.Mimari = mim64Bit) and (YazmacListesi[Yazmac1].Uzunluk = yu64bGY) then

    // 0100W000 = W = 1 = 64 bit işlem kodu
    KodEkle($48)

  // derlenecek kod mimarisi 32 bit, yazmaç 32 bit değilse...
  // 66 ön ekini kodun başına ekle
  else if(GAsm2.Mimari = mim32Bit) and (YazmacListesi[Yazmac1].Uzunluk <> yu32bGY) then

    KodEkle($66)

  // derlenecek kod mimarisi 16 bit, yazmaç 16 bit değilse...
  else if(GAsm2.Mimari = mim16Bit) and (YazmacListesi[Yazmac1].Uzunluk <> yu16bGY) then

    KodEkle($66);

  DesMim1 := YazmacListesi[Yazmac1].DesMim;
  DesMim2 := YazmacListesi[Yazmac2].DesMim;

  // yazmaç uzunlukları birbirine eşit ise ...
  // mov  eax,ebx
  if(YazmacListesi[Yazmac1].Uzunluk = YazmacListesi[Yazmac2].Uzunluk) then
  begin

    // yazmacın 8 bit olması halinde "IslemKodu" kullanılacak
    // aksi durumda bir sonraki sıra değeri (IslemKodu + 1) kullanılacak
    if(YazmacListesi[Yazmac1].Uzunluk = yu8bGY) then

      KodEkle(IslemKodu)
    else KodEkle(IslemKodu + 1);

    // İşlemKodu Hedef_Yazmaç, Kaynak_Yazmaç
    // 11_HY0_KY0 -> 11 = $C0, HY0 = Hedef Yazmaç, KY0 = Kaynak Yazmaç
    // -----------------------
    // $C0 = 11000000b = yazmaç adresleme modu
    i := $C0 or ((YazmacListesi[Yazmac2].Deger and 7) shl 3) or
      (YazmacListesi[Yazmac1].Deger and 7);
    KodEkle(i);
    Result := HATA_YOK;
  end
  // yazmaç uzunlukları birbirinden farklı ise ...
  // rol  eax,cl gibi
  else if(YazmacListesi[Yazmac1].Uzunluk <> YazmacListesi[Yazmac2].Uzunluk) then
  begin

    // yazmacın 8 bit olması halinde "IslemKodu" kullanılacak
    // aksi durumda bir sonraki sıra değeri (IslemKodu + 1) kullanılacak
    if(YazmacListesi[Yazmac1].Uzunluk = yu8bGY) then

      KodEkle(IslemKodu)
    else KodEkle(IslemKodu + 1);

    // İşlemKodu Hedef_Yazmaç, Kaynak_Yazmaç
    // 11_HY0_KY0 -> 11 = $C0, HY0 = Hedef Yazmaç, KY0 = Kaynak Yazmaç
    // -----------------------
    // $C0 = 11000000b = yazmaç adresleme modu
    i := $C0 or ((REGDeger and 7) shl 3) or (YazmacListesi[Yazmac1].Deger and 7);
    KodEkle(i);
    Result := HATA_YOK;
  end else Result := HATA_ISL_KOD_KULLANIM;
end;

// 5.2 - yazmaça sayısal değer ata
// REGDeger = MOD[7..6] + REG[5..3] + RM[2..0]
function YazmacaSayisalDegerAta(IslemKodu, REGDeger: Byte; SatirIcerik: TSatirIcerik;
  Yazmac: Integer; SayisalDegerVar: Boolean; SabitDeger: Integer;
  SabitDegerVG: TVeriGenisligi): Integer;
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

// 5.3 - yazmaça bellek değeri ata
function YazmacaBellekBolgesiAta(SatirIcerik: TSatirIcerik; Yazmac1,
  Yazmac2: Integer): Integer;
begin

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
