{-------------------------------------------------------------------------------

  Dosya: dosya.pas

  İşlev: dosya işlevlerini içerir

  Güncelleme Tarihi: 28/10/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit dosya;

interface

uses Classes, SysUtils, paylasim;

type
  TDosya = class
  private
    FDurum: TDosyaDurum;
    FKimlik, FSiraNo: Integer;
    FProjeDizin,
    FProjeDosyaAdi, FProjeDosyaUzanti: string;
    FBellekAdresi: QWord;
    FIslenenKodSatirSayisi,         // işlenen toplam kod satır sayısı (boş satırlar dahil değildir)
    FIslenenToplamSatir: Integer;   // o anda işlenen satır (hata olduğunda hatanın olduğu satır)
    FSatirlar: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    function Yukle(CP1254KarakterSetiniKullan: Boolean): Boolean;
    function Kaydet(sl: TStrings): Boolean;
    procedure IslenenKodSatirSayisiniArtir;
    procedure IslenenToplamSatirSayisiniArtir;
  published
    property Durum: TDosyaDurum read FDurum write FDurum;
    property Kimlik: Integer read FKimlik write FKimlik;
    property SiraNo: Integer read FSiraNo write FSiraNo;
    property ProjeDizin: string read FProjeDizin write FProjeDizin;
    property ProjeDosyaAdi: string read FProjeDosyaAdi write FProjeDosyaAdi;
    property ProjeDosyaUzanti: string read FProjeDosyaUzanti write FProjeDosyaUzanti;
    property BellekAdresi: QWord read FBellekAdresi write FBellekAdresi;
    property IslenenKodSatirSayisi: Integer read FIslenenKodSatirSayisi
      write FIslenenKodSatirSayisi;
    property IslenenToplamSatir: Integer read FIslenenToplamSatir
      write FIslenenToplamSatir;
    property Satirlar: TStringList read FSatirlar;
  end;

type
  TDosyalar = class
  private
    FKimlikSayaci: Integer;
    FDosyaSayisi: Integer;
    FDosyaListesi: TList;
    function DosyaSayisiAl: Integer;
    function DosyaAl(SiraNo: Integer): TDosya;
  public
    constructor Create;
    destructor Destroy; override;
    function ListeyeEkle(ATamYolDosyaAdi: string; Durum: TDosyaDurum; var DosyaAcik:
      Boolean): TDosya;
    function Bul(Kimlik: Integer): TDosya;
    function Sil(AKimlik: Integer): Boolean;
    procedure Temizle;
    procedure BellektekiDosyalariKapat;
    property DosyaSayisi: Integer read DosyaSayisiAl;
    property Dosya[Sira: Integer]: TDosya read DosyaAl;
  end;

function DosyaYolunuAyristir(TamDosyaYolu: string; var Dizin, DosyaAdi, DosyaUzanti: string): Boolean;

implementation

uses genel, Forms, LConvEncoding, dbugintf;

constructor TDosyalar.Create;
begin

  FDosyaListesi := TList.Create;

  FKimlikSayaci := 0;
end;

destructor TDosyalar.Destroy;
begin

  Temizle;

  FreeAndNil(FDosyaListesi);

  inherited;
end;

procedure TDosyalar.Temizle;
var
  i: Integer;
begin

  if(DosyaSayisi > 0) then
  begin

    for i := DosyaSayisi - 1 downto 0 do
    begin

      Dosya[i].Destroy;
    end;
  end;

  FDosyaListesi.Clear;
end;

function TDosyalar.ListeyeEkle(ATamYolDosyaAdi: string; Durum: TDosyaDurum; var DosyaAcik:
  Boolean): TDosya;
var
  i: Integer;
  Dizin, DosyaAdi, DosyaUzanti: string;
  D: TDosya;

  function YeniDosyaOlustur: Boolean;
  begin

    Result := False;

    if(DosyaSayisi < AZAMI_DOSYA_SAYISI) then
    begin

      Inc(FKimlikSayaci);

      D := TDosya.Create;
      D.Kimlik := FKimlikSayaci;

      Result := True;
    end;
  end;
begin

  // 1. dosyanın yeni olması durumunda...
  if(Durum = ddYeni) then
  begin

    if(YeniDosyaOlustur) then
    begin

      // bu değer yeni dosya için (bu aşamada) anlamsız
      DosyaAcik := False;

      D.Durum := Durum;

      D.ProjeDizin := GSonKullanilanDizin;
      D.ProjeDosyaAdi := Format('Dosya%d', [D.Kimlik]);
      D.ProjeDosyaUzanti := 'asm';

      FDosyaListesi.Add(D);

      Result := D;
    end else Result := nil;
  end
  else
  // 2. dosyanın daha önce kayıtlı bir dosya olması durumunda...
  // ddBellekte koşulu test ediliyor
  begin

    if(DosyaYolunuAyristir(ATamYolDosyaAdi, Dizin, DosyaAdi, DosyaUzanti)) then
    begin

      // dosyanın daha önce düzenleyicide açık olup olmadığı kontrol ediliyor.
      if(DosyaSayisi > 0) then
      begin

        for i := 0 to DosyaSayisi - 1 do
        begin

          D := Dosya[i];
          if(D.ProjeDizin = Dizin) and (D.ProjeDosyaAdi = DosyaAdi) and
            (D.ProjeDosyaUzanti = DosyaUzanti) {and (D.Durum = ddKaydedildi)} then
          begin

            // dosyanın açık olduğu bilgisini geri döndür
            DosyaAcik := True;
            Result := D;
            Exit;
          end;
        end;
      end;

      // dosya, kayıtlarda mevcut olmadığı için yeni dosya yapısı oluşturuluyor
      if(YeniDosyaOlustur) then
      begin

        // dosyanın açık olmadığı bilgisini geri döndür
        DosyaAcik := False;

        D.Durum := ddBellekte;     // dosyanın bellekte açılacağını bildirir

        D.ProjeDizin := Dizin;
        D.ProjeDosyaAdi := DosyaAdi;
        D.ProjeDosyaUzanti := DosyaUzanti;

        FDosyaListesi.Add(D);

        Result := D;
      end else Result := nil;
    end;
  end;
end;

function TDosyalar.DosyaSayisiAl: Integer;
begin

  Result := FDosyaListesi.Count;
end;

function TDosyalar.DosyaAl(SiraNo: Integer): TDosya;
begin

  Result := nil;

  if(SiraNo >= 0) and (SiraNo < DosyaSayisi) then
    Result := TDosya(FDosyaListesi[SiraNo]);
end;

function TDosyalar.Bul(Kimlik: Integer): TDosya;
var
  i: Integer;
  D: TDosya;
begin

  if(DosyaSayisi > 0) then
  begin

    for i := 0 to DosyaSayisi - 1 do
    begin

      D := Dosya[i];
      if(D.Kimlik = Kimlik) then
      begin

        Result := D;
        Exit;
      end;
    end;
  end;

  Result := nil;
end;

function TDosyalar.Sil(AKimlik: Integer): Boolean;
var
  i: Integer;
begin

  if(DosyaSayisi > 0) then
  begin

    for i := 0 to DosyaSayisi - 1 do
    begin

      if(Dosya[i].Kimlik = AKimlik) then
      begin

        Dosya[i].Destroy;
        FDosyaListesi.Delete(i);
        Result := True;
        Exit;
      end;
    end;
  end;

  Result := False;
end;

// derleyicinin yeniden derleme yapmadan önce bellketeki dosyaları kapatma işlemi
procedure TDosyalar.BellektekiDosyalariKapat;
var
  i: Integer;
begin

  if(DosyaSayisi > 0) then
  begin

    for i := DosyaSayisi - 1 downto 0 do
    begin

      // sadece bellkete açılan dosyalar
      if(Dosya[i].Durum = ddBellekte) then
      begin

        Sil(Dosya[i].Kimlik);
      end;
    end;
  end;
end;

constructor TDosya.Create;
begin

  FSatirlar := TStringList.Create;
end;

destructor TDosya.Destroy;
begin

  FSatirlar.Clear;

  FreeAndNil(FSatirlar);

  inherited;
end;

function TDosya.Yukle(CP1254KarakterSetiniKullan: Boolean): Boolean;
var
  YaziDosya: TextFile;
  Veri, s: string;
begin

  Result := False;

  FSatirlar.Clear;

  if(Length(FProjeDosyaUzanti) > 0) then
    s := FProjeDosyaAdi + '.' + FProjeDosyaUzanti
  else s := FProjeDosyaAdi;

  AssignFile(YaziDosya, FProjeDizin + DirectorySeparator + s);
  {$I-} Reset(YaziDosya); {$I+}

  if(IOResult = 0) then
  begin

    while not EOF(YaziDosya) do
    begin

      ReadLn(YaziDosya, Veri);

      if(CP1254KarakterSetiniKullan) then
        FSatirlar.Add(CP1254ToUTF8(Veri))
      else FSatirlar.Add(Veri);

      Application.ProcessMessages;
    end;

    CloseFile(YaziDosya);

    Result := True;
  end;
end;

function TDosya.Kaydet(sl: TStrings): Boolean;
var
  YaziDosya: TextFile;
  s: string;
  i: Integer;
begin

  Result := False;

  FSatirlar.Assign(sl);

  if(Length(FProjeDosyaUzanti) > 0) then
    s := FProjeDosyaAdi + '.' + FProjeDosyaUzanti
  else s := FProjeDosyaAdi;

  AssignFile(YaziDosya, FProjeDizin + DirectorySeparator + s);
  {$I-} Rewrite(YaziDosya); {$I+}

  if(IOResult = 0) then
  begin

    i := 0;
    while i < FSatirlar.Count do
    begin

      WriteLn(YaziDosya, FSatirlar[i]);
      Inc(i);
      Application.ProcessMessages;
    end;

    CloseFile(YaziDosya);

    Result := True;
  end;
end;

procedure TDosya.IslenenKodSatirSayisiniArtir;
begin

  Inc(FIslenenKodSatirSayisi);
end;

procedure TDosya.IslenenToplamSatirSayisiniArtir;
begin

  Inc(FIslenenToplamSatir);
end;

// tam dosya yolunu; dizin, dosya adı ve dosya uzantısı olarak ayrıştırır
function DosyaYolunuAyristir(TamDosyaYolu: string; var Dizin, DosyaAdi, DosyaUzanti: string): Boolean;
var
  s: string;
  i, j: Integer;
  Found: Boolean;
begin

  // tam dosya yolu belirtilmemişse, çık
  Result := False;
  if(Length(TamDosyaYolu) = 0) then Exit;

  // dosya adı alınamıyorsa, çık
  s := ExtractFileName(TamDosyaYolu);
  i := Length(s);
  if(i = 0) then Exit;

  // dosya yolunun dizin bilgisini al
  Dizin := ExtractFileDir(TamDosyaYolu);

  // dosya uzantısının olup olmadığını kontrol et
  j := i;
  Found := False;
  while (j > 0) and not Found do
  begin

    if(s[j] = '.') then
      Found := True
    else Dec(j);
  end;

  // dosya uzantısı var ise...
  if(j > 0) then
  begin

    DosyaAdi := Copy(s, 1, j - 1);
    DosyaUzanti := Copy(s, j + 1, i - j);
  end
  else
  begin

    DosyaAdi := s;
    DosyaUzanti := '';
  end;

  Result := True;
end;

end.
