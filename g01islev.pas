{-------------------------------------------------------------------------------

  Dosya: g01islev.pas

  İşlev: 1. grup kodlama işlevlerini gerçekleştirir

  1. grup kodlama işlevi, BİLDİRİM ifadelerini yönetir

  Güncelleme Tarihi: 24/08/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit g01islev;

interface

uses paylasim;

function Grup01Bildirim(SatirNo: Integer; ParcaNo: Integer;
  VeriKontrolTip: TVeriKontrolTip; Veri1: string; Veri2: QWord): Integer;

implementation

uses donusum, asm2, komutlar, kodlama, sysutils, genel, dosya, Dialogs;

var
  VeriTipi: TTemelVeriTipi;
  Tanimlanan: Integer;
  Esittir: Boolean;
  sTanim: string;
  iTanim: QWord;

function Grup01Bildirim(SatirNo: Integer; ParcaNo: Integer;
  VeriKontrolTip: TVeriKontrolTip; Veri1: string; Veri2: QWord): Integer;
var
  Dosya: PDosya;
  i, j: QWord;
  s: string;
  DosyaAcik: Boolean;
begin

  // bildirim verisi gönderilmeden önceki ilk aşama
  // ilk değer atamaları gerçekleştiriliyor
  if(VeriKontrolTip = vktIlk) then
  begin

    VeriTipi := tvtTanimsiz;
    Esittir := False;
    Tanimlanan := KomutListesi[Veri2].GrupNo;
    Result := HATA_YOK;
  end
  // eşittir kontrolü
  else if(VeriKontrolTip = vktEsittir) then
  begin

    // birden fazla eşittir işaretinin gelmesi durumunda
    if(Esittir) then

      Result := HATA_BILD_KULLANIM
    else
    begin

      Esittir := True;
      Result := HATA_YOK;
    end;
  end
  // karakter dizisi kontrolü
  else if(VeriKontrolTip = vktKarakterDizisi) then
  begin

    // daha önce hiç bir veri tanımlanmadıysa...
    if(VeriTipi = tvtTanimsiz) then
    begin

      sTanim := KucukHarfeCevir(Veri1);
      VeriTipi := tvtKarakterDizisi;
      Result := HATA_YOK;
    end else Result := HATA_BILD_KULLANIM;
  end
  // sayısal veri kontrolü
  else if(VeriKontrolTip = vktSayi) then
  begin

    // daha önce hiç bir veri tanımlanmadıysa...
    if(VeriTipi = tvtTanimsiz) then
    begin

      iTanim := Veri2;
      VeriTipi := tvtSayi;
      Result := HATA_YOK;
    end else Result := HATA_BILD_KULLANIM;
  end
  // satırdaki tüm veriler bu işleve gönderildi
  // son kontrol sonucu veri üretilecek
  else if(VeriKontrolTip = vktSon) then
  begin

    // * dosya adı tanımlaması
    if(Esittir) and (Tanimlanan = GRUP01_DOS_AD_) then
    begin

      GAsm2.Derleyici.CikisDosyaAdi := sTanim;
      Result := HATA_YOK;
    end
    else if(Esittir) and (Tanimlanan = GRUP01_BICIM) then
    begin

      sTanim := KucukHarfeCevir(sTanim);
      if(sTanim = 'pe64') then
        GAsm2.Derleyici.Bicim := dbPE64
      else if(sTanim = 'ikili') then
        GAsm2.Derleyici.Bicim := dbIkili
      else GAsm2.Derleyici.Bicim := dbBilinmiyor;

      Result := HATA_YOK;
    end
    // projeye dosya ekleme işlevi
    else if(Tanimlanan = GRUP01_DOS_EKLE) then
    begin

      // derleyici dosya listesine dosya bilgilerini ekle
      { TODO : göreceli (relative) dizin yapıları (..\..\dosya.asm) eklenerek kontrol edilecek }
      Dosya := GAsm2.Dosyalar.Ekle(GAktifDosya^.ProjeDizin + DirectorySeparator +
        sTanim, ddDerleyici, DosyaAcik);

      if not(Dosya = nil) then
      begin

        // dosyayı belleğe yükle
        if(Dosya^.Yukle(False)) then
        begin

          // dosyayı derleyicinin derleme listesine ekle
          GAsm2.Derleyici.DosyaEkle(Dosya, False);

          Result := HATA_YOK;
        end else Result := HATA_DOSYA_YOK;
      end else Result := HATA_DOSYA_YOK;
    end
    // * dosya uzantı tanımlaması
    else if(Esittir) and (Tanimlanan = GRUP01_DOS_UZN) then
    begin

      GAsm2.Derleyici.CikisDosyaUzanti := sTanim;
      Result := HATA_YOK;
    end
    // * adresleme tanımlaması
    else if(Esittir) and (Tanimlanan = GRUP01_KOD_ADR) then
    begin

      // SADECE sayı verisi
      if(VeriTipi = tvtSayi) then
      begin

        MevcutBellekAdresi := iTanim;
        Result := HATA_YOK;
      end else Result := HATA_VERI_TIPI;
    end
    // * mimari tanımlaması
    else if(Esittir) and (Tanimlanan = GRUP01_KOD_MIM) then
    begin

      // SADECE karakter verisi
      if(VeriTipi = tvtKarakterDizisi) then
      begin

        case sTanim of
          '16bit': begin GAktifDosya^.Mimari := mim16Bit; Result := HATA_YOK; end;
          '32bit': begin GAktifDosya^.Mimari := mim32Bit; Result := HATA_YOK; end;
          '64bit': begin GAktifDosya^.Mimari := mim64Bit; Result := HATA_YOK; end;
          else Result := HATA_BILINMEYEN_MIMARI;
        end;
        Result := HATA_YOK;
      end else Result := HATA_VERI_TIPI;
    end
    // * tabaka tanımlaması - veri uzunluğunu belirtilen sayının
    // katına (align) tamamamlar
    else if(Esittir) and (Tanimlanan = GRUP01_KOD_TBK) then
    begin

      // SADECE sayı verisi
      if(VeriTipi = tvtSayi) then
      begin

        // 0 ve 1 değerleri gözardı ediliyor
        if(iTanim > 1) then
        begin

          j := MevcutBellekAdresi + iTanim;
          j := j mod iTanim;
          j := iTanim - j;

          // işlem sonucu 0'dan büyük, align sayısından farklı olmalıdır
          if(j > 0) and (j <> iTanim) then
          begin

            while j > 0 do
            begin

              KodEkle(0);
              Dec(j);
            end;
          end;
        end;
        Result := HATA_YOK;
      end else Result := HATA_VERI_TIPI;
    end else Result := HATA_BILINMEYEN_BILDIRIM;
  end else Result := HATA_ETIKET_TANIM;
end;

end.
