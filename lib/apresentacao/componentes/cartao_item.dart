import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/identidade.dart';
import '../../dominio/item.dart';
import '../providers.dart';

/// Cartão de item com acabamento visual Linear/Apple HIG:
/// Micro-compressão tátil (scale 0.982), barra de acentuação vertical, badges categóricos com ícone e bordas cirúrgicas.
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
    final corCategoria = Identidade.corDaCategoria(item.categoria);
    final iconeCategoria = Identidade.iconeDaCategoria(item.categoria);

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
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        notifier.excluir(item);
      },
      child: AnimatedScale(
        scale: _pressionado ? 0.982 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: item.comprado
                ? cores.surfaceContainerHighest.withValues(alpha: 0.25)
                : cores.surfaceContainerLow,
            border: Border.all(
              color: item.comprado
                  ? cores.outlineVariant.withValues(alpha: 0.35)
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    // Barra vertical sutil de categorização (Padrão Linear Status Bar)
                    Container(
                      width: 3.5,
                      height: 38,
                      decoration: BoxDecoration(
                        color: item.comprado
                            ? corCategoria.withValues(alpha: 0.3)
                            : corCategoria,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Checkbox com resposta tátil nativa
                    Transform.scale(
                      scale: 1.05,
                      child: Checkbox(
                        value: item.comprado,
                        onChanged: (_) {
                          HapticFeedback.selectionClick();
                          notifier.alternarComprado(item);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
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
                                  color: corCategoria.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: corCategoria.withValues(alpha: 0.28),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      iconeCategoria,
                                      size: 11,
                                      color: corCategoria,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      item.categoria,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: corCategoria,
                                      ),
                                    ),
                                  ],
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
