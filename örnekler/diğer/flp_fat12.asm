;************************************************************************
;                                                                       *
;       Kodlayan: Fatih KILIÇ                                           *
;       Telif Bilgisi: haklar.txt dosyasına bakınız                     *
;                                                                       *
;       Dosya Adı: flp_fat12.asm                                        *
;       Dosya İşlevi: floppy FAT12 açılış sektörü                       *
;                                                                       *
;       Kodlama Tarihi: 08/12/2010                                      *
;       Güncelleme Tarihi: 09/10/2010                                   *
;                                                                       *
;************************************************************************
kod.mimari = '16Bit'
kod.adres = 0

;        jmp     start
;        nop

oem_name        db      'ELERA   '
byte_per_sec    dw      512
sec_per_clus    db      1
res_sec         dw      1
fat_nums        db      2
max_root_entry  dw      224     ;(14*512)/32
total_secs      dw      2880    ;for 1.44 floppy
media_desc      db      0xf0    ;3.5" çift taraflı, 80 iz, 18 sectör iz başına
sec_per_fat     dw      9
sec_per_track   dw      18
num_of_heads    dw      2
hidden_secs     dd      0
total_secs_ffff dd      0       ;65535 sektörden büyük diskler için
drive_num       db      0       ;0 = çıkarılabilir disk, 0x80 = hard disk
reserved        db      0
boot_sign       db      0x29    ;genişletilmiş boot imzası
vol_id          dd      0x08122010
vol_label       db      'ELERA      '
file_sys_type   db      'FAT12   '

;************************************************************************
;       boot sektör bellek kullanım değerleri                           *
;************************************************************************
;0x7c00..0x7e00 - 0x200  -> boot kod'un yüklendiği adres
;0x7e00..0x8000 - 0x200  -> boot yığın adresi
;0x8000..0x9c00 - 0x1c00 -> geçici sektörlerin yüklendiği adres
;0x10000.................-> bilden.bin dosyasının yüklendiği adres

kod.tabaka = 4
start:

        ;tüm segment yazmaçlarını ayarla
        ;cs = ds = es = 0x7c00
        ;ss = 0x8000-32
        ;----------------------------------------------------------------
        mov     ax,0x7c0
;        mov     ds,ax
;        mov     es,ax
;        mov     ss,ax
        mov     sp,(0x400-32)

        ;açılış yapılan boot aygıtı
        ;----------------------------------------------------------------
        mov     ax,1
        mov     [boot_drv],ax

        ;yükleme aygıt bilgisini ekrana yaz
        ;----------------------------------------------------------------
        mov     si,msg_loading
        call    write_msg

        ;es:bx (0x7c00+0x400=0x8000) dizin/dosya girişlerini yükle
        ;dizin/dosya girişleri 20. sektörden başlar. toplam 14 sektör
        ;----------------------------------------------------------------
        mov     bx,0x400
        mov     [lba_c],0
        mov     [lba_h],1
        mov     [lba_s],2
        mov     [num_sec2read],14
        call    read_sector
;        jc      show_read_error

        ;elera.bin dosyası mevcut mu ? ara.
        ;----------------------------------------------------------------
        mov     si,0x400
        mov     di,bilden_file
        cld
@@:
;        push    si
;        push    di
        mov     cx,11
;        rep     cmpsb
;        pop     di
;        pop     si
;        je      load_fat
;        add     si,32
        cmp     si,0x400+(512*14)
;        jb      @b

        ;elera.bin dosyası mevcut değilse,
        ;hata mesajı ver ve sistemi kilitle.
        ;----------------------------------------------------------------
        mov     si,file_not_found
        call    write_msg
        jmp     %BURASI

load_fat:

        ;elera.bin dosyasının bulunduğu ilk cluster'ı sakla
        ;----------------------------------------------------------------
        mov     ax,[si+0x1a]
        mov     [cluster],ax

        ;ilk FAT tablosunu geçici bellek alanına yükle
        ;----------------------------------------------------------------
        mov     bx,0x400
        mov     [lba_c],0
        mov     [lba_h],0
        mov     [lba_s],2
        mov     [num_sec2read],9
        call    read_sector
;        jc      show_read_error

        ;elera.bin dosyasının yükleneceği bellek alanı (0x10000)
        ;----------------------------------------------------------------
        mov     bx,0x1000
;        mov     es,bx
        xor     bx,bx

load_kernel:

        ;cluster değerini c,h,s formatına çevir ve sektörü oku
        ;----------------------------------------------------------------
        call    lba2chs
        call    read_sector
;        jc      show_read_error

        ;floppy okuma göstergesi ..................
        ;----------------------------------------------------------------
;        mov     al,'.'
        call    write_char

        ;es:bx değerini 512 byte artır
        ;----------------------------------------------------------------
;        mov     bx,es
;        add     bx,0x20         ;0x20 shl 4 = 0x200 (512)
;        mov     es,bx
        xor     bx,bx

        ;cluster değerini 1.5 ile çarp ve bir sonraki cluster değerini al
        ;----------------------------------------------------------------
        mov     si,[cluster]
;        shr     si,1
        pushf
;        add     si,[cluster]
;        add     si,0x400
        mov     ax,[si]
        popf
;        jc      .odd_cluster

.even_cluster:
;        and     ax,0xfff        ;alt 12 bit
;        jmp     .clus_calc_done
.odd_cluster:
;        shr     ax,4            ;üst 12 bit

.clus_calc_done:
;        cmp     ax,0xff8
;        jae     exec_kernel

        mov     [cluster],ax
;        jmp     load_kernel

exec_kernel:
        mov     ax,[boot_drv]

        push    B2 0x1000     ;segment
        push    B2 0          ;offset
;        retf

;========================================================================
;
;işlev  : write_msg
;tanım  : text modunda ekrana karakter katarı yazar
;giriş  : ds:si = karakter katar adresi
;çıkış  : yok
;
;========================================================================
kod.tabaka = 4
write_msg:
;@@:
        lodsb
;        test    al,al
        jz      @f
        call    write_char
;        jmp     @b
;@@:
;        ret

;========================================================================
;
;işlev  : write_char
;tanım  : text modunda ekrana karakter yazar
;giriş  : al = karakter
;çıkış  : yok
;
;========================================================================
kod.tabaka = 4
write_char:
        mov     ah,0xe
        int     0x10
;        ret

;========================================================================
;
;işlev  : show_read_error
;tanım  : sektör okuma hatası mesajını ekrana yazar
;giriş  : yok
;çıkış  : yok
;
;========================================================================
kod.tabaka = 4
show_read_error:
        mov     si,sec_read_error
        call    write_msg
        jmp     %BURASI

;========================================================================
;
;işlev  : lba2chs
;tanım  : mantıksal sektör değerini c,h,s formatına çevirir
;giriş  : ax = maktıksal sektor
;çıkış  : yok
;
;========================================================================
kod.tabaka = 4
lba2chs:

;        push    bx

        mov     ax,[cluster]
;        add     ax,31
;        push    ax
        mov     bl,18*2
        div     bl
        mov     [lba_c],al

        mov     al,ah
        mov     ah,0
        mov     bl,18
        div     bl
        mov     [lba_h],al

;        pop     ax
        mov     bl,18
        div     bl
        inc     ah
        mov     [lba_s],ah
        mov     [num_sec2read],1

;        pop     bx
;        ret

;========================================================================
;
;işlev  : read_sector
;tanım  : floppy sürücüsünden sektör içeriğini okur
;giriş  : yok
;çıkış  : yok
;
;========================================================================
kod.tabaka = 4
read_sector:

        mov     [read_retry],10
.retry:
        mov     ah,2
        mov     al,[num_sec2read]
        mov     dl,0
        mov     ch,[lba_c]
        mov     dh,[lba_h]
        mov     cl,[lba_s]
        int     0x13
;        jnc     .success

;        dec     [read_retry]
        jnz     .retry
.error:
        stc
;        ret
.success:
        clc
;        ret

;************************************************************************
;       katarlar(strings) - değişkenler(vars)                           *
;************************************************************************
kod.tabaka = 4
lba_c           db      0
lba_h           db      0
lba_s           db      0
num_sec2read    db      0
read_retry      db      0
kod.tabaka = 4
cluster         dw      0
boot_drv        dw      0

bilden_file     db      'BILDEN  BIN'
msg_loading     db      13,10,'denetim programi yukleniyor',0
file_not_found  db      13,10,'ERR: file not found...',0
sec_read_error  db      13,10,'ERR: sector read error.',0

;times (512-2)-$ db 0

signature:
        db      0x55
        db      0xaa
