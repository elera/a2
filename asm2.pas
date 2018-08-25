{-------------------------------------------------------------------------------

  Dosya: asm2.pas

  İşlev: derleyici içerisinde kullanılan tüm sınıfları yönetecek ana sınıf

  Güncelleme Tarihi: 24/08/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit asm2;

interface

uses Classes, SysUtils, ayarlar, atamalar, matematik, dosya, derleyici;

type
  TAsm2 = class
  private
  public
    Matematik: TMatematik;           // tüm çoklu matematiksel / mantıksal işlemleri yönetir
    AtamaListesi: TAtamaListesi;
    Dosyalar: TDosyalar;
    Derleyici: TDerleyici;
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

  Matematik := TMatematik.Create;
  AtamaListesi := TAtamaListesi.Create;
  Dosyalar := TDosyalar.Create;
  Derleyici := TDerleyici.Create;
end;

destructor TAsm2.Destroy;
begin

  Derleyici.Destroy;
  Dosyalar.Destroy;
  AtamaListesi.Destroy;
  Matematik.Destroy;
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
