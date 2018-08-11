{-------------------------------------------------------------------------------

  Dosya: kodlama.pas

  İşlev: oluşturulan kodları geçici belleğe yazma ve format oluşturma
    işlevlerini gerçekleştirir

  Güncelleme Tarihi: 30/04/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit kodlama;

{
  işlem kodu (opcode) atama olasılıkları
  1.1 - push  1		          ; sayısal değer

  1.2 - push  eax		        ; yazmaç
  işlev-1: YazmacKodla
  işlev-2: YazmacBirlestir

  1.3 - push  [eax]	        ; yazmaç ile bellek adresleme
  1.4 - push  [1234h]       ; sayısal değer ile bellek adresleme

  2.1 - mov   eax,123      ; sayısal değer
  işlev-1: YazmacKodla + SayisalDegerEkle

  2.2 - mov   eax,ebx		    ; yazmaç
  işlev-1: YazmacYazmacKodla

  2.3 - mov   eax,[ebx]	    ; yazmaç ile bellek adresleme
  2.4 - mov   eax,[1234h]   ; sayısal değer ile bellek adresleme

  3.1 - mov   [eax],1		    ; sayısal değer
  3.2 - mov   [eax],ebx	    ; yazmaç ile bellek adresleme
  3.3 - mov   [1234h],ebx	  ; sayısal değer ile bellek adresleme
}

interface

uses Classes, SysUtils, yazmaclar, onekler, donusum, paylasim, math, dosya;

const
  R_BX = 3;
  R_BP = 5;
  R_SI = 6;
  R_DI = 7;

  SD_8 = 1;
  SD_16 = 2;

const
  AdresTablolari: array[0..22] of Byte = (
    R_BX + R_SI,
    R_BX + R_DI,
    R_BP + R_SI,
    R_BP + R_DI,
    R_SI,
    R_DI,
    R_BX,

    R_BX + R_SI + SD_8,
    R_BX + R_DI + SD_8,
    R_BP + R_SI + SD_8,
    R_BP + R_DI + SD_8,
    R_SI + SD_8,
    R_DI + SD_8,
    R_BP + SD_8,
    R_BX + SD_8,

    R_BX + R_SI + SD_16,
    R_BX + R_DI + SD_16,
    R_BP + R_SI + SD_16,
    R_BP + R_DI + SD_16,
    R_SI + SD_16,
    R_DI + SD_16,
    R_BP + SD_16,
    R_BX + SD_16);

procedure KodBellekDegerleriniIlklendir;
function KodEkle(Kod: Byte): Boolean;
function KayanNoktaSayiDegeriniKodla(KayanNoktaSayi: string;
  SayiTipi: TVeriGenisligi): Integer;
function SayisalDegerKodla(ASayisalDeger: QWord; AVeriGenisligi: TVeriGenisligi = vgHatali): Integer;
function BellekAdresle1(IslemKodu, MODRMDegeri: Byte; SatirIcerik: TSatirIcerik): Integer;
function GoreceliDegerEkle(Komut: Integer; KomutIK: Byte): Integer;
function IslemKoduIleYazmacDegeriniBirlestir2(IK8, IKDiger, ModRMDeger: Byte; SI: TSatirIcerik): Integer;
function YazmacKodla(IsKod8, IsKodDiger, HedefYazmac, KaynakYazmac: Byte;
  SI: TSatirIcerik): Integer;
function YazmacBirlestir(IslemKodu, Yazmac: Byte; SatirIcerik: TSatirIcerik): Integer;
function IslemKoduVeYazmacDegeriniKodla2(IK8, IKDiger, ModRMDeger: Byte; SI: TSatirIcerik): Integer;
function SayisalDegerEkle(SayisalDeger: QWord; VeriGenisligi: TVeriGenisligi): Integer;

implementation

uses genel, asm2;

// kodların derlenerek yerleştirileceği belleği ilklendir
procedure KodBellekDegerleriniIlklendir;
begin

  KodBellekU := 0;
  BellekKapasitesi := KodBellekU;
  SetLength(KodBellek, KodBellekU);
  MevcutBellekAdresi := KodBellekU;
end;

function KodEkle(Kod: Byte): Boolean;
begin

  // bellek kapasitesi dolmuş ise. belleği artırmayı dene
  if(KodBellekU = BellekKapasitesi) then
  begin

    // eklenecek bellek azami dosya uzunluğundan büyük ise, olumsuz olarak işlevden çık
    if((BellekKapasitesi + BELLEK_BLOK_UZUNLUGU) > AZAMI_DOSYA_BOYUTU) then
    begin

      Result := False;
      Exit;
    end;

    // aksi durumda bellek kapasitesini blok uzunluğu kadar artır
    BellekKapasitesi += BELLEK_BLOK_UZUNLUGU;
    SetLength(KodBellek, BellekKapasitesi);
  end;

  // oluşturulan kodu bellek bölgesine yaz ve işaretçiyi bir artır
  KodBellek[KodBellekU] := Kod;
  Inc(KodBellekU);

  // MevcutBellekAdresi, adresleme işlemlerini yönetir
  Inc(MevcutBellekAdresi);
end;

function KayanNoktaSayiDegeriniKodla(KayanNoktaSayi: string;
  SayiTipi: TVeriGenisligi): Integer;
var
  KNSayi32: Single;
  KNSayi64: Double;
  KNSayi80: Extended;
  p: PByte;
  i: Integer;
begin

  if(SayiTipi = vgB4) then
  begin

    KNSayi32 := StrToFloat(StringReplace(KayanNoktaSayi, '.',  ',' ,[]));
    p := @KNSayi32;

    for i := 0 to 3 do begin KodEkle(p^); Inc(p); end;

    Result := HATA_YOK;
  end
  else if(SayiTipi = vgB8) then
  begin

    KNSayi64 := StrToFloat(StringReplace(KayanNoktaSayi, '.',  ',' ,[]));
    p := @KNSayi64;

    for i := 0 to 7 do begin KodEkle(p^); Inc(p); end;

    Result := HATA_YOK;
  end
  { TODO : 80 bitlik veri hatalı kodlanıyor, çözümlenecek. }
  else if(SayiTipi = vgB10) then
  begin

    KNSayi80 := StrToFloat(StringReplace(KayanNoktaSayi, '.',  ',' ,[]));
    p := @KNSayi80;

    for i := 0 to 9 do begin KodEkle(p^); Inc(p); end;

    Result := HATA_YOK;
  end else Result := HATA_VERI_TIPI;
end;

function SayisalDegerKodla(ASayisalDeger: QWord; AVeriGenisligi: TVeriGenisligi = vgHatali): Integer;
var
  SayisalDeger: QWord;
  VeriGenisligi: TVeriGenisligi;
  i, iVeriGenisligi: Integer;
begin

  SayisalDeger := ASayisalDeger;

  // veri genişiliği belirlenmemişse, veri genişliğini belirle
  if(AVeriGenisligi = vgHatali) then
  begin

    VeriGenisligi := SayiTipiniAl(ASayisalDeger);
  end
  else
  begin

    VeriGenisligi := AVeriGenisligi;
  end;

  // veri genişliği hatalı ise hata kodu ile işlevden çık
  if(VeriGenisligi = vgHatali) then
  begin

    Result := HATA_VERI_TIPI;
    Exit;
  end;

  case VeriGenisligi of
    vgB1: begin iVeriGenisligi := 1; end;
    vgB2: begin iVeriGenisligi := 2; end;
    vgB4: begin iVeriGenisligi := 4; end;
    vgB8: begin iVeriGenisligi := 8; end;
  end;

  // sayısal veriyi belleğe yaz
  for i := 1 to iVeriGenisligi do
  begin

    KodEkle(Byte(SayisalDeger));
    SayisalDeger := SayisalDeger shr 8;
  end;

  Result := HATA_YOK;
end;

// [...] içeriğindeki adresleme için kullanılan öndeğerleri yönetir.
// 1. tek öndeğere sahip yazmaçların bellek adreslenmesi tamamlandı
// 2. birden fazla yazmacın bellek adreslenmesi gerçekleştirilecek
// 3. yazmaç + sayısaldeğer, yazmaç + ölçek bellek adreslemesi gerçekleştirilecek
function BellekAdresle1(IslemKodu, MODRMDegeri: Byte; SatirIcerik: TSatirIcerik): Integer;
var
  i: Byte;

  procedure IslemKoduEkle;
  begin

    if(GSabitDegerVG = vgB1) then
    begin

      KodEkle(IslemKodu);
    end else KodEkle(IslemKodu + 1);
  end;
begin

  if(SatirIcerik.BolumTip1.BolumAnaTip = batBellek) then
  begin

    // bellek adreslemede 2 yazmaç kullanılmışsa
    if((baBellekYazmac1 in SatirIcerik.BolumTip1.BolumAyrinti) and
      (baBellekYazmac2 in SatirIcerik.BolumTip1.BolumAyrinti)) then
    begin


    end
    else
    // aksi durumda tek bir yazmaç kullanılmıştır
    begin

      // sayısal değer kontrolü burada yapılacak
      if(baBellekSabitDeger in SatirIcerik.BolumTip1.BolumAyrinti) then
      begin

        IslemKoduEkle;
        KodEkle($05);
        { TODO : 4 bytelık veri olarak belirlenmiştir. diğer veri tipleri de incelensin}
        Result := SayisalDegerKodla(GBellekSabitDeger, vgB4);
      end
      // 1. 32 bitlik yazmaç adresleme
      else if(YazmacListesi[GYazmac1].Uzunluk = yu32bGY) then
      begin

        // ayrıntılar eklenecek - sayısal değer gerekebilir
        if(YazmacListesi[GYazmac1].Ad = 'esp') then
        begin

          IslemKoduEkle;
          KodEkle($04);
          KodEkle($24);
          Result := HATA_YOK;
        end
        // ebp yazmacının öndeğer alması gerekmektedir. [ebp+0] gibi
        else if(YazmacListesi[GYazmac1].Ad = 'ebp') then
        begin

          Result := HATA_ISL_KOD_KULLANIM;
        end
        else
        // 32 bir mimari - 32 bit yazmaç
        // 64 bit mimari - 64 bit yazmaç
        // kontrol durumları
        // 1. sadece yazmaç değer kontrolü

        // 1.1 32 bit mimari 32 bit yazmaç - mevcut çalışma budur!!!
        // 1.2.1 64 bit mimari 32 bit yazmaç
        // 1.2.2 64 bit mimari 64 bit yazmaç

        // 32 bit genel yazmaçlar kodlandı. Tamam!
        // 64 bitlik mimarinin 32 bitlik yazmaçlarının kodlanması

        // esp / rsp ve ebp / rbp yazmaçları haricindeki diğer yazmaçların kodlaması
        begin

          // 32 bitlik yazmaçların kodlanması
          if(YazmacListesi[GYazmac1].DesMim = dmTum) then
          begin

            // mimarinin 16 bit, yazmaçların 32 bit olması durumunda
            if(GAktifDosya.Mimari = mim16Bit) then
            begin

              KodEkle($67);
              KodEkle($66);
            end
            // mimarinin 64 bit, yazmaçların 32 bit olması durumunda
            else if(GAktifDosya.Mimari = mim64Bit) then KodEkle($67);

            IslemKoduEkle;
            KodEkle((MODRMDegeri shl 3) or YazmacListesi[GYazmac1].Deger);
            Result := HATA_YOK;
          end
          // 32 / 64 bitlik yazmaçların kodlanması
          else if(YazmacListesi[GYazmac1].DesMim = dm64Bit) then
          begin

            // mimarinin 16 bit, yazmaçların 32 bit olması durumunda
            if(GAktifDosya.Mimari = mim64Bit) then
            begin

              KodEkle($67);
              KodEkle($41);

              IslemKoduEkle;
              KodEkle((MODRMDegeri shl 3) or (YazmacListesi[GYazmac1].Deger - 8));
              Result := HATA_YOK;
            end else Result := HATA_ISL_KOD_KULLANIM;
          end;
        end;
      end
      // 2. 64 bitlik yazmaç adresleme
      else if(YazmacListesi[GYazmac1].Uzunluk = yu64bGY) then
      begin

        if(YazmacListesi[GYazmac1].Deger > 7) then
        begin

          KodEkle($41);
          i := 8 - YazmacListesi[GYazmac1].Deger;
        end else i := YazmacListesi[GYazmac1].Deger;

        IslemKoduEkle;
        KodEkle((MODRMDegeri shl 3) or i);
        Result := HATA_YOK;
      end;
    end;
  end;
end;

// KomutIK = Komut İşlem Kodu
{ TODO : göreceli değer hesaplamada
  1. kapsayıcı metot, 2. 16 bitlik göreceli değerlerin eklenmesi sağlanacaktır }
function GoreceliDegerEkle(Komut: Integer; KomutIK: Byte): Integer;
var
  ii: Integer;
begin

  // ÖNEMLİ: tüm göreceli (relative) yönlendirmeler burada yapılacaktır.
  // işlem kodları en üst değer olmaktan çıkarılarak yerine
  // öndeğer (parametre) önceliği yerleştirilecektir

  // bu komutlar bir komut grubu olup, bulunulan konumdan kaç adım ileri veya
  // geri (relative) adrese dallanma yapılacağını bildirir
  // not: şu aşamada 8 bitlik katı kodlama uygulanmıştır
  if(GSabitDeger < (MevcutBellekAdresi + 2)) then
    ii := -((MevcutBellekAdresi + 2) - GSabitDeger)
  else ii := GSabitDeger - (MevcutBellekAdresi + 2);

  KodEkle(KomutIK);
  KodEkle(ii);
  Result := HATA_YOK;
end;

// bu işlev iptal edilecektir

// 2.1 - mov   eax,1
// $B8+ rw iw
function IslemKoduIleYazmacDegeriniBirlestir2(IK8, IKDiger, ModRMDeger: Byte; SI: TSatirIcerik): Integer;
begin

  if(YazmacListesi[GYazmac1].Uzunluk = yu8bGY) then
  begin

    KodEkle(IK8 + (ModRMDeger shl 3) or (YazmacListesi[GYazmac1].Deger and 7));
    Result := HATA_YOK;
  end
  else if(YazmacListesi[GYazmac1].Uzunluk = yu16bGY) then
  begin

    KodEkle(IKDiger + (ModRMDeger shl 3) or (YazmacListesi[GYazmac1].Deger and 7));
    Result := HATA_YOK;
  end
  else if(YazmacListesi[GYazmac1].Uzunluk = yu32bGY) then
  begin

    if(YazmacListesi[GYazmac1].DesMim = dm64Bit) then KodEkle($41);

    KodEkle(IKDiger + (ModRMDeger shl 3) or (YazmacListesi[GYazmac1].Deger and 7));
    Result := HATA_YOK;
  end
  else if(YazmacListesi[GYazmac1].Uzunluk = yu64bGY) then
  begin

    if(YazmacListesi[GYazmac1].Deger > 7) then
      KodEkle($4C)
    else KodEkle($48);

    KodEkle(IKDiger);
    KodEkle($C0 + (ModRMDeger shl 3) or (YazmacListesi[GYazmac1].Deger and 7));
    Result := HATA_YOK;
  end;
end;

// YazmacKodla:
// örnek kod: not eax
// örnek işlem kodu: REX + F6 /2
// IsKod8 = 8 bitlik işlem kodu
// IsKodDiger = 8 bit haricindeki işlem kodu
// KaynakYazmac = işlem kodundaki /x değeri (mod r/m değeri)
// HedefYazmac = kullanılan yazmaç değeri
function YazmacKodla(IsKod8, IsKodDiger, HedefYazmac, KaynakYazmac: Byte;
  SI: TSatirIcerik): Integer;
begin

  if(YazmacListesi[HedefYazmac].Uzunluk = yu8bGY) then
  begin

    if(YazmacListesi[HedefYazmac].DesMim = dmTum) then
    begin

      KodEkle(IsKod8);
      KodEkle($C0 + (YazmacListesi[KaynakYazmac].Deger shl 3) or
        (YazmacListesi[HedefYazmac].Deger and 7));
      Result := HATA_YOK;
    end
    else
    // 64 bitlik mimarinin 8 bitlik yazmaçları
    begin

      if(GAktifDosya.Mimari = mim64Bit) then
      begin

        if((YazmacListesi[HedefYazmac].Ad = 'spl') or (YazmacListesi[HedefYazmac].Ad = 'bpl') or
          (YazmacListesi[HedefYazmac].Ad = 'sil') or (YazmacListesi[HedefYazmac].Ad = 'dil')) then
          KodEkle($40)
        else KodEkle($41);

        KodEkle(IsKod8);
        KodEkle($C0 + (YazmacListesi[KaynakYazmac].Deger shl 3) or
          ((YazmacListesi[HedefYazmac].Deger - 8) and 7));
        Result := HATA_YOK;
      end else Result := HATA_64BIT_MIMARI_GEREKLI;
    end;
  end
  else if(YazmacListesi[HedefYazmac].Uzunluk = yu16bGY) then
  begin

    if(YazmacListesi[HedefYazmac].DesMim = dmTum) then
    begin

      if not(GAktifDosya.Mimari = mim16Bit) then KodEkle($66);

      KodEkle(IsKodDiger);
      KodEkle($C0 + (YazmacListesi[KaynakYazmac].Deger shl 3) or
        (YazmacListesi[HedefYazmac].Deger and 7));
      Result := HATA_YOK;
    end
    else
    // 64 bitlik mimarinin 8 bitlik yazmaçları
    begin

      if(GAktifDosya.Mimari = mim64Bit) then
      begin

        KodEkle($66);
        KodEkle($41);

        KodEkle(IsKodDiger);
        KodEkle($C0 + (YazmacListesi[KaynakYazmac].Deger shl 3) or
          ((YazmacListesi[HedefYazmac].Deger - 8) and 7));
        Result := HATA_YOK;
      end else Result := HATA_64BIT_MIMARI_GEREKLI;
    end;
  end
  else if(YazmacListesi[HedefYazmac].Uzunluk = yu32bGY) then
  begin

    if(YazmacListesi[HedefYazmac].DesMim = dmTum) then
    begin

      if(GAktifDosya.Mimari = mim16Bit) then KodEkle($66);

      KodEkle(IsKodDiger);
      KodEkle($C0 or (YazmacListesi[KaynakYazmac].Deger shl 3) or
        (YazmacListesi[HedefYazmac].Deger and 7));
      Result := HATA_YOK;
    end
    else
    // 64 bitlik mimarinin 8 bitlik yazmaçları
    begin

      if(GAktifDosya.Mimari = mim64Bit) then
      begin

        KodEkle($41);

        KodEkle(IsKodDiger);
        KodEkle($C0 + (YazmacListesi[KaynakYazmac].Deger shl 3) or
          ((YazmacListesi[HedefYazmac].Deger - 8) and 7));
        Result := HATA_YOK;
      end else Result := HATA_64BIT_MIMARI_GEREKLI;
    end;
  end
  else if(YazmacListesi[HedefYazmac].Uzunluk = yu64bGY) then
  begin

    if(YazmacListesi[HedefYazmac].Deger > 7) then
    begin

      KodEkle($49);
      KodEkle(IsKodDiger);
      KodEkle($C0 + (YazmacListesi[KaynakYazmac].Deger shl 3) or
        (YazmacListesi[HedefYazmac].Deger and 7));
    end
    else
    begin

      KodEkle($48);
      KodEkle(IsKodDiger);
      KodEkle($C0 + (YazmacListesi[KaynakYazmac].Deger shl 3) or
        ((YazmacListesi[HedefYazmac].Deger - 8) and 7));
    end;

    Result := HATA_YOK;
  end;
end;

// işlev tamamlanmadı
// push r32 -> 50+rd kodlama işlemlerini yönetir
function YazmacBirlestir(IslemKodu, Yazmac: Byte; SatirIcerik: TSatirIcerik): Integer;
var
  DesMim1, DesMim2: TDestekleyenMimari;
  i: Byte;
begin

  // 64 bitlik işlem kodları yalnızca 64 bitlik mimaride kullanılabilir
  if(GAktifDosya.Mimari <> mim64Bit) and (YazmacListesi[Yazmac].Uzunluk = yu64bGY) then
  begin

    Result := HATA_64BIT_MIMARI_GEREKLI;
    Exit;
  end;

  // derlenecek kod mimarisi 64 bit ise...
  {if(GAsm2.Mimari = mim64Bit) and (YazmacListesi[Yazmac].Uzunluk = yu64bGY) then

    // 0100W000 = W = 1 = 64 bit işlem kodu
    KodEkle($48)}

  // derlenecek kod mimarisi 32 bit, yazmaç 32 bit değilse...
  // 66 ön ekini kodun başına ekle
  if(GAktifDosya.Mimari = mim32Bit) and (YazmacListesi[Yazmac].Uzunluk <> yu32bGY) then

    KodEkle($66)

  // derlenecek kod mimarisi 16 bit, yazmaç 16 bit değilse...
  else if(GAktifDosya.Mimari = mim16Bit) and (YazmacListesi[Yazmac].Uzunluk <> yu16bGY) then

    KodEkle($66);

  DesMim1 := YazmacListesi[Yazmac].DesMim;

  KodEkle(IslemKodu + (YazmacListesi[Yazmac].Deger and 7));
  Result := HATA_YOK;
end;

// 2.2 - mov   eax,ebx
// $8A /r
function IslemKoduVeYazmacDegeriniKodla2(IK8, IKDiger, ModRMDeger: Byte; SI: TSatirIcerik): Integer;
begin

  if(YazmacListesi[GYazmac1].Uzunluk = yu8bGY) and (YazmacListesi[GYazmac2].Uzunluk = yu8bGY) then
  begin

    KodEkle(IK8);
    KodEkle($C0 + (ModRMDeger shl 3) or (YazmacListesi[GYazmac1].Deger and 7));
    Result := HATA_YOK;
  end
  {if(YazmacListesi[GYazmac1].Uzunluk = yu8bGY) then
  begin

    KodEkle(IK8 + (YazmacListesi[GYazmac1].Deger and 7));
    Result := HATA_YOK;
  end
  else if(YazmacListesi[GYazmac1].Uzunluk = yu16bGY) then
  begin

    KodEkle(IK8 + (YazmacListesi[GYazmac1].Deger and 7));
    Result := HATA_YOK;
  end
  else if(YazmacListesi[GYazmac1].Uzunluk = yu32bGY) then
  begin

    if(YazmacListesi[GYazmac1].DesMim = dm64Bit) then KodEkle($41);

    KodEkle(IKDiger + (YazmacListesi[GYazmac1].Deger and 7));
    Result := HATA_YOK;
  end;}


  else if(YazmacListesi[GYazmac1].Uzunluk = yu64bGY) then
  begin

    if(YazmacListesi[GYazmac1].Deger > 7) then
      KodEkle($4C)
    else KodEkle($48);

    KodEkle(IKDiger);
    KodEkle($C0 + (ModRMDeger shl 3) or (YazmacListesi[GYazmac1].Deger and 7));
    Result := HATA_YOK;
  end;
end;

// SayisalDeger = kodlanacak sayısal değer
// VG = SayisalDeger'in olması gereken veri türü
function SayisalDegerEkle(SayisalDeger: QWord; VeriGenisligi: TVeriGenisligi): Integer;
var
  VG: TVeriGenisligi;
  i, j: Integer;
begin

  VG := SayiTipiniAl(SayisalDeger);
  if(VG > VeriGenisligi) or (VG = vgHatali) then
  begin

    Result := HATA_SAYISAL_DEGER;
  end
  else
  begin

    case VeriGenisligi of
      vgB1: begin j := 1; end;
      vgB2: begin j := 2; end;
      vgB4: begin j := 4; end;
      vgB8: begin j := 8; end;
    end;

    // sayısal veriyi belleğe yaz
    for i := 1 to j do
    begin

      KodEkle(Byte(SayisalDeger));
      SayisalDeger := SayisalDeger shr 8;
    end;

    Result := HATA_YOK;
  end;
end;

// çok önemli: göreceli değerlerle işlem yapılırken ilgili komut bir sonraki
// adresi hesaplayamayacağından dolayı en az iki çevrim yapılması gerekmektedir
// kısaca: birinci aşamada sanal (ama gerçek uzunlukta) veri üretildikten sonra
// 2. aşamada gerçek kodlama gerçekleştirilecektir.
procedure GoreceliDegerEkle2;
var
  SayiTipi: TVeriGenisligi;
  SayisalVeri, VeriGenisligi, i: Integer;
  ii: Byte;
  i4: Integer;
begin

  SayiTipi := SayiTipiniAl(SayisalVeri);

  // eğer önek sayı değerinden büyükse sayı değerinin veri
  // genişliğini önek olarak ayarla
  if(GSabitDegerVG > SayiTipi) then SayiTipi := GSabitDegerVG;

  case SayiTipi of
    vgB1: ii := 1;
    vgB2: ii := 2;
    vgB4: ii := 4;
    vgB8: ii := 8;
  end;

  // bu komutlar bir komut grubu olup, bulunulan konumdan kaç adım ileri veya
  // geri (relative) adrese dallanma yapılacağını bildirir
  // not: şu aşamada 8 bitlik katı kodlama uygulanmıştır
  if(GSabitDeger < (MevcutBellekAdresi - 1)) then
    SayisalVeri := -((MevcutBellekAdresi - 1) - GSabitDeger)
  else SayisalVeri := GSabitDeger - (MevcutBellekAdresi - 1);

  SayiTipi := SayiTipiniAl(SayisalVeri);

  // eğer önek sayı değerinden büyükse sayı değerinin veri
  // genişliğini önek olarak ayarla
  if(GSabitDegerVG > SayiTipi) then SayiTipi := GSabitDegerVG;

  case SayiTipi of
    vgB1: ii := 1;
    vgB2: ii := 2;
    vgB4: ii := 4;
    vgB8: ii := 8;
  end;

  for i := 1 to ii do
  begin

    KodEkle(Byte(SayisalVeri));
    SayisalVeri := SayisalVeri shr 8;
  end;
end;

end.
