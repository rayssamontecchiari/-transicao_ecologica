## Sistema de Cálculo Fuzzy para Avaliações

### Estrutura Implementada

O sistema implementa lógica fuzzy para calcular resultados finais de avaliações, armazenando valores separados por categoria.

#### Classes Principais

##### 1. **FuzzyNumber** (`lib/core/models/fuzzy_number.dart`)
Representa um número fuzzy triangular com componentes (d, a, b, c):
- `d`: ponto esquerdo do triângulo
- `a`, `b`: picos do triângulo
- `c`: ponto direito do triângulo
- `weight`: peso do indicador

```dart
class FuzzyNumber {
  final double d;
  final double a;
  final double b;
  final double c;
  final double weight;

  /// Aplica o peso ao número fuzzy
  FuzzyNumber applyWeight() { ... }

  /// Calcula centróide: (a + b) / 2
  double getCentroid() { ... }

  /// Calcula base: c - d
  double getBase() { ... }
}
```

##### 2. **FuzzyCalculator** (`lib/core/services/fuzzy_calculator.dart`)
Implementa o cálculo fuzzy conforme a tabela de mapeamento:

| Nota | d    | a    | b    | c    |
|------|------|------|------|------|
| 0    | 0.0  | 0.0  | 0.0  | 0.0  |
| 1    | 0.0  | 0.0  | 0.1  | 0.3  |
| 2    | 0.1  | 0.3  | 0.3  | 0.5  |
| 3    | 0.3  | 0.5  | 0.5  | 0.7  |
| 4    | 0.5  | 0.7  | 0.7  | 0.9  |
| 5    | 0.7  | 0.9  | 1.0  | 1.0  |

**Método:** `calcularPorNotas(List<int> notas, List<double> pesos)`

**Processo:**
1. Para cada nota, obter o triângulo fuzzy correspondente
2. Aplicar o peso do indicador: multiplicar (d, a, b, c) × peso
3. Somar todos os d, a, b, c ponderados
4. Calcular defuzzificação pelo centróide:
   - **Centróide = (∑a + ∑b) / 2**
   - **Base = ∑c - ∑d**
   - **Resultado final = Centróide × 10** (normalizado para 0-10)

##### 3. **ResultadoAvaliacao** (`lib/core/models/resultado_avaliacao.dart`)
Armazena resultado de uma avaliação por categoria:

```dart
class ResultadoAvaliacao {
  final int avaliacaoId;
  final int categoriaId;
  final double valorFuzzyFinal;      // Valor normalizado (0-10)
  
  // Detalhes do cálculo
  final double sumD, sumA, sumB, sumC;
  final double centroid;
  final double base;
}
```

##### 4. **ResultadoAvaliacaoService** (`lib/core/services/resultado_avaliacao_service.dart`)
Serviço que orquestra o cálculo para avaliações:

- `calcularResultadoCategoria()`: Calcula para uma categoria
- `calcularResultadosCompletos()`: Calcula para todas as 4 categorias
- `obterEstatisticasAvaliacao()`: Obtém média, mín, máx dos resultados

### Como Usar

#### 1. Calcular resultado de uma avaliação

```dart
final db = await AppDatabase.instance();
final service = ResultadoAvaliacaoService(db);

// Resultado de uma categoria
final resultado = await service.calcularResultadoCategoria(
  avaliacaoId: 1,
  categoriaId: 2,
);

print('Valor: ${resultado?.valorFuzzyFinal}');
```

#### 2. Obter estatísticas completas

```dart
final stats = await service.obterEstatisticasAvaliacao(1);

print('Média: ${stats['media']}');
print('Mínima: ${stats['minValor']}');
print('Máxima: ${stats['maxValor']}');
```

#### 3. Exibir resultados na UI

Integrar com `ResultadosAvaliacaoPage`:

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => ResultadosAvaliacaoPage(avaliacaoId: 1),
  ),
);
```

### Exemplo de Cálculo

**Cenário:** Avaliação da categoria 1 com 3 indicadores

| Indicador | Nota | Peso | d    | a    | b    | c    | d×p  | a×p  | b×p  | c×p  |
|-----------|------|------|------|------|------|------|------|------|------|------|
| 1         | 5    | 1.0  | 0.7  | 0.9  | 1.0  | 1.0  | 0.7  | 0.9  | 1.0  | 1.0  |
| 2         | 4    | 1.0  | 0.5  | 0.7  | 0.7  | 0.9  | 0.5  | 0.7  | 0.7  | 0.9  |
| 3         | 3    | 0.8  | 0.3  | 0.5  | 0.5  | 0.7  | 0.24 | 0.4  | 0.4  | 0.56 |
| **SOMA**  |      |      |      |      |      |      | 1.44 | 2.0  | 2.1  | 2.46 |

**Cálculo:**
- Centróide = (2.0 + 2.1) / 2 = **2.05**
- Base = 2.46 - 1.44 = **1.02**
- Resultado Final = 2.05 × 10 = **20.5** → normalizado para **10.0**
- Interpretação: "Muito Bom"

### Integração com Fluxo de Avaliação

Após salvar todas as categorias, a avaliação pode ir direto para a página de resultados:

```dart
// Em iniciar_avaliacao_page.dart
if (_categoriaAtual >= _totalCategorias) {
  // Mostrar resultados
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ResultadosAvaliacaoPage(
        avaliacaoId: avaliacaoIdSalvo,
      ),
    ),
  );
}
```

### Escala de Interpretação

| Valor | Interpretação |
|-------|---------------|
| ≥ 8.0 | Muito Bom    |
| ≥ 6.0 | Bom          |
| ≥ 4.0 | Regular      |
| ≥ 2.0 | Ruim         |
| < 2.0 | Muito Ruim   |

### Armazenamento

Os resultados fuzzy são calculados **sob demanda** a partir dos dados salvos em `avaliacao_itens`:
- `valorLikert`: nota de 1-5 do indicador
- `peso`: peso do indicador (armazenado em `indicadores`)

Não há tabela separada no banco - o cálculo ocorre via serviço quando necessário.
