{-------------------------------------------------------------------------------

  Dosya: yazmaclar.pas

  İşlev: yazmaç ve işlevlerini içerir

  Güncelleme Tarihi: 24/03/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit yazmaclar;

interface

type
  TYazmacUzunluk = (yu8bGY, yu16bGY, yu16bBY, yu32bGY, yu32bHY, yu32bKY,
    yu64bGY, yu64bMMX, yu80bYN, yu128bXMM, yu256bYMM);

type
  TYazmac = record
    Ad: string[5];
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
  TOPLAM_YAZMAC = 154;
  YazmacListesi: array[0..TOPLAM_YAZMAC - 1] of TYazmac = (

    // 8 bit Genel Yazmaçlar
    (Ad: 'al';      Uzunluk: yu8bGY;      Deger: 0),
    (Ad: 'cl';      Uzunluk: yu8bGY;      Deger: 1),
    (Ad: 'dl';      Uzunluk: yu8bGY;      Deger: 2),
    (Ad: 'bl';      Uzunluk: yu8bGY;      Deger: 3),
    (Ad: 'ah';      Uzunluk: yu8bGY;      Deger: 4),
    (Ad: 'spl';     Uzunluk: yu8bGY;      Deger: 4),    // REX öneki ile kullanılır
    (Ad: 'ch';      Uzunluk: yu8bGY;      Deger: 5),
    (Ad: 'bpl';     Uzunluk: yu8bGY;      Deger: 5),    // REX öneki ile kullanılır
    (Ad: 'dh';      Uzunluk: yu8bGY;      Deger: 6),
    (Ad: 'sil';     Uzunluk: yu8bGY;      Deger: 6),    // REX öneki ile kullanılır
    (Ad: 'bh';      Uzunluk: yu8bGY;      Deger: 7),
    (Ad: 'dil';     Uzunluk: yu8bGY;      Deger: 7),    // REX öneki ile kullanılır
    (Ad: 'r8l';     Uzunluk: yu8bGY;      Deger: 0),
    (Ad: 'r9l';     Uzunluk: yu8bGY;      Deger: 1),
    (Ad: 'r10l';    Uzunluk: yu8bGY;      Deger: 2),
    (Ad: 'r11l';    Uzunluk: yu8bGY;      Deger: 3),
    (Ad: 'r12l';    Uzunluk: yu8bGY;      Deger: 4),
    (Ad: 'r13l';    Uzunluk: yu8bGY;      Deger: 5),
    (Ad: 'r14l';    Uzunluk: yu8bGY;      Deger: 6),
    (Ad: 'r15l';    Uzunluk: yu8bGY;      Deger: 7),

    // 16 bit Bölüm (segment) Yazmaçlar
    (Ad: 'es';      Uzunluk: yu16bBY;     Deger: 0),
    (Ad: 'cs';      Uzunluk: yu16bBY;     Deger: 1),
    (Ad: 'ss';      Uzunluk: yu16bBY;     Deger: 2),
    (Ad: 'ds';      Uzunluk: yu16bBY;     Deger: 3),
    (Ad: 'fs';      Uzunluk: yu16bBY;     Deger: 4),
    (Ad: 'gs';      Uzunluk: yu16bBY;     Deger: 5),

    // 16 bit Genel Yazmaçlar
    (Ad: 'ax';      Uzunluk: yu16bGY;     Deger: 0),
    (Ad: 'cx';      Uzunluk: yu16bGY;     Deger: 1),
    (Ad: 'dx';      Uzunluk: yu16bGY;     Deger: 2),
    (Ad: 'bx';      Uzunluk: yu16bGY;     Deger: 3),
    (Ad: 'sp';      Uzunluk: yu16bGY;     Deger: 4),
    (Ad: 'bp';      Uzunluk: yu16bGY;     Deger: 5),
    (Ad: 'si';      Uzunluk: yu16bGY;     Deger: 6),
    (Ad: 'di';      Uzunluk: yu16bGY;     Deger: 7),
    (Ad: 'r8w';     Uzunluk: yu16bGY;     Deger: 0),
    (Ad: 'r9w';     Uzunluk: yu16bGY;     Deger: 1),
    (Ad: 'r10w';    Uzunluk: yu16bGY;     Deger: 2),
    (Ad: 'r11w';    Uzunluk: yu16bGY;     Deger: 3),
    (Ad: 'r12w';    Uzunluk: yu16bGY;     Deger: 4),
    (Ad: 'r13w';    Uzunluk: yu16bGY;     Deger: 5),
    (Ad: 'r14w';    Uzunluk: yu16bGY;     Deger: 6),
    (Ad: 'r15w';    Uzunluk: yu16bGY;     Deger: 7),

    // 32 bit Genel Yazmaçlar
    (Ad: 'eax';     Uzunluk: yu32bGY;     Deger: 0),
    (Ad: 'ecx';     Uzunluk: yu32bGY;     Deger: 1),
    (Ad: 'edx';     Uzunluk: yu32bGY;     Deger: 2),
    (Ad: 'ebx';     Uzunluk: yu32bGY;     Deger: 3),
    (Ad: 'esp';     Uzunluk: yu32bGY;     Deger: 4),
    (Ad: 'ebp';     Uzunluk: yu32bGY;     Deger: 5),
    (Ad: 'esi';     Uzunluk: yu32bGY;     Deger: 6),
    (Ad: 'edi';     Uzunluk: yu32bGY;     Deger: 7),
    (Ad: 'r8d';     Uzunluk: yu32bGY;     Deger: 0),
    (Ad: 'r9d';     Uzunluk: yu32bGY;     Deger: 1),
    (Ad: 'r10d';    Uzunluk: yu32bGY;     Deger: 2),
    (Ad: 'r11d';    Uzunluk: yu32bGY;     Deger: 3),
    (Ad: 'r12d';    Uzunluk: yu32bGY;     Deger: 4),
    (Ad: 'r13d';    Uzunluk: yu32bGY;     Deger: 5),
    (Ad: 'r14d';    Uzunluk: yu32bGY;     Deger: 6),
    (Ad: 'r15d';    Uzunluk: yu32bGY;     Deger: 7),

    // 32 bit Hata Yazmaçları (debug)
    (Ad: 'dr0';     Uzunluk: yu32bHY;     Deger: 0),
    (Ad: 'dr1';     Uzunluk: yu32bHY;     Deger: 1),
    (Ad: 'dr2';     Uzunluk: yu32bHY;     Deger: 2),
    (Ad: 'dr3';     Uzunluk: yu32bHY;     Deger: 3),
    (Ad: 'dr4';     Uzunluk: yu32bHY;     Deger: 4),
    (Ad: 'dr5';     Uzunluk: yu32bHY;     Deger: 5),
    (Ad: 'dr6';     Uzunluk: yu32bHY;     Deger: 6),
    (Ad: 'dr7';     Uzunluk: yu32bHY;     Deger: 7),
    (Ad: 'dr8';     Uzunluk: yu32bHY;     Deger: 0),
    (Ad: 'dr9';     Uzunluk: yu32bHY;     Deger: 1),
    (Ad: 'dr10';    Uzunluk: yu32bHY;     Deger: 2),
    (Ad: 'dr11';    Uzunluk: yu32bHY;     Deger: 3),
    (Ad: 'dr12';    Uzunluk: yu32bHY;     Deger: 4),
    (Ad: 'dr13';    Uzunluk: yu32bHY;     Deger: 5),
    (Ad: 'dr14';    Uzunluk: yu32bHY;     Deger: 6),
    (Ad: 'dr15';    Uzunluk: yu32bHY;     Deger: 7),

    // 32 bit Kontrol Yazmaçları
    (Ad: 'cr0';     Uzunluk: yu32bKY;     Deger: 0),
    (Ad: 'cr1';     Uzunluk: yu32bKY;     Deger: 1),
    (Ad: 'cr2';     Uzunluk: yu32bKY;     Deger: 2),
    (Ad: 'cr3';     Uzunluk: yu32bKY;     Deger: 3),
    (Ad: 'cr4';     Uzunluk: yu32bKY;     Deger: 4),
    (Ad: 'cr5';     Uzunluk: yu32bKY;     Deger: 5),
    (Ad: 'cr6';     Uzunluk: yu32bKY;     Deger: 6),
    (Ad: 'cr7';     Uzunluk: yu32bKY;     Deger: 7),
    (Ad: 'cr8';     Uzunluk: yu32bKY;     Deger: 0),
    (Ad: 'cr9';     Uzunluk: yu32bKY;     Deger: 1),
    (Ad: 'cr10';    Uzunluk: yu32bKY;     Deger: 2),
    (Ad: 'cr11';    Uzunluk: yu32bKY;     Deger: 3),
    (Ad: 'cr12';    Uzunluk: yu32bKY;     Deger: 4),
    (Ad: 'cr13';    Uzunluk: yu32bKY;     Deger: 5),
    (Ad: 'cr14';    Uzunluk: yu32bKY;     Deger: 6),
    (Ad: 'cr15';    Uzunluk: yu32bKY;     Deger: 7),

    // 64 bit Genel Yazmaçlar
    (Ad: 'rax';     Uzunluk: yu64bGY;     Deger: 0),
    (Ad: 'rcx';     Uzunluk: yu64bGY;     Deger: 1),
    (Ad: 'rdx';     Uzunluk: yu64bGY;     Deger: 2),
    (Ad: 'rbx';     Uzunluk: yu64bGY;     Deger: 3),
    (Ad: 'rsp';     Uzunluk: yu64bGY;     Deger: 4),
    (Ad: 'rbp';     Uzunluk: yu64bGY;     Deger: 5),
    (Ad: 'rsi';     Uzunluk: yu64bGY;     Deger: 6),
    (Ad: 'rdi';     Uzunluk: yu64bGY;     Deger: 7),
    (Ad: 'r8';      Uzunluk: yu64bGY;     Deger: 0),
    (Ad: 'r9';      Uzunluk: yu64bGY;     Deger: 1),
    (Ad: 'r10';     Uzunluk: yu64bGY;     Deger: 2),
    (Ad: 'r11';     Uzunluk: yu64bGY;     Deger: 3),
    (Ad: 'r12';     Uzunluk: yu64bGY;     Deger: 4),
    (Ad: 'r13';     Uzunluk: yu64bGY;     Deger: 5),
    (Ad: 'r14';     Uzunluk: yu64bGY;     Deger: 6),
    (Ad: 'r15';     Uzunluk: yu64bGY;     Deger: 7),

    // 64 bit MMX yazmaçlar
    (Ad: 'mmx0';    Uzunluk: yu64bMMX;    Deger: 0),
    (Ad: 'mmx1';    Uzunluk: yu64bMMX;    Deger: 1),
    (Ad: 'mmx2';    Uzunluk: yu64bMMX;    Deger: 2),
    (Ad: 'mmx3';    Uzunluk: yu64bMMX;    Deger: 3),
    (Ad: 'mmx4';    Uzunluk: yu64bMMX;    Deger: 4),
    (Ad: 'mmx5';    Uzunluk: yu64bMMX;    Deger: 5),
    (Ad: 'mmx6';    Uzunluk: yu64bMMX;    Deger: 6),
    (Ad: 'mmx7';    Uzunluk: yu64bMMX;    Deger: 7),

    // 80 bit Yüzen Nokta (Floating Point - x87 tip) yazmaçlar
    (Ad: 'st0';     Uzunluk: yu80bYN;     Deger: 0),
    (Ad: 'st1';     Uzunluk: yu80bYN;     Deger: 1),
    (Ad: 'st2';     Uzunluk: yu80bYN;     Deger: 2),
    (Ad: 'st3';     Uzunluk: yu80bYN;     Deger: 3),
    (Ad: 'st4';     Uzunluk: yu80bYN;     Deger: 4),
    (Ad: 'st5';     Uzunluk: yu80bYN;     Deger: 5),
    (Ad: 'st6';     Uzunluk: yu80bYN;     Deger: 6),
    (Ad: 'st7';     Uzunluk: yu80bYN;     Deger: 7),

    // 128 bit XMM yazmaçlar
    (Ad: 'xmm0';    Uzunluk: yu128bXMM;   Deger: 0),
    (Ad: 'xmm1';    Uzunluk: yu128bXMM;   Deger: 1),
    (Ad: 'xmm2';    Uzunluk: yu128bXMM;   Deger: 2),
    (Ad: 'xmm3';    Uzunluk: yu128bXMM;   Deger: 3),
    (Ad: 'xmm4';    Uzunluk: yu128bXMM;   Deger: 4),
    (Ad: 'xmm5';    Uzunluk: yu128bXMM;   Deger: 5),
    (Ad: 'xmm6';    Uzunluk: yu128bXMM;   Deger: 6),
    (Ad: 'xmm7';    Uzunluk: yu128bXMM;   Deger: 7),
    (Ad: 'xmm8';    Uzunluk: yu128bXMM;   Deger: 0),
    (Ad: 'xmm9';    Uzunluk: yu128bXMM;   Deger: 1),
    (Ad: 'xmm10';   Uzunluk: yu128bXMM;   Deger: 2),
    (Ad: 'xmm11';   Uzunluk: yu128bXMM;   Deger: 3),
    (Ad: 'xmm12';   Uzunluk: yu128bXMM;   Deger: 4),
    (Ad: 'xmm13';   Uzunluk: yu128bXMM;   Deger: 5),
    (Ad: 'xmm14';   Uzunluk: yu128bXMM;   Deger: 6),
    (Ad: 'xmm15';   Uzunluk: yu128bXMM;   Deger: 7),

    // 256 bit YMM yazmaçlar
    (Ad: 'ymm0';    Uzunluk: yu256bYMM;   Deger: 0),
    (Ad: 'ymm1';    Uzunluk: yu256bYMM;   Deger: 1),
    (Ad: 'ymm2';    Uzunluk: yu256bYMM;   Deger: 2),
    (Ad: 'ymm3';    Uzunluk: yu256bYMM;   Deger: 3),
    (Ad: 'ymm4';    Uzunluk: yu256bYMM;   Deger: 4),
    (Ad: 'ymm5';    Uzunluk: yu256bYMM;   Deger: 5),
    (Ad: 'ymm6';    Uzunluk: yu256bYMM;   Deger: 6),
    (Ad: 'ymm7';    Uzunluk: yu256bYMM;   Deger: 7),
    (Ad: 'ymm8';    Uzunluk: yu256bYMM;   Deger: 0),
    (Ad: 'ymm9';    Uzunluk: yu256bYMM;   Deger: 1),
    (Ad: 'ymm10';   Uzunluk: yu256bYMM;   Deger: 2),
    (Ad: 'ymm11';   Uzunluk: yu256bYMM;   Deger: 3),
    (Ad: 'ymm12';   Uzunluk: yu256bYMM;   Deger: 4),
    (Ad: 'ymm13';   Uzunluk: yu256bYMM;   Deger: 5),
    (Ad: 'ymm14';   Uzunluk: yu256bYMM;   Deger: 6),
    (Ad: 'ymm15';   Uzunluk: yu256bYMM;   Deger: 7));

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
