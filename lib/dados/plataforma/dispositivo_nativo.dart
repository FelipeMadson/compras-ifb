import 'package:flutter/services.dart';

/// Estrutura tipada de metadados de telemetria e diagnóstico do hardware.
class InfoDispositivo {
  const InfoDispositivo({
    required this.fabricante,
    required this.modelo,
    required this.versaoAndroid,
    required this.nivelBateria,
  });

  final String fabricante;
  final String modelo;
  final String versaoAndroid;
  final int nivelBateria;
}

/// Adaptador Dart do canal de plataforma (MethodChannel).
///
/// Estabelece uma ponte binária de comunicação bidirecional com a atividade nativa Kotlin (MainActivity).
class DispositivoNativo {
  static const _canal = MethodChannel('compras/dispositivo');

  /// Consulta os subsistemas nativos do Android para extração de informações de hardware.
  ///
  /// Retorna `null` de maneira graciosa caso o canal não esteja implementado na plataforma
  /// (como durante a execução de testes em ambiente desktop sem host nativo).
  Future<InfoDispositivo?> obterInformacoes() async {
    try {
      final mapa = await _canal.invokeMapMethod<String, Object?>(
        'obterInformacoes',
      );
      if (mapa == null) return null;

      return InfoDispositivo(
        fabricante: mapa['fabricante'] as String,
        modelo: mapa['modelo'] as String,
        versaoAndroid: mapa['versaoAndroid'] as String,
        nivelBateria: mapa['bateria'] as int,
      );
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }
}
