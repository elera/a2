{-------------------------------------------------------------------------------

  Dosya: sayilar.pas

  İşlev: tüm sayı sistemleri ile ilgili işlevleri içerir

  Güncelleme Tarihi: 02/02/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit sayilar;

interface

uses Classes, SysUtils;

function SayiyaCevir(Sistem10s: string; var Sistem10i: Integer): Boolean;
function Sistem2Sistem10(Sistem2: string; var Sistem10: Integer): Boolean;
function Sistem16Sistem10(Sistem16: string; var Sistem10: Integer): Boolean;

implementation

uses strutils;

// ikili / onlu / onaltılı sayısal karakter katarının (string) sayısal (int)
// değere dönüştürme işlemini gerçekleştirir
function SayiyaCevir(Sistem10s: string; var Sistem10i: Integer): Boolean;
var
  SayiSistemi: Char;
  VeriUz: Integer;
  s: string;
begin

  VeriUz := Length(Sistem10s);
  SayiSistemi := Sistem10s[VeriUz];

  // ikili sayı sistemi -> onlu sayı sistemi sayısal değer
  // örn: 111b -> 7
  if(SayiSistemi = 'b') or (SayiSistemi = 'B') then
  begin

    s := Copy(Sistem10s, 1, VeriUz - 1);
    Result := Sistem2Sistem10(s, Sistem10i);
  end
  // onaltılı sayı sistemi -> onlu sayı sistemi sayısal değer
  // 0123h -> 291
  else if(SayiSistemi = 'h') or (SayiSistemi = 'H') then
  begin

    s := Copy(Sistem10s, 2, VeriUz - 2);
    Result := Sistem16Sistem10(s, Sistem10i);
  end
  // onlu sayı sistemi -> onlu sayı sistemi sayısal değer
  else
  begin

    Result := True;
    try
      Sistem10i := StrToInt(Sistem10s);
    except
      Result := False;
    end;
  end;
end;

// ikili sistem sayısal değerini onlu sistem sayısal değerine çevirir
function Sistem2Sistem10(Sistem2: string; var Sistem10: Integer): Boolean;
var
  i, j, IkiliDegerUz: Integer;
begin

  j := 0;
  IkiliDegerUz := Length(Sistem2);

  for i := IkiliDegerUz downto 1 do
  begin

    if(Sistem2[i] = '1') then
    begin

      j += 1 shl (IkiliDegerUz - i);
    end
    else if(Sistem2[i] <> '0') then
    begin

      Result := False;
      Exit;
    end;
  end;

  Sistem10 := j;
  Result := True;
end;

// onaltılı sistem sayısal değerini onlu sistem sayısal değerine çevirir
function Sistem16Sistem10(Sistem16: string; var Sistem10: Integer): Boolean;
var
  i: Integer;
begin

  Result := True;

  try
    i := Hex2Dec(Sistem16);
  except
    Result := False;
  end;

  if(Result) then Sistem10 := i;
end;

end.
