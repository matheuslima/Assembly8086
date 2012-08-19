;Matheus Lima
;Programa o contador 8254 para gerar um sinal de onda quadrada de 9600Hz
.model small   
org 100H
.data
COUNTER_ONE_ADDRESS		EQU 80H
COUNTER_TWO_ADDRESS		EQU 81H
COUNTER_TREE_ADDRESS 	EQU 82H
CONTROL_WORD_ADDRESS 	EQU 83H

; 00 (counter 0) + 11 (escreve LSB antes, MSB depois) + 011 (seleciona modo 3, gerar onda quadrada) + 0 (contador modo binário)
CONTROL_WORD_VALUE   	EQU 00110110b 
; 2.5 MHz (sinal de entrada) / 9.6 KHz (sinal de saída) = 260 = 104H
COUNTER_VALUE        	EQU 104H
.code

;Escreve palavra de controle no contador
mov DX,CONTROL_WORD_ADDRESS
mov AL,CONTROL_WORD_VALUE
out DX,AL

;Programa contador 0
mov DX,COUNTER_ONE_ADDRESS
mov AX,COUNTER_VALUE ; MSB em AH e LSB em AL
out DX,AL ; envia LSB primeiro
mov AL,AH ; copia o valor de MSB do contador armazenado em AH para o registrador AL
out DX,AL ; envia MSB

end
