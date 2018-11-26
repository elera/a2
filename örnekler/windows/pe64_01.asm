;-------------------------------------------------------------------------------
; proje adı: pe64_01.asm
; program biçimi: çalıştırılabilir
; program tanımı: windows ortamında çalışan 64 bitlik uygulama

        dosya.uzantı = 'exe'

program_başlangıç:
;-------------------------------------------------------------------------------
TEMEL_ADRES = 400000h

MAKİNE_TİP_X64 = 8664h

; https://board.flatassembler.net/topic.php?t=20690
; http://www.sunshine2k.de/reversing/tuts/tut_pe.htm
; https://wiki.osdev.org/PE
; https://en.wikibooks.org/wiki/X86_Disassembly/Windows_Executable_Files
; http://umuttosun.com/portable-executable-pe-file-format/


; MZ başlık verileri
        dw      'MZ'            ; signature
        dw	80h             ; lastsize
        dw      1               ; nblocks
        dw      0               ; nreloc
        dw      4               ; hdrsize

        dw      10h             ; minalloc
        dw	0FFFFh          ; maxalloc
        dw	0               ; ss
        dw      140h            ; sp
        dw      0               ; checksum
        dw      0               ; ip
        dw      0               ; cs
        dw      40h             ; relocpos
        dw      0               ; noverlay
        dw      0, 0, 0, 0      ; reserved1
        dw      0               ; oem_id
        dw      0               ; oem_info
        dd      0, 0, 0, 0, 0   ; reserved2
        dd	80h
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

db      'This program cannot be run in DOS mode.' ,0Dh, 0Ah
db      '$'



db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h

; PE başlık verileri (PeHeader)
        dd      'PE'                    ; mMagic
        dw      MAKİNE_TİP_X64          ; mMachine
        dw      3                       ; mNumberOfSections
        dd      %ts_unix+0              ; mTimeDateStamp
        dd	0                       ; mPointerToSymbolTable (COFF formatı için)
        dd      0                       ; mNumberOfSymbols (COFF formatı için)
        dw      0F0h                    ; mSizeOfOptionalHeader yapısının uzunluğu
        dw      2Fh                     ; mCharacteristics

; PE seçimli başlık verileri (Pe32OptionalHeader)
        dw      20Bh                    ; signature - 0x010b - PE32, 0x020b - PE32+ (64 bit)
        db	1                       ; MajorLinkerVersion
        db	48h                     ; MinorLinkerVersion
        dd      200h                    ; SizeOfCode
        dd      400h                    ; SizeOfInitializedData
        dd      0                       ; SizeOfUninitializedData
        dd      1000h                   ; AddressOfEntryPoint - kod başlangıç RVA adres değeri
        dd      1000h                   ; BaseOfCode
; COFF formatı için
        dd      400000h                 ; ImageBase
        dd      0                       ; SectionAlignment
        dd      1000h                   ; FileAlignment
        dw      200h                    ; MajorOSVersion
        dw      0                       ; MinorOSVersion
        dw      1                       ; MajorImageVersion
        dw      0                       ; MinorImageVersion
        dw      0                       ; MajorSubsystemVersion
        dw      0                       ; MinorSubsystemVersion
        dd      5                       ; Win32VersionValue
        dd      0                       ; SizeOfImage
        dd      4000h                   ; SizeOfHeaders
        dd      200h                    ; Checksum
        dw      0CEh                    ; Subsystem
        dw      4                       ; DLLCharacteristics
        dd      2                       ; SizeOfStackReserve
        dd      1000h                   ; SizeOfStackCommit
        dd      0                       ; SizeOfHeapReserve
        dd      1000h                   ; SizeOfHeapCommit
        dd      0                       ; LoaderFlags
        dd      10000h                  ; NumberOfRvaAndSizes



        dd      0

; dizinler
        dd      0
        dd      0

        dd      0
        dd      10h

        dd      0, 0

        dd      3000h
        dd      0AAh

        dd      0, 0
        dd      0, 0
        dd      0, 0
        dd      0, 0
        dd      0, 0
        dd      0, 0
        dd      0, 0
        dd      0, 0
        dd      0, 0
        dd      0, 0
        dd      0, 0
        dd      0, 0
        dd      0, 0
        dd      0, 0

; bölüm başlıkları - kod
        dq      '.kod'                          ; Name
        dd      2Dh                             ; PhysicalAddress
        dd      kod_başlangıç - TEMEL_ADRES     ; VirtualAddress
        dd      kod_bitiş - kod_başlangıç       ; SizeOfRawData
        dd      200h                            ; PointerToRawData
        dd      0                               ; PointerToRelocations
        dd      0                               ; PointerToLinenumbers
        dw      0                               ; NumberOfRelocations
        dw      0                               ; NumberOfLinenumbers
        dd      60000020h                       ; Characteristics

        dq      '.veri'
        dd      024h
        dd      veri_başlangıç - TEMEL_ADRES
        dd      veri_bitiş - veri_başlangıç
        dd      400h
        dd      0, 0
        dw      0, 0
        dd      0C0000040h

        dq      '.iveri'
        dd      0AAh
        dd      iveri_başlangıç - TEMEL_ADRES
        dd      iveri_bitiş - iveri_başlangıç
        dd      600h
        dd      0, 0
        dw      0, 0
        dd      0C0000040h
kod.tabaka = 200h
;-------------------------------------------------------------------------------
kod.mimari = '64Bit'
kod.adres = 401000h
kod_başlangıç:
;-------------------------------------------------------------------------------
        sub     rsp,28h         ; 28h = byte
        ;mov     r9d,0
        db      41h, 0B9h, 0, 0, 0, 0
        ;lea     r8,[PencereBaşlık]
        db      4Ch, 8Dh, 5
        dd      0FEFh
        ;lea     rdx,[PencereMesaj]
        db      48h, 8Dh, 15h
        dd      0FF9h
        mov     rcx,0           ; 0 değeri 32 bitliktir
        ;call    user32_işlevler.messageboxa
        db      0FFh, 15h, 2Fh, 20h, 00, 00

        mov     ecx,eax
        db      0FFh, 15h, 0Fh, 20h, 0, 0
        ;call    kernel32_işlevler.exit_process

kod.tabaka = 200h
kod_bitiş:
;-------------------------------------------------------------------------------
kod.mimari = '64Bit'
kod.adres = 402000h
veri_başlangıç:
;-------------------------------------------------------------------------------
PencereBaşlık:	db0     'Assembler 2 (a2)'
PencereMesaj:	db	%tarih + ' - ' + %saat

kod.tabaka = 200h
veri_bitiş:
;-------------------------------------------------------------------------------
kod.mimari = '64Bit'
kod.adres = 403000h
iveri_başlangıç:
;-------------------------------------------------------------------------------
        dd      0                                       ; OriginalFirstThunk
        dd      0                                       ; TimeDateStamp
        dd      0                                       ; ForwarderChain
        dd      kernel32_dosya - TEMEL_ADRES            ; Name
        dd      kernel32_işlevler - TEMEL_ADRES         ; FirstThunk

        dd      0, 0, 0, user32_dosya - TEMEL_ADRES, user32_işlevler - TEMEL_ADRES
        dd      0, 0, 0, 0, 0

; kernel32 çağrı giriş bilgileri
;-------------------------------------------------------------------------------
kernel32_işlevler:
kernel32_işlevler.exit_process:
        dq      ExitProcess - TEMEL_ADRES

kernel32_işlevler.getcommandlinea:
        dq      GetCommandLineA - TEMEL_ADRES
        dq      0

; user32 çağrı giriş bilgileri
;-------------------------------------------------------------------------------
user32_işlevler:
user32_işlevler.messageboxa:
        dq      MessageBoxA - TEMEL_ADRES
        dq      0

MessageBoxA:
        dw      0                                       ; Hint
        db0     'MessageBoxA'                           ; Name

kernel32_dosya:
        db0     'kernel32.dll'

user32_dosya:
        db0     'user32.dll'

ExitProcess:
        dw      0
        db0     'ExitProcess'

GetCommandLineA:
        dw      0
        db0     'GetCommandLineA'

kod.tabaka = 200h
iveri_bitiş:
;-------------------------------------------------------------------------------
program_bitiş:
