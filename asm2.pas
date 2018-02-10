{-------------------------------------------------------------------------------

  Dosya: asm2.pas

  İşlev: derleyici içerisinde kullanılacak sınıfları yönetecek ana sınıf

  Güncelleme Tarihi: 09/02/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit asm2;

interface

uses Classes, SysUtils, etiket;

type
  TAsm2 = class
  private
  public
    Etiketler: TEtiketler;
    constructor Create;
    destructor Destroy; override;
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

end.
