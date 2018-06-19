{-------------------------------------------------------------------------------

  Dosya: araclar.pas

  İşlev: yardımcı işlevleri içerir

  Güncelleme Tarihi: 17/06/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit araclar;

interface

uses Classes, SysUtils;

const
  PROCESSOR_ARCHITECTURE_AMD64 = 9;         // x64 (AMD or Intel)
  PROCESSOR_ARCHITECTURE_ARM = 5;           // ARM
  PROCESSOR_ARCHITECTURE_ARM64 = 12;        // ARM64
  PROCESSOR_ARCHITECTURE_IA64 = 6;          // Intel Itanium-based
  PROCESSOR_ARCHITECTURE_INTEL = 0;         // x86
  PROCESSOR_ARCHITECTURE_UNKNOWN = $FFFF;   // Unknown architecture.

type
  TSistemMimari = (sm32Bit, sm64Bit, smDiger);

function SistemMimarisiniAl: TSistemMimari;

implementation

{$IFDEF Windows}
uses windows;
{$ENDIF}

function SistemMimarisiniAl: TSistemMimari;
{$IFDEF Windows}
var
  SistemBilgisi: TSYSTEMINFO;
{$ENDIF}
begin

  {$IFDEF Windows}
  // işlev geriye kontrol değeri döndürmez
  GetSystemInfo(SistemBilgisi);

  case SistemBilgisi.wProcessorArchitecture of
    PROCESSOR_ARCHITECTURE_INTEL: Result := sm32Bit;
    PROCESSOR_ARCHITECTURE_AMD64: Result := sm64Bit;
    else Result := smDiger;
  end;
  {$ELSE}
  Result := smDiger;
  {$ENDIF}
end;

end.
