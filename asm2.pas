{-------------------------------------------------------------------------------

  Dosya: asm2.pas

  İşlev: derleyici içerisinde kullanılan tüm sınıfları yönetecek ana sınıf

  Güncelleme Tarihi: 25/02/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit asm2;

interface

uses Classes, SysUtils, ayarlar, atamalar, matematik;

type
  TMimari = (mim16Bit, mim32Bit, mim64Bit);

type
  TAsm2 = class
  private
    FMimari: TMimari;
    FDosyaAdi, FDosyaUzanti: string;
    FDerlemeBasarili: Boolean;
  public
    AtamaListesi: TAtamaListesi;
    Matematik: TMatematik;           // tüm çoklu matematiksel / mantıksal işlemleri yönetir
    FDerlemeCevrimSayisi: Integer;
    constructor Create;
    destructor Destroy; override;
    function ProgramAyarDosyasiniOku: TProgramAyarlari;
    procedure ProgramAyarDosyasinaYaz(ProgramAyarlari: TProgramAyarlari);
  published
    property Mimari: TMimari read FMimari write FMimari;
    property DosyaAdi: string read FDosyaAdi write FDosyaAdi;
    property DosyaUzanti: string read FDosyaUzanti write FDosyaUzanti;
    property DerlemeBasarili: Boolean read FDerlemeBasarili write FDerlemeBasarili;
    property DerlemeCevrimSayisi: Integer read FDerlemeCevrimSayisi
      write FDerlemeCevrimSayisi;
  end;

implementation

constructor TAsm2.Create;
begin

  AtamaListesi := TAtamaListesi.Create;
  Matematik := TMatematik.Create;

  FMimari := mim16Bit;
  FDosyaAdi := 'test';
  FDosyaUzanti := 'bin';
  FDerlemeBasarili := False;

  FDerlemeCevrimSayisi := 0;
end;

destructor TAsm2.Destroy;
begin

  Matematik.Destroy;
  AtamaListesi.Destroy;
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
