;-------------------------------------------------------------------------------
; proje adı: pe32_01.asm
; program biçimi: çalıştırılabilir
; program tanımı: windows ortamında çalışan 32 bitlik uygulama
;-------------------------------------------------------------------------------
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
	dd	bölüm1_son-kod_başlangıç
	dd	200h
	dd	0, 0, 0
	dd	0E0000060h

	dq	'.veri'
	dd	200h
	dd	1000h
	dd	bölüm1_son-kod_başlangıç
	dd	400h
	dd	0, 0, 0
	dd	0E0000060h

kod.tabaka = 200h

kod.mimari = '32Bit'
kod.adres = 401000h

kod_başlangıç:

; grafiksel arabirim kodları
;-------------------------------------------------------------------------------
        ; test amaçlı
        finit
        fld     [Val1]
        fld     [Val2]
        faddp
        fstp    [Val3]

        mov     eax,[SayisalDeger]
        mov     cl,3
        shl     eax,cl

        push    fs
        pop     eax

        sgdt    [Val3]
        mov     eax,[Val3]

        call    nas

        mov     ebx,eax
        mov     eax,ebx
        mov     edi,PencereMesaj+9

sonraki_basamak:

        xor     edx,edx
        mov     ebx,10
        div     ebx
        add     dl,48

        ; mov     [edi],dl
        db      88h, 17h

        inc     ecx
        dec     edi
        cmp     eax,0
        jnz     sonraki_basamak

        ; mesaj kutusunu görüntüle
        push    0
        push    PencereBaşlık
        push    PencereMesaj
        push    0
        call    [MessageBoxAİşlevi]

        ; programdan çık
        push    0
        call    [ExitProcessİşlevi]

nas:
        mov     eax,714
        ret

kod.tabaka = 200h

veri_başlangıç:
PencereBaşlık:	db	'Assembler 2 (a2)', 0
PencereBaşlık2:	db	'Assembler 2 (a2)-2', 0
PencereMesaj:	db	'0000000000', 0
SayisalDeger    dd      1
Val1            dd      0.1
Val2            dd      0.2
Val3            dd      0
Val4            dd      0

; program içerisinde kullanılacak sistem işlevleri (import table)
;-------------------------------------------------------------------------------
kod.tabaka = 4
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
;-------------------------------------------------------------------------------
; windows ortamında çalışacak program kodları - son
;-------------------------------------------------------------------------------
