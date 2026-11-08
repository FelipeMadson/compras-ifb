import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../dominio/item.dart';
import '../providers.dart';

/// Componente visual refinado de exibição e interação com um item individual da lista de compras.
/// Apresenta micro-animações táteis, transição suave de opacidade e estilo Glassmorphic sutil.
class CartaoItem extends ConsumerWidget {
  const CartaoItem({super.key, required this.item});

  final Item item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cores = Theme.of(context).colorScheme;
    final notifier = ref.read(itensProvider.notifier);

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: cores.errorContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Excluir',
              style: TextStyle(
                color: cores.onErrorContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.delete_outline, color: cores.onErrorContainer),
          ],
        ),
      ),
      onDismissed: (_) => notifier.excluir(item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: item.comprado
              ? cores.surfaceContainerHighest.withValues(alpha: 0.35)
              : cores.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.comprado
                ? cores.outlineVariant.withValues(alpha: 0.3)
                : cores.primary.withValues(alpha: 0.25),
            width: 1,
          ),
          boxShadow: [
            if (!item.comprado)
              BoxShadow(
                color: cores.shadow.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => context.go('/item/${item.id}'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // Checkbox estilizado com micro-animação
                  Transform.scale(
                    scale: 1.05,
                    child: Checkbox(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      value: item.comprado,
                      onChanged: (_) => notifier.alternarComprado(item),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Informações textuais do item com tipografia cinética
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: item.comprado
                                ? FontWeight.w500
                                : FontWeight.w600,
                            color: item.comprado
                                ? cores.outline
                                : cores.onSurface,
                            decoration: item.comprado
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                          child: Text(
                            item.nome,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: cores.secondaryContainer.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.categoria,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: cores.onSecondaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${item.quantidade} un.',
                              style: TextStyle(
                                fontSize: 12,
                                color: cores.onSurfaceVariant,
                              ),
                            ),
                            if (item.observacao.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '· ${item.observacao}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: cores.outline,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Ícone de sincronização com transição sutil
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      key: ValueKey(item.sincronizado),
                      item.sincronizado
                          ? Icons.cloud_done_outlined
                          : Icons.cloud_upload_outlined,
                      size: 20,
                      color: item.sincronizado ? cores.primary : cores.outline,
                      semanticLabel: item.sincronizado
                          ? 'Sincronizado com o servidor remoto'
                          : 'Aguardando sincronização remota',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
