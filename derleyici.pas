{-------------------------------------------------------------------------------

  Dosya: derleyici.pas

  İşlev: derleyicinin derlediği dosyaların yönetimini sağlar

  Güncelleme Tarihi: 31/08/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit derleyici;

interface

uses Classes, SysUtils, dosya, paylasim;

type
  TDerleyici = class
  private
    FMimari: TMimari;
    FDerlemeBasarili: Boolean;
    FDerlenenDosyaSayisi,
    FToplamDosyaSatirSayisi: Integer;
    FBicim: TDosyaBicim;
    FAktifDosya: TDosya;
    FAktifDosyaDegisti: Boolean;
    FDosyalar: TList;
    FDerlemeCevrimSayisi: Integer;
    FProjeDizin, FCikisDosyaAdi, FCikisDosyaUzanti: string;
    function AktifDosyaDegistiAl: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Ilklendir;
    function DosyaEkle(ADosya: TDosya; AnaDosya: Boolean): TDosya;
    function BirOncekiDosyayiAl: TDosya;
    procedure Temizle;
    procedure CevrimSayisiniArtir;
    function ToplamDosyaSayisiniAl: Integer;
    function ProgramDosyasiOlustur: Integer;
    property AktifDosya: TDosya read FAktifDosya;
  published
    property Mimari: TMimari read FMimari write FMimari;
    property ToplamDosyaSayisi: Integer read ToplamDosyaSayisiniAl;
    property DerlemeCevrimSayisi: Integer read FDerlemeCevrimSayisi
      write FDerlemeCevrimSayisi;
    property AktifDosyaDegisti: Boolean read AktifDosyaDegistiAl;
    property DerlemeBasarili: Boolean read FDerlemeBasarili write FDerlemeBasarili;
    property Bicim: TDosyaBicim read FBicim write FBicim;
    property ProjeDizin: string read FProjeDizin write FProjeDizin;
    property CikisDosyaAdi: string read FCikisDosyaAdi write FCikisDosyaAdi;
    property CikisDosyaUzanti: string read FCikisDosyaUzanti write FCikisDosyaUzanti;
    property DerlenenDosyaSayisi: Integer read FDerlenenDosyaSayisi
      write FDerlenenDosyaSayisi;
    property ToplamDosyaSatirSayisi: Integer read FToplamDosyaSatirSayisi
      write FToplamDosyaSatirSayisi;
  end;

implementation

uses Forms, genel;

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

  FMimari := mim16Bit;
end;

destructor TDerleyici.Destroy;
begin

  FDosyalar.Destroy;
  inherited Destroy;
end;

function TDerleyici.DosyaEkle(ADosya: TDosya; AnaDosya: Boolean): TDosya;
begin

  FDosyalar.Add(ADosya);

  ADosya.IslenenKodSatirSayisi := 0;
  ADosya.IslenenToplamSatir := 0;

  if not AnaDosya then FAktifDosyaDegisti := True;

  Inc(FDerlenenDosyaSayisi);

  FToplamDosyaSatirSayisi += ADosya.Satirlar.Count;

  FAktifDosya := ADosya;

  Result := ADosya;
end;

procedure TDerleyici.Ilklendir;
begin

  GAsm2.Dosyalar.BellektekiDosyalariKapat;

  Temizle;

  FAktifDosya := nil;
  FDerlenenDosyaSayisi := 0;
  FToplamDosyaSatirSayisi := 0;
  FAktifDosyaDegisti := False;

  FMimari := mim16Bit;
end;

function TDerleyici.BirOncekiDosyayiAl: TDosya;
begin

  Result := nil;
  if(FDosyalar.Count = 0) then Exit;

  // mevcut dosyayı dosya listesinden çıkar
  FDosyalar.Delete(FDosyalar.Count - 1);

  // eğer varsa ...
  if(FDosyalar.Count = 0) then Exit;

  // ... listedeki dosyayı işleve geri döndür
  Result := TDosya(FDosyalar.Items[FDosyalar.Count - 1]);
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

// ikili dosya biçiminde (binary file format) dosya oluştur
function TDerleyici.ProgramDosyasiOlustur: Integer;
var
  F: file of Byte;
  i: Integer;
  s: string;
begin

  if(Bicim = dbIkili) then
  begin

    // dosya uzantısının olmaması durumunda dosyaya uzantı ekleme (özellikle linux için)
    if(Length(CikisDosyaUzanti) > 0) then
      s := ProjeDizin + DirectorySeparator + CikisDosyaAdi + '.' + CikisDosyaUzanti
    else s := ProjeDizin + DirectorySeparator + CikisDosyaAdi;

    AssignFile(F, s);
    {$I-} Rewrite(F); {$I+}

    if(IOResult = 0) then
    begin

      if(KodBellekU > 0) then
      begin

        for i := 0 to KodBellekU - 1 do
        begin

          Write(F, KodBellek[i]);
          Application.ProcessMessages;
        end;
      end;

      CloseFile(F);
      Result := HATA_YOK;
    end else Result := HATA_PROG_DOSYA_OLUSTURMA;

    {$IFDEF Linux}
    RunCommand('chmod +x ' + s, s);
    {$ENDIF}

  end else Result := HATA_DESTEKLENMEYEN_BICIM;
end;

end.
