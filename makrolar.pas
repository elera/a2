{-------------------------------------------------------------------------------

  Dosya: makrolar.pas

  İşlev: makro yönetim işlevlerini içerir

  Güncelleme Tarihi: 23/08/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit makrolar;

interface

type
  TMakro = record
    MakroKimlik: Integer;
    MakroAdi: string;
  end;

const
  MAKRO_BURASI  = 1;
  MAKRO_TSUNIX  = MAKRO_BURASI + 1;
  MAKRO_SAAT    = MAKRO_TSUNIX + 1;
  MAKRO_TARIH   = MAKRO_SAAT + 1;

  TOPLAM_MAKRO = 4;
  MakroListesi: array[0..TOPLAM_MAKRO - 1] of TMakro = (
    // bulunulan adresi geri döndürür
    (MakroKimlik: MAKRO_BURASI; MakroAdi: '%burası'),
    // mevcut tarih / saat bilgisini, unix epoch formatında geri döndürür
    // bilgi: dosyanın tarih / saat damgası (DateTimeStamp) için.
    (MakroKimlik: MAKRO_TSUNIX; MakroAdi: '%ts_unix'),
    (MakroKimlik: MAKRO_SAAT;   MakroAdi: '%saat'),
    (MakroKimlik: MAKRO_TARIH;  MakroAdi: '%tarih')
  );

function MakroIslev(AIsleyici, AMakroAdi: string; var ASonKullanilanIsleyici:
  Char): Integer;

implementation

uses donusum, asm2, sysutils, genel, dateutils, kodlama;

function MakroIslev(AIsleyici, AMakroAdi: string; var ASonKullanilanIsleyici:
  Char): Integer;
var
  MakroAdi, s: string;
  MakroSiraNo, i, j: Integer;
  MakroDeger: QWord;
  ets: TDateTime;     // evrensel tarih / saat
  uts: Int64;         // unix / epoch tarih / saat
  SayisalDeger: Boolean;
  DT: TDateTime;
begin

  MakroAdi := KucukHarfeCevir(AMakroAdi);

  MakroSiraNo := -1;

  for i := 0 to TOPLAM_MAKRO - 1 do
  begin

    if(MakroListesi[i].MakroAdi = MakroAdi) then
    begin

      MakroSiraNo := MakroListesi[i].MakroKimlik;
      Break;
    end;
  end;

  if(MakroSiraNo > -1) then
  begin

    SayisalDeger := False;

    if(MakroSiraNo = MAKRO_BURASI) then
    begin

      MakroDeger := MevcutBellekAdresi;
      SayisalDeger := True;
    end
    else if(MakroSiraNo = MAKRO_TSUNIX) then
    begin

      ets := LocalTimeToUniversal(Now);
      uts := DateTimeToUnix(ets);
      MakroDeger := uts;
      SayisalDeger := True;
    end
    else if(MakroSiraNo = MAKRO_SAAT) then
    begin

      DT := Now;
      s := FormatDateTime('hh:nn', DT);
      SayisalDeger := False;
    end
    else if(MakroSiraNo = MAKRO_TARIH) then
    begin

      DT := Now;
      s := FormatDateTime('DD.MM.YYYY', DT);
      SayisalDeger := False;
    end;

    // veri sayısal bir değer ise matematiksel değer işleminden geçir
    { TODO : verinin bir sayısal değer olup olmadığı incelenerek koşul sağlanacaktır }
    if(SayisalDeger) then
    begin

      if(Length(AIsleyici) > 0) then
      begin

        GAsm2.Matematik.SayiEkle(AIsleyici[1], True, MakroDeger);
        ASonKullanilanIsleyici := AIsleyici[1];
      end
      else
      begin

        GAsm2.Matematik.SayiEkle('+', True, MakroDeger);
        ASonKullanilanIsleyici := '+';     // geçici değer
      end;

      Result := HATA_YOK;
    end
    else
    // verinin db türünde bir veri olduğu varsayılıyor
    begin

      j := Length(s);
      if(j > 0) then
      begin

        for i := 1 to j do
        begin

          KodEkle(Byte(s[i]));
        end;
      end;

      Result := HATA_YOK;
    end;
  end else Result := HATA_MAKRO_TANIMLANMAMIS;
end;

end.
