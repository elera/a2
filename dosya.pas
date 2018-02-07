{-------------------------------------------------------------------------------

  Dosya: dosya.pas

  İşlev: dosya işlevlerini içerir

  Güncelleme Tarihi: 07/02/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit dosya;

interface

uses Classes, SysUtils;

procedure ProgramDosyasiOlustur;

implementation

uses Forms;

// ikili dosya biçiminde (binary file format) dosya oluştur
procedure ProgramDosyasiOlustur;
var
  F: file of Byte;
  ProgramDizin, DosyaAdi, TamYol: string;
  i: Integer;
begin

  ProgramDizin := ExtractFilePath(Application.ExeName);
  DosyaAdi := 'test.bin';

  TamYol := ProgramDizin + DosyaAdi;

  AssignFile(F, TamYol);
  {$I-} Rewrite(F); {$I+}

  if(IOResult = 0) then
  begin

    for i := 1 to $F do
    begin

      Write(F, i);
      Application.ProcessMessages;
    end;
  end;

  CloseFile(F);
end;

end.
