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
  List<Avaliacao> _avaliacoesFamilia = [];
  int? _avaliacaoIdEmProgresso; // ID da avaliação em draft

  @override
  void initState() {
    super.initState();
    _init();
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
              avaliacaoExistente: avaliacaoExistente,
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
        // Recarregar avaliações
        await _carregarAvaliacoesFamilia();
      }
    }
  }

  Future<void> _carregarAvaliacoesFamilia() async {
    if (_selectedFamilia == null) return;

    try {
      final avaliacoesData = await (_db.select(_db.avaliacoes)
            ..where((a) => a.familiaId.equals(_selectedFamilia!.id))
            ..orderBy([(a) => drift.OrderingTerm.desc(a.data)]))
          .get();

      if (mounted) {
        setState(() {
          _avaliacoesFamilia = avaliacoesData;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar avaliações: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deletarAvaliacao(int avaliacaoId) async {
    try {
      await (_db.delete(_db.avaliacaoItens)
            ..where((a) => a.avaliacaoId.equals(avaliacaoId)))
          .go();
      await (_db.delete(_db.avaliacoes)..where((a) => a.id.equals(avaliacaoId)))
          .go();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Avaliação deletada com sucesso!'),
            duration: Duration(seconds: 2),
          ),
        );
        await _carregarAvaliacoesFamilia();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao deletar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildCategoryCard(
      BuildContext context, Categoria categoria, int index) {
    final theme = Theme.of(context);
    final colors = [
      Colors.green.shade50,
      Colors.teal.shade50,
      Colors.amber.shade50,
      Colors.purple.shade50,
    ];
    final iconColors = [
      Colors.green.shade700,
      Colors.teal.shade700,
      Colors.amber.shade700,
      Colors.purple.shade700,
    ];
    final icons = [
      Icons.terrain,
      Icons.public,
      Icons.handshake,
      Icons.bar_chart,
    ];

    final bgColor = colors[index % colors.length];
    final iconColor = iconColors[index % iconColors.length];
    final iconData = icons[index % icons.length];

    return Container(
      width: (MediaQuery.of(context).size.width - 56) / 2,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(iconData, color: iconColor, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            '${index + 1}. ${categoria.nome}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            categoria.descricao ?? '',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
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
        title: Text(
          'Nova Avaliação',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: primary,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.16),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 20, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
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
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: primary.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.task_alt,
                                    color: primary,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Nova Avaliação',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Siga os passos para avaliar sua família',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        '1. Selecione a Família',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Escolha a família que será avaliada.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          child: DropdownButtonFormField<Familia>(
                            value: _selectedFamilia,
                            decoration: InputDecoration(
                              hintText: 'Selecionar família',
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.people,
                                color: primary,
                              ),
                              suffixIcon: const Icon(Icons.keyboard_arrow_down),
                            ),
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
                                    if (f != null) {
                                      _carregarAvaliacoesFamilia();
                                    }
                                  },
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        '2. Categorias da Avaliação',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Serão avaliadas 4 dimensões principais.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (_categorias.isEmpty)
                        const Center(child: CircularProgressIndicator())
                      else
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: List.generate(
                            _categorias.length,
                            (index) => _buildCategoryCard(
                              context,
                              _categorias[index],
                              index,
                            ),
                          ),
                        ),

                      const SizedBox(height: 28),

                      ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _iniciarAvaliacao,
                        icon: const Icon(Icons.play_arrow),
                        label: Text(
                          _isProcessing ? 'Iniciando...' : 'Iniciar Avaliação',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      Text(
                        'Você poderá salvar e continuar depois',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),

                      const SizedBox(height: 20),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: Colors.green.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: primary.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.shield,
                                  color: primary,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Seus dados estão seguros',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Todas as informações são confidenciais e protegidas.',
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
                        ),
                      ),

                      const SizedBox(height: 24),

                      if (_selectedFamilia != null) ...[
                        if (_avaliacoesFamilia
                            .where((a) => a.status == 'draft')
                            .isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Avaliações em Progresso',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],

                      // Mantém as seções de avaliações existentes
                      if (_selectedFamilia != null) ...[
                        Builder(
                          builder: (context) {
                            final draftAvaliacoes = _avaliacoesFamilia
                                .where((a) => a.status == 'draft')
                                .toList();

                            if (draftAvaliacoes.isNotEmpty) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: draftAvaliacoes.length,
                                    itemBuilder: (context, index) {
                                      final avaliacao = draftAvaliacoes[index];
                                      final data = avaliacao.data;
                                      final progresso =
                                          avaliacao.categoriaAtual;

                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                          ),
                                          child: ListTile(
                                            leading: Icon(
                                              Icons.schedule,
                                              color: Colors.orange.shade700,
                                            ),
                                            title: Text(avaliacao.avaliador),
                                            subtitle: Text(
                                              'Categoria ${progresso + 1}/4 • ${data.day}/${data.month}/${data.year}',
                                            ),
                                            trailing: ElevatedButton(
                                              onPressed: _isProcessing
                                                  ? null
                                                  : () => _iniciarAvaliacao(
                                                        avaliacaoIdExistente:
                                                            avaliacao.id,
                                                      ),
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 14,
                                                  vertical: 10,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                ),
                                              ),
                                              child: const Text('Retomar'),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Avaliações Finalizadas (${_avaliacoesFamilia.where((a) => a.status == 'completed').length})',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (_avaliacoesFamilia
                            .where((a) => a.status == 'completed')
                            .isEmpty)
                          Card(
                            color: Colors.grey[100],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Nenhuma avaliação finalizada para esta família',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _avaliacoesFamilia
                                .where((a) => a.status == 'completed')
                                .length,
                            itemBuilder: (context, index) {
                              final avaliacao = _avaliacoesFamilia
                                  .where((a) => a.status == 'completed')
                                  .toList()[index];
                              final data = avaliacao.data;
                              final dataAlteracao = avaliacao.dataAlteracao;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                    title: Text(avaliacao.avaliador),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Criada: ${data.day}/${data.month}/${data.year} às ${data.hour}:${data.minute.toString().padLeft(2, '0')}',
                                        ),
                                        if (dataAlteracao
                                                .difference(data)
                                                .inSeconds >
                                            60)
                                          Text(
                                            'Alterada: ${dataAlteracao.day}/${dataAlteracao.month}/${dataAlteracao.year} às ${dataAlteracao.hour}:${dataAlteracao.minute.toString().padLeft(2, '0')}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                          ),
                                      ],
                                    ),
                                    trailing: PopupMenuButton(
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          child: const Row(
                                            children: [
                                              Icon(Icons.edit,
                                                  color: Colors.blue, size: 20),
                                              SizedBox(width: 8),
                                              Text('Editar',
                                                  style: TextStyle(
                                                      color: Colors.blue)),
                                            ],
                                          ),
                                          onTap: () => _iniciarAvaliacao(
                                            avaliacaoIdExistente: avaliacao.id,
                                          ),
                                        ),
                                        PopupMenuItem(
                                          child: const Row(
                                            children: [
                                              Icon(Icons.delete,
                                                  color: Colors.red, size: 20),
                                              SizedBox(width: 8),
                                              Text(
                                                'Deletar',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ],
                                          ),
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text(
                                                    'Confirmar Deleção'),
                                                content: const Text(
                                                  'Tem certeza que deseja deletar esta avaliação? Esta ação não pode ser desfeita.',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child:
                                                        const Text('Cancelar'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      _deletarAvaliacao(
                                                          avaliacao.id);
                                                    },
                                                    child: const Text(
                                                      'Deletar',
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
