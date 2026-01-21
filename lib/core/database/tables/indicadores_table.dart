import 'package:drift/drift.dart';
import 'categorias_table.dart';

class Indicadores extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get nome => text()();
  TextColumn get descricao => text()();

  RealColumn get peso => real().withDefault(const Constant(1.0))();

  IntColumn get categoriaId => integer().references(Categorias, #id)();
}
