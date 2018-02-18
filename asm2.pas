{-------------------------------------------------------------------------------

  Dosya: asm2.pas

  İşlev: derleyici içerisinde kullanılan tüm sınıfları yönetecek ana sınıf

  Güncelleme Tarihi: 17/02/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit asm2;

interface

uses Classes, SysUtils, ayarlar, etiket;

type
  TMimari = (mim16Bit, mim32Bit, mim64Bit);

type
  TAsm2 = class
  private
    FMimari: TMimari;
    FDosyaAdi, FDosyaUzanti: string;
    FDerlemeBasarili: Boolean;
  public
    Etiketler: TEtiketler;
    constructor Create;
    destructor Destroy; override;
    function ProgramAyarDosyasiniOku: TProgramAyarlari;
    procedure ProgramAyarDosyasinaYaz(ProgramAyarlari: TProgramAyarlari);
  published
    property Mimari: TMimari read FMimari write FMimari;
    property DosyaAdi: string read FDosyaAdi write FDosyaAdi;
    property DosyaUzanti: string read FDosyaUzanti write FDosyaUzanti;
    property DerlemeBasarili: Boolean read FDerlemeBasarili write FDerlemeBasarili;
  end;

implementation

constructor TAsm2.Create;
begin

  Etiketler := TEtiketler.Create;

  FMimari := mim16Bit;
  FDosyaAdi := 'test';
  FDosyaUzanti := 'bin';
  FDerlemeBasarili := False;
end;

destructor TAsm2.Destroy;
begin

  Etiketler.Destroy;
end;

function TAsm2.ProgramAyarDosyasiniOku: TProgramAyarlari;
begin

  Result := INIDosyasiniOku;
end;

procedure TAsm2.ProgramAyarDosyasinaYaz(ProgramAyarlari: TProgramAyarlari);
begin

  INIDosyasinaYaz(ProgramAyarlari);
end;

end.
