{-------------------------------------------------------------------------------

  Dosya: makrolar.pas

  İşlev: makro yönetim işlevlerini içerir

  Güncelleme Tarihi: 05/05/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit makrolar;

interface

type
  TMakro = record
    MakroKimlik: Integer;
    MakroAdi: string;
  end;

const
  MAKRO_BURASI = 1;
  MAKRO_TSUNIX = MAKRO_BURASI + 1;

  TOPLAM_MAKRO = 2;
  MakroListesi: array[0..TOPLAM_MAKRO - 1] of TMakro = (
    // bulunulan adresi geri döndürür
    (MakroKimlik: MAKRO_BURASI; MakroAdi: '%burası'),
    // mevcut tarih / saat bilgisini, unix epoch formatında geri döndürür
    // bilgi: dosyanın tarih / saat damgası (DateTimeStamp) için.
    (MakroKimlik: MAKRO_TSUNIX; MakroAdi: '%ts_unix')
  );

function MakroIslev(AIsleyici, AMakroAdi: string; var ASonKullanilanIsleyici:
  Char): Integer;

implementation

uses donusum, asm2, sysutils, genel, dateutils;

function MakroIslev(AIsleyici, AMakroAdi: string; var ASonKullanilanIsleyici:
  Char): Integer;
var
  MakroAdi: string;
  MakroSiraNo, i: Integer;
  MakroDeger: QWord;
  ets: TDateTime;     // evrensel tarih / saat
  uts: Int64;         // unix / epoch tarih / saat
begin

  MakroAdi := KucukHarfeCevir(AMakroAdi);

  MakroSiraNo := -1;

  for i := 0 to TOPLAM_MAKRO - 1 do
  begin

    if(MakroListesi[i].MakroAdi = MakroAdi) then
    begin

      MakroSiraNo := MakroListesi[i].MakroKimlik;
      Break;
    end;
  end;

  if(MakroSiraNo > -1) then
  begin

    if(MakroSiraNo = MAKRO_BURASI) then
    begin

      MakroDeger := MevcutBellekAdresi;
    end
    else if(MakroSiraNo = MAKRO_TSUNIX) then
    begin

      ets := LocalTimeToUniversal(Now);
      uts := DateTimeToUnix(ets);
      MakroDeger := uts;
    end;

    if(Length(AIsleyici) > 0) then
    begin

      GAsm2.Matematik.SayiEkle(AIsleyici[1], True, MakroDeger);
      ASonKullanilanIsleyici := AIsleyici[1];
    end
    else
    begin

      GAsm2.Matematik.SayiEkle('+', True, MakroDeger);
      ASonKullanilanIsleyici := '+';     // geçici değer
    end;

    Result := HATA_YOK;
  end else Result := HATA_MAKRO_TANIMLANMAMIS;
end;

end.
