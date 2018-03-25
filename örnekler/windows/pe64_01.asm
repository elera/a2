;---------------------------------------------------------------------
; program biçimi: exe
; program tanımı: windows ortamında çalışan 64 bitlik uygulama
; windows ortamında çalışacak program kodları - başlangıç
;---------------------------------------------------------------------
program_başlangıç:

TEMEL_ADRES = 140000000h

MAKİNE_TİP_I386 = 14Ch
MAKİNE_TİP_X64 = 8664h

dosya.uzantı = 'exe'

Signature:              dq 5A4Dh,0
ntHeader                dd 00004550h
        dw      MAKİNE_TİP_X64
        dw      1
TimeStump              dd 0
Symbol_table_offset    dd 0
Symbol_table_count     dd 0
Size_of_optional_header dw 80h
Characteristics        dw 23h
optional_header:
Magic_optional_header  dw 20Bh
Linker_version_major_and_minor dw 9
Size_of_code           dd 0
Size_of_init_data      dd 0C0h
Size_of_uninit_data    dd 0
        dd      bölüm1_başlangıç
base_of_code           dd ntHeader
image_base             dq TEMEL_ADRES
section_alignment      dd 10h
file_alignment         dd 10h
OS_version_major_minor dw 5,2
image_version_major_minor dd 0
subsystem_version_major_minor dw 5,2
Win32_version          dd 0
size_of_image          dd 159h
size_of_header         dd 0d0h
checksum               dd 0
subsystem              dw 2
DLL_flag               dw 8000h
Stack_allocation       dq 100000h
Stack_commit           dq 1000h
Heap_allocation        dq 100000h
Heap_commit            dq 1000h
loader_flag            dd 0h
number_of_dirs         dd 2
export_RVA_size         dq 0
import_RVA             dd girdiler_başlangıç
import_size            dd girdiler_son-girdiler_başlangıç
section_table          dq '.text'
virtual_size           dd 55h
virtual_address        dd bölüm1_başlangıç
Physical_size          dd girdiler_son-bölüm1_başlangıç
Physical_offset        dd bölüm1_başlangıç
Relocations            dd 0
Linenumbers            dd 0
Relocations_and_Linenumbers_count dd 0
Attributes              dd 80000020h

bölüm1_başlangıç:

; grafiksel arabirim kodları
;----------------------------------------------------------------

;    sub rsp, 28h        ; space for 4 arguments + 16byte aligned stack
db 48h, 83h, 0ECh, 28h

;    xor r9d, r9d        ; 4. argument: r9d = uType = 0
db 45h, 31h, 0C9h

;    lea r8, [MsgCaption]; 3. argument: r8  = caption
db 4Ch, 8Dh, 05h
dd      MsgCaption-0DEh

;    lea rdx,[MsgBoxText]; 2. argument: edx = window text
db 48h, 8Dh, 15h
dd      MsgBoxText-0E5h

        ; 1. argument: rcx = hWnd = NULL
        xor     ecx,ecx

;    call [MessageBoxAİşlevi]
db 0FFh, 15h
dd      MessageBoxAİşlevi-0EDh

;    add rsp, 28h
db 48h, 83h, 0C4h, 28h

;    ret
db 0C3h

;------------------------------------------------
MsgCaption      db '--Assembler 2 (a2)----',0
MsgBoxText      db '0.0.9.2018-10.03.2018   ',0
;------------------------------------------------

MessageBoxAİşlevi:
        dq      MessageBoxA
        dd      0


kod.tabaka = 4

; program içerisinde kullanılacak sistem işlevleri (import table)
;---------------------------------------------------------------------
girdiler_başlangıç:
        dd      0, 0, 0, user32_dll, MessageBoxAİşlevi
        dd      0, 0, 0, 0, 0



user32_dll:
        db      'user32',0

MessageBoxA:
        db      0, 0
        db      'MessageBoxA', 0

kod.tabaka = 4

girdiler_son:

bölüm1_son:

program_son:
;---------------------------------------------------------------------
; windows ortamında çalışacak program kodları - son
;---------------------------------------------------------------------