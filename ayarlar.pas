{-------------------------------------------------------------------------------

  Dosya: ayarlar.pas

  İşlev: program ayarlarını saklama / yönetme işlevlerini içerir

  Güncelleme Tarihi: 11/02/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit ayarlar;

interface

uses Forms, SysUtils;

type
  TProgramAyarlari = record
    PencereSol,
    PencereUst,
    PencereGenislik,
    PencereYukseklik: Integer;
    PencereDurum: TWindowState;
  end;

function INIDosyasiniOku: TProgramAyarlari;
procedure INIDosyasinaYaz(ProgramAyarlari: TProgramAyarlari);

implementation

uses IniFiles, genel;

// ini dosyasından program ayarlarını oku
function INIDosyasiniOku: TProgramAyarlari;
var
  SetupFile: TINIFile;
  FileName: string;
begin

  FileName := GProgramAyarDizin + 'a2.ini';
  if not(FileExists(FileName)) then
  begin

    SetupFile := TINIFile.Create(FileName);

    Result.PencereSol := -1;
    Result.PencereUst := -1;
    Result.PencereGenislik := -1;
    Result.PencereYukseklik := -1;
    Result.PencereDurum := wsNormal;

    SetupFile.WriteInteger('Pencere', 'Sol', Result.PencereSol);
    SetupFile.WriteInteger('Pencere', 'Ust', Result.PencereUst);
    SetupFile.WriteInteger('Pencere', 'Genislik', Result.PencereGenislik);
    SetupFile.WriteInteger('Pencere', 'Yukseklik', Result.PencereYukseklik);
    SetupFile.WriteInteger('Pencere', 'Durum', Ord(Result.PencereDurum));
    SetupFile.Free;
  end
  else
  begin

    SetupFile := TINIFile.Create(FileName);

    Result.PencereSol := SetupFile.ReadInteger('Pencere', 'Sol', -1);
    Result.PencereUst := SetupFile.ReadInteger('Pencere', 'Ust', -1);
    Result.PencereGenislik := SetupFile.ReadInteger('Pencere', 'Genislik', -1);
    Result.PencereYukseklik := SetupFile.ReadInteger('Pencere', 'Yukseklik', -1);
    Result.PencereDurum := TWindowState(SetupFile.ReadInteger('Pencere', 'Durum',
      Ord(wsNormal)));
    SetupFile.Free;
  end;
end;

// program ayarlarını ini dosyasına yaz
procedure INIDosyasinaYaz(ProgramAyarlari: TProgramAyarlari);
var
  SetupFile: TINIFile;
  FileName: string;
begin

  FileName := GProgramAyarDizin + 'a2.ini';

  SetupFile := TINIFile.Create(FileName);

  SetupFile.WriteInteger('Pencere', 'Sol', ProgramAyarlari.PencereSol);
  SetupFile.WriteInteger('Pencere', 'Ust', ProgramAyarlari.PencereUst);
  SetupFile.WriteInteger('Pencere', 'Genislik', ProgramAyarlari.PencereGenislik);
  SetupFile.WriteInteger('Pencere', 'Yukseklik', ProgramAyarlari.PencereYukseklik);
  SetupFile.WriteInteger('Pencere', 'Durum', Ord(ProgramAyarlari.PencereDurum));
  SetupFile.UpdateFile;
  SetupFile.Free;
end;

end.
