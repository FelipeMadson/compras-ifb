import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'telas/tela_item.dart';
import 'telas/tela_lista.dart';
import 'telas/tela_nao_encontrada.dart';
import 'telas/tela_sobre.dart';

/// Transição suave e responsiva com aceleração cúbica (Linear/Apple HIG).
CustomTransitionPage<void> _construirTransicaoSuave({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 240),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      final slide = Tween<Offset>(
        begin: const Offset(0.04, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

/// Configuração declarativa do grafo de navegação e suporte a ligação profunda (Deep Linking).
final roteadorProvider = Provider<GoRouter>((ref) {
  final roteador = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const TelaLista(),
        routes: [
          GoRoute(
            path: 'item/novo',
            pageBuilder: (context, state) => _construirTransicaoSuave(
              key: state.pageKey,
              child: const TelaItem(),
            ),
          ),
          GoRoute(
            path: 'item/:id',
            pageBuilder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              return _construirTransicaoSuave(
                key: state.pageKey,
                child: id == null ? const TelaNaoEncontrada() : TelaItem(id: id),
              );
            },
          ),
          GoRoute(
            path: 'sobre',
            pageBuilder: (context, state) => _construirTransicaoSuave(
              key: state.pageKey,
              child: const TelaSobre(),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const TelaNaoEncontrada(),
  );

  ref.onDispose(roteador.dispose);
  return roteador;
});
