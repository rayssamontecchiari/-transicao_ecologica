import '../database/app_database.dart';
import '../database/daos/comunidade_dao.dart';

class ComunidadeService {
  final ComunidadeDao _comunidadesDao;

  ComunidadeService(AppDatabase db) : _comunidadesDao = ComunidadeDao(db);

  Future<List<ComunidadeData>> getTodas() {
    return _comunidadesDao.getTodas();
  }

  Future<int> inserir(ComunidadeCompanion comunidade) {
    return _comunidadesDao.inserir(comunidade);
  }
}
