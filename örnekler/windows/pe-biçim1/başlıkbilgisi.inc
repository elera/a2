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
	dd	%ts_unix+0
	dd	78h
	dd	0
	dw	0E0h
	dw	10Fh

	dw	10Bh

MSDosMesaj:
        db      'WG.Gerekli.', 0Dh, 0Ah, '$'

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
	dq	'.kod'
	dd	200h
	dd	1000h
	dd	bölüm1_son - kod_başlangıç
	dd	200h
	dd	0, 0, 0
	dd	0E0000060h

	dq	'.veri'
	dd	200h
	dd	1000h
	dd	bölüm1_son - kod_başlangıç
	dd	400h
	dd	0, 0, 0
	dd	0E0000060h

kod.tabaka = 200h
