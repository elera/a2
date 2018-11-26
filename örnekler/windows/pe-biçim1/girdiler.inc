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
