import '../database/app_database.dart';
import '../database/daos/categorias_dao.dart';

class CategoriasService {
  final CategoriasDao _categoriasDao;

  CategoriasService(AppDatabase db) : _categoriasDao = CategoriasDao(db);

  /// Retorna uma categoria específica pelo ID
  Future<Categoria?> getCategoriaById(int id) {
    return _categoriasDao.getById(id);
  }

  /// Retorna todas as categorias
  Future<List<Categoria>> getTodas() {
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
  Future<int> inserir(CategoriasCompanion categoria) {
    return _categoriasDao.into(_categoriasDao.categorias).insert(categoria);
  }
}
