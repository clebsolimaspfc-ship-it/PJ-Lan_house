# Entidades do Sistema

## Clientes

Responsável pelo armazenamento dos dados dos clientes cadastrados.

### Principais atributos

* id_cliente
* nome
* saldo_credito
* email
* telefone
* data_cadastro

---

## Computadores

Tabela responsável pelos computadores da Lan House.

### Principais atributos

* id_computador
* nome
* discricao
* status
* valor_hora

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

## Vendas
Obetem todas as vendas da lan house

* id_venda
* preco_unitario
* quantidade
* data_venda

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
computadores
sessoes
produtos
audit_log
Venda
```
---

### MODELAGEM (Conceitual)
<img width="2526" height="1785" alt="Conceptual" src="https://github.com/user-attachments/assets/f421c0b1-c111-4bee-b004-0f319ab22458" />


### MODELAGEM (Lógico)

<img width="854" height="617" alt="Logico" src="https://github.com/user-attachments/assets/c4911347-cadc-4beb-bfd5-142f83f94590" />



