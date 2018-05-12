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

  TOPLAM_MAKRO = 1;
  MakroListesi: array[0..TOPLAM_MAKRO - 1] of TMakro = (
    (MakroKimlik: MAKRO_BURASI; MakroAdi: '%burası')
  );

function MakroIslev(AIsleyici, AMakroAdi: string; var ASonKullanilanIsleyici:
  Char): Integer;

implementation

uses donusum, asm2, sysutils, genel;

function MakroIslev(AIsleyici, AMakroAdi: string; var ASonKullanilanIsleyici:
  Char): Integer;
var
  MakroAdi: string;
  MakroSiraNo, i: Integer;
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

  if(MakroSiraNo = MAKRO_BURASI) then
  begin

    if(Length(AIsleyici) > 0) then
    begin

      GAsm2.Matematik.SayiEkle(AIsleyici[1], True, MevcutBellekAdresi);
      ASonKullanilanIsleyici := AIsleyici[1];
    end
    else
    begin

      GAsm2.Matematik.SayiEkle('+', True, MevcutBellekAdresi);
      ASonKullanilanIsleyici := '+';     // geçici değer
    end;

    Result := HATA_YOK;
  end else Result := HATA_MAKRO_TANIMLANMAMIS;
end;

end.
