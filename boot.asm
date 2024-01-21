ORG 0
BITS 16
_start:
	jmp short start
	nop

times 33 db 0 ; BIOS parameter block for the BIOS can fill up the code

; Move the message to the si register, call lodsb goes to si register and puts first character in al register.

start:
	jmp 0x7c0:step2 ; code reg replace with 0x7c0 then jump to step2

handle_zero:
	mov ah, 0eh
	mov al, 'A'
	mov bx, 0x00
	int 0x10
	iret
handle_one:
	mov ah, 0eh
	mov al, 'V'
	mov bx, 0x00
	int 0x10
	iret

step2:
	cli ; clear interrupts
	mov ax, 0x7c0
	mov ds, ax
	mov es, ax
	mov ax, 0x00
	mov ss, ax
	mov sp, 0x7c00
	sti ; enables interrupts

	mov word[ss:0x00], handle_zero ; ss is the stack segment must be specified, other wise it will point to 0x7c0
	mov word[ss:0x02], 0x7c0 ; ss is the stack segment must be specified, other wise it will point to 0x7c0

	mov word[ss:0x04], handle_one ; ss is the stack segment must be specified, other wise it will point to 0x7c0
	mov word[ss:0x06], 0x7c0 ; ss is the stack segment must be specified, other wise it will point to 0x7c0

	int 1

	mov si, message
	call print
	jmp $

print:
	mov bx, 0
.loop:
	lodsb ; load character that si reg is pointing to and increment
	cmp al, 0
	je .done ; anything under is if not 0
	call print_char ; if not 0 here
	jmp .loop

.done:
	ret
	
print_char:
	mov ah, 0eh
	int 0x10 ; Calling a BIOS routine for VIDEO TELETYPE OUTPUT
	ret

;message db 'I Love You My Beautiful Butterfly', 0
message db 'as-kernel', 0

times 510-($ - $$) db 0 ; Fill atleast 510 bytes of data
dw 0xAA55 ; assemble word basically for 2 bytes

