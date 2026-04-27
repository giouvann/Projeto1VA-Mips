# Projeto 01 - Assembly MIPS e Simulador MARS
**Disciplina:** Arquitetura e Organização de Computadores (2026.1) 

**Instituição:** Universidade Federal Rural de Pernambuco (UFRPE) 

**Professor:** Vítor A. Coutinho 

##  Integrantes do Grupo
* David Fernando de Melo - david.fmelo@ufrpe.br
* Evelin Paula Dionizio da Silva - 
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


##  Estrutura do Repositório
O projeto está organizado da seguinte forma:



##  Como Executar


##  Requisitos Implementados (Projeto Principal)


