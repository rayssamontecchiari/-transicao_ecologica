import 'package:drift/drift.dart';
import 'categorias_table.dart';
import 'dimensoes_table.dart';

/// Indicadores ou aspectos norteadores usados para avaliar cada categoria.
///
/// A tabela foi estendida com um campo opcional [dimensaoId], já que a segunda
/// categoria necessita de uma hierarquia adicional (dimensões → indicadores).
/// Ele referencia a tabela [Dimensoes] e pode ser nulo para categorias que não
/// utilizam dimensões.
@DataClassName('Indicador')
class Indicadores extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get nome => text()();
  TextColumn get descricao => text()();

  RealColumn get peso => real().withDefault(const Constant(1.0))();

  IntColumn get categoriaId => integer().references(Categorias, #id)();

  IntColumn get dimensaoId => integer().nullable().references(Dimensoes, #id)();
}
