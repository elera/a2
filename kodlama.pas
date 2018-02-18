{-------------------------------------------------------------------------------

  Dosya: kodlama.pas

  İşlev: oluşturulan kodları geçici belleğe yazma ve format oluşturma
    işlevlerini gerçekleştirir

  Güncelleme Tarihi: 14/02/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit kodlama;

interface

uses Classes, SysUtils;

procedure KodEkle(Kod: Byte);

implementation

uses genel;

procedure KodEkle(Kod: Byte);
begin

  KodBellek[KodBellekU] := Kod;
  Inc(KodBellekU);

  // bellek 4K bloklara ayrılarak kodların bellek bloklarına yerleşimi burada
  // yönetilecek
  Inc(MevcutBellekAdresi);
end;

end.
