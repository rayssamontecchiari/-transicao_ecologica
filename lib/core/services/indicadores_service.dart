import '../database/daos/indicadores_dao.dart';
import '../database/daos/categorias_dao.dart';
import '../database/app_database.dart';

class IndicadoresService {
  final AppDatabase _db;
  final IndicadoresDao _indicadoresDao;
  late final CategoriasDao _categoriasDao;

  IndicadoresService(AppDatabase db)
      : _db = db,
        _indicadoresDao = IndicadoresDao(db) {
    _categoriasDao = CategoriasDao(db);
  }

  /// Retorna uma categoria específica pelo ID
  Future<Categoria?> getCategoriaById(int id) {
    return _categoriasDao.getById(id);
  }

  /// Retorna todos os indicadores de uma categoria específica
  Future<List<Indicadore>> getIndicadoresByCategoria(int categoriaId) {
    return _indicadoresDao.getPorCategoria(categoriaId);
  }

  /// Conta o total de indicadores cadastrados
  Future<int> contarTotal() {
    return _indicadoresDao.contarTotal();
  }

  /// Verifica se existem indicadores cadastrados
  Future<bool> existeIndicadores() {
    return _indicadoresDao.existeIndicadores();
  }

  /// Retorna indicadores agrupados por categoria
  Future<Map<Categoria, List<Indicadore>>> getPorCategoria() async {
    final registros = await _indicadoresDao.getComCategoria();

    final Map<Categoria, List<Indicadore>> mapa = {};

    for (final (indicador, categoria) in registros) {
      mapa.putIfAbsent(categoria, () => []);
      mapa[categoria]!.add(indicador);
    }

    return mapa;
  }

  /// Atualiza peso (uso administrativo)
  Future<void> atualizarPesoIndicador(int indicadorId, double novoPeso) {
    return _indicadoresDao.atualizarPeso(indicadorId, novoPeso);
  }

  /// Insere um novo indicador no banco
  Future<int> inserirIndicador(IndicadoresCompanion indicador) {
    return _indicadoresDao.into(_indicadoresDao.indicadores).insert(indicador);
  }
}
