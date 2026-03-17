import 'package:drift/drift.dart';
import 'categorias_table.dart';

/// A dimensão é uma subdivisão dentro de uma categoria específica.
///
/// No caso da segunda categoria ("Análise Multidimensional da Sustentabilidade
/// das Práticas Agrícolas") existem três dimensões: Ecológica, Social e
/// Econômica. Outras categorias podem não utilizar dimensões.
@DataClassName('Dimensao')
class Dimensoes extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get nome => text()();

  /// referência para a categoria à qual esta dimensão pertence. Mantemos o
  /// vínculo à categoria para consultas mais simples e para manter coerência
  /// quando vários níveis de hierarquia forem necessários.
  IntColumn get categoriaId => integer().references(Categorias, #id)();
}
