import '../database/daos/indicador_dao.dart';
import '../database/daos/categoria_dao.dart';
import '../database/app_database.dart';

class IndicadorService {
  final IndicadorDao _indicadoresDao;
  late final CategoriaDao _categoriasDao;

  IndicadorService(AppDatabase db) : _indicadoresDao = IndicadorDao(db) {
    _categoriasDao = CategoriaDao(db);
  }

  /// Retorna uma categoria específica pelo ID
  Future<CategoriaData?> getCategoriaById(int id) {
    return _categoriasDao.getById(id);
  }

  /// Retorna todos os indicadores de uma categoria específica
  Future<List<IndicadorData>> getIndicadoresByCategoria(int categoriaId) {
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
  Future<Map<CategoriaData, List<IndicadorData>>> getPorCategoria() async {
    final registros = await _indicadoresDao.getComCategoria();

    final Map<CategoriaData, List<IndicadorData>> mapa = {};

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
  Future<int> inserirIndicador(IndicadorCompanion indicador) {
    return _indicadoresDao.into(_indicadoresDao.indicador).insert(indicador);
  }
}
