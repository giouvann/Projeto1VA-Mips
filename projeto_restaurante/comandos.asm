.data
teste_comando: .asciiz "cardapio_ad-15-00490-coca cola"
teste_rm: .asciiz "15"

str_cardapio_ad: .asciiz "cardapio_ad"
str_cardapio_rm: .asciiz "cardapio_rm"
str_cardapio_list: .asciiz "cardapio_list"

msg_err_comando: .asciiz "\nComando invalido\n"
msg_err_codigo: .asciiz "\nFalha: código de item inválido\n"
msg_err_item:   .asciiz "\nFalha: número de item já cadastrado\n"
msg_sucesso: .asciiz "\nItem adicionado com sucesso\n"
msg_removido:       .asciiz "\nItem removido com sucesso\n"
msg_err_nao_existe: .asciiz "\nErro: item nao existe\n"

resultado:
    .word 0   # codigo
    .word 0   # preco
    .word 0   # descricao

msg_item:   .asciiz "\n--- ITEM ---\n"
msg_codigo: .asciiz "Codigo: "
msg_preco:  .asciiz "\nPreco: "
msg_desc:   .asciiz "\nDescricao: "


.eqv ITEM_SIZE 48		# Tamanho de um item

.eqv MAX_ITENS 20		# Quantidade máxima

.eqv CODIGO_OFFSET 0		# Offset para acessar o código do item

.eqv PRECO_OFFSET 4		# Offset para acessar o preço do item

.eqv DESC_OFFSET 8		# Offset para acessar a descrição do item

.align 2
cardapio:			# Cardápio (array de itens)
    .space 960   		# 20 * 48 bytes


.text
.globl main

# ---------------- MAIN ----------------:
main:
    	la $a0, teste_comando
    	move $s0, $a0          # guarda ponteiro original

    	la $a1, resultado
    	jal conversao_cmd

    	move $a0, $s0          # comando
    	la $a1, resultado      # struct com parametros
    	jal switch_comandos
	
	jal cardapio_list
	
	la $a0, teste_rm
	jal cardapio_rm
	
	jal cardapio_list

    	li $v0, 10
    	syscall


# -------- FUNÇÃO --------
conversao_cmd:
    	addi $sp, $sp, -8
    	sw $ra, 0($sp)
    	sw $s0, 4($sp)

    	move $t0, $a0      # ponteiro da string
    	move $t4, $a1      # ponteiro da struct resultado

    	li $t1, 0          # contador de partes

loop_parse:
    	lb $t2, 0($t0)
    	beq $t2, $zero, fim_parse

    	li $t3, '-'
    	beq $t2, $t3, separador

    	addi $t0, $t0, 1
    	j loop_parse

separador:
    	sb $zero, 0($t0)   # quebra string

    	addi $t0, $t0, 1   # próximo início
    	addi $t1, $t1, 1

    	beq $t1, 1, salva_codigo
    	beq $t1, 2, salva_preco
    	beq $t1, 3, salva_desc

    	j loop_parse

salva_codigo:
    	sw $t0, 0($t4)
    	j loop_parse

salva_preco:
    	sw $t0, 4($t4)
    	j loop_parse

salva_desc:
    	sw $t0, 8($t4)
    	j loop_parse

fim_parse:
    	lw $ra, 0($sp)
    	lw $s0, 4($sp)
    	addi $sp, $sp, 8
    	jr $ra
    
strcmp:
    	# $a0: ponteiro para a primeira string
    	# $a1: ponteiro para a segunda string
    	# $v0: valor de retorno

loop_strcmp:
    	lb $t0, 0($a0)              # Carrega byte da primeira string
    	lb $t1, 0($a1)              # Carrega byte da segunda string
    	beq $t0, $t1, check_null_strcmp    # Se os caracteres sao iguais, testa se são null
    	sub $v0, $t0, $t1           # Caso sejam diferentes, a diferença é armazenada em $v0 
    	jr $ra                      # Retorna a diferença

check_null_strcmp:
    	beq $t0, $zero, equal_strcmp       # Se ambos são null (fim das cadeias de caracteres), as string são iguais
    	addi $a0, $a0, 1            # Não são null, passa para o próximo byte da primeira string
    	addi $a1, $a1, 1            # Não são null, passa para o próximo byte da segunda string
    	j loop_strcmp                      # Continua o loop

equal_strcmp:
    	li $v0, 0                   # Retorna 0 para string iguais
    	jr $ra                      # Retorno

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


switch_comandos:
    	addi $sp, $sp, -8
    	sw $ra, 0($sp)
    	sw $a1, 4($sp)     # salva ponteiro da struct

    	move $t0, $a0      # comando
    	la $a1, str_cardapio_ad
    	move $a0, $t0
    	jal strcmp

    	beq $v0, $zero, chama_cardapio_ad

    	li $v0, 4
    	la $a0, msg_err_comando
    	syscall
    	j fim_switch

chama_cardapio_ad:
    	lw $t4, 4($sp)     # struct

    	lw $a0, 0($t4)     # codigo
    	lw $a1, 4($t4)     # preco
    	lw $a2, 8($t4)     # descricao

    	jal cardapio_ad
    
fim_switch:
    	lw $ra, 0($sp)
    	addi $sp, $sp, 8
    	jr $ra

cardapio_ad:
    	# -------- PROLOGUE --------
    	addi $sp, $sp, -20
    	sw $ra, 0($sp)
    	sw $s0, 4($sp)
    	sw $s1, 8($sp)
    	sw $s2, 12($sp)
    	sw $s3, 16($sp)

    	# -------- SALVA PARÂMETROS --------
    	move $s0, $a0   # codigo (string)
    	move $s1, $a1   # preco (string)
    	move $s2, $a2   # descricao (string)

    	# -------- CODIGO (string -> int) --------
    	move $a0, $s0
    	jal string_to_int
    	move $s0, $v0   # salva resultado inteiro

	# -------- VALIDACAO --------
	blt $s0, 1, erro_codigo
	bgt $s0, 20, erro_codigo
	
	addi $s0, $s0, -1   # transforma em índice (0-based)
	
	# -------- CALCULO DO ENDERECO --------
	la $t0, cardapio
	li $t1, ITEM_SIZE

	mul $t2, $s0, $t1
	add $s3, $t0, $t2   # s3 = endereço do item

	# -------- VERIFICAR SE JA EXISTE --------
	lw $t3, CODIGO_OFFSET($s3)
	bne $t3, $zero, erro_item_existente

	# -------- SALVAR CODIGO --------
	addi $t4, $s0, 1    # volta para valor original
	sw $t4, CODIGO_OFFSET($s3)

    	# -------- PRECO (string -> int) --------
    	move $a0, $s1
    	jal string_to_int
    	move $s1, $v0

	sw $s1, PRECO_OFFSET($s3)

    	# -------- DESCRICAO (string) --------	
	move $t0, $s3

	addi $a0, $t0, DESC_OFFSET
	move $a1, $s2
	jal strcpy

fim_cardapio_ad:
    	# -------- EPILOGUE --------
    	lw $ra, 0($sp)
    	lw $s0, 4($sp)
    	lw $s1, 8($sp)
    	lw $s2, 12($sp)
    	lw $s3, 16($sp)
    	addi $sp, $sp, 20

    	jr $ra

erro_codigo:
    	li $v0, 4
    	la $a0, msg_err_codigo
    	syscall

    	j fim_cardapio_ad
    
erro_item_existente:
    	li $v0, 4
    	la $a0, msg_err_item
    	syscall

    	j fim_cardapio_ad
   
string_to_int:
    	li $v0, 0          # resultado = 0

loop_string_to_int:
    	lb $t0, 0($a0)     # pega caractere atual

    	# fim da string
    	beq $t0, $zero, fim_str_to_int

    	# quebra de linha '\n'
    	li $t1, 10
    	beq $t0, $t1, fim_str_to_int

    	# validar: '0' <= char <= '9'
    	li $t1, 48         # '0'
    	li $t2, 57         # '9'

    	blt $t0, $t1, fim_str_to_int  # se < '0', para
    	bgt $t0, $t2, fim_str_to_int  # se > '9', para

    	# converte ASCII → número
    	addi $t0, $t0, -48

    	# resultado = resultado * 10
    	mul $v0, $v0, 10

    	# resultado += digito
    	add $v0, $v0, $t0

    	# próximo caractere
    	addi $a0, $a0, 1
    	beq $zero, $zero, loop_string_to_int

fim_str_to_int:
    	jr $ra
    	
cardapio_list:
    	# -------- PROLOGUE --------
	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)

	li $s0, 0              # i = 0

loop_list:
	li $t0, MAX_ITENS
	bge $s0, $t0, fim_list

	# calcular endereço --------
	la $t1, cardapio
	li $t2, ITEM_SIZE
	mul $t3, $s0, $t2
	add $s1, $t1, $t3     # s1 = endereço do item

	# verificar se existe --------
	lw $t4, CODIGO_OFFSET($s1)
	beq $t4, $zero, proximo_item

	# -------- imprimir separador --------
    	li $v0, 4
    	la $a0, msg_item
    	syscall

    	# -------- imprimir código --------
    	li $v0, 4
    	la $a0, msg_codigo
    	syscall

    	move $a0, $t4
    	li $v0, 1
    	syscall

    	# -------- imprimir preço --------
    	lw $t5, PRECO_OFFSET($s1)

    	li $v0, 4
    	la $a0, msg_preco
    	syscall

    	move $a0, $t5
    	li $v0, 1
    	syscall

    	# -------- imprimir descrição --------
    	li $v0, 4
    	la $a0, msg_desc
    	syscall

    	addi $a0, $s1, DESC_OFFSET
    	li $v0, 4
    	syscall

proximo_item:
    	addi $s0, $s0, 1
    	j loop_list

fim_list:
    	# -------- EPILOGUE --------
    	lw $ra, 0($sp)
    	lw $s0, 4($sp)
    	lw $s1, 8($sp)
    	lw $s2, 12($sp)
    	addi $sp, $sp, 16

    	jr $ra

cardapio_rm:
    	# -------- PROLOGUE --------
    	addi $sp, $sp, -20
    	sw $ra, 0($sp)
    	sw $s0, 4($sp)
    	sw $s1, 8($sp)
    	sw $s2, 12($sp)
    	sw $s3, 16($sp)

    	# -------- SALVA PARÂMETRO --------
    	move $s0, $a0   # codigo (string)

    	# -------- CONVERTER CODIGO --------
   	move $a0, $s0
    	jal string_to_int
    	move $s1, $v0   # codigo int

    	# -------- VALIDACAO --------
    	blt $s1, 1, erro_codigo
    	bgt $s1, 20, erro_codigo

    	addi $s1, $s1, -1   # índice

    	# -------- CALCULAR ENDERECO --------
    	la $t0, cardapio
    	li $t1, ITEM_SIZE

    	mul $t2, $s1, $t1
    	add $s2, $t0, $t2   # endereço do item

    	# -------- VERIFICAR SE EXISTE --------
    	lw $t3, CODIGO_OFFSET($s2)
    	beq $t3, $zero, erro_item_nao_existe

   	# -------- REMOVER ITEM --------
    	sw $zero, CODIGO_OFFSET($s2)
    	sw $zero, PRECO_OFFSET($s2)

    	# limpar descrição (opcional: só colocar '\0' no início)
    	addi $t4, $s2, DESC_OFFSET
    	sb $zero, 0($t4)

    	# -------- SUCESSO --------
    	li $v0, 4
    	la $a0, msg_removido
    	syscall

    	j fim_cardapio_rm
    
fim_cardapio_rm:
    	lw $ra, 0($sp)
    	lw $s0, 4($sp)
    	lw $s1, 8($sp)
    	lw $s2, 12($sp)
    	lw $s3, 16($sp)
    	addi $sp, $sp, 20

    	jr $ra
   
erro_item_nao_existe:
    	li $v0, 4
    	la $a0, msg_err_nao_existe
    	syscall
    	j fim_cardapio_rm