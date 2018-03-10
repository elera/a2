{-------------------------------------------------------------------------------

  Dosya: komutlar.pas

  İşlev: işlem kodları (opcode) ve ilgili çağrı işlevlerini içerir

  Güncelleme Tarihi: 07/03/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit komutlar;

interface

uses Classes, SysUtils, genel, paylasim, g01islev, g02islev, g10islev,
  g11islev, g12islev;

type
  TKomutDurum = record
    SiraNo: Integer;
    ABVT: TAnaBolumVeriTipi;
  end;

type
  // tüm assembler komutlarının çağrı yapısı
  // 1. SatirNo = komut dizisinin bulunduğu satır
  // 2. ParcaNo = komut dizisinin her bir ana kesim / parça numarasıdır
  //    not: ParcaNo = 1, Veri2 değeri olarak komutun sıra numarasını döndürür
  // 3. VeriKontrolTip = işleve gönderilen veri tipini belirtir
  // 4. Veri1 = eğer varsa, karakter dizisi türünde veri
  // 5. Veri2 = eğer varsa, sayısal türde veri
  TAsmKomut = function(SatirNo: Integer; ParcaNo: Integer; VeriKontrolTip:
    TVeriKontrolTip; Veri1: string; Veri2: QWord): Integer;

type
  TKomut = record
    Komut: string[15];
    GrupNo: Integer;
    ABVT: TAnaBolumVeriTipi;
  end;

  { assembler komut listesi }
  const
    // 1. grup komutlar
    GRUP01_DOS_AD_  = $010001;
    GRUP01_DOS_UZN  = GRUP01_DOS_AD_ + 1;
    GRUP01_KOD_ADR  = GRUP01_DOS_UZN + 1;
    GRUP01_KOD_MIM  = GRUP01_KOD_ADR + 1;
    GRUP01_KOD_TBK  = GRUP01_KOD_MIM + 1;

    // 2. grup komutlar
    GRUP02_DB       = $020001;
    GRUP02_DW       = GRUP02_DB + 1;
    GRUP02_DD       = GRUP02_DW + 1;
    GRUP02_DQ       = GRUP02_DD + 1;

    // 10. grup komutlar
    GRUP10_AAA 		  = $100001;
    GRUP10_CLC 		  = GRUP10_AAA + 1;
    GRUP10_CLD 		  = GRUP10_CLC + 1;
    GRUP10_CLI 		  = GRUP10_CLD + 1;
    GRUP10_CMC 		  = GRUP10_CLI + 1;
    GRUP10_DAA 		  = GRUP10_CMC + 1;
    GRUP10_DAS 		  = GRUP10_DAA + 1;
    GRUP10_FCOS     = GRUP10_DAS + 1;
    GRUP10_FSIN     = GRUP10_FCOS + 1;
    GRUP10_FSINCOS  = GRUP10_FSIN + 1;
    GRUP10_HLT 		  = GRUP10_FSINCOS + 1;
    GRUP10_LAHF     = GRUP10_HLT + 1;
    GRUP10_LEAVE    = GRUP10_LAHF + 1;
    GRUP10_LOCK     = GRUP10_LEAVE + 1;
    GRUP10_POPA	    = GRUP10_LOCK + 1;
    GRUP10_POPAD    = GRUP10_POPA + 1;
    GRUP10_POPF	    = GRUP10_POPAD + 1;
    GRUP10_POPFD	  = GRUP10_POPF + 1;
    GRUP10_POPFQ	  = GRUP10_POPFD + 1;
    GRUP10_PUSHA	  = GRUP10_POPFQ + 1;
    GRUP10_PUSHAD   = GRUP10_PUSHA + 1;
    GRUP10_PUSHF	  = GRUP10_PUSHAD + 1;
    GRUP10_PUSHFD	  = GRUP10_PUSHF + 1;
    GRUP10_PUSHFQ	  = GRUP10_PUSHFD + 1;
    GRUP10_RDTSC	  = GRUP10_PUSHFQ + 1;
    GRUP10_RDTSCP   = GRUP10_RDTSC + 1;
    GRUP10_STI 		  = GRUP10_RDTSCP + 1;
    GRUP10_STC 		  = GRUP10_STI + 1;
    GRUP10_WBINVD   = GRUP10_STC + 1;

    // 11. grup komutlar
    GRUP11_INT      = $110001;

    // 12. grup komutlar
    GRUP12_MOV      = $120001;

    {GRUP01_AAS 		  = $10002;
    GRUP01_CBW 		  = $10003;
    GRUP01_CDQ 		  = $10004;
    GRUP01_CPUID 	  = $10008;
    GRUP01_CWD 		  = $10009;
    GRUP01_EMMS 		  = $1000C;
    GRUP01_FABS 		  = $1000D;
    GRUP01_FCHS 		  = $1000E;
    GRUP01_FCLEX 	  = $1000F;
    GRUP01_FDECSTP	  = $10011;
    GRUP01_FINCSTP	  = $10012;
    GRUP01_FINIT		  = $10013;
    GRUP01_FLDLG2	  = $10014;
    GRUP01_FLDLN2	  = $10015;
    GRUP01_FLDPI		  = $10016;
    GRUP01_FLDZ		  = $10017;
    GRUP01_FLDL2E	  = $10018;
    GRUP01_FLDL2T	  = $10019;
    GRUP01_FLD1		  = $1001A;
    GRUP01_FNCLEX	  = $1001B;
    GRUP01_FNINIT	  = $1001C;
    GRUP01_FNOP		  = $1001D;
    GRUP01_FPATAN	  = $1001E;
    GRUP01_FPREM		  = $1001F;
    GRUP01_FPREM1	  = $10020;
    GRUP01_FPTAN		  = $10021;
    GRUP01_FRNDINT	  = $10022;
    GRUP01_FSCALE	  = $10023;
    GRUP01_FSQRT		  = $10026;
    GRUP01_FTST		  = $10027;
    GRUP01_FYL2X		  = $10028;
    GRUP01_FYL2XP1	  = $10029;
    GRUP01_FXAM		  = $1002A;
    GRUP01_FXTRACT	  = $1002B;
    GRUP01_F2XM1		  = $1002C;
    GRUP01_IRET		  = $1002E;
    GRUP01_IRETD		  = $1002F;}

const
  TOPLAM_KOMUT = 40;
  KomutListesi: array[0..TOPLAM_KOMUT - 1] of TKomut = (

  // grup 01 - BİLDİRİMLER - (sıralama alfabetiktir)
  (Komut: 'dosya.ad';           GrupNo: GRUP01_DOS_AD_;       ABVT: abvtBildirim),
  (Komut: 'dosya.uzantı';       GrupNo: GRUP01_DOS_UZN;       ABVT: abvtBildirim),
  (Komut: 'kod.adres';          GrupNo: GRUP01_KOD_ADR;       ABVT: abvtBildirim),
  (Komut: 'kod.mimari';         GrupNo: GRUP01_KOD_MIM;       ABVT: abvtBildirim),
  (Komut: 'kod.tabaka';         GrupNo: GRUP01_KOD_TBK;       ABVT: abvtBildirim),

  // grup 02 - DEĞİŞKENLER - (sıralama sınıflamaya göredir)
  (Komut: 'db';                 GrupNo: GRUP02_DB;            ABVT: abvtDegisken),
  (Komut: 'dw';                 GrupNo: GRUP02_DW;            ABVT: abvtDegisken),
  (Komut: 'dd';                 GrupNo: GRUP02_DD;            ABVT: abvtDegisken),
  (Komut: 'dq';                 GrupNo: GRUP02_DQ;            ABVT: abvtDegisken),

  // grup 10 - işlem kodu - (sıralama alfabetiktir)
  // bu gruptaki komutlar: SADECE işlem koduna sahip, hiçbir öndeğer (parametre)
  // almayan komutlardır
  (Komut: 'aaa';                GrupNo: GRUP10_AAA;           ABVT: abvtIslemKodu),
  (Komut: 'clc';                GrupNo: GRUP10_CLC;           ABVT: abvtIslemKodu),
  (Komut: 'cld';                GrupNo: GRUP10_CLD;           ABVT: abvtIslemKodu),
  (Komut: 'cli';                GrupNo: GRUP10_CLI;           ABVT: abvtIslemKodu),
  (Komut: 'cmc';                GrupNo: GRUP10_CMC;           ABVT: abvtIslemKodu),
  (Komut: 'daa';                GrupNo: GRUP10_DAA;           ABVT: abvtIslemKodu),
  (Komut: 'das';                GrupNo: GRUP10_DAS;           ABVT: abvtIslemKodu),
  (Komut: 'hlt';                GrupNo: GRUP10_HLT;           ABVT: abvtIslemKodu),
  (Komut: 'fcos';               GrupNo: GRUP10_FCOS;          ABVT: abvtIslemKodu),
  (Komut: 'fsin';               GrupNo: GRUP10_FSIN;          ABVT: abvtIslemKodu),
  (Komut: 'fsincos';            GrupNo: GRUP10_FSINCOS;       ABVT: abvtIslemKodu),
  (Komut: 'lahf';               GrupNo: GRUP10_LAHF;          ABVT: abvtIslemKodu),
  (Komut: 'leave';              GrupNo: GRUP10_LEAVE;         ABVT: abvtIslemKodu),
  (Komut: 'lock';               GrupNo: GRUP10_LOCK;          ABVT: abvtIslemKodu),
  (Komut: 'popa';               GrupNo: GRUP10_POPA;          ABVT: abvtIslemKodu),
  (Komut: 'popad';              GrupNo: GRUP10_POPAD;         ABVT: abvtIslemKodu),
  (Komut: 'popf';               GrupNo: GRUP10_POPF;          ABVT: abvtIslemKodu),
  (Komut: 'popfd';              GrupNo: GRUP10_POPFD;         ABVT: abvtIslemKodu),
  (Komut: 'popfq';              GrupNo: GRUP10_POPFQ;         ABVT: abvtIslemKodu),
  (Komut: 'pusha';              GrupNo: GRUP10_PUSHA;         ABVT: abvtIslemKodu),
  (Komut: 'pushad';             GrupNo: GRUP10_PUSHAD;        ABVT: abvtIslemKodu),
  (Komut: 'pushf';              GrupNo: GRUP10_PUSHF;         ABVT: abvtIslemKodu),
  (Komut: 'pushfd';             GrupNo: GRUP10_PUSHFD;        ABVT: abvtIslemKodu),
  (Komut: 'pushfq';             GrupNo: GRUP10_PUSHFQ;        ABVT: abvtIslemKodu),
  (Komut: 'rdtsc';              GrupNo: GRUP10_RDTSC;         ABVT: abvtIslemKodu),
  (Komut: 'rdtscp';             GrupNo: GRUP10_RDTSCP;        ABVT: abvtIslemKodu),
  (Komut: 'stc';                GrupNo: GRUP10_STC;           ABVT: abvtIslemKodu),
  (Komut: 'sti';                GrupNo: GRUP10_STI;           ABVT: abvtIslemKodu),
  (Komut: 'wbinvd';             GrupNo: GRUP10_WBINVD;        ABVT: abvtIslemKodu),

  {    (Komut: 'aas';        GrupNo: GRUP01_AAS;      ABVT: abvtIslemKodu),
    (Komut: 'cbw';        GrupNo: GRUP01_CBW;      ABVT: abvtIslemKodu),
    (Komut: 'cdq';        GrupNo: GRUP01_CDQ;      ABVT: abvtIslemKodu),
    (Komut: 'cpuid';      GrupNo: GRUP01_CPUID;    ABVT: abvtIslemKodu),
    (Komut: 'cwd';        GrupNo: GRUP01_CWD;      ABVT: abvtIslemKodu),
    (Komut: 'emms';       GrupNo: GRUP01_EMMS;     ABVT: abvtIslemKodu),
    (Komut: 'fabs';       GrupNo: GRUP01_FABS;     ABVT: abvtIslemKodu),
    (Komut: 'fchs';       GrupNo: GRUP01_FCHS;     ABVT: abvtIslemKodu),
    (Komut: 'fclex';      GrupNo: GRUP01_FCLEX;    ABVT: abvtIslemKodu),
    (Komut: 'fdecstp';    GrupNo: GRUP01_FDECSTP;  ABVT: abvtIslemKodu),
    (Komut: 'fincstp';    GrupNo: GRUP01_FINCSTP;  ABVT: abvtIslemKodu),
    (Komut: 'finit';      GrupNo: GRUP01_FINIT;    ABVT: abvtIslemKodu),
    (Komut: 'fldlg2';     GrupNo: GRUP01_FLDLG2;   ABVT: abvtIslemKodu),
    (Komut: 'fldln2';     GrupNo: GRUP01_FLDLN2;   ABVT: abvtIslemKodu),
    (Komut: 'fldpi';      GrupNo: GRUP01_FLDPI;    ABVT: abvtIslemKodu),
    (Komut: 'fldz';       GrupNo: GRUP01_FLDZ;     ABVT: abvtIslemKodu),
    (Komut: 'fldl2e';     GrupNo: GRUP01_FLDL2E;   ABVT: abvtIslemKodu),
    (Komut: 'fldl2t';     GrupNo: GRUP01_FLDL2T;   ABVT: abvtIslemKodu),
    (Komut: 'fld1';       GrupNo: GRUP01_FLD1;     ABVT: abvtIslemKodu),
    (Komut: 'fnclex';     GrupNo: GRUP01_FNCLEX;   ABVT: abvtIslemKodu),
    (Komut: 'fninit';     GrupNo: GRUP01_FNINIT;   ABVT: abvtIslemKodu),
    (Komut: 'fnop';       GrupNo: GRUP01_FNOP;     ABVT: abvtIslemKodu),
    (Komut: 'fpatan';     GrupNo: GRUP01_FPATAN;   ABVT: abvtIslemKodu),
    (Komut: 'fprem';      GrupNo: GRUP01_FPREM;    ABVT: abvtIslemKodu),
    (Komut: 'fprem1';     GrupNo: GRUP01_FPREM1;   ABVT: abvtIslemKodu),
    (Komut: 'fptan';      GrupNo: GRUP01_FPTAN;    ABVT: abvtIslemKodu),
    (Komut: 'frndint';    GrupNo: GRUP01_FRNDINT;  ABVT: abvtIslemKodu),
    (Komut: 'fscale';     GrupNo: GRUP01_FSCALE;   ABVT: abvtIslemKodu),
    (Komut: 'fsqrt';      GrupNo: GRUP01_FSQRT;    ABVT: abvtIslemKodu),
    (Komut: 'ftst';       GrupNo: GRUP01_FTST;     ABVT: abvtIslemKodu),
    (Komut: 'fyl2x';      GrupNo: GRUP01_FYL2X;    ABVT: abvtIslemKodu),
    (Komut: 'fyl2xp1';    GrupNo: GRUP01_FYL2XP1;  ABVT: abvtIslemKodu),
    (Komut: 'fxam';       GrupNo: GRUP01_FXAM;     ABVT: abvtIslemKodu),
    (Komut: 'fxtract';    GrupNo: GRUP01_FXTRACT;  ABVT: abvtIslemKodu),
    (Komut: 'f2xm1';      GrupNo: GRUP01_F2XM1;    ABVT: abvtIslemKodu),
    (Komut: 'iret';       GrupNo: GRUP01_IRET;     ABVT: abvtIslemKodu),
    (Komut: 'iretd';      GrupNo: GRUP01_IRETD;    ABVT: abvtIslemKodu),}

    // 2. grup komutlar
    (Komut: 'int';          GrupNo: GRUP11_INT;   ABVT: abvtIslemKodu),

    // 3. grup komutlar
    (Komut: 'mov';          GrupNo: GRUP12_MOV;   ABVT: abvtIslemKodu)
    );

var
  KomutListe: array[0..TOPLAM_KOMUT - 1] of TAsmKomut = (
    @Grup01Bildirim,
    @Grup01Bildirim,
    @Grup01Bildirim,
    @Grup01Bildirim,
    @Grup01Bildirim,

    @Grup02Degisken,
    @Grup02Degisken,
    @Grup02Degisken,
    @Grup02Degisken,

    @Grup10Islev,
    @Grup10Islev,
    @Grup10Islev,
    @Grup10Islev,
    @Grup10Islev,
    @Grup10Islev,
    @Grup10Islev,
    @Grup10Islev,
    @Grup10Islev,
    @Grup10Islev,
    @Grup10Islev,
    @Grup10Islev,
    @Grup10Islev,
    @Grup10Islev,
    @Grup10Islev,
    @Grup10Islev,
    @Grup10Islev,
    @Grup10Islev,
    @Grup10Islev,
    @Grup10Islev,
    @Grup10Islev,
    @Grup10Islev,
    @Grup10Islev,
    @Grup10Islev,
    @Grup10Islev,
    @Grup10Islev,
    @Grup10Islev,
    @Grup10Islev,
    @Grup10Islev,
    {    @Grup01Islev,           // aas
    @Grup01Islev,           // cbw
    @Grup01Islev,           // cdq
    @Grup01Islev,           // cpuid
    @Grup01Islev,           // cwd
    @Grup01Islev,           // emms
    @Grup01Islev,           // fabs
    @Grup01Islev,           // fchs
    @Grup01Islev,           // fclex
    @Grup01Islev,           // fdecstp
    @Grup01Islev,           // fincstp
    @Grup01Islev,           // finit
    @Grup01Islev,           // fldlg2
    @Grup01Islev,           // fldln2
    @Grup01Islev,           // fldpi
    @Grup01Islev,           // fldz
    @Grup01Islev,           // fldl2e
    @Grup01Islev,           // fldl2t
    @Grup01Islev,           // fld1
    @Grup01Islev,           // fnclex
    @Grup01Islev,           // fninit
    @Grup01Islev,           // fnop
    @Grup01Islev,           // fpatan
    @Grup01Islev,           // fprem
    @Grup01Islev,           // fprem1
    @Grup01Islev,           // fptan
    @Grup01Islev,           // frndint
    @Grup01Islev,           // fscale
    @Grup01Islev,           // fsqrt
    @Grup01Islev,           // ftst
    @Grup01Islev,           // fyl2x
    @Grup01Islev,           // fyl2xp1
    @Grup01Islev,           // fxam
    @Grup01Islev,           // fxtract
    @Grup01Islev,           // f2xm1
    @Grup01Islev,           // iret
    @Grup01Islev,           // iretd}

    // 2. grup komutlar
    @Grup11Islev,

    // 3. grup komutlar
    @Grup12Islev
  );

function KomutBilgisiAl(AKomut: string): TKomutDurum;
function KomutHata(SatirNo: Integer; ParcaNo: Integer;
  VeriKontrolTip: TVeriKontrolTip; Veri1: string; Veri2: QWord): Integer;

implementation

uses donusum;

// komut ayrıntı bilgisini geri döndürür
function KomutBilgisiAl(AKomut: string): TKomutDurum;
var
  i, KomutU: Integer;
  Komut: string;
begin

  Komut := KucukHarfeCevir(AKomut);
  KomutU := Length(Komut);

  Result.SiraNo := -1;

  if(KomutU = 0) then Exit;

  for i := 0 to TOPLAM_KOMUT - 1 do
  begin

    if(Length(KomutListesi[i].Komut) = KomutU) and (KomutListesi[i].Komut = Komut) then
    begin

      Result.ABVT := KomutListesi[i].ABVT;
      Result.SiraNo := i;
      Break;
    end;
  end;
end;

// hata olması durumunda çağrılacak işlev
function KomutHata(SatirNo: Integer; ParcaNo: Integer;
  VeriKontrolTip: TVeriKontrolTip; Veri1: string; Veri2: QWord): Integer;
begin

  GHataAciklama := Veri1;
  Result := HATA_BILINMEYEN_KOMUT;
end;

end.
