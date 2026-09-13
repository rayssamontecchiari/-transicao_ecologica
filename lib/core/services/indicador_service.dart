import '../database/daos/indicador_dao.dart';
import '../database/daos/categoria_dao.dart';
import '../database/app_database.dart';
import 'resultado_cache_service.dart';

class IndicadorService {
  final IndicadorDao _indicadoresDao;
  late final CategoriaDao _categoriasDao;
  final AppDatabase _db;
  final ResultadoCacheService _cacheService = ResultadoCacheService();

  IndicadorService(AppDatabase db)
      : _db = db,
        _indicadoresDao = IndicadorDao(db) {
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
  Future<void> atualizarPesoIndicador(int indicadorId, double novoPeso) async {
    await _indicadoresDao.atualizarPeso(indicadorId, novoPeso);
    await _cacheService.invalidarTodosResultados();
  }

  /// Insere um novo indicador no banco
  Future<int> inserirIndicador(IndicadorCompanion indicador) async {
    final id =
        await _indicadoresDao.into(_indicadoresDao.indicador).insert(indicador);
    await _cacheService.invalidarTodosResultados();
    return id;
  }

  Future<bool> atualizarIndicador(
    int indicadorId,
    IndicadorCompanion indicador,
  ) async {
    final rows = await (_db.update(_db.indicador)
          ..where((i) => i.id.equals(indicadorId)))
        .write(indicador);
    if (rows > 0) {
      await _cacheService.invalidarTodosResultados();
      return true;
    }
    return false;
  }

  Future<int> contarUsoEmAvaliacoes(int indicadorId) async {
    final itens = await (_db.select(_db.avaliacaoItem)
          ..where((item) => item.indicadorId.equals(indicadorId)))
        .get();
    return itens.length;
  }

  Future<void> deletarIndicador(int indicadorId) async {
    final usos = await contarUsoEmAvaliacoes(indicadorId);
    if (usos > 0) {
      throw StateError(
        'Não é possível excluir indicador já utilizado em avaliações.',
      );
    }

    await (_db.delete(_db.indicador)..where((i) => i.id.equals(indicadorId)))
        .go();
    await _cacheService.invalidarTodosResultados();
  }
}
