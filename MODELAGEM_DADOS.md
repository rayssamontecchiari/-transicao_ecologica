# Modelagem de dados do projeto

Diagrama baseado nas entidades do domínio e nas tabelas do banco de dados do projeto.

```mermaid
erDiagram
    COMUNIDADE ||--o{ FAMILIA : pertence_a
    CATEGORIA ||--o{ INDICADOR : contem
    CATEGORIA ||--o{ DIMENSAO : possui
    CATEGORIA ||--o{ PRATICA : agrupa
    FAMILIA ||--o{ AVALIACAO : recebe
    AVALIACAO ||--o{ AVALIACAO_ITEM : contem
    INDICADOR ||--o{ AVALIACAO_ITEM : avaliado_em
    PRATICA ||--o{ AVALIACAO_ITEM : usada_em
    AVALIACAO ||--o{ RESULTADO_AVALIACAO : gera

    COMUNIDADE {
        int id PK
        string nome
    }

    FAMILIA {
        int id PK
        string nomeResponsavel
        string telefone
        string endereco
        int comunidadeId FK
    }

    CATEGORIA {
        int id PK
        string nome
        string descricao
    }

    DIMENSAO {
        int id PK
        string nome
        int categoriaId FK
    }

    INDICADOR {
        int id PK
        string nome
        string descricao
        double peso
        int categoriaId FK
        int dimensaoId FK
    }

    PRATICA {
        int id PK
        string nome
        int categoriaId FK
    }

    AVALIACAO {
        int id PK
        int familiaId FK
        datetime data
        string avaliador
        string observacoes
        string status
    }

    AVALIACAO_ITEM {
        int id PK
        int avaliacaoId FK
        int indicadorId FK
        int praticaId FK
        int valorLikert
        double valorFuzzy
    }

    RESULTADO_AVALIACAO {
        int avaliacaoId FK
        int categoriaId FK
        double valorFuzzyFinal
        double sumD
        double sumA
        double sumB
        double sumC
        double centroid
        double base
    }
```

Observações:
- `FuzzyNumber` é um objeto de cálculo auxiliar, não uma entidade persistida;
- os valores fuzzy são armazenados nos itens de avaliação e nos resultados finais.
