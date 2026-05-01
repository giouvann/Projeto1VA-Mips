######################################################################################
# GRUPO: David Fernando, Evelin Dionizio, Giovanna Costa, Miguel Monteiro 
# ATIVIDADE: Projeto 01 - 1a VA 
# DISCIPLINA: Arquitetura e Organizacao de Computadores 
# SEMESTRE: 2026.1 
# QUESTAO: Quest�o 1 - Funs�o strcpy 
# DESCRI��O: Copia uma string terminada em nulo da origem para o destino
######################################################################################
.globl strcpy

strcpy:
	move $v0, $a0               # Copia o endere�o inicial de $a0 para $v0

loop_strcpy:
	lb $t0, 0($a1)              # L� 1 byte da mem�ria da origem ($a1) para $t0 (Load Byte)
	sb $t0, 0($a0)              # Escreve esse byte de $t0 no destino $a0 (Store Byte)
	beq $t0, $zero, end_strcpy         # Se $t0 == 0 (se o caracter for NULL ('\0')'), encerra
	
	addi $a0, $a0, 1            # Soma 1 ao endere�o de dentino (vai para o pr�ximo byte)
	addi $a1, $a1, 1            # Soma 1 ao endere�o de origem (vai para o pr�ximo byte)
	
	j loop_strcpy                     # Salto incondicional
end_strcpy:
	jr $ra                     # Retorna para quem chamou
