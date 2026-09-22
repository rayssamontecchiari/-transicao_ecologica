# Transição Ecológica

Aplicativo Flutter para apoiar a gestão e a avaliação de comunidades e famílias em processos de transição ecológica e sustentabilidade. O sistema permite registrar dados de organização comunitária, acompanhar famílias, realizar avaliações de indicadores e obter resultados por categoria com cálculo baseado em lógica fuzzy.

A proposta do projeto é facilitar a coleta, organização e análise de informações relacionadas à adoção de práticas mais sustentáveis, com foco em indicadores ambientais, sociais e produtivos.

## Visão geral do aplicativo

O app foi pensado para uso em campo ou em ambiente administrativo local, com armazenamento interno e processamento offline. Entre as principais funcionalidades estão:

- cadastro e gerenciamento de comunidades;
- cadastro e acompanhamento de famílias;
- realização de avaliações com escala Likert;
- cálculo automático de resultados por categoria usando lógica fuzzy;
- visualização de relatórios e histórico de avaliações;
- dashboard com métricas gerais;
- exportação e importação de dados em formato de backup e JSON/CSV;
- persistência local com SQLite via Drift.

## Funcionalidades principais

### 1. Gestão de comunidades e famílias
O aplicativo permite registrar comunidades e famílias, mantendo dados essenciais como responsável, telefone, endereço e vínculo com a comunidade.

### 2. Estrutura de avaliação
As avaliações são organizadas por categorias, dimensões e indicadores. Cada indicador possui peso armazenado no banco de dados, e esse valor é usado diretamente no cálculo do resultado final da avaliação.

> A gestão dos pesos não é feita por arquivos do projeto nem por edição manual em código. O controle dos pesos é realizado via persistência no banco de dados do aplicativo.

### 3. Cálculo fuzzy
Os resultados das avaliações não são calculados apenas por médias simples. O projeto utiliza lógica fuzzy para transformar notas em valores triangulares e gerar um resultado normalizado por categoria.

### 4. Dashboard e histórico
A interface oferece painel com quantidade de famílias cadastradas, avaliações realizadas e média geral dos resultados, além de páginas para consultar avaliações anteriores e comparações.

### 5. Exportação/Importação
O app suporta:

- backup do banco de dados local;
- exportação em JSON;
- exportação em CSV;
- restauração de base de dados ou importação de dados exportados.

## Requisitos do sistema

Para rodar o projeto localmente, você precisa de:

- Flutter SDK 3.3.3 ou superior;
- Dart SDK compatível com a versão do Flutter;
- Android Studio com Android SDK, ou Xcode para iOS/macOS;
- Git para clonar o repositório;
- opcionalmente: Chrome para rodar em web e emuladores/dispositivos para mobile.

> O projeto foi configurado como aplicação Flutter nativa e usa SQLite localmente, então não exige servidor externo para execução básica.

## Instalação

### 1. Clone o repositório

```bash
git clone <url-do-repositorio>
cd transicao_ecologica
```

### 2. Verifique a instalação do Flutter

```bash
flutter --version
flutter doctor
```

Se houver pendências de ambiente, ajuste o Android SDK, emuladores ou licenças conforme solicitado pelo Flutter Doctor.

### 3. Instale as dependências

```bash
flutter pub get
```

### 4. Gere arquivos de código gerados

Este projeto usa Drift e geração de arquivos durante o desenvolvimento. Em muitos ambientes, pode ser necessário executar:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Se você quiser acompanhar geração contínua em modo de desenvolvimento:

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

### 5. Execute o aplicativo

#### Android / iOS / emulador

```bash
flutter run
```

#### Web

```bash
flutter run -d chrome
```

#### Lista de dispositivos disponíveis

```bash
flutter devices
```

## Estrutura principal do projeto

```text
lib/
  core/
    database/
    models/
    services/
  features/
    comunidades/
    familias/
    avaliacao/
    exportacao/
    home_page.dart
  main.dart
```

Principais áreas:

- `lib/core/database`: definição do banco SQLite e entidades;
- `lib/core/services`: regras de negócio, cálculos e exportação;
- `lib/features`: telas e fluxos do aplicativo;
- `lib/main.dart`: ponto de entrada da aplicação.

## Fluxo típico de uso

1. Cadastre comunidades e famílias;
2. Defina a estrutura de indicadores e pesos;
3. Inicie uma avaliação para uma família;
4. Responda os itens por categoria;
5. Consulte o resultado calculado e os relatórios;
6. Exporte backups ou dados para análise externa.

## Observações importantes

- O app armazena dados localmente no dispositivo;
- os cálculos de resultado são gerados com base nas notas e nos pesos persistidos no banco de dados;
- a gestão de pesos deve ser realizada diretamente no banco de dados do sistema, e não por alteração manual em arquivos do projeto;
- para alterar ou regenerar arquivos gerados pela arquitetura Drift, utilize `build_runner`;
- backup e restauração devem ser feitos com cuidado para evitar perda de dados.

## Documentação complementar

Este repositório também contém materiais adicionais:

- `FUZZY_SYSTEM.md`: documentação do cálculo fuzzy;
- `MODELAGEM_DADOS.md`: descrição da modelagem de dados;
- `GERENCIAMENTO_PESOS.md`: detalhes de gestão de pesos;

## Licença

Este projeto foi desenvolvido como parte de um trabalho acadêmico e, por padrão, está sem configuração de licença pública definida. 
