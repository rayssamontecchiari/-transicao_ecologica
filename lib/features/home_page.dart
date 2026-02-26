import 'package:flutter/material.dart';

import 'familias/cadastro_familia_page.dart';
import 'regioes/cadastro_regiao_page.dart';
import 'indicadores/cadastro_indicador_page.dart';

/// Página inicial do aplicativo com imagem, título e botões de navegação.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transição Ecológica'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/transicao_logo.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 16),
              Text(
                'Avaliação transição agroecológica',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CadastroFamiliaPage(),
                      ),
                    );
                  },
                  child: const Text('Cadastrar Família'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CadastroRegiaoPage(),
                      ),
                    );
                  },
                  child: const Text('Cadastrar Região'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CadastroIndicadorPage(),
                      ),
                    );
                  },
                  child: const Text('Cadastrar Indicador'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CadastrarAvaliacaoPage(),
                      ),
                    );
                  },
                  child: const Text('Cadastrar Nova Avaliação'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Página de cadastro de avaliação - ainda está em branco.
class CadastrarAvaliacaoPage extends StatelessWidget {
  const CadastrarAvaliacaoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Avaliação')),
      body: const Center(child: Text('Formulário de avaliação aqui')),
    );
  }
}
