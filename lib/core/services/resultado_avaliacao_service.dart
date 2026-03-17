import '../database/app_database.dart';
import '../models/resultado_avaliacao.dart';
import 'fuzzy_calculator.dart';

/// Serviço para cálculo dos resultados das avaliações usando lógica fuzzy
class ResultadoAvaliacaoService {
  final AppDatabase _db;

  ResultadoAvaliacaoService(this._db);

  /// Calcula o resultado fuzzy de uma avaliação por categoria
  Future<ResultadoAvaliacao?> calcularResultadoCategoria({
    required int avaliacaoId,
    required int categoriaId,
  }) async {
    try {
      // Recuperar indicadores da categoria
      final indicadores = await (_db.select(_db.indicadores)
            ..where((i) => i.categoriaId.equals(categoriaId)))
          .get();

      if (indicadores.isEmpty) return null;

      // Recuperar itens de avaliação (respostas)
      final itens = await (_db.select(_db.avaliacaoItens)
            ..where((ai) => ai.avaliacaoId.equals(avaliacaoId)))
          .get();

      // Filtrar itens que pertencem a indicadores desta categoria
      final indicadorIds = indicadores.map((i) => i.id).toSet();
      final itensDaCategoria = itens
          .where((item) => indicadorIds.contains(item.indicadorId))
          .toList();

      if (itensDaCategoria.isEmpty) return null;

      // Montar lista de notas e pesos
      final notas = <int>[];
      final pesos = <double>[];

      for (final item in itensDaCategoria) {
        if (item.valorLikert != null) {
          // Modo Likert: usar a nota diretamente
          notas.add(item.valorLikert!);

          // Encontrar o indicador para pegar o peso
          final indicador =
              indicadores.firstWhere((i) => i.id == item.indicadorId);
          pesos.add(indicador.peso);
        }
      }

      if (notas.isEmpty) return null;

      // Calcular resultado fuzzy
      final fuzzyResult = FuzzyCalculator.calcularPorNotas(notas, pesos);
      final valor = fuzzyResult['resultado'] ?? 0.0;
      final interpretacao = FuzzyCalculator.interpretarResultado(valor);

      return ResultadoAvaliacao.fromCalculation(
        avaliacaoId: avaliacaoId,
        categoriaId: categoriaId,
        fuzzyResult: fuzzyResult,
        interpretacao: interpretacao,
      );
    } catch (e) {
      print('Erro ao calcular resultado: $e');
      return null;
    }
  }

  /// Calcula os resultados fuzzy para todas as categorias de uma avaliação
  Future<List<ResultadoAvaliacao>> calcularResultadosCompletos(
    int avaliacaoId,
  ) async {
    try {
      final categorias = await _db.select(_db.categorias).get();
      final resultados = <ResultadoAvaliacao>[];

      for (final categoria in categorias) {
        final resultado = await calcularResultadoCategoria(
          avaliacaoId: avaliacaoId,
          categoriaId: categoria.id,
        );

        if (resultado != null) {
          resultados.add(resultado);
        }
      }

      return resultados;
    } catch (e) {
      print('Erro ao calcular resultados completos: $e');
      return [];
    }
  }

  /// Obter estatísticas consolidadas de uma avaliação
  Future<Map<String, dynamic>> obterEstatisticasAvaliacao(
    int avaliacaoId,
  ) async {
    try {
      final resultados = await calcularResultadosCompletos(avaliacaoId);

      if (resultados.isEmpty) return {};

      final valores = resultados.map((r) => r.valorFuzzyFinal).toList();
      final media = valores.isNotEmpty
          ? valores.reduce((a, b) => a + b) / valores.length
          : 0.0;

      final minValor =
          valores.isNotEmpty ? valores.reduce((a, b) => a < b ? a : b) : 0.0;

      final maxValor =
          valores.isNotEmpty ? valores.reduce((a, b) => a > b ? a : b) : 0.0;

      return {
        'resultados': resultados,
        'media': media,
        'minValor': minValor,
        'maxValor': maxValor,
        'totalCategorias': resultados.length,
        'interpretacaoMedia': FuzzyCalculator.interpretarResultado(media),
      };
    } catch (e) {
      print('Erro ao obter estatísticas: $e');
      return {};
    }
  }
}
