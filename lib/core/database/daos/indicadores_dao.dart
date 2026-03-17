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

  /// Retorna indicadores de uma categoria específica
  Future<List<Indicador>> getPorCategoria(int categoriaId) {
    return (select(indicadores)
          ..where((i) => i.categoriaId.equals(categoriaId)))
        .get();
  }

  /// Conta o número total de indicadores
  Future<int> contarTotal() {
    return (select(indicadores)
          ..orderBy([(i) => OrderingTerm(expression: i.id)]))
        .get()
        .then((list) => list.length);
  }

  /// Verifica se existe algum indicador cadastrado
  Future<bool> existeIndicadores() async {
    final count = await contarTotal();
    return count > 0;
  }

  Future<List<(Indicador, Categoria)>> getComCategoria() {
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
