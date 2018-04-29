{-------------------------------------------------------------------------------

  Dosya: yazmaclar.pas

  İşlev: yazmaç ve işlevlerini içerir

  Güncelleme Tarihi: 15/04/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit yazmaclar;

interface

type
  // yazmaçların kullanılabilineceği / desteklenen mimariler
  TDestekleyenMimari = (dmTum, dm16Bit, dm32Bit, dm64Bit);

  TYazmacUzunluk = (yu8bGY, yu16bGY, yu16bBY, yu32bGY, yu32bHY, yu32bKY,
    yu64bGY, yu64bMMX, yu80bYN, yu128bXMM, yu256bYMM);

type
  TYazmac = record
    Ad: string[5];
    Uzunluk: TYazmacUzunluk;
    Deger: Byte;
    DesMim: TDestekleyenMimari;
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
    (Ad: 'al';      Uzunluk: yu8bGY;      Deger: 0;   DesMim: dmTum),
    (Ad: 'cl';      Uzunluk: yu8bGY;      Deger: 1;   DesMim: dmTum),
    (Ad: 'dl';      Uzunluk: yu8bGY;      Deger: 2;   DesMim: dmTum),
    (Ad: 'bl';      Uzunluk: yu8bGY;      Deger: 3;   DesMim: dmTum),
    (Ad: 'ah';      Uzunluk: yu8bGY;      Deger: 4;   DesMim: dmTum),
    (Ad: 'ch';      Uzunluk: yu8bGY;      Deger: 5;   DesMim: dmTum),
    (Ad: 'dh';      Uzunluk: yu8bGY;      Deger: 6;   DesMim: dmTum),
    (Ad: 'bh';      Uzunluk: yu8bGY;      Deger: 7;   DesMim: dmTum),
    (Ad: 'r8l';     Uzunluk: yu8bGY;      Deger: 8;   DesMim: dm64Bit),
    (Ad: 'r9l';     Uzunluk: yu8bGY;      Deger: 9;   DesMim: dm64Bit),
    (Ad: 'r10l';    Uzunluk: yu8bGY;      Deger: 10;  DesMim: dm64Bit),
    (Ad: 'r11l';    Uzunluk: yu8bGY;      Deger: 11;  DesMim: dm64Bit),
    (Ad: 'r12l';    Uzunluk: yu8bGY;      Deger: 12;  DesMim: dm64Bit),
    (Ad: 'spl';     Uzunluk: yu8bGY;      Deger: 12;  DesMim: dm64Bit),
    (Ad: 'r13l';    Uzunluk: yu8bGY;      Deger: 13;  DesMim: dm64Bit),
    (Ad: 'bpl';     Uzunluk: yu8bGY;      Deger: 13;  DesMim: dm64Bit),
    (Ad: 'r14l';    Uzunluk: yu8bGY;      Deger: 14;  DesMim: dm64Bit),
    (Ad: 'sil';     Uzunluk: yu8bGY;      Deger: 14;  DesMim: dm64Bit),
    (Ad: 'r15l';    Uzunluk: yu8bGY;      Deger: 15;  DesMim: dm64Bit),
    (Ad: 'dil';     Uzunluk: yu8bGY;      Deger: 15;  DesMim: dm64Bit),

    { TODO : mimari bazında incelenecek yazmaçlar }

    // 16 bit Bölüm (segment) Yazmaçlar
    (Ad: 'es';      Uzunluk: yu16bBY;     Deger: 0),
    (Ad: 'cs';      Uzunluk: yu16bBY;     Deger: 1),
    (Ad: 'ss';      Uzunluk: yu16bBY;     Deger: 2),
    (Ad: 'ds';      Uzunluk: yu16bBY;     Deger: 3),
    (Ad: 'fs';      Uzunluk: yu16bBY;     Deger: 4),
    (Ad: 'gs';      Uzunluk: yu16bBY;     Deger: 5),

    // 16 bit Genel Yazmaçlar
    (Ad: 'ax';      Uzunluk: yu16bGY;     Deger: 0;   DesMim: dmTum),
    (Ad: 'cx';      Uzunluk: yu16bGY;     Deger: 1;   DesMim: dmTum),
    (Ad: 'dx';      Uzunluk: yu16bGY;     Deger: 2;   DesMim: dmTum),
    (Ad: 'bx';      Uzunluk: yu16bGY;     Deger: 3;   DesMim: dmTum),
    (Ad: 'sp';      Uzunluk: yu16bGY;     Deger: 4;   DesMim: dmTum),
    (Ad: 'bp';      Uzunluk: yu16bGY;     Deger: 5;   DesMim: dmTum),
    (Ad: 'si';      Uzunluk: yu16bGY;     Deger: 6;   DesMim: dmTum),
    (Ad: 'di';      Uzunluk: yu16bGY;     Deger: 7;   DesMim: dmTum),
    (Ad: 'r8w';     Uzunluk: yu16bGY;     Deger: 8;   DesMim: dm64Bit),
    (Ad: 'r9w';     Uzunluk: yu16bGY;     Deger: 9;   DesMim: dm64Bit),
    (Ad: 'r10w';    Uzunluk: yu16bGY;     Deger: 10;  DesMim: dm64Bit),
    (Ad: 'r11w';    Uzunluk: yu16bGY;     Deger: 11;  DesMim: dm64Bit),
    (Ad: 'r12w';    Uzunluk: yu16bGY;     Deger: 12;  DesMim: dm64Bit),
    (Ad: 'r13w';    Uzunluk: yu16bGY;     Deger: 13;  DesMim: dm64Bit),
    (Ad: 'r14w';    Uzunluk: yu16bGY;     Deger: 14;  DesMim: dm64Bit),
    (Ad: 'r15w';    Uzunluk: yu16bGY;     Deger: 15;  DesMim: dm64Bit),

    // 32 bit Genel Yazmaçlar
    (Ad: 'eax';     Uzunluk: yu32bGY;     Deger: 0;   DesMim: dmTum),
    (Ad: 'ecx';     Uzunluk: yu32bGY;     Deger: 1;   DesMim: dmTum),
    (Ad: 'edx';     Uzunluk: yu32bGY;     Deger: 2;   DesMim: dmTum),
    (Ad: 'ebx';     Uzunluk: yu32bGY;     Deger: 3;   DesMim: dmTum),
    (Ad: 'esp';     Uzunluk: yu32bGY;     Deger: 4;   DesMim: dmTum),
    (Ad: 'ebp';     Uzunluk: yu32bGY;     Deger: 5;   DesMim: dmTum),
    (Ad: 'esi';     Uzunluk: yu32bGY;     Deger: 6;   DesMim: dmTum),
    (Ad: 'edi';     Uzunluk: yu32bGY;     Deger: 7;   DesMim: dmTum),
    (Ad: 'r8d';     Uzunluk: yu32bGY;     Deger: 8;   DesMim: dm64Bit),
    (Ad: 'r9d';     Uzunluk: yu32bGY;     Deger: 9;   DesMim: dm64Bit),
    (Ad: 'r10d';    Uzunluk: yu32bGY;     Deger: 10;  DesMim: dm64Bit),
    (Ad: 'r11d';    Uzunluk: yu32bGY;     Deger: 11;  DesMim: dm64Bit),
    (Ad: 'r12d';    Uzunluk: yu32bGY;     Deger: 12;  DesMim: dm64Bit),
    (Ad: 'r13d';    Uzunluk: yu32bGY;     Deger: 13;  DesMim: dm64Bit),
    (Ad: 'r14d';    Uzunluk: yu32bGY;     Deger: 14;  DesMim: dm64Bit),
    (Ad: 'r15d';    Uzunluk: yu32bGY;     Deger: 15;  DesMim: dm64Bit),

    { TODO : mimari bazında incelenecek yazmaçlar }

    // 32 bit Hata Yazmaçları (debug)
    (Ad: 'dr0';     Uzunluk: yu32bHY;     Deger: 0),
    (Ad: 'dr1';     Uzunluk: yu32bHY;     Deger: 1),
    (Ad: 'dr2';     Uzunluk: yu32bHY;     Deger: 2),
    (Ad: 'dr3';     Uzunluk: yu32bHY;     Deger: 3),
    (Ad: 'dr4';     Uzunluk: yu32bHY;     Deger: 4),
    (Ad: 'dr5';     Uzunluk: yu32bHY;     Deger: 5),
    (Ad: 'dr6';     Uzunluk: yu32bHY;     Deger: 6),
    (Ad: 'dr7';     Uzunluk: yu32bHY;     Deger: 7),
    (Ad: 'dr8';     Uzunluk: yu32bHY;     Deger: 8),
    (Ad: 'dr9';     Uzunluk: yu32bHY;     Deger: 9),
    (Ad: 'dr10';    Uzunluk: yu32bHY;     Deger: 10),
    (Ad: 'dr11';    Uzunluk: yu32bHY;     Deger: 11),
    (Ad: 'dr12';    Uzunluk: yu32bHY;     Deger: 12),
    (Ad: 'dr13';    Uzunluk: yu32bHY;     Deger: 13),
    (Ad: 'dr14';    Uzunluk: yu32bHY;     Deger: 14),
    (Ad: 'dr15';    Uzunluk: yu32bHY;     Deger: 15),

    { TODO : mimari bazında incelenecek yazmaçlar }

    // 32 bit Kontrol Yazmaçları
    (Ad: 'cr0';     Uzunluk: yu32bKY;     Deger: 0),
    (Ad: 'cr1';     Uzunluk: yu32bKY;     Deger: 1),
    (Ad: 'cr2';     Uzunluk: yu32bKY;     Deger: 2),
    (Ad: 'cr3';     Uzunluk: yu32bKY;     Deger: 3),
    (Ad: 'cr4';     Uzunluk: yu32bKY;     Deger: 4),
    (Ad: 'cr5';     Uzunluk: yu32bKY;     Deger: 5),
    (Ad: 'cr6';     Uzunluk: yu32bKY;     Deger: 6),
    (Ad: 'cr7';     Uzunluk: yu32bKY;     Deger: 7),
    (Ad: 'cr8';     Uzunluk: yu32bKY;     Deger: 8),
    (Ad: 'cr9';     Uzunluk: yu32bKY;     Deger: 9),
    (Ad: 'cr10';    Uzunluk: yu32bKY;     Deger: 10),
    (Ad: 'cr11';    Uzunluk: yu32bKY;     Deger: 11),
    (Ad: 'cr12';    Uzunluk: yu32bKY;     Deger: 12),
    (Ad: 'cr13';    Uzunluk: yu32bKY;     Deger: 13),
    (Ad: 'cr14';    Uzunluk: yu32bKY;     Deger: 14),
    (Ad: 'cr15';    Uzunluk: yu32bKY;     Deger: 15),

    // 64 bit Genel Yazmaçlar
    (Ad: 'rax';     Uzunluk: yu64bGY;     Deger: 0;   DesMim: dm64Bit),
    (Ad: 'rcx';     Uzunluk: yu64bGY;     Deger: 1;   DesMim: dm64Bit),
    (Ad: 'rdx';     Uzunluk: yu64bGY;     Deger: 2;   DesMim: dm64Bit),
    (Ad: 'rbx';     Uzunluk: yu64bGY;     Deger: 3;   DesMim: dm64Bit),
    (Ad: 'rsp';     Uzunluk: yu64bGY;     Deger: 4;   DesMim: dm64Bit),
    (Ad: 'rbp';     Uzunluk: yu64bGY;     Deger: 5;   DesMim: dm64Bit),
    (Ad: 'rsi';     Uzunluk: yu64bGY;     Deger: 6;   DesMim: dm64Bit),
    (Ad: 'rdi';     Uzunluk: yu64bGY;     Deger: 7;   DesMim: dm64Bit),
    (Ad: 'r8';      Uzunluk: yu64bGY;     Deger: 8;   DesMim: dm64Bit),
    (Ad: 'r9';      Uzunluk: yu64bGY;     Deger: 9;   DesMim: dm64Bit),
    (Ad: 'r10';     Uzunluk: yu64bGY;     Deger: 10;  DesMim: dm64Bit),
    (Ad: 'r11';     Uzunluk: yu64bGY;     Deger: 11;  DesMim: dm64Bit),
    (Ad: 'r12';     Uzunluk: yu64bGY;     Deger: 12;  DesMim: dm64Bit),
    (Ad: 'r13';     Uzunluk: yu64bGY;     Deger: 13;  DesMim: dm64Bit),
    (Ad: 'r14';     Uzunluk: yu64bGY;     Deger: 14;  DesMim: dm64Bit),
    (Ad: 'r15';     Uzunluk: yu64bGY;     Deger: 15;  DesMim: dm64Bit),

    { TODO : mimari bazında incelenecek yazmaçlar }

    // 64 bit MMX yazmaçlar
    (Ad: 'mmx0';    Uzunluk: yu64bMMX;    Deger: 0),
    (Ad: 'mmx1';    Uzunluk: yu64bMMX;    Deger: 1),
    (Ad: 'mmx2';    Uzunluk: yu64bMMX;    Deger: 2),
    (Ad: 'mmx3';    Uzunluk: yu64bMMX;    Deger: 3),
    (Ad: 'mmx4';    Uzunluk: yu64bMMX;    Deger: 4),
    (Ad: 'mmx5';    Uzunluk: yu64bMMX;    Deger: 5),
    (Ad: 'mmx6';    Uzunluk: yu64bMMX;    Deger: 6),
    (Ad: 'mmx7';    Uzunluk: yu64bMMX;    Deger: 7),

    { TODO : mimari bazında incelenecek yazmaçlar }

    // 80 bit Yüzen Nokta (Floating Point - x87 tip) yazmaçlar
    (Ad: 'st0';     Uzunluk: yu80bYN;     Deger: 0),
    (Ad: 'st1';     Uzunluk: yu80bYN;     Deger: 1),
    (Ad: 'st2';     Uzunluk: yu80bYN;     Deger: 2),
    (Ad: 'st3';     Uzunluk: yu80bYN;     Deger: 3),
    (Ad: 'st4';     Uzunluk: yu80bYN;     Deger: 4),
    (Ad: 'st5';     Uzunluk: yu80bYN;     Deger: 5),
    (Ad: 'st6';     Uzunluk: yu80bYN;     Deger: 6),
    (Ad: 'st7';     Uzunluk: yu80bYN;     Deger: 7),

    { TODO : mimari bazında incelenecek yazmaçlar }

    // 128 bit XMM yazmaçlar
    (Ad: 'xmm0';    Uzunluk: yu128bXMM;   Deger: 0),
    (Ad: 'xmm1';    Uzunluk: yu128bXMM;   Deger: 1),
    (Ad: 'xmm2';    Uzunluk: yu128bXMM;   Deger: 2),
    (Ad: 'xmm3';    Uzunluk: yu128bXMM;   Deger: 3),
    (Ad: 'xmm4';    Uzunluk: yu128bXMM;   Deger: 4),
    (Ad: 'xmm5';    Uzunluk: yu128bXMM;   Deger: 5),
    (Ad: 'xmm6';    Uzunluk: yu128bXMM;   Deger: 6),
    (Ad: 'xmm7';    Uzunluk: yu128bXMM;   Deger: 7),
    (Ad: 'xmm8';    Uzunluk: yu128bXMM;   Deger: 8),
    (Ad: 'xmm9';    Uzunluk: yu128bXMM;   Deger: 9),
    (Ad: 'xmm10';   Uzunluk: yu128bXMM;   Deger: 10),
    (Ad: 'xmm11';   Uzunluk: yu128bXMM;   Deger: 11),
    (Ad: 'xmm12';   Uzunluk: yu128bXMM;   Deger: 12),
    (Ad: 'xmm13';   Uzunluk: yu128bXMM;   Deger: 13),
    (Ad: 'xmm14';   Uzunluk: yu128bXMM;   Deger: 14),
    (Ad: 'xmm15';   Uzunluk: yu128bXMM;   Deger: 15),

    { TODO : mimari bazında incelenecek yazmaçlar }

    // 256 bit YMM yazmaçlar
    (Ad: 'ymm0';    Uzunluk: yu256bYMM;   Deger: 0),
    (Ad: 'ymm1';    Uzunluk: yu256bYMM;   Deger: 1),
    (Ad: 'ymm2';    Uzunluk: yu256bYMM;   Deger: 2),
    (Ad: 'ymm3';    Uzunluk: yu256bYMM;   Deger: 3),
    (Ad: 'ymm4';    Uzunluk: yu256bYMM;   Deger: 4),
    (Ad: 'ymm5';    Uzunluk: yu256bYMM;   Deger: 5),
    (Ad: 'ymm6';    Uzunluk: yu256bYMM;   Deger: 6),
    (Ad: 'ymm7';    Uzunluk: yu256bYMM;   Deger: 7),
    (Ad: 'ymm8';    Uzunluk: yu256bYMM;   Deger: 8),
    (Ad: 'ymm9';    Uzunluk: yu256bYMM;   Deger: 9),
    (Ad: 'ymm10';   Uzunluk: yu256bYMM;   Deger: 10),
    (Ad: 'ymm11';   Uzunluk: yu256bYMM;   Deger: 11),
    (Ad: 'ymm12';   Uzunluk: yu256bYMM;   Deger: 12),
    (Ad: 'ymm13';   Uzunluk: yu256bYMM;   Deger: 13),
    (Ad: 'ymm14';   Uzunluk: yu256bYMM;   Deger: 14),
    (Ad: 'ymm15';   Uzunluk: yu256bYMM;   Deger: 15));

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
