######################################################################################
# GRUPO: David Fernando, Evelin Dionizio, Giovanna Costa, Miguel Monteiro 
# ATIVIDADE: Projeto 01 - 1ª VA
# DISCIPLINA: Arquitetura e Organização de Computadores 
# SEMESTRE: 2026.1 
# QUESTÃO: Questao 4 - Função strncmp  
# DESCRIÇÃO: 
######################################################################################
.globl strncmp

strncmp:
    # $a0: ponteiro para a primeira string
    # $a1: ponteiro para a segunda string
    # $a2: número máximo de caracteres a comparar
    # $v0: valor de retorno

loop_strncmp:
    beq $a2, $zero, equal_strncmp       # Se o número máximo de caracteres a comparar for zero, as strings são iguais
    lb $t0, 0($a0)              # Carrega byte da primeira string
    lb $t1, 0($a1)              # Carrega byte da segunda string
    beq $t0, $t1, check_null_strncmp    # Se os caracteres sao iguais, testa se são null
    sub $v0, $t0, $t1           # Caso sejam diferentes, a diferença é armazenada em $v0 
    jr $ra                      # Retorna a diferença

check_null_strncmp:
    beq $t0, $zero, equal_strncmp       # Se ambos são null (fim das cadeias de caracteres), as string são iguais
    addi $a0, $a0, 1            # Não são null, passa para o próximo byte da primeira string
    addi $a1, $a1, 1            # Não são null, passa para o próximo byte da segunda string
    addi $a2, $a2, -1           # Decrementa o número máximo de caracteres a comparar
    j loop_strncmp                      # Continua o loop

equal_strncmp:
    li $v0, 0                   # Retorna 0 para string iguais
    jr $ra                      # Retorno
