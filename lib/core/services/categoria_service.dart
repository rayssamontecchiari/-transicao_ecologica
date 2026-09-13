import '../database/app_database.dart';
import '../database/daos/categoria_dao.dart';

class CategoriaService {
  final CategoriaDao _categoriasDao;
  final AppDatabase _db;

  CategoriaService(AppDatabase db)
      : _db = db,
        _categoriasDao = CategoriaDao(db);

  /// Retorna uma categoria específica pelo ID
  Future<CategoriaData?> getCategoriaById(int id) {
    return _categoriasDao.getById(id);
  }

  /// Retorna todas as categorias
  Future<List<CategoriaData>> getTodas() {
    return _categoriasDao.getTodas();
  }

  /// Conta o total de categorias cadastradas
  Future<int> contarTotal() {
    return _categoriasDao.contarTotal();
  }

  /// Verifica se existem categorias cadastradas
  Future<bool> existeCategorias() {
    return _categoriasDao.existeCategorias();
  }

  /// Insere uma nova categoria
  Future<int> inserir(CategoriaCompanion categoria) {
    return _categoriasDao.into(_categoriasDao.categoria).insert(categoria);
  }

  Future<bool> atualizarCategoria(
    int categoriaId,
    CategoriaCompanion categoria,
  ) {
    return (_db.update(_db.categoria)..where((c) => c.id.equals(categoriaId)))
        .write(categoria)
        .then((rows) => rows > 0);
  }

  Future<int> contarIndicadoresVinculados(int categoriaId) async {
    final indicadores = await (_db.select(_db.indicador)
          ..where((i) => i.categoriaId.equals(categoriaId)))
        .get();
    return indicadores.length;
  }

  Future<int> contarDimensoesVinculadas(int categoriaId) async {
    final dimensoes = await (_db.select(_db.dimensao)
          ..where((d) => d.categoriaId.equals(categoriaId)))
        .get();
    return dimensoes.length;
  }

  Future<int> contarPraticasVinculadas(int categoriaId) async {
    final praticas = await (_db.select(_db.pratica)
          ..where((p) => p.categoriaId.equals(categoriaId)))
        .get();
    return praticas.length;
  }

  Future<void> deletarCategoria(int categoriaId) async {
    final indicadores = await contarIndicadoresVinculados(categoriaId);
    final dimensoes = await contarDimensoesVinculadas(categoriaId);
    final praticas = await contarPraticasVinculadas(categoriaId);

    if (indicadores > 0 || dimensoes > 0 || praticas > 0) {
      throw StateError(
        'Não é possível excluir categoria com vínculos em indicadores, dimensões ou práticas.',
      );
    }

    await (_db.delete(_db.categoria)..where((c) => c.id.equals(categoriaId)))
        .go();
  }
}
