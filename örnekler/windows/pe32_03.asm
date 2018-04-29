;-------------------------------------------------------------------------------
; proje adı: pe32_03.asm
; program biçimi: çalıştırılabilir
; program tanımı: windows ortamında çalışan 32 bitlik uygulama
;-------------------------------------------------------------------------------
TEMEL_ADRES = 400000h

KİMLİK_BAŞLIK = 101
KİMLİK_MESAJ = 102

WS_POPUP   = 80000000h
WS_CHILD   = 40000000h
WS_VISIBLE = 10000000h
WS_CAPTION = 00C00000h
WS_SYSMENU = 00080000h
WS_TABSTOP = 00010000h

BS_PUSHBUTTON       = 00000000h
BS_DEFPUSHBUTTON    = 00000001h
BS_CHECKBOX         = 00000002h
BS_AUTOCHECKBOX     = 00000003h
BS_RADIOBUTTON      = 00000004h
BS_3STATE           = 00000005h
BS_AUTO3STATE       = 00000006h
BS_GROUPBOX         = 00000007h
BS_USERBUTTON       = 00000008h
BS_AUTORADIOBUTTON  = 00000009h
BS_PUSHBOX          = 0000000Ah
BS_OWNERDRAW        = 0000000Bh
BS_TYPEMASK         = 0000000Fh
BS_LEFTTEXT         = 00000020h

BS_TEXT             = 00000000h
BS_ICON             = 00000040h
BS_BITMAP           = 00000080h
BS_LEFT             = 00000100h
BS_RIGHT            = 00000200h
BS_CENTER           = 00000300h
BS_TOP              = 00000400h
BS_BOTTOM           = 00000800h
BS_VCENTER          = 00000C00h
BS_PUSHLIKE         = 00001000h
BS_MULTILINE        = 00002000h
BS_NOTIFY           = 00004000h
BS_FLAT             = 00008000h
BS_RIGHTBUTTON      = BS_LEFTTEXT

dosya.uzantı = 'exe'

db	04Dh
db	05Ah
db	080h
db	000h
db	001h
db	000h
db	000h
db	000h
db	004h
db	000h
db	010h
db	000h
db	0FFh
db	0FFh
db	000h
db	000h
db	040h
db	001h
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
db	054h
db	068h
db	069h
db	073h
db	020h
db	070h
db	072h
db	06Fh
db	067h
db	072h
db	061h
db	06Dh
db	020h
db	063h
db	061h
db	06Eh
db	06Eh
db	06Fh
db	074h
db	020h
db	062h
db	065h
db	020h
db	072h
db	075h
db	06Eh
db	020h
db	069h
db	06Eh
db	020h
db	044h
db	04Fh
db	053h
db	020h
db	06Dh
db	06Fh
db	064h
db	065h
db	02Eh
db	00Dh
db	00Ah
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
db	07Eh
db	020h
db	042h
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
db	00Fh
db	001h
db	00Bh
db	001h
db	001h
db	048h
db	000h
db	002h
db	000h
db	000h
db	000h
db	006h
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
db	010h
db	000h
db	000h
db	000h
db	030h
db	000h
db	000h
db	000h
db	000h
db	040h
db	000h
db	000h
db	010h
db	000h
db	000h
db	000h
db	002h
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
db	079h
db	09Eh
db	000h
db	000h
db	002h
db	000h
db	000h
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
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	030h
db	000h
db	000h
db	034h
db	001h
db	000h
db	000h
db	000h
db	040h
db	000h
db	000h
db	0B8h
db	002h
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
db	02Eh
db	074h
db	065h
db	078h
db	074h
db	000h
db	000h
db	000h
db	072h
db	001h
db	000h
db	000h
db	000h
db	010h
db	000h
db	000h
db	000h
db	002h
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
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	020h
db	000h
db	000h
db	060h
db	02Eh
db	062h
db	073h
db	073h
db	000h
db	000h
db	000h
db	000h
db	044h
db	001h
db	000h
db	000h
db	000h
db	020h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	006h
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
db	0C0h
db	02Eh
db	069h
db	064h
db	061h
db	074h
db	061h
db	000h
db	000h
db	034h
db	001h
db	000h
db	000h
db	000h
db	030h
db	000h
db	000h
db	000h
db	002h
db	000h
db	000h
db	000h
db	006h
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
db	0C0h
db	02Eh
db	072h
db	073h
db	072h
db	063h
db	000h
db	000h
db	000h
db	0B8h
db	002h
db	000h
db	000h
db	000h
db	040h
db	000h
db	000h
db	000h
db	004h
db	000h
db	000h
db	000h
db	008h
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
db	040h

kod.tabaka = 200h
;-------------------------------------------------------------------------------
kod.mimari = '32Bit'
kod.adres = 401000h
kod_başlangıç:
;-------------------------------------------------------------------------------
        push    0
        call    [kernel32_işlevler2.getmodulehandlea]

        push    0
        push    40103Eh
        push    0
        push    25h
        push    eax
        call    [user32_işlevler2.dialogboxparama]

        or      eax,eax
        jz      çıkış

        push    [402000h]
        push    402004h
        push    402044h
        push    0
        call    [user32_işlevler2.messageboxa]

çıkış:
        push    0
        call    [kernel32_işlevler2.exitprocess]

        push    ebp
        mov     ebp,esp
        push    ebx
        push    esi
        push    edi

; cmp    dword [ebp+0Ch],00000110h
db	081h
db	07Dh
db	00Ch
db	010h
db	001h
db	000h
db	000h

; jz L10
db	074h
db	01Ah

; cmp    dword [ebp+0Ch],00000111h
db	081h
db	07Dh
db	00Ch
db	011h
db	001h
db	000h
db	000h

; jz L11
db	074h
db	02Eh

; cmp    dword [ebp+0Ch],00000010h
db	083h
db	07Dh
db	00Ch
db	010h

; jz L12
db	00Fh
db	084h
db	0FBh
db	000h
db	000h
db	000h
        xor     eax,eax

; jmp L13
db	0E9h
db	004h
db	001h
db	000h
db	000h

L10:
        push    B4 0CAh
        push    B4 0CCh
        push    B4 0C9h

db	0FFh
db	075h
db	008h

        call    [user32_işlevler2.checkradiobutton]
db	0E9h
db	0E2h
db	000h
db	000h
db	000h

L11:
db	083h
db	07Dh
db	010h
db	002h
db	00Fh
db	084h
db	0CDh
db	000h
db	000h
db	000h
db	083h
db	07Dh
db	010h
db	001h
db	00Fh
db	085h
db	0CEh
db	000h
db	000h
db	000h

        push    40h
        push    402004h
        push    65h
db	0FFh
db	075h
db	008h

        call    [user32_işlevler2.getdlgitemtexta]
        push    B4 100h
        push    402044h
        push    66h
db	0FFh
db	075h
db	008h

        call    [user32_işlevler2.getdlgitemtexta]
db	0C7h
db	005h
db	000h
db	020h
db	040h
db	000h
db	000h
db	000h
db	000h
db	000h

        push    B4 0C9h
db	0FFh
db	075h
db	008h

        call    [user32_işlevler2.isdlgbuttonchecked]
db	083h
db	0F8h
db	001h
        jnz     devam2
db	083h
db	00Dh
db	000h
db	020h
db	040h
db	000h
db	010h

devam2:
        push    B4 0CAh
db	0FFh
db	075h
db	008h

        call    [user32_işlevler2.isdlgbuttonchecked]
db	083h
db	0F8h
db	001h
db	075h
db	007h
db	083h
db	00Dh
db	000h
db	020h
db	040h
db	000h
db	040h
db	068h
db	0CBh
db	000h
db	000h
db	000h
db	0FFh
db	075h
db	008h
db	0FFh
db	015h
db	0BCh
db	030h
db	040h
db	000h
db	083h
db	0F8h
db	001h
db	075h
db	007h
db	083h
db	00Dh
db	000h
db	020h
db	040h
db	000h
db	020h
db	068h
db	0CCh
db	000h
db	000h
db	000h
db	0FFh
db	075h
db	008h
db	0FFh
db	015h
db	0BCh
db	030h
db	040h
db	000h
db	083h
db	0F8h
db	001h
db	075h
db	007h
db	083h
db	00Dh
db	000h
db	020h
db	040h
db	000h
db	030h
db	068h
db	02Dh
db	001h
db	000h
db	000h
db	0FFh
db	075h
db	008h
db	0FFh
db	015h
db	0BCh
db	030h
db	040h
db	000h
db	083h
db	0F8h
db	001h
db	075h
db	00Ah
db	081h
db	00Dh
db	000h
db	020h
db	040h
db	000h
db	000h
db	000h
db	004h
db	000h
db	06Ah
db	001h
db	0FFh
db	075h
db	008h
db	0FFh
db	015h
db	0C4h
db	030h
db	040h
db	000h
db	0EBh
db	00Bh

L12:
db	06Ah
db	000h
db	0FFh
db	075h
db	008h
db	0FFh
db	015h
db	0C4h
db	030h
db	040h
db	000h
db	0B8h
db	001h
db	000h
db	000h
db	000h

L13:
        pop     edi
        pop     esi
        pop     ebx
        leave

db	0C2h
db	010h

kod.tabaka = 200h
kod_bitiş:
;-------------------------------------------------------------------------------
kod.mimari = '32Bit'
kod.adres = 403000h
iveri_başlangıç:
;-------------------------------------------------------------------------------
        dd      kernel32_işlevler - TEMEL_ADRES, 0, 0
        dd      kernel32_dosya - TEMEL_ADRES, kernel32_işlevler2 - TEMEL_ADRES
        dd      user32_işlevler - TEMEL_ADRES, 0, 0
        dd      user32_dosya - TEMEL_ADRES, user32_işlevler2 - TEMEL_ADRES
        dd      0, 0, 0, 0, 0

kernel32_dosya:
        db      'kernel32.dll', 0, 0

user32_dosya:
        db      'user32.dll', 0

kod.tabaka = 4

kernel32_işlevler:
        dd      GetModuleHandleA - TEMEL_ADRES
        dd      ExitProcess - TEMEL_ADRES
        dd      0

kernel32_işlevler2:
kernel32_işlevler2.getmodulehandlea:
        dd      GetModuleHandleA - TEMEL_ADRES

kernel32_işlevler2.exitprocess:
        dd      ExitProcess - TEMEL_ADRES
        dd      0

GetModuleHandleA:
        dw      0
        db      'GetModuleHandleA', 0, 0

ExitProcess:
        dw      0
        db      'ExitProcess', 0

kod.tabaka = 4

user32_işlevler:
        dd      DialogBoxParamA - TEMEL_ADRES
        dd      CheckRadioButton - TEMEL_ADRES
        dd      GetDlgItemTextA - TEMEL_ADRES
        dd      IsDlgButtonChecked - TEMEL_ADRES
        dd      MessageBoxA - TEMEL_ADRES
        dd      EndDialog - TEMEL_ADRES
        dd      0

user32_işlevler2:
user32_işlevler2.dialogboxparama:
        dd      DialogBoxParamA - TEMEL_ADRES

user32_işlevler2.checkradiobutton:
        dd      CheckRadioButton - TEMEL_ADRES

user32_işlevler2.getdlgitemtexta:
        dd      GetDlgItemTextA - TEMEL_ADRES

user32_işlevler2.isdlgbuttonchecked:
        dd      IsDlgButtonChecked - TEMEL_ADRES

user32_işlevler2.messageboxa:
        dd      MessageBoxA - TEMEL_ADRES
        dd      EndDialog - TEMEL_ADRES
        dd      0

DialogBoxParamA:
        dw      0
        db      'DialogBoxParamA', 0

CheckRadioButton:
        dw      0
        db      'CheckRadioButton', 0, 0

GetDlgItemTextA:
        dw      0
        db      'GetDlgItemTextA', 0

IsDlgButtonChecked:
        dw      0
        db      'IsDlgButtonChecked', 0, 0

MessageBoxA:
        dw      0
        db      'MessageBoxA', 0

EndDialog:
        dw      0
        db      'EndDialog', 0

kod.tabaka = 200h
iveri_bitiş:
;-------------------------------------------------------------------------------
kod.mimari = '32Bit'
kod.adres = 403000h
rsrc_başlangıç:
;-------------------------------------------------------------------------------
db	000h
db	000h
db	000h
db	000h
db	07Eh
db	020h
db	042h
db	05Ah
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	001h
db	000h
db	005h
db	000h
db	000h
db	000h
db	018h
db	000h
db	000h
db	080h
db	000h
db	000h
db	000h
db	000h
db	07Eh
db	020h
db	042h
db	05Ah
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	001h
db	000h
        dw      37
db	000h
db	000h
db	030h
db	000h
db	000h
db	080h
db	000h
db	000h
db	000h
db	000h
db	07Eh
db	020h
db	042h
db	05Ah
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	001h
db	000h
db	009h
db	004h
db	000h
db	000h
db	048h
db	000h
db	000h
db	000h
db	058h
db	040h
db	000h
db	000h
db	060h
db	002h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db      0
db      0
db      0C0h
db      0


db	0C8h
db	080h
db	000h
db	000h
db	000h
db	000h
db	00Dh
db	000h
        dw      70
        dw      70
        dw      190
        dw      175
db	000h
db	000h
db	000h
db	000h

        dbw     'Create message box'

        dw      0

        dw      10
        dbw     'Ms Sans Serif'

db	000h
db	000h
db	090h
db	090h
db	000h
db	000h
db	000h
db	050h
db	000h
db	000h
db	000h
db	000h
        dw      10
        dw      10
        dw      70
        dw      8
        dw      0FFh
db	0FFh
db	0FFh
db	082h
db	000h

        dbw     '&Caption'
        dw      3Ah


db	000h
db	000h
db	000h
db	000h
db	000h
db	000h
db	081h
db	050h
db	000h
db	000h
db	000h
db	000h
        dw      10
        dw      20
        dw      170
        dw      13
        dw      KİMLİK_BAŞLIK
db	0FFh
db	0FFh
db	081h
db	000h
db	000h
db	000h
db	000h
db	000h
db	090h
db	090h
db	000h
db	000h
db	000h
db	050h
db	000h
db	000h
db	000h
db	000h
        dw      10
        dw      40
        dw      70
        dw      8
db	0FFh
db	0FFh
db	0FFh
db	0FFh
db	082h
db	000h

        dbw     '&Message'
        dw      3Ah

db	000h
db	000h
db	000h
db	000h
db	080h
db	000h
db	081h
db	050h
db	000h
db	000h
db	000h
db	000h
        dw      10
        dw      50
        dw      170
        dw      13
        dw      KİMLİK_MESAJ
db	0FFh
db	0FFh
db	081h
db	000h
db	000h
db	000h
db	000h
db	000h
db	090h
db	090h
db	007h
db	000h
db	000h
db	050h
db	000h
db	000h
db	000h
db	000h
        dw      10
        dw      70
        dw      80
        dw      70
db	0FFh
db	0FFh
db	0FFh
db	0FFh
db	080h
db	000h
        dbw     '&Icon'

db	000h
db	000h
db	000h
db	000h
db	009h
db	000h
db	003h
db	050h
db	000h
db	000h
db	000h
db	000h
        dw      20
        dw      82
        dw      60
        dw      13
db	0C9h
db	000h
db	0FFh
db	0FFh
db	080h
db	000h

        dbw     '&Error'
db	000h
db	000h
db	000h
db	000h
db	090h
db	090h
db	009h
db	000h
db	000h
db	050h
db	000h
db	000h
db	000h
db	000h
        dw      20
        dw      95
        dw      60
        dw      13
db	0CAh
db	000h
db	0FFh
db	0FFh
db	080h
db	000h

        dbw     'I&nformation'

db	000h
db	000h
db	000h
db	000h
db	090h
db	090h
db	009h
db	000h
db	000h
db	050h
db	000h
db	000h
db	000h
db	000h
        dw      20
        dw      108
        dw      60
        dw      13
db	0CBh
db	000h
db	0FFh
db	0FFh
db	080h
db	000h

        dbw     '&Question'
db	000h
db	000h
db	000h
db	000h
db	009h
db	000h
db	000h
db	050h
db	000h
db	000h
db	000h
db	000h
        dw      20
        dw      121
        dw      60
        dw      13
db	0CCh
db	000h
db	0FFh
db	0FFh
db	080h
db	000h

        dbw     '&Warning'

db	000h
db	000h
db	000h
db	000h
db	090h
db	090h
db	007h
db	000h
db	000h
db	050h
db	000h
db	000h
db	000h
db	000h
        dw      100
        dw      70
        dw      80
        dw      70
        dw      0FFh
db	0FFh
db	0FFh
db	080h
db	000h

        dbw     '&Style'

db	000h
db	000h
db	000h
db	000h
db	090h
db	090h
db	003h
db	000h
db	001h
db	050h
db	000h
db	000h
db	000h
db	000h
        dw      110
        dw      82
        dw      60
        dw      13

db	02Dh
db	001h
db	0FFh
db	0FFh
db	080h
db	000h

        dbw     '&Top Most'

; OK button
db	000h
db	000h
db	000h
db	000h
db	001h
db	000h
db	001h
db	050h
db	000h
db	000h
db	000h
db	000h
        dw      85
        dw      150
        dw      45
        dw      15
        dw      1
db	0FFh
db	0FFh
db	080h
db	000h

        dbw     'OK'

db	000h
db	000h
db	000h
db	000h
db	090h
db	090h
db	000h
db	000h
db	001h
db	050h
db	000h
db	000h
db	000h
db	000h
        dw      135
        dw      150
        dw      45
        dw      15
        dw      2
db	0FFh
db	0FFh
db	080h
db	000h

        dbw     'C&ancel'

kod.tabaka = 200h
