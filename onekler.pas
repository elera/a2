{-------------------------------------------------------------------------------

  Dosya: onekler.pas

  İşlev: sayısal verinin genişiliğini belirleyen önek değerleri içerir

  Güncelleme Tarihi: 02/04/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit onekler;

interface

type
  // veri genişliği
  TVeriGenisligi = (vgTanimsiz, vgB1, vgB2, vgB4, vgB8);

type
  TOnEk = record
    Ad: string[5];
    Deger: TVeriGenisligi;
  end;

{ önek listesi }
const
  TOPLAM_ONEK = 4;
  OnEkListesi: array[0..TOPLAM_ONEK - 1] of TOnEk = (
    (Ad: 'b1';    Deger: vgB1),
    (Ad: 'b2';    Deger: vgB2),
    (Ad: 'b4';    Deger: vgB4),
    (Ad: 'b8';    Deger: vgB8));

function OnEkBilgisiAl(AOnEk: string): TOnEk;

implementation

// önek veri ayrıntı değerini geri döndürür
function OnEkBilgisiAl(AOnEk: string): TOnEk;
var
  i: Integer;
  OnEk: string;
begin

  OnEk := LowerCase(AOnEk);

  Result.Deger := vgTanimsiz;

  for i := 0 to TOPLAM_ONEK - 1 do
  begin

    if(OnEkListesi[i].Ad = OnEk) then
    begin

      Result := OnEkListesi[i];
      Exit;
    end;
  end;
end;

end.
