{-------------------------------------------------------------------------------

  Dosya: degerkodla.pas

  İşlev: işlem kodundan sonraki 1 veya 2 öndeğerin (parametre) kodlamasını
    gerçekleştirir

  Güncelleme Tarihi: 09/06/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit degerkodla;
{
  işlem kodu (opcode) atama olasılıkları
  1.1 - push  1		          ; sayısal değer
  1.2 - push  eax		        ; yazmaç
  1.3 - push  [eax]	        ; yazmaç ile bellek adresleme
  1.4 - push  [1234h]       ; sayısal değer ile bellek adresleme

  2.1 - mov   eax,1		      ; sayısal değer
  2.2 - mov   eax,ebx		    ; yazmaç
  2.3 - mov   eax,[ebx]	    ; yazmaç ile bellek adresleme
  2.4 - mov   eax,[1234h]   ; sayısal değer ile bellek adresleme

  3.1 - mov   [eax],1		    ; sayısal değer
  3.2 - mov   [eax],ebx	    ; yazmaç ile bellek adresleme
  3.3 - mov   [1234h],ebx	  ; sayısal değer ile bellek adresleme
}
interface

uses paylasim, yazmaclar, genel, kodlama, onekler;

function YazmacAtamasiYap(IslemKodu: Byte; Yazmac1: Integer): Integer;
function KayanNoktaSayiDegeriniKodla(KayanNoktaSayi: string;
  SayiTipi: TVeriGenisligi): Integer;
function SayisalDegerKodla(ASayisalDeger: QWord; AVeriGenisligi: TVeriGenisligi = vgHatali): Integer;

implementation

uses sysutils, donusum;

// 1.2 - işlem kodu kullanımı
{ TODO : çalışma genişletilecek ve tamamlanacak }
// Yazmac1: adreslemede kullanılacak tek yazmacın sıra değeri
function YazmacAtamasiYap(IslemKodu: Byte; Yazmac1: Integer): Integer;
begin

  KodEkle(IslemKodu + YazmacListesi[Yazmac1].Deger);
  Result := HATA_YOK;
end;

function KayanNoktaSayiDegeriniKodla(KayanNoktaSayi: string;
  SayiTipi: TVeriGenisligi): Integer;
var
  KNSayi32: Single;
  KNSayi64: Double;
  p: PByte;
  i: Integer;
begin

  if(SayiTipi = vgB4) then
  begin

    KNSayi32 := StrToFloat(StringReplace(KayanNoktaSayi, '.',  ',' ,[]));
    p := @KNSayi32;

    for i := 0 to 3 do begin KodEkle(p^); Inc(p); end;

    Result := HATA_YOK;
  end
  else if(SayiTipi = vgB8) then
  begin

    KNSayi64 := StrToFloat(StringReplace(KayanNoktaSayi, '.',  ',' ,[]));
    p := @KNSayi64;

    for i := 0 to 7 do begin KodEkle(p^); Inc(p); end;

    Result := HATA_YOK;
  end else Result := HATA_VERI_TIPI;
end;

function SayisalDegerKodla(ASayisalDeger: QWord; AVeriGenisligi: TVeriGenisligi = vgHatali): Integer;
var
  SayisalDeger: QWord;
  VeriGenisligi: TVeriGenisligi;
  i, iVeriGenisligi: Integer;
begin

  SayisalDeger := ASayisalDeger;

  // veri genişiliği belirlenmemişse, veri genişliğini belirle
  if(AVeriGenisligi = vgHatali) then
  begin

    VeriGenisligi := SayiTipiniAl(ASayisalDeger);
  end
  else
  begin

    VeriGenisligi := AVeriGenisligi;
  end;

  // veri genişliği hatalı ise hata kodu ile işlevden çık
  if(VeriGenisligi = vgHatali) then
  begin

    Result := HATA_VERI_TIPI;
    Exit;
  end;

  case VeriGenisligi of
    vgB1: begin iVeriGenisligi := 1; end;
    vgB2: begin iVeriGenisligi := 2; end;
    vgB4: begin iVeriGenisligi := 4; end;
    vgB8: begin iVeriGenisligi := 8; end;
  end;

  // sayısal veriyi belleğe yaz
  for i := 1 to iVeriGenisligi do
  begin

    KodEkle(Byte(SayisalDeger));
    SayisalDeger := SayisalDeger shr 8;
  end;

  Result := HATA_YOK;
end;

end.
