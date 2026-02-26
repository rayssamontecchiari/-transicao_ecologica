import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/daos/avaliacoes_dao.dart';
import '../database/daos/indicadores_dao.dart';

class AvaliacaoService {
  final AvaliacoesDao _avaliacoesDao;
  final IndicadoresDao _indicadoresDao;

  AvaliacaoService(AppDatabase db)
      : _avaliacoesDao = AvaliacoesDao(db),
        _indicadoresDao = IndicadoresDao(db);

  /// Cria uma nova avaliação com seus itens
  Future<void> criarAvaliacao({
    required int familiaId,
    required String avaliador,
    String? observacoes,
    required Map<int, int> respostasLikert,
    // indicadorId -> valorLikert
  }) async {
    await _avaliacoesDao.transaction(() async {
      final avaliacaoId = await _avaliacoesDao.inserirAvaliacao(
        AvaliacoesCompanion.insert(
          familiaId: familiaId,
          avaliador: avaliador,
          observacoes: Value(observacoes),
        ),
      );

      final itens = respostasLikert.entries.map((entry) {
        return AvaliacaoItensCompanion.insert(
          avaliacaoId: avaliacaoId,
          indicadorId: entry.key,
          valorLikert: Value(entry.value),
        );
      }).toList();

      await _avaliacoesDao.inserirItens(itens);
    });
  }
}
