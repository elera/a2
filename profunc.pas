unit profunc;

{$mode objfpc}{$H+}

interface

{
  intel yönerge biçimi (Intel Instruction Format)
  -----------------------------------------------
  +--------+--------+--------+-----+------+-----+
  | prefix | opcode | modr/m | sib | disp | imm |
  +--------+--------+--------+-----+------+-----+

  ön ek (prefix): 0-4 byte
  işlem kodu (opcode): 1-3 byte
  mod yazmaç / bellek (modr/m): 1 byte
  ölçek (scale) - sıra (index) - taban (base) (sib): 1 byte
  yerini alma (displacement): 1-4 byte
  sayısal değer (immediate): 1-4 byte
}

const
  // sayısal yazmaç tanımlamaları
  iREG_EAX = $0;
  iREG_ECX = $1;
  iREG_EDX = $2;
  iREG_EBX = $3;
  iREG_ESP = $4;
  iREG_EBP = $5;
  iREG_ESI = $6;
  iREG_EDI = $7;

  // string yazmaç tanımlamaları
  sREG_EAX = 'EAX';
  sREG_ECX = 'ECX';
  sREG_EDX = 'EDX';
  sREG_EBX = 'EBX';
  sREG_ESP = 'ESP';
  sREG_EBP = 'EBP';
  sREG_ESI = 'ESI';
  sREG_EDI = 'EDI';

implementation

end.
