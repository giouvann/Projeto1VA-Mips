######################################################################################
# GRUPO: David Fernando, Evelin Dionizio, Giovanna Costa, Miguel Monteiro
# ATIVIDADE: Projeto 01 - 1a VA
# DISCIPLINA: Arquitetura e Organizacao de Computadores
# SEMESTRE: 2026.1
# DESCRICAO: Main de TESTE — valida as funcoes implementadas ate o momento
######################################################################################
.include "comandos.asm"

.text
.globl main

main:
    # adiciona item 01
    la $a0, t1
    la $a1, resultado
    jal conversao_cmd
    la $a1, resultado
    jal switch_comandos

    # lista cardapio
    la $a0, t2
    la $a1, resultado
    jal conversao_cmd
    la $a1, resultado
    jal switch_comandos

    # inicia mesa 01
    la $a0, t3
    la $a1, resultado
    jal conversao_cmd
    la $a1, resultado
    jal switch_comandos

    # adiciona item 01 na mesa 01
    la $a0, t4
    la $a1, resultado
    jal conversao_cmd
    la $a1, resultado
    jal switch_comandos

    li $v0, 10
    syscall

.data
t1: .asciiz "cardapio_ad-01-00490-coca cola"
t2: .asciiz "cardapio_list"
t3: .asciiz "mesa_iniciar-01-81988887777-Jose Silva"
t4: .asciiz "mesa_ad_item-01-01"
