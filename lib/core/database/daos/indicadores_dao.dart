import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/indicadores_table.dart';
import '../tables/categorias_table.dart';

part 'indicadores_dao.g.dart';

@DriftAccessor(tables: [Indicadores, Categorias])
class IndicadoresDao extends DatabaseAccessor<AppDatabase>
    with _$IndicadoresDaoMixin {
  IndicadoresDao(AppDatabase db) : super(db);

  Future<void> atualizarPeso(int id, double novoPeso) {
    return (update(indicadores)..where((i) => i.id.equals(id)))
        .write(IndicadoresCompanion(peso: Value(novoPeso)));
  }

  Future<List<Indicadore>> getPorCategoria(int categoriaId) {
    return (select(indicadores)
          ..where((i) => i.categoriaId.equals(categoriaId)))
        .get();
  }

  Future<List<(Indicadore, Categoria)>> getComCategoria() {
    final query = select(indicadores).join([
      innerJoin(
        categorias,
        categorias.id.equalsExp(indicadores.categoriaId),
      ),
    ]);

    return query.map((row) {
      return (
        row.readTable(indicadores),
        row.readTable(categorias),
      );
    }).get();
  }
}
