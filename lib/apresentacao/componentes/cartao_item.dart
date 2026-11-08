import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../dominio/item.dart';
import '../providers.dart';

/// Componente visual refinado de exibição e interação com um item individual da lista de compras.
/// Implementa micro-escala tátil (Linear/Apple HIG), transição contínua de estado e bordas sutis.
class CartaoItem extends ConsumerStatefulWidget {
  const CartaoItem({super.key, required this.item});

  final Item item;

  @override
  ConsumerState<CartaoItem> createState() => _CartaoItemState();
}

class _CartaoItemState extends ConsumerState<CartaoItem> {
  bool _pressionado = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final cores = Theme.of(context).colorScheme;
    final notifier = ref.read(itensProvider.notifier);

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: cores.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_outline, color: cores.onErrorContainer),
      ),
      onDismissed: (_) => notifier.excluir(item),
      child: AnimatedScale(
        scale: _pressionado ? 0.985 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: item.comprado
                ? cores.surfaceContainerHighest.withValues(alpha: 0.35)
                : cores.surfaceContainerLow,
            border: Border.all(
              color: item.comprado
                  ? cores.outlineVariant.withValues(alpha: 0.4)
                  : cores.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onHighlightChanged: (p) => setState(() => _pressionado = p),
              onTap: () => context.go('/item/${item.id}'),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Checkbox(
                      value: item.comprado,
                      onChanged: (_) => notifier.alternarComprado(item),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeInOut,
                            style: TextStyle(
                              fontSize: 14.5,
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
                          const SizedBox(height: 2),
                          Text(
                            '${item.categoria} · ${item.quantidade} un.${item.observacao.isNotEmpty ? ' · ${item.observacao}' : ''}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: cores.onSurfaceVariant,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      item.sincronizado
                          ? Icons.cloud_done_outlined
                          : Icons.cloud_upload_outlined,
                      size: 20,
                      color: item.sincronizado ? cores.primary : cores.outline,
                      semanticLabel: item.sincronizado
                          ? 'Sincronizado'
                          : 'Pendente de sincronização',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
