# Projeto 01 - Assembly MIPS e Simulador MARS
**Disciplina:** Arquitetura e Organização de Computadores (2026.1) 

**Instituição:** Universidade Federal Rural de Pernambuco (UFRPE) 

**Professor:** Vítor A. Coutinho 

##  Integrantes do Grupo
* David Fernando de Melo - david.fmelo@ufrpe.br
* Evelin Paula Dionizio da Silva - evelin.dionizio@ufrpe.br
* Giovanna Costa da Silva - giovanna.costa@ufrpe.br
* Miguel Monteiro Alves Paes - miguel.alves@ufrpe.br

##  Descrição do Projeto
Este repositório contém as atividades desenvolvidas para a 1ª VA da disciplina, focadas na implementação de lógica de baixo nível e sistemas operados via terminal em Assembly MIPS. O projeto está dividido em três frentes principais:

### 1. Funções de Manipulação de Strings (15% da nota)
Implementação em Assembly MIPS de funções fundamentais da biblioteca `string.h`. Estas funções servem como base lógica para o processamento de comandos do sistema principal:
* **strcpy**: Cópia de strings incluindo o caractere nulo.
* **memcpy**: Cópia de blocos de memória por quantidade de bytes.
* **strcmp e strncmp**: Comparação de strings com retorno baseado no valor ASCII.
* **strcat**: Concatenação de strings garantindo a terminação nula única.

### 2. Echo via MMIO (15% da nota)
Desenvolvimento de um sistema de comunicação direta com periféricos utilizando **Memory-Mapped I/O**. O código realiza a leitura constante do teclado (Keyboard) e a impressão imediata no display do simulador MARS sem o uso de syscalls de terminal padrão.

### 3. Sistema de Gestão de Restaurante (80% da nota)
O projeto principal consiste em um sistema robusto para restaurantes, operado através de um interpretador de comandos (Shell):
* **Gestão de Cardápio e Mesas**: Cadastro de até 20 itens e controle de 15 mesas simultâneas.
* **Controle de Pedidos e Contas**: Registro de consumo, cálculo de saldo devedor e suporte a pagamentos parciais.
* **Persistência de Dados**: Salvamento e recuperação automática de informações através de arquivos externos.
* **Interface Shell**: Banner personalizado no formato `<nome-shell>>` com tratamento de comandos inválidos.

##  Requisitos Implementados (Projeto Principal)
### Gestão de Dados e Memória
- Módulo de Inventário: Estruturação de dados para até 20 itens de cardápio, com tratamento de exceções para entradas inválidas e validação de tipos.
- Gerenciamento de Instâncias (Mesas): Alocação e controle de estado para 15 mesas, integrando registros de identificação (ID, responsável, contato) e ponteiros para listas de consumo.
- Processamento de Pedidos: Registro de consumo com capacidade de 20 entradas por mesa, incluindo lógica de incremento para itens redundantes.

### Lógica de Negócio e Financeiro
- Transações Financeiras: Algoritmo de abatimento parcial de débitos, garantindo a integridade do saldo devedor através de operações aritméticas.
- Relatórios de Consumo: Geração de extratos detalhados contendo o valor total consumido pela mesa, os valores pagos parcialmente e o saldo restante a ser pago.
- Finalização de Ciclo: Procedimento de fechamento de contas com verificação de quitação integral e reinicialização segura de buffers para liberação da mesa.

### Persistência e Interface (I/O)
- Persistência de Dados: Implementação de persistência via MIPS Syscalls para manipulação de arquivos, garantindo o salvamento e carregamento do estado da aplicação.
- Interface de Linha de Comando (CLI): Desenvolvimento de um terminal interativo baseado em polling de strings terminadas em \n.
- Shell Customizado: Implementação de um banner dinâmico e interpretador de comandos com suporte a argumentos (flags iniciadas por -) e tratamento de erros sintáticos.

##  Estrutura do Repositório
O projeto está organizado da seguinte forma:
* **`/exercicios`**: Contém a implementação das funções da biblioteca `string.h` e o código de teste.
    * `strcpy.asm`, `memcpy.asm`, `strcmp.asm`, `strncmp.asm`, `strcat.asm`: Implementações individuais de cada função.
    * `main_testes.asm`: Código principal para validação das funções de string.
* **`/mmio_echo`**: Contém o desafio de entrada e saída mapeada em memória.
    * `echo_mmio.asm`: Implementação do processo de Echo (Teclado/Display) sem uso de syscalls.
* **`/projeto_restaurante`**: Pasta do sistema principal de gestão.
    * `main.asm`: Ponto de entrada do programa e loop do Shell.
    * `comandos.asm`: Lógica de interpretação dos comandos.
    * `dados.asm`: Definição das estruturas de dados para cardápio e mesas.
    * `arquivos.asm`: Funções para salvar e recarregar dados em arquivos externos.

## Planejamento do uso de memória

### Item cardápio
| Campo     | Tipo      | Tamanho      | Offset |
|-----------|-----------|--------------|--------|
| código    | word      | 4            | 0      |
| preço     | word      | 4            | 4      |
| descrição | byte[40]  | 40           | 8      |
| **TOTAL** | —         | **48 bytes** | —      |



### Mesa
| Campo           | Tipo      | Tamanho       | Offset |
|-----------------|-----------|---------------|--------|
| status          | word      | 4             | 0      |
| pago            | word      | 4             | 4      |
| telefone        | byte[12]  | 12            | 8      |
| nome            | byte[32]  | 32            | 32     |
| pedidos         | word[160] | 160           | 52     |
| **TOTAL**       | —         | **212 bytes** | —      |


## Possível erro durante a montagem do programa

Durante os testes realizados em diferentes máquinas dos integrantes do grupo, foi identificado um possível problema relacionado à montagem do programa no MARS. O erro apresentado é:

```text
"ITEM_SIZE": operand is of incorrect type
```
O problema não se limita apenas à constante *ITEM_SIZE*, podendo ocorrer também com outras constantes definidas por meio da diretiva .eqv.

Esse comportamento está relacionado à ordem em que o MARS processa os arquivos incluídos no projeto, podendo fazer com que o arquivo `comandos.asm` seja montado antes de `dados.asm`, onde as constantes são definidas.

Caso esse erro ocorra, a solução consiste em remover a linha:
```text
.include "dados.asm"
```

do arquivo `main.asm` e adicioná-la no início do arquivo `comandos.asm`. Após essa alteração, o programa deverá ser montado e executado normalmente.
