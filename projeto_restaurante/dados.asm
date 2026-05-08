######################################################################################
# GRUPO: David Fernando, Evelin Dionizio, Giovanna Costa, Miguel Monteiro
# ATIVIDADE: Projeto 01 - 1ª VA
# DISCIPLINA: Arquitetura e Organização de Computadores
# SEMESTRE: 2026.1
# QUESTÃO: Projeto Principal
# DESCRIÇÃO: Definição das estruturas de dados, constantes e mensagens do sistema
######################################################################################

# Diretiva que inicia o segmento de dados estáticos do programa
.data

# CONSTANTES DO CARDÁPIO
# Definidas com .eqv: o montador substitui o nome pelo valor em toda ocorrência,
# sem alocar memória extra — funcionam como #define em C.

.eqv ITEM_SIZE     48   # Tamanho em bytes de cada slot do cardápio (4+4+40)
.eqv MAX_ITENS     20   # Quantidade máxima de itens no cardápio

.eqv CODIGO_OFFSET  0   # Deslocamento do campo código dentro do slot (lw/sw, 4 bytes)
.eqv PRECO_OFFSET   4   # Deslocamento do campo preço dentro do slot (lw/sw, em centavos)
.eqv DESC_OFFSET    8   # Deslocamento da string de descrição dentro do slot (lb/sb)
.eqv DESC_SIZE     40   # Capacidade da descrição: 39 caracteres úteis + 1 byte \0

# Layout de cada slot do cardápio (48 bytes no total):
# Offset  Tamanho  Campo       Instrução
#  0       4 bytes  codigo      lw / sw
#  4       4 bytes  preco       lw / sw  (valor em centavos)
#  8      40 bytes  descricao   lb / sb  (string terminada em \0)

.align 2                        # Força alinhamento a 4 bytes (evita exceção em lw/sw)
cardapio: .space 960            # Reserva 960 bytes zerados: 20 itens × 48 bytes

# CONSTANTES DAS MESAS

.eqv MESA_SIZE   212   # Tamanho em bytes de cada struct de mesa
.eqv MAX_MESAS    15   # Quantidade máxima de mesas no sistema

# Layout de cada struct de mesa (212 bytes no total):
# Offset  Tamanho  Campo      Instrução  Observação
#  0       1 byte  M_STATUS   lb / sb    0=desocupada, 1=ocupada
#  1-3     3 bytes (padding)  —          alinhamento para o próximo word
#  4       4 bytes M_PAGO     lw / sw    saldo pago em centavos
#  8      12 bytes M_TEL      lb / sb    telefone: 11 dígitos + \0
# 20      32 bytes M_NOME     lb / sb    nome: 31 chars + \0
# 52     160 bytes M_PEDIDOS  lw / sw    20 slots de pedido × 8 bytes

.eqv M_STATUS     0   # Offset do byte de status da mesa
.eqv M_PAGO       4   # Offset do word de saldo pago (em centavos)
.eqv M_TEL        8   # Offset da string de telefone do responsável
.eqv M_NOME      20   # Offset da string do nome do responsável
.eqv M_PEDIDOS   52   # Offset do array de pedidos da mesa

.eqv PEDIDO_SIZE  8   # Tamanho de cada slot de pedido: código (4) + quantidade (4)
.eqv P_COD        0   # Offset do código do item dentro do slot de pedido
.eqv P_QTD        4   # Offset da quantidade dentro do slot de pedido

.eqv TEL_SIZE    12   # Buffer do telefone: 11 dígitos + terminador \0
.eqv NOME_SIZE   32   # Buffer do nome: 31 caracteres + terminador \0
.eqv MAX_PEDIDOS 20   # Máximo de itens distintos por mesa

.align 2                        # Alinha a 4 bytes antes do array de mesas
mesas: .space 3180              # Reserva 3180 bytes zerados: 15 mesas × 212 bytes

# MENSAGENS — SISTEMA GERAL

msg_banner:       .asciiz "ParáLanches-shell>> "   # Banner R9: impresso antes de cada leitura do usuário
msg_cmd_invalido: .asciiz "\nComando invalido\n"  # Comando digitado não foi reconhecido
msg_newline:      .asciiz "\n"               # Quebra de linha para espaçamento de saída
msg_virgula:      .asciiz ","               # Separador de campos na listagem
msg_r$:           .asciiz "R$ "             # Prefixo de valor monetário
msg_ponto:        .asciiz ","               # Separador decimal em print_preco (ex: 4,90)
msg_zero_esq:     .asciiz "0"              # Zero à esquerda para centavos < 10 (ex: 4,05)

# MENSAGENS — CARDÁPIO

msg_item_adicionado:   .asciiz "\nItem adicionado com sucesso\n"              # Retorno de cardapio_ad com êxito
msg_item_removido:     .asciiz "\nItem removido com sucesso\n"                # Retorno de cardapio_rm com êxito
msg_err_cod_invalido:  .asciiz "\nFalha: codigo de item invalido\n"           # Código fora do intervalo 01-20
msg_err_ja_cadastrado: .asciiz "\nFalha: numero de item ja cadastrado\n"      # Slot do cardápio já ocupado
msg_err_sem_cadastro:  .asciiz "\nFalha: Codigo informado nao possui item cadastrado no cardapio\n"  # Slot vazio na remoção
msg_cardapio_vazio:    .asciiz "\n--- Cardapio vazio ---\n"                   # Nenhum item cadastrado ao listar

# MENSAGENS — MESAS

msg_mesa_ok:          .asciiz "\nAtendimento iniciado com sucesso\n"              # mesa_iniciar executado com êxito
msg_mesa_inexistente: .asciiz "\nFalha: mesa inexistente\n"                       # Código de mesa fora de 01-15
msg_mesa_ocupada:     .asciiz "\nFalha: mesa ocupada\n"                           # Tentativa de iniciar mesa já ocupada
msg_mesa_nao_iniciou: .asciiz "\nFalha: mesa nao iniciou atendimento\n"           # Operação em mesa desocupada
msg_item_nao_cardapio:.asciiz "\nFalha: item nao cadastrado no cardapio\n"        # Item não existe no cardápio
msg_item_nao_conta:   .asciiz "\nFalha: item nao consta na conta\n"               # Item não consta nos pedidos da mesa
msg_mesa_fechada:     .asciiz "\nMesa fechada com sucesso\n"                      # mesa_fechar executado com êxito
msg_pagamento_ok:     .asciiz "\nPagamento realizado com sucesso\n"               # mesa_pagar executado com êxito
msg_saldo_pref:       .asciiz "\nFalha: saldo devedor ainda nao quitado. Valor restante: R$ "  # Prefixo do erro de saldo
msg_saldo_suf:        .asciiz "\n"                                                # Sufixo (quebra de linha) do erro de saldo

# MENSAGENS — RELATÓRIO (mesa_parcial)
# Rótulos impressos linha a linha no relatório de consumo da mesa

msg_parc_item:    .asciiz "\nItem: "       # Rótulo do código do item na listagem
msg_parc_qtd:     .asciiz "  Qtd: "       # Rótulo da quantidade pedida
msg_parc_desc:    .asciiz "  Desc: "      # Rótulo da descrição do item
msg_parc_total:   .asciiz "\nTotal:   R$ " # Rótulo do valor total da conta
msg_parc_pago:    .asciiz "Pago:    R$ "   # Rótulo do valor já pago
msg_parc_devedor: .asciiz "Devedor: R$ "   # Rótulo do saldo ainda em aberto

# MENSAGENS — ARQUIVO

msg_salvo_ok:      .asciiz "\nDados salvos com sucesso\n"       # Gravação no arquivo concluída
msg_recarregado_ok:.asciiz "\nDados recarregados com sucesso\n" # Leitura do arquivo concluída
msg_formatado_ok:  .asciiz "\nSistema formatado com sucesso\n"  # Dados em memória apagados
msg_err_arquivo:   .asciiz "\nErro ao acessar arquivo\n"        # Falha ao abrir/criar o arquivo

# STRINGS DE COMANDOS
# Cada string é comparada com a entrada do usuário pela função strcmp dentro de
# switch_comandos. O nome do label identifica qual comando a string representa.

str_cardapio_ad:     .asciiz "cardapio_ad"     # Texto esperado para adicionar item ao cardápio
str_cardapio_rm:     .asciiz "cardapio_rm"     # Texto esperado para remover item do cardápio
str_cardapio_list:   .asciiz "cardapio_list"   # Texto esperado para listar o cardápio
str_cardapio_format: .asciiz "cardapio_format" # Texto esperado para apagar todo o cardápio
str_mesa_iniciar:    .asciiz "mesa_iniciar"    # Texto esperado para iniciar atendimento de mesa
str_mesa_ad_item:    .asciiz "mesa_ad_item"    # Texto esperado para adicionar item à conta da mesa
str_mesa_rm_item:    .asciiz "mesa_rm_item"    # Texto esperado para remover item da conta da mesa
str_mesa_format:     .asciiz "mesa_format"     # Texto esperado para zerar todas as mesas
str_mesa_parcial:    .asciiz "mesa_parcial"    # Texto esperado para gerar relatório de consumo
str_mesa_pagar:      .asciiz "mesa_pagar"      # Texto esperado para registrar pagamento parcial
str_mesa_fechar:     .asciiz "mesa_fechar"     # Texto esperado para fechar a conta de uma mesa
str_salvar:          .asciiz "salvar"          # Texto esperado para salvar dados em arquivo
str_recarregar:      .asciiz "recarregar"      # Texto esperado para restaurar dados do arquivo
str_formatar:        .asciiz "formatar"        # Texto esperado para apagar todos os dados em memória

# CAMINHO DO ARQUIVO DE PERSISTÊNCIA
# Caminho absoluto onde o arquivo binário de dados é salvo e lido.
# Deve ser ajustado se o projeto for movido de diretório.

nome_arquivo: .asciiz "dados_resto.txt"

# BUFFER DE ENTRADA DO SHELL
# Área onde o syscall 8 (read_string) deposita a linha digitada pelo usuário.

.eqv BUF_SIZE 128   # Capacidade: 127 caracteres úteis + 1 byte de terminador \0

.align 2            # Alinha a 4 bytes (boa prática para acesso sequencial eficiente)
input_buf: .space 128   # Reserva 128 bytes para receber a entrada do terminal

# STRUCT RESULTADO DO PARSER
# Array de 4 words (ponteiros de 4 bytes cada) preenchido por conversao_cmd.
# Após o parse, cada posição aponta para o início de um token da linha de entrada.

.align 2   # Alinhamento a word para garantir acesso correto com lw/sw

resultado:
    .word 0   # resultado[0] — ponteiro para o token do comando  (ex: "cardapio_ad")
    .word 0   # resultado[1] — ponteiro para o argumento 1       (ex: "01")
    .word 0   # resultado[2] — ponteiro para o argumento 2       (ex: "00490")
    .word 0   # resultado[3] — ponteiro para o argumento 3       (ex: "coca cola")
