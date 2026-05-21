class FuzzyNumber {
  final int nota;

  FuzzyNumber({
    required this.nota,
  });

  Map<String, double> calcular() {
    return {
      'a': _valorA(nota) / 10.0,
      'b': _valorB(nota) / 10.0,
      'c': _valorC(nota) / 10.0,
      'd': _valorD(nota) / 10.0,
    };
  }

  int _valorD(int nota) {
    switch (nota) {
      case 5:
        return 7;
      case 4:
        return 5;
      case 3:
        return 3;
      case 2:
        return 1;
      case 1:
        return 0;
      case 0:
        return 0;
      default:
        throw ArgumentError('Nota inválida');
    }
  }

  int _valorA(int nota) {
    switch (nota) {
      case 5:
        return 9;
      case 4:
        return 7;
      case 3:
        return 5;
      case 2:
        return 3;
      case 1:
        return 0;
      case 0:
        return 0;
      default:
        throw ArgumentError('Nota inválida');
    }
  }

  int _valorB(int nota) {
    switch (nota) {
      case 5:
        return 10;
      case 4:
        return 7;
      case 3:
        return 5;
      case 2:
        return 3;
      case 1:
        return 1;
      case 0:
        return 0;
      default:
        throw ArgumentError('Nota inválida');
    }
  }

  int _valorC(int nota) {
    switch (nota) {
      case 5:
        return 10;
      case 4:
        return 9;
      case 3:
        return 7;
      case 2:
        return 5;
      case 1:
        return 3;
      case 0:
        return 0;
      default:
        throw ArgumentError('Nota inválida');
    }
  }
}
