import 'package:drift/drift.dart';
import 'categorias_table.dart';

/// As práticas agrícolas avaliadas na segunda categoria.
///
/// As práticas não são vinculadas a uma dimensão ou indicador específico,
/// mas sim à categoria como um todo. Elas são utilizadas na avaliação da
/// categoria "Análise Multidimensional da Sustentabilidade das Práticas
/// Agrícolas".
class Praticas extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get nome => text()();

  /// Referência para a categoria à qual esta prática pertence.
  IntColumn get categoriaId => integer().references(Categorias, #id)();
}
