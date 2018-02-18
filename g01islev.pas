{-------------------------------------------------------------------------------

  Dosya: g01islev.pas

  İşlev: 1. grup kodlama işlevlerini gerçekleştirir

  1. grup kodlama işlevi, derleyici koşullarını yönlendirmede kullanılan bildirimlerdir

  Güncelleme Tarihi: 18/02/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit g01islev;

interface

uses genel;

function Grup01Bildirim(ParcaNo: Integer; VeriKontrolTip: TVeriKontrolTip;
  Veri1: string; Veri2: QWord): Integer;

implementation

uses donusum, asm2, komutlar;

var
  Tanimlanan: Integer;
  Tamam, Esittir: Boolean;
  Tanim: string;

function Grup01Bildirim(ParcaNo: Integer; VeriKontrolTip: TVeriKontrolTip;
  Veri1: string; Veri2: QWord): Integer;
begin

  // tanım verisi gönderilmeden önceki ilk aşama
  // ilk değer atamaları gerçekleştiriliyor
  if(VeriKontrolTip = vktIlk) then
  begin

    Tamam := False;
    Esittir := False;
    Tanimlanan := KomutListesi[Veri2].GrupNo;
    Result := HATA_YOK;
  end
  // eşittir kontrolü
  else if(VeriKontrolTip = vktEsittir) then
  begin

    // birden fazla eşittir işaretinin gelmesi durumunda
    if(Esittir) then

      Result := HATA_BILDIRIM_KULLANIM
    else
    begin

      Esittir := True;
      Result := HATA_YOK;
    end;
  end
  // karakter dizisi kontrolü
  else if(VeriKontrolTip = vktKarakterDizisi) then
  begin

    // ifadenin tamamlanmış olması halinde halen veri geliyorsa
    if(Tamam) then

      Result := HATA_BILDIRIM_KULLANIM
    else
    begin

      Tanim := KucukHarfeCevir(Veri1);
      Tamam := True;
      Result := HATA_YOK;
    end;
  end
  // satırdaki tüm veriler bu işleve gönderildi
  // son kontrol sonucu veri üretilecek
  else if(VeriKontrolTip = vktSon) then
  begin

    // 1. mimari tanımlaması
    if(Tanimlanan = GRUP01_KOD_MIM) then
    begin

      case Tanim of
        '16bit': begin GAsm2.Mimari := mim16Bit; Result := HATA_YOK; end;
        '32bit': begin GAsm2.Mimari := mim32Bit; Result := HATA_YOK; end;
        '64bit': begin GAsm2.Mimari := mim64Bit; Result := HATA_YOK; end;
        else Result := HATA_BILINMEYEN_MIMARI;
      end;
    end
    // 2. dosya adı tanımlaması
    else if(Tanimlanan = GRUP01_DOS_ADI) then
    begin

      GAsm2.DosyaAdi := Tanim;
      Result := HATA_YOK;
    end
    // 3. dosya uzantı tanımlaması
    else if(Tanimlanan = GRUP01_DOS_UZN) then
    begin

      GAsm2.DosyaUzanti := Tanim;
      Result := HATA_YOK;
    end else Result := HATA_BILINMEYEN_BILDIRIM;
  end else Result := HATA_BILINMEYEN_BILDIRIM;
end;

end.
