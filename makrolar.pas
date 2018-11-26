{-------------------------------------------------------------------------------

  Dosya: makrolar.pas

  İşlev: makro değer işlevlerini yönetir

  Güncelleme Tarihi: 15/09/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit makrolar;

interface

uses paylasim;

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

procedure MakroIslev(var AParcaSonuc: TParcaSonuc);

implementation

uses donusum, sysutils, genel, dateutils;

procedure MakroIslev(var AParcaSonuc: TParcaSonuc);
var
  MakroAdi, s: string;
  MakroSiraNo, i: Integer;
  ets: TDateTime;     // evrensel tarih / saat
  uts: Int64;         // unix / epoch tarih / saat
  DT: TDateTime;
begin

  // geri dönüş öndeğeri
  AParcaSonuc.VeriTipi := vTanimsiz;

  // gelen veri makro işareti (%) olmaksızın bu noktaya gelir
  MakroAdi := '%' + KucukHarfeCevir(AParcaSonuc.HamVeri);

  // makro değerini makro listesinde ara
  MakroSiraNo := -1;
  for i := 0 to TOPLAM_MAKRO - 1 do
  begin

    if(MakroListesi[i].MakroAdi = MakroAdi) then
    begin

      MakroSiraNo := MakroListesi[i].MakroKimlik;
      Break;
    end;
  end;

  // makro değerini karaktersel veriye çevirerek geri döndür
  case MakroSiraNo of

    MAKRO_BURASI:
    begin

      AParcaSonuc.VeriTipi := vKarakterDizisi;
      AParcaSonuc.HamVeri := IntToStr(MevcutBellekAdresi);
    end;
    MAKRO_TSUNIX:
    begin

      ets := LocalTimeToUniversal(Now);
      uts := DateTimeToUnix(ets);
      AParcaSonuc.VeriTipi := vKarakterDizisi;
      AParcaSonuc.HamVeri := IntToStr(uts);
    end;
    MAKRO_SAAT:
    begin

      DT := Now;
      s := FormatDateTime('hh:nn', DT);
      AParcaSonuc.VeriTipi := vKarakterDizisi;
      AParcaSonuc.HamVeri := s;
    end;
    MAKRO_TARIH:
    begin

      DT := Now;
      s := FormatDateTime('DD.MM.YYYY', DT);
      AParcaSonuc.VeriTipi := vKarakterDizisi;
      AParcaSonuc.HamVeri := s;
    end;
  end;
end;

end.
