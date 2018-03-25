{-------------------------------------------------------------------------------

  Dosya: asm2.pas

  İşlev: derleyici içerisinde kullanılan tüm sınıfları yönetecek ana sınıf

  Güncelleme Tarihi: 25/03/2018

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
    FProjeDizin, FDosyaAdi, FProjeDosyaUzanti, FCikisDosyaUzanti: string;
    FDerlemeBasarili: Boolean;
  public
    AtamaListesi: TAtamaListesi;
    Matematik: TMatematik;           // tüm çoklu matematiksel / mantıksal işlemleri yönetir
    FDerlemeCevrimSayisi: Integer;
    constructor Create;
    destructor Destroy; override;
    procedure Ilklendir;
    function ProgramAyarDosyasiniOku: TProgramAyarlari;
    procedure ProgramAyarDosyasinaYaz(ProgramAyarlari: TProgramAyarlari);
  published
    property Mimari: TMimari read FMimari write FMimari;
    property ProjeDizin: string read FProjeDizin write FProjeDizin;
    property DosyaAdi: string read FDosyaAdi write FDosyaAdi;
    property ProjeDosyaUzanti: string read FProjeDosyaUzanti write FProjeDosyaUzanti;
    property CikisDosyaUzanti: string read FCikisDosyaUzanti write FCikisDosyaUzanti;
    property DerlemeBasarili: Boolean read FDerlemeBasarili write FDerlemeBasarili;
    property DerlemeCevrimSayisi: Integer read FDerlemeCevrimSayisi
      write FDerlemeCevrimSayisi;
  end;

implementation

uses genel;

constructor TAsm2.Create;
begin

  AtamaListesi := TAtamaListesi.Create;
  Matematik := TMatematik.Create;

  Ilklendir;
end;

procedure TAsm2.Ilklendir;
begin

  // bu 2 değer fazla gibi gözükebilir ama fazla değildir
  // her yeni dosya açma işleminde bu işlem çağrılmaktadır
  AtamaListesi.Temizle;
  Matematik.Temizle;

  FMimari := mim16Bit;
  FProjeDizin := GProgramCalismaDizin;
  FDosyaAdi := '';
  FProjeDosyaUzanti := '';
  FCikisDosyaUzanti := '';
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
