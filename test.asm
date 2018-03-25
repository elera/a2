;---------------------------------------------------------------------
; proje adı: test.asm
; program biçimi: çalıştırılabilir
; program tanımı: windows ortamında çalışan 32 bitlik uygulama
;---------------------------------------------------------------------
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

        dd      0, 0, 0

kod.mimari = '32Bit'
kod.adres = 401000h

bölüm1_başlangıç:

; grafiksel arabirim kodları
;----------------------------------------------------------------

        mov     edi,PencereMesaj+9
        mov     eax,714
        mov     ebx,3
        mov     ecx,4

sonraki_basamak:

        xor     edx,edx
        mov     ebx,10
        div     ebx

        ; add     dl,'0'
        db      80h, 0C2h, 30h,

        ; mov     [edi],dl
        db      88h, 17h

        inc     ecx
        dec     edi

        ; cmp     eax,0
        db      83h, 0F8h, 00h

        jnz     sonraki_basamak

        push    0
        push    PencereBaşlık
        push    PencereMesaj
        push    0

        ; her iki çağrı da [] arasında değerlendirilecek
        call    MessageBoxAİşlevi

        push    0
        call    ExitProcessİşlevi

PencereBaşlık:	db	'Assembler 2 (a2)', 0
PencereMesaj:	db	'0000000000', 0
SayisalDeger    dd      12345

kod.tabaka = 4

; program içerisinde kullanılacak sistem işlevleri (import table)
;---------------------------------------------------------------------
girdiler_başlangıç:
	dd	0, 0, 0, kernel32_dll - TEMEL_ADRES, ExitProcessİşlevi - TEMEL_ADRES
	dd	0, 0, 0, user32_dll - TEMEL_ADRES, MessageBoxAİşlevi - TEMEL_ADRES
	dd	0, 0, 0, 0, 0

kernel32_dll:
	db	'kernel32.dll', 0

user32_dll:
	db	'user32.dll', 0

ExitProcessİşlevi:
	dd	ExitProcess - TEMEL_ADRES
	dd	0

MessageBoxAİşlevi:
	dd	MessageBoxA - TEMEL_ADRES
	dd	0

ExitProcess:
	db	0, 0
	db	'ExitProcess', 0

MessageBoxA:
	db	0, 0
	db	'MessageBoxA', 0

kod.tabaka = 4

girdiler_son:

bölüm1_son:

program_son:
;---------------------------------------------------------------------
; windows ortamında çalışacak program kodları - son
;---------------------------------------------------------------------