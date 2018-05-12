{-------------------------------------------------------------------------------

  Dosya: kodlama.pas

  İşlev: oluşturulan kodları geçici belleğe yazma ve format oluşturma
    işlevlerini gerçekleştirir

  Güncelleme Tarihi: 30/04/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit kodlama;

interface

uses Classes, SysUtils;

procedure KodBellekDegerleriniIlklendir;
function KodEkle(Kod: Byte): Boolean;

implementation

uses genel;

// kodların derlenerek yerleştirileceği belleği ilklendir
procedure KodBellekDegerleriniIlklendir;
begin

  KodBellekU := 0;
  BellekKapasitesi := KodBellekU;
  SetLength(KodBellek, KodBellekU);
  MevcutBellekAdresi := KodBellekU;
end;

function KodEkle(Kod: Byte): Boolean;
begin

  // bellek kapasitesi dolmuş ise. belleği artırmayı dene
  if(KodBellekU = BellekKapasitesi) then
  begin

    // eklenecek bellek azami dosya uzunluğundan büyük ise, olumsuz olarak işlevden çık
    if((BellekKapasitesi + BELLEK_BLOK_UZUNLUGU) > AZAMI_DOSYA_BOYUTU) then
    begin

      Result := False;
      Exit;
    end;

    // aksi durumda bellek kapasitesini blok uzunluğu kadar artır
    BellekKapasitesi += BELLEK_BLOK_UZUNLUGU;
    SetLength(KodBellek, BellekKapasitesi);
  end;

  // oluşturulan kodu bellek bölgesine yaz ve işaretçiyi bir artır
  KodBellek[KodBellekU] := Kod;
  Inc(KodBellekU);

  // MevcutBellekAdresi, adresleme işlemlerini yönetir
  Inc(MevcutBellekAdresi);
end;

end.
