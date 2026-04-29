######################################################################################
# GRUPO: David Fernando, Evelin Dionizio, Giovanna Costa, Miguel Monteiro 
# ATIVIDADE: Projeto 01 - 1a VA 
# DISCIPLINA: Arquitetura e Organizacao de Computadores 
# SEMESTRE: 2026.1 
# QUESTAO: Questão 1 - Funsão strcpy 
# DESCRIÇÃO: Copia uma string terminada em nulo da origem para o destino
######################################################################################
.globl strcpy

strcpy:
	move $v0, $a0               # Copia o endereço inicial de $a0 para $v0

loop:
	lb $t0, 0($a1)              # Lê 1 byte da memória da origem ($a1) para $t0 (Load Byte)
	sb $t0, 0($a0)              # Escreve esse byte de $t0 no destino $a0 (Store Byte)
	beq $t0, $zero, end         # Se $t0 == 0 (se o caracter for NULL ('\0')'), encerra
	
	addi $a0, $a0, 1            # Soma 1 ao endereço de dentino (vai para o próximo byte)
	addi $a1, $a1, 1            # Soma 1 ao endereço de origem (vai para o próximo byte)
	
	j loop                     # Salto incondicional
end:
	jr $ra                     # Retorna para quem chamou
