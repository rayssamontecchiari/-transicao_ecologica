import '../database/app_database.dart';
import '../database/daos/regiao_dao.dart';

class RegiaoService {
  final RegiaoDao _regioesDao;

  RegiaoService(AppDatabase db) : _regioesDao = RegiaoDao(db);

  Future<List<RegiaoData>> getTodas() {
    return _regioesDao.getTodas();
  }

  Future<int> inserir(RegiaoCompanion regiao) {
    return _regioesDao.inserir(regiao);
  }
}
