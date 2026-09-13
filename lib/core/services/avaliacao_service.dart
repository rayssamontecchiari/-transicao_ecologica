import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/daos/avaliacao_dao.dart';
import 'resultado_cache_service.dart';

class AvaliacaoService {
  final AvaliacaoDao _avaliacaoDao;
  final ResultadoCacheService _cacheService = ResultadoCacheService();

  AvaliacaoService(AppDatabase db) : _avaliacaoDao = AvaliacaoDao(db);

  DateTime _normalizarMesAno(DateTime data) {
    return DateTime(data.year, data.month, 1);
  }

  Future<void> criarAvaliacao({
    required int familiaId,
    required String avaliador,
    String? observacoes,
    DateTime? dataAvaliacao,
    Map<int, int>? respostasLikert,
    Map<int, Set<int>>? itensPorPratica,
  }) async {
    await _avaliacaoDao.transaction(() async {
      final avaliacaoId = await _avaliacaoDao.inserirAvaliacao(
        AvaliacaoCompanion.insert(
          familiaId: familiaId,
          avaliador: avaliador,
          data: Value(
            _normalizarMesAno(dataAvaliacao ?? DateTime.now()),
          ),
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

  Future<void> deletarAvaliacao(int avaliacaoId) async {
    await _avaliacaoDao.deletarAvaliacao(avaliacaoId);
    await _cacheService.removerResultadosDaAvaliacao(avaliacaoId);
  }

  Future<void> atualizarAvaliacao({
    required int avaliacaoId,
    required int familiaId,
    required String avaliador,
    String? observacoes,
    DateTime? dataAvaliacao,
    Map<int, int>? respostasLikert,
    Map<int, Set<int>>? itensPorPratica,
  }) async {
    await _avaliacaoDao.transaction(() async {
      await _avaliacaoDao.atualizarAvaliacao(
        avaliacaoId,
        AvaliacaoCompanion(
          familiaId: Value(familiaId),
          avaliador: Value(avaliador),
          data: Value(
            _normalizarMesAno(dataAvaliacao ?? DateTime.now()),
          ),
          observacoes: Value(observacoes),
          dataAlteracao: Value(DateTime.now()),
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
