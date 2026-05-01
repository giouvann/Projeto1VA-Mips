######################################################################################
# GRUPO: David Fernando, Evelin Dionizio, Giovanna Costa, Miguel Monteiro 
# ATIVIDADE: Projeto 01 - 1a VA
# DISCIPLINA: Arquitetura e Organiza��o de Computadores 
# SEMESTRE: 2026.1 
# QUEST�O: Quest�o 1 - Funs�o memcpy  
# DESCRI��O: Copia um bloco cont�nuo de mem�ria de um endere�o de origem para um endere�o de destino
######################################################################################
.globl memcpy

memcpy:
	move $v0, $a0		# Salva o endere�o inicial de $a0 para $v0
	
loop_memcpy:
	beq $a2, $zero, end_memcpy	# Se $a2 == 0, pula para o fim
	lbu $t0, 0($a1)		# Carrega 1 byte da memoria de origem ($a1) para $t0
	sb $t0, 0($a0)		# Armazena esse byte no endere�o de destino
	
	addi $a0, $a0, 1	# Avan�a o ponteiro de destino para o proximo byte
	addi $a1, $a1, 1	# Avan�a o ponteiro de origem para o proximo byte
	addi $a2, $a2, -1	# decrementa o contador de bytes restantes (num --)
	
	j loop_memcpy			# Continua o loop
end_memcpy:
	jr $ra 			# Retorno
