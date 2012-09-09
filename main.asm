;Matheus Lima
fixo SEGMENT at 0000h

        ASSUME ds:fixo
fixo ENDS
code segment at 0F000h
	org 0000h
	comeco label far
code ends
assume cs:code

;;este programa esta ok (proteus)
;testado no L86 ok 19/06/2012
.model small  
.8086

.data
	;8254
	COUNTER_ONE_ADDRESS		EQU 10000000b
	COUNTER_TWO_ADDRESS		EQU 10010000b
	COUNTER_TREE_ADDRESS 	EQU 10100000b
	CONTROL_WORD_ADDRESS 	EQU 10110000b
	; 00 (counter 0) + 11 (escreve LSB antes, MSB depois) + 011 (seleciona modo 3, gerar onda quadrada) + 0 (contador modo binário)
	CONTROL_WORD_VALUE   	EQU 00110110b 
	; 2.5 MHz (sinal de entrada) / 9.6 KHz (sinal de saída) = 260 = 104H
	COUNTER_VALUE        	EQU 104H
	
	;8255_B
	PORTA	    equ 1000000b ;dados
	PORTB       equ 1010000b
	PORTC	    equ 1100000b ;control display
	PORTCONTROL equ 1110000b
.code

codigo: 

	call configura_Contador
	
	;call memoryTest

;configura 8255
    mov dx, PORTCONTROL
    mov al,10000001b ;comand byte:mod0,portAout,portBout,portCin(0-3),portCout(4-7) = 81h
    out dx, al ;programa a 8255
	
;configura o display	

	call configura_display
	
;;escrevendo no display:

	call delay
	
;;;;;escrevendo as strings


	mov ax,offset STRING1
	push ax
	call esc_strings
	call delay
	
	mov ax,0C0h ;escrever na 2 linha
	push ax
	call esc_command
	call delay
	
	mov ax,offset STRING2
	push ax
	call esc_strings
	call delay
	call delay
	call delay
	
	mov ax,01h ;comando clear display
 	push ax
	call esc_command
	call delay
	
	mov ax,offset STRING3
	push ax
	call esc_strings
	call delay
	call delay
	call delay
	call delay
;;;;string lida na ram

	mov ax,01h ;comando clear display
 	push ax
	call esc_command
	call delay

mov cx,10h
mov ax,61h
mov bx,10h
escreveram:
	mov [bx],al
	inc ax
	inc bx
loop escreveram
mov cx,10h
mov bx,10h
lerram:
	
	mov al,[bx]
	push ax
	call esc_fromreg
	call delay
	call delay
	inc bx
loop lerram
	
	jmp FIM01
	
	
;****************************************************************
; Funções do display - Inicio
;****************************************************************
public configura_display
configura_display proc near
	call delay
	
	mov ax,38h
	push ax
	call esc_command
	call delay
	
	mov ax,38h
	push ax
	call esc_command
	call delay
	
	mov ax,06h
	push ax
	call esc_command
	call delay
	
	
	mov ax,0Eh
	push ax
	call esc_command
	call delay
	
	
	mov ax,01h
	push ax
	call esc_command
	call delay

	ret
configura_display endp

public esc_fromreg
esc_fromreg proc near
pop cx
pop ax
push cx
mov dx,PORTA
	out dx,al ;escreve dado
	
	call delay
	
	mov dx,PORTC
	mov al,0A0H ;enable =1, rs =1
	out dx,al
	
	call delay

	mov dx,PORTC
	mov al,00100000b
	out dx,al ;volta enable =0, rs =1
	
	 inc bx ;;incremento para pegar prox caractere
	;call delay
	
ret
esc_fromreg endp

public esc_strings
esc_strings proc near
	pop cx ;desempilha ip
	pop si ;desempilha offset
	push cx ;empilha ip
	;mov SI,offset STRING
	mov BX,0h
minhafrase:
	MOV Al, cs:[bx + si]
		CMP Al, "$"
		JZ endstr
	mov dx,PORTA
	out dx,al ;escreve dado
	
	call delay
	
	mov dx,PORTC
	mov al,0A0H ;enable =1, rs =1
	out dx,al
	
	call delay

	mov dx,PORTC
	mov al,00100000b
	out dx,al ;volta enable =0, rs =1
	
	 inc bx ;;incremento para pegar prox caractere
	;call delay
	
	jmp minhafrase
endstr:
ret
esc_strings endp

public esc_command
esc_command proc near
	pop cx ;desempilha ip
	pop ax ;desempilha word
	push cx ;empilha ip denovo
	mov dx,PORTA
	out dx,al
	call delay
	
	mov dx,PORTC
	mov al,80h
	out dx,al ;habilita enable
	
	call delay
	
	mov dx,PORTC
	mov al,0h
	out dx,al ;volta enable =0
ret
esc_command endp

public delay
delay PROC NEAR
	pop dx
	mov cx,0ffh
	atraso:
	loop atraso
	push dx
ret
delay endp
;****************************************************************
; Funções do display - Fim
;****************************************************************

;****************************************************************
; Funções do teclado - Inicio
;****************************************************************
scan proc near
scan endp
;****************************************************************
; Funções do teclado - Fim
;****************************************************************


;****************************************************************
; Funções dos dispositivos - Inicio
;****************************************************************
configura_Contador proc near
	pop bx;
	
	;Escreve palavra de controle no contador
	mov dx,CONTROL_WORD_ADDRESS
	mov al,CONTROL_WORD_VALUE
	out dx,al

	;Programa contador 0
	mov dx,COUNTER_ONE_ADDRESS
	mov ax,COUNTER_VALUE ; MSB em AH e LSB em AL
	out dx,al ; envia LSB primeiro
	mov al,ah ; copia o valor de MSB do contador armazenado em AH para o registrador AL
	out dx,al ; envia MSB
	
	push bx;
	ret
configura_Contador endp
;****************************************************************
; Funções dos dispositivos - Fim
;****************************************************************

org 500H
	STRING1 DB "     Matheus $"
	STRING2 DB "     Lima $"
	STRING3 DB "     Mota $"
FIM01:

;Boot do sistema
org 0FFF0H
	nop
    jmp  far ptr comeco

end codigo