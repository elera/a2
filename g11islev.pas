{-------------------------------------------------------------------------------

  Dosya: g11islev.pas

  İşlev: 11. grup kodlama işlevlerini gerçekleştirir

  11. grup kodlama işlevi, tek parametreli yazmaç, sabit değer ve segment
    değerlerinin işlendiği komutlardır

  Güncelleme Tarihi: 19/03/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit g11islev;

interface

uses Classes, SysUtils, genel, paylasim;

function Grup11Islev(SatirNo: Integer; ParcaNo: Integer; VeriKontrolTip:
  TVeriKontrolTip; Veri1: string; Veri2: QWord): Integer;

implementation

uses kodlama, Dialogs, asm2, komutlar, yazmaclar, donusum, dbugintf;

  // ünite içi genel kullanımlık yerel değişkenler
var
  // ifadeyi yorumlayan işlevler tarafından kullanılan genel değişkenler
  ArtiIsleyiciKullanildi: Boolean;
  KoseliParantezSayisi: Integer;

function Grup11Islev(SatirNo: Integer; ParcaNo: Integer;
  VeriKontrolTip: TVeriKontrolTip; Veri1: string; Veri2: QWord): Integer;
var
  SayiTipi: TSayiTipi;
  SayisalVeri, VeriGenisligi, i: Integer;
  ii: Byte;
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

    //SendDebug('G13-Yazmaç: ' + YazmacListesi[Veri2].Ad);

    if(SatirIcerik.BolumTip1.BolumAnaTip = batYok) then
    begin

      SatirIcerik.BolumTip1.BolumAnaTip := batYazmac;
      SatirIcerik.BolumTip1.BolumAyrinti += [baHedefYazmac];
      GYazmac1 := Veri2;
      Result := HATA_YOK;
    end else Result := HATA_ISL_KOD_KULLANIM; // geçici

  end
  else if(VeriKontrolTip = vktKPAc) then
  begin

    SendDebug('G13: vktKPAc');

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

    SendDebug('G13: vktKPKapat');

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

    //SendDebug('G13: Artı');

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

    //SendDebug('G13: Ölçek');

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

    //SendDebug('G13_Sayı: ' + IntToStr(Veri2));

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

    // int komutu
    if(SatirIcerik.Komut.GrupNo = GRUP11_INT) then
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
    // jnz komutu
    else if(SatirIcerik.Komut.GrupNo = GRUP11_JNZ) then
    begin

      // jnz komut adresleme işlemi SADECE mevcut noktadan geri
      // bir adrese atlama olarak ve byte türünde değerlendirildi.
      ii := (MevcutBellekAdresi + 2) - GSabitDeger;
      KodEkle($75);
      KodEkle(-ii);
      Result := HATA_YOK;
    end
    // call komutu
    // FF /2
    // = $FF + 00 010 101 (101 = displacement)
    else if(SatirIcerik.Komut.GrupNo = GRUP11_CALL) then
    begin

      //SendDebug('G13_Z0: ' + IntToStr(GBellekSabitDeger));

      KodEkle($FF);
      KodEkle($0 + $10 + $5);

      if(SatirIcerik.BolumTip1.BolumAnaTip = batBellek) then
      begin

        if(baBellekSabitDeger in SatirIcerik.BolumTip1.BolumAyrinti) then
        begin

          for i := 1 to 4 do
          begin

            KodEkle(Byte(GBellekSabitDeger));
            GBellekSabitDeger := GBellekSabitDeger shr 8;
          end;
        end;
      end
      else
      begin

        //SendDebug('G13_Z2: ' + IntToStr(GSabitDeger));

        for i := 1 to 4 do
        begin

          KodEkle(Byte(GSabitDeger));
          GSabitDeger := GSabitDeger shr 8;
        end;
      end;

      Result := HATA_YOK;
    end
    // PUSH komutu
    // sayısal değer tamam
    else if(SatirIcerik.Komut.GrupNo = GRUP11_PUSH) then
    begin

      if(SatirIcerik.BolumTip1.BolumAnaTip = batSayisalDeger) then
      begin

        SayiTipi := SayiTipiniAl(GSabitDeger);

        // 64 bitlik sayıyı hiçbir mimari desteklememektedir
        if(VeriGenisligi = 8) then

          Result := 1
        // 32 sayıyı 16 bitlik mimari desteklememektedir
        else if(VeriGenisligi = 4) and (GAsm2.Mimari = mim16Bit) then

          Result := 1
        else
        begin

          // diğer durumlarda ilgili mimariye göre sayısal atamalar
          // yapılmaktadır. burada ön ek kavramı devreye girmekte ve
          // $66 ve diğer kontrollerin uygulanması gerekmektedir
          // bilgi: henüz uygulanmadı
          case SayiTipi of
            //stHatali: // şu aşamada değerlendirilmesi gereksiz
            st1B: begin VeriGenisligi := 1; KodEkle($6A); end;
            st2B: begin VeriGenisligi := 2; KodEkle($68); end;
            st4B: begin VeriGenisligi := 4; KodEkle($68); end;
            // 64 bitlik sayı değeri geçerli değildir
          end;

          // sayısal veriyi belleğe yaz
          SayisalVeri := GSabitDeger;
          for i := 1 to VeriGenisligi do
          begin

            KodEkle(Byte(SayisalVeri));
            SayisalVeri := SayisalVeri shr 8;
          end;

          Result := HATA_YOK;
        end;
      end
      else if(SatirIcerik.BolumTip1.BolumAnaTip = batYazmac) then
      begin

        if(YazmacListesi[GYazmac1].Uzunluk = yu32bGY) then
        begin

          KodEkle($50 + YazmacListesi[GYazmac1].Deger);
          Result := HATA_YOK;
        end else Result := HATA_DEVAM_EDEN_CALISMA;
      end;
    end
    // INC ve DEC komutları incelenmiştir
    else if(baHedefYazmac in SatirIcerik.BolumTip1.BolumAyrinti) then
    begin

      if(SatirIcerik.BolumTip1.BolumAnaTip = batYazmac) then
      begin

        if(SatirIcerik.Komut.GrupNo = GRUP11_INC) then
        begin

          SendDebug('G13_Yazmaç: ' + YazmacListesi[GYazmac1].Ad);

          KodEkle($40 + YazmacListesi[GYazmac1].Deger);
          Result := HATA_YOK;
        end
        else if(SatirIcerik.Komut.GrupNo = GRUP11_DEC) then
        begin

          //SendDebug('G13_Yazmaç: ' + YazmacListesi[GYazmac1].Ad);

          KodEkle($48 + YazmacListesi[GYazmac1].Deger);
          Result := HATA_YOK;
        end
        // div komutu
        // F7 /6
        // = $F7 + 00 110 000
        else if(SatirIcerik.Komut.GrupNo = GRUP11_DIV) then
        begin

          //SendDebug('G13_Yazmaç: ' + YazmacListesi[GYazmac1].Ad);

          KodEkle($F7);
          KodEkle($C0 + $30 + YazmacListesi[GYazmac1].Deger);
          Result := HATA_YOK;
        end;
      end;
    end else Result := 1;
  end else Result := 1;
end;

end.
