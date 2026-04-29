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

##  Como Executar





