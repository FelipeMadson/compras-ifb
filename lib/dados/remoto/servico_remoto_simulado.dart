import 'dart:math';

import '../../dominio/item.dart';
import 'nova_tentativa.dart';

/// Simulador de endpoint de backend HTTP para testes de robustez de rede.
///
/// Reproduz as características físicas de ambientes móveis reais:
/// latência estocástica (200ms a 800ms) e oscilações intermitentes na transmissão.
class ServicoRemotoSimulado {
  ServicoRemotoSimulado({this.taxaDeFalha = 0.3, Random? aleatorio})
      : _aleatorio = aleatorio ?? Random();

  /// Probabilidade nominal de ocorrência de falha temporária [0.0, 1.0].
  final double taxaDeFalha;
  final Random _aleatorio;

  Future<void> enviar(Item item) async {
    await Future<void>.delayed(
      Duration(milliseconds: 200 + _aleatorio.nextInt(600)),
    );
    if (_aleatorio.nextDouble() < taxaDeFalha) {
      throw const FalhaTransitoria('Servidor indisponível temporariamente (simulação).');
    }
  }
}
