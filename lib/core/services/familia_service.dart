import '../database/app_database.dart';
import '../database/daos/familias_dao.dart';

class FamiliasService {
  final FamiliasDao _familiasDao;

  FamiliasService(AppDatabase db) : _familiasDao = FamiliasDao(db);

  Future<List<Familia>> getTodas() {
    return _familiasDao.getTodas();
  }

  Future<int> cadastrarFamilia(FamiliasCompanion familia) {
    return _familiasDao.inserir(familia);
  }

  /// Deleta uma família pelo ID
  Future<void> deletarFamilia(int familiaId) {
    return _familiasDao.deletar(familiaId);
  }
}
