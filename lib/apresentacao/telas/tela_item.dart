import 'package:flutter/material.dart';
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
    final textos = Theme.of(context).textTheme;
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
        appBar: AppBar(title: Text(_editando ? 'Editar item' : 'Novo item')),
        body: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _chaveDoFormulario,
                onChanged: _marcarAlterado,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    TextFormField(
                      controller: _nome,
                      autofocus: !_editando,
                      textCapitalization: TextCapitalization.sentences,
                      maxLength: tamanhoMaximoNome,
                      decoration: const InputDecoration(
                        labelText: 'Nome do item',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.edit_outlined),
                      ),
                      validator: (valor) => validarNome(valor ?? ''),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _categoria,
                      decoration: const InputDecoration(
                        labelText: 'Categoria',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: [
                        for (final categoria in categorias)
                          DropdownMenuItem(
                            value: categoria,
                            child: Text(categoria),
                          ),
                      ],
                      onChanged: (valor) {
                        if (valor != null) {
                          setState(() => _categoria = valor);
                          _marcarAlterado();
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text('Quantidade', style: textos.titleMedium),
                            ),
                            IconButton.outlined(
                              tooltip: 'Diminuir quantidade',
                              onPressed: _quantidade > quantidadeMinima
                                  ? () => _mudarQuantidade(-1)
                                  : null,
                              icon: const Icon(Icons.remove),
                            ),
                            ConstrainedBox(
                              constraints: const BoxConstraints(minWidth: 56),
                              child: Text(
                                '$_quantidade',
                                textAlign: TextAlign.center,
                                style: textos.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton.outlined(
                              tooltip: 'Aumentar quantidade',
                              onPressed: _quantidade < quantidadeMaxima
                                  ? () => _mudarQuantidade(1)
                                  : null,
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _observacao,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Observações adicionais (opcional)',
                        hintText: 'Marca de preferência, tamanho, peso, embalagem...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.notes_outlined),
                      ),
                    ),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: _salvando ? null : _salvar,
                      icon: _salvando
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check),
                      label: Text(
                        _editando ? 'Salvar alterações' : 'Adicionar à lista',
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
