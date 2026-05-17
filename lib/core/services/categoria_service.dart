import '../database/app_database.dart';
import '../database/daos/categoria_dao.dart';

class CategoriaService {
  final CategoriaDao _categoriasDao;

  CategoriaService(AppDatabase db) : _categoriasDao = CategoriaDao(db);

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
}
