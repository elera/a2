{-------------------------------------------------------------------------------

  Dosya: g01islev.pas

  İşlev: 1. grup kodlama işlevlerini gerçekleştirir

  1. grup kodlama işlevi, BİLDİRİM ifadelerini yönetir

  Güncelleme Tarihi: 13/08/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit g01islev;

interface

uses paylasim;

function Grup01Bildirim(SatirNo: Integer; ParcaNo: Integer;
  VeriKontrolTip: TVeriKontrolTip; Veri1: string; Veri2: QWord): Integer;

implementation

uses donusum, asm2, komutlar, kodlama, sysutils, genel, dosya;

var
  VeriTipi: TTemelVeriTipi;
  Tanimlanan: Integer;
  Esittir: Boolean;
  sTanim: string;
  iTanim: QWord;

function Grup01Bildirim(SatirNo: Integer; ParcaNo: Integer;
  VeriKontrolTip: TVeriKontrolTip; Veri1: string; Veri2: QWord): Integer;
var
  Dosya: TDosya;
  i, j: QWord;
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

    if(Esittir) then
    begin

      // * dosya adı tanımlaması
      if(Tanimlanan = GRUP01_DOS_AD_) then
      begin

        GAktifDosya.CikisDosyaAdi := sTanim;
        Result := HATA_YOK;
      end
      else if(Tanimlanan = GRUP01_BICIM) then
      begin

        sTanim := KucukHarfeCevir(sTanim);
        if(sTanim = 'pe64') then
          GAktifDosya.Bicim := dbPE64
        else if(sTanim = 'ikili') then
          GAktifDosya.Bicim := dbIkili
        else GAktifDosya.Bicim := dbBilinmiyor;

        Result := HATA_YOK;
      end
      // * dosya uzantı tanımlaması
      else if(Tanimlanan = GRUP01_DOS_UZN) then
      begin

        GAktifDosya.CikisDosyaUzanti := sTanim;
        Result := HATA_YOK;
      end
      // * adresleme tanımlaması
      else if(Tanimlanan = GRUP01_KOD_ADR) then
      begin

        // SADECE sayı verisi
        if(VeriTipi = tvtSayi) then
        begin

          MevcutBellekAdresi := iTanim;
          Result := HATA_YOK;
        end else Result := HATA_VERI_TIPI;
      end
      // * mimari tanımlaması
      else if(Tanimlanan = GRUP01_KOD_MIM) then
      begin

        // SADECE karakter verisi
        if(VeriTipi = tvtKarakterDizisi) then
        begin

          case sTanim of
            '16bit': begin GAktifDosya.Mimari := mim16Bit; Result := HATA_YOK; end;
            '32bit': begin GAktifDosya.Mimari := mim32Bit; Result := HATA_YOK; end;
            '64bit': begin GAktifDosya.Mimari := mim64Bit; Result := HATA_YOK; end;
            else Result := HATA_BILINMEYEN_MIMARI;
          end;
          Result := HATA_YOK;
        end else Result := HATA_VERI_TIPI;
      end
      // * tabaka tanımlaması - veri uzunluğunu belirtilen sayının
      // katına (align) tamamamlar
      else if(Tanimlanan = GRUP01_KOD_TBK) then
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
  end else Result := HATA_BEKLENMEYEN_IFADE;
end;

end.
