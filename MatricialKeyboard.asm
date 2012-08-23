;Matheus Lima
;Programa o CI 8255 para fazer a leitura de um teclado matricial

dados segment at 0000H
dados ends
assume ds:dados

codigo segment at 0F000H
	org 0000H
	inicio label far ;Aqui eu criei um label far, que pode ser usado no jmp para ir para um segmento e um offset específico
codigo ends
assume cs:codigo

.model small
org 100H
.data
ROWS	EQU 4			;número de linhas
COLS	EQU 4			;múmero de colunas
PORTA	EQU	00H			;endereço da porta A
PORTB	EQU	0CH			;endereço da porta B
.code

verifica_tecla:
	call scan
	pop dx
	cmp dx,1
	jnz fim
	call delay
	
	jmp verifica_tecla
fim:

	

scan proc near
	;tira da pilha o endereço da instrução seguinte a chamada de scan e armazena em dx
	pop dx
	mov bl, 0FEH ;máscara das colunas do teclado
	mov cx, 3
	varre_colunas:
		mov al, bl
		rol bl, 1
		out PORTB, al ;escreve na porta B a máscara de bits
		in  al, PORTA ;lê da porta A as linhas do teclado
		cmp al, 0FH
		jne achou_tecla ; Se leu diferente de F (1111), significa que achou uma tecla pressionada
		loop varre_colunas
	
	mov ax,0 ;Se chegou aqui, não encontrou tecla pressionada
	push ax
	
	retorno:
		;coloca na pilha o endereço da instrução seguinte a chamada de scan armazenado em dx
		push dx
		ret
	achou_tecla:
		mov ax, 1
		push ax
		jmp retorno
scan endp

delay proc near
	pop dx
	;delay de aproximadamente 10 ms
	;entrada de 2.5MHz
	mov cx, 25000
	delay1:
	loop delay1
	push dx
	ret
delay endp

org 0FFF0H
nop
jmp far ptr inicio

end
