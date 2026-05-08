######################################################################################
# GRUPO: David Fernando, Evelin Dionizio, Giovanna Costa, Miguel Monteiro
# ATIVIDADE: Projeto 01 - 1a VA
# DISCIPLINA: Arquitetura e Organizacao de Computadores
# SEMESTRE: 2026.1
# DESCRIÇÃO: Ponto de entrada do programa — shell interativo que lê comandos
#            continuamente do terminal, exibe o banner e despacha cada comando.
#            Implementa R8 (loop de leitura), R9 (banner) e R10 (interpretação).
######################################################################################

# Inclui o segmento .data com todas as constantes, mensagens e estruturas de dados
#include "dados.asm"

# Inclui o segmento .text com o parser, switch e todas as funções do sistema
.include "comandos.asm"

# Inicia o segmento de código deste arquivo
.text

# Declara "main" como símbolo global para que o montador/MARS identifique o ponto de entrada
.globl main

# FUNÇÃO: limpar_newline
# Entrada : $a0 = ponteiro para o buffer de entrada (já preenchido pelo syscall 8)
# Efeito  : Percorre a string byte a byte procurando '\n' (ASCII 10).
#           Ao encontrá-lo, substitui por '\0' para remover a quebra de linha
#           que o syscall 8 deixa no final do buffer.
#           Se a string terminar em '\0' sem '\n' (buffer cheio), não faz nada.
# Leaf function: não usa pilha.
limpar_newline:
    move $t0, $a0          # $t0 = cursor que percorre o buffer
ln_loop:
    lb   $t1, 0($t0)       # lê o byte atual
    beq  $t1, $zero, ln_fim  # chegou ao fim da string sem achar '\n': encerra
    li   $t2, 10           # '\n' = ASCII 10
    beq  $t1, $t2, ln_achou  # encontrou o '\n': substitui por '\0'
    addi $t0, $t0, 1       # avança o cursor
    j    ln_loop
ln_achou:
    sb   $zero, 0($t0)     # sobrescreve o '\n' com '\0'
ln_fim:
    jr   $ra               # retorna ao chamador

# main — Shell interativo (R8, R9, R10)
#
# Fluxo de cada iteração:
#   1. Imprime o banner  "drago-shell>> "           (R9)
#   2. Lê uma linha do terminal via syscall 8       (R8)
#   3. Remove o '\n' final do buffer (limpar_newline)
#   4. Ignora linhas vazias (primeiro byte == '\0')
#   5. Chama conversao_cmd para tokenizar a entrada
#   6. Chama switch_comandos para despachar o comando (R10)
#   7. Volta ao passo 1 — loop infinito
main:
    # $s0 guarda o endereço base do buffer input_buf durante o programa.
    # Usar $s0 evita recarregar 'la' a cada iteração e protege o valor entre jals.
    la   $s0, input_buf    # $s0 = endereço permanente do buffer de entrada

shell_loop:
    # ----- R9: imprime o banner antes de cada leitura -----
    li   $v0, 4
    la   $a0, msg_banner   # "drago-shell>> "
    syscall

    # ----- R8: lê a linha digitada pelo usuário -----
    li   $v0, 8            # syscall 8 = read_string
    move $a0, $s0          # $a0 = endereço do buffer de destino
    li   $a1, BUF_SIZE     # $a1 = capacidade máxima (127 chars + '\0')
    syscall
    # Após o syscall 8, input_buf contém a string digitada COM '\n' no final.

    # ----- Remove o '\n' que o syscall 8 insere no final -----
    move $a0, $s0          # passa o buffer para limpar_newline
    jal  limpar_newline    # substitui '\n' por '\0'

    # ----- Ignora linhas vazias (usuário pressionou Enter sem digitar nada) -----
    lb   $t0, 0($s0)       # lê o primeiro byte do buffer
    beq  $t0, $zero, shell_loop  # se for '\0', linha vazia: volta ao topo

    # ----- R10: tokeniza e despacha o comando -----
    move $a0, $s0          # $a0 = ponteiro para a string de entrada
    la   $a1, resultado    # $a1 = ponteiro para a struct resultado
    jal  conversao_cmd     # separa tokens pelo '-'; preenche resultado[0..3]

    la   $a1, resultado    # recarrega $a1 (jal pode ter alterado o registrador)
    jal  switch_comandos   # identifica e executa o comando; imprime "Comando invalido" se desconhecido

    j    shell_loop        # volta ao início do loop — terminal nunca encerra sozinho
