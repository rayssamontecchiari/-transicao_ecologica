import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/avaliacao_table.dart';
import '../tables/avaliacao_item_table.dart';

part 'avaliacao_dao.g.dart';

@DriftAccessor(tables: [Avaliacao, AvaliacaoItem])
class AvaliacaoDao extends DatabaseAccessor<AppDatabase>
    with _$AvaliacaoDaoMixin {
  AvaliacaoDao(super.db);

  Future<int> inserirAvaliacao(AvaliacaoCompanion data) {
    return into(avaliacao).insert(data);
  }

  Future<void> inserirItens(List<AvaliacaoItemCompanion> itens) async {
    await batch((batch) {
      batch.insertAll(avaliacaoItem, itens);
    });
  }

  Future<List<AvaliacaoData>> getPorFamilia(int familiaId) {
    return (select(avaliacao)
          ..where((a) => a.familiaId.equals(familiaId))
          ..orderBy([(a) => OrderingTerm.desc(a.data)]))
        .get();
  }

  Future<List<AvaliacaoItemData>> getItensPorAvaliacao(int avaliacaoId) {
    return (select(avaliacaoItem)
          ..where((a) => a.avaliacaoId.equals(avaliacaoId)))
        .get();
  }

  Future<void> deletarAvaliacao(int avaliacaoId) async {
    await transaction(() async {
      await (delete(avaliacaoItem)
            ..where((a) => a.avaliacaoId.equals(avaliacaoId)))
          .go();

      await (delete(avaliacao)..where((a) => a.id.equals(avaliacaoId))).go();
    });
  }

  Future<bool> atualizarAvaliacao(int id, AvaliacaoCompanion data) {
    return (update(avaliacao)..where((a) => a.id.equals(id))).replace(data);
  }

  Future<void> atualizarItensAvaliacao(
    int avaliacaoId,
    List<AvaliacaoItemCompanion> itens,
  ) async {
    await transaction(() async {
      await (delete(avaliacaoItem)
            ..where((a) => a.avaliacaoId.equals(avaliacaoId)))
          .go();

      if (itens.isNotEmpty) {
        await batch((batch) {
          batch.insertAll(avaliacaoItem, itens);
        });
      }
    });
  }
}
