{-------------------------------------------------------------------------------

  Dosya: bildirimler.pas

  BİLDİRİM komutlarını yönetir

  Güncelleme Tarihi: 09/09/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit bildirimler;

interface

uses paylasim;

function BildirimleriTamamla(Bildirim: TBildirim): Integer;

implementation

uses donusum, asm2, komutlar, kodlama, sysutils, genel, dosya, dbugintf;

function BildirimleriTamamla(Bildirim: TBildirim): Integer;
var
  D: TDosya;
  i: QWord;
  KK: string;
  DosyaAcik: Boolean;
begin

  // veri tipinin karakter katarı olması durumunda karakterleri küçük harfe çevir
  if(Bildirim.VeriTipi = vKarakterDizisi) then KK := KucukHarfeCevir(Bildirim.VeriKK);

  // 1. eşittir ifadesinin KULLANILMADIĞI, vKarakterDizisi veri tipindeki ifadeler.
  // örnek: dosya.ekle 'dosya'
  if not(Bildirim.Esittir) and (Bildirim.VeriTipi = vKarakterDizisi) then
  begin

    // komut: dosya.ekle 'dosya'
    if(Bildirim.GrupNo = GRUP01_DOS_EKLE) then
    begin

      // dosyayı, açık olan dosyalar listesine ekle
      { TODO : göreceli (relative) dizin yapıları (..\..\dosya.asm) eklenerek kontrol edilecek }
      D := GAsm2.Dosyalar.ListeyeEkle(GAktifDosya.ProjeDizin + DirectorySeparator +
        KK, ddBellekte, DosyaAcik);

      if not(D = nil) then
      begin

        // dosya daha önce açılmamışsa belleğe yükle
        if not(DosyaAcik) then
        begin

          if not(D.Yukle(False)) then
          begin

            Result := HATA_DOSYA_YOK;
            Exit;
          end;
        end;

        // dosyayı derleyicinin derleme listesine ekle
        GAsm2.Derleyici.DosyaEkle(D, False);

        Result := HATA_YOK;
      end else Result := HATA_DOSYA_YOK;
    end else Result := HATA_BILD_KULLANIM;
  end
  // 2. eşittir ifadesinin kullanıldığı, vKarakterDizisi veri tipindeki ifadeler.
  // örnek: dosya.ad = 'dosya'
  else if(Bildirim.Esittir) and (Bildirim.VeriTipi = vKarakterDizisi) then
  begin

    // komut: dosya.ad = 'dosya'
    if(Bildirim.GrupNo = GRUP01_DOS_AD_) then
    begin

      GAsm2.Derleyici.CikisDosyaAdi := KK;
      Result := HATA_YOK;
    end
    // komut: dosya.biçim = 'ikili'
    else if(Bildirim.GrupNo = GRUP01_BICIM) then
    begin

      if(KK = 'pe64') then
        GAsm2.Derleyici.Bicim := dbPE64
      else if(KK = 'ikili') then
        GAsm2.Derleyici.Bicim := dbIkili
      else GAsm2.Derleyici.Bicim := dbBilinmiyor;

      Result := HATA_YOK;
    end
    // komut: dosya.uzantı = 'bin'
    else if(Bildirim.GrupNo = GRUP01_DOS_UZN) then
    begin

      GAsm2.Derleyici.CikisDosyaUzanti := KK;
      Result := HATA_YOK;
    end
    // komut: dosya.mimari = '32bit'
    else if(Bildirim.GrupNo = GRUP01_KOD_MIM) then
    begin

      case KK of
        '16bit': begin GAsm2.Derleyici.Mimari := mim16Bit; Result := HATA_YOK; end;
        '32bit': begin GAsm2.Derleyici.Mimari := mim32Bit; Result := HATA_YOK; end;
        '64bit': begin GAsm2.Derleyici.Mimari := mim64Bit; Result := HATA_YOK; end;
        else Result := HATA_BILINMEYEN_MIMARI;
      end;
      Result := HATA_YOK;
    end else Result := HATA_BILD_KULLANIM;
  end
  // 3. eşittir ifadesinin kullanıldığı, vSayi veri tipindeki ifadeler.
  // örnek: kod.adres = 0x1000
  else if(Bildirim.Esittir) and (Bildirim.VeriTipi = vSayi) then
  begin

    // komut: kod.adres = 0x1000
    if(Bildirim.GrupNo = GRUP01_KOD_ADR) then
    begin

      MevcutBellekAdresi := Bildirim.VeriSD;
      Result := HATA_YOK;
    end
    // * tabaka tanımlaması - veri uzunluğunu belirtilen sayının
    // katına (align) tamamlar
    // komut: kod.tabaka = 16
    else if(Bildirim.GrupNo = GRUP01_KOD_TBK) then
    begin

      // 0 ve 1 değerleri gözardı ediliyor
      if(Bildirim.VeriSD > 1) then
      begin

        i := MevcutBellekAdresi + Bildirim.VeriSD;
        i := i mod Bildirim.VeriSD;
        i := Bildirim.VeriSD - i;

        // işlem sonucu 0'dan büyük, align sayısından farklı olmalıdır
        if(i > 0) and (i <> Bildirim.VeriSD) then
        begin

          while i > 0 do
          begin

            KodEkle(0);
            Dec(i);
          end;
        end;
      end;

      Result := HATA_YOK;
    end else Result := HATA_BILD_KULLANIM;
  end else Result := HATA_BILINMEYEN_BILDIRIM;
end;

end.
