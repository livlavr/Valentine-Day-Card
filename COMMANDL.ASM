;--------------------------------------------------------------------|
;Enter: SI - Beginning of the number
;Broke:	CX, BX, SI, AX
;Output: BX - Number from console
;--------------------------------------------------------------------|
GetCMDLArgs	proc

		mov si, 82h
		call GetNumber
		;mov ax, 0b800h
		;mov es, ax
		;xor ax, ax
		;mov byte ptr al, bl
		;mov ah, 01000010b
		;mov di, 0a0h
		;stosw
		mov dl, bl
		call GetNumber
		mov dh, bl

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

@@Loop:	lodsb				; ax = ds:[si++]
		cmp ax, 39h			; ax <= '9'
		jge @@Exit
		cmp ax, 30h 			; ax >= '0'
		jle @@Exit
		sub ax, 30h
		mov cx, bx			; cx = bx
		shl bx, 3			; bx *= 8
		shl cx, 1			; cx *= 2 (2bx)
		add bx, cx			; bx = 10bx
		add bx, ax
		jmp @@Loop

@@Exit:		inc si
		ret

GetNumber	endp
;--------------------------------------------------------------------|
;--------------------------------------------------------------------|
;--------------------------------------------------------------------|
;--------------------------------------------------------------------|
;--------------------------------------------------------------------|
;--------------------------------------------------------------------|
;--------------------------------------------------------------------|
;--------------------------------------------------------------------|
