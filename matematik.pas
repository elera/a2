{-------------------------------------------------------------------------------

  Dosya: matematik.pas

  İşlev: derleyici içerisinde kullanılacak tekli / çoklu matematiksel /
    mantıksal işlem ve parentez öncelikli işlevlerin çalıştırılarak
    sonuç değeri döndüren nesnesel yapı

  Güncelleme Tarihi: 26/02/2018

  Bilgilendirme:
    1. işlemler; önce işaret, sonra sayı olarak yapılmaktadır. ör: + 1 - 1 * 1 / 1
    2. her bir açma parantezi bir alt kademe işlem sahası açarken,
    3. her bir kapama parantezi bir üst kademede kalan işlemi tamamlamaktadır
    4. IslemYapiliyor değişkeni, ilk işlem ile aktif olurken; Sonuc değerinin
      alınmasıyla aktifliğini yitirir

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit matematik;

{ TODO : and, or, shl, shr mantıksal işlevleri eklenecek  }

interface

uses Classes, SysUtils, paylasim;

type
  TIslem = record
    Isaret: TIslemTipleri;      // işlem ve parantez işareti (+-*/)
    DegerMevcutMu: Boolean;     // parantez öncesi değer mevcut mu?
    Deger: QWord;               // işlenecek değer
  end;

  TMatematik = class
  private
    FElemanSayisi,            // FIslemDizi dizisindeki eleman sayısı
    FSayiToplami: QWord;
    FSayiMevcut: Boolean;     // parantez öncesi sayı olup olmadığını belirtir
    FAktifIslem: TIslem;      // en son yapılan işlem
    FIslemYapiliyor: Boolean; // o anda matematiksel işlemin yapılığ yapılmadığını gösterir
    FIslemDizi: array of TIslem;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SayiEkle(AIslem: TIslemTipleri; ADeger: QWord);
    function ParantezEkle(Parantez: TIslemTipleri; DegerMevcut: Boolean;
      ADeger: QWord): Integer;
    function Sonuc(var SonucDeger: QWord): Integer;
    procedure Temizle;
  published
    property IslemYapiliyor: Boolean read FIslemYapiliyor;
  end;

implementation

uses genel, dbugintf;

constructor TMatematik.Create;
begin

  FIslemYapiliyor := False;

  // ilk değer atamaları
  FElemanSayisi := 0;
  FSayiToplami := 0;

  FSayiMevcut := False;

  FAktifIslem.Isaret := iTopla;
  FAktifIslem.Deger := 0;
end;

destructor TMatematik.Destroy;
begin

  if(FElemanSayisi > 0) then Temizle;

  inherited;
end;

// nesneye sayı ekleme işlevini yerine getirir
// AIslem değişkeni, ileriye yönelik mantıksal değerleri yönetmek için tasarlanmıştır
procedure TMatematik.SayiEkle(AIslem: TIslemTipleri; ADeger: QWord);
begin

  {case AIslem of
    iTopla: SendDebug('Sayısal Veri+:' + IntToStr(ADeger));
    iCikar: SendDebug('Sayısal Veri-:' + IntToStr(ADeger));
    iCarp: SendDebug('Sayısal Veri*:' + IntToStr(ADeger));
    iBol: SendDebug('Sayısal Veri/:' + IntToStr(ADeger));
  end;}


  // eğer işlem yapılıyor aktif değil ise, aktifleştir
  if not(FIslemYapiliyor) then FIslemYapiliyor := True;

  // öncelikle mevcut işlemi gerçekleştir, daha sonra işareti ekle
  // ör: 1 + 2 gibi. buradaki işlem + 1 + 2 olarak değerlendirilmektedir
  case AIslem of
    iTopla: FAktifIslem.Deger := FAktifIslem.Deger + ADeger;
    iCikart: FAktifIslem.Deger := FAktifIslem.Deger - ADeger;
    iCarp:  FAktifIslem.Deger := FAktifIslem.Deger * ADeger;
    iBol:   FAktifIslem.Deger := FAktifIslem.Deger div ADeger;
    // işleyici olmaması durumunda öndeğer toplama işlemidir
    else FAktifIslem.Deger := FAktifIslem.Deger + ADeger;
  end;

  if(AIslem = iBelirsiz) then
    FAktifIslem.Isaret := iTopla
  else FAktifIslem.Isaret := AIslem;

  FSayiMevcut := True;
end;

// öncelik içeren parantez işlemleri
function TMatematik.ParantezEkle(Parantez: TIslemTipleri; DegerMevcut: Boolean;
  ADeger: QWord): Integer;
begin

  // eğer işlem yapılıyor aktif değil ise, aktifleştir
  if not(FIslemYapiliyor) then FIslemYapiliyor := True;

  if(Parantez = iPAc) then
  begin

    // parantez öncesi değer gelmemesi gerekmekte
    // hatalı ifade ör: 12 (
    if(DegerMevcut) then

      Result := HATA_PAR_ONC_SAYISAL_DEGER
    else
    begin

      // parantez öncesi aktif bir işlem ( sayı mevcut ise,
      // tekrar alınmak üzere yığına at
      if(FSayiMevcut) then
      begin

        Inc(FElemanSayisi);
        SetLength(FIslemDizi, FElemanSayisi);
        FIslemDizi[FElemanSayisi - 1].DegerMevcutMu := True;
        FIslemDizi[FElemanSayisi - 1].Deger := FAktifIslem.Deger;
        FIslemDizi[FElemanSayisi - 1].Isaret := FAktifIslem.Isaret;
      end
      else
      // aksi durumda boş bir yığın oluştur
      // not: her bir ( işareti alt bir seviye oluşturur
      begin

        Inc(FElemanSayisi);
        SetLength(FIslemDizi, FElemanSayisi);
        FIslemDizi[FElemanSayisi - 1].DegerMevcutMu := False;
        FIslemDizi[FElemanSayisi - 1].Deger := FAktifIslem.Deger;
        FIslemDizi[FElemanSayisi - 1].Isaret := FAktifIslem.Isaret;
      end;

      // öndeğerleri uygula
      FSayiMevcut := False;
      FAktifIslem.Isaret := iTopla;
      FAktifIslem.Deger := 0;
      Result := 0;
    end;
  end
  else if(Parantez = iPKapat) then
  begin

    // 2/1 değer mevcut ise, aktif değere ekle
    if(DegerMevcut) then
    begin

      case FAktifIslem.Isaret of
        iTopla: FAktifIslem.Deger := FAktifIslem.Deger + ADeger;
        iCikart: FAktifIslem.Deger := FAktifIslem.Deger - ADeger;
        iCarp:  FAktifIslem.Deger := FAktifIslem.Deger * ADeger;
        iBol:   FAktifIslem.Deger := FAktifIslem.Deger div ADeger;
      end;
    end;

    // 2/2 ve yığına atılmış değeri alarak bu değere ekle ve aktif değer olarak bırak
    // not: her bir ) işareti alt seviyeyi iptal ederek üst seviyeye çıkar
    if(FElemanSayisi > 0) then
    begin

      if(FIslemDizi[FElemanSayisi - 1].DegerMevcutMu = True) then
      begin

        case FIslemDizi[FElemanSayisi - 1].Isaret of
          iTopla: FAktifIslem.Deger := FAktifIslem.Deger + FIslemDizi[FElemanSayisi - 1].Deger;
          iCikart: FAktifIslem.Deger := FAktifIslem.Deger - FIslemDizi[FElemanSayisi - 1].Deger;
          iCarp:  FAktifIslem.Deger := FAktifIslem.Deger * FIslemDizi[FElemanSayisi - 1].Deger;
          iBol:   FAktifIslem.Deger := FAktifIslem.Deger div FIslemDizi[FElemanSayisi - 1].Deger;
        end;
      end;

      Dec(FElemanSayisi);
      SetLength(FIslemDizi, FElemanSayisi);
    end;

    Result := 0;
  end;
end;

// girdilerden oluşan sayısal ifadelerin sonucunu geri döndürür
function TMatematik.Sonuc(var SonucDeger: QWord): Integer;
begin

  // hatalı örnek ifade: ((1 + 2)
  if(FElemanSayisi > 0) then

    Result := HATA_KAPATMA_PAR_GEREKLI
  else
  begin

    FSayiToplami := FAktifIslem.Deger;
    SonucDeger := FSayiToplami;
    Result := 0;
  end;

  // işlem yapılıyor değişkenini güncelleştir
  FIslemYapiliyor := False;
end;

// tüm değerleri öndeğerlere ayarla
procedure TMatematik.Temizle;
begin

  FSayiToplami := 0;
  FElemanSayisi := 0;
  SetLength(FIslemDizi, FElemanSayisi);

  FAktifIslem.Isaret := iTopla;
  FAktifIslem.Deger := 0;

  // işlem yapılıyor değişkenini güncelleştir
  FIslemYapiliyor := False;
end;

end.
