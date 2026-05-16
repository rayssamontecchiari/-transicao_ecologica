import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift hide Column, Table;

import '../../core/database/app_database.dart';
import '../../core/services/familia_service.dart';
import '../../core/services/categorias_service.dart';
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
  late CategoriasService _categoriasService;
  late AppDatabase _db;

  List<Familia> _familias = [];
  List<Categoria> _categorias = [];
  Familia? _selectedFamilia;
  bool _isLoading = true;
  int _categoriaAtual = 0;
  bool _isProcessing = false;
  int? _avaliacaoIdEmProgresso; // ID da avaliação em draft
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
    _categoriasService = CategoriasService(_db);

    final familias = await _familiasService.getTodas();
    final categorias = await _categoriasService.getTodas();

    setState(() {
      _familias = familias;
      _categorias = categorias;
      _isLoading = false;
      if (familias.isNotEmpty) {
        _selectedFamilia = familias.first;
      }
    });
  }

  Future<void> _iniciarAvaliacao({int? avaliacaoIdExistente}) async {
    if (_selectedFamilia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma família')),
      );
      return;
    }

    setState(() => _isProcessing = true);
    _avaliacaoIdEmProgresso = avaliacaoIdExistente;

    try {
      // Determinar de qual categoria começar
      int inicioCategoria = 0;
      if (avaliacaoIdExistente != null) {
        // Buscar em qual categoria a avaliação parou
        final avaliacao = _db.select(_db.avaliacoes)
          ..where((a) => a.id.equals(avaliacaoIdExistente));
        final avaliacaoData = await avaliacao.getSingleOrNull();
        if (avaliacaoData != null) {
          // Se estava incompleta, começar da próxima categoria
          inicioCategoria = avaliacaoData.categoriaAtual + 1;
          if (inicioCategoria >= _categorias.length) {
            // Já estava completa, começar do 0
            inicioCategoria = 0;
          }
        }
      }

      for (int i = inicioCategoria; i < _categorias.length; i++) {
        if (!mounted) break;

        setState(() => _categoriaAtual = i);

        final categoria = _categorias[i];

        Avaliacao? avaliacaoExistente;
        if (_avaliacaoIdEmProgresso != null) {
          avaliacaoExistente = await (_db.select(_db.avaliacoes)
                ..where((a) => a.id.equals(_avaliacaoIdEmProgresso!)))
              .getSingleOrNull();
        }

        final result = await Navigator.of(context).push<int>(
          MaterialPageRoute(
            builder: (_) => CategoriaFormPage(
              categoriaId: categoria.id,
              familiaId: _selectedFamilia!.id,
              avaliacaoId: 1,
              categoriaAtual: i + 1,
              totalCategorias: _categorias.length,
            ),
          ),
        );

        if (result == null || result <= 0) {
          // User cancelled - a avaliação fica em draft
          break;
        }

        // Atualizar o ID da avaliação com o retorno do formulário
        _avaliacaoIdEmProgresso = result;

        // Atualizar no banco para rastrear em qual categoria parou
        if (_avaliacaoIdEmProgresso != null) {
          await (_db.update(_db.avaliacoes)
                ..where((a) => a.id.equals(_avaliacaoIdEmProgresso!)))
              .write(
            AvaliacoesCompanion(
              categoriaAtual: drift.Value(i),
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
                                child: DropdownButtonFormField<Familia>(
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
                                      : (f) {
                                          setState(() => _selectedFamilia = f);
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
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed:
                                    _isProcessing ? null : _iniciarAvaliacao,
                                icon: const Icon(Icons.play_arrow),
                                label: Text(
                                  _isProcessing
                                      ? 'Iniciando...'
                                      : 'Iniciar Avaliação',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 18),
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
