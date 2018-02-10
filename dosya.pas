{-------------------------------------------------------------------------------

  Dosya: dosya.pas

  İşlev: dosya işlevlerini içerir

  Güncelleme Tarihi: 07/02/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit dosya;

interface

uses Classes, SysUtils;

function ProgramDosyasiOlustur: Boolean;

implementation

uses genel, Forms;

// ikili dosya biçiminde (binary file format) dosya oluştur
function ProgramDosyasiOlustur: Boolean;
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

    if(KodBellekU > 0) then
    begin

      for i := 0 to KodBellekU - 1 do
      begin

        Write(F, KodBellek[i]);
        Application.ProcessMessages;
      end;
    end;

    CloseFile(F);
    Result := True;
  end else Result := False;
end;

end.
