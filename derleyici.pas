{-------------------------------------------------------------------------------

  Dosya: derleyici.pas

  İşlev: derleyicinin derlediği dosyaların yönetimini sağlar

  Güncelleme Tarihi: 25/08/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit derleyici;

interface

uses Classes, SysUtils, dosya, paylasim;

type
  TDerleyici = class
  private
    FDerlemeBasarili: Boolean;
    FDerlenenDosyaSayisi,
    FToplamDosyaSatirSayisi: Integer;
    FBicim: TDosyaBicim;
    FAktifDosya: PDosya;
    FAktifDosyaDegisti: Boolean;
    FDosyalar: TList;
    FDerlemeCevrimSayisi: Integer;
    FProjeDizin, FCikisDosyaAdi, FCikisDosyaUzanti: string;
    function AktifDosyaDegistiAl: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Ilklendir;
    function DosyaEkle(ADosya: PDosya; AnaDosya: Boolean): PDosya;
    function BirOncekiDosyayiAl: PDosya;
    procedure Temizle;
    procedure CevrimSayisiniArtir;
    function ToplamDosyaSayisiniAl: Integer;
    property AktifDosya: PDosya read FAktifDosya;
  published
    property ToplamDosyaSayisi: Integer read ToplamDosyaSayisiniAl;
    property DerlemeCevrimSayisi: Integer read FDerlemeCevrimSayisi
      write FDerlemeCevrimSayisi;
    property AktifDosyaDegisti: Boolean read AktifDosyaDegistiAl;
    property DerlemeBasarili: Boolean read FDerlemeBasarili write FDerlemeBasarili;
    property Bicim: TDosyaBicim read FBicim write FBicim;
    property ProjeDizin: string read FProjeDizin write FProjeDizin;
    property CikisDosyaAdi: string read FCikisDosyaAdi write FCikisDosyaAdi;
    property CikisDosyaUzanti: string read FCikisDosyaUzanti write FCikisDosyaUzanti;
    property DerlenenDosyaSayisi: Integer read FDerlenenDosyaSayisi write FDerlenenDosyaSayisi;
    property ToplamDosyaSatirSayisi: Integer read FToplamDosyaSatirSayisi
        write FToplamDosyaSatirSayisi;
  end;

implementation

uses genel;

function TDerleyici.AktifDosyaDegistiAl: Boolean;
begin

  Result := FAktifDosyaDegisti;
  FAktifDosyaDegisti := False;
end;

constructor TDerleyici.Create;
begin

  FDosyalar := TList.Create;

  FAktifDosya := nil;
  FDerlenenDosyaSayisi := 0;
  FToplamDosyaSatirSayisi := 0;
  FDerlemeCevrimSayisi := 0;
  FAktifDosyaDegisti := False;
end;

destructor TDerleyici.Destroy;
begin

  FDosyalar.Destroy;
  inherited Destroy;
end;

function TDerleyici.DosyaEkle(ADosya: PDosya; AnaDosya: Boolean): PDosya;
begin

  FDosyalar.Add(ADosya);

  ADosya^.IslenenKodSatirSayisi := 0;
  ADosya^.IslenenToplamSatir := 0;

  if not AnaDosya then FAktifDosyaDegisti := True;

  FAktifDosya := ADosya;

  Inc(FDerlenenDosyaSayisi);

  FToplamDosyaSatirSayisi += ADosya^.Satirlar.Count;

  Result := FAktifDosya;
end;

procedure TDerleyici.Ilklendir;
begin

  Temizle;

  FAktifDosya := nil;
  FDerlenenDosyaSayisi := 0;
  FToplamDosyaSatirSayisi := 0;
  FDerlemeCevrimSayisi := 0;
  FAktifDosyaDegisti := False;

  GAsm2.Dosyalar.DerleyiciDosyalariniKapat;
end;

function TDerleyici.BirOncekiDosyayiAl: PDosya;
var
  i: Integer;
  Dosya: PDosya;
begin

  Result := nil;
  if(FDosyalar.Count = 0) then Exit;

  //Dosya := FDosyalar.Items[FDosyalar.Count - 1];
  //FreeAndNil(Dosya);
  FDosyalar.Delete(FDosyalar.Count - 1);

  if(FDosyalar.Count = 0) then Exit;

  //ADosya^.IslenenKodSatirSayisi := 0;
  //ADosya^.IslenenToplamSatir := 0;

  Result := PDosya(FDosyalar.Items[FDosyalar.Count - 1]);
end;

procedure TDerleyici.Temizle;
begin

  FDosyalar.Clear;
end;

procedure TDerleyici.CevrimSayisiniArtir;
begin

  Inc(FDerlemeCevrimSayisi);
end;

function TDerleyici.ToplamDosyaSayisiniAl: Integer;
begin

  Result := FDosyalar.Count;
end;

end.
