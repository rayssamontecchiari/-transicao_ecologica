import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/regioes_table.dart';

part 'regioes_dao.g.dart';

@DriftAccessor(tables: [Regioes])
class RegioesDao extends DatabaseAccessor<AppDatabase> with _$RegioesDaoMixin {
  RegioesDao(AppDatabase db) : super(db);

  Future<List<Regioe>> getTodas() {
    return select(regioes).get();
  }

  Future<int> inserir(RegioesCompanion regiao) {
    return into(regioes).insert(regiao);
  }
}
