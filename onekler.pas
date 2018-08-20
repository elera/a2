{-------------------------------------------------------------------------------

  Dosya: onekler.pas

  İşlev: sayısal verinin genişiliğini belirleyen önek değerleri içerir

  Güncelleme Tarihi: 23/04/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit onekler;

interface

type
  // veri genişliği
  // B1 = 1 Byte, B1B2 = 1 Byte verinin 2 Byte olarak tanımlanması
  // B1Sifir = byte uzunluklu verinin 0 ile sonlandırılması
  { TODO : vgB1B2 ve diğer tanımlanacak veriler TOnEk kısmında da tanımlanabilir }
  TVeriGenisligi = (vgHatali, vgB1, vgB1Sifir, vgB1B2, vgB2, vgB4, vgB8, vgB10);

type
  TOnEk = record
    Ad: string[5];
    Deger: TVeriGenisligi;
  end;

{ önek listesi }
const
  TOPLAM_ONEK = 5;
  OnEkListesi: array[0..TOPLAM_ONEK - 1] of TOnEk = (
    (Ad: 'b1';    Deger: vgB1),
    (Ad: 'b2';    Deger: vgB2),
    (Ad: 'b4';    Deger: vgB4),
    (Ad: 'b8';    Deger: vgB8),
    (Ad: 'b10';   Deger: vgB10));

function OnEkBilgisiAl(AOnEk: string): TOnEk;

implementation

// önek veri ayrıntı değerini geri döndürür
function OnEkBilgisiAl(AOnEk: string): TOnEk;
var
  i: Integer;
  OnEk: string;
begin

  OnEk := LowerCase(AOnEk);

  Result.Deger := vgHatali;

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
