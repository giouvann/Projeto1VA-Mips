######################################################################################
# GRUPO: David Fernando, Evelin Dionizio, Giovanna Costa, Miguel Monteiro
# ATIVIDADE: Projeto 01 - 1ª VA
# DISCIPLINA: Arquitetura e Organização de Computadores
# SEMESTRE: 2026.1
# QUESTÃO: Projeto Principal
# DESCRIÇÃO: Parser de comandos, switch de despacho, funções do sistema e utilitários
######################################################################################

# Inclui o segmento .data com todas as constantes, mensagens e estruturas de dados
.include "dados.asm"

# Diretiva que inicia o segmento de código (instruções executáveis)
.text

# FUNÇÃO: conversao_cmd
# Entrada : $a0 = ponteiro para a string de entrada digitada pelo usuário
#           $a1 = ponteiro para a struct resultado (array de 4 words)
# Efeito  : Percorre a string byte a byte; ao encontrar '-', substitui por \0
#           e registra o ponteiro do token seguinte em resultado[1], [2] ou [3].
#           resultado[0] recebe o ponteiro para o início da string (o comando).
# Não usa pilha pois não chama outras funções (leaf function).
conversao_cmd:
    move $t0, $a0          # $t0 = cursor que percorre a string caractere a caractere
    move $t4, $a1          # $t4 = endereço base da struct resultado

    li   $t1, 0            # $t1 = índice do próximo campo a preencher (começa em 0)

    sw   $t0, 0($t4)       # resultado[0] = ponteiro para o início da string (o comando)
    addi $t1, $t1, 1       # avança índice: próximo campo a preencher é resultado[1]

loop_parse:
    lb   $t2, 0($t0)               # lê o byte atual apontado pelo cursor
    beq  $t2, $zero, fim_parse     # se for \0 (fim de string), encerra o parsing
    li   $t3, '-'                  # carrega o código ASCII do caractere '-' (45)
    beq  $t2, $t3, parse_separador # se o byte atual é '-', trata como separador
    addi $t0, $t0, 1               # byte comum: avança o cursor para o próximo byte
    j    loop_parse                # volta ao início do loop

parse_separador:
    sb   $zero, 0($t0)     # substitui o '-' por \0, encerrando o token anterior
    addi $t0, $t0, 1       # avança o cursor para o primeiro byte do próximo token
    bgt  $t1, 3, loop_parse  # se já preenchemos 4 campos (0-3), ignora separadores extras
    mul  $t5, $t1, 4       # calcula offset em bytes: índice × 4 (cada ponteiro tem 4 bytes)
    add  $t5, $t5, $t4     # soma o offset ao endereço base da struct resultado
    sw   $t0, 0($t5)       # grava o ponteiro do novo token em resultado[t1]
    addi $t1, $t1, 1       # incrementa o índice para o próximo campo
    j    loop_parse        # volta ao loop principal

fim_parse:
    jr $ra                 # retorna ao chamador (endereço salvo em $ra)

# FUNÇÃO: switch_comandos
# Entrada : $a1 = ponteiro para a struct resultado (preenchida por conversao_cmd)
# Efeito  : Compara resultado[0] (o comando digitado) com cada string conhecida.
#           Ao encontrar correspondência, desvia para o bloco exec_* correto.
#           Se nenhum comando for reconhecido, imprime "Comando invalido".
# Convenção: $ra e $a1 são salvos na pilha pois esta função faz chamadas jal (strcmp).
switch_comandos:
    addi $sp, $sp, -8      # abre espaço na pilha para 2 words (8 bytes)
    sw   $ra, 0($sp)       # salva o endereço de retorno (será sobrescrito pelos jals)
    sw   $a1, 4($sp)       # salva o ponteiro da struct resultado para uso posterior

    # Padrão repetido para cada comando:
    # 1) recarrega o ponteiro da struct resultado da pilha (jal pode ter destruído $a1)
    # 2) lê resultado[0] (ponteiro do comando digitado)
    # 3) carrega o endereço da string esperada
    # 4) chama strcmp; se retornar 0 (iguais), desvia para o bloco de execução

    lw   $t9, 4($sp)           # recupera ponteiro da struct resultado da pilha
    lw   $a0, 0($t9)           # $a0 = resultado[0] = ponteiro do comando digitado
    la   $a1, str_cardapio_ad  # $a1 = ponteiro da string "cardapio_ad"
    jal  strcmp                # compara as duas strings; resultado em $v0
    beq  $v0, $zero, exec_cardapio_ad  # se $v0==0, strings iguais → executa

    lw   $t9, 4($sp)           # recarrega struct (jal strcmp pode ter alterado $t9)
    lw   $a0, 0($t9)           # $a0 = ponteiro do comando digitado
    la   $a1, str_cardapio_rm  # $a1 = "cardapio_rm"
    jal  strcmp
    beq  $v0, $zero, exec_cardapio_rm

    lw   $t9, 4($sp)
    lw   $a0, 0($t9)
    la   $a1, str_cardapio_list  # $a1 = "cardapio_list"
    jal  strcmp
    beq  $v0, $zero, exec_cardapio_list

    lw   $t9, 4($sp)
    lw   $a0, 0($t9)
    la   $a1, str_cardapio_format  # $a1 = "cardapio_format"
    jal  strcmp
    beq  $v0, $zero, exec_cardapio_format

    lw   $t9, 4($sp)
    lw   $a0, 0($t9)
    la   $a1, str_mesa_iniciar  # $a1 = "mesa_iniciar"
    jal  strcmp
    beq  $v0, $zero, exec_mesa_iniciar

    lw   $t9, 4($sp)
    lw   $a0, 0($t9)
    la   $a1, str_mesa_ad_item  # $a1 = "mesa_ad_item"
    jal  strcmp
    beq  $v0, $zero, exec_mesa_ad_item

    lw   $t9, 4($sp)
    lw   $a0, 0($t9)
    la   $a1, str_mesa_rm_item  # $a1 = "mesa_rm_item"
    jal  strcmp
    beq  $v0, $zero, exec_mesa_rm_item

    lw   $t9, 4($sp)
    lw   $a0, 0($t9)
    la   $a1, str_mesa_format  # $a1 = "mesa_format"
    jal  strcmp
    beq  $v0, $zero, exec_mesa_format

    lw   $t9, 4($sp)
    lw   $a0, 0($t9)
    la   $a1, str_mesa_parcial  # $a1 = "mesa_parcial"
    jal  strcmp
    beq  $v0, $zero, exec_mesa_parcial

    lw   $t9, 4($sp)
    lw   $a0, 0($t9)
    la   $a1, str_mesa_pagar  # $a1 = "mesa_pagar"
    jal  strcmp
    beq  $v0, $zero, exec_mesa_pagar

    lw   $t9, 4($sp)
    lw   $a0, 0($t9)
    la   $a1, str_mesa_fechar  # $a1 = "mesa_fechar"
    jal  strcmp
    beq  $v0, $zero, exec_mesa_fechar

    lw   $t9, 4($sp)
    lw   $a0, 0($t9)
    la   $a1, str_salvar  # $a1 = "salvar"
    jal  strcmp
    beq  $v0, $zero, exec_salvar

    lw   $t9, 4($sp)
    lw   $a0, 0($t9)
    la   $a1, str_recarregar  # $a1 = "recarregar"
    jal  strcmp
    beq  $v0, $zero, exec_recarregar

    lw   $t9, 4($sp)
    lw   $a0, 0($t9)
    la   $a1, str_formatar  # $a1 = "formatar"
    jal  strcmp
    beq  $v0, $zero, exec_formatar

    # Chegou aqui: nenhuma string casou com o comando digitado
    li   $v0, 4                # syscall 4 = print_string
    la   $a0, msg_cmd_invalido # mensagem de comando inválido
    syscall
    j    fim_switch            # vai para o epílogo

# --- Blocos de execução ---
# Cada bloco carrega os argumentos da struct resultado e chama a função correspondente.

exec_cardapio_ad:
    lw   $t9, 4($sp)       # recupera ponteiro da struct resultado
    lw   $a0, 4($t9)       # resultado[1] = ponteiro do código do item (arg1)
    lw   $a1, 8($t9)       # resultado[2] = ponteiro do preço (arg2)
    lw   $a2, 12($t9)      # resultado[3] = ponteiro da descrição (arg3)
    jal  cardapio_ad       # chama a função de adição ao cardápio
    j    fim_switch

exec_cardapio_rm:
    lw   $t9, 4($sp)
    lw   $a0, 4($t9)       # resultado[1] = ponteiro do código a remover
    jal  cardapio_rm
    j    fim_switch

exec_cardapio_list:
    jal  cardapio_list     # sem argumentos: lista todos os itens cadastrados
    j    fim_switch

exec_cardapio_format:
    jal  cardapio_format   # sem argumentos: apaga todos os itens do cardápio
    j    fim_switch

exec_mesa_iniciar:
    lw   $t9, 4($sp)
    lw   $a0, 4($t9)       # resultado[1] = ponteiro do código da mesa
    lw   $a1, 8($t9)       # resultado[2] = ponteiro do telefone
    lw   $a2, 12($t9)      # resultado[3] = ponteiro do nome do responsável
    jal  mesa_iniciar
    j    fim_switch

exec_mesa_ad_item:
    lw   $t9, 4($sp)
    lw   $a0, 4($t9)       # resultado[1] = ponteiro do código da mesa
    lw   $a1, 8($t9)       # resultado[2] = ponteiro do código do item
    jal  mesa_ad_item
    j    fim_switch

exec_mesa_rm_item:
    lw   $t9, 4($sp)
    lw   $a0, 4($t9)       # resultado[1] = ponteiro do código da mesa
    lw   $a1, 8($t9)       # resultado[2] = ponteiro do código do item a remover
    jal  mesa_rm_item
    j    fim_switch

exec_mesa_format:
    jal  mesa_format       # sem argumentos: zera todas as mesas
    j    fim_switch

exec_mesa_parcial:
    lw   $t9, 4($sp)
    lw   $a0, 4($t9)       # resultado[1] = ponteiro do código da mesa
    jal  mesa_parcial
    j    fim_switch

exec_mesa_pagar:
    lw   $t9, 4($sp)
    lw   $a0, 4($t9)       # resultado[1] = ponteiro do código da mesa
    lw   $a1, 8($t9)       # resultado[2] = ponteiro do valor a pagar (em centavos)
    jal  mesa_pagar
    j    fim_switch

exec_mesa_fechar:
    lw   $t9, 4($sp)
    lw   $a0, 4($t9)       # resultado[1] = ponteiro do código da mesa
    jal  mesa_fechar
    j    fim_switch

exec_salvar:
    jal  salvar            # sem argumentos: grava cardápio e mesas no arquivo
    j    fim_switch

exec_recarregar:
    jal  recarregar        # sem argumentos: restaura dados a partir do arquivo
    j    fim_switch

exec_formatar:
    jal  formatar          # sem argumentos: apaga todos os dados em memória
    j    fim_switch

fim_switch:
    lw   $ra, 0($sp)       # restaura o endereço de retorno salvo no prólogo
    addi $sp, $sp, 8       # libera os 8 bytes reservados na pilha
    jr   $ra               # retorna ao chamador

# FUNÇÃO: cardapio_ad
# Entrada : $a0 = ponteiro para string do código (ex: "15")
#           $a1 = ponteiro para string do preço em centavos (ex: "00490")
#           $a2 = ponteiro para string da descrição (ex: "coca cola")
# Efeito  : Converte código e preço para inteiro, valida intervalo (1-20),
#           verifica se o slot está livre, e grava os dados no cardápio.
cardapio_ad:
    addi $sp, $sp, -20     # abre frame de 20 bytes (5 registradores × 4 bytes)
    sw   $ra,  0($sp)      # salva endereço de retorno (função faz chamadas jal)
    sw   $s0,  4($sp)      # preserva $s0 (será usado para armazenar ptr do código)
    sw   $s1,  8($sp)      # preserva $s1 (será usado para armazenar ptr do preço)
    sw   $s2, 12($sp)      # preserva $s2 (será usado para armazenar ptr da descrição)
    sw   $s3, 16($sp)      # preserva $s3 (será usado para armazenar o código como inteiro)

    move $s0, $a0          # $s0 = ponteiro para string do código (salvo antes de qualquer jal)
    move $s1, $a1          # $s1 = ponteiro para string do preço
    move $s2, $a2          # $s2 = ponteiro para string da descrição

    move $a0, $s0          # passa o ptr do código como argumento para string_to_int
    jal  string_to_int     # converte string numérica para inteiro; resultado em $v0
    move $s3, $v0          # $s3 = código do item como inteiro

    blt  $s3, 1,  cad_err_cod   # se código < 1, é inválido
    bgt  $s3, 20, cad_err_cod   # se código > 20, é inválido

    # Calcula o endereço do slot no array cardapio:
    # endereço = base_cardapio + (código - 1) × ITEM_SIZE
    addi $t0, $s3, -1     # índice base-0: código 1 → índice 0, código 20 → índice 19
    li   $t1, ITEM_SIZE   # carrega o tamanho de cada slot (48 bytes)
    mul  $t0, $t0, $t1    # calcula o deslocamento em bytes
    la   $t2, cardapio    # carrega o endereço base do array cardápio
    add  $t2, $t2, $t0    # $t2 = endereço do slot correspondente ao código

    lw   $t3, CODIGO_OFFSET($t2)  # lê o campo código do slot
    bne  $t3, $zero, cad_err_ja   # se diferente de 0, slot já está ocupado

    move $a0, $s1          # passa o ptr do preço como argumento para string_to_int
    jal  string_to_int     # converte string do preço para inteiro; resultado em $v0
    move $t4, $v0          # $t4 = preço em centavos

    # Grava os dados do item no slot (o endereço $t2 sobreviveu pois não houve jal entre)
    sw   $s3, CODIGO_OFFSET($t2)  # grava o código inteiro no campo código do slot
    sw   $t4, PRECO_OFFSET($t2)   # grava o preço em centavos no campo preço do slot

    # Copia a descrição para o campo desc do slot, com limite de DESC_SIZE bytes
    addi $a0, $t2, DESC_OFFSET    # $a0 = endereço de destino (campo desc no slot)
    move $a1, $s2                 # $a1 = endereço de origem (string da descrição)
    li   $a2, DESC_SIZE           # $a2 = limite máximo de bytes a copiar (40)
    jal  strncopy                 # copia com garantia de terminador \0

    li   $v0, 4                    # syscall 4 = print_string
    la   $a0, msg_item_adicionado  # mensagem de sucesso
    syscall
    j    cad_fim

cad_err_cod:
    li   $v0, 4
    la   $a0, msg_err_cod_invalido  # código fora do intervalo 01-20
    syscall
    j    cad_fim

cad_err_ja:
    li   $v0, 4
    la   $a0, msg_err_ja_cadastrado  # slot já possui item registrado
    syscall

cad_fim:
    lw   $s3, 16($sp)      # restaura $s3
    lw   $s2, 12($sp)      # restaura $s2
    lw   $s1,  8($sp)      # restaura $s1
    lw   $s0,  4($sp)      # restaura $s0
    lw   $ra,  0($sp)      # restaura endereço de retorno
    addi $sp, $sp, 20      # libera o frame da pilha
    jr   $ra               # retorna ao chamador

# FUNÇÃO: cardapio_rm
# Entrada : $a0 = ponteiro para string do código do item a remover
# Efeito  : Converte o código, valida intervalo, verifica se slot está ocupado,
#           e zera os 48 bytes do slot (código, preço e descrição).
cardapio_rm:
    addi $sp, $sp, -8      # abre frame de 8 bytes
    sw   $ra, 0($sp)       # salva endereço de retorno
    sw   $s0, 4($sp)       # preserva $s0 (armazenará o código como inteiro)

    jal  string_to_int     # converte string do código para inteiro; $a0 já está correto
    move $s0, $v0          # $s0 = código do item como inteiro

    blt  $s0, 1,  crm_err_cod   # código < 1: inválido
    bgt  $s0, 20, crm_err_cod   # código > 20: inválido

    # Calcula endereço do slot: base + (código-1) × ITEM_SIZE
    addi $t0, $s0, -1     # índice base-0
    li   $t1, ITEM_SIZE   # 48 bytes por slot
    mul  $t0, $t0, $t1    # deslocamento em bytes
    la   $t2, cardapio    # endereço base do cardápio
    add  $t2, $t2, $t0    # $t2 = endereço do slot

    lw   $t3, CODIGO_OFFSET($t2)   # lê o campo código do slot
    beq  $t3, $zero, crm_err_vazio  # se for 0, slot está vazio (nada a remover)

    # Zera o slot inteiro: 48 bytes = 12 words de 4 bytes
    li   $t3, 12           # contador: 12 iterações para apagar 12 words
crm_zero:
    beq  $t3, $zero, crm_ok  # se contador chegou a 0, encerra o loop
    sw   $zero, 0($t2)        # escreve word 0 no endereço atual do slot
    addi $t2, $t2, 4          # avança o ponteiro para o próximo word
    addi $t3, $t3, -1         # decrementa o contador
    j    crm_zero             # repete

crm_ok:
    li   $v0, 4
    la   $a0, msg_item_removido  # confirma remoção com sucesso
    syscall
    j    crm_fim

crm_err_cod:
    li   $v0, 4
    la   $a0, msg_err_cod_invalido  # código fora do intervalo
    syscall
    j    crm_fim

crm_err_vazio:
    li   $v0, 4
    la   $a0, msg_err_sem_cadastro  # slot não tinha nenhum item cadastrado
    syscall

crm_fim:
    lw   $s0, 4($sp)       # restaura $s0
    lw   $ra, 0($sp)       # restaura endereço de retorno
    addi $sp, $sp, 8       # libera o frame
    jr   $ra

# FUNÇÃO: cardapio_list
# Efeito  : Percorre os 20 slots do cardápio em ordem crescente de índice.
#           Para cada slot ocupado, imprime código, preço e descrição.
#           Se nenhum slot estiver ocupado, exibe mensagem de cardápio vazio.
# Nota    : $s0 e $s1 guardam o cursor e o contador para sobreviver às chamadas jal.
cardapio_list:
    addi $sp, $sp, -12     # abre frame de 12 bytes (3 registradores × 4)
    sw   $ra, 0($sp)       # salva endereço de retorno
    sw   $s0, 4($sp)       # preserva $s0 (cursor no array de itens)
    sw   $s1, 8($sp)       # preserva $s1 (contador de slots restantes)

    la   $s0, cardapio     # $s0 = endereço do primeiro slot do cardápio
    li   $s1, MAX_ITENS    # $s1 = 20 (quantidade total de slots a percorrer)

    # Primeiro passo: conta quantos slots estão ocupados para decidir se imprime cabeçalho
    move $t0, $s0          # $t0 = cópia do cursor para a contagem prévia
    li   $t1, MAX_ITENS    # $t1 = contador da contagem prévia
    li   $t2, 0            # $t2 = acumulador de slots ocupados encontrados
cl_conta:
    beq  $t1, $zero, cl_conta_fim  # se percorreu todos os slots, encerra contagem
    lw   $t3, CODIGO_OFFSET($t0)   # lê o campo código do slot atual
    beq  $t3, $zero, cl_conta_prox # código 0 = slot vazio, pula
    addi $t2, $t2, 1               # incrementa o contador de itens encontrados
cl_conta_prox:
    addi $t0, $t0, ITEM_SIZE       # avança o cursor para o próximo slot
    addi $t1, $t1, -1              # decrementa o contador
    j    cl_conta
cl_conta_fim:
    beq  $t2, $zero, cl_vazio      # se nenhum item foi encontrado, exibe "vazio"

cl_loop:
    beq  $s1, $zero, cl_fim        # se percorreu todos os 20 slots, encerra
    lw   $t0, CODIGO_OFFSET($s0)   # lê o campo código do slot atual
    beq  $t0, $zero, cl_prox       # código 0 = slot vazio, pula sem imprimir

    # Imprime o código do item (inteiro)
    li   $v0, 1            # syscall 1 = print_int
    move $a0, $t0          # $a0 = código do item
    syscall

    li   $v0, 4            # syscall 4 = print_string
    la   $a0, msg_virgula  # imprime separador ","
    syscall

    # Imprime o preço em centavos diretamente como inteiro
    lw   $a0, PRECO_OFFSET($s0)  # $a0 = preço em centavos do slot atual
    li   $v0, 1                  # syscall 1 = print_int
    syscall

    li   $v0, 4
    la   $a0, msg_virgula  # imprime separador ","
    syscall

    # Imprime a descrição (string terminada em \0)
    li   $v0, 4                        # syscall 4 = print_string
    addi $a0, $s0, DESC_OFFSET         # $a0 = endereço da descrição no slot atual
    syscall                            # $s0 é $s-reg, sobreviveu ao jal anterior

    li   $v0, 4
    la   $a0, msg_newline  # quebra de linha após cada item
    syscall

cl_prox:
    addi $s0, $s0, ITEM_SIZE   # avança o cursor para o próximo slot (48 bytes)
    addi $s1, $s1, -1          # decrementa o contador de slots restantes
    j    cl_loop               # volta ao topo do loop

cl_vazio:
    li   $v0, 4
    la   $a0, msg_cardapio_vazio  # informa que não há itens cadastrados
    syscall

cl_fim:
    lw   $s1, 8($sp)       # restaura $s1
    lw   $s0, 4($sp)       # restaura $s0
    lw   $ra, 0($sp)       # restaura endereço de retorno
    addi $sp, $sp, 12      # libera o frame
    jr   $ra

# FUNÇÃO: cardapio_format
# Efeito  : Zera todos os 960 bytes do array cardápio, apagando todos os itens.
#           Leaf function: não usa pilha.
cardapio_format:
    la   $t0, cardapio     # $t0 = ponteiro para o início do array cardápio
    li   $t1, 960          # $t1 = total de bytes a zerar (20 itens × 48 bytes)
cf_loop:
    beq  $t1, $zero, cf_fim  # se zerou todos os bytes, encerra
    sw   $zero, 0($t0)        # escreve word 0 no endereço atual
    addi $t0, $t0, 4          # avança 4 bytes (tamanho de uma word)
    addi $t1, $t1, -4         # decrementa o contador de bytes restantes
    j    cf_loop
cf_fim:
    jr   $ra               # retorna ao chamador

# FUNÇÃO: mesa_iniciar
# Entrada : $a0 = ponteiro para string do código da mesa (ex: "09")
#           $a1 = ponteiro para string do telefone (ex: "08198765432")
#           $a2 = ponteiro para string do nome (ex: "Jose Silva")
# Efeito  : Valida o código (1-15), verifica se a mesa está desocupada,
#           marca status como ocupada, copia telefone e nome, zera pedidos e saldo.
# Nota    : $s4 guarda o endereço da mesa para sobreviver às chamadas jal strncopy.
#           Frame expandido para 24 bytes para acomodar 6 $s-regs.
mesa_iniciar:
    addi $sp, $sp, -24     # abre frame de 24 bytes (6 registradores × 4)
    sw   $ra,  0($sp)      # salva endereço de retorno
    sw   $s0,  4($sp)      # preserva $s0 (ponteiro da string do ID)
    sw   $s1,  8($sp)      # preserva $s1 (ponteiro da string do telefone)
    sw   $s2, 12($sp)      # preserva $s2 (ponteiro da string do nome)
    sw   $s3, 16($sp)      # preserva $s3 (ID da mesa como inteiro)
    sw   $s4, 20($sp)      # preserva $s4 (endereço da struct da mesa na memória)

    move $s0, $a0          # salva o ptr do ID antes de qualquer jal (jal destrói $a-regs)
    move $s1, $a1          # salva o ptr do telefone
    move $s2, $a2          # salva o ptr do nome

    move $a0, $s0          # passa o ptr do ID como argumento
    jal  string_to_int     # converte string do ID para inteiro; resultado em $v0
    move $s3, $v0          # $s3 = ID da mesa como inteiro

    blt  $s3, 1,  mi_err_inexistente   # ID < 1: mesa inexistente
    bgt  $s3, 15, mi_err_inexistente   # ID > 15: mesa inexistente

    # Calcula endereço da struct da mesa: base_mesas + (ID-1) × MESA_SIZE
    addi $t0, $s3, -1     # índice base-0
    li   $t1, MESA_SIZE   # 212 bytes por mesa
    mul  $t0, $t0, $t1    # deslocamento em bytes
    la   $t2, mesas       # endereço base do array de mesas
    add  $t2, $t2, $t0    # $t2 = endereço da struct da mesa
    move $s4, $t2          # $s4 = endereço da mesa (protegido em $s para sobreviver a jals)

    lb   $t3, M_STATUS($s4)  # lê o byte de status da mesa
    li   $t4, 1              # valor 1 = mesa ocupada
    beq  $t3, $t4, mi_err_ocupada  # se status == 1, mesa já está em uso

    # Marca a mesa como ocupada
    li   $t3, 1
    sb   $t3, M_STATUS($s4)  # grava status = 1 (ocupada) na struct da mesa

    # Copia o telefone com limite de TEL_SIZE bytes (11 dígitos + \0)
    addi $a0, $s4, M_TEL   # destino: campo M_TEL dentro da struct da mesa
    move $a1, $s1           # origem: string do telefone digitada pelo usuário
    li   $a2, TEL_SIZE      # limite: 12 bytes (11 dígitos + \0)
    jal  strncopy           # $s4 sobrevive pois é $s-reg (não destruído por callees)

    # Copia o nome com limite de NOME_SIZE bytes (31 chars + \0)
    addi $a0, $s4, M_NOME  # destino: campo M_NOME dentro da struct da mesa
    move $a1, $s2           # origem: string do nome digitada pelo usuário
    li   $a2, NOME_SIZE     # limite: 32 bytes (31 chars + \0)
    jal  strncopy           # $s4 ainda válido após este jal

    # Zera todos os slots de pedido da mesa (20 slots × 8 bytes cada)
    addi $t5, $s4, M_PEDIDOS  # $t5 = ponteiro para o início do array de pedidos
    li   $t6, MAX_PEDIDOS      # $t6 = contador: 20 iterações
mi_zero_loop:
    beq  $t6, $zero, mi_zero_fim  # se zerou todos os slots, encerra
    sw   $zero, 0($t5)             # zera o campo P_COD do slot (código do item = 0)
    sw   $zero, 4($t5)             # zera o campo P_QTD do slot (quantidade = 0)
    addi $t5, $t5, PEDIDO_SIZE    # avança o ponteiro para o próximo slot (8 bytes)
    addi $t6, $t6, -1             # decrementa o contador
    j    mi_zero_loop
mi_zero_fim:

    sw   $zero, M_PAGO($s4)   # zera o saldo pago da mesa (começa com R$0,00)

    li   $v0, 4
    la   $a0, msg_mesa_ok     # mensagem de atendimento iniciado com sucesso
    syscall
    j    mi_fim

mi_err_inexistente:
    li   $v0, 4
    la   $a0, msg_mesa_inexistente  # código de mesa fora do intervalo 01-15
    syscall
    j    mi_fim

mi_err_ocupada:
    li   $v0, 4
    la   $a0, msg_mesa_ocupada  # mesa já está em atendimento
    syscall

mi_fim:
    lw   $s4, 20($sp)      # restaura $s4 (ordem inversa à do prólogo)
    lw   $s3, 16($sp)
    lw   $s2, 12($sp)
    lw   $s1,  8($sp)
    lw   $s0,  4($sp)
    lw   $ra,  0($sp)      # restaura endereço de retorno
    addi $sp, $sp, 24      # libera o frame
    jr   $ra

# FUNÇÃO: mesa_ad_item
# Entrada : $a0 = ponteiro para string do código da mesa
#           $a1 = ponteiro para string do código do item do cardápio
# Efeito  : Valida mesa e item, verifica se item já consta na conta da mesa.
#           Se sim, incrementa a quantidade. Se não, ocupa um slot vazio.
mesa_ad_item:
    addi $sp, $sp, -24     # abre frame de 24 bytes
    sw   $ra,  0($sp)
    sw   $s0,  4($sp)      # ID da mesa como inteiro
    sw   $s1,  8($sp)      # código do item como inteiro
    sw   $s2, 12($sp)      # endereço da struct da mesa
    sw   $s3, 16($sp)      # (reservado para uso futuro)
    sw   $s4, 20($sp)      # (reservado para uso futuro)

    jal  string_to_int     # converte string do ID da mesa para inteiro
    move $s0, $v0          # $s0 = ID da mesa

    blt  $s0, 1,  mai_err_inexistente   # ID < 1: mesa inexistente
    bgt  $s0, 15, mai_err_inexistente   # ID > 15: mesa inexistente

    # Calcula endereço da mesa
    addi $t0, $s0, -1
    li   $t1, MESA_SIZE
    mul  $t0, $t0, $t1
    la   $t2, mesas
    add  $t2, $t2, $t0
    move $s2, $t2           # $s2 = endereço da struct da mesa

    lb   $t3, M_STATUS($s2)          # lê status da mesa
    beq  $t3, $zero, mai_err_nao_iniciou  # status 0 = desocupada

    move $a0, $a1           # $a1 ainda contém o ptr do código do item (não foi alterado)
    jal  string_to_int      # converte string do código do item para inteiro
    move $s1, $v0           # $s1 = código do item

    blt  $s1, 1,  mai_err_cod_item   # código < 1: inválido
    bgt  $s1, 20, mai_err_cod_item   # código > 20: inválido

    # Verifica se o item existe no cardápio (slot não-zerado)
    addi $t0, $s1, -1
    li   $t1, ITEM_SIZE
    mul  $t0, $t0, $t1
    la   $t2, cardapio
    add  $t2, $t2, $t0
    lw   $t3, CODIGO_OFFSET($t2)          # lê código do slot no cardápio
    beq  $t3, $zero, mai_err_nao_cardapio # código 0 = item não cadastrado

    # Busca linear nos slots de pedido da mesa
    addi $t5, $s2, M_PEDIDOS  # $t5 = ponteiro para o primeiro slot de pedido
    li   $t6, MAX_PEDIDOS      # $t6 = contador de slots restantes (20)
mai_busca:
    beq  $t6, $zero, mai_novo_slot  # chegou ao fim sem achar: usa slot novo
    lw   $t7, P_COD($t5)
    beq  $t7, $s1, mai_incrementa  # slot com este código já existe → incrementa
    beq  $t7, $zero, mai_novo_slot # slot vazio → usa este
    addi $t5, $t5, PEDIDO_SIZE     # avança para o próximo slot
    addi $t6, $t6, -1
    j    mai_busca

mai_incrementa:
    lw   $t8, P_QTD($t5)    # lê a quantidade atual do pedido
    addi $t8, $t8, 1        # incrementa em 1
    sw   $t8, P_QTD($t5)    # grava a nova quantidade
    j    mai_ok

mai_novo_slot:
    sw   $s1, P_COD($t5)    # grava o código do item no slot vazio
    li   $t8, 1
    sw   $t8, P_QTD($t5)    # define quantidade inicial = 1

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

# FUNÇÃO: mesa_rm_item
# Entrada : $a0 = ponteiro para string do código da mesa
#           $a1 = ponteiro para string do código do item
# Efeito  : Localiza o item nos pedidos da mesa. Se quantidade > 1, decrementa.
#           Se quantidade == 1, zera o slot (libera a entrada).
mesa_rm_item:
    addi $sp, $sp, -20
    sw   $ra,  0($sp)
    sw   $s0,  4($sp)      # ID da mesa
    sw   $s1,  8($sp)      # código do item
    sw   $s2, 12($sp)      # endereço da mesa
    sw   $s3, 16($sp)      # (reservado)

    jal  string_to_int
    move $s0, $v0          # $s0 = ID da mesa

    blt  $s0, 1,  mri_err_inexistente
    bgt  $s0, 15, mri_err_inexistente

    addi $t0, $s0, -1
    li   $t1, MESA_SIZE
    mul  $t0, $t0, $t1
    la   $t2, mesas
    add  $t2, $t2, $t0
    move $s2, $t2           # $s2 = endereço da mesa

    lb   $t3, M_STATUS($s2)
    beq  $t3, $zero, mri_err_nao_iniciou  # mesa desocupada

    move $a0, $a1           # passa ptr do código do item para string_to_int
    jal  string_to_int
    move $s1, $v0           # $s1 = código do item

    blt  $s1, 1,  mri_err_cod
    bgt  $s1, 20, mri_err_cod

    # Busca linear o item nos pedidos da mesa
    addi $t5, $s2, M_PEDIDOS
    li   $t6, MAX_PEDIDOS
mri_busca:
    beq  $t6, $zero, mri_err_nao_conta  # percorreu todos sem achar: item não está na conta
    lw   $t7, P_COD($t5)
    beq  $t7, $s1, mri_achou           # encontrou o slot com este item
    addi $t5, $t5, PEDIDO_SIZE
    addi $t6, $t6, -1
    j    mri_busca

mri_achou:
    lw   $t8, P_QTD($t5)    # lê a quantidade atual
    addi $t8, $t8, -1       # decrementa em 1
    bgt  $t8, $zero, mri_atualiza  # se ainda > 0, apenas atualiza a quantidade

    # Quantidade chegou a 0: zera o slot para liberá-lo
    sw   $zero, P_COD($t5)  # apaga o código do item no slot
    sw   $zero, P_QTD($t5)  # apaga a quantidade no slot
    j    mri_ok

mri_atualiza:
    sw   $t8, P_QTD($t5)    # grava a quantidade decrementada

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

# FUNÇÃO: mesa_format
# Efeito  : Zera os 3180 bytes do array mesas, colocando todas como desocupadas.
#           Leaf function: não usa pilha.
mesa_format:
    la   $t0, mesas        # $t0 = endereço do início do array de mesas
    li   $t1, 3180         # $t1 = total de bytes a zerar (15 mesas × 212 bytes)
mf_loop:
    beq  $t1, $zero, mf_fim  # se zerou tudo, encerra
    sw   $zero, 0($t0)        # escreve word 0 no endereço atual
    addi $t0, $t0, 4          # avança 4 bytes
    addi $t1, $t1, -4         # decrementa o contador
    j    mf_loop
mf_fim:
    jr   $ra

# FUNÇÃO: mesa_parcial
# Entrada : $a0 = ponteiro para string do código da mesa
# Efeito  : Lista cada item pedido com código, quantidade e descrição.
#           Calcula e exibe total, valor pago e saldo devedor.
# Nota    : $s5 e $s6 guardam quantidade e preço do item atual para sobreviver
#           às chamadas syscall que podem alterar $t-regs.
mesa_parcial:
    addi $sp, $sp, -32     # abre frame de 32 bytes (8 registradores × 4)
    sw   $ra,  0($sp)
    sw   $s0,  4($sp)      # ID da mesa como inteiro
    sw   $s1,  8($sp)      # endereço da struct da mesa
    sw   $s2, 12($sp)      # total acumulado em centavos
    sw   $s3, 16($sp)      # cursor: ponteiro para o slot de pedido atual
    sw   $s4, 20($sp)      # contador de slots restantes
    sw   $s5, 24($sp)      # quantidade do pedido atual (protegida entre syscalls)
    sw   $s6, 28($sp)      # preço unitário do item atual (protegido entre syscalls)

    jal  string_to_int
    move $s0, $v0          # $s0 = ID da mesa

    blt  $s0, 1,  mp_err_inexistente
    bgt  $s0, 15, mp_err_inexistente

    addi $t0, $s0, -1
    li   $t1, MESA_SIZE
    mul  $t0, $t0, $t1
    la   $t2, mesas
    add  $t2, $t2, $t0
    move $s1, $t2           # $s1 = endereço da mesa

    lb   $t3, M_STATUS($s1)
    beq  $t3, $zero, mp_err_nao_iniciou  # mesa desocupada, nada a exibir

    addi $s3, $s1, M_PEDIDOS  # $s3 = ponteiro para o primeiro slot de pedido
    li   $s4, MAX_PEDIDOS      # $s4 = 20 slots a percorrer
    li   $s2, 0               # $s2 = acumulador do total (começa zerado)

mp_loop:
    beq  $s4, $zero, mp_resumo  # percorreu todos os slots, vai ao resumo
    lw   $t0, P_COD($s3)
    beq  $t0, $zero, mp_prox    # slot vazio, pula

    # Localiza o item no cardápio para obter preço e descrição
    addi $t1, $t0, -1
    li   $t2, ITEM_SIZE
    mul  $t1, $t1, $t2
    la   $t2, cardapio
    add  $t2, $t2, $t1         # $t2 = endereço do slot do item no cardápio

    # Salva quantidade e preço em $s-regs ANTES de qualquer syscall
    lw   $s5, P_QTD($s3)           # $s5 = quantidade pedida (protegida)
    lw   $s6, PRECO_OFFSET($t2)    # $s6 = preço unitário em centavos (protegido)

    # Imprime rótulo e código do item
    li   $v0, 4
    la   $a0, msg_parc_item    # imprime "Item: "
    syscall
    lw   $t0, P_COD($s3)       # relê código (t0 pode ter sido destruído pelos syscalls)
    li   $v0, 1
    move $a0, $t0
    syscall

    # Imprime rótulo e quantidade
    li   $v0, 4
    la   $a0, msg_parc_qtd     # imprime "  Qtd: "
    syscall
    li   $v0, 1
    move $a0, $s5              # $s5 ainda válido (é $s-reg)
    syscall

    # Imprime rótulo da descrição
    li   $v0, 4
    la   $a0, msg_parc_desc    # imprime "  Desc: "
    syscall

    # Recalcula o ponteiro para a descrição (t2 pode ter sido corrompido pelos syscalls)
    addi $t0, $s0, -1
    li   $t1, MESA_SIZE
    mul  $t0, $t0, $t1
    la   $t2, mesas
    add  $t2, $t2, $t0         # reconstrói ponteiro da mesa
    lw   $t0, P_COD($s3)       # relê código do item
    addi $t0, $t0, -1
    li   $t1, ITEM_SIZE
    mul  $t0, $t0, $t1
    la   $t2, cardapio
    add  $t2, $t2, $t0         # $t2 = slot do item no cardápio
    addi $a0, $t2, DESC_OFFSET # $a0 = ponteiro para a string de descrição
    li   $v0, 4
    syscall                    # imprime a descrição do item

    li   $v0, 4
    la   $a0, msg_newline
    syscall

    # Acumula total: quantidade × preço unitário
    mul  $t0, $s5, $s6         # $t0 = subtotal deste item
    add  $s2, $s2, $t0         # adiciona ao acumulador total

mp_prox:
    addi $s3, $s3, PEDIDO_SIZE  # avança cursor para o próximo slot
    addi $s4, $s4, -1           # decrementa contador
    j    mp_loop

mp_resumo:
    # Imprime total da conta
    li   $v0, 4
    la   $a0, msg_parc_total    # "Total:   R$ "
    syscall
    move $a0, $s2               # $s2 = total acumulado em centavos
    jal  print_preco            # imprime no formato X,XX
    li   $v0, 4
    la   $a0, msg_newline
    syscall

    # Imprime valor já pago
    li   $v0, 4
    la   $a0, msg_parc_pago     # "Pago:    R$ "
    syscall
    lw   $a0, M_PAGO($s1)       # lê o saldo pago da mesa
    jal  print_preco
    li   $v0, 4
    la   $a0, msg_newline
    syscall

    # Calcula e imprime saldo devedor = total - pago
    lw   $t0, M_PAGO($s1)
    sub  $t0, $s2, $t0          # $t0 = devedor
    li   $v0, 4
    la   $a0, msg_parc_devedor  # "Devedor: R$ "
    syscall
    move $a0, $t0
    jal  print_preco
    li   $v0, 4
    la   $a0, msg_newline
    syscall

    j    mp_fim

mp_err_inexistente:
    li   $v0, 4
    la   $a0, msg_mesa_inexistente
    syscall
    j    mp_fim

mp_err_nao_iniciou:
    li   $v0, 4
    la   $a0, msg_mesa_nao_iniciou
    syscall

mp_fim:
    lw   $s6, 28($sp)
    lw   $s5, 24($sp)
    lw   $s4, 20($sp)
    lw   $s3, 16($sp)
    lw   $s2, 12($sp)
    lw   $s1,  8($sp)
    lw   $s0,  4($sp)
    lw   $ra,  0($sp)
    addi $sp, $sp, 32
    jr   $ra

# FUNÇÃO: mesa_pagar
# Entrada : $a0 = ponteiro para string do código da mesa
#           $a1 = ponteiro para string do valor em centavos (ex: "00500" = R$5,00)
# Efeito  : Adiciona o valor informado ao campo M_PAGO da mesa (pagamento parcial).
mesa_pagar:
    addi $sp, $sp, -16
    sw   $ra,  0($sp)
    sw   $s0,  4($sp)      # ID da mesa
    sw   $s1,  8($sp)      # endereço da mesa
    sw   $s2, 12($sp)      # valor a pagar em centavos

    jal  string_to_int
    move $s0, $v0          # $s0 = ID da mesa

    blt  $s0, 1,  mpg_err_inexistente
    bgt  $s0, 15, mpg_err_inexistente

    addi $t0, $s0, -1
    li   $t1, MESA_SIZE
    mul  $t0, $t0, $t1
    la   $t2, mesas
    add  $t2, $t2, $t0
    move $s1, $t2           # $s1 = endereço da mesa

    lb   $t3, M_STATUS($s1)
    beq  $t3, $zero, mpg_err_nao_iniciou  # mesa desocupada: não aceita pagamento

    move $a0, $a1           # passa ptr do valor para string_to_int
    jal  string_to_int
    move $s2, $v0           # $s2 = valor a pagar em centavos

    # M_PAGO += valor
    lw   $t0, M_PAGO($s1)  # lê o saldo pago atual
    add  $t0, $t0, $s2      # soma o novo pagamento
    sw   $t0, M_PAGO($s1)  # grava o novo saldo pago

    li   $v0, 4
    la   $a0, msg_pagamento_ok
    syscall
    j    mpg_fim

mpg_err_inexistente:
    li   $v0, 4
    la   $a0, msg_mesa_inexistente
    syscall
    j    mpg_fim

mpg_err_nao_iniciou:
    li   $v0, 4
    la   $a0, msg_mesa_nao_iniciou
    syscall

mpg_fim:
    lw   $s2, 12($sp)
    lw   $s1,  8($sp)
    lw   $s0,  4($sp)
    lw   $ra,  0($sp)
    addi $sp, $sp, 16
    jr   $ra

# FUNÇÃO: mesa_fechar
# Entrada : $a0 = ponteiro para string do código da mesa
# Efeito  : Calcula o total da conta, verifica se o saldo devedor é zero.
#           Se sim, zera os 212 bytes da struct (status volta a 0 = desocupada).
#           Se não, exibe o saldo restante e impede o fechamento.
mesa_fechar:
    addi $sp, $sp, -20
    sw   $ra,  0($sp)
    sw   $s0,  4($sp)      # ID da mesa
    sw   $s1,  8($sp)      # endereço da mesa
    sw   $s2, 12($sp)      # total bruto calculado
    sw   $s3, 16($sp)      # saldo devedor (total - pago)

    jal  string_to_int
    move $s0, $v0          # $s0 = ID da mesa

    blt  $s0, 1,  mf2_err_inexistente  # < 1: inválido
    bgt  $s0, 15, mf2_err_inexistente  # > 15: inválido (enunciado tem typo dizendo 10)

    addi $t0, $s0, -1
    li   $t1, MESA_SIZE
    mul  $t0, $t0, $t1
    la   $t2, mesas
    add  $t2, $t2, $t0
    move $s1, $t2           # $s1 = endereço da mesa

    lb   $t3, M_STATUS($s1)
    beq  $t3, $zero, mf2_err_inexistente  # mesa desocupada não pode ser fechada

    # Calcula o total da conta percorrendo os pedidos
    addi $t5, $s1, M_PEDIDOS  # cursor nos pedidos
    li   $t6, MAX_PEDIDOS      # contador
    li   $s2, 0               # acumulador do total
mf2_calc:
    beq  $t6, $zero, mf2_calc_fim  # percorreu todos os slots
    lw   $t7, P_COD($t5)
    beq  $t7, $zero, mf2_calc_prox  # slot vazio, pula

    # Busca o preço do item no cardápio
    addi $t0, $t7, -1
    li   $t1, ITEM_SIZE
    mul  $t0, $t0, $t1
    la   $t2, cardapio
    add  $t2, $t2, $t0
    lw   $t3, PRECO_OFFSET($t2)  # preço unitário em centavos
    lw   $t4, P_QTD($t5)         # quantidade pedida
    mul  $t3, $t3, $t4           # subtotal = preço × quantidade
    add  $s2, $s2, $t3           # acumula no total

mf2_calc_prox:
    addi $t5, $t5, PEDIDO_SIZE  # avança para o próximo slot
    addi $t6, $t6, -1
    j    mf2_calc

mf2_calc_fim:
    lw   $t0, M_PAGO($s1)       # lê o saldo pago
    sub  $s3, $s2, $t0          # $s3 = devedor = total - pago

    blez $s3, mf2_fechar        # se devedor <= 0, pode fechar a mesa

    # Ainda há saldo devedor: exibe o valor e impede o fechamento
    li   $v0, 4
    la   $a0, msg_saldo_pref    # "Falha: saldo devedor ... R$ "
    syscall
    move $a0, $s3               # valor devedor em centavos
    jal  print_preco            # imprime no formato X,XX
    li   $v0, 4
    la   $a0, msg_saldo_suf     # quebra de linha final
    syscall
    j    mf2_fim

mf2_fechar:
    # Zera todos os 212 bytes da struct byte a byte (MESA_SIZE não é múltiplo de 4 exato)
    move $t0, $s1          # $t0 = ponteiro para início da struct da mesa
    li   $t1, 212          # $t1 = 212 bytes a zerar
mf2_zero:
    beq  $t1, $zero, mf2_zero_fim  # zerou tudo, encerra
    sb   $zero, 0($t0)             # escreve byte 0 no endereço atual
    addi $t0, $t0, 1               # avança 1 byte
    addi $t1, $t1, -1              # decrementa o contador
    j    mf2_zero
mf2_zero_fim:

    li   $v0, 4
    la   $a0, msg_mesa_fechada  # confirma fechamento com sucesso
    syscall
    j    mf2_fim

mf2_err_inexistente:
    li   $v0, 4
    la   $a0, msg_mesa_inexistente
    syscall

mf2_fim:
    lw   $s3, 16($sp)
    lw   $s2, 12($sp)
    lw   $s1,  8($sp)
    lw   $s0,  4($sp)
    lw   $ra,  0($sp)
    addi $sp, $sp, 20
    jr   $ra

# FUNÇÃO: salvar
# Efeito  : Abre (ou cria) o arquivo binário de persistência em modo escrita,
#           grava o array cardápio (960 bytes) e o array mesas (3180 bytes),
#           e fecha o arquivo. Exibe mensagem de êxito ou erro.
salvar:
    # PROLOGO
    addi $sp, $sp, -8
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)

    # abrir arquivo (write)
    li $v0, 13
    la $a0, nome_arquivo
    li $a1, 1
    li $a2, 0
    syscall

    move $s0, $v0

    bltz $s0, salvar_err

    # escrever cardapio
    li $v0, 15
    move $a0, $s0
    la $a1, cardapio
    li $a2, 960
    syscall

    # escrever mesas
    li $v0, 15
    move $a0, $s0
    la $a1, mesas
    li $a2, 3180
    syscall

    # fechar arquivo
    li $v0, 16
    move $a0, $s0
    syscall
    
    li $v0, 4
    la $a0, msg_salvo_ok
    syscall
    
    j salvar_fim

salvar_err:
    li $v0, 4
    la $a0, msg_err_arquivo
    syscall

salvar_fim:
    # EPILOGO
    lw   $s0, 4($sp)
    lw   $ra, 0($sp)
    addi $sp, $sp, 8
    jr   $ra

# FUNÇÃO: recarregar
# Efeito  : Abre o arquivo de persistência em modo leitura, lê cardápio e mesas
#           de volta para a memória, e fecha o arquivo.
recarregar:
    # PROLOGO
    addi $sp, $sp, -8
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)

    # abrir arquivo (read)
    li $v0, 13
    la $a0, nome_arquivo
    li $a1, 0
    li $a2, 0
    syscall

    move $s0, $v0

    bltz $s0, recarregar_err

    # ler cardapio
    li $v0, 14
    move $a0, $s0
    la $a1, cardapio
    li $a2, 960
    syscall
    
    # ler mesas
    li $v0, 14
    move $a0, $s0
    la $a1, mesas
    li $a2, 3180
    syscall

    # fechar arquivo
    li $v0, 16
    move $a0, $s0
    syscall
    
    li $v0, 4
    la $a0, msg_recarregado_ok
    syscall

    j recarregar_fim

recarregar_err:
    li $v0, 4
    la $a0, msg_err_arquivo
    syscall

recarregar_fim:
    # EPILOGO
    lw   $s0, 4($sp)
    lw   $ra, 0($sp)
    addi $sp, $sp, 8
    jr   $ra

# FUNÇÃO: formatar
# Efeito  : Chama cardapio_format e mesa_format para apagar todos os dados em memória.
#           NÃO salva automaticamente no arquivo (é necessário usar "salvar" depois).
formatar:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)       # salva $ra pois esta função faz chamadas jal

    jal  cardapio_format   # apaga todos os itens do cardápio
    jal  mesa_format       # apaga todas as mesas

    li   $v0, 4
    la   $a0, msg_formatado_ok  # confirma que os dados em memória foram apagados
    syscall

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

# FUNÇÃO: print_preco
# Entrada : $a0 = valor em centavos (ex: 490 → imprime "4,90")
# Efeito  : Divide por 100 para obter reais (quociente) e centavos (resto).
#           Imprime no formato "X,XX" com zero à esquerda se centavos < 10.
# Aviso   : Destrói $t0-$t3. O chamador deve proteger valores importantes em $s-regs.
# Leaf function: não usa pilha (não faz chamadas jal).
print_preco:
    li   $t1, 100          # divisor: 100 centavos = 1 real
    div  $a0, $t1          # divide $a0 por 100
    mflo $t2               # $t2 = quociente (parte em reais)
    mfhi $t3               # $t3 = resto (parte em centavos, 0-99)

    li   $v0, 1            # syscall 1 = print_int
    move $a0, $t2          # imprime a parte em reais
    syscall

    li   $v0, 4            # syscall 4 = print_string
    la   $a0, msg_ponto    # imprime o separador decimal ","
    syscall

    # Verifica se centavos < 10: se sim, imprime "0" antes (ex: 05 → "0" + "5")
    li   $t0, 10
    bge  $t3, $t0, pp_sem_zero  # se centavos >= 10, não precisa de zero à esquerda
    li   $v0, 4
    la   $a0, msg_zero_esq      # imprime "0" como prefixo dos centavos
    syscall

pp_sem_zero:
    # Sempre imprime os centavos. Quando centavos == 0 o fluxo já passou pelo
    # bloco do zero à esquerda acima, então aqui imprime o "0" restante → "0,00".
    # Para centavos >= 10 (ex: 90), imprime direto "90" → "9,90".
    li   $v0, 1
    move $a0, $t3            # imprime os centavos (ex: 0, 5, 80, 99)
    syscall

pp_fim:
    jr   $ra               # retorna ao chamador

# FUNÇÃO: strcmp
# Entrada : $a0 = ponteiro para a primeira string
#           $a1 = ponteiro para a segunda string
# Saída   : $v0 = 0 se as strings são iguais; valor diferente de 0 se diferentes
# Efeito  : Compara byte a byte até encontrar diferença ou \0 simultâneo.
# Leaf function: não usa pilha.
strcmp:
    lb $t0, 0($a0)         # lê byte atual da primeira string
    lb $t1, 0($a1)         # lê byte atual da segunda string
    bne $t0, $t1, strcmp_diff   # bytes diferentes: strings não são iguais
    beq $t0, $zero, strcmp_equal  # ambos são \0 simultâneos: strings iguais
    addi $a0, $a0, 1       # avança ponteiro da primeira string
    addi $a1, $a1, 1       # avança ponteiro da segunda string
    j strcmp               # continua comparando
strcmp_diff:
    sub $v0, $t0, $t1      # $v0 = diferença dos bytes (≠ 0)
    jr  $ra
strcmp_equal:
    li  $v0, 0             # $v0 = 0 indica strings iguais
    jr  $ra

# FUNÇÃO: string_to_int
# Entrada : $a0 = ponteiro para string numérica (ex: "00490")
# Saída   : $v0 = valor inteiro correspondente (ex: 490)
# Efeito  : Processa dígito a dígito enquanto o caractere estiver entre '0' (48) e '9' (57).
# Leaf function: não usa pilha.
string_to_int:
    li $v0, 0              # acumulador do resultado começa em 0
s2i_loop:
    lb $t0, 0($a0)         # lê o byte atual da string
    blt $t0, 48, s2i_fim   # se byte < '0' (ASCII 48), não é dígito: encerra
    bgt $t0, 57, s2i_fim   # se byte > '9' (ASCII 57), não é dígito: encerra
    addi $t0, $t0, -48     # converte ASCII para valor numérico ('0'→0, '9'→9)
    mul  $v0, $v0, 10      # desloca o acumulador uma casa decimal à esquerda
    add  $v0, $v0, $t0     # adiciona o dígito atual ao acumulador
    addi $a0, $a0, 1       # avança o ponteiro para o próximo byte
    j s2i_loop
s2i_fim:
    jr $ra                 # retorna com o valor inteiro em $v0

# FUNÇÃO: strcopy
# Entrada : $a0 = ponteiro para o buffer de destino
#           $a1 = ponteiro para a string de origem
# Efeito  : Copia byte a byte até encontrar \0 (inclusive).
# Atenção : Sem limite de tamanho — usar apenas quando o tamanho é garantido.
#           Para entradas do usuário, prefira strncopy.
strcopy:
sc_loop:
    lb   $t0, 0($a1)       # lê byte da origem
    sb   $t0, 0($a0)       # grava byte no destino
    beq  $t0, $zero, sc_fim  # se foi \0, cópia concluída
    addi $a0, $a0, 1       # avança ponteiro de destino
    addi $a1, $a1, 1       # avança ponteiro de origem
    j    sc_loop
sc_fim:
    jr   $ra

# FUNÇÃO: strncopy
# Entrada : $a0 = ponteiro para o buffer de destino
#           $a1 = ponteiro para a string de origem
#           $a2 = limite máximo de bytes a copiar (incluindo o \0 final)
# Efeito  : Copia até $a2 bytes ou até encontrar \0.
#           Sempre garante que o destino termina em \0 (mesmo se truncado).
strncopy:
    move $t2, $a2          # $t2 = contador de bytes restantes
snc_loop:
    beq  $t2, $zero, snc_termina  # atingiu o limite: para de copiar
    lb   $t0, 0($a1)              # lê byte da origem
    beq  $t0, $zero, snc_termina  # encontrou \0 na origem: encerra
    sb   $t0, 0($a0)              # grava o byte no destino
    addi $a0, $a0, 1              # avança ponteiro de destino
    addi $a1, $a1, 1              # avança ponteiro de origem
    addi $t2, $t2, -1             # decrementa o contador
    j    snc_loop
snc_termina:
    sb   $zero, 0($a0)    # grava \0 no destino — garante terminação correta sempre
    jr   $ra
