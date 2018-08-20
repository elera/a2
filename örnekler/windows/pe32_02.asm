;-------------------------------------------------------------------------------
; program biçimi: exe
; program tanımı: dll biçim çalışması test uygulaması
; windows ortamında çalışacak program kodları - başlangıç
;-------------------------------------------------------------------------------
program_başlangıç:

TEMEL_ADRES = 400000h

MAKİNE_TİP_I386 = 14Ch
MAKİNE_TİP_X64 = 8664h

dosya.uzantı = 'exe'
kod.mimari = '16Bit'

; MZ başlık verileri
	dw	'MZ'
	dw	200h
	dw 	1
	dw 	0
	dw 	1
	db 	0,'G'

; PE başlık verileri
	dd	'PE'
	dw	MAKİNE_TİP_I386
	dw	1
	dd	0FFF0013Ch
	dd	78h
	dd	0

	dw	0E0h
	dw	10Fh

	dw	10Bh

MSDosMesaj      db      'WG.Gerekli.', 0Dh, 0Ah, '$'

	dd	1000h
	dd	0
	dd	0Ch
	dd	TEMEL_ADRES
	dd	1000h
	dd	200h

DosOrtamKodlar:
	mov	dx,116h
	mov	ah,9
	int	21h

	db	0E9h
	dd	4
	dw	0

int_kullanım2:
        int     20h

	dd	2000h
	dd	200h
	dd	0
	dw	2
	dw	0
	dd	1000h
	dd	1000h
	dd	10000h
	dd	0
	dd	0
	dd	0Ah

; dizin yapıları
	dd	0, 0
	dd	girdiler_başlangıç - TEMEL_ADRES, girdiler_son - girdiler_başlangıç
	dd	0, 0
	dd	0, 0
	dd	0, 0
	dd	0, 0
	dd	0, 0
	dd	0, 0
	dd	0, 0
	dd	0, 0

	dq	0, 0, 0, 0, 0, 0

; bölümler (Bölüm1) - sections
	dq	'Bölüm1'
	dd	400h
	dd	1000h
	dd	bölüm1_son-bölüm1_başlangıç
	dd	200h
	dd	0, 0, 0
	dd	0E0000060h

	dq	'.idata'
	dd	400h
	dd	1000h
	dd	bölüm1_son-bölüm1_başlangıç
	dd	200h
	dd	0, 0, 0
	dd	0E0000060h

	dq	0
	dd	0
	dd	0
	dd	0
	dd	0
	dd	0, 0, 0
	dd	0

	dq	0
	dd	0
	dd	0
	dd	0
	dd	0
	dd	0, 0, 0
	dd	0

	dq	0
	dd	0
	dd	0
	dd	0
	dd	0
	dd	0, 0, 0
	dd	0

	dq	0
	dd	0
	dd	0
	dd	0
	dd	0
	dd	0, 0, 0
	dd	0

        dd 0, 0, 0

kod.mimari = '32Bit'
kod.adres = 401000h

bölüm1_başlangıç:

; grafiksel arabirim kodları
;-------------------------------------------------------------------------------
        call    [MerhabaDLLİşlevi]

        push    0
        call    [ExitProcessİşlevi]

PencereBaşlık:	db0	'Assembler 2 (a2)'
PencereMesaj:	db0	'0000000000'
SayisalDeger    dd      12345

kod.tabaka = 4

; program içerisinde kullanılacak sistem işlevleri (import table)
;-------------------------------------------------------------------------------
girdiler_başlangıç:
	dd	0, 0, 0, kernel32_dll - TEMEL_ADRES, ExitProcessİşlevi - TEMEL_ADRES
	dd	0, 0, 0, merhaba_dll - TEMEL_ADRES, MerhabaDLLİşlevi - TEMEL_ADRES
	dd	0, 0, 0, 0, 0

kernel32_dll:
	db0	'kernel32.dll'

merhaba_dll:
	db0	'merhaba.dll'

ExitProcessİşlevi:
	dd	ExitProcess - TEMEL_ADRES
	dd	0

MerhabaDLLİşlevi:
	dd	MerhabaDLL - TEMEL_ADRES
	dd	0

ExitProcess:
	db	0, 0
	db0	'ExitProcess'

MerhabaDLL:
	db	0, 0
	db0	'MerhabaDLL'

kod.tabaka = 4

girdiler_son:

bölüm1_son:

program_son:
;-------------------------------------------------------------------------------
; windows ortamında çalışacak program kodları - son
;-------------------------------------------------------------------------------
