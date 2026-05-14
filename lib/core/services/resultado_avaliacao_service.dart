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
      final indicadores = await (_db.select(_db.indicadores)
            ..where((i) => i.categoriaId.equals(categoriaId)))
          .get();

      if (indicadores.isEmpty) return null;

      final itens = await (_db.select(_db.avaliacaoItens)
            ..where((ai) => ai.avaliacaoId.equals(avaliacaoId)))
          .get();

      final indicadorIds = indicadores.map((i) => i.id).toSet();

      final itensDaCategoria = itens
          .where((item) => indicadorIds.contains(item.indicadorId))
          .toList();

      if (itensDaCategoria.isEmpty) return null;

      print('[DEBUG] Categoria $categoriaId - Itens recuperados:');
      for (final item in itensDaCategoria) {
        print(
            '  - Indicador ${item.indicadorId}: valorLikert=${item.valorLikert}');
      }

      final notas = <int>[];
      final pesos = <double>[];

      for (final item in itensDaCategoria) {
        if (item.valorLikert != null) {
          final indicador =
              indicadores.firstWhere((i) => i.id == item.indicadorId);

          notas.add(item.valorLikert!);
          pesos.add(indicador.peso);
        }
      }

      if (notas.isEmpty) return null;

      print('[DEBUG] Categoria $categoriaId - Notas: $notas, Pesos: $pesos');

      final fuzzyResult = FuzzyCalculator.calcularPorNotas(notas, pesos);

      print('[DEBUG] Resultado Fuzzy: $fuzzyResult');

      final valor = fuzzyResult['resultado'] ?? 0.0;

      return ResultadoAvaliacao.fromCalculation(
        avaliacaoId: avaliacaoId,
        categoriaId: categoriaId,
        fuzzyResult: fuzzyResult,
      );
    } catch (e) {
      // Erro ao calcular resultado
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
      // Erro ao calcular resultados completos
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
      };
    } catch (e) {
      print('Erro ao obter estatísticas: $e');
      return {};
    }
  }
}
