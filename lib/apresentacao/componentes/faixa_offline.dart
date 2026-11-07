import 'package:flutter/material.dart';

/// Alerta visual e semântico de indisponibilidade de conexão à rede externa.
///
/// O atributo [liveRegion] em [Semantics] instrui leitores de tela a vocalizarem a alteração
/// de conectividade de forma prioritária e não intrusiva.
class FaixaOffline extends StatelessWidget {
  const FaixaOffline({super.key});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Semantics(
      liveRegion: true,
      child: Material(
        color: cores.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.wifi_off, size: 20, color: cores.onSecondaryContainer),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Modo offline. Suas alterações permanecem seguras no SQLite e '
                  'serão replicadas automaticamente ao restaurar a rede.',
                  style: TextStyle(
                    color: cores.onSecondaryContainer,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
