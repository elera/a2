{-------------------------------------------------------------------------------

  Dosya: degerkodla.pas

  İşlev: işlem kodundan sonraki 1 veya 2 öndeğerin (parametre) kodlamasını
    gerçekleştirir

  Güncelleme Tarihi: 02/05/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit degerkodla;
{
  işlem kodu (opcode) atama olasılıkları
  1.1 - push  1		          ; sayısal değer
  1.2 - push  eax		        ; yazmaç
  1.3 - push  [eax]	        ; yazmaç ile bellek adresleme
  1.4 - push  [1234h]       ; sayısal değer ile bellek adresleme

  2.1 - mov   eax,1		      ; sayısal değer
  2.2 - mov   eax,ebx		    ; yazmaç
  2.3 - mov   eax,[ebx]	    ; yazmaç ile bellek adresleme
  2.4 - mov   eax,[1234h]   ; sayısal değer ile bellek adresleme

  3.1 - mov   [eax],1		    ; sayısal değer
  3.2 - mov   [eax],ebx	    ; yazmaç ile bellek adresleme
  3.3 - mov   [1234h],ebx	  ; sayısal değer ile bellek adresleme
}
interface

uses paylasim, yazmaclar, genel, kodlama;

function YazmacAtamasiYap(IslemKodu: Byte; Yazmac1: Integer): Integer;
function YazmactanYazmacaAtamaYap(SatirIcerik: TSatirIcerik; Yazmac1,
  Yazmac2: Integer): Integer;

implementation

// 1.2 - işlem kodu kullanımı
{ TODO : çalışma genişletilecek ve tamamlanacak }
// Yazmac1: adreslemede kullanılacak tek yazmacın sıra değeri
function YazmacAtamasiYap(IslemKodu: Byte; Yazmac1: Integer): Integer;
begin

  KodEkle(IslemKodu + YazmacListesi[Yazmac1].Deger);
  Result := HATA_YOK;
end;

// işlem kodunun "İşlemKodu Yazmaç1, Yazmaç2" olması halinde gerekli
// kodlar bu işlev tarafından oluşturulur.
// Yazmac1: adreslemede kullanılacak 1. yazmacın sıra değeri
// Yazmac2: adreslemede kullanılacak 2. yazmacın sıra değeri
function YazmactanYazmacaAtamaYap(SatirIcerik: TSatirIcerik; Yazmac1,
  Yazmac2: Integer): Integer;
var
  DesMim1, DesMim2: TDestekleyenMimari;
  i: Byte;
begin

  DesMim1 := YazmacListesi[Yazmac1].DesMim;
  DesMim2 := YazmacListesi[Yazmac2].DesMim;

  // 1. yazmaçlar tüm mimariler tarafından destekleniyorsa
  if(DesMim1 = dmTum) and (DesMim2 = dmTum) then
  begin

    // yazmaç uzunlukları birbirine eşit ise ...
    if(YazmacListesi[Yazmac1].Uzunluk = YazmacListesi[Yazmac2].Uzunluk) then
    begin

      // İşlemKodu Hedef_Yazmaç, Kaynak_Yazmaç
      // 11_HY0_KY0 -> 11 = $C0, HY0 = Hedef Yazmaç, KY0 = Kaynak Yazmaç
      // -----------------------
      // $C0 = 11000000b = yazmaç adresleme modu
      i := $C0 or ((YazmacListesi[Yazmac2].Deger and 7) shl 3) or
        (YazmacListesi[Yazmac1].Deger and 7);
      KodEkle(i);
      Result := HATA_YOK;
    end else Result := HATA_ISL_KOD_KULLANIM;
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

end.
