# Respostas do Questionário - Atividade de Navegação Flutter

### 1. Qual era a estrutura do seu projeto antes da inclusão das novas telas?
Antes das mudanças, o projeto possuía uma tela inicial (`HomePage`) que servia como um menu para diferentes exemplos de gerenciamento de estado (Provider, Riverpod, BLoC). A listagem de produtos era exibida em uma única tela dedicada a cada padrão, sem a possibilidade de ver detalhes individuais de cada item.

### 2. Como ficou o fluxo da aplicação após a implementação da navegação?
O fluxo agora segue a estrutura:
- **Tela Inicial:** Boas-vindas e ponto de entrada com botão para o catálogo.
- **Tela de Produtos:** Listagem dinâmica consumindo a Fake API (FakestoreAPI).
- **Tela de Detalhes:** Exibição completa das informações de um produto selecionado.

### 3. Qual é o papel do `Navigator.push()` no seu projeto?
O `Navigator.push()` é responsável por empilhar uma nova tela sobre a atual. No projeto, ele é usado para levar o usuário da tela inicial para a lista de produtos e da lista de produtos para os detalhes de um item específico, mantendo o histórico de navegação.

### 4. Qual é o papel do `Navigator.pop()` no seu projeto?
O `Navigator.pop()` remove a tela que está no topo da pilha de navegação, retornando o usuário para a tela anterior. Ele é usado na tela de detalhes (através do botão "Voltar") para retornar à listagem de produtos.

### 5. Como os dados do produto selecionado foram enviados para a tela de detalhes?
Os dados foram enviados através do construtor da classe `ProductDetailPage`. Ao clicar em um item da lista, o objeto `Product` correspondente é passado como argumento para a nova tela, permitindo que ela acesse todas as propriedades do produto selecionado.

### 6. Por que a tela de detalhes depende das informações da tela anterior?
A tela de detalhes é genérica e reutilizável; ela não sabe qual produto deve exibir até que a tela anterior (a listagem) informe qual item foi selecionado pelo usuário. Sem essas informações, a tela de detalhes não teria dados para preencher a interface (nome, preço, descrição, imagem).

### 7. Quais foram as principais mudanças feitas no projeto original?
As principais mudanças foram:
- **Modelo `Product`:** Atualizado para incluir os campos `description` e `imageUrl`.
- **`ProductService`:** Modificado para mapear corretamente a descrição e a imagem vindas da API JSON.
- **`HomePage`:** Simplificada para focar na jornada do usuário rumo ao catálogo de produtos.
- **Criação da `ProductDetailPage`:** Uma nova interface para exibir informações detalhadas.
- **Implementação da Navegação:** Adição de `onTap` na listagem para disparar o `Navigator.push()`.

### 8. Quais dificuldades você encontrou durante a adaptação do projeto para múltiplas telas?
A principal dificuldade foi garantir a consistência entre as diferentes implementações de estado (Provider, BLoC, Riverpod) para que todas navegassem corretamente para a mesma tela de detalhes, mantendo a integridade dos dados e o comportamento esperado do `Navigator`.

### 9. Justificativa das Escolhas de Gerenciamento de Estado no Projeto
No projeto final consolidado, foram adotadas as seguintes estratégias para gerenciamento de estado:

*   **Sessão do Usuário (SessionManager):** Implementado utilizando **Provider** (`ChangeNotifier`). O Provider foi escolhido para a sessão global por sua simplicidade e acoplamento direto com o ciclo de vida do Flutter. Por se tratar de um estado que afeta toda a aplicação (autenticado vs não autenticado), o escopo global do Provider provê acesso rápido e direto a qualquer widget da árvore, notificando as telas para redesenho imediato no login ou logout.
*   **Listagem de Produtos e Favoritos (ProductApiBloc):** Implementado com **BLoC**. O BLoC foi a escolha principal para a tela de catálogo por sua arquitetura orientada a Eventos e Estados. Essa abordagem separa rigidamente a lógica de negócio da interface gráfica. Estados como carregamento (`ProductApiLoadingState`), sucesso (`ProductApiLoadedState`) e erro (`ProductApiErrorState`) são definidos explicitamente, tornando o fluxo altamente testável, previsível e escalável para cenários complexos do e-commerce.
*   **Carregamento de Detalhes do Produto:** Na `ProductDetailPage`, optou-se por **setState** para controlar variáveis de estado puramente locais (como o estado de carregamento e mensagens de erro do detalhe específico). No entanto, o controle de favoritos da tela de detalhes foi integrado reativamente aos gerenciadores globais (BLoC ou Provider da listagem correspondente) via callbacks (`onFavoriteChanged`), garantindo consistência instantânea dos dados entre a tela de listagem e de detalhes.
