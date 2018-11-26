;-------------------------------------------------------------------------------
; proje adı: pe32_01.asm
; program biçimi: çalıştırılabilir
; program tanımı: windows ortamında çalışan 32 bitlik uygulama
;-------------------------------------------------------------------------------

; önemli: problem çıkaran kodlar satır başından itibaren açıklama olarak işaretlenmiş
; bir sonraki satırda ise geçici çözüm yolu uygulanmıştır

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

kod.mimari = '32Bit'
kod.adres = 401000h

kod_başlangıç:

; grafiksel arabirim kodları
;-------------------------------------------------------------------------------
;        mov     ecx,test2
        mov     ecx,0
        push    ecx
        pop     eax
;        call    SayısalDeğeriKaraktereÇevir
        call    0

        ; mesaj kutusunu görüntüle
        push    0
;        push    PencereBaşlık
        push    0
;        push    PencereMesaj
        push    0
        push    0
;        call    [MessageBoxAİşlevi]
        call    0

        ; programdan çık
        push    0
;        call    [ExitProcessİşlevi]
        call    0

dosya.ekle 'islevler0.inc'

dd      'C'

;===============================================================================
; işlev adı: SayısalDeğeriKaraktereÇevir
; açıklama : sayısal değeri karakter katarı değerine çevirir
;
; giriş değerleri:
;       eax = karakter katarına çevrilecek sayı
; çıkış değerleri:
;       karakter katarı değeri PencereMesaj adresinde
;===============================================================================
SayısalDeğeriKaraktereÇevir:

        pushad

;        mov     edi,PencereMesaj+9
        mov     edi,0

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
;        jnz     sonraki_basamak
        jnz     0

        popad
        ret

;===============================================================================
; işlev adı: topla
; açıklama : toplama işlemini gerçekleştirir
;
; giriş değerleri:
;       eax = 1. sayı
;       ebx = 2. sayı
; çıkış değerleri:
;       eax = sonuç değer
;===============================================================================
topla:
        add     eax,ebx
        ret

kod.tabaka = 200h

veri_başlangıç:
PencereBaşlık:	db0     'Assembler 2 (a2)'
PencereMesaj:	db0     '0000000000'

; program içerisinde kullanılacak sistem işlevleri (import table)
;-------------------------------------------------------------------------------
kod.tabaka = 4
girdiler_başlangıç:
	dd	0, 0, 0, kernel32_dll - TEMEL_ADRES, ExitProcessİşlevi - TEMEL_ADRES
	dd	0, 0, 0, user32_dll - TEMEL_ADRES, MessageBoxAİşlevi - TEMEL_ADRES
	dd	0, 0, 0, 0, 0

kernel32_dll:
	db0     'kernel32.dll'

user32_dll:
	db0     'user32.dll'

ExitProcessİşlevi:
	dd	ExitProcess - TEMEL_ADRES
	dd	0

MessageBoxAİşlevi:
	dd	MessageBoxA - TEMEL_ADRES
	dd	0

ExitProcess:
	dw      0
	db0     'ExitProcess'

MessageBoxA:
	dw      0
	db0     'MessageBoxA'

kod.tabaka = 4

girdiler_son:

bölüm1_son:

program_son:
;-------------------------------------------------------------------------------
; windows ortamında çalışacak program kodları - son
;-------------------------------------------------------------------------------
