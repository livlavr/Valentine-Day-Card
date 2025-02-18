;--------------------------------------------------------------------|
;Enter: SI - Beginning of the number
;Broke:	CX, BX, SI, AX
;Output: BX - Number from console
;--------------------------------------------------------------------|
GetCMDLArgs	proc

		mov si, 82h
		call GetNumber			; bl - length of frame
		mov dl, bl
		call GetNumber			; bl - Height of frame
		mov dh, bl
		call GetColor			; bl - ColorHexNumber
		mov FrameColor, bl
		call GetNumber			; bl - NumberOfPreset
		call SetStyle			; Style - Preset
		ret

GetCMDLArgs	endp
;--------------------------------------------------------------------|
;Enter: SI - Beginning of the number
;Broke:	CX, BX, SI, AX
;Output: BX - Number from console
;--------------------------------------------------------------------|
GetNumber	proc

		xor bx, bx
		xor ax, ax

@@Loop:		lodsb				; ax = ds:[si++]
		cmp ax, 39h			; ax <= '9'
		jg @@Exit
		cmp ax, 30h 			; ax >= '0'
		jl @@Exit
		sub ax, 30h
		mov cx, bx			; cx = bx
		shl bx, 3			; bx *= 8
		shl cx, 1			; cx *= 2 (2bx)
		add bx, cx			; bx = 10bx
		add bx, ax
		jmp @@Loop

@@Exit:		ret

GetNumber	endp
;--------------------------------------------------------------------|
;Enter: SI - Beginning of the color
;Broke:	CX, BX, SI, AX
;Output: BX - Number from console
;--------------------------------------------------------------------|
GetColor	proc

		xor bx, bx
		xor ax, ax

Digit:		lodsb				; ax = ds:[si++]
		cmp ax, 39h			; ax <= '9'
		jg BigLetter
		cmp ax, 30h 			; ax >= '0'
		jl BigLetter

		sub ax, 30h
		shl bx, 4			; bx *= 16
		add bx, ax
		jmp Digit

BigLetter:
		cmp ax, 46h			; ax <= 'F'
		jg SmallLetter
		cmp ax, 41h 			; ax >= 'A'
		jl SmallLetter

		sub ax, 37h
		shl bx, 4			; bx *= 16
		add bx, ax			; bx += ax
		jmp Digit

SmallLetter:
		cmp ax, 66h			; ax <= 'f'
		jg @@Exit
		cmp ax, 61h 			; ax >= 'a'
		jl @@Exit

		sub ax, 57h
		shl bx, 4			; bx *= 16
		add bx, ax
		jmp Digit

@@Exit:		ret

GetColor	endp
;--------------------------------------------------------------------|
;Enter: BL - Number of Preset, SI - Beginning of user style (if exists)
;Broke: AX, BX
;Output: Style - style preset
;--------------------------------------------------------------------|
SetStyle	proc

		cmp bx, 0h
		je UserStyle

		mov ax, bx			;
		shl bx, 3			; bx *= 9
		add bx, ax			;

		xor ax, ax
		mov ax, offset FramesArray
		add ax, bx
		mov Style, ax
		jmp @@Exit

UserStyle:
		;mov ax, si
		mov Style, si
		add si, 11			; move ptr to start of message '"'

@@Exit:		ret

SetStyle	endp
;--------------------------------------------------------------------|
;--------------------------------------------------------------------|
;--------------------------------------------------------------------|
;--------------------------------------------------------------------|
;--------------------------------------------------------------------|
;--------------------------------------------------------------------|
;--------------------------------------------------------------------|
