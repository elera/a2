;-------------------------------------------------------------------------------
; proje adı: pe32_04.asm
; program biçimi: çalıştırılabilir
; program tanımı: windows ortamında çalışan 32 bitlik uygulama

        dosya.uzantı = 'exe'

program_başlangıç:
;-------------------------------------------------------------------------------
TEMEL_ADRES = 400000h

MAKİNE_TİP_I386 = 14Ch

; MZ başlık verileri
        dw      'MZ'
        dw	80h
        dw      1
        dw      0
        dw      4

        dw      10h
        dw	0FFh
        dw	0
        dw      140h
        dw      0, 0, 0
        dw      40h
        dw      0
        dd      0, 0, 0, 0, 0, 0, 0, 0
        dd	80h
db	00Eh
db	01Fh
db	0BAh
db	00Eh
db	000h
db	0B4h
db	009h
db	0CDh
db	021h
db	0B8h
db	001h
db	04Ch
db	0CDh
db	021h

db      'This program cannot be run in DOS mode...$',0


db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h

; PE başlık verileri
        dd      'PE'
        dw      MAKİNE_TİP_I386
        dw      2
        dd      5AC0DF12h
        dd	0
        dd      0
        dw      0E0h
        dw      10Fh

; PE seçimli başlık verileri
        dw      10Bh
        db	1
        db	48h
        dd      200h
        dd      200h
        dd      0
        dd      1000h
        dd      1000h
        dd      2000h
        dd      TEMEL_ADRES
        dd      1000h
        dd      200h
        dw      1
        dw      0
        dw      0, 0
        dw      4
        dw      0
        dd      0
        dd      3000h
        dd      200h
        dd      8641h
        dw      2
        dw      0
        dd      1000h
        dd      1000h
        dd      10000h
        dd      0
        dd      0
        dd      10h

; dizinler
        dd      0
        dd      0

        dd      2000h
        dd      0B0h

        dd      0, 0
        dd      0, 0
        dd      0, 0
        dd      0, 0
        dd      0, 0
        dd      0, 0
        dd      0, 0
        dd      0, 0
        dd      0, 0
        dd      0, 0
        dd      0, 0
        dd      0, 0
        dd      0, 0
        dd      0, 0

        dq      '.kod'
        dd      3Bh
        dd      kod_başlangıç - TEMEL_ADRES
        dd      kod_bitiş - kod_başlangıç
        dd      200h
        dd      0, 0
        dw      0, 0
        dd      60000020h

        dq      '.veri'
        dd      0B0h
        dd      veri_başlangıç - TEMEL_ADRES
        dd      veri_bitiş - veri_başlangıç
        dd      400h
        dd      0, 0
        dw      0, 0
        dd      0C0000040h
kod.tabaka = 200h

;-------------------------------------------------------------------------------
kod.mimari = '32Bit'
kod.adres = 401000h
kod_başlangıç:
;-------------------------------------------------------------------------------
        push    0
        call    [kernel32_işlevler.getcommandlinea]

        push    0
        push    PencereBaşlık
        push    eax
        push    0
        call    [user32_işlevler.messageboxa]

        push    0
        call    [kernel32_işlevler.exitprocess]

PencereBaşlık:	db	'Assembler 2 (a2)', 0

kod.tabaka = 200h
kod_bitiş:

;-------------------------------------------------------------------------------
kod.mimari = '32Bit'
kod.adres = 402000h
veri_başlangıç:
;-------------------------------------------------------------------------------
        dd      kernel32_işlevler - TEMEL_ADRES, 0, 0
        dd      kernel32_dosya - TEMEL_ADRES, kernel32_işlevler - TEMEL_ADRES
        dd      user32_işlevler - TEMEL_ADRES, 0, 0
        dd      user32_dosya - TEMEL_ADRES, user32_işlevler - TEMEL_ADRES
        dd      0, 0, 0, 0, 0

; kernel32 çağrı giriş bilgileri
;-------------------------------------------------------------------------------
kernel32_dosya:
        db      'kernel32.dll', 0

kernel32_işlevler:
kernel32_işlevler.exitprocess:
        dd      ExitProcess - TEMEL_ADRES

kernel32_işlevler.getcommandlinea:
        dd      GetCommandLineA - TEMEL_ADRES
        dd      0

ExitProcess:
        dw      0
        db      'ExitProcess', 0

GetCommandLineA:
        dw      0
        db      'GetCommandLineA', 0

; user32 çağrı giriş bilgileri
;-------------------------------------------------------------------------------
user32_dosya:
        db      'user32.dll', 0

user32_işlevler:
user32_işlevler.messageboxa:
        dd      MessageBoxA - TEMEL_ADRES
        dd      0

MessageBoxA:
        dw      0
        db      'MessageBoxA', 0

kod.tabaka = 200h
veri_bitiş:
;-------------------------------------------------------------------------------
program_bitiş:
