# Descogeo

Aplicativo Flutter simples que apresenta um país aleatório e suas principais informações.

## API utilizada
- **Nome:** countries.dev
- **Endereço:** https://countries.dev/
- **Documentação:** https://countries.dev/docs
- **Endpoint utilizado:** https://countries.dev/random
- **Método HTTP:** GET
- **Autenticação:** não exige chave de API nem cadastro.

## Funcionalidades
- Consulta um país aleatório por HTTP.
- Converte a resposta JSON em um objeto Dart.
- Exibe bandeira, nome, capital, continente/região, população, idiomas e moeda.
- Apresenta indicador de carregamento e mensagem em caso de erro.

## Conceitos aplicados
- Requisição HTTP com o pacote `http`.
- Leitura e conversão de JSON com `jsonDecode`.
- Métodos assíncronos com `async` e `await`.
- Atualização da interface conforme carregamento, sucesso ou erro.

## Como executar
1. Instale o Flutter e configure o VS Code/Android Studio.
2. Abra esta pasta no VS Code.
3. No terminal, execute `flutter pub get`.
4. Inicie um emulador Android, conecte um celular com depuração USB ou execute no Chrome com `flutter run -d chrome`.

## Dependência principal
- `http`: realiza a requisição HTTP à API.
