import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/identidade.dart';
import '../providers.dart';

/// Tela institucional com créditos acadêmicos, diagnóstico de hardware via canal nativo e metadados SQLite.
class TelaSobre extends ConsumerWidget {
  const TelaSobre({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final textos = tema.textTheme;
    final cores = tema.colorScheme;
    final dispositivo = ref.watch(infoDispositivoProvider);
    final bancoCriadoEm = ref.watch(bancoCriadoEmProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sobre o Projeto')),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cores.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.shopping_cart_checkout,
                        size: 32,
                        color: cores.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(Identidade.nomeDoApp, style: textos.titleLarge),
                          Text(
                            'Versão 1.0.0 (Build 1)',
                            style: textos.bodySmall?.copyWith(color: cores.outline),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  Identidade.descricao,
                  style: textos.bodyMedium?.copyWith(color: cores.onSurfaceVariant),
                ),
                const Divider(height: 36),
                Text(
                  'Autoria e Vínculo Institucional',
                  style: textos.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                for (final integrante in Identidade.integrantes)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: cores.secondaryContainer,
                      child: Icon(Icons.person, color: cores.onSecondaryContainer),
                    ),
                    title: Text(integrante.nome, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('Matrícula institucional: ${integrante.matricula}'),
                  ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: cores.secondaryContainer,
                    child: Icon(Icons.school, color: cores.onSecondaryContainer),
                  ),
                  title: const Text('Curso Superior de Tecnologia em Sistemas para Internet'),
                  subtitle: const Text(Identidade.turma),
                ),
                const Divider(height: 36),
                Text(
                  'Dispositivo (Canal Nativo Kotlin / MethodChannel)',
                  style: textos.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  color: cores.surfaceVariant.withOpacity(0.35),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: cores.outlineVariant.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: dispositivo.when(
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (erro, _) => Text(
                        'Falha na consulta ao canal nativo: $erro',
                        style: TextStyle(color: cores.error),
                      ),
                      data: (info) => info == null
                          ? const Text(
                              'Canal nativo indisponível nesta plataforma de execução.',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _ItemInfo(
                                  rotulo: 'Fabricante e Modelo',
                                  valor: '${info.fabricante} ${info.modelo}',
                                ),
                                const SizedBox(height: 8),
                                _ItemInfo(
                                  rotulo: 'Versão do Android',
                                  valor: 'Android ${info.versaoAndroid}',
                                ),
                                const SizedBox(height: 8),
                                _ItemInfo(
                                  rotulo: 'Nível de Carga da Bateria',
                                  valor: '${info.nivelBateria}%',
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const Divider(height: 36),
                Text(
                  'Persistência Relacional Local',
                  style: textos.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  color: cores.surfaceVariant.withOpacity(0.35),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: cores.outlineVariant.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: bancoCriadoEm.when(
                      loading: () => const Text('Consultando tabela de metadados...'),
                      error: (erro, _) => Text(
                        'Erro ao consultar metadados do SQLite: $erro',
                        style: TextStyle(color: cores.error),
                      ),
                      data: (data) => _ItemInfo(
                        rotulo: 'Instanciação do Banco SQLite',
                        valor: data == null
                            ? 'Data de criação não registrada.'
                            : 'Arquivo criado no armazenamento privado em ${_formatar(data)}.',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemInfo extends StatelessWidget {
  const _ItemInfo({required this.rotulo, required this.valor});

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rotulo,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(valor, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

String _formatar(DateTime data) {
  String dois(int n) => n.toString().padLeft(2, '0');
  return '${dois(data.day)}/${dois(data.month)}/${data.year} às ${dois(data.hour)}:${dois(data.minute)}';
}
