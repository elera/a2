{-------------------------------------------------------------------------------

  Dosya: g02islev.pas

  İşlev: 2. grup kodlama işlevlerini gerçekleştirir

  2. grup kodlama işlevi, veri tanımlayıcı ifadelerin yönetimidir

  Güncelleme Tarihi: 18/02/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit g02islev;

interface

uses Classes, SysUtils, genel;

function Grup02Bildirim(ParcaNo: Integer; VeriKontrolTip: TVeriKontrolTip;
  Veri1: string; Veri2: QWord): Integer;

implementation

uses donusum, komutlar, kodlama;

var
  SayiTipi: TSayiTipi;
  VeriGenisligi: Integer;
  VirgulKullanildi: Boolean;

function Grup02Bildirim(ParcaNo: Integer; VeriKontrolTip: TVeriKontrolTip;
  Veri1: string; Veri2: QWord): Integer;
var
  _SayiTipi: TSayiTipi;
  i, j: Integer;
  SayisalVeri: QWord;
  s: string;
begin

  // ilk veri - Veri2 komut sıra numarasını verir
  if(VeriKontrolTip = vktIlk) then
  begin

    case KomutListesi[Veri2].GrupNo of
      GRUP02_DB: begin VeriGenisligi := 1; SayiTipi := st1B; end;
      GRUP02_DW: begin VeriGenisligi := 2; SayiTipi := st2B; end;
      GRUP02_DD: begin VeriGenisligi := 4; SayiTipi := st4B; end;
      GRUP02_DQ: begin VeriGenisligi := 8; SayiTipi := st8B; end;
    end;

    // virgül kullanıldı olarak belirlenerek ilk gelecek verinin sayısal
    // veya karaktersel veri olması sağlanıyor
    VirgulKullanildi := True;

    Result := HATA_YOK;
  end
  else if(VeriKontrolTip = vktKarakterDizisi) then
  begin

    if not(VirgulKullanildi) then

      Result := HATA_TANIMLAMA
    else
    begin

      // karakter dizisinin uzunluğu db olması halinde veri uzunluğunu kontrol
      // etmeye gerek yoktur. veri uzunluğu sınırsızdır
      // aksi durumda uzunluk kontrolünün yapılması gerekmektedir
      if(SayiTipi = st1B) then

        s := Veri1
      else
      begin

        // programcı tarafından tanıma atanan veri uzunluğu
        i := Length(Veri1);

        // atanan veri, tanımlanan veri uzunluğundan büyükse hata kodu ile çıkış yap
        if(i > VeriGenisligi) then
        begin

          Result := HATA_VERI_TIPI;
          Exit;
        end
        // atanan veri, tanımlanan veri uzunluğundan küçükse, verinin sonunu 0 ile doldur
        else if(i < VeriGenisligi) then
        begin

          s := Veri1;
          for j := 1 to VeriGenisligi - i do s := s + #0;
        end else s := Veri1;
      end;

      // hazırlanan veriyi hedef bellek bölgesine kopyala
      j := Length(s);
      for i := 1 to j do KodEkle(Byte(s[i]));

      VirgulKullanildi := False;

      Result := HATA_YOK;
    end;
  end
  else if(VeriKontrolTip = vktSayi) then
  begin

    if not(VirgulKullanildi) then

      Result := HATA_TANIMLAMA
    else
    begin

      _SayiTipi := SayiTipiniAl(Veri2);
      if(SayiTipi >= _SayiTipi) then
      begin

        SayisalVeri := Veri2;

        // sayısal veriyi belleğe yaz
        for i := 1 to VeriGenisligi do
        begin

          KodEkle(Byte(SayisalVeri));
          SayisalVeri := SayisalVeri shr 8;
        end;

        VirgulKullanildi := False;

        Result := HATA_YOK;
      end else Result := HATA_SAYISAL_DEGER;
    end;
  end else if(VeriKontrolTip = vktVirgul) then
  begin

    if(VirgulKullanildi) then

      Result := HATA_TANIMLAMA
    else
    begin

      VirgulKullanildi := True;
      Result := HATA_YOK;
    end;
  end
  else if(VeriKontrolTip = vktSon) then
  begin

    // en son virgül kullanılması halinde işlemi hata ile sonlandır
    if(VirgulKullanildi) then

      Result := HATA_TANIMLAMA
    else Result := HATA_YOK;
  end else Result := HATA_BILINMEYEN_HATA;
end;

end.
