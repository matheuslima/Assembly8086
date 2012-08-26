;Matheus Lima
;Escreve nos primeiros 64K de endereço e lê o dado escrito nesses endereços.
;O objetivo é detectar falhas na montagem da memória RAM
.model small
.data
memValue equ 0FFH
.code

call memoryTest
pop dx
cmp dx,0
jnz sucess
;Coloca em dx o endereço de memória que deu erro
pop dx
sucess:
	mov ax,0

memoryTest proc near
	;Desempilha o endereço da instrução seguinte à chamada da procedure memoryTest
	pop dx
	mov cx, 0FFFFH
	mov si, 0FFFFH
	mov ax, memValue
	;Escreve memValue (0FFH) nos primeiros 64K de memória (0FFFFH)
	write:
		mov [bx],ax
		dec bx
		loop write
	
	mov cx, 0FFFFH
	mov bx, 0FFFFH
	;Lê toda memória que foi anteriormente escrita para buscar algum valor diferente
	;do que foi escrito. Isso indica problemas na memória, como erro na montagem ou
	;pino defeituoso
	read:
		mov ax,[bx]
		cmp ax,memValue
		;Se leu diferente do que foi escrito, há erro na memória
		jnz memoryError
		dec bx
		loop read
	;Se chegou aqui, não encontrou erro na memória. Empilha o valor 0, que indica sucesso
	mov ax, 0
	push ax
	exit:
		;Empilha o endereço da instrução seguinte à chamada da procedure memoryTest
		push dx
		ret
	memoryError:
		;Empilha o endereço de memória em que foi encontrado divergência entre o valor
		;escrito e o valor lido
		push bx
		;Empilha o valor 1, que indica erro
		mov ax,1
		push ax
		jmp exit
memoryTest endp

end
