{-------------------------------------------------------------------------------

  Dosya: donusum.pas

  İşlev: sayısal / karaktersel çevrim ile ilgili işlevleri içerir

  Güncelleme Tarihi: 03/02/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit donusum;

interface

uses Classes, SysUtils;

function SayiyaCevir(Sistem10s: string; var Sistem10i: Integer): Boolean;
function Sistem2Sistem10(Sistem2: string; var Sistem10: Integer): Boolean;
function Sistem16Sistem10(Sistem16: string; var Sistem10: Integer): Boolean;
function KucukHarfeCevir(s: string): string;

implementation

uses LazUTF8, strutils;

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

//  büyük karakterleri (2 karakter uzunluğundaki UTF-8 karakterler de dahil)
//  küçük karakterlere çevirir
function KucukHarfeCevir(s: string): string;
var
  i: Integer;
  s2, s3: string;
begin

  if(UTF8Length(s) = 0) then
  begin

    Result := '';
    Exit;
  end;

  // ascii kod harf aralıkları
  // 65..90 = A..Z - 97..122 = a..z

  // not: UTF-8 karakter kodları 1'den fazla karakter uzunluğundadır
  s2 := '';
  for i := 1 to UTF8Length(s) do
  begin

    s3 := UTF8Copy(s, i, 1);
    if(Length(s3) = 1) and (s3[1] in ['A'..'Z']) then
    begin

      // I karakterinin küçük harf ascii kod karşılığı i'dir
      // her ne kadar doğrunun böyle olduğunu zannediyorsak da,
      // olması gereken doğru çevrim burada olduğu gibidir
      if(s3[1] = 'I') then
        s2 += 'ı'
      else s2 += Chr(Byte(s3[1]) + 32);
    end
    else
    begin

      if(s3 = 'Ğ') then
        s2 += 'ğ'
      else if(s3 = 'Ü') then
        s2 += 'ü'
      else if(s3 = 'Ş') then
        s2 += 'ş'
      else if(s3 = 'I') then
        s2 += 'ı'
      else if(s3 = 'İ') then
        s2 += 'i'
      else if(s3 = 'Ö') then
        s2 += 'ö'
      else if(s3 = 'Ç') then
        s2 += 'ç'
      else s2 += s3;
    end;
  end;

  Result := s2;
end;

end.
