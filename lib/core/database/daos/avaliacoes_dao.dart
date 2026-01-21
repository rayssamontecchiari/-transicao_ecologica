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

  Future<List<Avaliacoe>> getPorFamilia(int familiaId) {
    return (select(avaliacoes)
          ..where((a) => a.familiaId.equals(familiaId))
          ..orderBy([(a) => OrderingTerm.desc(a.data)]))
        .get();
  }
}
