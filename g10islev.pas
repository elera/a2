{-------------------------------------------------------------------------------

  Dosya: g10islev.pas

  İşlev: 10. grup kodlama işlevlerini gerçekleştirir

  10. grup kodlama işlevi, SADECE işlem kodunun (opcode) işlendiği komutlardır

  Güncelleme Tarihi: 30/09/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit g10islev;

interface

uses Classes, SysUtils, genel, paylasim;

function Grup10Islev: Integer;

implementation

uses kodlama, asm2, komutlar;

function Grup10Islev: Integer;

  // bu işlev, tüm mimarilerde çalıştırılacak tek byte'lık kodları üretir
  function KodOlustur1(Kod: Byte): Integer;
  begin

    KodEkle(Kod);
    Result := HATA_YOK;
  end;

  // bu işlev, 64 bit mimari haricinde çalıştırılacak tek byte'lık kodları üretir
  function KodOlustur11(Kod: Byte): Integer;
  begin

    if(GAsm2.Derleyici.Mimari = mim64Bit) then

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

  // bu işlev, SADECE 64 bitlik mimarilerde çalıştırılacak iki byte'lık kodları üretir
  function KodOlustur22(Kod1, Kod2: Byte): Integer;
  begin

    if(GAsm2.Derleyici.Mimari = mim64Bit) then
    begin

      KodEkle(Kod1);
      KodEkle(Kod2);
      Result := HATA_YOK;
    end else Result := HATA_64BIT_MIMARI_GEREKLI;
  end;

  // bu işlev, tüm mimarilerde çalıştırılacak üç byte'lık kodları üretir
  function KodOlustur3(Kod1, Kod2, Kod3: Byte): Integer;
  begin

    KodEkle(Kod1);
    KodEkle(Kod2);
    KodEkle(Kod3);
    Result := HATA_YOK;
  end;

  // 16 / 32 / 64 bitlik genel kodlama
  function KodOlustur4(Mimari: TMimari; Kod: Byte): Integer;
  begin

    // 64 bitlik mimari ve sadece 64 bitlik mimaride çalışacak kodlar
    if(Mimari = mim64Bit) then
    begin

      if(Mimari = GAsm2.Derleyici.Mimari) then
      begin

        KodEkle($48);
        KodEkle(Kod);
        Result := HATA_YOK;
      end else Result := HATA_64BIT_MIMARI_GEREKLI;
    end
    // 16 / 32 bitlik mimari
    else if(Mimari <> GAsm2.Derleyici.Mimari) then
    begin

      KodEkle($66);
      KodEkle(Kod);
      Result := HATA_YOK;
    end
    else
    begin

      KodEkle(Kod);
      Result := HATA_YOK;
    end;
  end;

begin

  case SI.Komut.GNo of
    GRUP10_AAA:         Result := KodOlustur11($37);
    GRUP10_AAS:         Result := KodOlustur11($3F);
    GRUP10_CLC:         Result := KodOlustur1($F8);
    GRUP10_CLD:         Result := KodOlustur1($FC);
    GRUP10_CLI:         Result := KodOlustur1($FA);
    GRUP10_CMC:         Result := KodOlustur1($F5);
    GRUP10_CPUID:       Result := KodOlustur2($0F, $A2);
    GRUP10_DAA:         Result := KodOlustur11($27);
    GRUP10_DAS:         Result := KodOlustur11($2F);
    GRUP10_EMMS:        Result := KodOlustur2($0F, $77);
    GRUP10_F2XM1:       Result := KodOlustur2($D9, $F0);
    GRUP10_FABS:        Result := KodOlustur2($D9, $E1);
    GRUP10_FADDP:       Result := KodOlustur2($DE, $C1);
    GRUP10_FCHS:        Result := KodOlustur2($D9, $E0);
    GRUP10_FCLEX:       Result := KodOlustur3($9B, $DB, $E2);
    GRUP10_FCOS:        Result := KodOlustur2($D9, $FF);
    GRUP10_FDECSTP:     Result := KodOlustur2($D9, $F6);
    GRUP10_FINCSTP:     Result := KodOlustur2($D9, $F7);
    GRUP10_FINIT:       Result := KodOlustur3($9B, $DB, $E3);
    GRUP10_FLD1:        Result := KodOlustur2($D9, $E8);
    GRUP10_FLDL2E:      Result := KodOlustur2($D9, $EA);
    GRUP10_FLDL2T:      Result := KodOlustur2($D9, $E9);
    GRUP10_FLDLG2:      Result := KodOlustur2($D9, $EC);
    GRUP10_FLDLN2:      Result := KodOlustur2($D9, $ED);
    GRUP10_FLDPI:       Result := KodOlustur2($D9, $EB);
    GRUP10_FLDZ:        Result := KodOlustur2($D9, $EE);
    GRUP10_FNCLEX:      Result := KodOlustur2($DB, $E2);
    GRUP10_FNINIT:      Result := KodOlustur2($DB, $E3);
    GRUP10_FNOP:        Result := KodOlustur2($D9, $D0);
    GRUP10_FPATAN:      Result := KodOlustur2($D9, $F3);
    GRUP10_FPREM:       Result := KodOlustur2($D9, $F8);
    GRUP10_FPREM1:      Result := KodOlustur2($D9, $F5);
    GRUP10_FPTAN:       Result := KodOlustur2($D9, $F2);
    GRUP10_FRNDINT:     Result := KodOlustur2($D9, $FC);
    GRUP10_FSCALE:      Result := KodOlustur2($D9, $FD);
    GRUP10_FSIN:        Result := KodOlustur2($D9, $FE);
    GRUP10_FSINCOS:     Result := KodOlustur2($D9, $FB);
    GRUP10_FSQRT:       Result := KodOlustur2($D9, $FA);
    GRUP10_FTST:        Result := KodOlustur2($D9, $E4);
    GRUP10_FYL2X:       Result := KodOlustur2($D9, $F1);
    GRUP10_FYL2XP1:     Result := KodOlustur2($D9, $F9);
    GRUP10_FXAM:        Result := KodOlustur2($D9, $E5);
    GRUP10_FXTRACT:     Result := KodOlustur2($D9, $F4);
    GRUP10_HLT:         Result := KodOlustur1($F4);
    GRUP10_INTO:        Result := KodOlustur11($CE);
    GRUP10_LAHF:        Result := KodOlustur11($9F);
    GRUP10_LEAVE:       Result := KodOlustur1($C9);
    GRUP10_LODSB:       Result := KodOlustur1($AC);
    GRUP10_LODSD:       Result := KodOlustur4(mim32Bit, $AD);
    GRUP10_LODSW:       Result := KodOlustur4(mim16Bit, $AD);
    GRUP10_LODSQ:       Result := KodOlustur4(mim64Bit, $AD);
    GRUP10_MOVSB:       Result := KodOlustur1($A4);
    GRUP10_MOVSD:       Result := KodOlustur4(mim32Bit, $A5);
    GRUP10_MOVSW:       Result := KodOlustur4(mim16Bit, $A5);
    GRUP10_MOVSQ:       Result := KodOlustur4(mim64Bit, $A5);
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
    GRUP10_STC:         Result := KodOlustur1($F9);
    GRUP10_STI:         Result := KodOlustur1($FB);
    GRUP10_STOSB:       Result := KodOlustur1($AA);
    GRUP10_STOSD:       Result := KodOlustur4(mim32Bit, $AB);
    GRUP10_STOSW:       Result := KodOlustur4(mim16Bit, $AB);
    GRUP10_STOSQ:       Result := KodOlustur4(mim64Bit, $AB);
    GRUP10_SYSCALL:     Result := KodOlustur22($0F, $05);
    GRUP10_SYSENTER:    Result := KodOlustur2($0F, $34);
    GRUP10_WBINVD:      Result := KodOlustur2($0F, $09);

    {GRUP01_AAS: KodEkle($3F);
    GRUP01_CBW: KodEkle($98);
    GRUP01_CDQ: KodEkle($98);    // REX. incelenecek
    GRUP01_CWD: KodEkle($98);    // REX. incelenecek
    GRUP01_IRET: KodEkle($CF);
    GRUP01_IRETD: KodEkle($CF); }  // 16 bit olması haline 66 eki alır

    else
    begin

      //GHataAciklama := ParcaSonuc.VeriKK;
      Result := HATA_BEKLENMEYEN_IFADE;
    end;
  end;
end;

end.
