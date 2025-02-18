.model tiny
.186
.code
org 100h
locals
;--------------------------------------------------------------------|
VIDEOSEG	equ 0b800h
SCREENL		equ 050h
SCREENW		equ 019h
; TODO change defines
;--------------------------------------------------------------------|
; Enter:  DI
; Broke:  AX
; Output: DI*160
;
; Description:
; ax = di
; di *= 2^7
; ax *= 2^5
; di += ax
;--------------------------------------------------------------------|
DI_MUL_160	macro
		mov ax, di
		shl di, 7
		shl ax, 5
		add di, ax
endm
;--------------------------------------------------------------------|
; DH - X coord the start of frame
; DL - Y coord the start of frame
; BH - Lenght of frame
; BL - Height of frame
;--------------------------------------------------------------------|
Start:		call GetCMDLArgs

		mov byte ptr si, offset String
		call SetFramePosition
		push di

		mov bx, VIDEOSEG
		mov es, bx
		xor bx, bx

		call DrawFrame

		pop di
		call PrintMessage

		mov ax, 4c00h			; return 0
		int 21h

include CommandLine.asm

;--------------------------------------------------------------------|
; Enter:  DX, SI - String to print
; Broke:  BX, DI, AX
; Output: DI - Position of left high frames angle
;--------------------------------------------------------------------|
SetFramePosition	proc

		xor ax, ax
		mov al, dl
		cmp ax, 0h
		jne SkipAutoLength

		call GetStringLength
		xor ax, ax
		add cx, 4h			; magic const sorry
		mov dl, cl

SkipAutoLength:	mov al, dh
		cmp ax, 0h
		jne SkipAutoHeight

		mov dh,	5h			; TODO fix

SkipAutoHeight:	mov di, SCREENW			; di = 25 (screen_width)

		xor ax, ax			; ax = 0
		mov al, dh			; ax = user_height
		sub di, ax			; di = screen_w - user_h

		shr di, 1			; di //= 2
		mov bx, SCREENL			; bx = 80 (screen_length)
		mov al, dl			; ax = user_length
		sub bx, ax			; bx -= ax
		shr bx, 1
		shl bx, 1
		DI_MUL_160			; di *= 160 (Broke ax)

		add di, bx			; di += bx

		ret

SetFramePosition	endp
;--------------------------------------------------------------------|
; Enter: DI, DX
; Broke: AX, SI, DI, BX
; Output: none
;--------------------------------------------------------------------|
DrawFrame	proc

		mov ah, FrameColor		; ah = Frame Color
		mov si, offset Symbols		; si = &Symbols

		call DrawLine

		xor bx, bx
		mov bl, dh			; bx = user_width
		sub bx, 2h

RepeatedLines:	call DrawLine
		sub si, 3h
		dec bx
		cmp bx, 0h
		jne RepeatedLines

		add si, 3h
		call DrawLine

		ret

DrawFrame	endp
;--------------------------------------------------------------------|
; Enter: DI, DX
; Broke: CX, SI, DI(stack fix)
; Output: none
;--------------------------------------------------------------------|
DrawLine	proc

		push di

		lodsb				; al = ds:[si++]
		stosw				; es:[di] = ax

		lodsb				; al = ds:[si++]
		xor cx, cx
		mov cl, dl			; cx = user_length
		sub cx, 2h
		rep stosw			; rep use cx

		lodsb
		stosw

		pop di
		add di, 0a0h		; TODO change to define constant

		ret

DrawLine	endp
;--------------------------------------------------------------------|
; Enter: DI - (top left corner of frame (Pixels)),
;        DX - Sizes Of Frame (DH - Width, DL - Lenght)
; Broke: DI(stack fix), AX(in macros and in lodsb), BX(Line Position)
; Output:
;--------------------------------------------------------------------|
PrintMessage	proc

		mov bx, di			; bx = di (top left corner of frame (Pixels))
							; am i need it?

		mov byte ptr si, offset String	; si = &String

		call SetStringPosition		; Get line position to di register

		xor ax, ax			; ax = 0
					; TODO fix print error if line is empty
		mov ah, FrameColor	; TODO make useful set color

Print:		lodsb
		stosw
		loop Print

		ret

PrintMessage	endp
;--------------------------------------------------------------------|
; Enter:  BX, DI - (top left corner of frame (Pixels)),
;         DX - Sizes Of Frame (DH - Width, DL - Lenght),
;	  SI = &String
; Broke:  DI, CX, AX, BX
; Output: DI - position of the text line
;--------------------------------------------------------------------|
SetStringPosition	proc

		xor cx, cx		; cx = 0
		mov cl, dh		; cx = Width
		shr cx, 1		; cx /= 2 (cx = 1/2 Width)
		mov di, cx		; di = cx (di = 1/2 Width)
		DI_MUL_160		; di *= 160 (di = 160px * 1/2 Width)
		add di, bx	        ; di += top left corner of frame (Pixels)
					; TODO add shift for multiline
		call GetStringLength

		xor ax, ax		; ax = 0
		mov al, dl		; ax = user_length
		sub ax, cx		; ax = user_length - length_of_word(cx)
		add di, ax		; di += ax
		shr di, 1
		shl di, 1

		ret

SetStringPosition	endp
;--------------------------------------------------------------------|
; Enter:  SI = &String
; Broke:  AX, SI(fixed), BX, CX
; Output: CX - length of string
;--------------------------------------------------------------------|
GetStringLength	proc
		mov bx, si			; bx = &String
		xor ax, ax			; ax = 0
		xor cx, cx			; cx = 0

CountLength:	lodsb				; al = ds:[si++]
		cmp al, '$'
		jne CountLength

		sub si, bx			; si -= &String
		mov cx, si			; cx = si (length of string)
		mov si, bx			; si = &String
		dec cx				; cx -= 1

		ret

GetStringLength	endp
;--------------------------------------------------------------------|
.data
Symbols		db "*-*I I*-*", "$"
String		db "Happy New Year", "$"
FrameColor	db 0
;--------------------------------------------------------------------|
end		Start
