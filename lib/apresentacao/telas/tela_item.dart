import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/identidade.dart';
import '../../dominio/item.dart';
import '../../dominio/regras_item.dart';
import '../providers.dart';
import 'tela_nao_encontrada.dart';

/// Ponto de entrada para edição ou criação de itens.
///
/// Trata carregamentos assíncronos decorrentes de ativação por ligação profunda (Deep Link).
class TelaItem extends ConsumerWidget {
  const TelaItem({super.key, this.id});

  final int? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = this.id;
    if (id == null) return const FormularioItem();

    return ref.watch(itensProvider).when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (erro, _) => Scaffold(
            appBar: AppBar(),
            body: Center(child: Text('Falha ao localizar o item: $erro')),
          ),
          data: (itens) {
            final item = itens.where((i) => i.id == id).firstOrNull;
            return item == null
                ? const TelaNaoEncontrada()
                : FormularioItem(item: item);
          },
        );
  }
}

class FormularioItem extends ConsumerStatefulWidget {
  const FormularioItem({super.key, this.item});

  final Item? item;

  @override
  ConsumerState<FormularioItem> createState() => _FormularioItemState();
}

class _FormularioItemState extends ConsumerState<FormularioItem> {
  final _chaveDoFormulario = GlobalKey<FormState>();
  late final TextEditingController _nome;
  late final TextEditingController _observacao;
  late String _categoria;
  late int _quantidade;
  bool _alterado = false;
  bool _salvando = false;

  bool get _editando => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nome = TextEditingController(text: item?.nome ?? '');
    _observacao = TextEditingController(text: item?.observacao ?? '');
    _categoria = item?.categoria ?? Identidade.categorias.first;
    _quantidade = item?.quantidade ?? 1;
  }

  @override
  void dispose() {
    _nome.dispose();
    _observacao.dispose();
    super.dispose();
  }

  void _marcarAlterado() {
    if (!_alterado) {
      setState(() => _alterado = true);
    }
  }

  void _mudarQuantidade(int variacao) {
    HapticFeedback.lightImpact();
    setState(() {
      _quantidade = ajustarQuantidade(_quantidade, variacao);
      _alterado = true;
    });
  }

  Future<void> _salvar() async {
    if (!_chaveDoFormulario.currentState!.validate()) return;
    setState(() => _salvando = true);

    final agora = DateTime.now();
    final original = widget.item;
    final item = original == null
        ? Item(
            nome: _nome.text.trim(),
            quantidade: _quantidade,
            categoria: _categoria,
            observacao: _observacao.text.trim(),
            criadoEm: agora,
            atualizadoEm: agora,
          )
        : original.copyWith(
            nome: _nome.text.trim(),
            quantidade: _quantidade,
            categoria: _categoria,
            observacao: _observacao.text.trim(),
          );

    try {
      await ref.read(itensProvider.notifier).salvar(item);
      if (!mounted) return;
      context.pop();
    } catch (erro) {
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao persistir no SQLite: $erro')),
      );
    }
  }

  Future<bool> _confirmarDescarte() async {
    final descartar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Descartar alterações?'),
        content: const Text(
          'As modificações introduzidas neste formulário não foram salvas e serão perdidas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Continuar editando'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    return descartar ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final textos = tema.textTheme;
    final cores = tema.colorScheme;
    final categorias = {...Identidade.categorias, _categoria}.toList();

    return PopScope(
      canPop: !_alterado,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final descartar = await _confirmarDescarte();
        if (descartar && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_editando ? 'Editar item' : 'Novo item'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Voltar',
            onPressed: () async {
              if (!_alterado) {
                context.pop();
                return;
              }
              final descartar = await _confirmarDescarte();
              if (descartar && context.mounted) {
                context.pop();
              }
            },
          ),
        ),
        body: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _chaveDoFormulario,
                onChanged: _marcarAlterado,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  children: [
                    // Campo Nome do Item
                    TextFormField(
                      controller: _nome,
                      autofocus: !_editando,
                      textCapitalization: TextCapitalization.sentences,
                      maxLength: tamanhoMaximoNome,
                      decoration: const InputDecoration(
                        labelText: 'Nome do item',
                        hintText: 'Ex.: Leite desnatado, Pão integral...',
                        prefixIcon: Icon(Icons.edit_outlined),
                      ),
                      validator: (valor) => validarNome(valor ?? ''),
                    ),
                    const SizedBox(height: 20),
                    // Campo Categoria
                    DropdownButtonFormField<String>(
                      initialValue: _categoria,
                      decoration: const InputDecoration(
                        labelText: 'Categoria',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      dropdownColor: cores.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      items: [
                        for (final categoria in categorias)
                          DropdownMenuItem(
                            value: categoria,
                            child: Row(
                              children: [
                                Icon(
                                  Identidade.iconeDaCategoria(categoria),
                                  size: 16,
                                  color: Identidade.corDaCategoria(categoria),
                                ),
                                const SizedBox(width: 8),
                                Text(categoria),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (valor) {
                        if (valor != null) {
                          setState(() => _categoria = valor);
                          _marcarAlterado();
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    // Atalhos Rápidos de Categoria em Chips
                    SizedBox(
                      height: 32,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (final cat in Identidade.categorias)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text(cat),
                                avatar: Icon(
                                  Identidade.iconeDaCategoria(cat),
                                  size: 13,
                                  color: _categoria == cat
                                      ? Identidade.corDaCategoria(cat)
                                      : cores.outline,
                                ),
                                selected: _categoria == cat,
                                onSelected: (_) {
                                  HapticFeedback.selectionClick();
                                  setState(() => _categoria = cat);
                                  _marcarAlterado();
                                },
                                labelStyle: TextStyle(
                                  fontSize: 11,
                                  fontWeight: _categoria == cat
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: _categoria == cat
                                      ? Identidade.corDaCategoria(cat)
                                      : cores.onSurface,
                                ),
                                selectedColor: Identidade.corDaCategoria(cat)
                                    .withValues(alpha: 0.16),
                                backgroundColor: cores.surfaceContainerLow,
                                side: BorderSide(
                                  color: _categoria == cat
                                      ? Identidade.corDaCategoria(cat)
                                      : cores.outlineVariant,
                                  width: _categoria == cat ? 1.2 : 0.8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Seletor Estilizado de Quantidade (Padrão Apple HIG Stepper)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: cores.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: cores.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Quantidade',
                                      style: textos.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -0.01,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Unidades a adquirir',
                                      style: textos.bodySmall?.copyWith(
                                        color: cores.outline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Botão Diminuir
                              Material(
                                color: cores.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(10),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: _quantidade > quantidadeMinima
                                      ? () => _mudarQuantidade(-1)
                                      : null,
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: cores.outlineVariant
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.remove,
                                      size: 18,
                                      color: _quantidade > quantidadeMinima
                                          ? cores.onSurface
                                          : cores.outline.withValues(alpha: 0.4),
                                    ),
                                  ),
                                ),
                              ),
                              // Valor Numérico
                              Container(
                                constraints: const BoxConstraints(minWidth: 50),
                                alignment: Alignment.center,
                                child: Text(
                                  '$_quantidade',
                                  style: textos.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                              // Botão Aumentar
                              Material(
                                color: cores.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(10),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: _quantidade < quantidadeMaxima
                                      ? () => _mudarQuantidade(1)
                                      : null,
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: cores.outlineVariant
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      size: 18,
                                      color: _quantidade < quantidadeMaxima
                                          ? cores.onSurface
                                          : cores.outline.withValues(alpha: 0.4),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Botões de Presets Rápidos
                          Row(
                            children: [
                              Text(
                                'Ajuste rápido: ',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: cores.outline,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              for (final inc in [1, 2, 5, 10]) ...[
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(6),
                                    onTap: () => _mudarQuantidade(inc),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: cores.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: cores.outlineVariant
                                              .withValues(alpha: 0.7),
                                        ),
                                      ),
                                      child: Text(
                                        '+$inc',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: cores.onSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Campo Observação
                    TextFormField(
                      controller: _observacao,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Observação (opcional)',
                        hintText: 'Marca de preferência, tamanho, peso, embalagem...',
                        prefixIcon: Icon(Icons.notes_outlined),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Botão Principal de Submissão
                    FilledButton.icon(
                      onPressed: _salvando ? null : _salvar,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: _salvando
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check, size: 20),
                      label: Text(
                        _editando ? 'Salvar alterações' : 'Adicionar à lista',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
