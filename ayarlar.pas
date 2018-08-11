{-------------------------------------------------------------------------------

  Dosya: ayarlar.pas

  İşlev: program ayarlarını saklama / yönetme işlevlerini içerir

  Güncelleme Tarihi: 11/08/2018

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

    DuzenleyiciYaziBoyut: Integer;

    // ayarlar
    AcikDosyalariTabAlanindaAc: Boolean;

    // son kullanılan dosyalar
    SonKullanilanDosyalar: array[0..4] of string;
  end;

function INIDosyasiniOku: TProgramAyarlari;
procedure INIDosyasinaYaz(ProgramAyarlari: TProgramAyarlari);

implementation

uses IniFiles, genel, dosya, Classes, paylasim;

// ini dosyasından program ayarlarını oku
function INIDosyasiniOku: TProgramAyarlari;
var
  INIDosyasi: TINIFile;
  FileName, s: string;
  i, j: Integer;
  DosyaAcik: Boolean;
  sl: TStringList;
begin

  FileName := GProgramAyarDizin + 'a2.ini';
  if not(FileExists(FileName)) then
  begin

    INIDosyasi := TINIFile.Create(FileName);

    // pencere koordinatları ilk değer atamaları
    Result.PencereSol := -1;
    Result.PencereUst := -1;
    Result.PencereGenislik := -1;
    Result.PencereYukseklik := -1;
    Result.PencereDurum := wsNormal;

    Result.DuzenleyiciYaziBoyut := 8;

    INIDosyasi.WriteInteger('Pencere', 'Sol', Result.PencereSol);
    INIDosyasi.WriteInteger('Pencere', 'Ust', Result.PencereUst);
    INIDosyasi.WriteInteger('Pencere', 'Genislik', Result.PencereGenislik);
    INIDosyasi.WriteInteger('Pencere', 'Yukseklik', Result.PencereYukseklik);
    INIDosyasi.WriteInteger('Pencere', 'Durum', Ord(Result.PencereDurum));

    INIDosyasi.WriteInteger('Duzenleyici', 'YaziBoyut', Result.DuzenleyiciYaziBoyut);

    // program ayar ilk değer atamaları
    Result.AcikDosyalariTabAlanindaAc := True;
    INIDosyasi.WriteBool('ProgramAyar', 'AcikDosyalariTabAlanindaAc', Result.AcikDosyalariTabAlanindaAc);

    // son kullanılan dosyalar ilk değer atamaları
    for i := 0 to 4 do Result.SonKullanilanDosyalar[i] := '';
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

    Result.DuzenleyiciYaziBoyut := INIDosyasi.ReadInteger('Duzenleyici',
      'YaziBoyut', 8);

    Result.AcikDosyalariTabAlanindaAc := INIDosyasi.ReadBool('ProgramAyar',
      'AcikDosyalariTabAlanindaAc', True);

    // son kullanılan dosya bilgilerini al
    for i := 0 to 4 do
    begin

      Result.SonKullanilanDosyalar[i] := INIDosyasi.ReadString('SonKullanılanDosyalar',
        'Dosya' + IntToStr(i + 1), '');
    end;

    // tab alanında açık olup, listeye kaydedilen dosyaların listesini al
    if(Result.AcikDosyalariTabAlanindaAc) then
    begin

      sl := TStringList.Create;

      INIDosyasi.ReadSectionValues('AcikDosyalar', sl);
      for i := 0 to sl.Count - 1 do
      begin

        j := Pos('=', sl[i]);
        if(j > 0) then
        begin

          s := Copy(sl[i], j + 1, Length(sl[i]) - j);

          // DosyaAcik değerinin hata döndürmesinin burada kontrol edilmesi önemli değil
          GAsm2.Dosyalar.Ekle(s, False, DosyaAcik);
        end;
      end;

      FreeAndNil(sl);
    end;

    INIDosyasi.Free;
  end;
end;

// program ayarlarını ini dosyasına yaz
procedure INIDosyasinaYaz(ProgramAyarlari: TProgramAyarlari);
var
  INIDosyasi: TINIFile;
  FileName: string;
  i, j: Integer;
begin

  FileName := GProgramAyarDizin + 'a2.ini';

  INIDosyasi := TINIFile.Create(FileName);
  INIDosyasi.EraseSection('SonKullanılanDosyalar');
  INIDosyasi.EraseSection('AcikDosyalar');

  INIDosyasi.WriteInteger('Pencere', 'Sol', ProgramAyarlari.PencereSol);
  INIDosyasi.WriteInteger('Pencere', 'Ust', ProgramAyarlari.PencereUst);
  INIDosyasi.WriteInteger('Pencere', 'Genislik', ProgramAyarlari.PencereGenislik);
  INIDosyasi.WriteInteger('Pencere', 'Yukseklik', ProgramAyarlari.PencereYukseklik);
  INIDosyasi.WriteInteger('Pencere', 'Durum', Ord(ProgramAyarlari.PencereDurum));

  INIDosyasi.WriteInteger('Duzenleyici', 'YaziBoyut', ProgramAyarlari.DuzenleyiciYaziBoyut);

  INIDosyasi.WriteBool('ProgramAyar', 'AcikDosyalariTabAlanindaAc',
    ProgramAyarlari.AcikDosyalariTabAlanindaAc);

  // son kullanılan 5 dosyayı ayar dosyasına kaydet
  for i := 0 to 4 do
  begin

    INIDosyasi.WriteString('SonKullanılanDosyalar', 'Dosya' + IntToStr(i + 1),
      ProgramAyarlari.SonKullanilanDosyalar[i]);
  end;

  // tab alanında açık olan dosyaları ayar dosyasına kaydet
  if(ProgramAyarlari.AcikDosyalariTabAlanindaAc) then
  begin

    j := 1;
    for i := 0 to GAsm2.Dosyalar.Toplam - 1 do
    begin

      if(GAsm2.Dosyalar.Eleman[i].Durum = ddKaydedildi) then
      begin

        INIDosyasi.WriteString('AcikDosyalar', 'Dosya' + IntToStr(j),
          GAsm2.Dosyalar.Eleman[i].ProjeDizin + DirectorySeparator +
          GAsm2.Dosyalar.Eleman[i].ProjeDosyaAdi + '.' +
          GAsm2.Dosyalar.Eleman[i].ProjeDosyaUzanti);

        Inc(j);
      end;
    end;
  end;

  INIDosyasi.UpdateFile;
  INIDosyasi.Free;
end;

end.
