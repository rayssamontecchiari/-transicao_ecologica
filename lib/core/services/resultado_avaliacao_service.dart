import '../database/app_database.dart';
import '../models/resultado_avaliacao.dart';
import 'fuzzy_calculator.dart';
import 'resultado_cache_service.dart';

/// Serviço para cálculo dos resultados das avaliações usando lógica fuzzy
class ResultadoAvaliacaoService {
  final AppDatabase _db;
  final ResultadoCacheService _cacheService = ResultadoCacheService();

  ResultadoAvaliacaoService(this._db);

  static int calcularNotaPratica({
    required int marcacoes,
    required int totalAspectos,
  }) {
    if (totalAspectos <= 0) return 0;
    if (marcacoes <= 0) return 0;
    if (marcacoes >= totalAspectos) return 5;

    final proporcao = marcacoes / totalAspectos;
    return (proporcao * 5.0).round().clamp(0, 5);
  }

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
        // Na categoria 2, cada prática recebe uma nota com base na quantidade de
        // aspectos norteadores selecionados dentro dela. A regra é: para cada
        // prática, a pontuação final é proporcional ao número de aspectos
        // marcados em relação ao total de aspectos da categoria (6). Isso reflete
        // a lógica descrita no trabalho, em que cada resposta positiva vale 1 ponto
        // dentro da prática.
        final praticasDaCategoria = await (_db.select(_db.pratica)
              ..where((p) => p.categoriaId.equals(categoriaId)))
            .get();
        final totalAspectos = indicadores.length;

        for (final pratica in praticasDaCategoria) {
          final marcacoes = itensDaCategoria
              .where((item) => item.praticaId == pratica.id)
              .map((item) => item.indicadorId)
              .toSet()
              .length;

          final nota = calcularNotaPratica(
            marcacoes: marcacoes,
            totalAspectos: totalAspectos,
          );

          notas.add(nota);
          pesos.add(1.0);
          print(
            '[DEBUG] Categoria 2 - Prática ${pratica.id}: marcacoes=$marcacoes/$totalAspectos -> nota=$nota',
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
