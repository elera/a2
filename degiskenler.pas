{-------------------------------------------------------------------------------

  Dosya: degşskenler.pas

  DEĞİŞKEN komutlarını yönetir

  Güncelleme Tarihi: 26/09/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit degiskenler;

interface

uses Classes, SysUtils, genel, paylasim;

function DegiskenleriTamamla(ParcaSonuc: TParcaSonuc): Integer;

implementation

uses donusum, komutlar, kodlama, onekler;

function DegiskenleriTamamla(ParcaSonuc: TParcaSonuc): Integer;
var
  KomutVG, VG: TVeriGenisligi;
  VeriUzunluk: Integer;
  i, j: Integer;
  SayisalVeri: QWord;
  s, s2: string;
begin

  case SI.Komut.GNo of
    GRUP02_DB:  begin VeriUzunluk := 1; KomutVG := vgB1;     end;
    GRUP02_DB0: begin VeriUzunluk := 1; KomutVG := vgB1Sifir;end;
    GRUP02_DBW: begin VeriUzunluk := 1; KomutVG := vgB1B2;   end;
    GRUP02_DW:  begin VeriUzunluk := 2; KomutVG := vgB2;     end;
    GRUP02_DD:  begin VeriUzunluk := 4; KomutVG := vgB4;     end;
    GRUP02_DQ:  begin VeriUzunluk := 8; KomutVG := vgB8;     end;
    GRUP02_DT:  begin VeriUzunluk := 10;KomutVG := vgB10;    end;
  end;

  if(ParcaSonuc.VeriTipi = vKarakterDizisi) then
  begin

    // pascal derleyici tarafından utf-8 olarak kodlanan veri ansi karaktere çevriliyor
    s2 := YeniUTF8AnsiTR(ParcaSonuc.VeriKK);

    // karakter dizisinin uzunluğu db, db0 veya dbw olması halinde veri
    // uzunluğunu kontrol etmeye gerek yoktur. veri uzunluğu sınırsızdır.
    // aksi durumda uzunluk kontrolünün yapılması gerekmektedir
    if(KomutVG = vgB1) or (KomutVG = vgB1Sifir) or (KomutVG = vgB1B2) then

      s := s2
    else
    begin

      // programcı tarafından tanıma atanan veri uzunluğu
      i := Length(s2);

      // atanan veri, tanımlanan veri uzunluğundan büyükse hata kodu ile çıkış yap
      if(i > VeriUzunluk) then
      begin

        Result := HATA_VERI_TIPI;
        Exit;
      end
      // atanan veri, tanımlanan veri uzunluğundan küçükse, verinin sonunu 0 ile doldur
      else if(i < VeriUzunluk) then
      begin

        s := s2;
        for j := 1 to VeriUzunluk - i do s := s + #0;
      end else s := s2;
    end;

    // hazırlanan veriyi hedef bellek bölgesine kopyala

    // 1. 1 bytelık verinin 2 byte olarak değerlendirilmesi
    if(KomutVG = vgB1B2) then
    begin

      j := Length(s);
      for i := 1 to j do begin KodEkle(Byte(s[i])); KodEkle(Byte(0)); end;
    end
    else
    // 2. 1 bytelık verinin 1 byte olarak değerlendirilmesi
    begin

      j := Length(s);
      for i := 1 to j do KodEkle(Byte(s[i]));
    end;

    // veri tipinin vgB1Sifir olması durumunda verinin sonuna 0 değeri ekle
    if(KomutVG = vgB1Sifir) then KodEkle(0);

    Result := HATA_YOK;
  end
  else if(ParcaSonuc.VeriTipi = vSayi) then
  begin

    VG := SayiTipiniAl(ParcaSonuc.VeriSD);

    { Önemli: sayısal değer istenen değerden büyük olması durumunda;
      (örnek: db 1 - 2 ; 64 bitlik değer dönecektir) sayısal değer olması gereken
      değer kadar sağdan (en anlamsız bit) itibaren işlenecektir. }
    //if(KomutVG >= VG) then
    begin

      SayisalVeri := ParcaSonuc.VeriSD;

      // sayısal veriyi belleğe yaz
      for i := 1 to VeriUzunluk do
      begin

        KodEkle(Byte(SayisalVeri));
        SayisalVeri := SayisalVeri shr 8;
      end;

      Result := HATA_YOK;
    end;
  end
  else if(ParcaSonuc.VeriTipi = vKayanNokta) then
  begin

    Result := KayanNoktaSayiDegeriniKodla(ParcaSonuc.VeriKK, KomutVG);
  end;
end;

end.
