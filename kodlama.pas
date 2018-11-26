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
function IslemKodlariniIsle(ParcaSonuc: TParcaSonuc): Integer;
function KayanNoktaSayiDegeriniKodla(KayanNoktaSayi: string;
  SayiTipi: TVeriGenisligi): Integer;
function SayisalDegerKodla(ASayisalDeger: QWord; AVeriGenisligi: TVeriGenisligi = vgHatali): Integer;
function BellekAdresle(IsKod8, IsKodDiger, MODRMDegeri: Byte; SI:
  TSatirIcerik): Integer;
function GoreceliDegerEkle(Komut: Integer; KomutIK: Byte): Integer;
function IslemKoduIleYazmacDegeriniBirlestir(IsKod8, IsKodDiger, Yazmac: Byte): Integer;
function IslemKoduIleYazmacDegeriniBirlestir2(IK8, IKDiger, ModRMDeger: Byte; SI: TSatirIcerik): Integer;
function YazmacKodla(IsKod8, IsKodDiger, HedefYazmac, KaynakYazmac: Byte;
  SI: TSatirIcerik): Integer;
function YazmacaBellekBolgesiAta(YazmacaBB: Boolean; IsKod8, IsKodDiger: Byte): Integer;
function SayisalDegerEkle(SayisalDeger: QWord; VeriGenisligi: TVeriGenisligi): Integer;
function BellekBolgesineYazmacAta(SI: TSatirIcerik; Yazmac1,
  Yazmac2: Integer): Integer;
function BellekBolgesineSayisalDegerAta(SI: TSatirIcerik; Yazmac1,
  Yazmac2: Integer): Integer;

implementation

uses genel, asm2, dbugintf, hataayiklama;

var
  // IslemKodlariniIsle işlevi tarafından süreklilik (parça takibi) için kullanılmaktadır
  BT: PBolumTip = nil;

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

  // ikili dosya biçimine sahip verileri kodla
  if(GAsm2.Derleyici.Bicim = dbIkili) then
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
  end
  { TODO : diğer formattaki dosyalar çoklu bölümler halinde burada kodlanacak }
  else Result := False;
end;

function IslemKodlariniIsle(ParcaSonuc: TParcaSonuc): Integer;
var
  i, i4: Integer;
  VG: TVeriGenisligi;
  procedure BTVerileriniSifirla(_BT: PBolumTip);
  begin

    _BT^.BolumAnaTip := batYok;
    _BT^.BellekIcerik := [];
  end;
begin

  if(SI.BolumNo = 0) then
  begin

    SI.BolumNo := 1;
    BT := @SI.B1;
    BTVerileriniSifirla(BT);
  end;

  {if(((SI.B1.BolumAnaTip = batYok) or (SI.B1.BolumAnaTip = batBellek)) and
    not(GVirgulKullanildi)) then BT := @SI.B1
  else if(((SI.B2.BolumAnaTip = batYok) or (SI.B2.BolumAnaTip = batBellek)) and
    (GVirgulKullanildi)) then BT := @SI.B2
  else if(((SI.B3.BolumAnaTip = batYok) or (SI.B3.BolumAnaTip = batBellek)) and
    (GVirgulKullanildi)) then BT := @SI.B3
  else BT := nil;}

  // ÖNEMLİ:
  // 1. .BolumTip1, .BolumTip2 ve .BolumTip3 alt yapılarına anasayfa'da batYok değeri atanmaktadır
  // 2. .BolumTip1, .BolumTip2 ve .BolumTip3 alt yapılarına vtKPAc kısmında batBellek tipi atanmaktadır
  // 3. Köşeli parantez kontrolü vtKPAc sorgulama kısmında gerçekleştiriliyor
  // 4. Sabit sayısal değer (imm) ve ölçek değeri (scale) diğer sorgu aşamalarında atanmaktadır
  if(ParcaSonuc.ParcaTipi = ptVeri) and (ParcaSonuc.VeriTipi = vYazmac) then
  begin

    if(BT = nil) then
    begin

      Result := HATA_ISL_KOD_KULLANIM;
      Exit;
    end;

    //  örnek: işlemkodu B1, B2, B3

    //GVirgulKullanildi := False;

    if(BT^.BolumAnaTip = batYok) then
    begin

      BT^.BolumAnaTip := batYazmac;
      BT^.Yazmac := ParcaSonuc.SiraNo;
      Result := HATA_YOK;
    end
    // bellek yazmaç bildirimlerinin hangi alana yapılacağı kontrolü
    // bu aşamada değil; son aşamada gerçekleştirilecektir
    else if(BT^.BolumAnaTip = batBellek) then
    begin

      if(biYazmac1 in BT^.BellekIcerik) then
      begin

        if(biYazmac2 in BT^.BellekIcerik) then
        begin

          Result := HATA_ISL_KOD_KULLANIM
        end
        else
        begin

          BT^.BellekIcerik += [biYazmac2];
          BT^.YazmacB2 := ParcaSonuc.SiraNo;
          Result := HATA_YOK;
        end;
      end
      else
      begin

        BT^.YazmacB1 := ParcaSonuc.SiraNo;
        BT^.BellekIcerik += [biYazmac1];
        Result := HATA_YOK;
      end;
    end else Result := HATA_ISL_KULLANIM;
  end
  else if(ParcaSonuc.ParcaTipi = ptIslem) and (ParcaSonuc.IslemTipi = iVirgul) then
  begin

    // işlem kodundan sonra veya 3. (son) bölümden sonra , gelmişse
    if(SI.BolumNo = 0) or (SI.BolumNo = 3) then
    begin

      Result := HATA_ISL_KOD_KULLANIM;
    end
    // mevcut bölüm tipine hiç atama yapılmamışsa
    else if(BT^.BolumAnaTip = batYok) then
    begin

      Result := HATA_ISL_KOD_KULLANIM;
    end
    else
    begin

      Inc(SI.BolumNo);
      case SI.BolumNo of
        //1: BT := @SI.B1;  // 1. atama işlevin en üst kısmında yapılmaktadır
        2: begin BT := @SI.B2; BTVerileriniSifirla(BT); end;
        3: begin BT := @SI.B3; BTVerileriniSifirla(BT); end;
      end;

      Result := HATA_YOK;
    end;
  end
  // tamamlanmadı
  else if(ParcaSonuc.ParcaTipi = ptIslem) and (ParcaSonuc.IslemTipi = iTopla) then
  begin

    Result := HATA_YOK;
  end
  else if(ParcaSonuc.ParcaTipi = ptIslem) and (ParcaSonuc.IslemTipi = iKPAc) then
  begin

    // daha önce köşeli parantez kullanılmışsa
    if(KoseliParantezSayisi > 0) then

      Result := HATA_ISL_KOD_KULLANIM
    else
    begin

      // bu kodlar daha yüksek mantıkla güçlendirilmeli
      if(SI.B1.BolumAnaTip = batYok) then SI.B1.BolumAnaTip := batBellek
      else if(SI.B2.BolumAnaTip = batYok) then SI.B2.BolumAnaTip := batBellek
      else if(SI.B3.BolumAnaTip = batYok) then SI.B3.BolumAnaTip := batBellek;

      Inc(KoseliParantezSayisi);
      Result := HATA_YOK;
    end;
  end
  else if(ParcaSonuc.ParcaTipi = ptIslem) and (ParcaSonuc.IslemTipi = iKPKapat) then
  begin

    // açılan parantez sayısı kadar parantez kapatılmalıdır
    if(KoseliParantezSayisi < 1) then

      Result := HATA_ISL_KOD_KULLANIM
    else
    begin

      Dec(KoseliParantezSayisi);
      Result := HATA_YOK;
    end;
  end
  {else if(VeriKontrolTip = vktKarakterDizisi) then
  begin

    Result := HATA_DEVAM_EDEN_CALISMA;
  end   }
  else if(ParcaSonuc.ParcaTipi = ptVeri) and (ParcaSonuc.VeriTipi = vSayi) then
  begin

    if(BT^.BolumAnaTip = batYok) then
    begin

      BT^.BolumAnaTip := batSayisalDeger;
      BT^.SabitDeger := ParcaSonuc.VeriSD;
      Result := HATA_YOK;
    end else if(BT^.BolumAnaTip = batBellek) then
    begin

      BT^.BellekIcerik += [biSabitDeger];
      BT^.SabitDeger := ParcaSonuc.VeriSD;
      Result := HATA_YOK;
    end else Result := HATA_ISL_KOD_KULLANIM;
  end
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

// çalışma, şu aşamada tek değişkenli (g11islev) işlevlerin alt yapısını içerir
// [...] içeriğindeki adresleme için kullanılan öndeğerleri yönetir.
// 1. tek öndeğere sahip yazmaçların bellek adreslenmesi tamamlandı
// 2. birden fazla yazmacın bellek adreslenmesi gerçekleştirilecek
// 3. yazmaç + sayısaldeğer, yazmaç + ölçek bellek adreslemesi gerçekleştirilecek
function BellekAdresle(IsKod8, IsKodDiger, MODRMDegeri: Byte; SI:
  TSatirIcerik): Integer;
var
  KodDeger, i: Byte;
  VG: TVeriGenisligi;

  procedure IslemKoduEkle;
  begin

    if(GSabitDegerVG = vgB1) then
    begin

      KodEkle(IsKod8);
    end else KodEkle(IsKodDiger);
  end;
begin

  // 8 ve 16 bitlik sabit değer atamaları da eklenecek

  // bellek içeriğinde SADECE sayısal değer var ise...
  if(biSabitDeger in SI.B1.BellekIcerik) then
  begin

    VG := SayiTipiniAl(SI.B1.SabitDeger);

    if(VG = vgB2) then
    begin

      KodEkle(IsKodDiger);
      KodEkle((MODRMDegeri shl 3) or 6);
      SayisalDegerEkle(SI.B1.SabitDeger, VG);
      Result := HATA_YOK;
    end;
  end
  // 16 bitlik genel yazmaç bellek adreslemesi
  else if(YazmacListesi[SI.B1.YazmacB1].Uzunluk = yu16bGY) then
  begin

    // KodDeger değişkeninin
    // 7..4 bit = 1. bellek yazmacı
    // 3..0 bit = 2. bellek yazmacı
    KodDeger := 0;
    case YazmacListesi[SI.B1.YazmacB1].Ad of
      'bx': KodDeger := (3 shl 4);
      'bp': KodDeger := (5 shl 4);
      'si': KodDeger := (6 shl 4);
      'di': KodDeger := (7 shl 4);
      else KodDeger := (15 shl 4);  // 15 = $F
    end;

    // 2. yazmaç var ve 16 bitlik ise
    if(biYazmac2 in SI.B1.BellekIcerik) then
    begin

      if(YazmacListesi[SI.B1.YazmacB2].Uzunluk = yu16bGY) then
      begin

        case YazmacListesi[SI.B1.YazmacB2].Ad of
          'bx': KodDeger += 3;
          'bp': KodDeger += 5;
          'si': KodDeger += 6;
          'di': KodDeger += 7;
          else KodDeger += 15;  // 15 = $F
        end;
      end
      else
      begin

        Result := HATA_ISL_KOD_KULLANIM;
        Exit;
      end
    end;

    // kullanılabilinecek tüm olasılıklar
    case KodDeger of
      $36, $63: i := 0;   // bx + si veya si + bx
      $37, $73: i := 1;   // bx + di veya di + bx
      $56, $65: i := 2;   // bp + si veya si + bp
      $57, $75: i := 3;   // bp + di veya di + bp
      $60: i := 4;        // si
      $70: i := 5;        // di
      $30: i := 7;        // bx
      else i := $FF;
    end;

    // hatalı kombinasyon kullanıldıysa hata kodu ile işlevden çık
    if(i = $FF) then
    begin

      Result := HATA_ISL_KOD_KULLANIM;
      Exit;
    end;

    KodEkle(IsKodDiger);
    KodEkle((MODRMDegeri shl 3) or i);
    Result := HATA_YOK;
  end
  else
  // aksi durumda tek bir yazmaç kullanılmıştır
  begin

    // sayısal değer kontrolü burada yapılacak
    if(biSabitDeger in SI.B1.BellekIcerik) then
    begin

      IslemKoduEkle;
      KodEkle($05);
      { TODO : 4 bytelık veri olarak belirlenmiştir. diğer veri tipleri de incelensin}
      Result := SayisalDegerKodla(SI.B1.SabitDeger, vgB4);
    end
    // 1. 32 bitlik yazmaç adresleme
    else if(YazmacListesi[SI.B1.Yazmac].Uzunluk = yu32bGY) then
    begin

      // ayrıntılar eklenecek - sayısal değer gerekebilir
      if(YazmacListesi[SI.B1.Yazmac].Ad = 'esp') then
      begin

        IslemKoduEkle;
        KodEkle($04);
        KodEkle($24);
        Result := HATA_YOK;
      end
      // ebp yazmacının öndeğer alması gerekmektedir. [ebp+0] gibi
      else if(YazmacListesi[SI.B1.Yazmac].Ad = 'ebp') then
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
        if(YazmacListesi[SI.B1.Yazmac].DesMim = dmTum) then
        begin

          // mimarinin 16 bit, yazmaçların 32 bit olması durumunda
          if(GAsm2.Derleyici.Mimari = mim16Bit) then
          begin

            KodEkle($67);
            KodEkle($66);
          end
          // mimarinin 64 bit, yazmaçların 32 bit olması durumunda
          else if(GAsm2.Derleyici.Mimari = mim64Bit) then KodEkle($67);

          IslemKoduEkle;
          KodEkle((MODRMDegeri shl 3) or YazmacListesi[SI.B1.Yazmac].Deger);
          Result := HATA_YOK;
        end
        // 32 / 64 bitlik yazmaçların kodlanması
        else if(YazmacListesi[SI.B1.Yazmac].DesMim = dm64Bit) then
        begin

          // mimarinin 16 bit, yazmaçların 32 bit olması durumunda
          if(GAsm2.Derleyici.Mimari = mim64Bit) then
          begin

            KodEkle($67);
            KodEkle($41);

            IslemKoduEkle;
            KodEkle((MODRMDegeri shl 3) or (YazmacListesi[SI.B1.Yazmac].Deger - 8));
            Result := HATA_YOK;
          end else Result := HATA_ISL_KOD_KULLANIM;
        end;
      end;
    end
    // 2. 64 bitlik yazmaç adresleme
    else if(YazmacListesi[SI.B1.Yazmac].Uzunluk = yu64bGY) then
    begin

      if(YazmacListesi[SI.B1.Yazmac].Deger > 7) then
      begin

        KodEkle($41);
        i := YazmacListesi[SI.B1.Yazmac].Deger - 8;
      end else i := YazmacListesi[SI.B1.Yazmac].Deger;

      IslemKoduEkle;
      KodEkle((MODRMDegeri shl 3) or i);
      Result := HATA_YOK;
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
  if(SI.B1.SabitDeger < (MevcutBellekAdresi + 2)) then
    ii := -((MevcutBellekAdresi + 2) - SI.B1.SabitDeger)
  else ii := SI.B1.SabitDeger - (MevcutBellekAdresi + 2);

  KodEkle(KomutIK);
  KodEkle(ii);
  Result := HATA_YOK;
end;

// bu işlev iptal edilecektir

// 2.1 - mov   eax,1
// $B8+ rw iw
function IslemKoduIleYazmacDegeriniBirlestir2(IK8, IKDiger, ModRMDeger: Byte; SI: TSatirIcerik): Integer;
begin

  if(YazmacListesi[SI.B1.Yazmac].Uzunluk = yu8bGY) then
  begin

    KodEkle(IK8 + (ModRMDeger shl 3) or (YazmacListesi[SI.B1.Yazmac].Deger and 7));
    Result := HATA_YOK;
  end
  else if(YazmacListesi[SI.B1.Yazmac].Uzunluk = yu16bGY) then
  begin

    KodEkle(IKDiger + (ModRMDeger shl 3) or (YazmacListesi[SI.B1.Yazmac].Deger and 7));
    Result := HATA_YOK;
  end
  else if(YazmacListesi[SI.B1.Yazmac].Uzunluk = yu32bGY) then
  begin

    if(YazmacListesi[SI.B1.Yazmac].DesMim = dm64Bit) then KodEkle($41);

    KodEkle(IKDiger + (ModRMDeger shl 3) or (YazmacListesi[SI.B1.Yazmac].Deger and 7));
    Result := HATA_YOK;
  end
  else if(YazmacListesi[SI.B1.Yazmac].Uzunluk = yu64bGY) then
  begin

    if(YazmacListesi[SI.B1.Yazmac].Deger > 7) then
      KodEkle($4C)
    else KodEkle($48);

    KodEkle(IKDiger);
    KodEkle($C0 + (ModRMDeger shl 3) or (YazmacListesi[SI.B1.Yazmac].Deger and 7));
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

      if(GAsm2.Derleyici.Mimari = mim64Bit) then
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

      if not(GAsm2.Derleyici.Mimari = mim16Bit) then KodEkle($66);

      KodEkle(IsKodDiger);
      KodEkle($C0 + (YazmacListesi[KaynakYazmac].Deger shl 3) or
        (YazmacListesi[HedefYazmac].Deger and 7));
      Result := HATA_YOK;
    end
    else
    // 64 bitlik mimarinin 8 bitlik yazmaçları
    begin

      if(GAsm2.Derleyici.Mimari = mim64Bit) then
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

      if(GAsm2.Derleyici.Mimari = mim16Bit) then KodEkle($66);

      KodEkle(IsKodDiger);
      KodEkle($C0 or (YazmacListesi[KaynakYazmac].Deger shl 3) or
        (YazmacListesi[HedefYazmac].Deger and 7));
      Result := HATA_YOK;
    end
    else
    // 64 bitlik mimarinin 8 bitlik yazmaçları
    begin

      if(GAsm2.Derleyici.Mimari = mim64Bit) then
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

// 5.3 - yazmaça bellek değeri ata
// YazmacKodla:
// örnek kod: not eax
// örnek işlem kodu: REX + F6 /2
// IsKod8 = 8 bitlik işlem kodu
// IsKodDiger = 8 bit haricindeki işlem kodu
// KaynakYazmac = işlem kodundaki /x değeri (mod r/m değeri)
// HedefYazmac = kullanılan yazmaç değeri
function YazmacaBellekBolgesiAta(YazmacaBB: Boolean; IsKod8, IsKodDiger: Byte): Integer;
var
  BT1, BT2: TBolumTip;
  Y1, Y2: Integer;
begin

  // işlem yapılırken, İşlemKodu Yazmaç, [Bellek] biçiminde işlem yapılacak
  if(YazmacaBB) then
  begin

    BT1 := SI.B1;
    BT2 := SI.B2;
    Y1 := SI.B1.YazmacB1;      // ... bu ve ...
    Y2 := SI.B1.YazmacB2;
  end
  else
  begin

    BT1 := SI.B2;
    BT2 := SI.B1;
    Y1 := SI.B1.YazmacB2;    // ... bu kısımlar teyit edilsin
    Y2 := SI.B1.YazmacB1;
  end;

  if(BT1.BolumAnaTip = batYazmac) and (BT2.BolumAnaTip = batBellek) then
  begin

    if(YazmacListesi[Y1].Uzunluk = yu8bGY) then

      KodEkle(IsKod8)
    else KodEkle(IsKodDiger);

    if(biSabitDeger in BT2.BellekIcerik) then
    begin

      KodEkle((YazmacListesi[Y1].Deger shl 3) or 5);
      SayisalDegerEkle(SI.B2.SabitDeger, vgB4);
    end
    else
    begin

      KodEkle((YazmacListesi[Y1].Deger shl 3) or
        (YazmacListesi[SI.B1.YazmacB1].Deger and 7));
    end;

    Result := HATA_YOK;
  end else Result := HATA_DEVAM_EDEN_CALISMA;
end;

// İşlemKodu + Yazmac değerinin birleştirilmesini sağlar
function IslemKoduIleYazmacDegeriniBirlestir(IsKod8, IsKodDiger, Yazmac: Byte): Integer;
begin

  if(YazmacListesi[Yazmac].Uzunluk = yu8bGY) then
  begin

    if(YazmacListesi[Yazmac].DesMim = dmTum) then
    begin

      KodEkle(IsKod8 + (YazmacListesi[Yazmac].Deger));
      Result := HATA_YOK;
    end
    else
    // 64 bitlik mimarinin 8 bitlik yazmaçları
    begin

      if(GAsm2.Derleyici.Mimari = mim64Bit) then
      begin

        if((YazmacListesi[Yazmac].Ad = 'spl') or (YazmacListesi[Yazmac].Ad = 'bpl') or
          (YazmacListesi[Yazmac].Ad = 'sil') or (YazmacListesi[Yazmac].Ad = 'dil')) then
          KodEkle($40)
        else KodEkle($41);

        KodEkle(IsKod8 + (YazmacListesi[Yazmac].Deger - 8));
        Result := HATA_YOK;
      end else Result := HATA_64BIT_MIMARI_GEREKLI;
    end;
  end
  else if(YazmacListesi[Yazmac].Uzunluk = yu16bGY) then
  begin

    if(YazmacListesi[Yazmac].DesMim = dmTum) then
    begin

      if not(GAsm2.Derleyici.Mimari = mim16Bit) then KodEkle($66);

      KodEkle(IsKodDiger + (YazmacListesi[Yazmac].Deger));
      Result := HATA_YOK;
    end
    else
    // 64 bitlik mimarinin 16 bitlik yazmaçları
    begin

      if(GAsm2.Derleyici.Mimari = mim64Bit) then
      begin

        KodEkle($66);
        KodEkle($41);

        KodEkle(IsKodDiger + (YazmacListesi[Yazmac].Deger - 8));
        Result := HATA_YOK;
      end else Result := HATA_64BIT_MIMARI_GEREKLI;
    end;
  end
  else if(YazmacListesi[Yazmac].Uzunluk = yu32bGY) then
  begin

    if(YazmacListesi[Yazmac].DesMim = dmTum) then
    begin

      if(GAsm2.Derleyici.Mimari = mim16Bit) then KodEkle($66);

      KodEkle(IsKodDiger + (YazmacListesi[Yazmac].Deger));
      Result := HATA_YOK;
    end
    else
    // 64 bitlik mimarinin 32 bitlik yazmaçları
    begin

      if(GAsm2.Derleyici.Mimari = mim64Bit) then
      begin

        KodEkle($41);

        KodEkle(IsKodDiger + (YazmacListesi[Yazmac].Deger - 8));
        Result := HATA_YOK;
      end else Result := HATA_64BIT_MIMARI_GEREKLI;
    end;
  end
  else if(YazmacListesi[Yazmac].Uzunluk = yu64bGY) then
  begin

    if(YazmacListesi[Yazmac].Deger > 7) then
    begin

      KodEkle($41);
      KodEkle(IsKodDiger + (YazmacListesi[Yazmac].Deger - 8));
    end
    else
    begin

      KodEkle(IsKodDiger + (YazmacListesi[Yazmac].Deger));
    end;

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
  if(SI.B1.SabitDeger < (MevcutBellekAdresi - 1)) then
    SayisalVeri := -((MevcutBellekAdresi - 1) - SI.B1.SabitDeger)
  else SayisalVeri := SI.B1.SabitDeger - (MevcutBellekAdresi - 1);

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

// 5.4 - bellek bölgesine yazmaç ata
function BellekBolgesineYazmacAta(SI: TSatirIcerik; Yazmac1,
  Yazmac2: Integer): Integer;
begin

end;

// 5.5 - bellek bölgesine sayısal değer ata
function BellekBolgesineSayisalDegerAta(SI: TSatirIcerik; Yazmac1,
  Yazmac2: Integer): Integer;
begin

end;

end.
