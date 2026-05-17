import '../database/app_database.dart';
import '../database/daos/familia_dao.dart';

class FamiliasService {
  final FamiliaDao _familiasDao;

  FamiliasService(AppDatabase db) : _familiasDao = FamiliaDao(db);

  Future<List<FamiliaData>> getTodas() {
    return _familiasDao.getTodas();
  }

  Future<int> cadastrarFamilia(FamiliaCompanion familia) {
    return _familiasDao.inserir(familia);
  }

  /// Deleta uma família pelo ID
  Future<void> deletarFamilia(int familiaId) {
    return _familiasDao.deletar(familiaId);
  }

  /// Atualiza uma família
  Future<bool> atualizarFamilia(int familiaId, FamiliaCompanion familia) {
    return _familiasDao.atualizar(familiaId, familia);
  }
}
