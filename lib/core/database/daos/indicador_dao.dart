import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/indicador_table.dart';
import '../tables/categoria_table.dart';

part 'indicador_dao.g.dart';

@DriftAccessor(tables: [Indicador, Categoria])
class IndicadorDao extends DatabaseAccessor<AppDatabase>
    with _$IndicadorDaoMixin {
  IndicadorDao(super.db);

  Future<void> atualizarPeso(int id, double novoPeso) {
    return (update(indicador)..where((i) => i.id.equals(id)))
        .write(IndicadorCompanion(peso: Value(novoPeso)));
  }

  Future<List<IndicadorData>> getPorCategoria(int categoriaId) {
    return (select(indicador)..where((i) => i.categoriaId.equals(categoriaId)))
        .get();
  }

  Future<int> contarTotal() {
    return (select(indicador)..orderBy([(i) => OrderingTerm(expression: i.id)]))
        .get()
        .then((list) => list.length);
  }

  Future<bool> existeIndicadores() async {
    final count = await contarTotal();
    return count > 0;
  }

  Future<List<(IndicadorData, CategoriaData)>> getComCategoria() {
    final query = select(indicador).join([
      innerJoin(
        categoria,
        categoria.id.equalsExp(indicador.categoriaId),
      ),
    ]);

    return query.map((row) {
      return (
        row.readTable(indicador),
        row.readTable(categoria),
      );
    }).get();
  }
}
