import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/categoria_table.dart';

part 'categoria_dao.g.dart';

@DriftAccessor(tables: [Categoria])
class CategoriaDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriaDaoMixin {
  CategoriaDao(super.db);

  /// Retorna uma categoria específica pelo ID
  Future<CategoriaData?> getById(int id) {
    return (select(categoria)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  /// Retorna todas as categorias
  Future<List<CategoriaData>> getTodas() {
    return select(categoria).get();
  }

  /// Conta o número total de categorias
  Future<int> contarTotal() {
    return (select(categoria)..orderBy([(c) => OrderingTerm(expression: c.id)]))
        .get()
        .then((list) => list.length);
  }

  /// Verifica se existe alguma categoria cadastrada
  Future<bool> existeCategorias() async {
    final count = await contarTotal();
    return count > 0;
  }
}
