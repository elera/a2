{-------------------------------------------------------------------------------

  Dosya: komutlar.pas

  İşlev: işlem kodları (opcode) ve ilgili çağrı işlevlerini içerir

  Güncelleme Tarihi: 09/06/2018

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
  GRUP02_DBW      = GRUP02_DB + 1;
  GRUP02_DW       = GRUP02_DBW + 1;
  GRUP02_DD       = GRUP02_DW + 1;
  GRUP02_DQ       = GRUP02_DD + 1;
  GRUP02_DT       = GRUP02_DQ + 1;

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
  GRUP10_FADDP    = GRUP10_FABS + 1;
  GRUP10_FCHS     = GRUP10_FADDP + 1;
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
  GRUP10_INTO     = GRUP10_HLT + 1;
  GRUP10_LAHF     = GRUP10_INTO + 1;
  GRUP10_LEAVE    = GRUP10_LAHF + 1;
  GRUP10_LOCK     = GRUP10_LEAVE + 1;
  GRUP10_LODSB    = GRUP10_LOCK + 1;
  GRUP10_LODSD    = GRUP10_LODSB + 1;
  GRUP10_LODSW    = GRUP10_LODSD + 1;
  GRUP10_LODSQ    = GRUP10_LODSW + 1;
  GRUP10_MOVSB    = GRUP10_LODSQ + 1;
  GRUP10_MOVSD    = GRUP10_MOVSB + 1;
  GRUP10_MOVSW    = GRUP10_MOVSD + 1;
  GRUP10_MOVSQ    = GRUP10_MOVSW + 1;
  GRUP10_POPA	    = GRUP10_MOVSQ + 1;
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
  GRUP10_STOSB    = GRUP10_STI + 1;
  GRUP10_STOSD    = GRUP10_STOSB + 1;
  GRUP10_STOSW    = GRUP10_STOSD + 1;
  GRUP10_STOSQ    = GRUP10_STOSW + 1;
  GRUP10_SYSCALL  = GRUP10_STOSQ + 1;
  GRUP10_SYSENTER = GRUP10_SYSCALL + 1;
  GRUP10_WBINVD   = GRUP10_SYSENTER + 1;

  // 11. grup komutlar
  GRUP11_BSWAP    = $110001;
  GRUP11_CALL     = GRUP11_BSWAP + 1;
  GRUP11_DEC      = GRUP11_CALL + 1;
  GRUP11_DIV      = GRUP11_DEC + 1;
  GRUP11_FLD      = GRUP11_DIV + 1;
  GRUP11_FST      = GRUP11_FLD + 1;
  GRUP11_FSTP     = GRUP11_FST + 1;
  GRUP11_FXCH     = GRUP11_FSTP + 1;
  GRUP11_INC      = GRUP11_FXCH + 1;
  GRUP11_INT      = GRUP11_INC + 1;
  GRUP11_JA       = GRUP11_INT + 1;
  GRUP11_JAE      = GRUP11_JA + 1;
  GRUP11_JB       = GRUP11_JAE + 1;
  GRUP11_JBE      = GRUP11_JB + 1;
  GRUP11_JC       = GRUP11_JBE + 1;
  GRUP11_JCXZ     = GRUP11_JC + 1;
  GRUP11_JECXZ    = GRUP11_JCXZ + 1;
  GRUP11_JRCXZ    = GRUP11_JECXZ + 1;
  GRUP11_JE       = GRUP11_JRCXZ + 1;
  GRUP11_JG       = GRUP11_JE + 1;
  GRUP11_JGE      = GRUP11_JG + 1;
  GRUP11_JL       = GRUP11_JGE + 1;
  GRUP11_JLE      = GRUP11_JL + 1;
  GRUP11_JMP      = GRUP11_JLE + 1;
  GRUP11_JNA      = GRUP11_JMP + 1;
  GRUP11_JNAE     = GRUP11_JNA + 1;
  GRUP11_JNB      = GRUP11_JNAE + 1;
  GRUP11_JNBE     = GRUP11_JNB + 1;
  GRUP11_JNC      = GRUP11_JNBE + 1;
  GRUP11_JNE      = GRUP11_JNC + 1;
  GRUP11_JNG      = GRUP11_JNE + 1;
  GRUP11_JNGE     = GRUP11_JNG + 1;
  GRUP11_JNL      = GRUP11_JNGE + 1;
  GRUP11_JNLE     = GRUP11_JNL + 1;
  GRUP11_JNO      = GRUP11_JNLE + 1;
  GRUP11_JNP      = GRUP11_JNO + 1;
  GRUP11_JNS      = GRUP11_JNP + 1;
  GRUP11_JNZ      = GRUP11_JNS + 1;
  GRUP11_JO       = GRUP11_JNZ + 1;
  GRUP11_JP       = GRUP11_JO + 1;
  GRUP11_JPE      = GRUP11_JP + 1;
  GRUP11_JPO      = GRUP11_JPE + 1;
  GRUP11_JS       = GRUP11_JPO + 1;
  GRUP11_JZ       = GRUP11_JS + 1;
  GRUP11_NOT      = GRUP11_JZ + 1;
  GRUP11_PUSH     = GRUP11_NOT + 1;
  GRUP11_POP      = GRUP11_PUSH + 1;
  GRUP11_RET      = GRUP11_POP + 1;
  GRUP11_RETF     = GRUP11_RET + 1;
  GRUP11_RETN     = GRUP11_RETF + 1;
  GRUP11_SGDT     = GRUP11_RETN + 1;
  GRUP11_SIDT     = GRUP11_SGDT + 1;

  // 12. grup komutlar
  GRUP12_ADC      = $120001;
  GRUP12_ADD      = GRUP12_ADC + 1;
  GRUP12_AND      = GRUP12_ADD + 1;
  GRUP12_CMP      = GRUP12_AND + 1;
  GRUP12_IMUL     = GRUP12_CMP + 1;
  GRUP12_IN       = GRUP12_IMUL + 1;
  GRUP12_LEA      = GRUP12_IN + 1;
  GRUP12_MOV      = GRUP12_LEA + 1;
  GRUP12_MOVSX    = GRUP12_MOV + 1;
  GRUP12_MOVZX    = GRUP12_MOVSX + 1;
  GRUP12_OR       = GRUP12_MOVZX + 1;
  GRUP12_OUT      = GRUP12_OR + 1;
  GRUP12_RCL      = GRUP12_OUT + 1;
  GRUP12_RCR      = GRUP12_RCL + 1;
  GRUP12_ROL      = GRUP12_RCR + 1;
  GRUP12_ROR      = GRUP12_ROL + 1;
  GRUP12_SAL      = GRUP12_ROR + 1;
  GRUP12_SAR      = GRUP12_SAL + 1;
  GRUP12_SBB      = GRUP12_SAR + 1;
  GRUP12_SHL      = GRUP12_SBB + 1;
  GRUP12_SHLD     = GRUP12_SHL + 1;
  GRUP12_SHR      = GRUP12_SHLD + 1;
  GRUP12_SHRD     = GRUP12_SHR + 1;
  GRUP12_SUB      = GRUP12_SHRD + 1;
  GRUP12_TEST     = GRUP12_SUB + 1;
  GRUP12_XCHG     = GRUP12_TEST + 1;
  GRUP12_XOR      = GRUP12_XCHG + 1;

  {
  GRUP01_CBW 		  = $10003;
  GRUP01_CDQ 		  = $10004;
  GRUP01_CWD 		  = $10009;
  GRUP01_IRET		  = $1002E;
  GRUP01_IRETD		  = $1002F;}

const
  TOPLAM_KOMUT = 167;
  KomutListesi: array[0..TOPLAM_KOMUT - 1] of TKomut = (

  // grup 01 - BİLDİRİMLER - (sıralama alfabetiktir)
  (Komut: 'dosya.ad';           GrupNo: GRUP01_DOS_AD_;       KomutTipi: ktBildirim),
  (Komut: 'dosya.uzantı';       GrupNo: GRUP01_DOS_UZN;       KomutTipi: ktBildirim),
  (Komut: 'kod.adres';          GrupNo: GRUP01_KOD_ADR;       KomutTipi: ktBildirim),
  (Komut: 'kod.mimari';         GrupNo: GRUP01_KOD_MIM;       KomutTipi: ktBildirim),
  (Komut: 'kod.tabaka';         GrupNo: GRUP01_KOD_TBK;       KomutTipi: ktBildirim),

  // grup 02 - DEĞİŞKENLER - (sıralama sınıflamaya göredir)
  (Komut: 'db';                 GrupNo: GRUP02_DB;            KomutTipi: ktDegisken),
  (Komut: 'dbw';                GrupNo: GRUP02_DBW;           KomutTipi: ktDegisken),
  (Komut: 'dw';                 GrupNo: GRUP02_DW;            KomutTipi: ktDegisken),
  (Komut: 'dd';                 GrupNo: GRUP02_DD;            KomutTipi: ktDegisken),
  (Komut: 'dq';                 GrupNo: GRUP02_DQ;            KomutTipi: ktDegisken),
  (Komut: 'dt';                 GrupNo: GRUP02_DT;            KomutTipi: ktDegisken),

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
  (Komut: 'faddp';              GrupNo: GRUP10_FADDP;         KomutTipi: ktIslemKodu),
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
  (Komut: 'into';               GrupNo: GRUP10_INTO;          KomutTipi: ktIslemKodu),
  (Komut: 'lahf';               GrupNo: GRUP10_LAHF;          KomutTipi: ktIslemKodu),
  (Komut: 'leave';              GrupNo: GRUP10_LEAVE;         KomutTipi: ktIslemKodu),
  (Komut: 'lock';               GrupNo: GRUP10_LOCK;          KomutTipi: ktIslemKodu),
  (Komut: 'lodsb';              GrupNo: GRUP10_LODSB;         KomutTipi: ktIslemKodu),
  (Komut: 'lodsd';              GrupNo: GRUP10_LODSD;         KomutTipi: ktIslemKodu),
  (Komut: 'lodsw';              GrupNo: GRUP10_LODSW;         KomutTipi: ktIslemKodu),
  (Komut: 'lodsq';              GrupNo: GRUP10_LODSQ;         KomutTipi: ktIslemKodu),
  (Komut: 'movsb';              GrupNo: GRUP10_MOVSB;         KomutTipi: ktIslemKodu),
  (Komut: 'movsd';              GrupNo: GRUP10_MOVSD;         KomutTipi: ktIslemKodu),
  (Komut: 'movsw';              GrupNo: GRUP10_MOVSW;         KomutTipi: ktIslemKodu),
  (Komut: 'movsq';              GrupNo: GRUP10_MOVSQ;         KomutTipi: ktIslemKodu),
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
  (Komut: 'stosb';              GrupNo: GRUP10_STOSB;         KomutTipi: ktIslemKodu),
  (Komut: 'stosd';              GrupNo: GRUP10_STOSD;         KomutTipi: ktIslemKodu),
  (Komut: 'stosw';              GrupNo: GRUP10_STOSW;         KomutTipi: ktIslemKodu),
  (Komut: 'stosq';              GrupNo: GRUP10_STOSQ;         KomutTipi: ktIslemKodu),
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
    (Komut: 'bswap';            GrupNo: GRUP11_BSWAP;         KomutTipi: ktIslemKodu),
    (Komut: 'call';             GrupNo: GRUP11_CALL;          KomutTipi: ktIslemKodu),
    (Komut: 'dec';              GrupNo: GRUP11_DEC;           KomutTipi: ktIslemKodu),
    (Komut: 'div';              GrupNo: GRUP11_DIV;           KomutTipi: ktIslemKodu),
    (Komut: 'fld';              GrupNo: GRUP11_FLD;           KomutTipi: ktIslemKodu),
    (Komut: 'fst';              GrupNo: GRUP11_FST;           KomutTipi: ktIslemKodu),
    (Komut: 'fstp';             GrupNo: GRUP11_FSTP;          KomutTipi: ktIslemKodu),
    (Komut: 'fxch';             GrupNo: GRUP11_FXCH;          KomutTipi: ktIslemKodu),
    (Komut: 'inc';              GrupNo: GRUP11_INC;           KomutTipi: ktIslemKodu),
    (Komut: 'int';              GrupNo: GRUP11_INT;           KomutTipi: ktIslemKodu),
    (Komut: 'ja';               GrupNo: GRUP11_JA;            KomutTipi: ktIslemKodu),
    (Komut: 'jae';              GrupNo: GRUP11_JAE;           KomutTipi: ktIslemKodu),
    (Komut: 'jb';               GrupNo: GRUP11_JB;            KomutTipi: ktIslemKodu),
    (Komut: 'jbe';              GrupNo: GRUP11_JBE;           KomutTipi: ktIslemKodu),
    (Komut: 'jc';               GrupNo: GRUP11_JC;            KomutTipi: ktIslemKodu),
    (Komut: 'jcxz';             GrupNo: GRUP11_JCXZ;          KomutTipi: ktIslemKodu),
    (Komut: 'jecxz';            GrupNo: GRUP11_JECXZ;         KomutTipi: ktIslemKodu),
    (Komut: 'jrcxz';            GrupNo: GRUP11_JRCXZ;         KomutTipi: ktIslemKodu),
    (Komut: 'je';               GrupNo: GRUP11_JE;            KomutTipi: ktIslemKodu),
    (Komut: 'jg';               GrupNo: GRUP11_JG;            KomutTipi: ktIslemKodu),
    (Komut: 'jge';              GrupNo: GRUP11_JGE;           KomutTipi: ktIslemKodu),
    (Komut: 'jl';               GrupNo: GRUP11_JL;            KomutTipi: ktIslemKodu),
    (Komut: 'jle';              GrupNo: GRUP11_JLE;           KomutTipi: ktIslemKodu),
    (Komut: 'jmp';              GrupNo: GRUP11_JMP;           KomutTipi: ktIslemKodu),
    (Komut: 'jna';              GrupNo: GRUP11_JNA;           KomutTipi: ktIslemKodu),
    (Komut: 'jnae';             GrupNo: GRUP11_JNAE;          KomutTipi: ktIslemKodu),
    (Komut: 'jnb';              GrupNo: GRUP11_JNB;           KomutTipi: ktIslemKodu),
    (Komut: 'jnbe';             GrupNo: GRUP11_JNBE;          KomutTipi: ktIslemKodu),
    (Komut: 'jnc';              GrupNo: GRUP11_JNC;           KomutTipi: ktIslemKodu),
    (Komut: 'jne';              GrupNo: GRUP11_JNE;           KomutTipi: ktIslemKodu),
    (Komut: 'jng';              GrupNo: GRUP11_JNG;           KomutTipi: ktIslemKodu),
    (Komut: 'jnge';             GrupNo: GRUP11_JNGE;          KomutTipi: ktIslemKodu),
    (Komut: 'jnl';              GrupNo: GRUP11_JNL;           KomutTipi: ktIslemKodu),
    (Komut: 'jnle';             GrupNo: GRUP11_JNLE;          KomutTipi: ktIslemKodu),
    (Komut: 'jno';              GrupNo: GRUP11_JNO;           KomutTipi: ktIslemKodu),
    (Komut: 'jnp';              GrupNo: GRUP11_JNP;           KomutTipi: ktIslemKodu),
    (Komut: 'jns';              GrupNo: GRUP11_JNS;           KomutTipi: ktIslemKodu),
    (Komut: 'jnz';              GrupNo: GRUP11_JNZ;           KomutTipi: ktIslemKodu),
    (Komut: 'jo';               GrupNo: GRUP11_JO;            KomutTipi: ktIslemKodu),
    (Komut: 'jp';               GrupNo: GRUP11_JP;            KomutTipi: ktIslemKodu),
    (Komut: 'jpe';              GrupNo: GRUP11_JPE;           KomutTipi: ktIslemKodu),
    (Komut: 'jpo';              GrupNo: GRUP11_JPO;           KomutTipi: ktIslemKodu),
    (Komut: 'js';               GrupNo: GRUP11_JS;            KomutTipi: ktIslemKodu),
    (Komut: 'jz';               GrupNo: GRUP11_JZ;            KomutTipi: ktIslemKodu),
    (Komut: 'not';              GrupNo: GRUP11_NOT;           KomutTipi: ktIslemKodu),
    (Komut: 'push';             GrupNo: GRUP11_PUSH;          KomutTipi: ktIslemKodu),
    (Komut: 'pop';              GrupNo: GRUP11_POP;           KomutTipi: ktIslemKodu),
    (Komut: 'ret';              GrupNo: GRUP11_RET;           KomutTipi: ktIslemKodu),
    (Komut: 'retf';             GrupNo: GRUP11_RETF;          KomutTipi: ktIslemKodu),
    (Komut: 'retn';             GrupNo: GRUP11_RETN;          KomutTipi: ktIslemKodu),
    (Komut: 'sgdt';             GrupNo: GRUP11_SGDT;          KomutTipi: ktIslemKodu),
    (Komut: 'sidt';             GrupNo: GRUP11_SIDT;          KomutTipi: ktIslemKodu),

    // 12. grup komutlar
    (Komut: 'adc';              GrupNo: GRUP12_ADC;           KomutTipi: ktIslemKodu),
    (Komut: 'add';              GrupNo: GRUP12_ADD;           KomutTipi: ktIslemKodu),
    (Komut: 'and';              GrupNo: GRUP12_AND;           KomutTipi: ktIslemKodu),
    (Komut: 'cmp';              GrupNo: GRUP12_CMP;           KomutTipi: ktIslemKodu),
    (Komut: 'imul';             GrupNo: GRUP12_IMUL;          KomutTipi: ktIslemKodu),
    (Komut: 'in';               GrupNo: GRUP12_IN;            KomutTipi: ktIslemKodu),
    (Komut: 'lea';              GrupNo: GRUP12_LEA;           KomutTipi: ktIslemKodu),
    (Komut: 'mov';              GrupNo: GRUP12_MOV;           KomutTipi: ktIslemKodu),
    (Komut: 'movsx';            GrupNo: GRUP12_MOVSX;         KomutTipi: ktIslemKodu),
    (Komut: 'movzx';            GrupNo: GRUP12_MOVZX;         KomutTipi: ktIslemKodu),
    (Komut: 'or';               GrupNo: GRUP12_OR;            KomutTipi: ktIslemKodu),
    (Komut: 'out';              GrupNo: GRUP12_OUT;           KomutTipi: ktIslemKodu),
    (Komut: 'rcl';              GrupNo: GRUP12_RCL;           KomutTipi: ktIslemKodu),
    (Komut: 'rcr';              GrupNo: GRUP12_RCR;           KomutTipi: ktIslemKodu),
    (Komut: 'rol';              GrupNo: GRUP12_ROL;           KomutTipi: ktIslemKodu),
    (Komut: 'ror';              GrupNo: GRUP12_ROR;           KomutTipi: ktIslemKodu),
    (Komut: 'sal';              GrupNo: GRUP12_SAL;           KomutTipi: ktIslemKodu),
    (Komut: 'sar';              GrupNo: GRUP12_SAR;           KomutTipi: ktIslemKodu),
    (Komut: 'sbb';              GrupNo: GRUP12_SBB;           KomutTipi: ktIslemKodu),
    (Komut: 'shl';              GrupNo: GRUP12_SHL;           KomutTipi: ktIslemKodu),
    (Komut: 'shld';             GrupNo: GRUP12_SHLD;          KomutTipi: ktIslemKodu),
    (Komut: 'shr';              GrupNo: GRUP12_SHR;           KomutTipi: ktIslemKodu),
    (Komut: 'shrd';             GrupNo: GRUP12_SHRD;          KomutTipi: ktIslemKodu),
    (Komut: 'sub';              GrupNo: GRUP12_SUB;           KomutTipi: ktIslemKodu),
    (Komut: 'test';             GrupNo: GRUP12_TEST;          KomutTipi: ktIslemKodu),
    (Komut: 'xchg';             GrupNo: GRUP12_XCHG;          KomutTipi: ktIslemKodu),
    (Komut: 'xor';              GrupNo: GRUP12_XOR;           KomutTipi: ktIslemKodu)

    );

var
  KomutListe: array[0..TOPLAM_KOMUT - 1] of TAsmKomut = (

    // 1. grup komutlar
    @Grup01Bildirim, @Grup01Bildirim, @Grup01Bildirim, @Grup01Bildirim,
    @Grup01Bildirim,

    // 2. grup komutlar
    @Grup02Degisken, @Grup02Degisken, @Grup02Degisken, @Grup02Degisken,
    @Grup02Degisken, @Grup02Degisken,

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
    @Grup10Islev, @Grup10Islev, @Grup10Islev, @Grup10Islev, @Grup10Islev,
    @Grup10Islev, @Grup10Islev, @Grup10Islev, @Grup10Islev, @Grup10Islev,
    @Grup10Islev, @Grup10Islev, @Grup10Islev, @Grup10Islev, @Grup10Islev,
    @Grup10Islev,
    {
    @Grup01Islev,           // cbw
    @Grup01Islev,           // cdq
    @Grup01Islev,           // cwd
    @Grup01Islev,           // iret
    @Grup01Islev,           // iretd}

    // 11. grup komutlar
    @Grup11Islev, @Grup11Islev, @Grup11Islev, @Grup11Islev, @Grup11Islev,
    @Grup11Islev, @Grup11Islev, @Grup11Islev, @Grup11Islev, @Grup11Islev,
    @Grup11Islev, @Grup11Islev, @Grup11Islev, @Grup11Islev, @Grup11Islev,
    @Grup11Islev, @Grup11Islev, @Grup11Islev, @Grup11Islev, @Grup11Islev,
    @Grup11Islev, @Grup11Islev, @Grup11Islev, @Grup11Islev, @Grup11Islev,
    @Grup11Islev, @Grup11Islev, @Grup11Islev, @Grup11Islev, @Grup11Islev,
    @Grup11Islev, @Grup11Islev, @Grup11Islev, @Grup11Islev, @Grup11Islev,
    @Grup11Islev, @Grup11Islev, @Grup11Islev, @Grup11Islev, @Grup11Islev,
    @Grup11Islev, @Grup11Islev, @Grup11Islev, @Grup11Islev, @Grup11Islev,
    @Grup11Islev, @Grup11Islev, @Grup11Islev, @Grup11Islev, @Grup11Islev,
    @Grup11Islev, @Grup11Islev, @Grup11Islev,

    // 12. grup komutlar
    @Grup12Islev, @Grup12Islev, @Grup12Islev, @Grup12Islev, @Grup12Islev,
    @Grup12Islev, @Grup12Islev, @Grup12Islev, @Grup12Islev, @Grup12Islev,
    @Grup12Islev, @Grup12Islev, @Grup12Islev, @Grup12Islev, @Grup12Islev,
    @Grup12Islev, @Grup12Islev, @Grup12Islev, @Grup12Islev, @Grup12Islev,
    @Grup12Islev, @Grup12Islev, @Grup12Islev, @Grup12Islev, @Grup12Islev,
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
