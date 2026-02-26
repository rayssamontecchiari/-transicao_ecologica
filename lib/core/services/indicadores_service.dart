import '../database/daos/indicadores_dao.dart';
import '../database/app_database.dart';

class IndicadoresService {
  final IndicadoresDao _indicadoresDao;

  IndicadoresService(AppDatabase db) : _indicadoresDao = IndicadoresDao(db);

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
}
