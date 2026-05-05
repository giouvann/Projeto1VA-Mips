######################################################################################
# GRUPO: David Fernando, Evelin Dionizio, Giovanna Costa, Miguel Monteiro
# ATIVIDADE: Projeto 01 - 1ª VA
# DISCIPLINA: Arquitetura e Organização de Computadores
# SEMESTRE: 2026.1
# QUESTÃO: Projeto Principal
# DESCRIÇÃO: Parser, switch de comandos, funções core e utilitários
######################################################################################
.include "dados.asm"
.text

# ====================================================================================
# PARSER DE STRING
# Entrada : $a0 = ptr string de entrada, $a1 = ptr struct resultado (4 words)
# Efeito  : preenche resultado[0..3] com ponteiros para cada token
#           substitui '-' por \0 para separar os tokens in-place
# ====================================================================================
conversao_cmd:
    move $t0, $a0          # cursor na string
    move $t4, $a1          # base da struct resultado
    li   $t1, 0            # índice do próximo campo a preencher

    # resultado[0] = início da string (comando)
    sw   $t0, 0($t4)
    addi $t1, $t1, 1       # próximo campo: índice 1

loop_parse:
    lb   $t2, 0($t0)
    beq  $t2, $zero, fim_parse    # fim de string
    li   $t3, '-'
    beq  $t2, $t3, parse_separador
    addi $t0, $t0, 1
    j    loop_parse

parse_separador:
    sb   $zero, 0($t0)     # termina token anterior com \0
    addi $t0, $t0, 1       # avança para início do próximo token
    bgt  $t1, 3, loop_parse  # ignora separadores além do 3º arg
    mul  $t5, $t1, 4
    add  $t5, $t5, $t4
    sw   $t0, 0($t5)       # resultado[t1] = ptr do novo token
    addi $t1, $t1, 1
    j    loop_parse

fim_parse:
    jr $ra

# ====================================================================================
# SWITCH DE COMANDOS
# Entrada : $a1 = ptr struct resultado
# ====================================================================================
switch_comandos:
    addi $sp, $sp, -8
    sw   $ra, 0($sp)
    sw   $a1, 4($sp)       # salva ptr da struct para recuperar em cada exec_*

    # Macro de comparação: sempre recarrega cmd da struct antes de cada strcmp
    # para não depender de $a0 após jal (caller-saved)

    lw   $t9, 4($sp)       # ptr struct resultado
    lw   $a0, 0($t9)       # resultado[0] = ptr do comando

    la   $a1, str_cardapio_ad
    jal  strcmp
    beq  $v0, $zero, exec_cardapio_ad

    lw   $t9, 4($sp)
    lw   $a0, 0($t9)
    la   $a1, str_cardapio_rm
    jal  strcmp
    beq  $v0, $zero, exec_cardapio_rm

    lw   $t9, 4($sp)
    lw   $a0, 0($t9)
    la   $a1, str_cardapio_list
    jal  strcmp
    beq  $v0, $zero, exec_cardapio_list

    lw   $t9, 4($sp)
    lw   $a0, 0($t9)
    la   $a1, str_cardapio_format
    jal  strcmp
    beq  $v0, $zero, exec_cardapio_format

    lw   $t9, 4($sp)
    lw   $a0, 0($t9)
    la   $a1, str_mesa_iniciar
    jal  strcmp
    beq  $v0, $zero, exec_mesa_iniciar

    lw   $t9, 4($sp)
    lw   $a0, 0($t9)
    la   $a1, str_mesa_ad_item
    jal  strcmp
    beq  $v0, $zero, exec_mesa_ad_item

    lw   $t9, 4($sp)
    lw   $a0, 0($t9)
    la   $a1, str_mesa_rm_item
    jal  strcmp
    beq  $v0, $zero, exec_mesa_rm_item

    lw   $t9, 4($sp)
    lw   $a0, 0($t9)
    la   $a1, str_mesa_format
    jal  strcmp
    beq  $v0, $zero, exec_mesa_format

    lw   $t9, 4($sp)
    lw   $a0, 0($t9)
    jal  strcmp

    lw   $t9, 4($sp)
    lw   $a0, 0($t9)
    jal  strcmp

    lw   $t9, 4($sp)
    lw   $a0, 0($t9)
    jal  strcmp

    lw   $t9, 4($sp)
    lw   $a0, 0($t9)
    jal  strcmp

    lw   $t9, 4($sp)
    lw   $a0, 0($t9)
    jal  strcmp

    lw   $t9, 4($sp)
    lw   $a0, 0($t9)
    jal  strcmp

    # Nenhum comando reconhecido
    li   $v0, 4
    la   $a0, msg_cmd_invalido
    syscall
    j    fim_switch

exec_cardapio_ad:
    lw   $t9, 4($sp)
    lw   $a0, 4($t9)
    lw   $a1, 8($t9)
    lw   $a2, 12($t9)
    jal  cardapio_ad
    j    fim_switch

exec_cardapio_rm:
    lw   $t9, 4($sp)
    lw   $a0, 4($t9)
    jal  cardapio_rm
    j    fim_switch

exec_cardapio_list:
    jal  cardapio_list
    j    fim_switch

exec_cardapio_format:
    jal  cardapio_format
    j    fim_switch

exec_mesa_iniciar:
    lw   $t9, 4($sp)
    lw   $a0, 4($t9)
    lw   $a1, 8($t9)
    lw   $a2, 12($t9)
    jal  mesa_iniciar
    j    fim_switch

exec_mesa_ad_item:
    lw   $t9, 4($sp)
    lw   $a0, 4($t9)
    lw   $a1, 8($t9)
    jal  mesa_ad_item
    j    fim_switch

exec_mesa_rm_item:
    lw   $t9, 4($sp)
    lw   $a0, 4($t9)
    lw   $a1, 8($t9)
    jal  mesa_rm_item
    j    fim_switch

exec_mesa_format:
    jal  mesa_format
    j    fim_switch







fim_switch:
    lw   $ra, 0($sp)
    addi $sp, $sp, 8
    jr   $ra

# ====================================================================================
# CARDAPIO_AD — adiciona item ao cardápio
# Entrada : $a0=ptr_cod, $a1=ptr_preco, $a2=ptr_desc
# ====================================================================================
cardapio_ad:
    addi $sp, $sp, -20
    sw   $ra,  0($sp)
    sw   $s0,  4($sp)    # ptr string código
    sw   $s1,  8($sp)    # ptr string preço
    sw   $s2, 12($sp)    # ptr string descrição
    sw   $s3, 16($sp)    # código inteiro

    move $s0, $a0
    move $s1, $a1
    move $s2, $a2

    move $a0, $s0
    jal  string_to_int
    move $s3, $v0

    blt  $s3, 1,  cad_err_cod
    bgt  $s3, 20, cad_err_cod

    # endereço do slot = cardapio + (cod-1) × ITEM_SIZE
    addi $t0, $s3, -1
    li   $t1, ITEM_SIZE
    mul  $t0, $t0, $t1
    la   $t2, cardapio
    add  $t2, $t2, $t0

    # slot já ocupado?
    lw   $t3, CODIGO_OFFSET($t2)
    bne  $t3, $zero, cad_err_ja

    # converte preço
    move $a0, $s1
    jal  string_to_int
    move $t4, $v0

    # grava código e preço
    sw   $s3, CODIGO_OFFSET($t2)
    sw   $t4, PRECO_OFFSET($t2)

    # copia descrição com limite
    addi $a0, $t2, DESC_OFFSET
    move $a1, $s2
    li   $a2, DESC_SIZE
    jal  strncopy

    li   $v0, 4
    la   $a0, msg_item_adicionado
    syscall
    j    cad_fim

cad_err_cod:
    li   $v0, 4
    la   $a0, msg_err_cod_invalido
    syscall
    j    cad_fim

cad_err_ja:
    li   $v0, 4
    la   $a0, msg_err_ja_cadastrado
    syscall

cad_fim:
    lw   $s3, 16($sp)
    lw   $s2, 12($sp)
    lw   $s1,  8($sp)
    lw   $s0,  4($sp)
    lw   $ra,  0($sp)
    addi $sp, $sp, 20
    jr   $ra

# ====================================================================================
# CARDAPIO_RM — remove item do cardápio
# Entrada : $a0 = ptr string com código do item
# ====================================================================================
cardapio_rm:
    addi $sp, $sp, -8
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)

    jal  string_to_int
    move $s0, $v0

    blt  $s0, 1,  crm_err_cod
    bgt  $s0, 20, crm_err_cod

    addi $t0, $s0, -1
    li   $t1, ITEM_SIZE
    mul  $t0, $t0, $t1
    la   $t2, cardapio
    add  $t2, $t2, $t0

    # slot vazio?
    lw   $t3, CODIGO_OFFSET($t2)
    beq  $t3, $zero, crm_err_vazio

    # zera o slot inteiro (48 bytes = 12 words)
    li   $t3, 12           # 12 words = 48 bytes
crm_zero:
    beq  $t3, $zero, crm_ok
    sw   $zero, 0($t2)
    addi $t2, $t2, 4
    addi $t3, $t3, -1
    j    crm_zero

crm_ok:
    li   $v0, 4
    la   $a0, msg_item_removido
    syscall
    j    crm_fim

crm_err_cod:
    li   $v0, 4
    la   $a0, msg_err_cod_invalido
    syscall
    j    crm_fim

crm_err_vazio:
    li   $v0, 4
    la   $a0, msg_err_sem_cadastro
    syscall

crm_fim:
    lw   $s0, 4($sp)
    lw   $ra, 0($sp)
    addi $sp, $sp, 8
    jr   $ra

# ====================================================================================
# CARDAPIO_LIST — lista todos os itens cadastrados em ordem crescente de código
# $s0=cursor e $s1=contador protegidos entre iteracoes do loop
# ====================================================================================
cardapio_list:
    addi $sp, $sp, -12
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)     # cursor no array (sobrevive a jals)
    sw   $s1, 8($sp)     # contador de slots restantes

    la   $s0, cardapio
    li   $s1, MAX_ITENS

    # verifica se há algum item antes de listar
    move $t0, $s0
    li   $t1, MAX_ITENS
    li   $t2, 0          # contador de itens encontrados
cl_conta:
    beq  $t1, $zero, cl_conta_fim
    lw   $t3, CODIGO_OFFSET($t0)
    beq  $t3, $zero, cl_conta_prox
    addi $t2, $t2, 1
cl_conta_prox:
    addi $t0, $t0, ITEM_SIZE
    addi $t1, $t1, -1
    j    cl_conta
cl_conta_fim:
    beq  $t2, $zero, cl_vazio

cl_loop:
    beq  $s1, $zero, cl_fim
    lw   $t0, CODIGO_OFFSET($s0)
    beq  $t0, $zero, cl_prox    # slot vazio, pula

    # imprime código
    li   $v0, 1
    move $a0, $t0
    syscall
    li   $v0, 4
    la   $a0, msg_virgula
    syscall

    # imprime preco em centavos (inteiro)
    lw   $a0, PRECO_OFFSET($s0)
    li   $v0, 1
    syscall

    li   $v0, 4
    la   $a0, msg_virgula
    syscall

    # imprime descrição — $s0 ainda válido
    li   $v0, 4
    addi $a0, $s0, DESC_OFFSET
    syscall

    li   $v0, 4
    la   $a0, msg_newline
    syscall

cl_prox:
    addi $s0, $s0, ITEM_SIZE
    addi $s1, $s1, -1
    j    cl_loop

cl_vazio:
    li   $v0, 4
    la   $a0, msg_cardapio_vazio
    syscall

cl_fim:
    lw   $s1, 8($sp)
    lw   $s0, 4($sp)
    lw   $ra, 0($sp)
    addi $sp, $sp, 12
    jr   $ra

# ====================================================================================
# CARDAPIO_FORMAT — apaga todos os itens do cardápio
# ====================================================================================
cardapio_format:
    la   $t0, cardapio
    li   $t1, 960          # 960 bytes = 20 × 48
cf_loop:
    beq  $t1, $zero, cf_fim
    sw   $zero, 0($t0)
    addi $t0, $t0, 4
    addi $t1, $t1, -4
    j    cf_loop
cf_fim:
    jr   $ra

# ====================================================================================
# MESA_INICIAR — inicia atendimento em mesa desocupada
# Entrada : $a0=ptr_id, $a1=ptr_tel, $a2=ptr_nome
# FIX: $s4 salva endereço da mesa para sobreviver a jals de strcopy
#      Frame expandido para -24 (6 regs × 4 bytes)
#      strncopy usado em vez de strcopy (sem limite)
# ====================================================================================
mesa_iniciar:
    addi $sp, $sp, -24        # FIX: era -20, agora -24 para $s4
    sw   $ra,  0($sp)
    sw   $s0,  4($sp)         # ptr string ID
    sw   $s1,  8($sp)         # ptr string telefone
    sw   $s2, 12($sp)         # ptr string nome
    sw   $s3, 16($sp)         # ID inteiro
    sw   $s4, 20($sp)         # FIX: endereço da mesa (sobrevive a jals)

    move $s0, $a0
    move $s1, $a1
    move $s2, $a2

    move $a0, $s0
    jal  string_to_int
    move $s3, $v0

    blt  $s3, 1,  mi_err_inexistente
    bgt  $s3, 15, mi_err_inexistente

    # endereço da mesa
    addi $t0, $s3, -1
    li   $t1, MESA_SIZE
    mul  $t0, $t0, $t1
    la   $t2, mesas
    add  $t2, $t2, $t0
    move $s4, $t2             # FIX: $s4 preserva o endereço durante os jals

    # mesa já ocupada?
    lb   $t3, M_STATUS($s4)
    li   $t4, 1
    beq  $t3, $t4, mi_err_ocupada

    # status = ocupada
    li   $t3, 1
    sb   $t3, M_STATUS($s4)

    # FIX: strncopy com limite (evita buffer overflow)
    addi $a0, $s4, M_TEL
    move $a1, $s1
    li   $a2, TEL_SIZE
    jal  strncopy              # $s4 sobrevive pois é $s-reg

    addi $a0, $s4, M_NOME
    move $a1, $s2
    li   $a2, NOME_SIZE
    jal  strncopy              # $s4 ainda intacto

    # FIX: zerar pedidos usando $s4 (não $t2 que foi destruído pelos jals)
    addi $t5, $s4, M_PEDIDOS
    li   $t6, MAX_PEDIDOS
mi_zero_loop:
    beq  $t6, $zero, mi_zero_fim
    sw   $zero, 0($t5)         # P_COD = 0
    sw   $zero, 4($t5)         # P_QTD = 0
    addi $t5, $t5, PEDIDO_SIZE
    addi $t6, $t6, -1
    j    mi_zero_loop
mi_zero_fim:

    # zera saldo pago
    sw   $zero, M_PAGO($s4)

    li   $v0, 4
    la   $a0, msg_mesa_ok
    syscall
    j    mi_fim

mi_err_inexistente:
    li   $v0, 4
    la   $a0, msg_mesa_inexistente
    syscall
    j    mi_fim

mi_err_ocupada:
    li   $v0, 4
    la   $a0, msg_mesa_ocupada
    syscall

mi_fim:
    lw   $s4, 20($sp)
    lw   $s3, 16($sp)
    lw   $s2, 12($sp)
    lw   $s1,  8($sp)
    lw   $s0,  4($sp)
    lw   $ra,  0($sp)
    addi $sp, $sp, 24
    jr   $ra

# ====================================================================================
# MESA_AD_ITEM — adiciona item do cardápio na conta da mesa
# Entrada : $a0=ptr_id_mesa, $a1=ptr_cod_item
# ====================================================================================
mesa_ad_item:
    addi $sp, $sp, -24
    sw   $ra,  0($sp)
    sw   $s0,  4($sp)    # ID mesa inteiro
    sw   $s1,  8($sp)    # código item inteiro
    sw   $s2, 12($sp)    # endereço da mesa
    sw   $s3, 16($sp)    # endereço do slot de pedido
    sw   $s4, 20($sp)    # (livre para uso futuro)

    jal  string_to_int
    move $s0, $v0

    blt  $s0, 1,  mai_err_inexistente
    bgt  $s0, 15, mai_err_inexistente

    # endereço da mesa
    addi $t0, $s0, -1
    li   $t1, MESA_SIZE
    mul  $t0, $t0, $t1
    la   $t2, mesas
    add  $t2, $t2, $t0
    move $s2, $t2

    lb   $t3, M_STATUS($s2)
    beq  $t3, $zero, mai_err_nao_iniciou

    # converte código do item
    move $a0, $a1             # $a1 ainda tem ptr_cod_item
    jal  string_to_int
    move $s1, $v0

    blt  $s1, 1,  mai_err_cod_item
    bgt  $s1, 20, mai_err_cod_item

    # verifica se item existe no cardápio
    addi $t0, $s1, -1
    li   $t1, ITEM_SIZE
    mul  $t0, $t0, $t1
    la   $t2, cardapio
    add  $t2, $t2, $t0
    lw   $t3, CODIGO_OFFSET($t2)
    beq  $t3, $zero, mai_err_nao_cardapio

    # busca slot do pedido na mesa
    addi $t5, $s2, M_PEDIDOS
    li   $t6, MAX_PEDIDOS
mai_busca:
    beq  $t6, $zero, mai_novo_slot  # não encontrou → slot novo
    lw   $t7, P_COD($t5)
    beq  $t7, $s1, mai_incrementa   # já existe → incrementa
    beq  $t7, $zero, mai_novo_slot  # slot vazio → usa este
    addi $t5, $t5, PEDIDO_SIZE
    addi $t6, $t6, -1
    j    mai_busca

mai_incrementa:
    lw   $t8, P_QTD($t5)
    addi $t8, $t8, 1
    sw   $t8, P_QTD($t5)
    j    mai_ok

mai_novo_slot:
    # $t5 aponta para o primeiro slot vazio encontrado
    sw   $s1, P_COD($t5)
    li   $t8, 1
    sw   $t8, P_QTD($t5)

mai_ok:
    li   $v0, 4
    la   $a0, msg_item_adicionado
    syscall
    j    mai_fim

mai_err_inexistente:
    li   $v0, 4
    la   $a0, msg_mesa_inexistente
    syscall
    j    mai_fim

mai_err_nao_iniciou:
    li   $v0, 4
    la   $a0, msg_mesa_nao_iniciou
    syscall
    j    mai_fim

mai_err_cod_item:
    li   $v0, 4
    la   $a0, msg_err_cod_invalido
    syscall
    j    mai_fim

mai_err_nao_cardapio:
    li   $v0, 4
    la   $a0, msg_item_nao_cardapio
    syscall

mai_fim:
    lw   $s4, 20($sp)
    lw   $s3, 16($sp)
    lw   $s2, 12($sp)
    lw   $s1,  8($sp)
    lw   $s0,  4($sp)
    lw   $ra,  0($sp)
    addi $sp, $sp, 24
    jr   $ra

# ====================================================================================
# MESA_RM_ITEM — remove item da conta da mesa
# Entrada : $a0=ptr_id_mesa, $a1=ptr_cod_item
# ====================================================================================
mesa_rm_item:
    addi $sp, $sp, -20
    sw   $ra,  0($sp)
    sw   $s0,  4($sp)    # ID mesa
    sw   $s1,  8($sp)    # código item
    sw   $s2, 12($sp)    # endereço mesa
    sw   $s3, 16($sp)

    jal  string_to_int
    move $s0, $v0

    blt  $s0, 1,  mri_err_inexistente
    bgt  $s0, 15, mri_err_inexistente

    addi $t0, $s0, -1
    li   $t1, MESA_SIZE
    mul  $t0, $t0, $t1
    la   $t2, mesas
    add  $t2, $t2, $t0
    move $s2, $t2

    lb   $t3, M_STATUS($s2)
    beq  $t3, $zero, mri_err_nao_iniciou

    move $a0, $a1
    jal  string_to_int
    move $s1, $v0

    blt  $s1, 1,  mri_err_cod
    bgt  $s1, 20, mri_err_cod

    # busca o item nos pedidos
    addi $t5, $s2, M_PEDIDOS
    li   $t6, MAX_PEDIDOS
mri_busca:
    beq  $t6, $zero, mri_err_nao_conta
    lw   $t7, P_COD($t5)
    beq  $t7, $s1, mri_achou
    addi $t5, $t5, PEDIDO_SIZE
    addi $t6, $t6, -1
    j    mri_busca

mri_achou:
    lw   $t8, P_QTD($t5)
    addi $t8, $t8, -1
    bgt  $t8, $zero, mri_atualiza  # ainda tem unidades
    # quantidade chegou a 0 → zera o slot
    sw   $zero, P_COD($t5)
    sw   $zero, P_QTD($t5)
    j    mri_ok

mri_atualiza:
    sw   $t8, P_QTD($t5)

mri_ok:
    li   $v0, 4
    la   $a0, msg_item_removido
    syscall
    j    mri_fim

mri_err_inexistente:
    li   $v0, 4
    la   $a0, msg_mesa_inexistente
    syscall
    j    mri_fim

mri_err_nao_iniciou:
    li   $v0, 4
    la   $a0, msg_mesa_nao_iniciou
    syscall
    j    mri_fim

mri_err_cod:
    li   $v0, 4
    la   $a0, msg_err_cod_invalido
    syscall
    j    mri_fim

mri_err_nao_conta:
    li   $v0, 4
    la   $a0, msg_item_nao_conta
    syscall

mri_fim:
    lw   $s3, 16($sp)
    lw   $s2, 12($sp)
    lw   $s1,  8($sp)
    lw   $s0,  4($sp)
    lw   $ra,  0($sp)
    addi $sp, $sp, 20
    jr   $ra

# ====================================================================================
# MESA_FORMAT — coloca todas as mesas como desocupadas e zera registros
# ====================================================================================
mesa_format:
    la   $t0, mesas
    li   $t1, 3180         # 15 × 212 bytes
mf_loop:
    beq  $t1, $zero, mf_fim
    sw   $zero, 0($t0)
    addi $t0, $t0, 4
    addi $t1, $t1, -4
    j    mf_loop
mf_fim:
    jr   $ra

# ====================================================================================
# MESA_PARCIAL — relatório de consumo da mesa
# Entrada : $a0 = ptr string com código da mesa
# FIX: $s3=cursor pedidos, $s4=contador, $s5=total_pago — protegidos contra jals
# ====================================================================================
# ====================================================================================
# MESA_PAGAR — pagamento parcial
# Entrada : $a0=ptr_id_mesa, $a1=ptr_valor_centavos
# ====================================================================================
# ====================================================================================
# MESA_FECHAR — fecha a mesa se saldo devedor = 0
# Entrada : $a0 = ptr string com código da mesa
# FIX: limite corrigido para 15 (era 10 — typo do enunciado)
# ====================================================================================
# ====================================================================================
# SALVAR — grava cardapio e mesas em arquivo binário
# ====================================================================================
# ====================================================================================
# RECARREGAR — lê arquivo e restaura cardapio e mesas
# ====================================================================================
# ====================================================================================
# FORMATAR — apaga todos os dados em memória (não salva no arquivo)
# ====================================================================================


# --- UTILITÁRIOS ---

# --- strcmp ---
# Entrada : $a0=ptr_s1, $a1=ptr_s2
# Saída   : $v0=0 se iguais, !=0 se diferentes
strcmp:
    lb $t0, 0($a0)
    lb $t1, 0($a1)
    bne $t0, $t1, strcmp_diff
    beq $t0, $zero, strcmp_equal
    addi $a0, $a0, 1
    addi $a1, $a1, 1
    j strcmp
strcmp_diff:
    sub $v0, $t0, $t1
    jr  $ra
strcmp_equal:
    li  $v0, 0
    jr  $ra

# --- string_to_int ---
# Entrada : $a0 = ptr string numérica
# Saída   : $v0 = inteiro convertido
string_to_int:
    li $v0, 0
s2i_loop:
    lb $t0, 0($a0)
    blt $t0, 48, s2i_fim
    bgt $t0, 57, s2i_fim
    addi $t0, $t0, -48
    mul  $v0, $v0, 10
    add  $v0, $v0, $t0
    addi $a0, $a0, 1
    j s2i_loop
s2i_fim:
    jr $ra

# --- strcopy (sem limite — use apenas internamente quando tamanho garantido) ---
strcopy:
sc_loop:
    lb   $t0, 0($a1)
    sb   $t0, 0($a0)
    beq  $t0, $zero, sc_fim
    addi $a0, $a0, 1
    addi $a1, $a1, 1
    j    sc_loop
sc_fim:
    jr   $ra

# --- strncopy (com limite — preferida para entradas do usuário) ---
# Entrada : $a0=dest, $a1=src, $a2=limite (incluindo \0)
# Sempre termina com \0
strncopy:
    move $t2, $a2
snc_loop:
    beq  $t2, $zero, snc_termina
    lb   $t0, 0($a1)
    beq  $t0, $zero, snc_termina
    sb   $t0, 0($a0)
    addi $a0, $a0, 1
    addi $a1, $a1, 1
    addi $t2, $t2, -1
    j    snc_loop
snc_termina:
    sb   $zero, 0($a0)    # garante \0 final sempre
    jr   $ra
