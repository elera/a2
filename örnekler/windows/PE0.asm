dosya.uzantı = 'exe'

; çoklu veri tipinde tanımlı windows ortamında çalışan exe kod başlangıcı
başla:

; MZ başlık verileri
        dw      'MZ'
        dw      200h
        dw      1
        dw      0
        dw      1
        db      0,'G'

; PE başlık verileri
        dd      'PE'
        dw      14Ch
        dw      1
        dw      13Ch
        dw      0FFF0h
        dw      78h
        dw      0
        dd      0

        dw      0E0h
        dw      10Fh
        dw      10Bh

        db      'Need Win32.'
        db      0Dh, 0Ah
        db      '$'

        dd      1000h
        dd      0
        dd      0Ch
        dd      400000h
        dd      1000h
        dd      200h

        db      0BAh, 016h, 001h, 0B4h, 009h, 0CDh, 021h
        db      0E9h
        dd      4
        dw      0
        db      0CDh, 020h
        dd      2000h
        dd      200h
        dd      0
        dw      2
        dw      0
        dd      1000h
        dd      1000h
        dd      10000h
        dd      0
        dd      0
        dd      0Ah

        dd      0, 0
        dd      1028h, 80h
        dq      0, 0, 0, 0
        dq      0, 0, 0, 0
        dq      0, 0, 0, 0
        dd      0, 0, 0, 0

; bölümler (Bolum1) - sections
        dq      'Bölüm1'
        dd      400h
        dd      1000h
        dd      0A8h
        dd      200h
        dd      0, 0, 0
        dd      0E0000060h

        dq      0
        db      0, 0, 0, 0
        dq      0, 0, 0, 0
        dq      0, 0, 0, 0
        dq      0, 0, 0, 0
        dq      0, 0, 0, 0
        dq      0, 0, 0, 0
        dq      0, 0, 0, 0
        dd      0, 0


dosya.ekle 'PE1.asm'

