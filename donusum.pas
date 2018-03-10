{-------------------------------------------------------------------------------

  Dosya: donusum.pas

  İşlev: sayısal / karaktersel çevrim ile ilgili işlevleri içerir

  Güncelleme Tarihi: 09/03/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit donusum;

interface

uses Classes, SysUtils, paylasim;

function SayiyaCevir(Sistem10s: string; var Sistem10i: QWord): Boolean;
function Sistem2Sistem10(Sistem2: string; var Sistem10: QWord): Boolean;
function Sistem16Sistem10(Sistem16: string; var Sistem10: QWord): Boolean;
function KucukHarfeCevir(s: string): string;
function YeniUTF8AnsiTR(s: string): string;
function SayiTipiniAl(SayisalDeger: QWord): TSayiTipi;

implementation

uses LazUTF8;

// ikili / onlu / onaltılı sayısal karakter katarının (string) sayısal (int)
// değere dönüştürme işlemini gerçekleştirir
function SayiyaCevir(Sistem10s: string; var Sistem10i: QWord): Boolean;
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

    s := Copy(Sistem10s, 1, VeriUz - 1);
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
function Sistem2Sistem10(Sistem2: string; var Sistem10: QWord): Boolean;
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
function Sistem16Sistem10(Sistem16: string; var Sistem10: QWord): Boolean;
var
  i: Int64;
begin

  Result := True;

  try
    i := StrToInt64('$' + Sistem16);
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

// Utf8ToAnsi vb diğer işlevler istenen sonucu vermediğinden dolayı
// çözüm olarak yeni işlev kodlanmıştır - 09.03.2018
function YeniUTF8AnsiTR(s: string): string;
var
  i: Integer;
  s2, s3: string;
begin

  if(UTF8Length(s) = 0) then
  begin

    Result := '';
    Exit;
  end;

  s2 := '';
  for i := 1 to UTF8Length(s) do
  begin

    s3 := UTF8Copy(s, i, 1);

    if(s3 = 'ç') then
      s2 += #231
    else if(s3 = 'Ç') then
      s2 += #199
    else if(s3 = 'ğ') then
      s2 += #240
    else if(s3 = 'Ğ') then
      s2 += #208
    else if(s3 = 'ı') then
      s2 += #253
    {else if(s3 = 'I') then   // ascii kod tablosu içerisinde olduğundan
      s2 += #73}              // yeniden tanımlanmasına gerek yoktur
    {else if(s3 = 'i') then   // ascii kod tablosu içerisinde olduğundan
      s2 += #105}             // yeniden tanımlanmasına gerek yoktur
    else if(s3 = 'İ') then
      s2 += #221
    else if(s3 = 'ö') then
      s2 += #246
    else if(s3 = 'Ö') then
      s2 += #214
    else if(s3 = 'ş') then
      s2 += #254
    else if(s3 = 'Ş') then
      s2 += #222
    else if(s3 = 'ü') then
      s2 += #252
    else if(s3 = 'Ü') then
      s2 += #220
    else s2 += s3;
  end;

  Result := s2;
end;

// sayısal verinin veri tipini belirler
function SayiTipiniAl(SayisalDeger: QWord): TSayiTipi;
begin

  if((SayisalDeger and $FFFFFFFFFFFFFF00) > 0) then
  begin

    if((SayisalDeger and $FFFFFFFFFFFF0000) > 0) then
    begin

      if((SayisalDeger and $FFFFFFFF00000000) > 0) then
      begin

        Result := st8B;
      end else Result := st4B;
    end else Result := st2B;
  end else Result := st1B;
end;

end.
