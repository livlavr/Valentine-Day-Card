.model tiny
.186
.code
org 100h
;--------------------------------------------------------------------|
VIDEOSEG	equ 0b800h
COLOR		equ 00100000b
MYLENGTH	equ 030h
MYWIDTH		equ 0fh
SCREENL		equ 050h
SCREENW		equ 019h
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
; di += bx
;--------------------------------------------------------------------|
DI_MUL_160	macro
		mov ax, di	
		shl di, 7	
		shl ax, 5	
		add di, ax	
		add di, bx
endm
;--------------------------------------------------------------------|
; DH - X coord the start of frame
; DL - Y coord the start of frame
; BH - Lenght of frame
; BL - Height of frame
;--------------------------------------------------------------------|
Start:
		mov dl, MYLENGTH
		mov dh, MYWIDTH

		call SetPosition

		mov bx, VIDEOSEG
		mov es, bx
		xor bx, bx

		call DrawFrame

		mov ax, 4c00h			; return 0
		int 21h

;--------------------------------------------------------------------|
; Enter:  DX
; Broke:  BX, DI, AX
; Output: DI - Position of left high frames angle
;--------------------------------------------------------------------|
SetPosition	proc

		mov di, SCREENW			; di = SCREEN_WIDTH

		xor ax, ax
		mov al, dh
		sub di, ax

		shr di, 1			; di //= 2
		mov bx, SCREENL			; bx = 80
		mov al, dl
		sub bx, ax			; bx = user_length ; Haven't to shr bx, because I need length in bytes

		DI_MUL_160

		ret

SetPosition	endp
;--------------------------------------------------------------------|
; Enter: DI, DX
; Broke: AX, SI, DI, BX
; Output: none
;--------------------------------------------------------------------|
DrawFrame	proc

		mov ah, COLOR			; ah = color
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
; Output:
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
		add di, 0a0h

		ret

DrawLine	endp
;--------------------------------------------------------------------|
; Enter: DI - (top left corner of frame (Pixels)),
;        DX - Sizes Of Frame (DH - Width, DL - Lenght)
; Broke: CX, SI, DI(stack fix)
; Output:
;--------------------------------------------------------------------|
PrintLine	proc
;		DI += (DH >> 1) * 160
		ret
PrintLine	endp
;--------------------------------------------------------------------|
.data
Symbols		db "*-*I I*-*", "$"
String		db "Happy Valentine!$", "$"
;--------------------------------------------------------------------|
end		Start
