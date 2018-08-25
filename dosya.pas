{-------------------------------------------------------------------------------

  Dosya: dosya.pas

  İşlev: dosya işlevlerini içerir

  Güncelleme Tarihi: 25/08/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit dosya;

interface

uses Classes, SysUtils, paylasim;

type
  PDosya = ^TDosya;
  TDosya = class
  private
    FMimari: TMimari;
    FDurum: TDosyaDurum;
    FKimlik, FSiraNo: Integer;
    FProjeDizin,
    FProjeDosyaAdi, FProjeDosyaUzanti: string;
    FBellekAdresi: QWord;
    FAcikOlmaDurumu: TDosyaAcikDurum;
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
    property Mimari: TMimari read FMimari write FMimari;
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
    FDosyaListesi: array of TDosya;
    function Al(ASiraNo: Integer): PDosya;
    function ToplamAl: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function Ekle(ATamYolDosyaAdi: string; Durum: TDosyaDurum; var DosyaAcik:
      Boolean): PDosya;
    function Bul(Kimlik: Integer): PDosya;
    function Sil(AKimlik: Integer): Boolean;
    procedure Temizle;
    procedure DerleyiciDosyalariniKapat;
    property Toplam: Integer read ToplamAl;
    property Eleman[Sira: Integer]: PDosya read Al;
  end;

function ProgramDosyasiOlustur: Integer;
function DosyaYolunuAyristir(TamDosyaYolu: string; var Dizin, DosyaAdi, DosyaUzanti: string): Boolean;

implementation

uses genel, Forms, LConvEncoding;

constructor TDosyalar.Create;
begin

  FKimlikSayaci := 0;

  FDosyaSayisi := 0;
  SetLength(FDosyaListesi, FDosyaSayisi);
end;

destructor TDosyalar.Destroy;
begin

  Temizle;
  inherited;
end;

function TDosyalar.Al(ASiraNo: Integer): PDosya;
begin

  Result := nil;

  if(ASiraNo >= 0) and (ASiraNo < FDosyaSayisi) then
    Result := @FDosyaListesi[ASiraNo];
end;

function TDosyalar.ToplamAl: Integer;
begin

  Result := FDosyaSayisi;
end;

function TDosyalar.Ekle(ATamYolDosyaAdi: string; Durum: TDosyaDurum; var DosyaAcik:
  Boolean): PDosya;
var
  i: Integer;
  Dizin, DosyaAdi, DosyaUzanti: string;
  Dosya: TDosya;

  function YeniDosyaOlustur: Boolean;
  begin

    Result := False;

    if(Toplam < AZAMI_DOSYA_SAYISI) then
    begin

      Inc(FKimlikSayaci);

      Dosya := TDosya.Create;
      Dosya.Kimlik := FKimlikSayaci;

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

      Dosya.Durum := Durum;

      Dosya.ProjeDizin := GSonKullanilanDizin;
      Dosya.ProjeDosyaAdi := Format('Dosya%d', [Dosya.Kimlik]);
      Dosya.ProjeDosyaUzanti := 'asm';

      Inc(FDosyaSayisi);
      SetLength(FDosyaListesi, FDosyaSayisi);
      FDosyaListesi[FDosyaSayisi - 1] := Dosya;

      Result := @FDosyaListesi[FDosyaSayisi - 1];
    end else Result := nil;
  end
  else
  // 2. dosyanın daha önce kayıtlı bir dosya olması durumunda...
  begin

    if(DosyaYolunuAyristir(ATamYolDosyaAdi, Dizin, DosyaAdi, DosyaUzanti)) then
    begin

      // dosya durumunun ddKaydedildi olması durumunda, dosyanın daha önce açık
      // olup olmadığı kontrol ediliyor.
      // ddDerleyici durumunda bu kontrol yoktur. her bir ddDerleyici isteğinde
      // dosyanın bir kopyası daha belleğe açılmaktadır. (tasarım gereği)
      if(Durum = ddKaydedildi) then
      begin

        if(FDosyaSayisi > 0) then
        begin

          for i := 0 to FDosyaSayisi - 1 do
          begin

            Dosya := FDosyaListesi[i];
            if(Dosya.ProjeDizin = Dizin) and (Dosya.ProjeDosyaAdi = DosyaAdi) and
              (Dosya.ProjeDosyaUzanti = DosyaUzanti) and (Dosya.Durum = ddKaydedildi) then
            begin

              // dosyanın açık olduğu bilgisini geri döndür
              DosyaAcik := True;
              Result := @Dosya;
              Exit;
            end;
          end;
        end;
      end;

      // dosya, kayıtlarda mevcut olmadığı için yeni dosya yapısı oluşturuluyor
      if(YeniDosyaOlustur) then
      begin

        // dosyanın açık olmadığı bilgisini geri döndür
        DosyaAcik := False;

        Dosya.Durum := Durum;

        Dosya.ProjeDizin := Dizin;
        Dosya.ProjeDosyaAdi := DosyaAdi;
        Dosya.ProjeDosyaUzanti := DosyaUzanti;

        Inc(FDosyaSayisi);
        SetLength(FDosyaListesi, FDosyaSayisi);
        FDosyaListesi[FDosyaSayisi - 1] := Dosya;

        Result := @FDosyaListesi[FDosyaSayisi - 1];
      end else Result := nil;
    end;
  end;
end;

function TDosyalar.Bul(Kimlik: Integer): PDosya;
var
  i: Integer;
begin

  Result := nil;

  for i := 0 to FDosyaSayisi - 1 do
  begin

    if(FDosyaListesi[i].Kimlik = Kimlik) then
    begin

      Result := @FDosyaListesi[i];
      Exit;
    end;
  end;
end;

function TDosyalar.Sil(AKimlik: Integer): Boolean;
var
  i, j: Integer;
  FYedekDosyaListesi: array of TDosya;
begin

  Result := False;
  if(FDosyaSayisi = 0) then Exit;

  // eski kayıtlar yedeklenirken silinecek kayıt yok ediliyor
  j := 0;
  for i := 0 to FDosyaSayisi - 1 do
  begin

    if(FDosyaListesi[i].Kimlik = AKimlik) then
    begin

      FDosyaListesi[i].Destroy;
    end
    else
    begin

      Inc(j);
      SetLength(FYedekDosyaListesi, j);
      FYedekDosyaListesi[j - 1] := FDosyaListesi[i];
    end;
  end;

  // silinecek veri silindikten sonra (eğer var ise) yedeklenen kayıtlar
  // eski yerine bırakılıyor
  FDosyaSayisi := j;
  SetLength(FDosyaListesi, FDosyaSayisi);

  if(FDosyaSayisi > 0) then
  begin

    for i := 0 to FDosyaSayisi - 1 do
    begin

      FDosyaListesi[i] := FYedekDosyaListesi[i];
    end;
  end;

  // rezerv edilen geçici bellek iptal ediliyor
  SetLength(FYedekDosyaListesi, 0);
  Result := True;
end;

procedure TDosyalar.Temizle;
var
  i: Integer;
begin

  if(FDosyaSayisi > 0) then
  begin

    for i := FDosyaSayisi - 1 downto 0 do
    begin

      FDosyaListesi[i].Destroy;
    end;
  end;

  FDosyaSayisi := 0;
  SetLength(FDosyaListesi, FDosyaSayisi);
end;

// derleyicinin yeniden derleme yapmadan önce tüm dosyaları kapatma işlemi
procedure TDosyalar.DerleyiciDosyalariniKapat;
var
  i: Integer;
begin

  if(FDosyaSayisi > 0) then
  begin

    for i := FDosyaSayisi - 1 downto 0 do
    begin

      // sadece derleyici için açılan dosyalar kapatılıyor
      if(FDosyaListesi[i].Durum = ddDerleyici) then
      begin

        Sil(FDosyaListesi[i].Kimlik);
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

  FreeAndNil(FSatirlar);

  inherited Destroy;
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

// ikili dosya biçiminde (binary file format) dosya oluştur
function ProgramDosyasiOlustur: Integer;
var
  F: file of Byte;
  i: Integer;
  s: string;
begin

  if(GAsm2.Derleyici.Bicim = dbIkili) then
  begin

    // dosya uzantısının olmaması durumunda dosyaya uzantı ekleme (özellikle linux için)
    if(Length(GAsm2.Derleyici.CikisDosyaUzanti) > 0) then
      s := GAsm2.Derleyici.ProjeDizin + DirectorySeparator +
        GAsm2.Derleyici.CikisDosyaAdi + '.' + GAsm2.Derleyici.CikisDosyaUzanti
    else s := GAsm2.Derleyici.ProjeDizin + DirectorySeparator + GAsm2.Derleyici.CikisDosyaAdi;

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
