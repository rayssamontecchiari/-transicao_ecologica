import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/daos/avaliacoes_dao.dart';
import 'package:drift/drift.dart';

class AvaliacaoService {
  final AvaliacoesDao _avaliacoesDao;

  AvaliacaoService(AppDatabase db) : _avaliacoesDao = AvaliacoesDao(db);

  /// Cria uma nova avaliação com itens tradicionais, onde cada indicador
  /// recebe uma nota Likert (1–5).
  ///
  /// Use [respostasLikert] para a maioria das categorias. Para a categoria de
  /// "Análise Multidimensional" você pode fornecer [itensPorPratica] em vez
  /// de [respostasLikert]; nesse caso o parâmetro [respostasLikert] é
  /// ignorado. O mapa em [itensPorPratica] tem chave `praticaId` e valor com um
  /// conjunto de IDs de indicadores observados — cada item recebe automaticamente
  /// `valorLikert = 1`.
  Future<void> criarAvaliacao({
    required int familiaId,
    required String avaliador,
    String? observacoes,
    Map<int, int>? respostasLikert,
    Map<int, Set<int>>? itensPorPratica,
  }) async {
    await _avaliacoesDao.transaction(() async {
      final avaliacaoId = await _avaliacoesDao.inserirAvaliacao(
        AvaliacoesCompanion.insert(
          familiaId: familiaId,
          avaliador: avaliador,
          observacoes: Value(observacoes),
        ),
      );

      final itens = <AvaliacaoItensCompanion>[];

      if (itensPorPratica != null) {
        // for each practice, create an item per indicador with valorLikert = 1
        for (final entry in itensPorPratica.entries) {
          final praticaId = entry.key;
          for (final indicadorId in entry.value) {
            itens.add(AvaliacaoItensCompanion.insert(
              avaliacaoId: avaliacaoId,
              indicadorId: indicadorId,
              praticaId: Value(praticaId),
              valorLikert: const Value(1),
            ));
          }
        }
      } else if (respostasLikert != null) {
        itens.addAll(respostasLikert.entries.map((entry) {
          return AvaliacaoItensCompanion.insert(
            avaliacaoId: avaliacaoId,
            indicadorId: entry.key,
            valorLikert: Value(entry.value),
          );
        }));
      }

      if (itens.isNotEmpty) {
        await _avaliacoesDao.inserirItens(itens);
      }
    });
  }

  /// Obtém todas as avaliações de uma família
  Future<List<Avaliacao>> getAvaliacoesPorFamilia(int familiaId) {
    return _avaliacoesDao.getPorFamilia(familiaId);
  }

  /// Obtém itens de uma avaliação específica
  Future<List<AvaliacaoItem>> getItensPorAvaliacao(int avaliacaoId) {
    return _avaliacoesDao.getItensPorAvaliacao(avaliacaoId);
  }

  /// Deleta uma avaliação e seus itens associados
  Future<void> deletarAvaliacao(int avaliacaoId) {
    return _avaliacoesDao.deletarAvaliacao(avaliacaoId);
  }
}
