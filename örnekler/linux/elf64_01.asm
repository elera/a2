;---------------------------------------------------------------------
; program biçimi: çalıştırılabilir
; program tanımı: linux ortamında çalışan ELF64 biçiminde yazı mod uygulaması
; linux ortamında çalışacak program kodları - başlangıç
;---------------------------------------------------------------------
program_başlangıç:

TEMEL_ADRES = 400000h
VERİ_ADRES = TEMEL_ADRES + 1000h

MAKİNE_TİP_I386 = 14Ch
MAKİNE_TİP_X64 = 8664h

dosya.uzantı = ''
kod.mimari = '16Bit'

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
        dq      VERİ_ADRES+veri_başlangıç
        dq      VERİ_ADRES+veri_başlangıç
        dq      0Dh

        dq      0Dh
        dq      10h


kod_başlangıç:
        ;mov rax,1
        db      48h, 0c7h, 0c0h, 01h, 00h, 00h, 00h

        ;mov rdi,1
        db      48h, 0c7h, 0c7h, 01h, 00h, 00h, 00h

        ;mov rsi,Mesaj
        db      48h, 0c7h, 0c6h, 0dah, 10h, 40h, 00h

        ;mov rdx,0dh - mesaj uzunluk
        db      48h, 0c7h, 0c2h, 0dh, 00h, 00h, 00h

        ;syscall
        db      0fh, 05h

        ;mov rax,3ch
        db      48h, 0c7h, 0c0h, 3ch, 00h, 00h, 00h

        ;xor rdi,rdi
        db      48h, 31h, 0ffh

        ;syscall
        db      0fh, 05h

veri_başlangıç:
        db      'Fatih KILIC.', 0Ah

program_son:
;---------------------------------------------------------------------
; linux ortamında çalışacak program kodları - son
;---------------------------------------------------------------------
