######################################################################################
# GRUPO: David Fernando, Evelin Dionizio, Giovanna Costa, Miguel Monteiro 
# ATIVIDADE: Projeto 01 - 1a VA
# DISCIPLINA: Arquitetura e Organização de Computadores 
# SEMESTRE: 2026.1 
# QUESTÃO: Questão 1 - Funsão memcpy  
# DESCRIÇÃO: Copia um bloco contínuo de memória de um endereço de origem para um endereço de destino
######################################################################################
.globl memcpy

memcpy:
	move $v0, $a0		# Salva o endereço inicial de $a0 para $v0
	
loop:
	beq $a2, $zero, end	# Se $a2 == 0, pula para o fim
	lbu $t0, 0($a1)		# Carrega 1 byte da memoria de origem ($a1) para $t0
	sb $t0, 0($a0)		# Armazena esse byte no endereço de destino
	
	addi $a0, $a0, 1	# Avança o ponteiro de destino para o proximo byte
	addi $a1, $a1, 1	# Avança o ponteiro de origem para o proximo byte
	addi $a2, $a2, -1	# decrementa o contador de bytes restantes (num --)
	
	j loop			# Continua o loop
end:
	jr $ra 			# Retorno