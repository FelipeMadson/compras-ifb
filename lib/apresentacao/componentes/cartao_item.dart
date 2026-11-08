import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../dominio/item.dart';
import '../providers.dart';

/// Cartão de item com acabamento visual Linear/Apple HIG:
/// Micro-compressão tátil (scale 0.98), bordas cirúrgicas de 1px e badges limpos.
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
        padding: const EdgeInsets.only(right: 22),
        decoration: BoxDecoration(
          color: cores.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cores.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Excluir',
              style: TextStyle(
                color: cores.error,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.delete_outline, color: cores.error, size: 20),
          ],
        ),
      ),
      onDismissed: (_) => notifier.excluir(item),
      child: AnimatedScale(
        scale: _pressionado ? 0.982 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: item.comprado
                ? cores.surfaceContainerHighest.withValues(alpha: 0.3)
                : cores.surfaceContainerLow,
            border: Border.all(
              color: item.comprado
                  ? cores.outlineVariant.withValues(alpha: 0.4)
                  : cores.outlineVariant,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onHighlightChanged: (p) => setState(() => _pressionado = p),
              onTap: () => context.go('/item/${item.id}'),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                child: Row(
                  children: [
                    // Checkbox nativo com feedback suave
                    Transform.scale(
                      scale: 1.05,
                      child: Checkbox(
                        value: item.comprado,
                        onChanged: (_) => notifier.alternarComprado(item),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Detalhes do item
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeInOut,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: item.comprado
                                  ? FontWeight.normal
                                  : FontWeight.w600,
                              color: item.comprado
                                  ? cores.outline
                                  : cores.onSurface,
                              decoration: item.comprado
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              letterSpacing: -0.01,
                            ),
                            child: Text(
                              item.nome,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: cores.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: cores.outlineVariant.withValues(alpha: 0.6),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  item.categoria,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: cores.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${item.quantidade} un.',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: cores.outline,
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
                                      color: cores.outline.withValues(alpha: 0.8),
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
                    // Indicador de sincronização sutil
                    Icon(
                      item.sincronizado
                          ? Icons.cloud_done_outlined
                          : Icons.cloud_upload_outlined,
                      size: 19,
                      color: item.sincronizado
                          ? cores.primary
                          : cores.outline.withValues(alpha: 0.6),
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
