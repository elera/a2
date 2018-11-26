        db      06Ah, 000h
        ; push    0

        db      068h, 01Ch, 010h, 040h, 000h
        ; push

        db      068h, 01Fh, 010h, 040h, 000h
        ; push

        db      06Ah, 000h
        ; push 0

        db      0FFh, 015h, 06Ch, 010h, 040h, 000h
        ;       call    user32.messageboxa

        db      06Ah, 000h

        db      0FFh, 015h, 064h, 010h, 040h, 000h

PencereBaşlık:
        db      'a2'
        db      0

PencereMesaj:
        db      'merhaba'
        db      0
        db      0

; kullanılacak sistem işlevleri (import table)
        dd      0, 0, 0, 1074h, 1064h
        dd      0, 0, 0, 1081h, 106Ch
        dd      0, 0, 0, 0, 0

        dd      108Ch, 0
        dd      109Ah, 0

        db      'kernel32.dll'
        db      0

        db      'user32.dll'
        db      0, 0, 0

        db      'ExitProcess'
        db      0, 0, 0

        db      'MessageBoxA'
        db      0
