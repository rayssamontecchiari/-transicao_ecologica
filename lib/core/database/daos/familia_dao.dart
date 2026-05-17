import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/familia_table.dart';

part 'familia_dao.g.dart';

@DriftAccessor(tables: [Familia])
class FamiliaDao extends DatabaseAccessor<AppDatabase> with _$FamiliaDaoMixin {
  FamiliaDao(super.db);

  Future<List<FamiliaData>> getTodas() {
    return select(familia).get();
  }

  Future<int> inserir(FamiliaCompanion data) {
    return into(familia).insert(data);
  }

  Future<int> deletar(int id) {
    return (delete(familia)..where((f) => f.id.equals(id))).go();
  }

  Future<bool> atualizar(int id, FamiliaCompanion data) async {
    final rowsUpdated =
        await (update(familia)..where((f) => f.id.equals(id))).write(data);

    return rowsUpdated > 0;
  }
}
