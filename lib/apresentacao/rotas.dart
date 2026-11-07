import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'telas/tela_item.dart';
import 'telas/tela_lista.dart';
import 'telas/tela_nao_encontrada.dart';
import 'telas/tela_sobre.dart';

/// Configuração declarativa do grafo de navegação e suporte a ligação profunda (Deep Linking).
///
/// Todas as rotas filhas de '/' herdam a pilha de navegação subjacente,
/// garantindo que a ação de retorno do usuário retroceda de forma previsível à listagem inicial.
final roteadorProvider = Provider<GoRouter>((ref) {
  final roteador = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const TelaLista(),
        routes: [
          // A rota estática 'item/novo' precede a dinâmica 'item/:id' para evitar colisão de parsing.
          GoRoute(
            path: 'item/novo',
            builder: (context, state) => const TelaItem(),
          ),
          GoRoute(
            path: 'item/:id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              return id == null ? const TelaNaoEncontrada() : TelaItem(id: id);
            },
          ),
          GoRoute(
            path: 'sobre',
            builder: (context, state) => const TelaSobre(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const TelaNaoEncontrada(),
  );

  ref.onDispose(roteador.dispose);
  return roteador;
});
