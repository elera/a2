{-------------------------------------------------------------------------------

  Dosya: asm2.pas

  İşlev: derleyici içerisinde kullanılan tüm sınıfları yönetecek ana sınıf

  Güncelleme Tarihi: 13/06/2018

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
    FProjeDizin, FProjeDosyaAdi, FProjeDosyaUzanti,
    FProgramDosyaAdi,
    FCikisDosyaAdi, FCikisDosyaUzanti: string;
    FDerlemeBasarili: Boolean;
    FIslenenSatirSayisi,            // işlenen toplam satır sayısı (boş satırlar dahil değildir)
    FIslenenSatir: Integer;         // o anda işlenen satır (hata olduğunda hatanın olduğu satır)
    procedure SetProjeDosyaAdi(AProjeDosyaAdi: string);
    procedure SetProjeDosyaUzanti(AProjeDosyaUzanti: string);
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
    property ProjeDosyaAdi: string read FProjeDosyaAdi write SetProjeDosyaAdi;
    property ProjeDosyaUzanti: string read FProjeDosyaUzanti write SetProjeDosyaUzanti;
    property CikisDosyaAdi: string read FCikisDosyaAdi write FCikisDosyaAdi;
    property CikisDosyaUzanti: string read FCikisDosyaUzanti write FCikisDosyaUzanti;
    property DerlemeBasarili: Boolean read FDerlemeBasarili write FDerlemeBasarili;
    property DerlemeCevrimSayisi: Integer read FDerlemeCevrimSayisi
      write FDerlemeCevrimSayisi;
    property ProgramDosyaAdi: string read FProgramDosyaAdi write FProgramDosyaAdi;
    property IslenenSatirSayisi: Integer read FIslenenSatirSayisi write FIslenenSatirSayisi;
    property IslenenSatir: Integer read FIslenenSatir write FIslenenSatir;
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
  FProjeDosyaAdi := '';
  FProjeDosyaUzanti := '';
  FCikisDosyaAdi := '';
  FCikisDosyaUzanti := '';
  FDerlemeBasarili := False;

  FDerlemeCevrimSayisi := 0;
end;

destructor TAsm2.Destroy;
begin

  Matematik.Destroy;
  AtamaListesi.Destroy;
end;

procedure TAsm2.SetProjeDosyaAdi(AProjeDosyaAdi: string);
begin

  if(FProjeDosyaAdi = AProjeDosyaAdi) then Exit;

  // her proje dosya adı girişi yapıldığında çıkış dosyası da bu dosya adını alır
  FProjeDosyaAdi := AProjeDosyaAdi;
  FCikisDosyaAdi := AProjeDosyaAdi;
end;

procedure TAsm2.SetProjeDosyaUzanti(AProjeDosyaUzanti: string);
begin

  if(FProjeDosyaUzanti = AProjeDosyaUzanti) then Exit;

  // proje ve cikis dosya uzantısını değiştir
  FProjeDosyaUzanti := AProjeDosyaUzanti;

  {$IFDEF Windows}
  FCikisDosyaUzanti := 'bin';
  {$ELSE}
  FCikisDosyaUzanti := '';
  {$ENDIF}
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
