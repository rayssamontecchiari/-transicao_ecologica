// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
import 'package:flutter_test/flutter_test.dart';

import 'package:transicao_ecologica/main.dart';

void main() {
  testWidgets('Home page contains title and buttons',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Avaliação transição agroecológica'), findsOneWidget);
    expect(find.text('Cadastrar Família'), findsOneWidget);
    expect(find.text('Cadastrar Região'), findsOneWidget);
    expect(find.text('Cadastrar Indicador'), findsOneWidget);
    expect(find.text('Cadastrar Nova Avaliação'), findsOneWidget);
  });
}
