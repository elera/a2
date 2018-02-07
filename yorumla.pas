{-------------------------------------------------------------------------------

  Dosya: yorumla.pas

  İşlev: verileri yorumlayan ve kodlara çeviren işlevleri içerir

  Güncelleme Tarihi: 07/02/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit yorumla;

interface

uses Classes, SysUtils, genel;

type
  TKomutDurum = record
    SiraNo: Integer;
    ABVT: TAnaBolumVeriTipi;
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
    ABVT: TAnaBolumVeriTipi;
  end;

{ assembler komut listesi }
const
  TOPLAM_KOMUT = 70;
  Komutlar: array[0..TOPLAM_KOMUT - 1] of TKomut = (
    (Komut: 'aaa';        ABVT: abvtIslemKodu),
    (Komut: 'aas';        ABVT: abvtIslemKodu),
    (Komut: 'cbw';        ABVT: abvtIslemKodu),
    (Komut: 'cdq';        ABVT: abvtIslemKodu),
    (Komut: 'cld';        ABVT: abvtIslemKodu),
    (Komut: 'cli';        ABVT: abvtIslemKodu),
    (Komut: 'cmc';        ABVT: abvtIslemKodu),
    (Komut: 'cpuid';      ABVT: abvtIslemKodu),
    (Komut: 'cwd';        ABVT: abvtIslemKodu),
    (Komut: 'daa';        ABVT: abvtIslemKodu),
    (Komut: 'das';        ABVT: abvtIslemKodu),
    (Komut: 'db';         ABVT: abvtTanim),
    (Komut: 'dd';         ABVT: abvtTanim),
    (Komut: 'dw';         ABVT: abvtTanim),
    (Komut: 'dq';         ABVT: abvtTanim),
    (Komut: 'emms';       ABVT: abvtIslemKodu),
    (Komut: 'fabs';       ABVT: abvtIslemKodu),
    (Komut: 'fchs';       ABVT: abvtIslemKodu),
    (Komut: 'fclex';      ABVT: abvtIslemKodu),
    (Komut: 'fcos';       ABVT: abvtIslemKodu),
    (Komut: 'fdecstp';    ABVT: abvtIslemKodu),
    (Komut: 'fincstp';    ABVT: abvtIslemKodu),
    (Komut: 'finit';      ABVT: abvtIslemKodu),
    (Komut: 'fldlg2';     ABVT: abvtIslemKodu),
    (Komut: 'fldln2';     ABVT: abvtIslemKodu),
    (Komut: 'fldpi';      ABVT: abvtIslemKodu),
    (Komut: 'fldz';       ABVT: abvtIslemKodu),
    (Komut: 'fldl2e';     ABVT: abvtIslemKodu),
    (Komut: 'fldl2t';     ABVT: abvtIslemKodu),
    (Komut: 'fld1';       ABVT: abvtIslemKodu),
    (Komut: 'fnclex';     ABVT: abvtIslemKodu),
    (Komut: 'fninit';     ABVT: abvtIslemKodu),
    (Komut: 'fnop';       ABVT: abvtIslemKodu),
    (Komut: 'fpatan';     ABVT: abvtIslemKodu),
    (Komut: 'fprem';      ABVT: abvtIslemKodu),
    (Komut: 'fprem1';     ABVT: abvtIslemKodu),
    (Komut: 'fptan';      ABVT: abvtIslemKodu),
    (Komut: 'frndint';    ABVT: abvtIslemKodu),
    (Komut: 'fscale';     ABVT: abvtIslemKodu),
    (Komut: 'fsin';       ABVT: abvtIslemKodu),
    (Komut: 'fsincos';    ABVT: abvtIslemKodu),
    (Komut: 'fsqrt';      ABVT: abvtIslemKodu),
    (Komut: 'ftst';       ABVT: abvtIslemKodu),
    (Komut: 'fyl2x';      ABVT: abvtIslemKodu),
    (Komut: 'fyl2xp1';    ABVT: abvtIslemKodu),
    (Komut: 'fxam';       ABVT: abvtIslemKodu),
    (Komut: 'fxtract';    ABVT: abvtIslemKodu),
    (Komut: 'f2xm1';      ABVT: abvtIslemKodu),
    (Komut: 'hlt';        ABVT: abvtIslemKodu),
    (Komut: 'int';        ABVT: abvtIslemKodu),
    (Komut: 'iret';       ABVT: abvtIslemKodu),
    (Komut: 'iretd';      ABVT: abvtIslemKodu),
    (Komut: 'lahf';       ABVT: abvtIslemKodu),
    (Komut: 'leave';      ABVT: abvtIslemKodu),
    (Komut: 'lock';       ABVT: abvtIslemKodu),
    (Komut: 'mov';        ABVT: abvtIslemKodu),
    (Komut: 'nop';        ABVT: abvtIslemKodu),
    (Komut: 'popa';       ABVT: abvtIslemKodu),
    (Komut: 'popad';      ABVT: abvtIslemKodu),
    (Komut: 'popf';       ABVT: abvtIslemKodu),
    (Komut: 'popfd';      ABVT: abvtIslemKodu),
    (Komut: 'pusha';      ABVT: abvtIslemKodu),
    (Komut: 'pushad';     ABVT: abvtIslemKodu),
    (Komut: 'pushf';      ABVT: abvtIslemKodu),
    (Komut: 'pushfd';     ABVT: abvtIslemKodu),
    (Komut: 'rdtsc';      ABVT: abvtIslemKodu),
    (Komut: 'rdtscp';     ABVT: abvtIslemKodu),
    (Komut: 'stc';        ABVT: abvtIslemKodu),
    (Komut: 'sti';        ABVT: abvtIslemKodu),
    (Komut: 'wbinvd';     ABVT: abvtIslemKodu));

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
  //    not: ParcaNo = 1, Veri2 değeri olarak komutun sıra numarasını döndürür
  // 2. VeriKontrolTip = işleve gönderilen veri tipini belirtir
  // 3. Veri1 = eğer varsa, karakter dizisi türünde veri
  // 4. Veri2 = eğer varsa, sayısal türde veri
  TAsmKomut = function(ParcaNo: Integer; VeriKontrolTip: TVeriKontrolTip; Veri1: string;
    Veri2: Integer): Integer;

function KomutBilgisiAl(AKomut: string): TKomutDurum;
function YazmacBilgisiAl(AYazmac: string): TYazmacDurum;
function KomutHata(ParcaNo: Integer; VeriKontrolTip: TVeriKontrolTip; Veri1: string;
  Veri2: Integer): Integer;
function GenelKomutSeti1(ParcaNo: Integer; VeriKontrolTip: TVeriKontrolTip; Veri1: string;
  Veri2: Integer): Integer;
function KomutINT(ParcaNo: Integer; VeriKontrolTip: TVeriKontrolTip; Veri1: string;
  Veri2: Integer): Integer;
function KomutMOV(ParcaNo: Integer; VeriKontrolTip: TVeriKontrolTip; Veri1: string;
  Veri2: Integer): Integer;
function GenelTanimlama(ParcaNo: Integer; VeriKontrolTip: TVeriKontrolTip; Veri1: string;
  Veri2: Integer): Integer;

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
    @GenelTanimlama,            // db
    @GenelTanimlama,            // dd
    @GenelTanimlama,            // dw
    @GenelTanimlama,            // dq
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
    @KomutINT,                  // int
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

uses anasayfa, incele, takip, donusum;

// ünite içi genel kullanımlık yerel değişkenler
var
  // ifadeyi yorumlayan işlevler tarafından kullanılan genel değişkenler
  VirgulKullanildi, ArtiIsleyiciKullanildi: Boolean;
  KoseliParantezSayisi: Integer;

// komut sıra değerini geri döndürür
// bilgi: ileri aşamalarda daha fazla bilgi döndürmek amacıyla KomutBilgisiAl
// adıyla isimlendirilmiştir
function KomutBilgisiAl(AKomut: string): TKomutDurum;
var
  i: Integer;
  Komut: string;
begin

  Komut := LowerCase(AKomut);

  Result.SiraNo := -1;
  for i := 0 to TOPLAM_KOMUT - 1 do
  begin

    if(Komutlar[i].Komut = Komut) then
    begin

      Result.ABVT := Komutlar[i].ABVT;
      Result.SiraNo := i;
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
function KomutHata(ParcaNo: Integer; VeriKontrolTip: TVeriKontrolTip; Veri1: string;
  Veri2: Integer): Integer;
begin

  GHataAciklama := Veri1;
  Result := HATA_BILINMEYEN_KOMUT;
end;

// tüm parametresiz komutların ortak çağrı işlevi
function GenelKomutSeti1(ParcaNo: Integer; VeriKontrolTip: TVeriKontrolTip; Veri1: string;
  Veri2: Integer): Integer;
begin

  if(VeriKontrolTip = vktIslemKodu) and (ParcaNo = 1) then
  begin

    GIslemKodAnaBolum += [ikabIslemKodu];
    GIslemKodu := Veri2;
    Result := 0;
  end
  else if(VeriKontrolTip = vktSon) then
  begin

    VerileriGoruntule;
    Result := 0;
  end
  else
  begin

    GHataAciklama := Veri1;
    Result := HATA_BEKLENMEYEN_IFADE;
  end
end;

// int komutu
function KomutINT(ParcaNo: Integer; VeriKontrolTip: TVeriKontrolTip; Veri1: string;
  Veri2: Integer): Integer;
begin

  if(VeriKontrolTip = vktIslemKodu) and (ParcaNo = 1) then
  begin

    GIslemKodAnaBolum += [ikabIslemKodu];
    GIslemKodu := Veri2;
    Result := 0;
  end
  else if(VeriKontrolTip = vktSayi) and (ParcaNo = 2) then
  begin

    GIKABVeriTipi1 := vtSayisalDeger;
    GIslemKodAyrinti := [ikaSabitDeger];
    GSabitDeger := Veri2;
    Result := 0;
  end
  else if(VeriKontrolTip = vktSon) then
  begin

    VerileriGoruntule;
    Result := 0;
  end
  else
  begin

    GHataAciklama := Veri1;
    Result := HATA_HATALI_KULLANIM;
  end;
end;

// mov komutu ve diğer ilgili en karmaşık komutların prototipi
function KomutMOV(ParcaNo: Integer; VeriKontrolTip: TVeriKontrolTip; Veri1: string;
  Veri2: Integer): Integer;
begin

  {frmAnaSayfa.mmDurumBilgisi.Lines.Add('Parça No: ' + IntToStr(ParcaNo));
  case VeriTipi of
    vtIslemKodu: frmAnaSayfa.mmDurumBilgisi.Lines.Add('VT IslemKodu: ' + Komutlar[Veri2].Komut);
    vtYazmac: frmAnaSayfa.mmDurumBilgisi.Lines.Add('VT Yazmaç: ' + Yazmaclar[Veri2].Ad);
    vtSayi: frmAnaSayfa.mmDurumBilgisi.Lines.Add('VT Sayı: ' + IntToStr(Veri2));
    vtVirgul: frmAnaSayfa.mmDurumBilgisi.Lines.Add('VT: vtVirgul');
    vtArti: frmAnaSayfa.mmDurumBilgisi.Lines.Add('VT: vtArti');
    vtKPAc: frmAnaSayfa.mmDurumBilgisi.Lines.Add('VT: vtKPAc');
    vtKPKapat: frmAnaSayfa.mmDurumBilgisi.Lines.Add('VT: vtKPKapat');
  end;}

  // ilk parça = işlem kodunun bulunduğu veri (opcode)
  // ilk parça ile birlikte Veri2 değeri de işlem kodunun sıra değerini içerir
  if(VeriKontrolTip = vktIslemKodu) then
  begin

    // işlem kodunun (opcode) her zaman 1. değer olarak gelmesi gerekmektedir
    if(ParcaNo <> 1) then

      Result := HATA_HATALI_KULLANIM
    else
    begin

      // işlem kodu ile ilgili ilk değer atamaları burada gerçekleştirilir
      GIslemKodAyrinti := [];
      GIslemKodAnaBolum += [ikabIslemKodu];
      GIslemKodu := Veri2;
      VirgulKullanildi := False;
      ArtiIsleyiciKullanildi := False;
      KoseliParantezSayisi := 0;
      GYazmacB1OlcekM := False;
      GYazmacB2OlcekM := False;
      Result := 0;
    end;
  end
  // ÖNEMLİ:
  // 1. GParametreTip1 ve GParametreTip2 değişkenlerine anasayfa'da ptYok olarak ilk değer atanıyor
  // 2. GParametreTip1 ve GParametreTip2 değişkenleri vtKPAc kısmında ptBellek olarak atama yapılıyor
  // 3. Köşeli parantez kontrolü vtKPAc sorgulama kısmında gerçekleştiriliyor
  // 4. Sabit sayısal değer (imm) ve ölçek değeri (scale) diğer sorgu aşamalarında atanmaktadır
  else if(VeriKontrolTip = vktYazmac) then
  begin

    if(ParcaNo = 2) then
    begin

      if(GIKABVeriTipi1 = vtYok) then GIKABVeriTipi1 := vtYazmac;

      if(GIKABVeriTipi1 = vtYazmac) then
      begin

        GYazmac1 := Veri2;
        GIslemKodAyrinti += [ikaIslemKodY1];
        Result := 0;
      end
      else
      begin

        if(ikaIslemKodB1 in GIslemKodAyrinti) then
        begin

          if(ikaIslemKodB2 in GIslemKodAyrinti) then
          begin

            Result := HATA_HATALI_KULLANIM
          end
          else
          begin

            GIslemKodAyrinti += [ikaIslemKodB2];
            GYazmacB2 := Veri2;
            Result := 0;
          end;
        end
        else
        begin

          GYazmacB1 := Veri2;
          GIslemKodAyrinti += [ikaIslemKodB1];
          Result := 0;
        end;
      end;
    end
    else if(ParcaNo = 3) then
    begin

      // 3. parça işlenmeden önce virgülün kullanılıp kullanılmadığı test edilmektedir
      if not VirgulKullanildi then
      begin

        Result := HATA_HATALI_ISL_KULLANIM;
      end
      else
      begin

        if(GIKABVeriTipi2 = vtYok) then GIKABVeriTipi2 := vtYazmac;

        if(GIKABVeriTipi2 = vtYazmac) then
        begin

          GYazmac2 := Veri2;
          GIslemKodAyrinti += [ikaIslemKodY2];
          Result := 0;
        end
        else
        begin

          if(ikaIslemKodB1 in GIslemKodAyrinti) then
          begin

            if(ikaIslemKodB2 in GIslemKodAyrinti) then
            begin

              Result := HATA_HATALI_KULLANIM
            end
            else
            begin

              GIslemKodAyrinti += [ikaIslemKodB2];
              GYazmacB2 := Veri2;
              Result := 0;
            end;
          end
          else
          begin

            GYazmacB1 := Veri2;
            GIslemKodAyrinti += [ikaIslemKodB1];
            Result := 0;
          end;
        end;
      end;
    end else Result := HATA_HATALI_KULLANIM;
  end
  else if(VeriKontrolTip = vktVirgul) then
  begin

    // virgül kullanılmadan önce:
    // 1. yazmaç değeri kullanılmamışsa
    // 2. sabit bellek değeri kullanılmamışsa
    // 3. ikinci kez virgül kullanılmışsa
    if not((ikaIslemKodY1 in GIslemKodAyrinti) or (ikaIslemKodB1 in GIslemKodAyrinti) or
      (ikaSabitDegerB in GIslemKodAyrinti)) then

      Result := HATA_YAZMAC_GEREKLI
    else if (VirgulKullanildi) then

      Result := HATA_HATALI_KULLANIM
    else
    begin

      VirgulKullanildi := True;
      Result := 0;
    end;
  end
  else if(VeriKontrolTip = vktKPAc) then
  begin

    // daha önce köşeli parantez kullanılmışsa
    if(KoseliParantezSayisi > 0) then

      Result := HATA_HATALI_KULLANIM
    // daha önce bellek adreslemede yazmaç veya bellek sabit değeri kullanılmışsa
    else if(ikaIslemKodB1 in GIslemKodAyrinti) or (ikaSabitDegerB in GIslemKodAyrinti) then

      Result := HATA_BELLEKTEN_BELLEGE
    else
    begin

      // ParcaNo = 2 = hedef alan, ParcaNo = 3 = kaynak alan
      if(ParcaNo = 2) then
        GIKABVeriTipi1 := vtBellek
      else if(ParcaNo = 3) then GIKABVeriTipi2 := vtBellek;

      Inc(KoseliParantezSayisi);
      Result := 0;
    end;
  end
  else if(VeriKontrolTip = vktKPKapat) then
  begin

    // açılan parantez sayısı kadar parantez kapatılmalıdır
    if(KoseliParantezSayisi < 1) then

      Result := HATA_HATALI_KULLANIM
    else
    begin

      Dec(KoseliParantezSayisi);
      Result := 0;
    end;
  end
  else if(VeriKontrolTip = vktArti) then
  begin

    // artı toplam değerinin kullanılması için tek bir köşeli parantez
    // açılması gerekmekte (bellek adresleme)
    if(KoseliParantezSayisi <> 1) then

      Result := HATA_HATALI_ISL_KULLANIM
    else
    begin

      ArtiIsleyiciKullanildi := True;
      Result := 0;
    end;
  end
  // ölçek (scale) - bellek adreslemede yazmaç ölçek değeri
  else if(VeriKontrolTip = vktOlcek) then
  begin

    if(ikaOlcek in GIslemKodAyrinti) then
    begin

      Result := HATA_OLCEK_ZATEN_KULLANILMIS;
    end
    else
    begin

      if(Veri2 = 1) or (Veri2 = 2) or (Veri2 = 4) or (Veri2 = 8) then
      begin

        GIslemKodAyrinti += [ikaOlcek];
        if(ArtiIsleyiciKullanildi) then

          GYazmacB2OlcekM := True
        else GYazmacB1OlcekM := True;

        GOlcek := Veri2;
        Result := 0;
      end
      else
      begin

        Result := HATA_HATALI_OLCEK_DEGER;
      end;
    end;
  end
  else if(VeriKontrolTip = vktSayi) then
  begin

    // ParcaNo 2 veya 3'ün bellek adreslemesi olması durumunda
    if(GIKABVeriTipi1 = vtBellek) or (GIKABVeriTipi2 = vtBellek) then
    begin

      if not(ikaSabitDegerB in GIslemKodAyrinti) then
      begin

        GIslemKodAyrinti += [ikaSabitDegerB];
        GSabitDeger := Veri2;
        Result := 0;
      end
      else
      begin

        Result := HATA_HATALI_KULLANIM;
      end;
    end
    else if(GIKABVeriTipi2 = vtYok) and (ParcaNo = 3) then
    begin

      GIKABVeriTipi2 := vtSayisalDeger;
      GIslemKodAyrinti += [ikaSabitDeger];
      GSabitDeger := Veri2;
      Result := 0;
    end else Result := HATA_HATALI_KULLANIM;
  end
  // son kontroller bu aşamada gerçekleştirilecek
  else if(VeriKontrolTip = vktSon) then
  begin

    VerileriGoruntule;
    //frmAnaSayfa.mmDurumBilgisi.Lines.Add('Son: ' + IntToStr(ParcaNo));
    Result := 0;
  end else Result := 1;
end;

var
  GSayiTipi: TSayiTipi;

function GenelTanimlama(ParcaNo: Integer; VeriKontrolTip: TVeriKontrolTip;
  Veri1: string; Veri2: Integer): Integer;
var
  SayiTipi: TSayiTipi;
begin

  if(VeriKontrolTip = vktTanim) then
  begin

    case Komutlar[Veri2].Komut of
      'db': GSayiTipi := st1B;
      'dw': GSayiTipi := st2B;
      'dd': GSayiTipi := st4B;
      'dq': GSayiTipi := st8B;
    end;
  end
  else if(VeriKontrolTip = vktSayi) then
  begin

    SayiTipi := SayiTipiniAl(Veri2);
    if(GSayiTipi >= SayiTipi) then
    begin

      case GSayiTipi of
        st1B: frmAnaSayfa.mmDurumBilgisi.Lines.Add('Sayı: ' + Format('%.2d', [Veri2]));
        st2B: frmAnaSayfa.mmDurumBilgisi.Lines.Add('Sayı: ' + Format('%.4d', [Veri2]));
        st4B: frmAnaSayfa.mmDurumBilgisi.Lines.Add('Sayı: ' + Format('%.8d', [Veri2]));
        st8B: frmAnaSayfa.mmDurumBilgisi.Lines.Add('Sayı: ' + Format('%.16d', [Veri2]));
      end;

      Result := 0;
    end else Result := HATA_HATALI_SAYISAL_DEGER;
  end else if(VeriKontrolTip = vktVirgul) then
  begin

    Result := 0;
  end;
end;

end.
