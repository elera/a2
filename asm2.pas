{-------------------------------------------------------------------------------

  Dosya: asm2.pas

  İşlev: derleyici içerisinde kullanılacak sınıfları yönetecek ana sınıf

  Güncelleme Tarihi: 11/02/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit asm2;

interface

uses Classes, SysUtils, ayarlar, etiket;

type
  TAsm2 = class
  private
  public
    Etiketler: TEtiketler;
    constructor Create;
    destructor Destroy; override;
    function ProgramAyarDosyasiniOku: TProgramAyarlari;
    procedure ProgramAyarDosyasinaYaz(ProgramAyarlari: TProgramAyarlari);
  end;

implementation

constructor TAsm2.Create;
begin

  Etiketler := TEtiketler.Create;
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
