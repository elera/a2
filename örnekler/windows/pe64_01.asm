;-------------------------------------------------------------------------------
; proje adı: pe64_01.asm
; program biçimi: çalıştırılabilir
; program tanımı: windows ortamında çalışan 64 bitlik uygulama

        dosya.uzantı = 'exe'

program_başlangıç:
;-------------------------------------------------------------------------------
TEMEL_ADRES = 400000h

MAKİNE_TİP_X64 = 8664h

; MZ başlık verileri
        dw      'MZ'
        dw	80h
        dw      1
        dw      0
        dw      4

        dw      10h
        dw	0FFFFh
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

db      'This program cannot be run in DOS mode.',0Dh, 0Ah
db      '$'



db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h

; PE başlık verileri
        dd      'PE'
        dw      MAKİNE_TİP_X64
        dw      3
        dd      5AC9CD22h
        dd	0
        dd      0
        dw      0F0h
        dw      2Fh

; PE seçimli başlık verileri
        dw      20Bh
        db	1
        db	48h
        dd      200h
        dd      400h
        dd      0
        dd      1000h
        dd      1000h
        dd      400000h
        dd      0
        dd      1000h
        dd      200h
        dw      1
        dw      0
        dw      0, 0
        dw      5
        dw      0
        dd      0
        dd      4000h
        dd      200h
        dd      048CEh
        dw      2
        dw      0
        dd      1000h
        dd      0
        dd      1000h
        dd      0
        dd      10000h
        dd      0

; dizinler
        dd      0
        dd      0

        dd      0
        dd      10h

        dd      0, 0

        dd      3000h
        dd      0AAh

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
        dd      2Dh
        dd      kod_başlangıç - TEMEL_ADRES
        dd      kod_bitiş - kod_başlangıç
        dd      200h
        dd      0, 0
        dw      0, 0
        dd      60000020h

        dq      '.veri'
        dd      024h
        dd      veri_başlangıç - TEMEL_ADRES
        dd      veri_bitiş - veri_başlangıç
        dd      400h
        dd      0, 0
        dw      0, 0
        dd      0C0000040h

        dq      '.iveri'
        dd      0AAh
        dd      iveri_başlangıç - TEMEL_ADRES
        dd      iveri_bitiş - iveri_başlangıç
        dd      600h
        dd      0, 0
        dw      0, 0
        dd      0C0000040h
kod.tabaka = 200h
;-------------------------------------------------------------------------------
kod.mimari = '64Bit'
kod.adres = 401000h
kod_başlangıç:
;-------------------------------------------------------------------------------
        sub     rsp,28h         ; 28h = byte
        ;mov     r9d,0
        db      41h, 0B9h, 0, 0, 0, 0
        ;lea     r8,[PencereBaşlık]
        db      4Ch, 8Dh, 5
        dd      0FEFh
        ;lea     rdx,[PencereMesaj]
        db      48h, 8Dh, 15h
        dd      0FF9h
        mov     rcx,0           ; 0 değeri 32 bitliktir
        ;call    user32_işlevler.messageboxa
        db      0FFh, 15h, 2Fh, 20h, 00, 00

        ;mov     ecx,eax
        db      89h, 0C1h, 0FFh, 15h, 0Fh, 20h, 0, 0
        ;call    kernel32_işlevler.exit_process


kod.tabaka = 200h
kod_bitiş:
;-------------------------------------------------------------------------------
kod.mimari = '64Bit'
kod.adres = 402000h
veri_başlangıç:
;-------------------------------------------------------------------------------
PencereBaşlık:	db	'Assembler 2 (a2)', 0
PencereMesaj:	db	'30.07.2018', 0

kod.tabaka = 200h
veri_bitiş:
;-------------------------------------------------------------------------------
kod.mimari = '64Bit'
kod.adres = 403000h
iveri_başlangıç:
;-------------------------------------------------------------------------------
        dd      0, 0, 0, kernel32_dosya - TEMEL_ADRES, kernel32_işlevler - TEMEL_ADRES
        dd      0, 0, 0, user32_dosya - TEMEL_ADRES, user32_işlevler - TEMEL_ADRES
        dd      0, 0, 0, 0, 0

; kernel32 çağrı giriş bilgileri
;-------------------------------------------------------------------------------
kernel32_işlevler:
kernel32_işlevler.exit_process:
        dq      ExitProcess - TEMEL_ADRES

kernel32_işlevler.getcommandlinea:
        dq      GetCommandLineA - TEMEL_ADRES
        dq      0

; user32 çağrı giriş bilgileri
;-------------------------------------------------------------------------------
user32_işlevler:
user32_işlevler.messageboxa:
        dq      MessageBoxA - TEMEL_ADRES
        dq      0

MessageBoxA:
        dw      0
        db      'MessageBoxA', 0

kernel32_dosya:
        db      'kernel32.dll', 0

user32_dosya:
        db      'user32.dll', 0

ExitProcess:
        dw      0
        db      'ExitProcess', 0

GetCommandLineA:
        dw      0
        db      'GetCommandLineA', 0

kod.tabaka = 200h
iveri_bitiş:
;-------------------------------------------------------------------------------
program_bitiş:
