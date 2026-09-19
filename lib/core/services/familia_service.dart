import '../database/app_database.dart';
import '../database/daos/familia_dao.dart';

class FamiliasService {
  final FamiliaDao _familiasDao;
  final AppDatabase _db;

  FamiliasService(AppDatabase db)
      : _db = db,
        _familiasDao = FamiliaDao(db);

  Future<List<FamiliaData>> getTodas() {
    return _familiasDao.getTodas();
  }

  static bool saoFamiliasDuplicadas({
    required String? nomeResponsavel,
    required String? telefone,
    required String? nomeResponsavelExistente,
    required String? telefoneExistente,
  }) {
    final nomeNormalizado = _normalizarTexto(nomeResponsavel);
    final telefoneNormalizado = _normalizarTexto(telefone);
    final nomeExistenteNormalizado = _normalizarTexto(nomeResponsavelExistente);
    final telefoneExistenteNormalizado = _normalizarTexto(telefoneExistente);

    if (nomeNormalizado.isEmpty || telefoneNormalizado.isEmpty) {
      return false;
    }

    return nomeNormalizado == nomeExistenteNormalizado &&
        telefoneNormalizado == telefoneExistenteNormalizado;
  }

  static bool possuiComunidadeAssociada(int? comunidadeId) {
    return comunidadeId != null && comunidadeId > 0;
  }

  static bool possuiAvaliacoesVinculadas(
      int familiaId, int quantidadeAvaliacoes) {
    return familiaId > 0 && quantidadeAvaliacoes > 0;
  }

  static bool podeExcluirFamilia(int quantidadeAvaliacoes) {
    return quantidadeAvaliacoes <= 0;
  }

  Future<int> contarAvaliacoesVinculadas(int familiaId) async {
    final avaliacoes = await (_db.select(_db.avaliacao)
          ..where((a) => a.familiaId.equals(familiaId)))
        .get();
    return avaliacoes.length;
  }

  Future<void> validarFamilia(
    FamiliaCompanion familia, {
    int? familiaIdIgnorada,
  }) async {
    final comunidadeId =
        familia.comunidadeId.present ? familia.comunidadeId.value : null;
    if (!possuiComunidadeAssociada(comunidadeId)) {
      throw StateError('Família deve estar associada a uma comunidade.');
    }

    final nomeResponsavel =
        familia.nomeResponsavel.present ? familia.nomeResponsavel.value : '';
    final telefone = familia.telefone.present ? familia.telefone.value : '';
    final familiasCadastradas = await _familiasDao.getTodas();

    final duplicada = familiasCadastradas.any((familiaExistente) {
      if (familiaExistente.id == familiaIdIgnorada) {
        return false;
      }

      return saoFamiliasDuplicadas(
        nomeResponsavel: nomeResponsavel,
        telefone: telefone,
        nomeResponsavelExistente: familiaExistente.nomeResponsavel,
        telefoneExistente: familiaExistente.telefone,
      );
    });

    if (duplicada) {
      throw StateError(
        'Já existe uma família cadastrada com o mesmo nome e telefone.',
      );
    }
  }

  Future<int> cadastrarFamilia(FamiliaCompanion familia) async {
    await validarFamilia(familia);
    return _familiasDao.inserir(familia);
  }

  /// Deleta uma família pelo ID
  Future<void> deletarFamilia(int familiaId) async {
    final quantidadeAvaliacoes = await contarAvaliacoesVinculadas(familiaId);
    if (possuiAvaliacoesVinculadas(familiaId, quantidadeAvaliacoes)) {
      throw StateError(
        'Não é possível excluir uma família com avaliações vinculadas.',
      );
    }

    await _familiasDao.deletar(familiaId);
  }

  /// Atualiza uma família
  Future<bool> atualizarFamilia(int familiaId, FamiliaCompanion familia) async {
    await validarFamilia(familia, familiaIdIgnorada: familiaId);
    return _familiasDao.atualizar(familiaId, familia);
  }

  static String _normalizarTexto(String? valor) {
    return (valor ?? '').trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }
}
