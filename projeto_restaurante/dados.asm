######################################################################################
# GRUPO: David Fernando, Evelin Dionizio, Giovanna Costa, Miguel Monteiro
# ATIVIDADE: Projeto 01 - 1ª VA
# DISCIPLINA: Arquitetura e Organização de Computadores
# SEMESTRE: 2026.1
# QUESTÃO: Projeto Principal
# DESCRIÇÃO: Definição das estruturas e funções de manipulação de dados do sistema
######################################################################################
.data

.eqv ITEM_SIZE 48		# Tamanho de um item

.eqv MAX_ITENS 20		# Quantidade máxima

.eqv CODIGO_OFFSET 0		# Offset para acessar o código do item

.eqv PRECO_OFFSET 4		# Offset para acessar o preço do item

.eqv DESC_OFFSET 8		# Offset para acessar a descrição do item

cardapio:			# Cardápio (array de itens)
    .space 960   		# 20 * 48 bytes

