import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Tela exibida em caso de rota inválida ou id inexistente em ligação profunda.
class TelaNaoEncontrada extends StatelessWidget {
  const TelaNaoEncontrada({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Item Não Encontrado')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'O endereço ou identificador requisitado não corresponde a nenhum item cadastrado.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Retornar à lista'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
