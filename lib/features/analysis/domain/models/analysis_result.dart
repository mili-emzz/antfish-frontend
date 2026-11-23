import 'package:flutter/foundation.dart';

import '../../../../core/ui/widgets/risk_badge.dart';

/// URL extraída del contenido analizado (`urls_extraidas` en contrato v2).
@immutable
class ExtractedUrl {
  const ExtractedUrl({
    required this.url,
    required this.dominio,
    this.flagsSintacticos = const [],
  });

  factory ExtractedUrl.fromJson(Map<String, dynamic> json) {
    final rawFlags = json['flags_sintacticos'];
    return ExtractedUrl(
      url: (json['url'] as String?) ?? '',
      dominio: (json['dominio'] as String?) ?? '',
      flagsSintacticos: rawFlags is List
          ? rawFlags.whereType<String>().toList()
          : const [],
    );
  }

  final String url;
  final String dominio;
  final List<String> flagsSintacticos;
}

/// Hallazgo individual detectado por el motor del backend (`hallazgos`).
///
/// Importante (`AGENTS.md` §9): los puntos son brutos sin topar; nunca deben
/// sumarse en el cliente para calcular el score total.
@immutable
class AnalysisFinding {
  const AnalysisFinding({
    required this.reglaCodigo,
    required this.titulo,
    required this.descripcion,
    required this.puntos,
  });

  factory AnalysisFinding.fromJson(Map<String, dynamic> json) =>
      AnalysisFinding(
        reglaCodigo: (json['regla_codigo'] as String?) ?? '',
        titulo: (json['titulo'] as String?) ?? '',
        descripcion: (json['descripcion'] as String?) ?? '',
        puntos: (json['puntos'] as num?)?.toInt() ?? 0,
      );

  final String reglaCodigo;
  final String titulo;
  final String descripcion;
  final int puntos;
}

/// Estado de consulta de una fuente externa de inteligencia (`fuentes_consultadas`).
@immutable
class ConsultedSource {
  const ConsultedSource({
    required this.api,
    required this.estado,
    required this.positivo,
    required this.detecciones,
    required this.desdeCache,
  });

  factory ConsultedSource.fromJson(Map<String, dynamic> json) =>
      ConsultedSource(
        api: (json['api'] as String?) ?? '',
        estado: (json['estado'] as String?) ?? 'error',
        positivo: (json['positivo'] as bool?) ?? false,
        detecciones: (json['detecciones'] as num?)?.toInt() ?? 0,
        desdeCache: (json['desde_cache'] as bool?) ?? false,
      );

  final String api;
  final String estado; // 'ok' | 'timeout' | 'rate_limit' | 'error'
  final bool positivo;
  final int detecciones;
  final bool desdeCache;
}

/// Página del historial paginado por cursor (`GET /api/v1/analysis`).
@immutable
class AnalysisHistoryPage {
  const AnalysisHistoryPage({required this.items, this.nextCursor});

  factory AnalysisHistoryPage.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(AnalysisResult.fromJson)
              .toList()
        : const <AnalysisResult>[];
    final cursor = json['next_cursor'];
    return AnalysisHistoryPage(
      items: items,
      nextCursor: cursor is String && cursor.isNotEmpty ? cursor : null,
    );
  }

  final List<AnalysisResult> items;
  final String? nextCursor;
}

/// Modelo de dominio inmutable para el resultado de un análisis en AntFish.
/// Fuente de verdad: `docs/contrato_api_v2.md` §2.
@immutable
class AnalysisResult {
  const AnalysisResult({
    required this.id,
    required this.tipoEntrada,
    required this.scoreTotal,
    required this.nivelRiesgo,
    required this.puntosPorCapa,
    required this.analisisParcial,
    required this.fechaAnalisis,
    this.mensajeHash,
    this.dominioPrincipal,
    this.urlsExtraidas = const [],
    this.motivoCortocircuito,
    this.hallazgos = const [],
    this.recomendaciones = const [],
    this.fuentesConsultadas = const [],
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    final score = (json['score_total'] as num?)?.toInt() ?? 0;

    final rawPuntos = json['puntos_por_capa'];
    final puntos = <String, int>{};
    if (rawPuntos is Map) {
      for (final entry in rawPuntos.entries) {
        if (entry.key is String && entry.value is num) {
          puntos[entry.key as String] = (entry.value as num).toInt();
        }
      }
    }

    final rawUrls = json['urls_extraidas'];
    final urls = rawUrls is List
        ? rawUrls
              .whereType<Map<String, dynamic>>()
              .map(ExtractedUrl.fromJson)
              .toList()
        : const <ExtractedUrl>[];

    final rawHallazgos = json['hallazgos'];
    final hallazgos = rawHallazgos is List
        ? rawHallazgos
              .whereType<Map<String, dynamic>>()
              .map(AnalysisFinding.fromJson)
              .toList()
        : const <AnalysisFinding>[];

    final rawRecs = json['recomendaciones'];
    final recomendaciones = rawRecs is List
        ? rawRecs.whereType<String>().toList()
        : const <String>[];

    final rawSources = json['fuentes_consultadas'];
    final fuentes = rawSources is List
        ? rawSources
              .whereType<Map<String, dynamic>>()
              .map(ConsultedSource.fromJson)
              .toList()
        : const <ConsultedSource>[];

    final rawDate = json['fecha'] ?? json['fecha_analisis'];
    final parsedDate = rawDate is String ? DateTime.tryParse(rawDate) : null;

    return AnalysisResult(
      id: (json['id'] as String?) ?? '',
      tipoEntrada: (json['tipo_entrada'] as String?) ?? 'url',
      mensajeHash: json['mensaje_hash'] as String?,
      dominioPrincipal: json['dominio_principal'] as String?,
      urlsExtraidas: urls,
      scoreTotal: score,
      nivelRiesgo: RiskLevel.fromApi(
        json['nivel_riesgo'] as String?,
        fallbackScore: score,
      ),
      puntosPorCapa: puntos,
      motivoCortocircuito: json['motivo_cortocircuito'] as String?,
      analisisParcial: (json['analisis_parcial'] as bool?) ?? false,
      hallazgos: hallazgos,
      recomendaciones: recomendaciones,
      fuentesConsultadas: fuentes,
      fechaAnalisis: parsedDate ?? DateTime.now().toUtc(),
    );
  }

  final String id;
  final String tipoEntrada; // 'sms' | 'url'
  final String? mensajeHash; // null cuando tipoEntrada == 'url'
  final String? dominioPrincipal;
  final List<ExtractedUrl> urlsExtraidas;
  final int scoreTotal; // 0..100
  final RiskLevel nivelRiesgo; // bajo | medio | alto | critico
  final Map<String, int> puntosPorCapa; // {'apis': n, 'url': m, 'texto': k}
  final bool analisisParcial;
  final DateTime fechaAnalisis;
  final String? motivoCortocircuito; // 'lista_negra' | 'suplantacion_marca'
  final List<AnalysisFinding> hallazgos;
  final List<String> recomendaciones;
  final List<ConsultedSource> fuentesConsultadas;

  bool get esAmenaza =>
      nivelRiesgo == RiskLevel.alto || nivelRiesgo == RiskLevel.critico;
  bool get tieneCortocircuito => motivoCortocircuito != null;

  /// URL dominante (primera URL extraída, sobre la que corren las APIs).
  ExtractedUrl? get urlDominante =>
      urlsExtraidas.isNotEmpty ? urlsExtraidas.first : null;

  /// URL secundaria (solo expone `flags_sintacticos`, `AGENTS.md` §9).
  ExtractedUrl? get urlSecundaria =>
      urlsExtraidas.length > 1 ? urlsExtraidas[1] : null;

  /// Título legible para mostrar en listas de historial sin almacenar texto SMS.
  String get displayTarget {
    if (dominioPrincipal != null && dominioPrincipal!.trim().isNotEmpty) {
      return dominioPrincipal!.trim();
    }
    if (urlDominante != null && urlDominante!.url.trim().isNotEmpty) {
      return urlDominante!.url.trim();
    }
    if (tipoEntrada == 'sms') {
      return 'Mensaje SMS analizado';
    }
    return 'Enlace analizado';
  }
}
