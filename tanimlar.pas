{-------------------------------------------------------------------------------

  Dosya: tanimlar.pas

  TANIM komutlarını yönetir

  TANIM ifadeleri; programcının tanımladığı, sabit olmayan sayısal ve
    ve karakter katarı türünde tanımlama verileridir

  Güncelleme Tarihi: 26/09/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit tanimlar;

interface

uses paylasim;

function TanimlariTamamla(ParcaSonuc: TParcaSonuc): Integer;

implementation

uses atamalar, asm2, genel;

function TanimlariTamamla(ParcaSonuc: TParcaSonuc): Integer;
var
  Atama: TAtama;
begin

  // tanımlayıcı etiket değerinin etiket tanım listesinde olup olmadığını kontrol et
  Atama := GAsm2.AtamaListesi.Bul(GAktifDosya, SI.VeriKK);
  if(Atama = nil) or (Atama.YenidenAtanabilir) then
  begin

    Result := GAsm2.AtamaListesi.Ekle(GAktifDosya, atTanim, SI.VeriKK,
      ParcaSonuc);

  end else Result := HATA_ETIKET_TANIMLANMIS;
end;

end.
