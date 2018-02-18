{-------------------------------------------------------------------------------

  Dosya: yazmaclar.pas

  İşlev: yazmaç ve işlevlerini içerir

  Güncelleme Tarihi: 17/02/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit yazmaclar;

interface

type
  TYazmacUzunluk = (yu8Bit, yu16Bit, yu32Bit, yu64Bit);

type
  TYazmac = record
    Ad: string[3];
    Uzunluk: TYazmacUzunluk;
    Deger: Byte;
  end;

type
  TYazmacDurum = record
    Sonuc: Integer;
    Uzunluk: TYazmacUzunluk;
  end;

{ yazmaç listesi }
const
  TOPLAM_YAZMAC = 24;
  YazmacListesi: array[0..TOPLAM_YAZMAC - 1] of TYazmac = (
    (Ad: 'al';  Uzunluk: yu8Bit;  Deger: 0),
    (Ad: 'cl';  Uzunluk: yu8Bit;  Deger: 1),
    (Ad: 'dl';  Uzunluk: yu8Bit;  Deger: 2),
    (Ad: 'bl';  Uzunluk: yu8Bit;  Deger: 3),
    (Ad: 'ah';  Uzunluk: yu8Bit;  Deger: 4),
    (Ad: 'ch';  Uzunluk: yu8Bit;  Deger: 5),
    (Ad: 'dh';  Uzunluk: yu8Bit;  Deger: 6),
    (Ad: 'bh';  Uzunluk: yu8Bit;  Deger: 7),
    (Ad: 'ax';  Uzunluk: yu16Bit; Deger: 0),
    (Ad: 'cx';  Uzunluk: yu16Bit; Deger: 1),
    (Ad: 'dx';  Uzunluk: yu16Bit; Deger: 2),
    (Ad: 'bx';  Uzunluk: yu16Bit; Deger: 3),
    (Ad: 'sp';  Uzunluk: yu16Bit; Deger: 4),
    (Ad: 'bp';  Uzunluk: yu16Bit; Deger: 5),
    (Ad: 'si';  Uzunluk: yu16Bit; Deger: 6),
    (Ad: 'di';  Uzunluk: yu16Bit; Deger: 7),
    (Ad: 'eax'; Uzunluk: yu32Bit; Deger: 0),
    (Ad: 'ecx'; Uzunluk: yu32Bit; Deger: 1),
    (Ad: 'edx'; Uzunluk: yu32Bit; Deger: 2),
    (Ad: 'ebx'; Uzunluk: yu32Bit; Deger: 3),
    (Ad: 'esp'; Uzunluk: yu32Bit; Deger: 4),
    (Ad: 'ebp'; Uzunluk: yu32Bit; Deger: 5),
    (Ad: 'esi'; Uzunluk: yu32Bit; Deger: 6),
    (Ad: 'edi'; Uzunluk: yu32Bit; Deger: 7));

function YazmacBilgisiAl(AYazmac: string): TYazmacDurum;

implementation

// yazmaç sıra değerini geri döndürür
function YazmacBilgisiAl(AYazmac: string): TYazmacDurum;
var
  i: Integer;
  Yazmac: string;
begin

  Yazmac := LowerCase(AYazmac);

  Result.Sonuc := -1;

  for i := 0 to TOPLAM_YAZMAC - 1 do
  begin

    if(YazmacListesi[i].Ad = Yazmac) then
    begin

      Result.Sonuc := i;
      Result.Uzunluk := YazmacListesi[i].Uzunluk;
      Break;
    end;
  end;
end;

end.
