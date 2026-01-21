import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/categorias_table.dart';

part 'categorias_dao.g.dart';

@DriftAccessor(tables: [Categorias])
class CategoriasDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriasDaoMixin {

  CategoriasDao(AppDatabase db) : super(db);

  Future<List<Categoria>> getTodas() {
    return select(categorias).get();
  }
}
