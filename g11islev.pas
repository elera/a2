{-------------------------------------------------------------------------------

  Dosya: g11islev.pas

  İşlev: 11. grup kodlama işlevlerini gerçekleştirir

  11. grup kodlama işlevi, işlem kodu ve byte tipine sahip değeri içerir

  Güncelleme Tarihi: 07/03/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit g11islev;

interface

uses Classes, SysUtils, genel, paylasim;

function Grup11Islev(SatirNo: Integer; ParcaNo: Integer;
  VeriKontrolTip: TVeriKontrolTip; Veri1: string; Veri2: QWord): Integer;

implementation

uses kodlama, donusum;

var
  IslemKodu: Integer;
  SabitDegerAtandi: Boolean;
  SabitDeger: Byte;

function Grup11Islev(SatirNo: Integer; ParcaNo: Integer; VeriKontrolTip: TVeriKontrolTip;
  Veri1: string; Veri2: QWord): Integer;
var
  SayiTipi: TSayiTipi;
begin

  if(VeriKontrolTip = vktIlk) then
  begin

    IslemKodu := Veri2;
    SabitDegerAtandi := False;
    Result := HATA_YOK;
  end
  else if(VeriKontrolTip = vktSayi) and (ParcaNo = 2) then
  begin

    SayiTipi := SayiTipiniAl(Veri2);
    if(SayiTipi > st1B) then

      Result := HATA_VERI_TIPI
    else
    begin

      SabitDegerAtandi := True;
      SabitDeger := Veri2;
      Result := HATA_YOK;
    end;
  end
  else if(VeriKontrolTip = vktSon) then
  begin

    if not(SabitDegerAtandi) then

      Result := HATA_ISL_KULLANIM
    else
    begin

      // int 03
      if(SabitDeger = 3) then

        KodEkle($CC)
      else
      // int xx
      begin

        KodEkle($CD);
        KodEkle(SabitDeger);
      end;

      Result := HATA_YOK;
    end;
  end
  else
  begin

    GHataAciklama := Veri1;
    Result := HATA_ISL_KOD_KULLANIM;
  end;
end;

end.
