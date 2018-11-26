;-------------------------------------------------------------------------------
; proje adı: pe32_01.asm
; program biçimi: çalıştırılabilir
; program tanımı: windows ortamında çalışan 32 bitlik uygulama
;-------------------------------------------------------------------------------
dosya.uzantı = 'exe'

TEMEL_ADRES = 400000h

dosya.ekle 'tanımw.inc'
dosya.ekle 'başlıkbilgisi.inc'

kod.mimari = '32Bit'
kod.adres = 401000h
kod_başlangıç:

; grafiksel arabirim kodları
;-------------------------------------------------------------------------------
;        mov     ecx,test2
        push    ecx
        pop     eax
;        call    SayısalDeğeriKaraktereÇevir

        ; mesaj kutusunu görüntüle
        push    0
;        push    PencereBaşlık
;        push    PencereMesaj
        push    0
;        call    [MessageBoxAİşlevi]

        ; programdan çık
        push    0
;        call    [ExitProcessİşlevi]

;dosya.ekle 'islevler.inc'

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

dosya.ekle 'girdiler.inc'

bölüm1_son:
