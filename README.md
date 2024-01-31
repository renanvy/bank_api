# Elixir/Phoenix Bank API

API criada com Elixir e Phoenix para aprimorar os conhecimentos na linguagem.

## Funcionalidades:

**Cadastro de contas**

Neste endpoint, devem ser enviados os dados de uma conta e ela deve ser cadastrada na base de contas, caso os dados de usuário estejam válidos de acordo com a seção Regras de negócio.

**Autenticação**

Neste endpoint, devem ser enviados os dados de login de uma conta já cadastrada. Esses dados devem ser validados e deve ser retornado um token que será utilizado para validar transações do usuário. Nos próximos endpoints, o token deve ser enviado para identificar o usuário logado.

**Cadastro de transação**

Neste endpoint, devem ser enviados os dados de uma transação e ela deve ser cadastrada na base de transações, caso ela seja feita entre contas válidas e caso haja saldo suficiente na conta do usuário logado para realização dela.

**Estorno de transação**

Neste endpoint, deve ser enviado o ID de uma transação já cadastrada e os efeitos dessa transação devem ser revertidos, caso seja possível e a transação tenha sido iniciada pelo usuário logado.

**Busca de transações por data**

Neste endpoint, devem ser enviadas datas inicial e final. O endpoint deve retornar todas as transações realizadas pelo usuário logado entre essas datas em ordem cronológica.

**Visualização de saldo**

Neste endpoint, deve ser visualizado o saldo do usuário logado.

## Regras de negócio:

1.  Não deve ser possível forjar um token de autenticação. Os tokens devem identificar de forma única o usuário logado.
2.  Uma transação só deve ser realizada caso haja saldo suficiente na conta do usuário para realizá-la.
3.  Após a realização de uma transação, a conta do usuário enviante deve ter seu valor descontado do valor da transação e a do usuário recebedor acrescentada do valor da transação.
4.  Todas as transações realizadas devem ser registradas no banco de dados.
5.  Caso todas as transações no banco de dados sejam realizadas novamente a partir do estado inicial de todas as contas, os saldos devem equivaler aos saldos expostos na interface. Em outros termos: Para toda conta, se somarmos os valores de todas as transações no histórico dela a qualquer momento, o saldo total da conta deve ser o saldo atual.
6.  Uma transação só pode ser estornada uma vez.
7.  Os dados do sistema devem se manter sempre consistentes, mesmo sob grande volume de requisições simultâneas. Deve ser considerado que o sistema irá ser escalado horizontalmente, portanto considere que os dados devem se manter consistentes mesmo sob modificações concorrentes.

## Documentação da API

A documentação da API pode ser acessada [aqui](https://bankapi25.docs.apiary.io/)

## Testando a API em produção:

https://bank-api.fly.dev

## Requisitos para rodar o projeto:

- Elixir 1.14.5
- Erlang 26.2.1
- Postgres

Obs: Se ainda não tem o Elixir e Erlang instalados em sua máquina recomendo a instalação do [asdf](https://asdf-vm.com/).

## Rodando o projeto:

- Instalar as dependências, criar o banco e rodar as migrations: `mix setup`
- Iniciando o servidor: `mix phx.server`
- Rodar os testes: `mix test`
