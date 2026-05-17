import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/daos/avaliacao_dao.dart';

class AvaliacaoService {
  final AvaliacaoDao _avaliacaoDao;

  AvaliacaoService(AppDatabase db) : _avaliacaoDao = AvaliacaoDao(db);

  Future<void> criarAvaliacao({
    required int familiaId,
    required String avaliador,
    String? observacoes,
    Map<int, int>? respostasLikert,
    Map<int, Set<int>>? itensPorPratica,
  }) async {
    await _avaliacaoDao.transaction(() async {
      final avaliacaoId = await _avaliacaoDao.inserirAvaliacao(
        AvaliacaoCompanion.insert(
          familiaId: familiaId,
          avaliador: avaliador,
          observacoes: Value(observacoes),
        ),
      );

      final itens = <AvaliacaoItemCompanion>[];

      if (itensPorPratica != null) {
        for (final entry in itensPorPratica.entries) {
          final praticaId = entry.key;

          for (final indicadorId in entry.value) {
            itens.add(
              AvaliacaoItemCompanion.insert(
                avaliacaoId: avaliacaoId,
                indicadorId: indicadorId,
                praticaId: Value(praticaId),
                valorLikert: const Value(1),
              ),
            );
          }
        }
      } else if (respostasLikert != null) {
        itens.addAll(
          respostasLikert.entries.map((entry) {
            return AvaliacaoItemCompanion.insert(
              avaliacaoId: avaliacaoId,
              indicadorId: entry.key,
              valorLikert: Value(entry.value),
            );
          }),
        );
      }

      if (itens.isNotEmpty) {
        await _avaliacaoDao.inserirItens(itens);
      }
    });
  }

  Future<List<AvaliacaoData>> getAvaliacoesPorFamilia(
    int familiaId,
  ) {
    return _avaliacaoDao.getPorFamilia(familiaId);
  }

  Future<List<AvaliacaoItemData>> getItensPorAvaliacao(
    int avaliacaoId,
  ) {
    return _avaliacaoDao.getItensPorAvaliacao(avaliacaoId);
  }

  Future<void> deletarAvaliacao(int avaliacaoId) {
    return _avaliacaoDao.deletarAvaliacao(avaliacaoId);
  }

  Future<void> atualizarAvaliacao({
    required int avaliacaoId,
    required int familiaId,
    required String avaliador,
    String? observacoes,
    Map<int, int>? respostasLikert,
    Map<int, Set<int>>? itensPorPratica,
  }) async {
    await _avaliacaoDao.transaction(() async {
      await _avaliacaoDao.atualizarAvaliacao(
        avaliacaoId,
        AvaliacaoCompanion(
          familiaId: Value(familiaId),
          avaliador: Value(avaliador),
          observacoes: Value(observacoes),
        ),
      );

      final itens = <AvaliacaoItemCompanion>[];

      if (itensPorPratica != null) {
        for (final entry in itensPorPratica.entries) {
          final praticaId = entry.key;

          for (final indicadorId in entry.value) {
            itens.add(
              AvaliacaoItemCompanion.insert(
                avaliacaoId: avaliacaoId,
                indicadorId: indicadorId,
                praticaId: Value(praticaId),
                valorLikert: const Value(1),
              ),
            );
          }
        }
      } else if (respostasLikert != null) {
        itens.addAll(
          respostasLikert.entries.map((entry) {
            return AvaliacaoItemCompanion.insert(
              avaliacaoId: avaliacaoId,
              indicadorId: entry.key,
              valorLikert: Value(entry.value),
            );
          }),
        );
      }

      await _avaliacaoDao.atualizarItensAvaliacao(
        avaliacaoId,
        itens,
      );
    });
  }
}
