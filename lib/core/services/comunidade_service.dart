import '../database/app_database.dart';
import '../database/daos/comunidade_dao.dart';

class ComunidadeService {
  final ComunidadeDao _comunidadesDao;
  final AppDatabase _db;

  ComunidadeService(AppDatabase db)
      : _db = db,
        _comunidadesDao = ComunidadeDao(db);

  static bool saoComunidadesDuplicadas({
    required String? nome,
    required String? nomeExistente,
  }) {
    final nomeNormalizado = _normalizarTexto(nome);
    final nomeExistenteNormalizado = _normalizarTexto(nomeExistente);

    if (nomeNormalizado.isEmpty) {
      return false;
    }

    return nomeNormalizado == nomeExistenteNormalizado;
  }

  Future<List<ComunidadeData>> getTodas() {
    return _comunidadesDao.getTodas();
  }

  Future<void> validarComunidade(
    ComunidadeCompanion comunidade, {
    int? comunidadeIdIgnorada,
  }) async {
    final nome = comunidade.nome.present ? comunidade.nome.value : '';
    final comunidadesCadastradas = await _comunidadesDao.getTodas();

    final duplicada = comunidadesCadastradas.any((comunidadeExistente) {
      if (comunidadeExistente.id == comunidadeIdIgnorada) {
        return false;
      }

      return saoComunidadesDuplicadas(
        nome: nome,
        nomeExistente: comunidadeExistente.nome,
      );
    });

    if (duplicada) {
      throw StateError('Já existe uma comunidade cadastrada com esse nome.');
    }
  }

  Future<int> inserir(ComunidadeCompanion comunidade) async {
    await validarComunidade(comunidade);
    return _comunidadesDao.inserir(comunidade);
  }

  Future<bool> atualizarComunidade(
      int comunidadeId, ComunidadeCompanion comunidade) async {
    await validarComunidade(comunidade, comunidadeIdIgnorada: comunidadeId);
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

  static String _normalizarTexto(String? valor) {
    return (valor ?? '').trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }
}
