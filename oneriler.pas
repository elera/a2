{-------------------------------------------------------------------------------

  Dosya: oneriler.pas

  İşlev: derleyici içerisinde kullanılan bildirimlerle ilgili öneriler sunarak
    programcının kod yazmasını kolaylaştıran öneri dizilerini içerir

  Güncelleme Tarihi: 06/03/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit oneriler;

interface

uses Classes;

const
  TOPLAM_ONERI = 7;
  OneriDizisi: array[0..TOPLAM_ONERI - 1] of string = (
    'dosya.ad = ''dosya''',
    'dosya.uzantı = ''exe''',
    'kod.adres = 400000h',
    'kod.mimari = ''16Bit''',
    'kod.mimari = ''32Bit''',
    'kod.mimari = ''64Bit''',
    'kod.tabaka = 4'
  );

procedure OnerileriListele(MevcutKelime: string; sl: TStrings);

implementation

uses donusum;

// SynCompletion nesnesinin OnExecute işlevine öneriler sunar
procedure OnerileriListele(MevcutKelime: string; sl: TStrings);
var
  i: Integer;
  s: string;
begin

  s := KucukHarfeCevir(MevcutKelime);

  sl.Clear;
  for i := 0 to TOPLAM_ONERI - 1 do
  begin

    if(Pos(s, OneriDizisi[i]) > 0) then sl.Add(OneriDizisi[i]);
  end;
end;

end.
