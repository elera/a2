{-------------------------------------------------------------------------------

  Dosya: ayarlar.pas

  İşlev: program ayarlarını saklama / yönetme işlevlerini içerir

  Güncelleme Tarihi: 31/03/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit ayarlar;

interface

uses Forms, SysUtils;

type
  TProgramAyarlari = record

    // pencere koordinatları
    PencereSol,
    PencereUst,
    PencereGenislik,
    PencereYukseklik: Integer;
    PencereDurum: TWindowState;

    // son kullanılan dosyalar
    SonKullanilanDosyalar: array[0..4] of string;
  end;

function INIDosyasiniOku: TProgramAyarlari;
procedure INIDosyasinaYaz(ProgramAyarlari: TProgramAyarlari);

implementation

uses IniFiles, genel;

// ini dosyasından program ayarlarını oku
function INIDosyasiniOku: TProgramAyarlari;
var
  INIDosyasi: TINIFile;
  FileName: string;
  i: Integer;
begin

  FileName := GProgramAyarDizin + 'a2.ini';
  if not(FileExists(FileName)) then
  begin

    INIDosyasi := TINIFile.Create(FileName);

    // pencere ilk değer koordinatları
    Result.PencereSol := -1;
    Result.PencereUst := -1;
    Result.PencereGenislik := -1;
    Result.PencereYukseklik := -1;
    Result.PencereDurum := wsNormal;

    // son kullanılan dosyalar ilk değer atamaları
    for i := 0 to 4 do Result.SonKullanilanDosyalar[i] := '';

    INIDosyasi.WriteInteger('Pencere', 'Sol', Result.PencereSol);
    INIDosyasi.WriteInteger('Pencere', 'Ust', Result.PencereUst);
    INIDosyasi.WriteInteger('Pencere', 'Genislik', Result.PencereGenislik);
    INIDosyasi.WriteInteger('Pencere', 'Yukseklik', Result.PencereYukseklik);
    INIDosyasi.WriteInteger('Pencere', 'Durum', Ord(Result.PencereDurum));

    for i := 0 to 4 do
    begin

      INIDosyasi.WriteString('SonKullanılanDosyalar', 'Dosya' + IntToStr(i + 1),
        Result.SonKullanilanDosyalar[i]);
    end;

    INIDosyasi.Free;
  end
  else
  begin

    INIDosyasi := TINIFile.Create(FileName);

    Result.PencereSol := INIDosyasi.ReadInteger('Pencere', 'Sol', -1);
    Result.PencereUst := INIDosyasi.ReadInteger('Pencere', 'Ust', -1);
    Result.PencereGenislik := INIDosyasi.ReadInteger('Pencere', 'Genislik', -1);
    Result.PencereYukseklik := INIDosyasi.ReadInteger('Pencere', 'Yukseklik', -1);
    Result.PencereDurum := TWindowState(INIDosyasi.ReadInteger('Pencere', 'Durum',
      Ord(wsNormal)));

    for i := 0 to 4 do
    begin

      Result.SonKullanilanDosyalar[i] := INIDosyasi.ReadString('SonKullanılanDosyalar',
        'Dosya' + IntToStr(i + 1), '');
    end;

    INIDosyasi.Free;
  end;
end;

// program ayarlarını ini dosyasına yaz
procedure INIDosyasinaYaz(ProgramAyarlari: TProgramAyarlari);
var
  INIDosyasi: TINIFile;
  FileName: string;
  i: Integer;
begin

  FileName := GProgramAyarDizin + 'a2.ini';

  INIDosyasi := TINIFile.Create(FileName);

  INIDosyasi.WriteInteger('Pencere', 'Sol', ProgramAyarlari.PencereSol);
  INIDosyasi.WriteInteger('Pencere', 'Ust', ProgramAyarlari.PencereUst);
  INIDosyasi.WriteInteger('Pencere', 'Genislik', ProgramAyarlari.PencereGenislik);
  INIDosyasi.WriteInteger('Pencere', 'Yukseklik', ProgramAyarlari.PencereYukseklik);
  INIDosyasi.WriteInteger('Pencere', 'Durum', Ord(ProgramAyarlari.PencereDurum));

  for i := 0 to 4 do
  begin

    INIDosyasi.WriteString('SonKullanılanDosyalar', 'Dosya' + IntToStr(i + 1),
      ProgramAyarlari.SonKullanilanDosyalar[i]);
  end;

  INIDosyasi.UpdateFile;
  INIDosyasi.Free;
end;

end.
