{-------------------------------------------------------------------------------

  Dosya: hataayiklama.pas

  İşlev: kodlamadaki hatanın tespiti ile ilgili işlevleri içerir

  Güncelleme Tarihi: 27/09/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit hataayiklama;

interface

uses Classes, SysUtils, genel, paylasim, dbugintf;

procedure MesajGoruntule(Tanim, Mesaj: string);
procedure KomutBilgisiniGoruntule;
procedure VeriBilgisiniGoruntule(ParcaSonuc: TParcaSonuc);
procedure BellekIcerikVerileriniGoruntule(BolumTip: TBolumTip);

implementation

uses yazmaclar;

procedure MesajGoruntule(Tanim, Mesaj: string);
begin

  Exit;

  if(Length(Tanim) = 0) then
    SendDebug(Mesaj)
  else SendDebug(Tanim + ': ' + Mesaj);
end;

procedure KomutBilgisiniGoruntule;
var
  VeriBirKomutMu: Boolean;
begin

  Exit;

  SendDebug('Komut Bilgisi:');

  VeriBirKomutMu := False;
  case SI.Komut.Tip of
    kTanimsiz: SendDebug('HA-Komut Tipi: kTanimsiz');
    kIslemKodu:
    begin

      SendDebug('HA-Komut Tipi: kIslemKodu');
      VeriBirKomutMu := True;
    end;
    kDegisken:
    begin

      SendDebug('HA-Komut Tipi: kDegisken');
      VeriBirKomutMu := True;
    end;
    kTanim:
    begin

      SendDebug('HA-Komut Tipi: kTanim');
      VeriBirKomutMu := True;
    end;
    kBildirim:
    begin

      SendDebug('HA-Komut Tipi: kBildirim');
      VeriBirKomutMu := True;
    end;
  end;

  if(VeriBirKomutMu) then
  begin

    SendDebug('HA-Komut Adı: ' + SI.Komut.Ad);
    SendDebug('HA-Komut Grup No: ' + IntToStr(SI.Komut.GNo));
  end;
end;

procedure VeriBilgisiniGoruntule(ParcaSonuc: TParcaSonuc);
begin

  Exit;

  SendDebug('HA -> VeriBilgisiniGoruntule');

  case ParcaSonuc.ParcaTipi of
    ptYok: SendDebug('HA -> Parça Tipi: ptYok');
    ptTanimsiz: SendDebug('HA -> Parça Tipi: ptTanimsiz');
    //ptKomut: KomutBilgisiniGoruntule(ParcaSonuc.;   // komut yapısının bu yapıya dahil olması gerekmekte
    ptVeri:
    begin

      SendDebug('HA -> Parça Tipi: ptVeri');
      case ParcaSonuc.VeriTipi of
        vTanimsiz: SendDebug('HA -> Veri Tipi: Tanımsız');
        vYazmac: SendDebug('HA -> Yazmaç: ' + YazmacListesi[ParcaSonuc.SiraNo].Ad);
        vSayi:
        begin

          // normal sayı
          //SendDebug('HA -> Normal Sayı: ' + IntToStr(ParcaSonuc.VeriSD));
          // normal sayı
          //SendDebug('HA -> Bellek Sayı: ' + IntToStr(GSabitDeger1));
        end;
      end;
    end;
    ptIslem:
    begin

      SendDebug('HA-Parça Tipi: ptIslem');
      case ParcaSonuc.IslemTipi of
        iTopla: SendDebug('HA-İşlem Tipi: +');
        iEsittir: SendDebug('HA-İşlem Tipi: =');
        iVirgul: SendDebug('HA-İşlem Tipi: ,');
        iKPAc: SendDebug('HA-İşlem Tipi: [');
        iKPKapat: SendDebug('HA-İşlem Tipi: ]');
      end;
    end;
  end;
end;

procedure BolumVerileriniGoruntule(BolumTip: TBolumTip);
begin

  Exit;

  case BolumTip.BolumAnaTip of
    batYazmac:
    begin

      SendDebug('HA-Bölüm Tipi: batYazmac');
      SendDebug('HA-Yazmaç: ' + YazmacListesi[BolumTip.Yazmac].Ad);
    end;
    else SendDebug('HA-Bölüm Tipi: bilinmiyor');
  end;
end;

// bellek içerik verilerini görüntüler
// push [eax], mov esi,[ebx + 10] gibi
procedure BellekIcerikVerileriniGoruntule(BolumTip: TBolumTip);
begin

  Exit;

  case BolumTip.BolumAnaTip of
    batBellek:
    begin

      SendDebug('HA -> Bellek Adresleme Verisi');
      if(biYazmac1 in BolumTip.BellekIcerik) then
        SendDebug('HA -> 1. Yazmaç: ' + YazmacListesi[BolumTip.YazmacB1].Ad);
      if(biYazmac2 in BolumTip.BellekIcerik) then
        SendDebug('HA -> 2. Yazmaç: ' + YazmacListesi[BolumTip.YazmacB2].Ad);

      if(biSabitDeger in BolumTip.BellekIcerik) then

        SendDebug('HA -> Sayısal Değer: ' + IntToStr(BolumTip.SabitDeger));
    end;
    else SendDebug('HA-Veri: mevcut değil!');
  end;
end;
end.
