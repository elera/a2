{-------------------------------------------------------------------------------

  Dosya: asm2.pas

  İşlev: derleyici içerisinde kullanılan tüm sınıfları yönetecek ana sınıf

  Güncelleme Tarihi: 11/08/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit asm2;

interface

uses Classes, SysUtils, ayarlar, atamalar, matematik, dosya;

type
  TAsm2 = class
  private
  public
    Dosyalar: TDosyalar;
    AtamaListesi: TAtamaListesi;
    Matematik: TMatematik;           // tüm çoklu matematiksel / mantıksal işlemleri yönetir
    constructor Create;
    destructor Destroy; override;
    function ProgramAyarDosyasiniOku: TProgramAyarlari;
    procedure ProgramAyarDosyasinaYaz(ProgramAyarlari: TProgramAyarlari);
  published
  end;

implementation

uses genel;

constructor TAsm2.Create;
begin

  Dosyalar := TDosyalar.Create;
  AtamaListesi := TAtamaListesi.Create;
  Matematik := TMatematik.Create;
end;

destructor TAsm2.Destroy;
begin

  Matematik.Destroy;
  AtamaListesi.Destroy;
  Dosyalar.Destroy;
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
