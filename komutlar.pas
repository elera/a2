{-------------------------------------------------------------------------------

  Dosya: komutlar.pas

  İşlev: işlem kodları (opcode) ve ilgili çağrı işlevlerini içerir

  Güncelleme Tarihi: 18/02/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit komutlar;

interface

uses Classes, SysUtils, genel, g01islev, g02islev, g10islev, g11islev, g12islev;

type
  TKomutDurum = record
    SiraNo: Integer;
    ABVT: TAnaBolumVeriTipi;
  end;

type
  // tüm assembler komutlarının çağrı yapısı
  // 1. ParcaNo = komut dizisinin her bir ana kesim / parça numarasıdır
  //    not: ParcaNo = 1, Veri2 değeri olarak komutun sıra numarasını döndürür
  // 2. VeriKontrolTip = işleve gönderilen veri tipini belirtir
  // 3. Veri1 = eğer varsa, karakter dizisi türünde veri
  // 4. Veri2 = eğer varsa, sayısal türde veri
  TAsmKomut = function(ParcaNo: Integer; VeriKontrolTip: TVeriKontrolTip; Veri1: string;
    Veri2: QWord): Integer;

type
  TKomut = record
    Komut: string[15];
    GrupNo: Integer;
    ABVT: TAnaBolumVeriTipi;
  end;

  { assembler komut listesi }
  const
    // 1. grup komutlar
    GRUP01_KOD_MIM  = $010001;
    GRUP01_DOS_ADI  = $010002;
    GRUP01_DOS_UZN  = $010003;

    // 2. grup komutlar
    GRUP02_DB       = $020001;
    GRUP02_DW       = $020002;
    GRUP02_DD       = $020003;
    GRUP02_DQ       = $020004;

    // 10. grup komutlar
    GRUP10_AAA 		  = $100001;

    // 11. grup komutlar
    GRUP11_INT      = $110001;

    // 12. grup komutlar
    GRUP12_MOV      = $120001;

    {GRUP01_AAS 		  = $10002;
    GRUP01_CBW 		  = $10003;
    GRUP01_CDQ 		  = $10004;
    GRUP01_CLD 		  = $10005;
    GRUP01_CLI 		  = $10006;
    GRUP01_CMC 		  = $10007;
    GRUP01_CPUID 	  = $10008;
    GRUP01_CWD 		  = $10009;
    GRUP01_DAA 		  = $1000A;
    GRUP01_DAS 		  = $1000B;
    GRUP01_EMMS 		  = $1000C;
    GRUP01_FABS 		  = $1000D;
    GRUP01_FCHS 		  = $1000E;
    GRUP01_FCLEX 	  = $1000F;
    GRUP01_FCOS 		  = $10010;
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
    GRUP01_FSIN		  = $10024;
    GRUP01_FSINCOS	  = $10025;
    GRUP01_FSQRT		  = $10026;
    GRUP01_FTST		  = $10027;
    GRUP01_FYL2X		  = $10028;
    GRUP01_FYL2XP1	  = $10029;
    GRUP01_FXAM		  = $1002A;
    GRUP01_FXTRACT	  = $1002B;
    GRUP01_F2XM1		  = $1002C;
    GRUP01_HLT		    = $1002D;
    GRUP01_IRET		  = $1002E;
    GRUP01_IRETD		  = $1002F;
    GRUP01_LAHF		  = $10030;
    GRUP01_LEAVE		  = $10031;
    GRUP01_LOCK		  = $10032;
    GRUP01_POPA		  = $10033;
    GRUP01_POPAD		  = $10034;
    GRUP01_POPF		  = $10035;
    GRUP01_POPFD		  = $10036;
    GRUP01_PUSHA		  = $10037;
    GRUP01_PUSHAD	  = $10038;
    GRUP01_PUSHF		  = $10039;
    GRUP01_PUSHFD	  = $1003A;
    GRUP01_RDTSC		  = $1003B;
    GRUP01_RDTSCP	  = $1003C;
    GRUP01_STC		    = $1003D;
    GRUP01_STI		    = $1003E;
    GRUP01_WBINVD	  = $1003F;}

    // 2. grup komutlar; işlem kodundan hemen sonra byte türünde sayısal sabit
    // değer alan komutlardır

const
  TOPLAM_KOMUT = 10;
  KomutListesi: array[0..TOPLAM_KOMUT - 1] of TKomut = (

  // grup 01 - bildirimler - (sıralama sınıflamaya göredir)
  (Komut: 'kod.mimari';         GrupNo: GRUP01_KOD_MIM;       ABVT: abvtBildirim),
  (Komut: 'dosya.adı';          GrupNo: GRUP01_DOS_ADI;       ABVT: abvtBildirim),
  (Komut: 'dosya.uzantı';       GrupNo: GRUP01_DOS_UZN;       ABVT: abvtBildirim),

  // grup 02 - tanımlayıcılar - (sıralama sınıflamaya göredir)
  (Komut: 'db';                 GrupNo: GRUP02_DB;            ABVT: abvtTanim),
  (Komut: 'dw';                 GrupNo: GRUP02_DW;            ABVT: abvtTanim),
  (Komut: 'dd';                 GrupNo: GRUP02_DD;            ABVT: abvtTanim),
  (Komut: 'dq';                 GrupNo: GRUP02_DQ;            ABVT: abvtTanim),

  // grup 10 - işlem kodu - (sıralama alfabetiktir)
  // bu gruptaki komutlar: SADECE işlem koduna sahip, hiçbir öndeğer (parametre)
  // almayan komutlardır
  (Komut: 'aaa';                GrupNo: GRUP10_AAA;           ABVT: abvtIslemKodu),  // bitmedi
  {    (Komut: 'aas';        GrupNo: GRUP01_AAS;      ABVT: abvtIslemKodu),
    (Komut: 'cbw';        GrupNo: GRUP01_CBW;      ABVT: abvtIslemKodu),
    (Komut: 'cdq';        GrupNo: GRUP01_CDQ;      ABVT: abvtIslemKodu),
    (Komut: 'cld';        GrupNo: GRUP01_CLD;      ABVT: abvtIslemKodu),
    (Komut: 'cli';        GrupNo: GRUP01_CLI;      ABVT: abvtIslemKodu),
    (Komut: 'cmc';        GrupNo: GRUP01_CMC;      ABVT: abvtIslemKodu),
    (Komut: 'cpuid';      GrupNo: GRUP01_CPUID;    ABVT: abvtIslemKodu),
    (Komut: 'cwd';        GrupNo: GRUP01_CWD;      ABVT: abvtIslemKodu),
    (Komut: 'daa';        GrupNo: GRUP01_DAA;      ABVT: abvtIslemKodu),
    (Komut: 'das';        GrupNo: GRUP01_DAS;      ABVT: abvtIslemKodu),
    (Komut: 'emms';       GrupNo: GRUP01_EMMS;     ABVT: abvtIslemKodu),
    (Komut: 'fabs';       GrupNo: GRUP01_FABS;     ABVT: abvtIslemKodu),
    (Komut: 'fchs';       GrupNo: GRUP01_FCHS;     ABVT: abvtIslemKodu),
    (Komut: 'fclex';      GrupNo: GRUP01_FCLEX;    ABVT: abvtIslemKodu),
    (Komut: 'fcos';       GrupNo: GRUP01_FCOS;     ABVT: abvtIslemKodu),
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
    (Komut: 'fsin';       GrupNo: GRUP01_FSIN;     ABVT: abvtIslemKodu),
    (Komut: 'fsincos';    GrupNo: GRUP01_FSINCOS;  ABVT: abvtIslemKodu),
    (Komut: 'fsqrt';      GrupNo: GRUP01_FSQRT;    ABVT: abvtIslemKodu),
    (Komut: 'ftst';       GrupNo: GRUP01_FTST;     ABVT: abvtIslemKodu),
    (Komut: 'fyl2x';      GrupNo: GRUP01_FYL2X;    ABVT: abvtIslemKodu),
    (Komut: 'fyl2xp1';    GrupNo: GRUP01_FYL2XP1;  ABVT: abvtIslemKodu),
    (Komut: 'fxam';       GrupNo: GRUP01_FXAM;     ABVT: abvtIslemKodu),
    (Komut: 'fxtract';    GrupNo: GRUP01_FXTRACT;  ABVT: abvtIslemKodu),
    (Komut: 'f2xm1';      GrupNo: GRUP01_F2XM1;    ABVT: abvtIslemKodu),
    (Komut: 'hlt';        GrupNo: GRUP01_HLT;      ABVT: abvtIslemKodu),
    (Komut: 'iret';       GrupNo: GRUP01_IRET;     ABVT: abvtIslemKodu),
    (Komut: 'iretd';      GrupNo: GRUP01_IRETD;    ABVT: abvtIslemKodu),
    (Komut: 'lahf';       GrupNo: GRUP01_LAHF;     ABVT: abvtIslemKodu),
    (Komut: 'leave';      GrupNo: GRUP01_LEAVE;    ABVT: abvtIslemKodu),
    (Komut: 'lock';       GrupNo: GRUP01_LOCK;     ABVT: abvtIslemKodu),
    (Komut: 'popa';       GrupNo: GRUP01_POPA;     ABVT: abvtIslemKodu),
    (Komut: 'popad';      GrupNo: GRUP01_POPAD;    ABVT: abvtIslemKodu),
    (Komut: 'popf';       GrupNo: GRUP01_POPF;     ABVT: abvtIslemKodu),
    (Komut: 'popfd';      GrupNo: GRUP01_POPFD;    ABVT: abvtIslemKodu),
    (Komut: 'pusha';      GrupNo: GRUP01_PUSHA;    ABVT: abvtIslemKodu),
    (Komut: 'pushad';     GrupNo: GRUP01_PUSHAD;   ABVT: abvtIslemKodu),
    (Komut: 'pushf';      GrupNo: GRUP01_PUSHF;    ABVT: abvtIslemKodu),
    (Komut: 'pushfd';     GrupNo: GRUP01_PUSHFD;   ABVT: abvtIslemKodu),
    (Komut: 'rdtsc';      GrupNo: GRUP01_RDTSC;    ABVT: abvtIslemKodu),
    (Komut: 'rdtscp';     GrupNo: GRUP01_RDTSCP;   ABVT: abvtIslemKodu),
    (Komut: 'stc';        GrupNo: GRUP01_STC;      ABVT: abvtIslemKodu),
    (Komut: 'sti';        GrupNo: GRUP01_STI;      ABVT: abvtIslemKodu),
    (Komut: 'wbinvd';     GrupNo: GRUP01_WBINVD;   ABVT: abvtIslemKodu),}

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

  @Grup02Bildirim,            // db
  @Grup02Bildirim,            // dd
  @Grup02Bildirim,            // dw
  @Grup02Bildirim,           // dq

    // 1. grup komutlar
    @Grup10Islev,           // aaa
{    @Grup01Islev,           // aas
    @Grup01Islev,           // cbw
    @Grup01Islev,           // cdq
    @Grup01Islev,           // cld
    @Grup01Islev,           // cli
    @Grup01Islev,           // cmc
    @Grup01Islev,           // cpuid
    @Grup01Islev,           // cwd
    @Grup01Islev,           // daa
    @Grup01Islev,           // das
    @Grup01Islev,           // emms
    @Grup01Islev,           // fabs
    @Grup01Islev,           // fchs
    @Grup01Islev,           // fclex
    @Grup01Islev,           // fcos
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
    @Grup01Islev,           // fsin
    @Grup01Islev,           // fsincos
    @Grup01Islev,           // fsqrt
    @Grup01Islev,           // ftst
    @Grup01Islev,           // fyl2x
    @Grup01Islev,           // fyl2xp1
    @Grup01Islev,           // fxam
    @Grup01Islev,           // fxtract
    @Grup01Islev,           // f2xm1
    @Grup01Islev,           // hlt
    @Grup01Islev,           // iret
    @Grup01Islev,           // iretd
    @Grup01Islev,           // lahf
    @Grup01Islev,           // leave
    @Grup01Islev,           // lock
    @Grup01Islev,           // popa
    @Grup01Islev,           // popad
    @Grup01Islev,           // popf
    @Grup01Islev,           // popfd
    @Grup01Islev,           // pusha
    @Grup01Islev,           // pushad
    @Grup01Islev,           // pushf
    @Grup01Islev,           // pushfd
    @Grup01Islev,           // rdtsc
    @Grup01Islev,           // rdtscp
    @Grup01Islev,           // stc
    @Grup01Islev,           // sti
    @Grup01Islev,           // wbinvd}

    // 2. grup komutlar
    @Grup11Islev,

    // 3. grup komutlar
    @Grup12Islev
  );

function KomutBilgisiAl(AKomut: string): TKomutDurum;
function KomutHata(ParcaNo: Integer; VeriKontrolTip: TVeriKontrolTip; Veri1: string;
  Veri2: QWord): Integer;

implementation

uses donusum;

// komut sıra değerini geri döndürür
// bilgi: ileri aşamalarda daha fazla bilgi döndürmek amacıyla KomutBilgisiAl
// adıyla isimlendirilmiştir
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
function KomutHata(ParcaNo: Integer; VeriKontrolTip: TVeriKontrolTip; Veri1: string;
  Veri2: QWord): Integer;
begin

  GHataAciklama := Veri1;
  Result := HATA_BILINMEYEN_KOMUT;
end;

end.
