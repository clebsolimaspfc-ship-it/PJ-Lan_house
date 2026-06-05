# Entidades do Sistema

## Clientes

Responsável pelo armazenamento dos dados dos clientes cadastrados.

### Principais atributos

* id_cliente
* nome
* cpf
* email
* telefone
* data_cadastro

---

## Administradores

Responsável pelos usuários administrativos do sistema.

### Principais atributos

* id_admin
* nome
* email
* senha_hash
* nivel_acesso
* ultimo_login

---

## Computadores

Tabela responsável pelos computadores da Lan House.

### Principais atributos

* id_computador
* nome
* especificacoes
* status
* preco_hora

---

## Sessoes

Controla as sessões realizadas pelos clientes.

### Principais atributos

* id_sessao
* inicio
* fim
* valor_total
* status

---

## Produtos

Armazena os produtos vendidos na Lan House.

### Principais atributos

* id_produto
* nome
* categoria
* preco
* estoque

---

## Forma_pagamento

Responsável pelas formas de pagamento utilizadas.

### Principais atributos

* id_forma_pagamento
* nome
* descricao

Exemplos:

* PIX
* Crédito
* Débito
* Dinheiro

---

## Consumo

Representa os produtos consumidos durante uma sessão.

### Principais atributos

* id_consumo
* quantidade.
* subtotal
* data_consumo

---

## Torneios

Tabela responsável pelos campeonatos da Lan House.

### Principais atributos

* id_torneio
* nome
* jogo
* data_torneio
* premio
* descricao

---

## Inscricoes

Tabela associativa entre clientes e torneios.

### Principais atributos

* id_inscricao
* data_inscricao

---

## Audit_log

Responsável pela auditoria do sistema.

### Principais atributos

* id_log
* tabela_afetada
* acao
* descricao
* ip_origem
* data_evento

---

# Diagrama Entidade-Relacionamento (DER)

## Visão Geral

### Entidades do DER

```text
clientes
administradores
computadores
sessoes
produtos
forma_pagamento
consumo
torneios
inscricoes
audit_log
```
---

### MODELAGEM (Conceitual)
<img width="2526" height="1785" alt="Conceptual" src="https://github.com/user-attachments/assets/f421c0b1-c111-4bee-b004-0f319ab22458" />


### MODELAGEM (Lógico)

<img width="854" height="617" alt="Logico" src="https://github.com/user-attachments/assets/c4911347-cadc-4beb-bfd5-142f83f94590" />



