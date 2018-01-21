{-------------------------------------------------------------------------------

  Dosya: matematik.pas

  İşlev: derleyici içerisinde kullanılacak tekli / çoklu matematiksel /
    mantıksal işlem ve parentez öncelikli işlevlerin çalıştırılarak
    sonuç değeri döndüren nesnesel yapı

  Güncelleme Tarihi: 21/01/2018

  Bilgilendirme:
    1. işlemler; önce işaret, sonra sayı olarak yapılmaktadır. ör: + 1 - 1 * 1 / 1
    2. her bir açma parantezi bir alt kademe işlem sahası açarken,
    3. her bir kapama parantezi bir üst kademede kalan işlemi tamamlamaktadır

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit matematik;

{ TODO : and, or, shl, shr mantıksal işlevleri eklenecek  }

interface

uses Classes, SysUtils;

type
  TIslem = record
    Isaret: Char;               // işlem ve parantez işareti (+-*/)
    DegerMevcutMu: Boolean;     // parantez öncesi değer mevcut mu?
    Deger: Integer;             // işlenecek değer
  end;

  TMatematik = class
  private
    FElemanSayisi,            // FIslemDizi dizisindeki eleman sayısı
    FSayiToplami: Integer;
    FSayiMevcut: Boolean;     // parantez öncesi sayı olup olmadığını belirtir
    FAktifIslem: TIslem;      // en son yapılan işlem
    FIslemDizi: array of TIslem;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SayiEkle(AIslem: string; ADegerMevcut: Boolean; ADeger: Integer);
    function ParantezEkle(Parantez: Char; DegerMevcut: Boolean;
      ADeger: Integer): Integer;
    function Sonuc(var SonucDeger: Integer): Integer;
    procedure Temizle;
  published
  end;

implementation

uses genel;

constructor TMatematik.Create;
begin

  // ilk değer atamaları
  FElemanSayisi := 0;
  FSayiToplami := 0;

  FSayiMevcut := False;

  FAktifIslem.Isaret := '+';
  FAktifIslem.Deger := 0;
end;

destructor TMatematik.Destroy;
begin

  if(FElemanSayisi > 0) then Temizle;

  inherited;
end;

// nesneye sayı ekleme işlevini yerine getirir
// AIslem değişkeni, ileriye yönelik mantıksal değerleri yönetmek için tasarlanmıştır
procedure TMatematik.SayiEkle(AIslem: string; ADegerMevcut: Boolean; ADeger: Integer);
begin

  // değerin mevcut olmaması halinde mevcut değerin işareti değiştirilir
  // ör: (3 + 1) - (3 + 1) işleminde - işareti solundaki değeri - olarak belirler
  if not(ADegerMevcut) then

    FAktifIslem.Isaret := AIslem[1]
  else
  begin

    // öncelikle mevcut işlemi gerçekleştir, daha sonra işareti ekle
    // ör: 1 + 2 gibi. buradaki işlem + 1 + 2 olarak değerlendirilmektedir
    case FAktifIslem.Isaret of
      '+': FAktifIslem.Deger := FAktifIslem.Deger + ADeger;
      '-': FAktifIslem.Deger := FAktifIslem.Deger - ADeger;
      '*': FAktifIslem.Deger := FAktifIslem.Deger * ADeger;
      '/': FAktifIslem.Deger := FAktifIslem.Deger div ADeger;
    end;

    // işlem yapıldıktan sonra bir sonraki işlemin işaretini ata
    if(Length(AIslem) = 1) then
      FAktifIslem.Isaret := AIslem[1]
    else FAktifIslem.Isaret := '+';

    FSayiMevcut := True;
  end;
end;

// öncelik içeren parantez işlemleri
function TMatematik.ParantezEkle(Parantez: Char; DegerMevcut: Boolean;
  ADeger: Integer): Integer;
begin

  if(Parantez = '(') then
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
      FAktifIslem.Isaret := '+';
      FAktifIslem.Deger := 0;
      Result := 0;
    end;
  end
  else if(Parantez = ')') then
  begin

    // 2/1 değer mevcut ise, aktif değere ekle
    if(DegerMevcut) then
    begin

      case FAktifIslem.Isaret of
        '+': FAktifIslem.Deger := FAktifIslem.Deger + ADeger;
        '-': FAktifIslem.Deger := FAktifIslem.Deger - ADeger;
        '*': FAktifIslem.Deger := FAktifIslem.Deger * ADeger;
        '/': FAktifIslem.Deger := FAktifIslem.Deger div ADeger;
      end;
    end;

    // 2/2 ve yığına atılmış değeri alarak bu değere ekle ve aktif değer olarak bırak
    // not: her bir ) işareti alt seviyeyi iptal ederek üst seviyeye çıkar
    if(FElemanSayisi > 0) then
    begin

      if(FIslemDizi[FElemanSayisi - 1].DegerMevcutMu = True) then
      begin

        case FIslemDizi[FElemanSayisi - 1].Isaret of
          '+': FAktifIslem.Deger := FAktifIslem.Deger + FIslemDizi[FElemanSayisi - 1].Deger;
          '-': FAktifIslem.Deger := FAktifIslem.Deger - FIslemDizi[FElemanSayisi - 1].Deger;
          '*': FAktifIslem.Deger := FAktifIslem.Deger * FIslemDizi[FElemanSayisi - 1].Deger;
          '/': FAktifIslem.Deger := FAktifIslem.Deger div FIslemDizi[FElemanSayisi - 1].Deger;
        end;
      end;

      Dec(FElemanSayisi);
      SetLength(FIslemDizi, FElemanSayisi);
    end;

    Result := 0;
  end;
end;

// girdilerden oluşan sayısal ifadelerin sonucunu geri döndürür
function TMatematik.Sonuc(var SonucDeger: Integer): Integer;
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
end;

// tüm değerleri öndeğerlere ayarla
procedure TMatematik.Temizle;
begin

  FSayiToplami := 0;
  FElemanSayisi := 0;
  SetLength(FIslemDizi, FElemanSayisi);

  FAktifIslem.Isaret := '+';
  FAktifIslem.Deger := 0;
end;

end.
