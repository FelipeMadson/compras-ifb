import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Gerenciador de conexão, criação de esquema e metadados do banco SQLite.
///
/// Implementa injeção da [DatabaseFactory] para permitir alternância
/// transparente entre a fábrica nativa do Android em produção e a fábrica
/// FFI em memória durante a execução de testes automatizados de integração.
class BancoDeDados {
  BancoDeDados({required DatabaseFactory fabrica, String? caminho})
      : _fabrica = fabrica,
        _caminho = caminho;

  static const versaoDoEsquema = 1;
  static const nomeDoArquivo = 'compras.db';

  final DatabaseFactory _fabrica;
  final String? _caminho;
  Future<Database>? _abertura;

  /// Retorna a conexão ativa ou instancia uma nova mediante abertura idempotente.
  Future<Database> abrir() => _abertura ??= _abrir();

  Future<Database> _abrir() async {
    final caminho =
        _caminho ?? p.join(await _fabrica.getDatabasesPath(), nomeDoArquivo);
    return _fabrica.openDatabase(
      caminho,
      options: OpenDatabaseOptions(
        version: versaoDoEsquema,
        onCreate: _criarEsquema,
      ),
    );
  }

  Future<void> _criarEsquema(Database db, int versao) async {
    await db.execute('''
      CREATE TABLE itens (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        nome          TEXT    NOT NULL,
        quantidade    INTEGER NOT NULL CHECK (quantidade BETWEEN 1 AND 99),
        categoria     TEXT    NOT NULL,
        observacao    TEXT    NOT NULL DEFAULT '',
        comprado      INTEGER NOT NULL DEFAULT 0,
        sincronizado  INTEGER NOT NULL DEFAULT 0,
        criado_em     INTEGER NOT NULL,
        atualizado_em INTEGER NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_itens_sincronizado ON itens (sincronizado)',
    );

    await db.execute('''
      CREATE TABLE metadados (
        chave TEXT PRIMARY KEY,
        valor TEXT NOT NULL
      )
    ''');

    await db.insert('metadados', {
      'chave': 'criado_em',
      'valor': DateTime.now().toIso8601String(),
    });
  }

  /// Recupera o valor de uma chave específica na tabela de controle de metadados.
  Future<String?> lerMetadado(String chave) async {
    final db = await abrir();
    final linhas = await db.query(
      'metadados',
      columns: ['valor'],
      where: 'chave = ?',
      whereArgs: [chave],
      limit: 1,
    );
    return linhas.isEmpty ? null : linhas.first['valor'] as String;
  }

  /// Encerra a conexão ativa e libera os descritores do banco.
  Future<void> fechar() async {
    final abertura = _abertura;
    _abertura = null;
    if (abertura != null) {
      final db = await abertura;
      await db.close();
    }
  }
}
