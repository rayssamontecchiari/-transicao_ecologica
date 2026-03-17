import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/avaliacoes_table.dart';
import '../tables/avaliacao_itens_table.dart';

part 'avaliacoes_dao.g.dart';

@DriftAccessor(tables: [Avaliacoes, AvaliacaoItens])
class AvaliacoesDao extends DatabaseAccessor<AppDatabase>
    with _$AvaliacoesDaoMixin {
  AvaliacoesDao(AppDatabase db) : super(db);

  Future<int> inserirAvaliacao(AvaliacoesCompanion avaliacao) {
    return into(avaliacoes).insert(avaliacao);
  }

  Future<void> inserirItens(List<AvaliacaoItensCompanion> itens) async {
    await batch((batch) {
      batch.insertAll(avaliacaoItens, itens);
    });
  }

  Future<List<Avaliacao>> getPorFamilia(int familiaId) {
    return (select(avaliacoes)
          ..where((a) => a.familiaId.equals(familiaId))
          ..orderBy([(a) => OrderingTerm.desc(a.data)]))
        .get();
  }

  Future<List<AvaliacaoItem>> getItensPorAvaliacao(int avaliacaoId) {
    return (select(avaliacaoItens)
          ..where((a) => a.avaliacaoId.equals(avaliacaoId)))
        .get();
  }

  Future<void> deletarAvaliacao(int avaliacaoId) async {
    await transaction(() async {
      // Deletar itens associados
      await (delete(avaliacaoItens)
            ..where((a) => a.avaliacaoId.equals(avaliacaoId)))
          .go();
      // Deletar avaliação
      await (delete(avaliacoes)..where((a) => a.id.equals(avaliacaoId))).go();
    });
  }
}
