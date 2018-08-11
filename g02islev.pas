{-------------------------------------------------------------------------------

  Dosya: g02islev.pas

  İşlev: 2. grup kodlama işlevlerini gerçekleştirir

  2. grup kodlama işlevi, DEĞİŞKEN ifadelerini yönetir

  Güncelleme Tarihi: 05/08/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit g02islev;

interface

uses Classes, SysUtils, genel, paylasim;

function Grup02Degisken(SatirNo: Integer; ParcaNo: Integer;
  VeriKontrolTip: TVeriKontrolTip; Veri1: string; Veri2: QWord): Integer;

implementation

uses donusum, komutlar, kodlama, onekler, dbugintf;

var
  SayiTipi: TVeriGenisligi;
  VeriGenisligi: Integer;
  VirgulKullanildi: Boolean;

function Grup02Degisken(SatirNo: Integer; ParcaNo: Integer;
  VeriKontrolTip: TVeriKontrolTip; Veri1: string; Veri2: QWord): Integer;
var
  _SayiTipi: TVeriGenisligi;
  i, j: Integer;
  SayisalVeri: QWord;
  s, s2: string;
begin

  // ilk veri - Veri2 komut sıra numarasını verir
  if(VeriKontrolTip = vktIlk) then
  begin

    case KomutListesi[Veri2].GrupNo of
      GRUP02_DB:  begin VeriGenisligi := 1; SayiTipi := vgB1;   end;
      GRUP02_DBW: begin VeriGenisligi := 1; SayiTipi := vgB1B2; end;
      GRUP02_DW:  begin VeriGenisligi := 2; SayiTipi := vgB2;   end;
      GRUP02_DD:  begin VeriGenisligi := 4; SayiTipi := vgB4;   end;
      GRUP02_DQ:  begin VeriGenisligi := 8; SayiTipi := vgB8;   end;
      GRUP02_DT:  begin VeriGenisligi := 10;SayiTipi := vgB10;  end;
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

      // pascal derleyici tarafından utf-8 olarak kodlanan veri ansi karaktere çevriliyor
      s2 := YeniUTF8AnsiTR(Veri1);

      // karakter dizisinin uzunluğu db veya dbw olması halinde veri uzunluğunu kontrol
      // etmeye gerek yoktur. veri uzunluğu sınırsızdır
      // aksi durumda uzunluk kontrolünün yapılması gerekmektedir
      if(SayiTipi = vgB1) or (SayiTipi = vgB1B2) then

        s := s2
      else
      begin

        // programcı tarafından tanıma atanan veri uzunluğu
        i := Length(s2);

        // atanan veri, tanımlanan veri uzunluğundan büyükse hata kodu ile çıkış yap
        if(i > VeriGenisligi) then
        begin

          Result := HATA_VERI_TIPI;
          Exit;
        end
        // atanan veri, tanımlanan veri uzunluğundan küçükse, verinin sonunu 0 ile doldur
        else if(i < VeriGenisligi) then
        begin

          s := s2;
          for j := 1 to VeriGenisligi - i do s := s + #0;
        end else s := s2;
      end;

      // hazırlanan veriyi hedef bellek bölgesine kopyala
      if(SayiTipi = vgB1B2) then
      begin

        j := Length(s);
        for i := 1 to j do begin KodEkle(Byte(s[i])); KodEkle(Byte(0)); end;
      end
      else
      begin

        j := Length(s);
        for i := 1 to j do KodEkle(Byte(s[i]));
      end;

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
  end
  else if(VeriKontrolTip = vktKayanNokta) then
  begin

    if not(VirgulKullanildi) then

      Result := HATA_TANIMLAMA
    else
    begin

      VirgulKullanildi := False;

      Result := KayanNoktaSayiDegeriniKodla(Veri1, SayiTipi);
    end;
  end
  else if(VeriKontrolTip = vktVirgul) then
  begin

    // üstüste virgül kontrol değerinin gelmesi durumunda hata oluştur
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
