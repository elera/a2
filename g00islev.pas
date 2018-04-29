{-------------------------------------------------------------------------------

  Dosya: g00islev.pas

  İşlev: 0. grup kodlama işlevlerini gerçekleştirir

  0. grup kodlama işlevi, TANIM ifadelerini yönetir

  TANIM ifadeleri; programcının tanımladığı, sabit olmayan sayısal ve
    ve karakter katarı türünde tanımlama verileridir

  Güncelleme Tarihi: 07/03/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit g00islev;

interface

uses paylasim;

function Grup00Islev(SatirNo: Integer; ParcaNo: Integer;
  VeriKontrolTip: TVeriKontrolTip; Veri1: string; Veri2: QWord): Integer;

implementation

uses atamalar, donusum, asm2, sysutils, genel, onekler;

var
  VeriTipi: TTemelVeriTipi;
  Tanimlanan: string;
  Esittir: Boolean;
  VeriUzunlugu: Integer;
  sTanim: string;
  iTanim: QWord;

function Grup00Islev(SatirNo: Integer; ParcaNo: Integer;
  VeriKontrolTip: TVeriKontrolTip; Veri1: string; Veri2: QWord): Integer;
var
  s: string;
  i: Integer;
  Atama: TAtama;
  SayiTipi: TVeriGenisligi;
begin

  // tanım verisi gönderilmeden önceki ilk aşama
  // ilk değer atamaları gerçekleştiriliyor
  if(VeriKontrolTip = vktIlk) then
  begin

    VeriTipi := tvtTanimsiz;
    Esittir := False;
    Tanimlanan := Veri1;

    // tanımlayıcı etiket değerinin etiket tanım listesinde olup olmadığını kontrol et
    Atama := GAsm2.AtamaListesi.Bul(Veri1);
    if(Atama = nil) then
    begin

      Result := HATA_YOK;
    end else Result := HATA_ETIKET_TANIMLANMIS;
  end
  // eşittir kontrolü
  else if(VeriKontrolTip = vktEsittir) then
  begin

    // birden fazla eşittir işaretinin gelmesi durumunda
    if(Esittir) then

      Result := HATA_TANIM_KULLANIM
    else
    begin

      Esittir := True;
      Result := HATA_YOK;
    end;
  end
  // karakter dizisi kontrolü
  { TODO : henüz test edilmedi. test edilecek! }
  else if(VeriKontrolTip = vktKarakterDizisi) then
  begin

    // daha önce hiç bir veri tanımlanmadıysa...
    if(VeriTipi = tvtTanimsiz) then
    begin

      sTanim := Veri1;
      VeriTipi := tvtKarakterDizisi;
      Result := HATA_YOK;
    end else Result := HATA_TANIM_KULLANIM;
  end
  // sayısal veri kontrolü
  else if(VeriKontrolTip = vktSayi) then
  begin

    // daha önce hiç bir veri tanımlanmadıysa...
    if(VeriTipi = tvtTanimsiz) then
    begin

      VeriTipi := tvtSayi;

      iTanim := Veri2;

      SayiTipi := SayiTipiniAl(iTanim);
      case SayiTipi of
        //stHatali: // şu aşamada değerlendirilmesi gereksiz
        vgB1: VeriUzunlugu := 1;
        vgB2: VeriUzunlugu := 2;
        vgB4: VeriUzunlugu := 4;
        vgB8: VeriUzunlugu := 8;
      end;

      Result := HATA_YOK;
    end else Result := HATA_TANIM_KULLANIM;
  end
  // satırdaki tüm veriler bu işleve gönderildi
  // son kontrol sonucu veri üretilecek
  else if(VeriKontrolTip = vktSon) then
  begin

    if(Esittir) and ((VeriTipi = tvtKarakterDizisi) or (VeriTipi = tvtSayi)) then
    begin

      { TODO : henüz test edilmedi. test edilecek! }
      if(VeriTipi = tvtKarakterDizisi) then
      begin

        VeriUzunlugu := Length(sTanim);
        Result := GAsm2.AtamaListesi.Ekle(SatirNo, Tanimlanan, etTanim, -1,
          tvtKarakterDizisi, sTanim, 0);

        Result := HATA_YOK;
      end
      else if(VeriTipi = tvtSayi) then
      begin

        Result := GAsm2.AtamaListesi.Ekle(SatirNo, Tanimlanan, etTanim, -1,
          tvtSayi, '', iTanim);

        Result := HATA_YOK;
      end else Result := HATA_BILINMEYEN_BILDIRIM;
    end else Result := HATA_TANIMLAMA;
  end else Result := HATA_BILINMEYEN_BILDIRIM;
end;

end.
