; ikinci program
; derleme sonucunda oluşan test.bin dosyasının uzantısını
; exe olarak değiştirirseniz, program windows ortamında çalışacaktır

; çoklu veri tipinde tanımlı windows ortamında çalışan exe kod başlangıcı
başla:

; MZ başlık verileri
dw 'MZ'
dw 200h
dw 1
dw 0
dw 1
db 0,'G'

; PE başlık verileri
dd 'PE'
dw 14Ch
dw 1
dw 13Ch
dw 0FFF0h
dw 78h
dw 0
dd 0

dw 0E0h
dw 10Fh
dw 10Bh

;MSDosMesaj
db 'WG.Gerekli.', 0Dh, 0Ah, '$'

dd 1000h
dd 0
dd 0Ch
dd 400000h
dd 1000h
dd 200h

db 0BAh, 16h, 1h, 0B4h, 9h, 0CDh, 21h
db 0E9h
dd 4
dw 0
db 0CDh, 20h
dd 2000h
dd 200h
dd 0
dw 2
dw 0
dd 1000h
dd 1000h
dd 10000h
dd 0
dd 0
dd 0Ah


dd 0, 0
dd 1028h, 80h
dq 0, 0, 0, 0
dq 0, 0, 0, 0
dq 0, 0, 0, 0
dd 0, 0, 0, 0

; bölümler (Bolum1) - sections
;dq 'Bolum1'
db      'Bolum1'
db      0, 0, 0

dd 400h
dd 1000h
dd 0A8h
dd 200h
dd 0, 0, 0
dd 0E0000060h

;dq ''
dq      2020202020202020h

db 0, 0, 0, 0
dq 0, 0, 0, 0
dq 0, 0, 0, 0
dq 0, 0, 0, 0
dq 0, 0, 0, 0
dq 0, 0, 0, 0
dq 0, 0, 0, 0
dd 0, 0, 0, 0

; grafiksel arabirim kodları
db 6Ah, 0, 68h, 1Ch
db 10h, 40h, 0, 68h
db 1Fh, 10h, 40h, 0
db 6Ah, 0, 0FFh, 15h
db 6Ch, 10h, 40h, 0
db 6Ah, 0h, 0FFh, 15h
db 64h, 10h, 40h, 0

PencereBaşlık: db 'a2', 0
PencereMesaj: db 'merhaba', 0
db 0

; kullanılacak sistem işlevleri (import table)
dd 0, 0, 0, 1074h, 1064h
dd 0, 0, 0, 1081h, 106ch
dd 0, 0, 0, 0, 0

dd 108ch, 0
dd 109ah, 0

db 'kernel32.dll', 0
db 'user32.dll', 0
db 0, 0
db 'ExitProcess', 0
db 0, 0
db 'MessageBoxA', 0

son:
; çoklu veri tipinde tanımlı windows ortamında çalışan exe kod sonu
