;-------------------------------------------------------------------------------
; program adı: pe32_dll_01.asm
; program tanımı: 32 bit windows dll
; windows ortamında çalışacak program kodları - başlangıç
;-------------------------------------------------------------------------------
program_başlangıç:

TEMEL_ADRES = 400000h

dosya.ad = 'merhaba'
dosya.uzantı = 'dll'

; MZ başlık verileri
	dw	'MZ'
        dw      80h
        dw      1
        dw      0
        dw      4
        dw      10h
        dw      0FFFFh
        dw      0
        dw      140h

db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	040h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	080h
db	000h
db	000h
db	000h
db	00Eh
db	01Fh
db	0BAh
db	00Eh
db	000h
db	0B4h
db	009h
db	0CDh
db	021h
db	0B8h
db	001h
db	04Ch
db	0CDh
db	021h

        db      'This program cannot be run in DOS mode.', 0Dh, 0Ah

db	024h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	050h
db	045h
db	000h
db	000h
db	04Ch
db	001h
db	004h
db	000h
db	0CFh
db	03Ah
db	0AEh
db	05Ah
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	0E0h
db	000h
db	00Eh
db	021h

        dw      10Bh
        db      001h
        db      048h
        dd      200h
        dd      600h
        dd      0
        dd      1000h
        dd      1000h
        dd      2000h
        dd      400000h
        dd      1000h
        dd      200h

db	001h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	004h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	050h
db	000h
db	000h
db	000h
db	004h
db	000h
db	000h
db	039h
db	0A7h
db	000h
db	000h
db	002h
db	000h
db	040h
db	000h
db	000h
db	010h
db	000h
db	000h
db	000h
db	010h
db	000h
db	000h
db	000h
db	000h
db	001h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	010h
db	000h
db	000h
db	000h
db	000h
db	030h
db	000h
db	000h
db	049h
db	000h
db	000h
db	000h
db	000h
db	020h
db	000h
db	000h
db	052h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	040h
db	000h
db	000h
db	00Ch
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h

; bölümler - sections

        dq      '.text'
        dd      37h
        dd      1000h
        dd      kod_son-kod_başlangıç
        dd      400h
        dd      0, 0, 0
        dd      60000020h

        dq      '.idata'
        dd      52h
        dd      2000h
        dd      iveri_son-iveri_başlangıç
        dd      600h
        dd      0, 0, 0
        dd      0C0000040h

        dq      '.edata'
        dd      49h
        dd      3000h
        dd      edata_son-edata_başlangıç
        dd      800h
        dd      0, 0, 0
        dd      40000040h

        dq      '.reloc'
        dd      0Ch
        dd      4000h
        dd      reloc_son-reloc_başlangıç
        dd      0A00h
        dd      0, 0, 0
        dd      42000040h

kod.tabaka = 200h
;-------------------------------------------------------------------------------
kod.mimari = '32Bit'
kod.adres = 401000h
kod_başlangıç:
;-------------------------------------------------------------------------------
DLLBaşlangıçİşlevi:

        push    ebp
        mov     ebp,esp
        mov     eax,1
        leave

        ; retn 000ch
        db	0C2h
        db	00Ch

kod.tabaka = 4

	db	'DLL dosyasından merhaba!', 0

MerhabaDLLİşlevi:

        push    10h
        push    0
        push    40100Ch
        push    0
        call    [40203Ch]

        db	0C3h

kod.tabaka = 512
kod_son:
;-------------------------------------------------------------------------------
kod.mimari = '32Bit'
kod.adres = 402000h
iveri_başlangıç:
;-------------------------------------------------------------------------------
        dd      dosya3 - TEMEL_ADRES
        dd      0
        dd      0
        dd      dosya1 - TEMEL_ADRES
        dd      dosya2 - TEMEL_ADRES
        dd      0
        dd      0
        dd      0
        dd      0
        dw      0

        dw      0
dosya1:
        db      'USER32.DLL', 0
        db      0
dosya3:
        dd      MessageBoxA - TEMEL_ADRES
        dd      0
dosya2:
        dd      MessageBoxA - TEMEL_ADRES
        dd      0
MessageBoxA:
        dw      0
        db      'MessageBoxA', 0

kod.tabaka = 200h
iveri_son:
;-------------------------------------------------------------------------------
kod.mimari = '32Bit'
kod.adres = 403000h
edata_başlangıç:
;-------------------------------------------------------------------------------
        dd      0
        dd      0
        dw      0
        dw      0
        dd      3032h
        dd      1
        dd      1
        dd      1
        dd      burası2 - TEMEL_ADRES
        dd      dll_işlevler_adres - TEMEL_ADRES
        dd      dll_dosya_adı - TEMEL_ADRES

burası2:
        dd      MerhabaDLLİşlevi - TEMEL_ADRES

dll_işlevler_adres:
        dd      dll_işlevler - TEMEL_ADRES

dll_dosya_adı:
        dw      0
        db      'merhaba.dll', 0

dll_işlevler:
        db      'MerhabaDLL', 0

kod.tabaka = 200h
edata_son:
;-------------------------------------------------------------------------------
kod.mimari = '32Bit'
kod.adres = 404000h
reloc_başlangıç:
;-------------------------------------------------------------------------------
db	000h
db	010h
db	000h
db	000h
db	00Ch
db	000h
db	000h
db	000h
db	02Ah
db	030h
db	032h
db	030h
db	000h
db	000h

kod.tabaka = 200h
reloc_son:

program_son:
;-------------------------------------------------------------------------------
; windows ortamında çalışacak program kodları - son
;-------------------------------------------------------------------------------
