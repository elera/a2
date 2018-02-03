{-------------------------------------------------------------------------------

  Dosya: yorumla.pas

  İşlev: verileri yorumlayan ve kodlara çeviren işlevleri içerir

  Güncelleme Tarihi: 30/01/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit yorumla;

interface

uses Classes, SysUtils, genel;

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
  TOPLAM_KOMUT = 66;
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
    (Komut: 'int';      ),
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
  //    not: ParcaNo = 1, Veri2 değeri olarak komutun sıra numarasını döndürür
  // 2. VeriTipi = işleve gönderilen veri tipini belirtir
  // 3. Veri1 = eğer varsa, karakter dizisi türünde veri
  // 4. Veri2 = eğer varsa, sayısal türde veri
  TAsmKomut = function(ParcaNo: Integer; VeriTipi: TVeriTipi; Veri1: string;
    Veri2: Integer): Integer;

function KomutBilgisiAl(AKomut: string): TKomutDurum;
function YazmacBilgisiAl(AYazmac: string): TYazmacDurum;
function KomutHata(ParcaNo: Integer; VeriTipi: TVeriTipi; Veri1: string;
  Veri2: Integer): Integer;
function GenelKomutSeti1(ParcaNo: Integer; VeriTipi: TVeriTipi; Veri1: string;
  Veri2: Integer): Integer;
function KomutINT(ParcaNo: Integer; VeriTipi: TVeriTipi; Veri1: string;
  Veri2: Integer): Integer;
function KomutMOV(ParcaNo: Integer; VeriTipi: TVeriTipi; Veri1: string;
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

uses anasayfa, incele, takip;

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
function KomutHata(ParcaNo: Integer; VeriTipi: TVeriTipi; Veri1: string;
  Veri2: Integer): Integer;
begin

  GHataAciklama := Veri1;
  Result := HATA_BILINMEYEN_KOMUT;
end;

// tüm parametresiz komutların ortak çağrı işlevi
function GenelKomutSeti1(ParcaNo: Integer; VeriTipi: TVeriTipi; Veri1: string;
  Veri2: Integer): Integer;
begin

  if(VeriTipi = vtIslemKodu) and (ParcaNo = 1) then
  begin

    GIslemKodAnaBolum += [ikabIslemKodu];
    GIslemKodu := Veri2;
    Result := 0;
  end
  else if(VeriTipi = vtSon) then
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
function KomutINT(ParcaNo: Integer; VeriTipi: TVeriTipi; Veri1: string;
  Veri2: Integer): Integer;
begin

  if(VeriTipi = vtIslemKodu) and (ParcaNo = 1) then
  begin

    GIslemKodAnaBolum += [ikabIslemKodu];
    GIslemKodu := Veri2;
    Result := 0;
  end
  else if(VeriTipi = vtSayi) and (ParcaNo = 2) then
  begin

    GParametreTip1 := ptSayisalDeger;
    GIslemKodDegisken := [ikdSabitDeger];
    GSabitDeger := Veri2;
    Result := 0;
  end
  else if(VeriTipi = vtSon) then
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
function KomutMOV(ParcaNo: Integer; VeriTipi: TVeriTipi; Veri1: string;
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
  if(VeriTipi = vtIslemKodu) then
  begin

    // işlem kodunun (opcode) her zaman 1. değer olarak gelmesi gerekmektedir
    if(ParcaNo <> 1) then

      Result := HATA_HATALI_KULLANIM
    else
    begin

      // işlem kodu ile ilgili ilk değer atamaları burada gerçekleştirilir
      GIslemKodDegisken := [];
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
  else if(VeriTipi = vtYazmac) then
  begin

    if(ParcaNo = 2) then
    begin

      if(GParametreTip1 = ptYok) then GParametreTip1 := ptYazmac;

      if(GParametreTip1 = ptYazmac) then
      begin

        GYazmac1 := Veri2;
        GIslemKodDegisken := GIslemKodDegisken + [ikdIslemKodY1];
        Result := 0;
      end
      else
      begin

        if(ikdIslemKodB1 in GIslemKodDegisken) then
        begin

          if(ikdIslemKodB2 in GIslemKodDegisken) then
          begin

            Result := HATA_HATALI_KULLANIM
          end
          else
          begin

            GIslemKodDegisken := GIslemKodDegisken + [ikdIslemKodB2];
            GYazmacB2 := Veri2;
            Result := 0;
          end;
        end
        else
        begin

          GYazmacB1 := Veri2;
          GIslemKodDegisken := GIslemKodDegisken + [ikdIslemKodB1];
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

        if(GParametreTip2 = ptYok) then GParametreTip2 := ptYazmac;

        if(GParametreTip2 = ptYazmac) then
        begin

          GYazmac2 := Veri2;
          GIslemKodDegisken := GIslemKodDegisken + [ikdIslemKodY2];
          Result := 0;
        end
        else
        begin

          if(ikdIslemKodB1 in GIslemKodDegisken) then
          begin

            if(ikdIslemKodB2 in GIslemKodDegisken) then
            begin

              Result := HATA_HATALI_KULLANIM
            end
            else
            begin

              GIslemKodDegisken := GIslemKodDegisken + [ikdIslemKodB2];
              GYazmacB2 := Veri2;
              Result := 0;
            end;
          end
          else
          begin

            GYazmacB1 := Veri2;
            GIslemKodDegisken := GIslemKodDegisken + [ikdIslemKodB1];
            Result := 0;
          end;
        end;
      end;
    end else Result := HATA_HATALI_KULLANIM;
  end
  else if(VeriTipi = vtVirgul) then
  begin

    // virgül kullanılmadan önce:
    // 1. yazmaç değeri kullanılmamışsa
    // 2. sabit bellek değeri kullanılmamışsa
    // 3. ikinci kez virgül kullanılmışsa
    if not((ikdIslemKodY1 in GIslemKodDegisken) or (ikdIslemKodB1 in GIslemKodDegisken) or
      (ikdSabitDegerB in GIslemKodDegisken)) then

      Result := HATA_YAZMAC_GEREKLI
    else if (VirgulKullanildi) then

      Result := HATA_HATALI_KULLANIM
    else
    begin

      VirgulKullanildi := True;
      Result := 0;
    end;
  end
  else if(VeriTipi = vtKPAc) then
  begin

    // daha önce köşeli parantez kullanılmışsa
    if(KoseliParantezSayisi > 0) then

      Result := HATA_HATALI_KULLANIM
    // daha önce bellek adreslemede yazmaç veya bellek sabit değeri kullanılmışsa
    else if(ikdIslemKodB1 in GIslemKodDegisken) or (ikdSabitDegerB in GIslemKodDegisken) then

      Result := HATA_BELLEKTEN_BELLEGE
    else
    begin

      // ParcaNo = 2 = hedef alan, ParcaNo = 3 = kaynak alan
      if(ParcaNo = 2) then
        GParametreTip1 := ptBellek
      else if(ParcaNo = 3) then GParametreTip2 := ptBellek;

      Inc(KoseliParantezSayisi);
      Result := 0;
    end;
  end
  else if(VeriTipi = vtKPKapat) then
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
  else if(VeriTipi = vtArti) then
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
  else if(VeriTipi = vtOlcek) then
  begin

    if(ikdOlcek in GIslemKodDegisken) then
    begin

      Result := HATA_OLCEK_ZATEN_KULLANILMIS;
    end
    else
    begin

      if(Veri2 = 1) or (Veri2 = 2) or (Veri2 = 4) or (Veri2 = 8) then
      begin

        GIslemKodDegisken := GIslemKodDegisken + [ikdOlcek];
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
  else if(VeriTipi = vtSayi) then
  begin

    // ParcaNo 2 veya 3'ün bellek adreslemesi olması durumunda
    if(GParametreTip1 = ptBellek) or (GParametreTip2 = ptBellek) then
    begin

      if not(ikdSabitDegerB in GIslemKodDegisken) then
      begin

        GIslemKodDegisken := GIslemKodDegisken + [ikdSabitDegerB];
        GSabitDeger := Veri2;
        Result := 0;
      end
      else
      begin

        Result := HATA_HATALI_KULLANIM;
      end;
    end
    else if(GParametreTip2 = ptYok) and (ParcaNo = 3) then
    begin

      GParametreTip2 := ptSayisalDeger;
      GIslemKodDegisken := GIslemKodDegisken + [ikdSabitDeger];
      GSabitDeger := Veri2;
      Result := 0;
    end else Result := HATA_HATALI_KULLANIM;
  end
  // son kontroller bu aşamada gerçekleştirilecek
  else if(VeriTipi = vtSon) then
  begin

    VerileriGoruntule;
    //frmAnaSayfa.mmDurumBilgisi.Lines.Add('Son: ' + IntToStr(ParcaNo));
    Result := 0;
  end else Result := 1;
end;

end.
