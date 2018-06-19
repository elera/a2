;---------------------------------------------------------------------
; program biçimi: çalıştırılabilir
; program tanımı: linux ortamında çalışan ELF64 biçiminde yazı mod uygulaması
; linux ortamında çalışacak program kodları - başlangıç
;---------------------------------------------------------------------
kod.adres = 400000h

TEMEL_ADRES = 400000h

program_başlangıç:

MAKİNE_TİP_I386 = 14Ch
MAKİNE_TİP_X64 = 8664h

kod.mimari = '64Bit'

        db      7fh, 45h, 4ch, 46h
        db      02h
        db      01h
        db      01h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 02h, 00h

        dw      3eh
        dd      1

        dq      TEMEL_ADRES+kod_başlangıç
        dq      40h
        dq      0
        dd      0
        dw      40h
        dw      38h
        dw      2
        dd      40h
        dw      0

        ;data section
        dd      1
        dd      5
        dq      0b0h
        dq      TEMEL_ADRES+kod_başlangıç
        dq      TEMEL_ADRES+kod_başlangıç
        dq      veri_başlangıç-kod_başlangıç
        dq      veri_başlangıç-kod_başlangıç
        dq      1000h
        dd      1
        dd      6

        dq      0DAh
        dq      4010DAh
        dq      4010DAh
        dq      0Dh

        dq      0Dh
        dq      10h


kod_başlangıç:

        mov     rax,1
        mov     rdi,1
        mov     rsi,4010DAh
        mov     rdx,18
        syscall

        mov     rax,3Ch
        xor     rdi,rdi
        syscall

veri_başlangıç:
        db      'Assembler 2 (a2)', 0Ah

program_son:
;---------------------------------------------------------------------
; linux ortamında çalışacak program kodları - son
;---------------------------------------------------------------------
