import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift hide Column, Table;

import '../../core/database/app_database.dart';
import '../../core/services/familia_service.dart';
import '../../core/services/categoria_service.dart';
import 'avaliacao_form.dart';
import 'resultado_avaliacao_page.dart';

/// Página inicial do fluxo de avaliação.
/// Permite selecionar uma família e iniciar o fluxo de 4 categorias de avaliação.
class IniciarAvaliacaoPage extends StatefulWidget {
  const IniciarAvaliacaoPage({super.key});

  @override
  State<IniciarAvaliacaoPage> createState() => _IniciarAvaliacaoPageState();
}

class _IniciarAvaliacaoPageState extends State<IniciarAvaliacaoPage> {
  late FamiliasService _familiasService;
  late CategoriaService _categoriaService;
  late AppDatabase _db;

  List<FamiliaData> _familias = [];
  List<CategoriaData> _categorias = [];
  FamiliaData? _selectedFamilia;
  bool _isLoading = true;
  int _categoriaAtual = 0;
  bool _isProcessing = false;
  int? _avaliacaoIdEmProgresso; // ID da avaliação em draft
  int? _avaliacaoPendenteId;
  final TextEditingController _avaliadorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _avaliadorController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    _db = await AppDatabase.instance();
    _familiasService = FamiliasService(_db);
    _categoriaService = CategoriaService(_db);

    final familias = await _familiasService.getTodas();
    final categorias = await _categoriaService.getTodas();

    setState(() {
      _familias = familias;
      _categorias = categorias;
      _isLoading = false;
      if (familias.isNotEmpty) {
        _selectedFamilia = familias.first;
      }
    });

    if (_selectedFamilia != null) {
      await _carregarAvaliacaoPendente();
    }
  }

  Future<void> _carregarAvaliacaoPendente() async {
    if (_selectedFamilia == null) return;

    final avaliacaoPendente = await (_db.select(_db.avaliacao)
          ..where((a) =>
              a.familiaId.equals(_selectedFamilia!.id) &
              a.status.equals('draft')))
        .getSingleOrNull();

    if (!mounted) return;

    setState(() {
      _avaliacaoPendenteId = avaliacaoPendente?.id;
    });
  }

  Future<void> _iniciarAvaliacao({required bool continuar}) async {
    if (_selectedFamilia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma família')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      int avaliacaoIdExistente;

      if (continuar && _avaliacaoPendenteId != null) {
        avaliacaoIdExistente = _avaliacaoPendenteId!;
      } else {
        // Criar uma nova avaliação
        avaliacaoIdExistente = await _db.avaliacao.insertOne(
          AvaliacaoCompanion.insert(
            familiaId: _selectedFamilia!.id,
            avaliador: _avaliadorController.text,
            status: const drift.Value('draft'),
          ),
        );
      }

      _avaliacaoIdEmProgresso = avaliacaoIdExistente;

      // Sempre começar da primeira categoria
      int inicioCategoria = 0;

      for (int i = inicioCategoria; i < _categorias.length; i++) {
        if (!mounted) break;

        setState(() => _categoriaAtual = i);

        final categoria = _categorias[i];

        final completed = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => CategoriaFormPage(
              categoriaId: categoria.id,
              familiaId: _selectedFamilia!.id,
              avaliacaoId: _avaliacaoIdEmProgresso!,
              categoriaAtual: i + 1,
              totalCategorias: _categorias.length,
            ),
          ),
        );

        if (completed != true) {
          // User cancelled or did not complete the category
          break;
        }

        // Não atualizamos mais `categoriaAtual` no banco; apenas registramos
        // a data de alteração para referência.
        if (_avaliacaoIdEmProgresso != null) {
          await (_db.update(_db.avaliacao)
                ..where((a) => a.id.equals(_avaliacaoIdEmProgresso!)))
              .write(
            AvaliacaoCompanion(
              dataAlteracao: drift.Value(DateTime.now()),
            ),
          );
        }
      }

      if (mounted) {
        // Verificar se completou todas as categorias
        if (_categoriaAtual == _categorias.length - 1) {
          // Avaliação foi completada - ir para página de resultados
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => ResultadoAvaliacaoPage(
                avaliacaoId: _avaliacaoIdEmProgresso!,
                familia: _selectedFamilia!,
              ),
            ),
          );
        } else {
          // Avaliação foi cancelada - voltar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Avaliação cancelada. Dados salvos em rascunho.'),
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: primary,
        iconTheme: IconThemeData(color: primary),
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Iniciar Avaliação',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Icon(Icons.eco, size: 24),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Container(
                  height: 260,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.16),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(34),
                      bottomRight: Radius.circular(34),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 16, bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Siga os passos para adicionar uma nova avaliação agroecológica.',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Preencha a família e o avaliador antes de começar.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: primary,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '1',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Selecione a Família',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Escolha a família que será avaliada.',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 1,
                              child: SizedBox(
                                height: 58,
                                child: DropdownButtonFormField<FamiliaData>(
                                  value: _selectedFamilia,
                                  decoration: InputDecoration(
                                    hintText: 'Selecionar família',
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.people,
                                      color: primary,
                                    ),
                                  ),
                                  isExpanded: true,
                                  items: _familias
                                      .map(
                                        (f) => DropdownMenuItem(
                                          value: f,
                                          child: Text(
                                            '${f.nomeResponsavel} (Família #${f.id})',
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: _isProcessing
                                      ? null
                                      : (f) async {
                                          setState(() => _selectedFamilia = f);
                                          await _carregarAvaliacaoPendente();
                                        },
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: primary,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '2',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Escolha o Avaliador',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Informe o nome do avaliador responsável.',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 1,
                              child: SizedBox(
                                height: 58,
                                child: TextField(
                                  controller: _avaliadorController,
                                  enabled: !_isProcessing,
                                  decoration: InputDecoration(
                                    hintText: 'Nome do avaliador',
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.person,
                                      color: primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            if (_avaliacaoPendenteId != null)
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _isProcessing
                                          ? null
                                          : () => _iniciarAvaliacao(
                                              continuar: true),
                                      icon: const Icon(Icons.play_arrow),
                                      label: Text(
                                        _isProcessing
                                            ? 'Processando...'
                                            : 'Continuar Avaliação',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 18),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _isProcessing
                                          ? null
                                          : () => _iniciarAvaliacao(
                                              continuar: false),
                                      icon: const Icon(Icons.add),
                                      label:
                                          const Text('Iniciar nova avaliação'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: primary,
                                        side: BorderSide(color: primary),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 18),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            else
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _isProcessing
                                      ? null
                                      : () =>
                                          _iniciarAvaliacao(continuar: false),
                                  icon: const Icon(Icons.play_arrow),
                                  label: Text(
                                    _isProcessing
                                        ? 'Iniciando...'
                                        : 'Iniciar Avaliação',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5FBF4),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Categorias que serão avaliadas',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            if (_categorias.isEmpty)
                              const Center(child: CircularProgressIndicator())
                            else
                              Column(
                                children: List.generate(
                                  _categorias.length * 2 - 1,
                                  (index) {
                                    if (index.isOdd) {
                                      return const SizedBox(height: 12);
                                    }
                                    final categoryIndex = index ~/ 2;
                                    final categoria =
                                        _categorias[categoryIndex];
                                    final icons = [
                                      Icons.agriculture,
                                      Icons.eco,
                                      Icons.group,
                                      Icons.bar_chart,
                                    ];
                                    final iconData =
                                        icons[categoryIndex % icons.length];

                                    return Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            iconData,
                                            color: primary,
                                            size: 26,
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Text(
                                              categoria.nome,
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
