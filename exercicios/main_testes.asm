######################################################################################
# GRUPO: David Fernando, Evelin Dionizio, Giovanna Costa, Miguel Monteiro 
# ATIVIDADE: Projeto 01 - 1a VA
# DISCIPLINA: Arquitetura e Organizacao de Computadores 
# SEMESTRE: 2026.1 
# QUESTAO: Questao 1
# DESCRICAO: Codigo main para validar as funcoes strcpy, memcpy, strcmp, strncmp e strcat.
######################################################################################
.data
	# Dados para o teste
	string_origem:  .asciiz "Item: Picanha"  # String que queremos copiar
	buffer_destino: .space 30                # Reserva 30 bytes vazios para o destino

    # Dados para o teste da strcat
    str_destino:   .asciiz "Ola "
                   .space 20         # Espanssço extra para caber o "Mundo!"
    str_origem:    .asciiz "Mundo!"
    msg_strcat:    .asciiz "\nTeste strcat (Concatenação): "
    
    # Dados para o teste de strncmp
    str_ncmp1: .asciiz "Ola mundo"
    str_ncmp2: .asciiz "Ola mundo meu"
    
    # Dados para o teste de strcmp
    str_cmp1: .asciiz "Para lanches"
    str_cmp2: .asciiz "Para lanches"

.text
.globl main_teste

main_teste:
	jal teste_strcpy
	#jal teste_memcpy
	#jal teste_strcat
	#jal teste_strncmp
	#jal teste_strcmp

	# Finaliza o programa após o teste escolhido
	li $v0, 10		# Escolhe a função de "encerrar programa" (serviço 10)
	syscall			# Finaliza a execução

teste_strcpy:
	addi $sp, $sp, -4	# Salva o endereço de retorno na pilha
	sw $ra, 0($sp)		# Armazena o endereço de volta pro main

	la $a0, buffer_destino	# $a0 = destino
	la $a1, string_origem	# $a1 = origem
	jal strcpy		# chama a função strcpy

	# Imprime o resultado na tela
	move $a0, $v0		# Move o valor de retorno ($v0 contêm o endereço do destino) para $a0 para impressão
	li $v0, 4		# Prepara o sistema para imprimir uma string (Serviço 4)
	syscall

	lw $ra, 0($sp)		# Recupera endereço de retorno
	addi $sp, $sp, 4	# Fecha o espaço na pilha
	jr $ra			# Retorna para o main

teste_memcpy:
	addi $sp, $sp, -4	# Salva o endereço de retorno na pilha
	sw $ra, 0($sp)		# Armazena o endereço de volta pro main

	la $a0, buffer_destino	# Destino
	la $a1, string_origem	# Origem
	li $a2, 14		# Define a quantidade de bytes que quer copiar (Item: Picanha + \0)
	jal memcpy		# Chama a função memcpy

	# Imprime o resultado na tela
	move $a0, $v0		# Move o valor de retorno ($v0 contêm o endereço do destino) para $a0 para impressão
	li $v0, 4		# Prepara o sistema para imprimir uma string (Serviço 4)
	syscall

	lw $ra, 0($sp)		# Recupera endereço de retorno
	addi $sp, $sp, 4	# Fecha o espaço na pilha
	jr $ra			# Retorna para o main

teste_strcat:
        addi $sp, $sp, -4	# Salva o endereço de retorno na pilha
        sw $ra, 0($sp)		# Armazena o endereço de volta pro main

        la $a0, str_destino    # Carrega base do destino
        la $a1, str_origem     # Carrega origem
        jal strcat             # Executa a juncao

        # Impressao do resultado
        li $v0, 4
        la $a0, msg_strcat     # Imprime o rotulo
        syscall

        li $v0, 4              # Serviço 4: Imprimir String
        la $a0, str_destino    # Carrega o endereço da string que agora deve ter
        syscall

        lw $ra, 0($sp)		# Recupera endereço de retorno
        addi $sp, $sp, 4	# Fecha o espaço na pilha
        jr $ra			# Retorna para o main

teste_strncmp:
        addi $sp, $sp, -4	# Salva o endereço de retorno na pilha
        sw $ra, 0($sp)		# Armazena o endereço de volta pro main

        la $a0, str_ncmp1    	# Carrega primeira string
        la $a1, str_ncmp2     	# Carrega segunda string
        li $a2, 10		# Define range de letras a serem testadas
        jal strncmp		# Executa a comparação
        
        move $a0, $v0
        li $v0, 1              # Serviço 4: Imprimir String
        syscall

        lw $ra, 0($sp)		# Recupera endereço de retorno
        addi $sp, $sp, 4	# Fecha o espaço na pilha
        jr $ra			# Retorna para o main

teste_strcmp:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $a0, str_cmp1
	la $a1, str_cmp2
	jal strcmp
	
	move $a0, $v0
        li $v0, 1              # Serviço 4: Imprimir String
        syscall

        lw $ra, 0($sp)		# Recupera endereço de retorno
        addi $sp, $sp, 4	# Fecha o espaço na pilha
        jr $ra
