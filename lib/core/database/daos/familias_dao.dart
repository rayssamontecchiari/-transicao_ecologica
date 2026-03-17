import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/familias_table.dart';

part 'familias_dao.g.dart';

@DriftAccessor(tables: [Familias])
class FamiliasDao extends DatabaseAccessor<AppDatabase>
    with _$FamiliasDaoMixin {
  FamiliasDao(AppDatabase db) : super(db);

  Future<List<Familia>> getTodas() {
    return select(familias).get();
  }

  Future<int> inserir(FamiliasCompanion familia) {
    return into(familias).insert(familia);
  }

  /// Deleta uma família pelo ID
  Future<int> deletar(int id) {
    return (delete(familias)..where((f) => f.id.equals(id))).go();
  }
}
