import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/categorias_table.dart';

part 'categorias_dao.g.dart';

@DriftAccessor(tables: [Categorias])
class CategoriasDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriasDaoMixin {
  CategoriasDao(AppDatabase db) : super(db);

  /// Retorna uma categoria específica pelo ID
  Future<Categoria?> getById(int id) {
    return (select(categorias)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  /// Retorna todas as categorias
  Future<List<Categoria>> getTodas() {
    return select(categorias).get();
  }

  /// Conta o número total de categorias
  Future<int> contarTotal() {
    return (select(categorias)
          ..orderBy([(c) => OrderingTerm(expression: c.id)]))
        .get()
        .then((list) => list.length);
  }

  /// Verifica se existe alguma categoria cadastrada
  Future<bool> existeCategorias() async {
    final count = await contarTotal();
    return count > 0;
  }
}
