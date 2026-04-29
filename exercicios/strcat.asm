######################################################################################
# GRUPO: David Fernando, Evelin Dionizio, Giovanna Costa, Miguel Monteiro 
# ATIVIDADE: Projeto 01 - 1ª VA
# DISCIPLINA: Arquitetura e Organização de Computadores 
# SEMESTRE: 2026.1 
# QUESTÃO: Função strcat  
# DESCRIÇÃO: Une duas strings "colando" a segunda logo após o término da primeira na memória.
######################################################################################
.globl strcat

strcat:
    # Salvamos o endereco original de $a0 para retornar no final, se necessario
    move $v0, $a0

procurar_nulo:
    lb $t0, 0($a0)         # Carrega o caractere atual do destino
    beq $t0, $zero, iniciar_copia # Se for '\0', encontramos o fim da primeira string
    addi $a0, $a0, 1       # Avanca o ponteiro do destino
    j procurar_nulo

iniciar_copia:
    # Agora $a0 aponta para o lugar do antigo '\0'
loop_copia:
    lb $t1, 0($a1)         # Carrega caractere da origem
    sb $t1, 0($a0)         # Escreve no destino
    beq $t1, $zero, fim_cat # Se o caractere copiado foi o '\0', terminamos

    addi $a0, $a0, 1       # Avanca ponteiro destino
    addi $a1, $a1, 1       # Avanca ponteiro origem
    j loop_copia

fim_cat:
    jr $ra                 # Retorna para o main