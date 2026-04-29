######################################################################################
# GRUPO: David Fernando, Evelin Dionizio, Giovanna Costa, Miguel Monteiro 
# ATIVIDADE: Projeto 01 - 1a VA
# DISCIPLINA: Arquitetura e Organizacao de Computadores 
# SEMESTRE: 2026.1 
# QUESTAO: Questao 1
# DESCRICAO: Codigo main para validar as funcoes strcpy, memcpy, strcmp, strncmp e strcat.
######################################################################################
.data
    # Dados para o teste da strcpy
    string_origem:  .asciiz "Item: Picanha"  # String que queremos copiar
    buffer_destino: .space 30                # Reserva 30 bytes vazios para o destino

    # Dados para o teste da strcat
    str_destino:   .asciiz "Ola "
                   .space 20         # Espaço extra para caber o "Mundo!"
    str_origem:    .asciiz "Mundo!"
    msg_strcat:    .asciiz "\nTeste strcat (Concatenação): "

.text
.globl main

main:
    # Prepara os argumentos para a strcpy 
    la $a0, buffer_destino    # $a0 = destino
    la $a1, string_origem     #$a1 = origem
    
    jal strcpy         # Salta para a função strcpy (em outro arquivo) e salva o endereço de retorno em $ra
    
    # Mostra o resultado na tela
    move $a0, $v0      # Move o valor de retorno ($v0 contêm o endereço do destino) para $a0 para impressão
    li $v0, 4          # Prepara o sistema para imprimir uma string (Serviço 4)
    syscall

    # INICIO DO TESTE STRCAT
    la $a0, str_destino    # Carrega base do destino
    la $a1, str_origem     # Carrega origem
    jal strcat             # Executa a juncao

    # Impressao do resultado
    li $v0, 4
    la $a0, msg_strcat     # Imprime o rotulo
    syscall
    
    li $v0, 4              # Serviço 4: Imprimir String
    la $a0, str_destino    # Carrega o endereço da string que agora deve ter
    syscall                

    # Finaliza o programa 
    li $v0, 10	      #	Escolhe a função de "encerrar programa" (serviço 10)			
    syscall           # Finaliza a execução
