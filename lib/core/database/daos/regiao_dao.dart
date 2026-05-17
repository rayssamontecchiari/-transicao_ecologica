import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/regiao_table.dart';

part 'regiao_dao.g.dart';

@DriftAccessor(tables: [Regiao])
class RegiaoDao extends DatabaseAccessor<AppDatabase> with _$RegiaoDaoMixin {
  RegiaoDao(super.db);

  Future<List<RegiaoData>> getTodas() {
    return select(regiao).get();
  }

  Future<int> inserir(RegiaoCompanion data) {
    return into(regiao).insert(data);
  }
}
