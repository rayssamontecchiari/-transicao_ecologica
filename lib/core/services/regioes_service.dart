import '../database/app_database.dart';
import '../database/daos/regioes_dao.dart';

class RegioesService {
  final RegioesDao _regioesDao;

  RegioesService(AppDatabase db) : _regioesDao = RegioesDao(db);

  Future<List<Regiao>> getTodas() {
    return _regioesDao.getTodas();
  }

  Future<int> inserir(RegioesCompanion regiao) {
    return _regioesDao.inserir(regiao);
  }
}
