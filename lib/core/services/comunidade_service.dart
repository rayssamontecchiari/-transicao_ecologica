import '../database/app_database.dart';
import '../database/daos/comunidade_dao.dart';

class ComunidadeService {
  final ComunidadeDao _comunidadesDao;
  final AppDatabase _db;

  ComunidadeService(AppDatabase db)
      : _db = db,
        _comunidadesDao = ComunidadeDao(db);

  Future<List<ComunidadeData>> getTodas() {
    return _comunidadesDao.getTodas();
  }

  Future<int> inserir(ComunidadeCompanion comunidade) {
    return _comunidadesDao.inserir(comunidade);
  }

  Future<bool> atualizarComunidade(
      int comunidadeId, ComunidadeCompanion comunidade) {
    return _comunidadesDao.atualizar(comunidadeId, comunidade);
  }

  Future<int> contarFamiliasVinculadas(int comunidadeId) async {
    final familias = await (_db.select(_db.familia)
          ..where((f) => f.comunidadeId.equals(comunidadeId)))
        .get();
    return familias.length;
  }

  static bool possuiFamiliasVinculadas(
      int comunidadeId, int quantidadeFamilias) {
    return comunidadeId > 0 && quantidadeFamilias > 0;
  }

  Future<void> deletarComunidade(int comunidadeId) async {
    final quantidadeFamilias = await contarFamiliasVinculadas(comunidadeId);
    if (possuiFamiliasVinculadas(comunidadeId, quantidadeFamilias)) {
      throw StateError(
        'Não é possível excluir uma comunidade com famílias vinculadas.',
      );
    }

    await _comunidadesDao.deletar(comunidadeId);
  }
}
