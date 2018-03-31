{-------------------------------------------------------------------------------

  Dosya: g12islev.pas

  İşlev: 12. grup kodlama işlevlerini gerçekleştirir

  Güncelleme Tarihi: 14/02/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit g12islev;

interface

uses Classes, SysUtils, genel, paylasim;

function Grup12Islev(SatirNo: Integer; ParcaNo: Integer;
  VeriKontrolTip: TVeriKontrolTip; Veri1: string; Veri2: QWord): Integer;
function IslemKodunDegiskenKodlariniOlustur(SatirIcerik: TSatirIcerik): Integer;
function YazmactanYazmacaAtamaYap(SatirIcerik: TSatirIcerik): Integer;

implementation

uses dbugintf, yazmaclar, kodlama, komutlar, asm2;

// ünite içi genel kullanımlık yerel değişkenler
var
  // ifadeyi yorumlayan işlevler tarafından kullanılan genel değişkenler
  VirgulKullanildi, ArtiIsleyiciKullanildi: Boolean;
  KoseliParantezSayisi: Integer;

// mov komutu ve diğer ilgili en karmaşık komutların prototipi
function Grup12Islev(SatirNo: Integer; ParcaNo: Integer;
  VeriKontrolTip: TVeriKontrolTip; Veri1: string; Veri2: QWord): Integer;
var
  i: Integer;
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

    if(ParcaNo = 2) then
    begin

      if(SatirIcerik.BolumTip1.BolumAnaTip = batYok) then
        SatirIcerik.BolumTip1.BolumAnaTip := batYazmac;

      if(SatirIcerik.BolumTip1.BolumAnaTip = batYazmac) then
      begin

        //SendDebug('G12_Yazmaç1: ' + IntToStr(Veri2));
        GYazmac1 := Veri2;
        SatirIcerik.BolumTip1.BolumAyrinti += [baHedefYazmac];  // ?
        Result := HATA_YOK;
      end
      else //if(SatirIcerik.BolumTip1.BolumAnaTip = batBellek) then
      begin

        //SendDebug('G12_6: ' + IntToStr(Veri2));

        if(baBellekYazmac1 in SatirIcerik.BolumTip1.BolumAyrinti) then
        begin

          if(baBellekYazmac2 in SatirIcerik.BolumTip1.BolumAyrinti) then
          begin

            Result := HATA_ISL_KOD_KULLANIM
          end
          else
          begin

            SendDebug('G12_YazmaçB2: ' + YazmacListesi[Veri2].Ad);
            SatirIcerik.BolumTip1.BolumAyrinti += [baBellekYazmac2];
            GYazmacB2 := Veri2;
            Result := HATA_YOK;
          end;
        end
        else
        begin

          SendDebug('G12_YazmaçB1: ' + YazmacListesi[Veri2].Ad);
          GYazmacB1 := Veri2;
          SatirIcerik.BolumTip1.BolumAyrinti += [baBellekYazmac1];
          Result := HATA_YOK;
        end;
      end;
    end
    else if(ParcaNo = 3) then
    begin

      //SendDebug('G12_Yazmaç12_2: ' + YazmacListesi[Veri2].Ad);

      // 3. parça işlenmeden önce virgülün kullanılıp kullanılmadığı test edilmektedir
      if not VirgulKullanildi then
      begin

        Result := HATA_ISL_KULLANIM;
      end
      else
      begin

        if(SatirIcerik.BolumTip2.BolumAnaTip = batYok) then
          SatirIcerik.BolumTip2.BolumAnaTip := batYazmac;

        if(SatirIcerik.BolumTip1.BolumAnaTip = batYazmac) then
        begin

          GYazmac2 := Veri2;
          SatirIcerik.BolumTip2.BolumAyrinti += [baKaynakYazmac];
          Result := HATA_YOK;
        end
        else
        begin

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
      end;
    end else Result := HATA_ISL_KOD_KULLANIM;
  end
  else if(VeriKontrolTip = vktVirgul) then
  begin

    SendDebug('G12_vktVirgul');

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

    SendDebug('G12_vktKPAc');

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

    SendDebug('G12_vktKPKapat');

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

    SendDebug('G12_vktSayi');

    // ParcaNo 2 veya 3'ün bellek adreslemesi olması durumunda
    if(SatirIcerik.BolumTip1.BolumAnaTip = batBellek) or
      (SatirIcerik.BolumTip2.BolumAnaTip = batBellek) then
    begin

      if not(baBellekSabitDeger in SatirIcerik.BolumTip1.BolumAyrinti) then
      begin

        SatirIcerik.BolumTip1.BolumAyrinti += [baBellekSabitDeger];
        GSabitDeger := Veri2;
        Result := HATA_YOK;
      end
      else
      begin

        Result := HATA_ISL_KOD_KULLANIM;
      end;
    end
    else if(SatirIcerik.BolumTip2.BolumAnaTip = batYok) {and (ParcaNo = 3)} then
    begin

      //SendDebug('G12_Sayı1: ' + IntToStr(Veri2));
      SatirIcerik.BolumTip1.BolumAnaTip := batSayisalDeger;
      SatirIcerik.BolumTip1.BolumAyrinti += [baSabitDeger];
      GSabitDeger := Veri2;
      Result := HATA_YOK;
    end else Result := HATA_ISL_KOD_KULLANIM;
  end
  // son kontroller bu aşamada gerçekleştirilecek
  else if(VeriKontrolTip = vktSon) then
  begin

    //SendDebug('G12: ' + YazmacListesi[GYazmac1].Ad);
    //SendDebug('G12_Sayı: ' + IntToStr(GSabitDeger));

    // uygulanan komut
    // add     dl,'0'
    // db      80h, 0C2h, 30h
    if(SatirIcerik.Komut.GrupNo = GRUP12_ADD) then
    begin

      // yazmaçtan yazmaca atama işlemi
      if(SatirIcerik.BolumTip1.BolumAnaTip = batYazmac) and
        (SatirIcerik.BolumTip2.BolumAnaTip = batYazmac) then
      begin

        // bu aşamada yazmaç uyumluluğunun uyumlu olduğu farzediliyor.
        // yazmaç uyumluluğu alt satırdaki YazmactanYazmacaAtamaYap işlevi
        // tarafından yerine getirilmektedir
        case YazmacListesi[GYazmac1].Uzunluk of
          yu8bGY: KodEkle($00);
          yu16bGY:
          begin

            // 16 bitlik yazmaçların 16 bit mimari haricinde kullanılması halinde
            // 66 ön ekini kodun başına ekle
            if(GAsm2.Mimari <> mim16Bit) then KodEkle($66);

            KodEkle($01);
          end;
          yu32bGY:
          begin

            // 32 bitlik yazmaçların 16 bit mimaride kullanılması halinde
            // 66 ön ekini kodun başına ekle
            if(GAsm2.Mimari = mim16Bit) then KodEkle($66);

            KodEkle($01);
          end;
        end;

        Result := YazmactanYazmacaAtamaYap(SatirIcerik);
      end
      else
      begin

        // 32 bitlik yazmaca 8 bitlik veri aktarılıyor
        if(YazmacListesi[GYazmac1].Uzunluk = yu8bGY) then
        begin

          KodEkle($80);
          KodEkle($C0 + YazmacListesi[GYazmac1].Deger);
          KodEkle(GSabitDeger);
          Result := HATA_YOK;
        end else Result := HATA_BILINMEYEN_HATA;
      end;
    end

    // uygulanan komut
    // cmp     eax,1
    // db      83h, 0F8h, 00h
    else if(SatirIcerik.Komut.GrupNo = GRUP12_CMP) then
    begin

      // yazmaçtan yazmaca atama işlemi
      if(SatirIcerik.BolumTip1.BolumAnaTip = batYazmac) and
        (SatirIcerik.BolumTip2.BolumAnaTip = batYazmac) then
      begin

        // bu aşamada yazmaç uyumluluğunun uyumlu olduğu farzediliyor.
        // yazmaç uyumluluğu alt satırdaki YazmactanYazmacaAtamaYap işlevi
        // tarafından yerine getirilmektedir
        case YazmacListesi[GYazmac1].Uzunluk of
          yu8bGY: KodEkle($38);
          yu16bGY:
          begin

            // 16 bitlik yazmaçların 16 bit mimari haricinde kullanılması halinde
            // 66 ön ekini kodun başına ekle
            if(GAsm2.Mimari <> mim16Bit) then KodEkle($66);

            KodEkle($39);
          end;
          yu32bGY:
          begin

            // 32 bitlik yazmaçların 16 bit mimaride kullanılması halinde
            // 66 ön ekini kodun başına ekle
            if(GAsm2.Mimari = mim16Bit) then KodEkle($66);

            KodEkle($39);
          end;
        end;

        Result := YazmactanYazmacaAtamaYap(SatirIcerik);
      end
      else
      begin

        // 32 bitlik yazmaca 8 bitlik veri aktarılıyor
        if(YazmacListesi[GYazmac1].Uzunluk = yu32bGY) then
        begin

          KodEkle($83);
          KodEkle($C0 + (7 shl 3) + YazmacListesi[GYazmac1].Deger);
          KodEkle(GSabitDeger);
          Result := HATA_YOK;
        end else Result := HATA_BILINMEYEN_HATA;
      end;
    end
    else if(SatirIcerik.Komut.GrupNo = GRUP12_MOV) then
    begin

      // yazmaçtan yazmaca atama işlemi
      if(SatirIcerik.BolumTip1.BolumAnaTip = batYazmac) and
        (SatirIcerik.BolumTip2.BolumAnaTip = batYazmac) then
      begin

        // bu aşamada yazmaç uyumluluğunun uyumlu olduğu farzediliyor.
        // yazmaç uyumluluğu alt satırdaki YazmactanYazmacaAtamaYap işlevi
        // tarafından yerine getirilmektedir
        case YazmacListesi[GYazmac1].Uzunluk of
          yu8bGY: KodEkle($88);
          yu16bGY:
          begin

            // 16 bitlik yazmaçların 16 bit mimari haricinde kullanılması halinde
            // 66 ön ekini kodun başına ekle
            if(GAsm2.Mimari <> mim16Bit) then KodEkle($66);

            KodEkle($89);
          end;
          yu32bGY:
          begin

            // 32 bitlik yazmaçların 16 bit mimaride kullanılması halinde
            // 66 ön ekini kodun başına ekle
            if(GAsm2.Mimari = mim16Bit) then KodEkle($66);

            KodEkle($89);
          end;
        end;

        Result := YazmactanYazmacaAtamaYap(SatirIcerik);
      end
      else
      begin
//      Result := HATA_YOK;
//      Exit;

        // bu kısımdaki veriler yazmaçlara sabir veri aktarma şeklindedir
        // 8 bitlik veri
        if(YazmacListesi[GYazmac1].Uzunluk = yu8bGY) then
        begin

          KodEkle($B0 + YazmacListesi[GYazmac1].Deger);
          KodEkle(Byte(GSabitDeger));
          Result := HATA_YOK;
        end
        // 16 bitlik veri
        else if(YazmacListesi[GYazmac1].Uzunluk = yu16bGY) then
        begin

          KodEkle($B8 + YazmacListesi[GYazmac1].Deger);
          KodEkle(Byte(GSabitDeger));
          KodEkle(Byte(GSabitDeger shr 8));
          Result := HATA_YOK;
        end
        // 32 bitlik veri
        else if(YazmacListesi[GYazmac1].Uzunluk = yu32bGY) then
        begin

          KodEkle($B8 + YazmacListesi[GYazmac1].Deger);
          for i := 1 to 4 do
          begin

            KodEkle(Byte(GSabitDeger));
            GSabitDeger := GSabitDeger shr 8;
            Result := HATA_YOK;
          end;
        end else Result := HATA_BILINMEYEN_HATA;
      end;
    end
    else if(SatirIcerik.Komut.GrupNo = GRUP12_XOR) then
    begin

      // yazmaçtan yazmaca atama işlemi
      if(SatirIcerik.BolumTip1.BolumAnaTip = batYazmac) and
        (SatirIcerik.BolumTip2.BolumAnaTip = batYazmac) then
      begin

        // bu aşamada yazmaç uyumluluğunun uyumlu olduğu farzediliyor.
        // yazmaç uyumluluğu alt satırdaki YazmactanYazmacaAtamaYap işlevi
        // tarafından yerine getirilmektedir
        case YazmacListesi[GYazmac1].Uzunluk of
          yu8bGY: KodEkle($30);
          yu16bGY:
          begin

            // 16 bitlik yazmaçların 16 bit mimari haricinde kullanılması halinde
            // 66 ön ekini kodun başına ekle
            if(GAsm2.Mimari <> mim16Bit) then KodEkle($66);

            KodEkle($31);
          end;
          yu32bGY:
          begin

            // 32 bitlik yazmaçların 16 bit mimaride kullanılması halinde
            // 66 ön ekini kodun başına ekle
            if(GAsm2.Mimari = mim16Bit) then KodEkle($66);

            KodEkle($31);
          end;
        end;

        Result := YazmactanYazmacaAtamaYap(SatirIcerik);
      end else Result := HATA_DEVAM_EDEN_CALISMA;
    end
  end else Result := 1;
end;

// işlem kodunun "İşlemKodu Yazmaç1, Yazmaç2" olması halinde gerekli
// kodlar bu işlev tarafından oluşturulur.
function YazmactanYazmacaAtamaYap(SatirIcerik: TSatirIcerik): Integer;
var
  DesMim1, DesMim2: TDestekleyenMimari;
begin

  DesMim1 := YazmacListesi[GYazmac1].DesMim;
  DesMim2 := YazmacListesi[GYazmac2].DesMim;

  // 1. yazmaçlar tüm mimariler tarafından destekleniyorsa
  if(DesMim1 = dmTum) and (DesMim2 = dmTum) then
  begin

    // yazmaç uzunlukları birbirine eşit ise ...
    if(YazmacListesi[GYazmac1].Uzunluk = YazmacListesi[GYazmac2].Uzunluk) then

      Result := IslemKodunDegiskenKodlariniOlustur(SatirIcerik)
    else Result := HATA_ISL_KOD_KULLANIM;
  end

  // 2. yazmaçlar SADECE 64 bit mimariler tarafından destekleniyorsa
  else if(DesMim1 = dm64Bit) and (DesMim2 = dm64Bit) then
  begin

    Result := HATA_DEVAM_EDEN_CALISMA;

    { TODO : REX çalışmaları buraya eklenecek }
    {if(GAsm2.Mimari = mim64Bit) then
    begin

      KodEkle($31);
      Result := IslemKodunDegiskenKodlariniOlustur(SatirIcerik);
    end else Result := HATA_64BIT_MIMARI_GEREKLI;}
  end
end;

function IslemKodunDegiskenKodlariniOlustur(SatirIcerik: TSatirIcerik): Integer;
var
  i: Byte;
begin

  // İşlemKodu Hedef_Yazmaç, Kaynak_Yazmaç
  // 11_HY0_KY0 -> 11 = $C0, HY0 = Hedef Yazmaç, KY0 = Kaynak Yazmaç
  // -----------------------
  // 32 bit yazmaçtan 32 bit yazmaça aktarma işlemi. diğer yazmaçlar test edilsin
  if(SatirIcerik.BolumTip1.BolumAnaTip = batYazmac) and
    (SatirIcerik.BolumTip2.BolumAnaTip = batYazmac) then
  begin

    i := $C0 or (YazmacListesi[GYazmac2].Deger shl 3) or YazmacListesi[GYazmac1].Deger;
    KodEkle(i);
    Result := HATA_YOK;
  end;
end;

end.
