{-------------------------------------------------------------------------------

  Dosya: sayilar.pas

  İşlev: tüm sayı sistemleri ile ilgili işlevleri içerir

  Güncelleme Tarihi: 21/01/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit sayilar;

interface

uses Classes, SysUtils;

function SayiyaCevir(Veri: string; var SayisalKarsiligi: Integer): Boolean;

implementation

// karakter dizisinin sayısal bir değer olup olmadığını test eder
// sayısal değer olması durumunda geriye değeri döndürür
function SayiyaCevir(Veri: string; var SayisalKarsiligi: Integer): Boolean;
begin

  Result := True;
  try
    SayisalKarsiligi := StrToInt(Veri);
  except
    Result := False;
  end;
end;

end.
