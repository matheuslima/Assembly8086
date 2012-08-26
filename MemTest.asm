;Matheus Lima
;Escreve nos primeiros 64K de endere�o e l� o dado escrito nesses endere�os.
;O objetivo � detectar falhas na montagem da mem�ria RAM
.model small
.data
memValue equ 0FFH
.code

call memoryTest
pop dx
cmp dx,0
jnz sucess
;Coloca em dx o endere�o de mem�ria que deu erro
pop dx
sucess:
	mov ax,0

memoryTest proc near
	;Desempilha o endere�o da instru��o seguinte � chamada da procedure memoryTest
	pop dx
	mov cx, 0FFFFH
	mov si, 0FFFFH
	mov ax, memValue
	;Escreve memValue (0FFH) nos primeiros 64K de mem�ria (0FFFFH)
	write:
		mov [bx],ax
		dec bx
		loop write
	
	mov cx, 0FFFFH
	mov bx, 0FFFFH
	;L� toda mem�ria que foi anteriormente escrita para buscar algum valor diferente
	;do que foi escrito. Isso indica problemas na mem�ria, como erro na montagem ou
	;pino defeituoso
	read:
		mov ax,[bx]
		cmp ax,memValue
		;Se leu diferente do que foi escrito, h� erro na mem�ria
		jnz memoryError
		dec bx
		loop read
	;Se chegou aqui, n�o encontrou erro na mem�ria. Empilha o valor 0, que indica sucesso
	mov ax, 0
	push ax
	exit:
		;Empilha o endere�o da instru��o seguinte � chamada da procedure memoryTest
		push dx
		ret
	memoryError:
		;Empilha o endere�o de mem�ria em que foi encontrado diverg�ncia entre o valor
		;escrito e o valor lido
		push bx
		;Empilha o valor 1, que indica erro
		mov ax,1
		push ax
		jmp exit
memoryTest endp

end
