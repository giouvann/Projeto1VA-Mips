######################################################################################
# GRUPO: David Fernando, Evelin Dionizio, Giovanna Costa, Miguel Monteiro 
# ATIVIDADE: Projeto 01 - 1ª VA
# DISCIPLINA: Arquitetura e Organização de Computadores 
# SEMESTRE: 2026.1 
# QUESTÃO: Quest�o 2 - Echo MMIO  
# DESCRIÇÃO: Implementa��o de um c�digo que fica constantemente tentando ler um caractere do KEYBOARD MMIO e, sempre que receber um, imprime o mesmo caracter imediatamente no DISPLAY MMIO
######################################################################################
# Mapeamento de Endere�os (I/O):
#0xFFFF0000 - Controle do Teclado
#0xFFFF0004 - Dados do Teclado - Valor ASCII da tecla pressionada 
#0xFFFF0008 - Controle do Display
#0xFFFF00C - Dados do display - Valor ASCII a ser exibido

.data
quebra_linha: .asciiz "\n"		# Define um carecter de nova linha

.text
#main:
aguardando_tecla:
	lw $t0, 0xFFFF0000($zero)		# L� o registrador de controle do teclado
	andi $t0, $t0, 0x0001 			# Isola o bit de status (verifica se � 1)
	beq $t0, $zero, aguardando_tecla	# Se for 0 (nenhuma tecla), volta a espera
	lw $t1, 0xFFFF0004($zero)		# Se h� uma tecla, ler o valor ASCII dela
	
aguardando_display:
	lw $t2, 0xFFFF0008($zero)		# L� o registrador de controle do display
	andi $t2, $t2, 0x0001 			# Verifica se o display est� pronto pra imprimir
	beq $t0, $zero, aguardando_display	# Se o display estiver ocupado, volta a espera
	sw $t1, 0xFFFF000C($zero)		# Se o display est� livre, escreve a tecla lida para exibir
	
	j aguardando_tecla			# Retorna ao in�cio para capturara a pr�xima tecla
