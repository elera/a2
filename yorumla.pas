{-------------------------------------------------------------------------------

  Dosya: yorumla.pas
  İşlev: verileri yorumlayan ve kodlara çeviren işlevleri içerir
  Tarih: 13/01/2018
  Bilgi:

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit yorumla;

interface

uses Classes, SysUtils;

type
  TKomutDurum = record
    Sonuc: Integer;
  end;

type
  TYazmacUzunluk = (yu8Bit, yu16Bit, yu32Bit, yu64Bit);

type
  TYazmacDurum = record
    Sonuc: Integer;
    Uzunluk: TYazmacUzunluk;
  end;

type
  TKomut = record
    Komut: string[15];
  end;

{ assembler komut listesi }
const
  TOPLAM_KOMUT = 65;
  Komutlar: array[0..TOPLAM_KOMUT - 1] of TKomut = (
    (Komut: 'aaa';      ),
    (Komut: 'aas';      ),
    (Komut: 'cbw';      ),
    (Komut: 'cdq';      ),
    (Komut: 'cld';      ),
    (Komut: 'cli';      ),
    (Komut: 'cmc';      ),
    (Komut: 'cpuid';    ),
    (Komut: 'cwd';      ),
    (Komut: 'daa';      ),
    (Komut: 'das';      ),
    (Komut: 'emms';     ),
    (Komut: 'fabs';     ),
    (Komut: 'fchs';     ),
    (Komut: 'fclex';    ),
    (Komut: 'fcos';     ),
    (Komut: 'fdecstp';  ),
    (Komut: 'fincstp';  ),
    (Komut: 'finit';    ),
    (Komut: 'fldlg2';   ),
    (Komut: 'fldln2';   ),
    (Komut: 'fldpi';    ),
    (Komut: 'fldz';     ),
    (Komut: 'fldl2e';   ),
    (Komut: 'fldl2t';   ),
    (Komut: 'fld1';     ),
    (Komut: 'fnclex';   ),
    (Komut: 'fninit';   ),
    (Komut: 'fnop';     ),
    (Komut: 'fpatan';   ),
    (Komut: 'fprem';    ),
    (Komut: 'fprem1';   ),
    (Komut: 'fptan';    ),
    (Komut: 'frndint';  ),
    (Komut: 'fscale';   ),
    (Komut: 'fsin';     ),
    (Komut: 'fsincos';  ),
    (Komut: 'fsqrt';    ),
    (Komut: 'ftst';     ),
    (Komut: 'fyl2x';    ),
    (Komut: 'fyl2xp1';  ),
    (Komut: 'fxam';     ),
    (Komut: 'fxtract';  ),
    (Komut: 'f2xm1';    ),
    (Komut: 'hlt';      ),
    (Komut: 'iret';     ),
    (Komut: 'iretd';    ),
    (Komut: 'lahf';     ),
    (Komut: 'leave';    ),
    (Komut: 'lock';     ),
    (Komut: 'mov';      ),
    (Komut: 'nop';      ),
    (Komut: 'popa';     ),
    (Komut: 'popad';    ),
    (Komut: 'popf';     ),
    (Komut: 'popfd';    ),
    (Komut: 'pusha';    ),
    (Komut: 'pushad';   ),
    (Komut: 'pushf';    ),
    (Komut: 'pushfd';   ),
    (Komut: 'rdtsc';    ),
    (Komut: 'rdtscp';   ),
    (Komut: 'stc';      ),
    (Komut: 'sti';      ),
    (Komut: 'wbinvd';   ));

type
  TYazmac = record
    Ad: string[3];
    Uzunluk: TYazmacUzunluk;
    Deger: Byte;
  end;

{ yazmaç listesi }
const
  TOPLAM_YAZMAC = 24;
  Yazmaclar: array[0..TOPLAM_YAZMAC - 1] of TYazmac = (
    (Ad: 'al';  Uzunluk: yu8Bit;  Deger: $00),
    (Ad: 'cl';  Uzunluk: yu8Bit;  Deger: $01),
    (Ad: 'dl';  Uzunluk: yu8Bit;  Deger: $02),
    (Ad: 'bl';  Uzunluk: yu8Bit;  Deger: $03),
    (Ad: 'ah';  Uzunluk: yu8Bit;  Deger: $04),
    (Ad: 'ch';  Uzunluk: yu8Bit;  Deger: $05),
    (Ad: 'dh';  Uzunluk: yu8Bit;  Deger: $06),
    (Ad: 'bh';  Uzunluk: yu8Bit;  Deger: $07),
    (Ad: 'ax';  Uzunluk: yu16Bit; Deger: $10),
    (Ad: 'cx';  Uzunluk: yu16Bit; Deger: $11),
    (Ad: 'dx';  Uzunluk: yu16Bit; Deger: $12),
    (Ad: 'bx';  Uzunluk: yu16Bit; Deger: $13),
    (Ad: 'sp';  Uzunluk: yu16Bit; Deger: $14),
    (Ad: 'bp';  Uzunluk: yu16Bit; Deger: $15),
    (Ad: 'si';  Uzunluk: yu16Bit; Deger: $16),
    (Ad: 'di';  Uzunluk: yu16Bit; Deger: $17),
    (Ad: 'eax'; Uzunluk: yu32Bit; Deger: $20),
    (Ad: 'ecx'; Uzunluk: yu32Bit; Deger: $21),
    (Ad: 'edx'; Uzunluk: yu32Bit; Deger: $22),
    (Ad: 'ebx'; Uzunluk: yu32Bit; Deger: $23),
    (Ad: 'esp'; Uzunluk: yu32Bit; Deger: $24),
    (Ad: 'ebp'; Uzunluk: yu32Bit; Deger: $25),
    (Ad: 'esi'; Uzunluk: yu32Bit; Deger: $26),
    (Ad: 'edi'; Uzunluk: yu32Bit; Deger: $27));

type
  // tüm assembler komutlarının çağrı yapısı
  // 1. ParcaNo = komut dizisinin her bir ana kesim / parça numarasıdır
  //    1.1 ParcaNo = 1, Veri2 değeri olarak komutun kendisini döndürür
  //    1.2 ParcaNo = -1 = komut dizisini sonuna gelindiğini belirtir
  // 2. KontrolKarakteri = eğer varsa, dizi içerisindeki ",[()]" gibi kontrol karakteri
  // 3. Veri1 = eğer varsa, karakter dizisi türünde veri
  // 4. Veri2 = eğer varsa, sayısal türde veri
  TAsmKomut = function(ParcaNo: Integer; KontrolKarakteri: Char;
    Veri1: string; Veri2: Integer): Integer;

function KomutBilgisiAl(AKomut: string): TKomutDurum;
function YazmacBilgisiAl(AYazmac: string): TYazmacDurum;
function KomutHata(ParcaNo: Integer; KontrolKarakteri: Char; Veri1: string; Veri2: Integer): Integer;
function GenelKomutSeti1(ParcaNo: Integer; KontrolKarakteri: Char; Veri1: string; Veri2: Integer): Integer;
function KomutMOV(ParcaNo: Integer; KontrolKarakteri: Char; Veri1: string; Veri2: Integer): Integer;

var
  KomutListe: array[0..TOPLAM_KOMUT - 1] of TAsmKomut = (
    @GenelKomutSeti1,           // aaa
    @GenelKomutSeti1,           // aas
    @GenelKomutSeti1,           // cbw
    @GenelKomutSeti1,           // cdq
    @GenelKomutSeti1,           // cld
    @GenelKomutSeti1,           // cli
    @GenelKomutSeti1,           // cmc
    @GenelKomutSeti1,           // cpuid
    @GenelKomutSeti1,           // cwd
    @GenelKomutSeti1,           // daa
    @GenelKomutSeti1,           // das
    @GenelKomutSeti1,           // emms
    @GenelKomutSeti1,           // fabs
    @GenelKomutSeti1,           // fchs
    @GenelKomutSeti1,           // fclex
    @GenelKomutSeti1,           // fcos
    @GenelKomutSeti1,           // fdecstp
    @GenelKomutSeti1,           // fincstp
    @GenelKomutSeti1,           // finit
    @GenelKomutSeti1,           // fldlg2
    @GenelKomutSeti1,           // fldln2
    @GenelKomutSeti1,           // fldpi
    @GenelKomutSeti1,           // fldz
    @GenelKomutSeti1,           // fldl2e
    @GenelKomutSeti1,           // fldl2t
    @GenelKomutSeti1,           // fld1
    @GenelKomutSeti1,           // fnclex
    @GenelKomutSeti1,           // fninit
    @GenelKomutSeti1,           // fnop
    @GenelKomutSeti1,           // fpatan
    @GenelKomutSeti1,           // fprem
    @GenelKomutSeti1,           // fprem1
    @GenelKomutSeti1,           // fptan
    @GenelKomutSeti1,           // frndint
    @GenelKomutSeti1,           // fscale
    @GenelKomutSeti1,           // fsin
    @GenelKomutSeti1,           // fsincos
    @GenelKomutSeti1,           // fsqrt
    @GenelKomutSeti1,           // ftst
    @GenelKomutSeti1,           // fyl2x
    @GenelKomutSeti1,           // fyl2xp1
    @GenelKomutSeti1,           // fxam
    @GenelKomutSeti1,           // fxtract
    @GenelKomutSeti1,           // f2xm1
    @GenelKomutSeti1,           // hlt
    @GenelKomutSeti1,           // iret
    @GenelKomutSeti1,           // iretd
    @GenelKomutSeti1,           // lahf
    @GenelKomutSeti1,           // leave
    @GenelKomutSeti1,           // lock
    @KomutMOV,                  // mov
    @GenelKomutSeti1,           // nop
    @GenelKomutSeti1,           // popa
    @GenelKomutSeti1,           // popad
    @GenelKomutSeti1,           // popf
    @GenelKomutSeti1,           // popfd
    @GenelKomutSeti1,           // pusha
    @GenelKomutSeti1,           // pushad
    @GenelKomutSeti1,           // pushf
    @GenelKomutSeti1,           // pushfd
    @GenelKomutSeti1,           // rdtsc
    @GenelKomutSeti1,           // rdtscp
    @GenelKomutSeti1,           // stc
    @GenelKomutSeti1,           // sti
    @GenelKomutSeti1            // wbinvd
  );

implementation

uses anasayfa, genel, tasnif;

// komut sıra değerini geri döndürür
// bilgi: ileri aşamalarda daha fazla bilgi döndürmek amacıyla KomutBilgisiAl
// adıyla isimlendirilmiştir
function KomutBilgisiAl(AKomut: string): TKomutDurum;
var
  i: Integer;
  Komut: string;
begin

  Komut := LowerCase(AKomut);

  Result.Sonuc := -1;
  for i := 0 to TOPLAM_KOMUT - 1 do
  begin

    if(Komutlar[i].Komut = Komut) then
    begin

      Result.Sonuc := i;
      Break;
    end;
  end;
end;

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

    if(Yazmaclar[i].Ad = Yazmac) then
    begin

      Result.Sonuc := i;
      Result.Uzunluk := Yazmaclar[i].Uzunluk;
      Break;
    end;
  end;
end;

// hata olması durumunda çağrılacak işlev
function KomutHata(ParcaNo: Integer; KontrolKarakteri: Char; Veri1: string;
  Veri2: Integer): Integer;
begin

  HataAciklama := Veri1;
  Result := HATA_BILINMEYEN_KOMUT;
end;

// tüm parametresiz komutların ortak çağrı işlevi
function GenelKomutSeti1(ParcaNo: Integer; KontrolKarakteri: Char;
  Veri1: string; Veri2: Integer): Integer;
begin

  if(ParcaNo = 1) then
  begin

    KomutTipi := ktIslemKodu;
    IslemKodu := Veri2;
    ParametreTip1 := ptYok;
    ParametreTip2 := ptYok;
    Result := 0;
  end
  else if(ParcaNo > 1) then
  begin

    HataAciklama := Veri1;
    Result := HATA_BEKLENMEYEN_IFADE;
  end
end;

// işlev üzerinde çalışmalar devam etmektedir...
function KomutMOV(ParcaNo: Integer; KontrolKarakteri: Char;
  Veri1: string; Veri2: Integer): Integer;
var
  Yazmac: TYazmacDurum;
begin

  //frmMain.mmAsmLinesOutput.Lines.Add('Veri No: ' + IntToStr(ParcaNo));
  //frmMain.mmAsmLinesOutput.Lines.Add('Veri: ' + Veri1);

  if(KontrolKarakteri = #255) then
  begin

    Yazmac := YazmacBilgisiAl(Veri1);
    if(Yazmac.Sonuc = -1) then
    begin

      frmAnaSayfa.mmDurumBilgisi.Lines.Add('Bilinmeyen Yazmac!');
      Result := 1;
    end
    else
    begin

      frmAnaSayfa.mmDurumBilgisi.Lines.Add('Yazmac: ' + IntToStr(Yazmac.Sonuc));
      Result := 0;
    end;
  end
  else if(ParcaNo = 1) then
  begin

    KomutTipi := ktIslemKodu;
    IslemKodu := Veri2;
    //frmMain.mmAsmLinesOutput.Lines.Add('Parça No: ' + IntToStr(ParcaNo));
    //frmMain.mmAsmLinesOutput.Lines.Add('Komut: MOV');
    Result := 0;
  end
  else if(ParcaNo = 2) {or (ParcaNo = 3)} then
  begin

    if(KontrolKarakteri = ',') then
    begin

      Yazmac := YazmacBilgisiAl(Veri1);
      if(Yazmac.Sonuc = -1) then
      begin

        frmAnaSayfa.mmDurumBilgisi.Lines.Add('Bilinmeyen Yazmac!');
        Result := 1;
      end
      else
      begin

        ParametreTip1 := ptYazmac;
        Yazmac1 := Yazmac.Sonuc;
        //frmMain.mmAsmLinesOutput.Lines.Add('Yazmac: ' + IntToStr(Yazmac.Sonuc));
        Result := 0;
      end;
    end else Result := 1;
  end
  else if(ParcaNo = 3) then
  begin

    Yazmac := YazmacBilgisiAl(Veri1);
    if(Yazmac.Sonuc = -1) then
    begin

      frmAnaSayfa.mmDurumBilgisi.Lines.Add('Bilinmeyen Yazmac!');
      Result := 1;
    end
    else
    begin

      ParametreTip2 := ptYazmac;
      Yazmac2 := Yazmac.Sonuc;
      //frmMain.mmAsmLinesOutput.Lines.Add('Yazmac: ' + IntToStr(Yazmac.Sonuc));
      Result := 0;
    end;
  end else Result := 1;
end;

end.
