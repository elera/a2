{-------------------------------------------------------------------------------

  Dosya: g10islev.pas

  İşlev: 10. grup kodlama işlevlerini gerçekleştirir

  10. grup kodlama işlevi, SADECE işlem kodunun (opcode) işlendiği komutlardır

  Güncelleme Tarihi: 08/03/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit g10islev;

interface

uses Classes, SysUtils, genel, paylasim;

function Grup10Islev(SatirNo: Integer; ParcaNo: Integer; VeriKontrolTip:
  TVeriKontrolTip; Veri1: string; Veri2: QWord): Integer;

implementation

uses kodlama, Dialogs, asm2, komutlar;

var
  IslemKod: Integer;

function Grup10Islev(SatirNo: Integer; ParcaNo: Integer;
  VeriKontrolTip: TVeriKontrolTip; Veri1: string; Veri2: QWord): Integer;

  // bu işlev, tüm mimarilerde çalıştırılacak tek byte'lık kodları üretir
  function KodOlustur1(Kod: Byte): Integer;
  begin

    KodEkle(Kod);
    Result := HATA_YOK;
  end;

  // bu işlev, 64 bit mimari haricinde çalıştırılacak tek byte'lık kodları üretir
  function KodOlustur11(Kod: Byte): Integer;
  begin

    if(GAsm2.Mimari = mim64Bit) then

      Result := HATA_HATALI_MIMARI64
    else
    begin

      KodEkle(Kod);
      Result := HATA_YOK;
    end;
  end;

  // bu işlev, tüm mimarilerde çalıştırılacak iki byte'lık kodları üretir
  function KodOlustur2(Kod1, Kod2: Byte): Integer;
  begin

    KodEkle(Kod1);
    KodEkle(Kod2);
    Result := HATA_YOK;
  end;

  // bu işlev, tüm mimarilerde çalıştırılacak üç byte'lık kodları üretir
  function KodOlustur3(Kod1, Kod2, Kod3: Byte): Integer;
  begin

    KodEkle(Kod1);
    KodEkle(Kod2);
    KodEkle(Kod3);
    Result := HATA_YOK;
  end;
begin

  if(VeriKontrolTip = vktIlk) then
  begin

    IslemKod := Veri2;
    Result := HATA_YOK;
  end
  else if(VeriKontrolTip = vktSon) then
  begin

    case KomutListesi[IslemKod].GrupNo of
      GRUP10_AAA:         Result := KodOlustur11($37);
      GRUP10_CLC:         Result := KodOlustur1($F8);
      GRUP10_CLD:         Result := KodOlustur1($FC);
      GRUP10_CLI:         Result := KodOlustur1($FA);
      GRUP10_CMC:         Result := KodOlustur1($F5);
      GRUP10_DAA:         Result := KodOlustur11($27);
      GRUP10_DAS:         Result := KodOlustur11($2F);
      GRUP10_FCOS:        Result := KodOlustur2($D9, $FF);
      GRUP10_FSIN:        Result := KodOlustur2($D9, $FE);
      GRUP10_FSINCOS:     Result := KodOlustur2($D9, $FB);
      GRUP10_HLT:         Result := KodOlustur1($F4);
      GRUP10_LAHF:        Result := KodOlustur11($9F);
      GRUP10_LEAVE:       Result := KodOlustur1($C9);
      GRUP10_LOCK:        Result := KodOlustur1($F0);
      GRUP10_POPA:        Result := KodOlustur11($61);
      GRUP10_POPAD:       Result := KodOlustur11($61);
      GRUP10_POPF:        Result := KodOlustur1($9D);
      GRUP10_POPFD:       Result := KodOlustur1($9D);
      GRUP10_POPFQ:       Result := KodOlustur1($9D);
      GRUP10_PUSHA:       Result := KodOlustur11($60);
      GRUP10_PUSHAD:      Result := KodOlustur11($60);
      GRUP10_PUSHF:       Result := KodOlustur1($9C);
      GRUP10_PUSHFD:      Result := KodOlustur1($9C);
      GRUP10_PUSHFQ:      Result := KodOlustur1($9C);
      GRUP10_RDTSC:       Result := KodOlustur2($0F, $31);
      GRUP10_RDTSCP:      Result := KodOlustur3($0F, $01, $F9);
      GRUP10_STI:         Result := KodOlustur1($FB);
      GRUP10_STC:         Result := KodOlustur1($F9);
      GRUP10_WBINVD:      Result := KodOlustur2($0F, 09);
    end;
      {GRUP01_AAS: KodEkle($3F);
      GRUP01_CBW: KodEkle($98);
      GRUP01_CDQ: KodEkle($98);    // REX. incelenecek
      GRUP01_CPUID: begin KodEkle($0F); KodEkle($A2); end;
      GRUP01_CWD: KodEkle($98);    // REX. incelenecek

      GRUP01_EMMS: begin KodEkle($0F); KodEkle($77); end;
      GRUP01_FABS: begin KodEkle($D9); KodEkle($E1); end;
      GRUP01_FCHS: begin KodEkle($D9); KodEkle($E0); end;
      GRUP01_FCLEX: begin KodEkle($9B); KodEkle($DB); KodEkle($E2); end;
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
      GRUP01_FSQRT: begin KodEkle($D9); KodEkle($FA); end;
      GRUP01_FTST: begin KodEkle($D9); KodEkle($E4); end;
      GRUP01_FYL2X: begin KodEkle($D9); KodEkle($F1); end;
      GRUP01_FYL2XP1: begin KodEkle($D9); KodEkle($F9); end;
      GRUP01_FXAM: begin KodEkle($D9); KodEkle($E5); end;
      GRUP01_FXTRACT: begin KodEkle($D9); KodEkle($F4); end;
      GRUP01_F2XM1: begin KodEkle($D9); KodEkle($F0); end;
      GRUP01_IRET: KodEkle($CF);
      GRUP01_IRETD: KodEkle($CF); }  // 16 bit olması haline 66 eki alır
  end
  else
  begin

    GHataAciklama := Veri1;
    Result := HATA_BEKLENMEYEN_IFADE;
  end
end;

end.
