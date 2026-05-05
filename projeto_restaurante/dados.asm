######################################################################################
# GRUPO: David Fernando, Evelin Dionizio, Giovanna Costa, Miguel Monteiro
# ATIVIDADE: Projeto 01 - 1ª VA
# DISCIPLINA: Arquitetura e Organização de Computadores
# SEMESTRE: 2026.1
# QUESTÃO: Projeto Principal
# DESCRIÇÃO: Definição das estruturas e funções de manipulação de dados do sistema
######################################################################################
.data

# --- CONSTANTES — CARDÁPIO ---
.eqv ITEM_SIZE 48
.eqv MAX_ITENS     20
.eqv CODIGO_OFFSET  0   # lw/sw  — inteiro, 4 bytes
.eqv PRECO_OFFSET   4   # lw/sw  — inteiro (centavos), 4 bytes
.eqv DESC_OFFSET    8   # lb/sb  — string até 39 chars + \0
.eqv DESC_SIZE     40   # 39 chars úteis + \0

# Layout do item de cardápio (48 bytes):
# Offset  Tam   Campo    Instrução
#  0       4    codigo   lw/sw
#  4       4    preco    lw/sw
#  8      40    desc     lb/sb
# Total: 48 bytes

.align 2
cardapio: .space 960    # 20 × 48 bytes — todos zerados no MARS

# --- CONSTANTES — MESAS ---
.eqv MESA_SIZE   212
.eqv MAX_MESAS    15

# Layout da struct mesa (212 bytes):
# Offset  Tam   Campo      Instrução    Notas
#  0       1    M_STATUS   lb/sb        0=desocupada, 1=ocupada
#  1–3     3    (padding)               alinhamento para word
#  4       4    M_PAGO     lw/sw        saldo pago em centavos
#  8      12    M_TEL      lb/sb        11 dígitos + \0
# 20      32    M_NOME     lb/sb        31 chars + \0
# 52     160    M_PEDIDOS  lw/sw        20 slots × 8 bytes
# Total: 212 bytes

.eqv M_STATUS     0
.eqv M_PAGO       4
.eqv M_TEL        8
.eqv M_NOME      20
.eqv M_PEDIDOS   52

.eqv PEDIDO_SIZE  8     # bytes por slot de pedido
.eqv P_COD        0     # offset do cod_item dentro do slot — lw/sw
.eqv P_QTD        4     # offset da quantidade dentro do slot — lw/sw

.eqv TEL_SIZE    12     # 11 dígitos + \0
.eqv NOME_SIZE   32     # 31 chars   + \0
.eqv MAX_PEDIDOS 20

.align 2
mesas: .space 3180      # 15 × 212 = 3180 bytes (todos zerados no MARS)

# --- MENSAGENS — SISTEMA GERAL ---
msg_banner:           .asciiz "resto-shell>> "
msg_cmd_invalido:     .asciiz "\nComando invalido\n"
msg_newline:          .asciiz "\n"

# --- MENSAGENS — CARDÁPIO ---
msg_item_adicionado:  .asciiz "\nItem adicionado com sucesso\n"
msg_item_removido:    .asciiz "\nItem removido com sucesso\n"
msg_err_cod_invalido: .asciiz "\nFalha: codigo de item invalido\n"
msg_err_ja_cadastrado:.asciiz "\nFalha: numero de item ja cadastrado\n"
msg_err_sem_cadastro: .asciiz "\nFalha: Codigo informado nao possui item cadastrado no cardapio\n"
msg_cardapio_vazio:   .asciiz "\n--- Cardapio vazio ---\n"
msg_virgula:          .asciiz ","

# --- MENSAGENS — MESAS ---
msg_mesa_ok:          .asciiz "\nAtendimento iniciado com sucesso\n"
msg_mesa_inexistente: .asciiz "\nFalha: mesa inexistente\n"
msg_mesa_ocupada:     .asciiz "\nFalha: mesa ocupada\n"
msg_mesa_nao_iniciou: .asciiz "\nFalha: mesa nao iniciou atendimento\n"
msg_item_nao_cardapio:.asciiz "\nFalha: item nao cadastrado no cardapio\n"
msg_item_nao_conta:   .asciiz "\nFalha: item nao consta na conta\n"


# --- STRINGS DE COMANDOS — usadas pelo switch/parser ---
str_cardapio_ad:      .asciiz "cardapio_ad"
str_cardapio_rm:      .asciiz "cardapio_rm"
str_cardapio_list:    .asciiz "cardapio_list"
str_cardapio_format:  .asciiz "cardapio_format"
str_mesa_iniciar:     .asciiz "mesa_iniciar"
str_mesa_ad_item:     .asciiz "mesa_ad_item"
str_mesa_rm_item:     .asciiz "mesa_rm_item"
str_mesa_format:      .asciiz "mesa_format"

# ---  NOME DO ARQUIVO DE PERSISTÊNCIA ---
nome_arquivo:         .asciiz "dados_resto.bin"

# --- BUFFER DE ENTRADA DO SHELL ---
.eqv BUF_SIZE 128
.align 2
input_buf: .space 128

# --- STRUCT RESULTADO DO PARSER (4 ponteiros × 4 bytes) ---
.align 2
resultado:
    .word 0   # resultado[0] — ponteiro para o comando
    .word 0   # resultado[1] — ponteiro para arg1
    .word 0   # resultado[2] — ponteiro para arg2
    .word 0   # resultado[3] — ponteiro para arg3
