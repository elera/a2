{-------------------------------------------------------------------------------

  Dosya: etiket.pas
  İşlev: proje içerisindeki etiketleri (label) yönetir
  Tarih: 16/01/2018
  Bilgi:

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit etiket;

interface

uses Classes, SysUtils;

type
  TEtiketYapisi = record
    Ad: string;
    Adres: Integer;
    AtamaYapildi: Boolean;    // Adres değerine adres değeri atandı mı?
  end;

  TEtiket = class
  private
    FToplam: Integer;
    FEtiketler: array of TEtiketYapisi;
  public
    constructor Create;
    destructor Destroy; override;
    function Ekle(AAd: string; AAdres: Integer; AAtamaYapildi: Boolean): Integer;
    function Bul(AAd: string; var AAdres: Integer): Boolean;
    procedure Temizle;
  published
    property Toplam: Integer read FToplam;
  end;

implementation

uses genel;

constructor TEtiket.Create;
begin

  FToplam := 0;
end;

destructor TEtiket.Destroy;
begin

  if(FToplam > 0) then Temizle;

  inherited;
end;

function TEtiket.Ekle(AAd: string; AAdres: Integer; AAtamaYapildi: Boolean): Integer;
var
  i: Integer;
begin

  Result := 0;

  if(FToplam = 0) then
  begin

    Inc(FToplam);
    SetLength(FEtiketler, FToplam);
    FEtiketler[FToplam - 1].Ad := AAd;
    FEtiketler[FToplam - 1].Adres := AAdres;
    FEtiketler[FToplam - 1].AtamaYapildi := AAtamaYapildi;
  end
  else
  begin

    for i := 0 to FToplam - 1 do
    begin

      if(FEtiketler[i].Ad = AAd) then
      begin

        Result := HATA_ETIKET_TANIMLANMIS;
        Exit;
      end;
    end;

    Inc(FToplam);
    SetLength(FEtiketler, FToplam);
    FEtiketler[FToplam - 1].Ad := AAd;
    FEtiketler[FToplam - 1].Adres := AAdres;
    FEtiketler[FToplam - 1].AtamaYapildi := AAtamaYapildi;
  end;
end;

function TEtiket.Bul(AAd: string; var AAdres: Integer): Boolean;
var
  i: Integer;
begin

  Result := False;

  for i := 0 to FToplam - 1 do
  begin

    if(FEtiketler[i].Ad = AAd) and (FEtiketler[i].AtamaYapildi) then
    begin

      AAdres := FEtiketler[i].Adres;
      Result := True;
      Exit;
    end;
  end;
end;

procedure TEtiket.Temizle;
begin

  FToplam := 0;
  SetLength(FEtiketler, FToplam);
end;

end.