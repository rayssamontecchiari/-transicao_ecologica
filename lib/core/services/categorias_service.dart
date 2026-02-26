import '../database/app_database.dart';
import '../database/daos/categorias_dao.dart';

class CategoriasService {
  final CategoriasDao _categoriasDao;

  CategoriasService(AppDatabase db) : _categoriasDao = CategoriasDao(db);

  Future<List<Categoria>> getTodas() {
    return _categoriasDao.getTodas();
  }

  Future<int> inserir(CategoriasCompanion categoria) {
    return _categoriasDao.into(_categoriasDao.categorias).insert(categoria);
  }
}
