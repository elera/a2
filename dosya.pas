{-------------------------------------------------------------------------------

  Dosya: dosya.pas

  İşlev: dosya işlevlerini içerir

  Güncelleme Tarihi: 11/08/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit dosya;

interface

uses Classes, SysUtils, paylasim;

const
  // programın açacağı azami dosya sayısı
  AZAMI_DOSYA_SAYISI = 28;    // küüçük bir işaret :D

type
  TDosya = class(TCollectionItem)
  private
    FMimari: TMimari;
    FDurum: TDosyaDurum;
    FKimlik, FSiraNo: Integer;
    FProjeDizin,
    FProjeDosyaAdi, FProjeDosyaUzanti,
    FCikisDosyaAdi, FCikisDosyaUzanti: string;
    FBellekAdresi: QWord;
    FDerlemeBasarili: Boolean;
    FDerlemeCevrimSayisi: Integer;
    FIslenenSatirSayisi,            // işlenen toplam satır sayısı (boş satırlar dahil değildir)
    FIslenenSatir: Integer;         // o anda işlenen satır (hata olduğunda hatanın olduğu satır)
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    procedure SetCikisDosyaUzanti(ACikisDosyaUzanti: string);
  published
    property Mimari: TMimari read FMimari write FMimari;
    property Durum: TDosyaDurum read FDurum write FDurum;
    property Kimlik: Integer read FKimlik write FKimlik;
    property SiraNo: Integer read FSiraNo write FSiraNo;
    property ProjeDizin: string read FProjeDizin write FProjeDizin;
    property ProjeDosyaAdi: string read FProjeDosyaAdi write FProjeDosyaAdi;
    property ProjeDosyaUzanti: string read FProjeDosyaUzanti write FProjeDosyaUzanti;
    property CikisDosyaAdi: string read FCikisDosyaAdi write FCikisDosyaAdi;
    property CikisDosyaUzanti: string read FCikisDosyaUzanti write FCikisDosyaUzanti;
    property BellekAdresi: QWord read FBellekAdresi write FBellekAdresi;
    property DerlemeBasarili: Boolean read FDerlemeBasarili write FDerlemeBasarili;
    property DerlemeCevrimSayisi: Integer read FDerlemeCevrimSayisi
      write FDerlemeCevrimSayisi;
    property IslenenSatirSayisi: Integer read FIslenenSatirSayisi write FIslenenSatirSayisi;
    property IslenenSatir: Integer read FIslenenSatir write FIslenenSatir;
  end;

type
  TDosyalar = class(TCollection)
  private
    function Al(ASiraNo: Integer): TDosya;
    procedure Ver(ASiraNo: Integer; AEtiket: TDosya);
    function GetToplam: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function Ekle(ATamYolDosyaAdi: string; YeniDosya: Boolean; var DosyaAcik:
      Boolean): TDosya;
    function Bul(Kimlik: Integer): TDosya;
    function Sil(Kimlik: Integer): Boolean;
    procedure Temizle;
    property Toplam: Integer read GetToplam;
    property Eleman[Sira: Integer]: TDosya read Al write Ver;
  end;

function ProgramDosyasiOlustur(DosyaAdi: string): Boolean;
function DosyaYolunuAyristir(TamDosyaYolu: string; var Dizin, DosyaAdi, DosyaUzanti: string): Boolean;

implementation

uses genel, Forms;

var
  KimlikSayaci: Integer;

constructor TDosyalar.Create;
begin

  KimlikSayaci := 0;

  inherited Create(TDosya);
end;

destructor TDosyalar.Destroy;
begin

  inherited Destroy;
end;

function TDosyalar.Al(ASiraNo: Integer): TDosya;
begin

  Result := TDosya(inherited GetItem(ASiraNo));
end;

procedure TDosyalar.Ver(ASiraNo: Integer; AEtiket: TDosya);
begin

  inherited SetItem(ASiraNo, AEtiket);
end;

function TDosyalar.GetToplam: Integer;
begin

  Result := inherited Count;
end;

// dosyanın, dosya listesine eklenmesini sağlar
function TDosyalar.Ekle(ATamYolDosyaAdi: string; YeniDosya: Boolean; var DosyaAcik:
  Boolean): TDosya;
var
  Dosya: TDosya;
  i: Integer;
  Dizin, DosyaAdi, DosyaUzanti: string;

  function YeniDosyaOlustur: TDosya;
  begin

    Result := nil;

    if(Toplam < AZAMI_DOSYA_SAYISI) then
    begin

      Inc(KimlikSayaci);

      Result := inherited Add as TDosya;
      Result.Kimlik := KimlikSayaci;
    end;
  end;
begin

  // 1. dosyanın yeni olması durumunda...
  if(YeniDosya) then
  begin

    Dosya := YeniDosyaOlustur;
    if not(Dosya = nil) then
    begin

      // bu değer yeni dosya için (bu aşamada) anlamsız
      DosyaAcik := False;

      Dosya.Durum := ddYeni;

      Dosya.ProjeDizin := GSonKullanilanDizin;
      Dosya.ProjeDosyaAdi := Format('Dosya%d', [Dosya.Kimlik]);
      Dosya.ProjeDosyaUzanti := 'asm';

      Dosya.CikisDosyaAdi := Dosya.ProjeDosyaAdi;
      Dosya.CikisDosyaUzanti := Dosya.ProjeDosyaUzanti;
    end;
    Result := Dosya;
  end
  else
  // 2. dosyanın daha önce kayıtlı bir dosya olması durumunda...
  begin

    if(DosyaYolunuAyristir(ATamYolDosyaAdi, Dizin, DosyaAdi, DosyaUzanti)) then
    begin

      // dosyanın daha önce açık olup olmadığı kontrol ediliyor...
      for i := 0 to Toplam - 1 do
      begin

        Dosya := GAsm2.Dosyalar.Eleman[i];
        if(Dosya.ProjeDizin = Dizin) and (Dosya.ProjeDosyaAdi = DosyaAdi) and
          (Dosya.ProjeDosyaUzanti = DosyaUzanti) and (Dosya.Durum = ddKaydedildi) then
        begin

          // dosyanın açık olduğu bilgisini geri döndür
          DosyaAcik := True;
          Result := Dosya;
          Exit;
        end;
      end;

      // dosya, kayıtlarda mevcut olmadığı için yeni dosya yapısı oluşturuluyor
      Dosya := YeniDosyaOlustur;
      if not(Dosya = nil) then
      begin

        // dosyanın açık olmadığı bilgisini geri döndür
        DosyaAcik := False;

        Dosya.Durum := ddKaydedildi;

        Dosya.ProjeDizin := Dizin;
        Dosya.ProjeDosyaAdi := DosyaAdi;
        Dosya.ProjeDosyaUzanti := DosyaUzanti;

        Dosya.CikisDosyaAdi := Dosya.ProjeDosyaAdi;
        Dosya.CikisDosyaUzanti := Dosya.ProjeDosyaUzanti;
      end;
      Result := Dosya;
    end;
  end;
end;

function TDosyalar.Bul(Kimlik: Integer): TDosya;
var
  i: Integer;
begin

  Result := nil;

  for i := 0 to Toplam - 1 do
  begin

    if(Eleman[i].Kimlik = Kimlik) then
    begin

      Result := Eleman[i];
      Exit;
    end;
  end;
end;

function TDosyalar.Sil(Kimlik: Integer): Boolean;
var
  i: Integer;
begin

  Result := False;

  for i := 0 to Toplam - 1 do
  begin

    if(Eleman[i].Kimlik = Kimlik) then
    begin

      inherited Delete(i);
      Result := True;
      Exit;
    end;
  end;
end;

procedure TDosyalar.Temizle;
begin

  inherited Clear;
end;

constructor TDosya.Create(ACollection: TCollection);
begin

  inherited Create(ACollection);
end;

destructor TDosya.Destroy;
begin

  inherited Destroy;
end;

procedure TDosya.SetCikisDosyaUzanti(ACikisDosyaUzanti: string);
begin

  if(FCikisDosyaUzanti = ACikisDosyaUzanti) then Exit;

  FCikisDosyaUzanti := ACikisDosyaUzanti;
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
function ProgramDosyasiOlustur(DosyaAdi: string): Boolean;
var
  F: file of Byte;
  i: Integer;
  s: string;
begin

  AssignFile(F, DosyaAdi);
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
    Result := True;
  end else Result := False;

  {$IFDEF Linux}
  RunCommand('chmod +x ' + DosyaAdi, s);
  {$ENDIF}
end;

end.
