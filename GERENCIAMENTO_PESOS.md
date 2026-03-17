# Gerenciamento de Pesos dos Indicadores

## 📱 Interface Administrativa (Recomendado)

Acesse a página de gerenciamento:

```dart
// Na página de configurações ou administração:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const GerenciarPesosPage(
      categoriaIdInicial: 1, // Campesinidade
    ),
  ),
);
```

As funcionalidades disponíveis:
- ✅ Visualizar todos os indicadores de uma categoria
- ✅ Editar pesos de forma visual e intuitiva
- ✅ Validação automática (valores entre 0 e 1)
- ✅ Salvar múltiplos pesos simultaneamente
- ✅ Feedback visual de sucesso/erro

---

## 🗄️ Acesso Direto ao Banco de Dados (SQLite)

### Localização do banco:
```
Android: /data/data/com.example.app/databases/
iOS: Application Support/databases/
Windows: AppData/Local/Packages/
```

### Comandos SQL

#### 1️⃣ Visualizar pesos atuais de uma categoria

```sql
SELECT 
  i.id,
  i.nome,
  i.peso,
  i.categoriaId
FROM indicadores i
WHERE i.categoriaId = 1
ORDER BY i.id;
```

#### 2️⃣ Atualizar um peso específico

```sql
UPDATE indicadores
SET peso = 0.8
WHERE id = 2 AND categoriaId = 1;
```

#### 3️⃣ Atualizar todos os pesos de uma categoria de uma vez

**Categoria 1 - Campesinidade:**
```sql
UPDATE indicadores SET peso = CASE id
  WHEN 1 THEN 1.0    -- Energia
  WHEN 2 THEN 0.5    -- Escala
  WHEN 3 THEN 0.8    -- Autossuficiência
  WHEN 4 THEN 0.8    -- Força de trabalho
  WHEN 5 THEN 0.9    -- Agrobiodiversidade
  WHEN 6 THEN 0.7    -- Produtividade ecológica
  WHEN 7 THEN 0.8    -- Multifuncionalidade
  WHEN 8 THEN 0.9    -- Conhecimento
  WHEN 9 THEN 0.6    -- Cosmovisão
END
WHERE categoriaId = 1;
```

#### 4️⃣ Resetar todos os pesos para 1.0

```sql
UPDATE indicadores SET peso = 1.0 WHERE categoriaId = 1;
```

#### 5️⃣ Listar todas as categorias e seus indicadores

```sql
SELECT 
  c.id as categoria_id,
  c.nome as categoria,
  i.id,
  i.nome as indicador,
  i.peso
FROM categorias c
LEFT JOIN indicadores i ON c.id = i.categoriaId
ORDER BY c.id, i.id;
```

#### 6️⃣ Buscar indicadores com peso menor que um valor

```sql
SELECT 
  i.id,
  i.nome,
  i.peso,
  c.nome as categoria
FROM indicadores i
JOIN categorias c ON i.categoriaId = c.id
WHERE i.peso < 0.7
ORDER BY i.peso;
```

---

## ⚙️ Como acessar o banco via ferramentas

### Android Studio
```
1. View → Tool Windows → Device File Explorer
2. /data/data/com.example.app/databases/
3. Clique direito → Save As
```

### VS Code (SQLite Extension)
```
1. Instale: "SQLite" (alexcvzz)
2. Abra a paleta de comandos (Ctrl+Shift+P)
3. SQLite: Open Database
4. Selecione o arquivo .db
```

### DBeaver (Recomendado)
```
1. Baixe em: https://dbeaver.io/
2. Crie nova conexão → SQLite
3. Selecione o arquivo de banco
4. Acesse a tabela "indicadores"
```

---

## 📊 Estrutura da tabela `indicadores`

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | INTEGER PRIMARY KEY | ID único do indicador |
| nome | TEXT | Nome do indicador |
| descricao | TEXT | Descrição detalhada |
| peso | REAL DEFAULT 1.0 | **Peso do indicador (0.0 - 1.0)** |
| categoria_id | INTEGER | Referência à categoria |
| dimensao_id | INTEGER (nullable) | Referência à dimensão (se aplicável) |

---

## ⚠️ Validações Importantes

✅ **Pesos válidos:** 0.0 a 1.0 (reais/decimais)
❌ **Evitar:** Pesos negativos ou maiores que 1.0
❌ **Evitar:** Deixar pesos como NULL (usar 1.0 como padrão)

---

## 🔄 Workflow Recomendado

1. **Para pequenos ajustes:** Use a interface em `GerenciarPesosPage`
2. **Para ajustes em massa:** Use SQL direto no banco
3. **Sempre teste:** Execute uma avaliação após alterar pesos para verificar impacto

---

## 📝 Histórico de Pesos (Auditoria)

Para rastrear mudanças, seria ideal adicionar logging. Por enquanto, faça backup antes de grandes alterações:

```sql
-- Backup dos pesos atuais
CREATE TABLE indicadores_backup AS SELECT * FROM indicadores;

-- Depois faça as alterações
UPDATE indicadores SET peso = ...;

-- Se precisar reverter:
UPDATE indicadores SET peso = (SELECT peso FROM indicadores_backup WHERE indicadores_backup.id = indicadores.id);
```

