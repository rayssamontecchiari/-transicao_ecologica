import '../database/app_database.dart';
import '../models/resultado_avaliacao.dart';
import 'fuzzy_calculator.dart';
import 'resultado_cache_service.dart';

/// Serviço para cálculo dos resultados das avaliações usando lógica fuzzy
class ResultadoAvaliacaoService {
  final AppDatabase _db;
  final ResultadoCacheService _cacheService = ResultadoCacheService();

  ResultadoAvaliacaoService(this._db);

  /// Calcula o resultado fuzzy de uma avaliação por categoria
  Future<ResultadoAvaliacao?> calcularResultadoCategoria({
    required int avaliacaoId,
    required int categoriaId,
  }) async {
    try {
      final indicadores = await (_db.select(_db.indicador)
            ..where((i) => i.categoriaId.equals(categoriaId)))
          .get();

      if (indicadores.isEmpty) return null;

      final itens = await (_db.select(_db.avaliacaoItem)
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

      if (categoriaId == 2) {
        // Na categoria 2, cada marcacao gera uma linha (pratica x indicador)
        // com valorLikert=1. Consolidamos isso em uma unica nota 0..5 por
        // indicador antes do calculo fuzzy.
        final praticasDaCategoria = await (_db.select(_db.pratica)
              ..where((p) => p.categoriaId.equals(categoriaId)))
            .get();
        final totalPraticas = praticasDaCategoria.length;

        final marcacoesPorIndicador = <int, int>{};
        for (final item in itensDaCategoria) {
          if (item.valorLikert == null || item.valorLikert == 0) continue;
          marcacoesPorIndicador.update(
            item.indicadorId,
            (v) => v + 1,
            ifAbsent: () => 1,
          );
        }

        for (final indicador in indicadores) {
          final marcacoes = marcacoesPorIndicador[indicador.id] ?? 0;
          int nota;

          if (marcacoes == 0 || totalPraticas == 0) {
            nota = 0;
          } else {
            final proporcao = marcacoes / totalPraticas;
            nota = (proporcao * 5.0).round().clamp(1, 5);
          }

          notas.add(nota);
          pesos.add(indicador.peso);
          print(
            '[DEBUG] Categoria 2 - Indicador ${indicador.id}: marcacoes=$marcacoes/$totalPraticas -> nota=$nota',
          );
        }
      } else {
        for (final item in itensDaCategoria) {
          if (item.valorLikert != null) {
            final indicador =
                indicadores.firstWhere((i) => i.id == item.indicadorId);

            notas.add(item.valorLikert!);
            pesos.add(indicador.peso);
          }
        }
      }

      if (notas.isEmpty) return null;

      print('[DEBUG] Categoria $categoriaId - Notas: $notas, Pesos: $pesos');

      final fuzzyResult = FuzzyCalculator.calcularPorNotas(notas, pesos);

      print('[DEBUG] Resultado Fuzzy: $fuzzyResult');

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
      final avaliacao = await (_db.select(_db.avaliacao)
            ..where((a) => a.id.equals(avaliacaoId)))
          .getSingleOrNull();

      if (avaliacao == null) return [];

      final configVersion = await _cacheService.obterVersaoConfiguracao();

      final resultadosCache = await _cacheService.obterResultadosSeValidos(
        avaliacaoId: avaliacaoId,
        dataAlteracao: avaliacao.dataAlteracao,
        configVersion: configVersion,
      );

      if (resultadosCache != null) {
        return resultadosCache;
      }

      final categorias = await _db.select(_db.categoria).get();
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

      await _cacheService.salvarResultados(
        avaliacaoId: avaliacaoId,
        dataAlteracao: avaliacao.dataAlteracao,
        configVersion: configVersion,
        resultados: resultados,
      );

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
