import 'package:flutter_test/flutter_test.dart';
import 'package:transicao_ecologica/core/services/comunidade_service.dart';
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
  });

  group('FamiliasService business rules', () {
    test('treats a family with no linked evaluations as deletable', () {
      expect(
        FamiliasService.possuiAvaliacoesVinculadas(0, 0),
        isFalse,
      );
      expect(
        FamiliasService.podeExcluirFamilia(0),
        isTrue,
      );
    });

    test('treats a family with linked evaluations as not deletable', () {
      expect(
        FamiliasService.possuiAvaliacoesVinculadas(7, 1),
        isTrue,
      );
      expect(
        FamiliasService.podeExcluirFamilia(1),
        isFalse,
      );
    });
  });

  group('ComunidadeService business rules', () {
    test('treats a community with no linked families as deletable', () {
      expect(
        ComunidadeService.possuiFamiliasVinculadas(0, 0),
        isFalse,
      );
    });

    test('treats a community with linked families as not deletable', () {
      expect(
        ComunidadeService.possuiFamiliasVinculadas(3, 1),
        isTrue,
      );
    });

    test('considers community names duplicates when they differ only by case and spacing', () {
      expect(
        ComunidadeService.saoComunidadesDuplicadas(
          nome: '  norte  ',
          nomeExistente: 'NORTE',
        ),
        isTrue,
      );
    });
  });
}
