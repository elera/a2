{-------------------------------------------------------------------------------

  Dosya: komutlar.pas

  İşlev: işlem kodları (opcode) ve ilgili çağrı işlevlerini içerir

  Güncelleme Tarihi: 24/03/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit komutlar;

interface

uses Classes, SysUtils, genel, paylasim, g01islev, g02islev, g10islev,
  g12islev, g11islev;

type
  TKomutDurum = record
    SiraNo: Integer;
    KomutTipi: TKomutTipi;
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
  GRUP10_AAS      = GRUP10_AAA + 1;
  GRUP10_CLC 		  = GRUP10_AAS + 1;
  GRUP10_CLD 		  = GRUP10_CLC + 1;
  GRUP10_CLI 		  = GRUP10_CLD + 1;
  GRUP10_CMC 		  = GRUP10_CLI + 1;
  GRUP10_CPUID    = GRUP10_CMC + 1;
  GRUP10_DAA 		  = GRUP10_CPUID + 1;
  GRUP10_DAS 		  = GRUP10_DAA + 1;
  GRUP10_EMMS     = GRUP10_DAS + 1;
  GRUP10_F2XM1    = GRUP10_EMMS + 1;
  GRUP10_FABS     = GRUP10_F2XM1 + 1;
  GRUP10_FCHS     = GRUP10_FABS + 1;
  GRUP10_FCLEX    = GRUP10_FCHS + 1;
  GRUP10_FCOS     = GRUP10_FCLEX + 1;
  GRUP10_FDECSTP  = GRUP10_FCOS + 1;
  GRUP10_FINCSTP  = GRUP10_FDECSTP + 1;
  GRUP10_FINIT    = GRUP10_FINCSTP + 1;
  GRUP10_FLD1     = GRUP10_FINIT + 1;
  GRUP10_FLDL2E   = GRUP10_FLD1 + 1;
  GRUP10_FLDL2T   = GRUP10_FLDL2E + 1;
  GRUP10_FLDLG2   = GRUP10_FLDL2T + 1;
  GRUP10_FLDLN2   = GRUP10_FLDLG2 + 1;
  GRUP10_FLDPI    = GRUP10_FLDLN2 + 1;
  GRUP10_FLDZ     = GRUP10_FLDPI + 1;
  GRUP10_FNCLEX   = GRUP10_FLDZ + 1;
  GRUP10_FNINIT   = GRUP10_FNCLEX + 1;
  GRUP10_FNOP     = GRUP10_FNINIT + 1;
  GRUP10_FPATAN	  = GRUP10_FNOP + 1;
  GRUP10_FPREM	  = GRUP10_FPATAN + 1;
  GRUP10_FPREM1	  = GRUP10_FPREM + 1;
  GRUP10_FPTAN	  = GRUP10_FPREM1 + 1;
  GRUP10_FRNDINT  = GRUP10_FPTAN + 1;
  GRUP10_FSCALE   = GRUP10_FRNDINT + 1;
  GRUP10_FSIN     = GRUP10_FSCALE + 1;
  GRUP10_FSINCOS  = GRUP10_FSIN + 1;
  GRUP10_FSQRT    = GRUP10_FSINCOS + 1;
  GRUP10_FTST 	  = GRUP10_FSQRT + 1;
  GRUP10_FYL2X	  = GRUP10_FTST + 1;
  GRUP10_FYL2XP1  = GRUP10_FYL2X + 1;
  GRUP10_FXAM     = GRUP10_FYL2XP1 + 1;
  GRUP10_FXTRACT  = GRUP10_FXAM + 1;
  GRUP10_HLT 		  = GRUP10_FXTRACT + 1;
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
  GRUP10_STC 		  = GRUP10_RDTSCP + 1;
  GRUP10_STI 		  = GRUP10_STC + 1;
  GRUP10_SYSCALL  = GRUP10_STI + 1;
  GRUP10_SYSENTER = GRUP10_SYSCALL + 1;
  GRUP10_WBINVD   = GRUP10_SYSENTER + 1;

  // 11. grup komutlar
  GRUP11_CALL     = $110001;
  GRUP11_DEC      = GRUP11_CALL + 1;
  GRUP11_DIV      = GRUP11_DEC + 1;
  GRUP11_INC      = GRUP11_DIV + 1;
  GRUP11_INT      = GRUP11_INC + 1;
  GRUP11_JNZ      = GRUP11_INT + 1;
  GRUP11_PUSH     = GRUP11_JNZ + 1;

  // 12. grup komutlar
  GRUP12_MOV      = $120001;
  GRUP12_XOR      = GRUP12_MOV + 1;

  {
  GRUP01_CBW 		  = $10003;
  GRUP01_CDQ 		  = $10004;
  GRUP01_CWD 		  = $10009;
  GRUP01_IRET		  = $1002E;
  GRUP01_IRETD		  = $1002F;}

const
  TOPLAM_KOMUT = 81;
  KomutListesi: array[0..TOPLAM_KOMUT - 1] of TKomut = (

  // grup 01 - BİLDİRİMLER - (sıralama alfabetiktir)
  (Komut: 'dosya.ad';           GrupNo: GRUP01_DOS_AD_;       KomutTipi: ktBildirim),
  (Komut: 'dosya.uzantı';       GrupNo: GRUP01_DOS_UZN;       KomutTipi: ktBildirim),
  (Komut: 'kod.adres';          GrupNo: GRUP01_KOD_ADR;       KomutTipi: ktBildirim),
  (Komut: 'kod.mimari';         GrupNo: GRUP01_KOD_MIM;       KomutTipi: ktBildirim),
  (Komut: 'kod.tabaka';         GrupNo: GRUP01_KOD_TBK;       KomutTipi: ktBildirim),

  // grup 02 - DEĞİŞKENLER - (sıralama sınıflamaya göredir)
  (Komut: 'db';                 GrupNo: GRUP02_DB;            KomutTipi: ktDegisken),
  (Komut: 'dw';                 GrupNo: GRUP02_DW;            KomutTipi: ktDegisken),
  (Komut: 'dd';                 GrupNo: GRUP02_DD;            KomutTipi: ktDegisken),
  (Komut: 'dq';                 GrupNo: GRUP02_DQ;            KomutTipi: ktDegisken),

  // grup 10 - işlem kodu - (sıralama alfabetiktir)
  // bu gruptaki komutlar: SADECE işlem koduna sahip, hiçbir öndeğer (parametre)
  // almayan komutlardır
  (Komut: 'aaa';                GrupNo: GRUP10_AAA;           KomutTipi: ktIslemKodu),
  (Komut: 'aas';                GrupNo: GRUP10_AAS;           KomutTipi: ktIslemKodu),
  (Komut: 'clc';                GrupNo: GRUP10_CLC;           KomutTipi: ktIslemKodu),
  (Komut: 'cld';                GrupNo: GRUP10_CLD;           KomutTipi: ktIslemKodu),
  (Komut: 'cli';                GrupNo: GRUP10_CLI;           KomutTipi: ktIslemKodu),
  (Komut: 'cmc';                GrupNo: GRUP10_CMC;           KomutTipi: ktIslemKodu),
  (Komut: 'cpuid';              GrupNo: GRUP10_CPUID;         KomutTipi: ktIslemKodu),
  (Komut: 'daa';                GrupNo: GRUP10_DAA;           KomutTipi: ktIslemKodu),
  (Komut: 'das';                GrupNo: GRUP10_DAS;           KomutTipi: ktIslemKodu),
  (Komut: 'emms';               GrupNo: GRUP10_EMMS;          KomutTipi: ktIslemKodu),
  (Komut: 'f2xm1';              GrupNo: GRUP10_F2XM1;         KomutTipi: ktIslemKodu),
  (Komut: 'fabs';               GrupNo: GRUP10_FABS;          KomutTipi: ktIslemKodu),
  (Komut: 'fchs';               GrupNo: GRUP10_FCHS;          KomutTipi: ktIslemKodu),
  (Komut: 'fclex';              GrupNo: GRUP10_FCLEX;         KomutTipi: ktIslemKodu),
  (Komut: 'fcos';               GrupNo: GRUP10_FCOS;          KomutTipi: ktIslemKodu),
  (Komut: 'fdecstp';            GrupNo: GRUP10_FDECSTP;       KomutTipi: ktIslemKodu),
  (Komut: 'fincstp';            GrupNo: GRUP10_FINCSTP;       KomutTipi: ktIslemKodu),
  (Komut: 'finit';              GrupNo: GRUP10_FINIT;         KomutTipi: ktIslemKodu),
  (Komut: 'fld1';               GrupNo: GRUP10_FLD1;          KomutTipi: ktIslemKodu),
  (Komut: 'fldl2e';             GrupNo: GRUP10_FLDL2E;        KomutTipi: ktIslemKodu),
  (Komut: 'fldl2t';             GrupNo: GRUP10_FLDL2T;        KomutTipi: ktIslemKodu),
  (Komut: 'fldlg2';             GrupNo: GRUP10_FLDLG2;        KomutTipi: ktIslemKodu),
  (Komut: 'fldln2';             GrupNo: GRUP10_FLDLN2;        KomutTipi: ktIslemKodu),
  (Komut: 'fldpi';              GrupNo: GRUP10_FLDPI;         KomutTipi: ktIslemKodu),
  (Komut: 'fldz';               GrupNo: GRUP10_FLDZ;          KomutTipi: ktIslemKodu),
  (Komut: 'fnclex';             GrupNo: GRUP10_FNCLEX;        KomutTipi: ktIslemKodu),
  (Komut: 'fninit';             GrupNo: GRUP10_FNINIT;        KomutTipi: ktIslemKodu),
  (Komut: 'fnop';               GrupNo: GRUP10_FNOP;          KomutTipi: ktIslemKodu),
  (Komut: 'fpatan';             GrupNo: GRUP10_FPATAN;        KomutTipi: ktIslemKodu),
  (Komut: 'fprem';              GrupNo: GRUP10_FPREM;         KomutTipi: ktIslemKodu),
  (Komut: 'fprem1';             GrupNo: GRUP10_FPREM1;        KomutTipi: ktIslemKodu),
  (Komut: 'fptan';              GrupNo: GRUP10_FPTAN;         KomutTipi: ktIslemKodu),
  (Komut: 'frndint';            GrupNo: GRUP10_FRNDINT;       KomutTipi: ktIslemKodu),
  (Komut: 'fscale';             GrupNo: GRUP10_FSCALE;        KomutTipi: ktIslemKodu),
  (Komut: 'fsin';               GrupNo: GRUP10_FSIN;          KomutTipi: ktIslemKodu),
  (Komut: 'fsincos';            GrupNo: GRUP10_FSINCOS;       KomutTipi: ktIslemKodu),
  (Komut: 'fsqrt';              GrupNo: GRUP10_FSQRT;         KomutTipi: ktIslemKodu),
  (Komut: 'ftst';               GrupNo: GRUP10_FTST;          KomutTipi: ktIslemKodu),
  (Komut: 'fyl2x';              GrupNo: GRUP10_FYL2X;         KomutTipi: ktIslemKodu),
  (Komut: 'fyl2xp1';            GrupNo: GRUP10_FYL2XP1;       KomutTipi: ktIslemKodu),
  (Komut: 'fxam';               GrupNo: GRUP10_FXAM;          KomutTipi: ktIslemKodu),
  (Komut: 'fxtract';            GrupNo: GRUP10_FXTRACT;       KomutTipi: ktIslemKodu),
  (Komut: 'hlt';                GrupNo: GRUP10_HLT;           KomutTipi: ktIslemKodu),
  (Komut: 'lahf';               GrupNo: GRUP10_LAHF;          KomutTipi: ktIslemKodu),
  (Komut: 'leave';              GrupNo: GRUP10_LEAVE;         KomutTipi: ktIslemKodu),
  (Komut: 'lock';               GrupNo: GRUP10_LOCK;          KomutTipi: ktIslemKodu),
  (Komut: 'popa';               GrupNo: GRUP10_POPA;          KomutTipi: ktIslemKodu),
  (Komut: 'popad';              GrupNo: GRUP10_POPAD;         KomutTipi: ktIslemKodu),
  (Komut: 'popf';               GrupNo: GRUP10_POPF;          KomutTipi: ktIslemKodu),
  (Komut: 'popfd';              GrupNo: GRUP10_POPFD;         KomutTipi: ktIslemKodu),
  (Komut: 'popfq';              GrupNo: GRUP10_POPFQ;         KomutTipi: ktIslemKodu),
  (Komut: 'pusha';              GrupNo: GRUP10_PUSHA;         KomutTipi: ktIslemKodu),
  (Komut: 'pushad';             GrupNo: GRUP10_PUSHAD;        KomutTipi: ktIslemKodu),
  (Komut: 'pushf';              GrupNo: GRUP10_PUSHF;         KomutTipi: ktIslemKodu),
  (Komut: 'pushfd';             GrupNo: GRUP10_PUSHFD;        KomutTipi: ktIslemKodu),
  (Komut: 'pushfq';             GrupNo: GRUP10_PUSHFQ;        KomutTipi: ktIslemKodu),
  (Komut: 'rdtsc';              GrupNo: GRUP10_RDTSC;         KomutTipi: ktIslemKodu),
  (Komut: 'rdtscp';             GrupNo: GRUP10_RDTSCP;        KomutTipi: ktIslemKodu),
  (Komut: 'stc';                GrupNo: GRUP10_STC;           KomutTipi: ktIslemKodu),
  (Komut: 'sti';                GrupNo: GRUP10_STI;           KomutTipi: ktIslemKodu),
  (Komut: 'syscall';            GrupNo: GRUP10_SYSCALL;       KomutTipi: ktIslemKodu),
  (Komut: 'sysenter';           GrupNo: GRUP10_SYSENTER;      KomutTipi: ktIslemKodu),
  (Komut: 'wbinvd';             GrupNo: GRUP10_WBINVD;        KomutTipi: ktIslemKodu),

  {
    (Komut: 'cbw';        GrupNo: GRUP01_CBW;      KomutTipi: ktIslemKodu),
    (Komut: 'cdq';        GrupNo: GRUP01_CDQ;      KomutTipi: ktIslemKodu),
    (Komut: 'cwd';        GrupNo: GRUP01_CWD;      KomutTipi: ktIslemKodu),
    (Komut: 'iret';       GrupNo: GRUP01_IRET;     KomutTipi: ktIslemKodu),
    (Komut: 'iretd';      GrupNo: GRUP01_IRETD;    KomutTipi: ktIslemKodu),}

    // 11. grup komutlar
    (Komut: 'call';             GrupNo: GRUP11_CALL;          KomutTipi: ktIslemKodu),
    (Komut: 'dec';              GrupNo: GRUP11_DEC;           KomutTipi: ktIslemKodu),
    (Komut: 'div';              GrupNo: GRUP11_DIV;           KomutTipi: ktIslemKodu),
    (Komut: 'inc';              GrupNo: GRUP11_INC;           KomutTipi: ktIslemKodu),
    (Komut: 'int';              GrupNo: GRUP11_INT;           KomutTipi: ktIslemKodu),
    (Komut: 'jnz';              GrupNo: GRUP11_JNZ;           KomutTipi: ktIslemKodu),
    (Komut: 'push';             GrupNo: GRUP11_PUSH;          KomutTipi: ktIslemKodu),

    // 12. grup komutlar
    (Komut: 'mov';              GrupNo: GRUP12_MOV;           KomutTipi: ktIslemKodu),
    (Komut: 'xor';              GrupNo: GRUP12_XOR;           KomutTipi: ktIslemKodu)

    );

var
  KomutListe: array[0..TOPLAM_KOMUT - 1] of TAsmKomut = (

    // 1. grup komutlar
    @Grup01Bildirim, @Grup01Bildirim, @Grup01Bildirim, @Grup01Bildirim,
    @Grup01Bildirim,

    // 2. grup komutlar
    @Grup02Degisken, @Grup02Degisken, @Grup02Degisken, @Grup02Degisken,

    // 10. grup komutlar
    @Grup10Islev, @Grup10Islev, @Grup10Islev, @Grup10Islev, @Grup10Islev,
    @Grup10Islev, @Grup10Islev, @Grup10Islev, @Grup10Islev, @Grup10Islev,
    @Grup10Islev, @Grup10Islev, @Grup10Islev, @Grup10Islev, @Grup10Islev,
    @Grup10Islev, @Grup10Islev, @Grup10Islev, @Grup10Islev, @Grup10Islev,
    @Grup10Islev, @Grup10Islev, @Grup10Islev, @Grup10Islev, @Grup10Islev,
    @Grup10Islev, @Grup10Islev, @Grup10Islev, @Grup10Islev, @Grup10Islev,
    @Grup10Islev, @Grup10Islev, @Grup10Islev, @Grup10Islev, @Grup10Islev,
    @Grup10Islev, @Grup10Islev, @Grup10Islev, @Grup10Islev, @Grup10Islev,
    @Grup10Islev, @Grup10Islev, @Grup10Islev, @Grup10Islev, @Grup10Islev,
    @Grup10Islev, @Grup10Islev, @Grup10Islev, @Grup10Islev, @Grup10Islev,
    @Grup10Islev, @Grup10Islev, @Grup10Islev, @Grup10Islev, @Grup10Islev,
    @Grup10Islev, @Grup10Islev, @Grup10Islev, @Grup10Islev, @Grup10Islev,
    @Grup10Islev, @Grup10Islev, @Grup10Islev,
    {
    @Grup01Islev,           // cbw
    @Grup01Islev,           // cdq
    @Grup01Islev,           // cwd
    @Grup01Islev,           // iret
    @Grup01Islev,           // iretd}

    // 11. grup komutlar
    @Grup11Islev, @Grup11Islev, @Grup11Islev, @Grup11Islev, @Grup11Islev,
    @Grup11Islev, @Grup11Islev,

    // 12. grup komutlar
    @Grup12Islev, @Grup12Islev
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

      Result.KomutTipi := KomutListesi[i].KomutTipi;
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
