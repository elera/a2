{-------------------------------------------------------------------------------

  Dosya: g10islev.pas

  İşlev: 10. grup kodlama işlevlerini gerçekleştirir

  10. grup kodlama işlevi, SADECE işlem kodunun (opcode) işlendiği komutlardır

  Güncelleme Tarihi: 18/02/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit g10islev;

interface

uses Classes, SysUtils, genel;

function Grup10Islev(ParcaNo: Integer; VeriKontrolTip: TVeriKontrolTip; Veri1: string;
  Veri2: QWord): Integer;

implementation

uses kodlama, Dialogs, asm2, komutlar;

var
  IslemKod: Integer;

function Grup10Islev(ParcaNo: Integer; VeriKontrolTip: TVeriKontrolTip; Veri1: string;
  Veri2: QWord): Integer;
begin

  if(VeriKontrolTip = vktIlk) then
  begin

    IslemKod := Veri2;
    Result := HATA_YOK;
  end
  else if(VeriKontrolTip = vktSon) then
  begin

    case KomutListesi[IslemKod].GrupNo of
      GRUP10_AAA:
      begin

        if(GAsm2.Mimari = mim64Bit) then

          Result := HATA_HATALI_MIMARI64
        else
        begin

          KodEkle($37);
          Result := HATA_YOK;
        end;
      end;
      {GRUP01_AAS: KodEkle($3F);
      GRUP01_CBW: KodEkle($98);
      GRUP01_CDQ: KodEkle($98);    // REX. incelenecek
      GRUP01_CLD: KodEkle($FC);
      GRUP01_CLI: KodEkle($FA);
      GRUP01_CMC: KodEkle($F5);
      GRUP01_CPUID: begin KodEkle($0F); KodEkle($A2); end;
      GRUP01_CWD: KodEkle($98);    // REX. incelenecek
      GRUP01_DAA: KodEkle($27);
      GRUP01_DAS: KodEkle($2F);
      GRUP01_EMMS: begin KodEkle($0F); KodEkle($77); end;
      GRUP01_FABS: begin KodEkle($D9); KodEkle($E1); end;
      GRUP01_FCHS: begin KodEkle($D9); KodEkle($E0); end;
      GRUP01_FCLEX: begin KodEkle($9B); KodEkle($DB); KodEkle($E2); end;
      GRUP01_FCOS: begin KodEkle($D9); KodEkle($FF); end;
      GRUP01_FDECSTP: begin KodEkle($D9); KodEkle($F6); end;
      GRUP01_FINCSTP: begin KodEkle($D9); KodEkle($F7); end;
      GRUP01_FINIT: begin KodEkle($9B); KodEkle($DB); KodEkle($E3); end;
      GRUP01_FLDLG2: begin KodEkle($D9); KodEkle($EC); end;
      GRUP01_FLDLN2: begin KodEkle($D9); KodEkle($ED); end;
      GRUP01_FLDPI: begin KodEkle($D9); KodEkle($EB); end;
      GRUP01_FLDZ: begin KodEkle($D9); KodEkle($EE); end;
      GRUP01_FLDL2E: begin KodEkle($D9); KodEkle($EA); end;
      GRUP01_FLDL2T: begin KodEkle($D9); KodEkle($E9); end;
      GRUP01_FLD1: begin KodEkle($D9); KodEkle($E8); end;
      GRUP01_FNCLEX: KodBellek[KodBellekU] := Byte(0);
      GRUP01_FNINIT: KodBellek[KodBellekU] := Byte(0);
      GRUP01_FNOP: KodBellek[KodBellekU] := Byte(0);
      GRUP01_FPATAN: begin KodEkle($D9); KodEkle($F3); end;
      GRUP01_FPREM: begin KodEkle($D9); KodEkle($F8); end;
      GRUP01_FPREM1: begin KodEkle($D9); KodEkle($F5); end;
      GRUP01_FPTAN: begin KodEkle($D9); KodEkle($F2); end;
      GRUP01_FRNDINT: begin KodEkle($D9); KodEkle($FC); end;
      GRUP01_FSCALE: begin KodEkle($D9); KodEkle($FD); end;
      GRUP01_FSIN: begin KodEkle($D9); KodEkle($FE); end;
      GRUP01_FSINCOS: begin KodEkle($D9); KodEkle($FB); end;
      GRUP01_FSQRT: begin KodEkle($D9); KodEkle($FA); end;
      GRUP01_FTST: begin KodEkle($D9); KodEkle($E4); end;
      GRUP01_FYL2X: begin KodEkle($D9); KodEkle($F1); end;
      GRUP01_FYL2XP1: begin KodEkle($D9); KodEkle($F9); end;
      GRUP01_FXAM: begin KodEkle($D9); KodEkle($E5); end;
      GRUP01_FXTRACT: begin KodEkle($D9); KodEkle($F4); end;
      GRUP01_F2XM1: begin KodEkle($D9); KodEkle($F0); end;
      GRUP01_HLT: KodEkle($F4);
      GRUP01_IRET: KodEkle($CF);
      GRUP01_IRETD: KodEkle($CF);   // 16 bit olması haline 66 eki alır
      GRUP01_LAHF: KodEkle($9F);     // bu ve diğer bazı opcodelar 64 bit ortamı desteklemezler
      GRUP01_LEAVE: KodEkle($C9);    // bitler arasındaki ilişki gözden geçirilecek
      GRUP01_LOCK: KodEkle($F0);
      GRUP01_POPA: KodEkle($61);
      GRUP01_POPAD: KodEkle($61);
      GRUP01_POPF: KodEkle($9D);
      GRUP01_POPFD: KodEkle($9D);
      GRUP01_PUSHA: KodEkle($60);
      GRUP01_PUSHAD: KodEkle($60);
      GRUP01_PUSHF: KodEkle($9C);
      GRUP01_PUSHFD: KodEkle($9C);
      GRUP01_RDTSC;
      GRUP01_RDTSCP;
      GRUP01_STC;
      GRUP01_STI;
      GRUP01_WBINVD;}
    end;
  end
  else
  begin

    GHataAciklama := Veri1;
    Result := HATA_BEKLENMEYEN_IFADE;
  end
end;

end.
