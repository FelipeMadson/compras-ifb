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
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 18,
              color: Color(0xFFF59E0B),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Modo offline ativo. Suas alterações permanecem salvas no SQLite e '
                'serão sincronizadas automaticamente ao restabelecer a rede.',
                style: TextStyle(
                  color: cores.onSurface,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
