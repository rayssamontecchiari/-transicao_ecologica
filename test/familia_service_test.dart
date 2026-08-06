import 'package:flutter_test/flutter_test.dart';
import 'package:transicao_ecologica/core/services/familia_service.dart';

void main() {
  group('FamiliasService duplicate detection', () {
    test(
        'considers families duplicates when name and phone match ignoring case and whitespace',
        () {
      expect(
        FamiliasService.saoFamiliasDuplicadas(
          nomeResponsavel: '  Maria Souza  ',
          telefone: ' 99999-8888 ',
          nomeResponsavelExistente: 'maria souza',
          telefoneExistente: '99999-8888',
        ),
        isTrue,
      );
    });

    test('does not consider families duplicates when name or phone differ', () {
      expect(
        FamiliasService.saoFamiliasDuplicadas(
          nomeResponsavel: 'Maria Souza',
          telefone: '99999-8888',
          nomeResponsavelExistente: 'Joana Souza',
          telefoneExistente: '99999-8888',
        ),
        isFalse,
      );
    });

    test('considers families without a community as invalid', () {
      expect(FamiliasService.possuiComunidadeAssociada(null), isFalse);
      expect(FamiliasService.possuiComunidadeAssociada(0), isFalse);
      expect(FamiliasService.possuiComunidadeAssociada(7), isTrue);
    });
  });
}
