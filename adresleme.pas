{-------------------------------------------------------------------------------

  Dosya: adresleme.pas

  İşlev: bellek adresleme kontrol ve veri üretim işlemlerini gerçekleştirir

  Güncelleme Tarihi: 11/07/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit adresleme;

interface

uses Classes, SysUtils, paylasim;

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

function BellekAdresle1(IslemKodu: Byte; SatirIcerik: TSatirIcerik): Integer;
function GoreceliDegerEkle(Komut: Integer; KomutIK: Byte): Integer;

implementation

uses yazmaclar, genel, kodlama, onekler, degerkodla, donusum, komutlar;

// [...] içeriğindeki adresleme için kullanılan öndeğerleri yönetir.
function BellekAdresle1(IslemKodu: Byte; SatirIcerik: TSatirIcerik): Integer;
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

      if(GSabitDegerVG = vgB1) then
      begin

        KodEkle(IslemKodu);
      end else KodEkle(IslemKodu + 1);

      // sayısal değer kontrolü burada yapılacak
      if(baBellekSabitDeger in SatirIcerik.BolumTip1.BolumAyrinti) then
      begin

        KodEkle($05);
        { TODO : 4 bytelık veri olarak belirlenmiştir. diğer veri tipleri de incelensin}
        Result := SayisalDegerKodla(GBellekSabitDeger, vgB4);
      end
      // 32 bit genel yazmaç kontrolü
      else if(YazmacListesi[GYazmac1].Uzunluk = yu32bGY) then
      begin

        if(YazmacListesi[GYazmac1].Ad = 'esp') then
        begin

          KodEkle($04);
          KodEkle($24);
          Result := HATA_YOK;
        end
        else if(YazmacListesi[GYazmac1].Ad = 'ebp') then
        begin

          Result := HATA_ISL_KOD_KULLANIM;
        end
        else
        begin

          KodEkle(YazmacListesi[GYazmac1].Deger);
          Result := HATA_YOK;
        end;
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
