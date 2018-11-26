{-------------------------------------------------------------------------------

  Dosya: komutlar.pas

  İşlev: işlem kodları (opcode) ve ilgili çağrı işlevlerini içerir

  Güncelleme Tarihi: 08/09/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit komutlar;

interface

uses Classes, SysUtils, genel, paylasim, bildirimler;

{ assembler komut listesi }
const
  // 1. grup komutlar
  GRUP01_DOS_AD_  = $010001;
  GRUP01_BICIM    = GRUP01_DOS_AD_ + 1;
  GRUP01_DOS_EKLE = GRUP01_BICIM + 1;
  GRUP01_DOS_UZN  = GRUP01_DOS_EKLE + 1;
  GRUP01_KOD_ADR  = GRUP01_DOS_UZN + 1;
  GRUP01_KOD_MIM  = GRUP01_KOD_ADR + 1;
  GRUP01_KOD_TBK  = GRUP01_KOD_MIM + 1;

  // 2. grup komutlar
  GRUP02_DB       = $020001;
  GRUP02_DB0      = GRUP02_DB + 1;
  GRUP02_DBW      = GRUP02_DB0 + 1;
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
  GRUP12_SHR      = GRUP12_SHL + 1;
  GRUP12_SUB      = GRUP12_SHR + 1;
  GRUP12_TEST     = GRUP12_SUB + 1;
  GRUP12_XCHG     = GRUP12_TEST + 1;
  GRUP12_XOR      = GRUP12_XCHG + 1;

  // 13. grup komutlar
  GRUP13_SHLD     = $130001;
  GRUP13_SHRD     = GRUP13_SHLD + 1;

  {
  GRUP01_CBW 		  = $10003;
  GRUP01_CDQ 		  = $10004;
  GRUP01_CWD 		  = $10009;
  GRUP01_IRET		  = $1002E;
  GRUP01_IRETD		  = $1002F;}

const
  // SNo = sıra no = bu değerin ataması işlev sırasında gerçekleşmektedir.
  // GNo = grup no = komuta ait benzersiz kimlik
  TOPLAM_KOMUT = 170;
  KomutListesi: array[0..TOPLAM_KOMUT - 1] of TKomut = (

    // grup 01 - BİLDİRİMLER - (sıralama alfabetiktir)
    (Ad: 'dosya.ad';           SNo: 0; GNo: GRUP01_DOS_AD_;       Tip: kBildirim),
    (Ad: 'dosya.biçim';        SNo: 0; GNo: GRUP01_BICIM;         Tip: kBildirim),
    (Ad: 'dosya.ekle';         SNo: 0; GNo: GRUP01_DOS_EKLE;      Tip: kBildirim),
    (Ad: 'dosya.uzantı';       SNo: 0; GNo: GRUP01_DOS_UZN;       Tip: kBildirim),
    (Ad: 'kod.adres';          SNo: 0; GNo: GRUP01_KOD_ADR;       Tip: kBildirim),
    (Ad: 'kod.mimari';         SNo: 0; GNo: GRUP01_KOD_MIM;       Tip: kBildirim),
    (Ad: 'kod.tabaka';         SNo: 0; GNo: GRUP01_KOD_TBK;       Tip: kBildirim),

    // grup 02 - DEĞİŞKENLER - (sıralama sınıflamaya göredir)
    (Ad: 'db';                 SNo: 0; GNo: GRUP02_DB;            Tip: kDegisken),
    (Ad: 'db0';                SNo: 0; GNo: GRUP02_DB0;           Tip: kDegisken),
    (Ad: 'dbw';                SNo: 0; GNo: GRUP02_DBW;           Tip: kDegisken),
    (Ad: 'dw';                 SNo: 0; GNo: GRUP02_DW;            Tip: kDegisken),
    (Ad: 'dd';                 SNo: 0; GNo: GRUP02_DD;            Tip: kDegisken),
    (Ad: 'dq';                 SNo: 0; GNo: GRUP02_DQ;            Tip: kDegisken),
    (Ad: 'dt';                 SNo: 0; GNo: GRUP02_DT;            Tip: kDegisken),

    // grup 10 - işlem kodu - (sıralama alfabetiktir)
    // bu gruptaki komutlar: SADECE işlem koduna sahip, hiçbir öndeğer (parametre)
    // almayan komutlardır
    (Ad: 'aaa';                SNo: 0; GNo: GRUP10_AAA;           Tip: kIslemKodu),
    (Ad: 'aas';                SNo: 0; GNo: GRUP10_AAS;           Tip: kIslemKodu),
    (Ad: 'clc';                SNo: 0; GNo: GRUP10_CLC;           Tip: kIslemKodu),
    (Ad: 'cld';                SNo: 0; GNo: GRUP10_CLD;           Tip: kIslemKodu),
    (Ad: 'cli';                SNo: 0; GNo: GRUP10_CLI;           Tip: kIslemKodu),
    (Ad: 'cmc';                SNo: 0; GNo: GRUP10_CMC;           Tip: kIslemKodu),
    (Ad: 'cpuid';              SNo: 0; GNo: GRUP10_CPUID;         Tip: kIslemKodu),
    (Ad: 'daa';                SNo: 0; GNo: GRUP10_DAA;           Tip: kIslemKodu),
    (Ad: 'das';                SNo: 0; GNo: GRUP10_DAS;           Tip: kIslemKodu),
    (Ad: 'emms';               SNo: 0; GNo: GRUP10_EMMS;          Tip: kIslemKodu),
    (Ad: 'f2xm1';              SNo: 0; GNo: GRUP10_F2XM1;         Tip: kIslemKodu),
    (Ad: 'fabs';               SNo: 0; GNo: GRUP10_FABS;          Tip: kIslemKodu),
    (Ad: 'faddp';              SNo: 0; GNo: GRUP10_FADDP;         Tip: kIslemKodu),
    (Ad: 'fchs';               SNo: 0; GNo: GRUP10_FCHS;          Tip: kIslemKodu),
    (Ad: 'fclex';              SNo: 0; GNo: GRUP10_FCLEX;         Tip: kIslemKodu),
    (Ad: 'fcos';               SNo: 0; GNo: GRUP10_FCOS;          Tip: kIslemKodu),
    (Ad: 'fdecstp';            SNo: 0; GNo: GRUP10_FDECSTP;       Tip: kIslemKodu),
    (Ad: 'fincstp';            SNo: 0; GNo: GRUP10_FINCSTP;       Tip: kIslemKodu),
    (Ad: 'finit';              SNo: 0; GNo: GRUP10_FINIT;         Tip: kIslemKodu),
    (Ad: 'fld1';               SNo: 0; GNo: GRUP10_FLD1;          Tip: kIslemKodu),
    (Ad: 'fldl2e';             SNo: 0; GNo: GRUP10_FLDL2E;        Tip: kIslemKodu),
    (Ad: 'fldl2t';             SNo: 0; GNo: GRUP10_FLDL2T;        Tip: kIslemKodu),
    (Ad: 'fldlg2';             SNo: 0; GNo: GRUP10_FLDLG2;        Tip: kIslemKodu),
    (Ad: 'fldln2';             SNo: 0; GNo: GRUP10_FLDLN2;        Tip: kIslemKodu),
    (Ad: 'fldpi';              SNo: 0; GNo: GRUP10_FLDPI;         Tip: kIslemKodu),
    (Ad: 'fldz';               SNo: 0; GNo: GRUP10_FLDZ;          Tip: kIslemKodu),
    (Ad: 'fnclex';             SNo: 0; GNo: GRUP10_FNCLEX;        Tip: kIslemKodu),
    (Ad: 'fninit';             SNo: 0; GNo: GRUP10_FNINIT;        Tip: kIslemKodu),
    (Ad: 'fnop';               SNo: 0; GNo: GRUP10_FNOP;          Tip: kIslemKodu),
    (Ad: 'fpatan';             SNo: 0; GNo: GRUP10_FPATAN;        Tip: kIslemKodu),
    (Ad: 'fprem';              SNo: 0; GNo: GRUP10_FPREM;         Tip: kIslemKodu),
    (Ad: 'fprem1';             SNo: 0; GNo: GRUP10_FPREM1;        Tip: kIslemKodu),
    (Ad: 'fptan';              SNo: 0; GNo: GRUP10_FPTAN;         Tip: kIslemKodu),
    (Ad: 'frndint';            SNo: 0; GNo: GRUP10_FRNDINT;       Tip: kIslemKodu),
    (Ad: 'fscale';             SNo: 0; GNo: GRUP10_FSCALE;        Tip: kIslemKodu),
    (Ad: 'fsin';               SNo: 0; GNo: GRUP10_FSIN;          Tip: kIslemKodu),
    (Ad: 'fsincos';            SNo: 0; GNo: GRUP10_FSINCOS;       Tip: kIslemKodu),
    (Ad: 'fsqrt';              SNo: 0; GNo: GRUP10_FSQRT;         Tip: kIslemKodu),
    (Ad: 'ftst';               SNo: 0; GNo: GRUP10_FTST;          Tip: kIslemKodu),
    (Ad: 'fyl2x';              SNo: 0; GNo: GRUP10_FYL2X;         Tip: kIslemKodu),
    (Ad: 'fyl2xp1';            SNo: 0; GNo: GRUP10_FYL2XP1;       Tip: kIslemKodu),
    (Ad: 'fxam';               SNo: 0; GNo: GRUP10_FXAM;          Tip: kIslemKodu),
    (Ad: 'fxtract';            SNo: 0; GNo: GRUP10_FXTRACT;       Tip: kIslemKodu),
    (Ad: 'hlt';                SNo: 0; GNo: GRUP10_HLT;           Tip: kIslemKodu),
    (Ad: 'into';               SNo: 0; GNo: GRUP10_INTO;          Tip: kIslemKodu),
    (Ad: 'lahf';               SNo: 0; GNo: GRUP10_LAHF;          Tip: kIslemKodu),
    (Ad: 'leave';              SNo: 0; GNo: GRUP10_LEAVE;         Tip: kIslemKodu),
    (Ad: 'lock';               SNo: 0; GNo: GRUP10_LOCK;          Tip: kIslemKodu),
    (Ad: 'lodsb';              SNo: 0; GNo: GRUP10_LODSB;         Tip: kIslemKodu),
    (Ad: 'lodsd';              SNo: 0; GNo: GRUP10_LODSD;         Tip: kIslemKodu),
    (Ad: 'lodsw';              SNo: 0; GNo: GRUP10_LODSW;         Tip: kIslemKodu),
    (Ad: 'lodsq';              SNo: 0; GNo: GRUP10_LODSQ;         Tip: kIslemKodu),
    (Ad: 'movsb';              SNo: 0; GNo: GRUP10_MOVSB;         Tip: kIslemKodu),
    (Ad: 'movsd';              SNo: 0; GNo: GRUP10_MOVSD;         Tip: kIslemKodu),
    (Ad: 'movsw';              SNo: 0; GNo: GRUP10_MOVSW;         Tip: kIslemKodu),
    (Ad: 'movsq';              SNo: 0; GNo: GRUP10_MOVSQ;         Tip: kIslemKodu),
    (Ad: 'popa';               SNo: 0; GNo: GRUP10_POPA;          Tip: kIslemKodu),
    (Ad: 'popad';              SNo: 0; GNo: GRUP10_POPAD;         Tip: kIslemKodu),
    (Ad: 'popf';               SNo: 0; GNo: GRUP10_POPF;          Tip: kIslemKodu),
    (Ad: 'popfd';              SNo: 0; GNo: GRUP10_POPFD;         Tip: kIslemKodu),
    (Ad: 'popfq';              SNo: 0; GNo: GRUP10_POPFQ;         Tip: kIslemKodu),
    (Ad: 'pusha';              SNo: 0; GNo: GRUP10_PUSHA;         Tip: kIslemKodu),
    (Ad: 'pushad';             SNo: 0; GNo: GRUP10_PUSHAD;        Tip: kIslemKodu),
    (Ad: 'pushf';              SNo: 0; GNo: GRUP10_PUSHF;         Tip: kIslemKodu),
    (Ad: 'pushfd';             SNo: 0; GNo: GRUP10_PUSHFD;        Tip: kIslemKodu),
    (Ad: 'pushfq';             SNo: 0; GNo: GRUP10_PUSHFQ;        Tip: kIslemKodu),
    (Ad: 'rdtsc';              SNo: 0; GNo: GRUP10_RDTSC;         Tip: kIslemKodu),
    (Ad: 'rdtscp';             SNo: 0; GNo: GRUP10_RDTSCP;        Tip: kIslemKodu),
    (Ad: 'stc';                SNo: 0; GNo: GRUP10_STC;           Tip: kIslemKodu),
    (Ad: 'sti';                SNo: 0; GNo: GRUP10_STI;           Tip: kIslemKodu),
    (Ad: 'stosb';              SNo: 0; GNo: GRUP10_STOSB;         Tip: kIslemKodu),
    (Ad: 'stosd';              SNo: 0; GNo: GRUP10_STOSD;         Tip: kIslemKodu),
    (Ad: 'stosw';              SNo: 0; GNo: GRUP10_STOSW;         Tip: kIslemKodu),
    (Ad: 'stosq';              SNo: 0; GNo: GRUP10_STOSQ;         Tip: kIslemKodu),
    (Ad: 'syscall';            SNo: 0; GNo: GRUP10_SYSCALL;       Tip: kIslemKodu),
    (Ad: 'sysenter';           SNo: 0; GNo: GRUP10_SYSENTER;      Tip: kIslemKodu),
    (Ad: 'wbinvd';             SNo: 0; GNo: GRUP10_WBINVD;        Tip: kIslemKodu),

    {
      (Ad: 'cbw';        SNo: 0; GNo: GRUP01_CBW;      Tip: kIslemKodu),
      (Ad: 'cdq';        SNo: 0; GNo: GRUP01_CDQ;      Tip: kIslemKodu),
      (Ad: 'cwd';        SNo: 0; GNo: GRUP01_CWD;      Tip: kIslemKodu),
      (Ad: 'iret';       SNo: 0; GNo: GRUP01_IRET;     Tip: kIslemKodu),
      (Ad: 'iretd';      SNo: 0; GNo: GRUP01_IRETD;    Tip: kIslemKodu),}

      // 11. grup komutlar
      (Ad: 'bswap';            SNo: 0; GNo: GRUP11_BSWAP;         Tip: kIslemKodu),
      (Ad: 'call';             SNo: 0; GNo: GRUP11_CALL;          Tip: kIslemKodu),
      (Ad: 'dec';              SNo: 0; GNo: GRUP11_DEC;           Tip: kIslemKodu),
      (Ad: 'div';              SNo: 0; GNo: GRUP11_DIV;           Tip: kIslemKodu),
      (Ad: 'fld';              SNo: 0; GNo: GRUP11_FLD;           Tip: kIslemKodu),
      (Ad: 'fst';              SNo: 0; GNo: GRUP11_FST;           Tip: kIslemKodu),
      (Ad: 'fstp';             SNo: 0; GNo: GRUP11_FSTP;          Tip: kIslemKodu),
      (Ad: 'fxch';             SNo: 0; GNo: GRUP11_FXCH;          Tip: kIslemKodu),
      (Ad: 'inc';              SNo: 0; GNo: GRUP11_INC;           Tip: kIslemKodu),
      (Ad: 'int';              SNo: 0; GNo: GRUP11_INT;           Tip: kIslemKodu),
      (Ad: 'ja';               SNo: 0; GNo: GRUP11_JA;            Tip: kIslemKodu),
      (Ad: 'jae';              SNo: 0; GNo: GRUP11_JAE;           Tip: kIslemKodu),
      (Ad: 'jb';               SNo: 0; GNo: GRUP11_JB;            Tip: kIslemKodu),
      (Ad: 'jbe';              SNo: 0; GNo: GRUP11_JBE;           Tip: kIslemKodu),
      (Ad: 'jc';               SNo: 0; GNo: GRUP11_JC;            Tip: kIslemKodu),
      (Ad: 'jcxz';             SNo: 0; GNo: GRUP11_JCXZ;          Tip: kIslemKodu),
      (Ad: 'jecxz';            SNo: 0; GNo: GRUP11_JECXZ;         Tip: kIslemKodu),
      (Ad: 'jrcxz';            SNo: 0; GNo: GRUP11_JRCXZ;         Tip: kIslemKodu),
      (Ad: 'je';               SNo: 0; GNo: GRUP11_JE;            Tip: kIslemKodu),
      (Ad: 'jg';               SNo: 0; GNo: GRUP11_JG;            Tip: kIslemKodu),
      (Ad: 'jge';              SNo: 0; GNo: GRUP11_JGE;           Tip: kIslemKodu),
      (Ad: 'jl';               SNo: 0; GNo: GRUP11_JL;            Tip: kIslemKodu),
      (Ad: 'jle';              SNo: 0; GNo: GRUP11_JLE;           Tip: kIslemKodu),
      (Ad: 'jmp';              SNo: 0; GNo: GRUP11_JMP;           Tip: kIslemKodu),
      (Ad: 'jna';              SNo: 0; GNo: GRUP11_JNA;           Tip: kIslemKodu),
      (Ad: 'jnae';             SNo: 0; GNo: GRUP11_JNAE;          Tip: kIslemKodu),
      (Ad: 'jnb';              SNo: 0; GNo: GRUP11_JNB;           Tip: kIslemKodu),
      (Ad: 'jnbe';             SNo: 0; GNo: GRUP11_JNBE;          Tip: kIslemKodu),
      (Ad: 'jnc';              SNo: 0; GNo: GRUP11_JNC;           Tip: kIslemKodu),
      (Ad: 'jne';              SNo: 0; GNo: GRUP11_JNE;           Tip: kIslemKodu),
      (Ad: 'jng';              SNo: 0; GNo: GRUP11_JNG;           Tip: kIslemKodu),
      (Ad: 'jnge';             SNo: 0; GNo: GRUP11_JNGE;          Tip: kIslemKodu),
      (Ad: 'jnl';              SNo: 0; GNo: GRUP11_JNL;           Tip: kIslemKodu),
      (Ad: 'jnle';             SNo: 0; GNo: GRUP11_JNLE;          Tip: kIslemKodu),
      (Ad: 'jno';              SNo: 0; GNo: GRUP11_JNO;           Tip: kIslemKodu),
      (Ad: 'jnp';              SNo: 0; GNo: GRUP11_JNP;           Tip: kIslemKodu),
      (Ad: 'jns';              SNo: 0; GNo: GRUP11_JNS;           Tip: kIslemKodu),
      (Ad: 'jnz';              SNo: 0; GNo: GRUP11_JNZ;           Tip: kIslemKodu),
      (Ad: 'jo';               SNo: 0; GNo: GRUP11_JO;            Tip: kIslemKodu),
      (Ad: 'jp';               SNo: 0; GNo: GRUP11_JP;            Tip: kIslemKodu),
      (Ad: 'jpe';              SNo: 0; GNo: GRUP11_JPE;           Tip: kIslemKodu),
      (Ad: 'jpo';              SNo: 0; GNo: GRUP11_JPO;           Tip: kIslemKodu),
      (Ad: 'js';               SNo: 0; GNo: GRUP11_JS;            Tip: kIslemKodu),
      (Ad: 'jz';               SNo: 0; GNo: GRUP11_JZ;            Tip: kIslemKodu),
      (Ad: 'not';              SNo: 0; GNo: GRUP11_NOT;           Tip: kIslemKodu),
      (Ad: 'push';             SNo: 0; GNo: GRUP11_PUSH;          Tip: kIslemKodu),
      (Ad: 'pop';              SNo: 0; GNo: GRUP11_POP;           Tip: kIslemKodu),
      (Ad: 'ret';              SNo: 0; GNo: GRUP11_RET;           Tip: kIslemKodu),
      (Ad: 'retf';             SNo: 0; GNo: GRUP11_RETF;          Tip: kIslemKodu),
      (Ad: 'retn';             SNo: 0; GNo: GRUP11_RETN;          Tip: kIslemKodu),
      (Ad: 'sgdt';             SNo: 0; GNo: GRUP11_SGDT;          Tip: kIslemKodu),
      (Ad: 'sidt';             SNo: 0; GNo: GRUP11_SIDT;          Tip: kIslemKodu),

      // 12. grup komutlar
      (Ad: 'adc';              SNo: 0; GNo: GRUP12_ADC;           Tip: kIslemKodu),
      (Ad: 'add';              SNo: 0; GNo: GRUP12_ADD;           Tip: kIslemKodu),
      (Ad: 'and';              SNo: 0; GNo: GRUP12_AND;           Tip: kIslemKodu),
      (Ad: 'cmp';              SNo: 0; GNo: GRUP12_CMP;           Tip: kIslemKodu),
      (Ad: 'imul';             SNo: 0; GNo: GRUP12_IMUL;          Tip: kIslemKodu),
      (Ad: 'in';               SNo: 0; GNo: GRUP12_IN;            Tip: kIslemKodu),
      (Ad: 'lea';              SNo: 0; GNo: GRUP12_LEA;           Tip: kIslemKodu),
      (Ad: 'mov';              SNo: 0; GNo: GRUP12_MOV;           Tip: kIslemKodu),
      (Ad: 'movsx';            SNo: 0; GNo: GRUP12_MOVSX;         Tip: kIslemKodu),
      (Ad: 'movzx';            SNo: 0; GNo: GRUP12_MOVZX;         Tip: kIslemKodu),
      (Ad: 'or';               SNo: 0; GNo: GRUP12_OR;            Tip: kIslemKodu),
      (Ad: 'out';              SNo: 0; GNo: GRUP12_OUT;           Tip: kIslemKodu),
      (Ad: 'rcl';              SNo: 0; GNo: GRUP12_RCL;           Tip: kIslemKodu),
      (Ad: 'rcr';              SNo: 0; GNo: GRUP12_RCR;           Tip: kIslemKodu),
      (Ad: 'rol';              SNo: 0; GNo: GRUP12_ROL;           Tip: kIslemKodu),
      (Ad: 'ror';              SNo: 0; GNo: GRUP12_ROR;           Tip: kIslemKodu),
      (Ad: 'sal';              SNo: 0; GNo: GRUP12_SAL;           Tip: kIslemKodu),
      (Ad: 'sar';              SNo: 0; GNo: GRUP12_SAR;           Tip: kIslemKodu),
      (Ad: 'sbb';              SNo: 0; GNo: GRUP12_SBB;           Tip: kIslemKodu),
      (Ad: 'shl';              SNo: 0; GNo: GRUP12_SHL;           Tip: kIslemKodu),
      (Ad: 'shr';              SNo: 0; GNo: GRUP12_SHR;           Tip: kIslemKodu),
      (Ad: 'sub';              SNo: 0; GNo: GRUP12_SUB;           Tip: kIslemKodu),
      (Ad: 'test';             SNo: 0; GNo: GRUP12_TEST;          Tip: kIslemKodu),
      (Ad: 'xchg';             SNo: 0; GNo: GRUP12_XCHG;          Tip: kIslemKodu),
      (Ad: 'xor';              SNo: 0; GNo: GRUP12_XOR;           Tip: kIslemKodu),

      // 13. grup komutlar
      (Ad: 'shld';             SNo: 0; GNo: GRUP13_SHLD;          Tip: kIslemKodu),
      (Ad: 'shrd';             SNo: 0; GNo: GRUP13_SHRD;          Tip: kIslemKodu)
    );

function KomutBilgisiAl(AKomut: string): TKomut;
function DegerBirKomutMu(ADeger: string): Boolean;
function KomutHata(SatirNo: Integer; ParcaNo: Integer;
  VeriKontrolTip: TKomutTipi; Veri1: string; Veri2: QWord): Integer;

implementation

uses donusum;

// AKomut komut dizisini KomutListesi'nde arar, mevcut olması durumunda geriye
// komut yapısını döndürür
function KomutBilgisiAl(AKomut: string): TKomut;
var
  i, KomutU: Integer;
  Komut: string;
begin

  Komut := KucukHarfeCevir(AKomut);
  KomutU := Length(Komut);

  Result.Tip := kTanimsiz;
  if(KomutU = 0) then Exit;

  for i := 0 to TOPLAM_KOMUT - 1 do
  begin

    if(Length(KomutListesi[i].Ad) = KomutU) and (KomutListesi[i].Ad = Komut) then
    begin

      Result := KomutListesi[i];
      Exit;
    end;
  end;
end;

// ilgili değerin KomutListesi'ndeki bir değer olup olmadığını sorgular
function DegerBirKomutMu(ADeger: string): Boolean;
var
  i, DegerU: Integer;
  Deger: string;
begin

  Deger := KucukHarfeCevir(ADeger);
  DegerU := Length(Deger);

  Result := False;
  if(DegerU = 0) then Exit;

  for i := 0 to TOPLAM_KOMUT - 1 do
  begin

    if(Length(KomutListesi[i].Ad) = DegerU) and (KomutListesi[i].Ad = Deger) then
    begin

      Result := True;
      Exit;
    end;
  end;
end;

// hata olması durumunda çağrılacak işlev
function KomutHata(SatirNo: Integer; ParcaNo: Integer;
  VeriKontrolTip: TKomutTipi; Veri1: string; Veri2: QWord): Integer;
begin

  GHataAciklama := Veri1;
  Result := HATA_BILINMEYEN_KOMUT;
end;

end.
