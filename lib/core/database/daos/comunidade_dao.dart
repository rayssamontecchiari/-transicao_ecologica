import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/comunidade_table.dart';

part 'comunidade_dao.g.dart';

@DriftAccessor(tables: [Comunidade])
class ComunidadeDao extends DatabaseAccessor<AppDatabase>
    with _$ComunidadeDaoMixin {
  ComunidadeDao(super.db);

  Future<List<ComunidadeData>> getTodas() {
    return select(comunidade).get();
  }

  Future<int> inserir(ComunidadeCompanion data) {
    return into(comunidade).insert(data);
  }

  Future<int> deletar(int id) {
    return (delete(comunidade)..where((c) => c.id.equals(id))).go();
  }

  Future<bool> atualizar(int id, ComunidadeCompanion data) async {
    final rowsUpdated =
        await (update(comunidade)..where((c) => c.id.equals(id))).write(data);
    return rowsUpdated > 0;
  }
}
