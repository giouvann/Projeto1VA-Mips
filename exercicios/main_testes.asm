######################################################################################
# GRUPO: David Fernando, Evelin Dionizio, Giovanna Costa, Miguel Monteiro 
# ATIVIDADE: Projeto 01 - 1a VA
# DISCIPLINA: Arquitetura e Organizacao de Computadores 
# SEMESTRE: 2026.1 
# DESCRICAOO: Codigo para validar as funcooes strcpy, memcpy, strcmp, strncmp e strcat.
######################################################################################
.data
    #  Banner para do restaurante
    banner:      .asciiz "\nUFRPE-Restaurante-shell>> "
    
    # Dados para o teste da strcpy
    string_origem:  .asciiz "Item: Picanha"  # String que queremos copiar
    buffer_destino: .space 30                # Reserva 30 bytes vazios para o destino
    
    msg_antes:   .asciiz "Antes da copia (destino): "
    msg_depois:  .asciiz "Depois da copia (destino): "

.text
.globl main

main:
    # 1. Imprime o banner do projeto 
    li $v0, 4
    la $a0, banner
    syscall

    # 2. Mostra o buffer de destino antes da cópia
    li $v0, 4
    la $a0, msg_antes
    syscall
    la $a0, buffer_destino
    syscall
    
    # 3. Prepara os argumentos para a strcpy 
    # $a0 = destino, $a1 = origem
    la $a0, buffer_destino
    la $a1, string_origem
    
    jal strcpy         # Chama a tua função que está no outro strcpy
    
    # 4. O retorno da função está em $v0 
    move $a0, $v0      
    li $v0, 4          
    syscall

    # 5. Finaliza o programa (Syscall 10)
    li $v0, 10
    syscall