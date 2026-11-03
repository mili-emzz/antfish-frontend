# AGENTS.md: AntFish Frontend (Flutter)

Instrucciones para cualquier agente de IA que trabaje en el frontend de este repositorio. El detalle vive en `docs/resumen_proyecto.json`, `docs/CONTEXTO/CONTEXTO_AntFish_V2.md` y `DESIGN.md`. **Léelos antes de escribir código.**

---

## 1. Propósito y Fuentes de Verdad

AntFish es una aplicación móvil (Android e iOS) para el análisis de SMS y URLs sospechosas (phishing/smishing), consumiendo la API REST del backend AntFish.

### Orden de precedencia estricto:
1. **Contrato del backend y requerimientos de negocio**: `docs/CONTEXTO/CONTEXTO_AntFish_V2.md` (§1 a §8 inmutables) y `docs/MODELADO-AGENTS/antfish_modelo_nosql.json`.
2. **Arquitectura frontend**: `docs/arquitectura_frontend_v1.json`.
3. **Sistema de diseño**: `DESIGN.md` (Sistema *Dark Crystal Cyber-Shield*).
4. **Casos de uso**: `docs/CONTEXTO/Antfish_Casos_de_Uso.md`.
5. **Este archivo (`AGENTS.md`)**.

> [!IMPORTANT]
> **Regla ante contradicciones:** Prevalece siempre el contrato del backend. Si encuentras una discrepancia, **detente y pregunta**; regístrala en la tabla `cove_verificacion` de la arquitectura antes de tocar la pantalla o servicio afectado. Nunca tomes decisiones unilaterales que violen el contrato.

---

## 2. Comandos

```bash
flutter run                                           # Ejecutar la app en emulador o dispositivo
flutter analyze                                       # Análisis estático de Dart
dart format --output=none --set-exit-if-changed .     # Verificación de formato de código
dart format .                                         # Formatear código
flutter test                                          # Pruebas unitarias y de widgets
flutter test --update-goldens                         # Actualizar golden tests del semáforo
dart run build_runner build --delete-conflicting-outputs  # Generar código (freezed / json_serializable)
dart run custom_lint                                  # Verificación de reglas de capas y dependencias
```

---

## 3. Stack Tecnológico y Dependencias

* **Lenguaje y Framework:** Dart 3.x + Flutter 3.x (un solo código base para Android e iOS, RNF-04).
* **Gestión de Estado:** `flutter_riverpod` (AsyncNotifier) [pendiente de ratificación final DPF-01; alternativa válida: `flutter_bloc`].
* **Navegación:** `go_router` con guards reactivos según el estado de sesión.
* **Cliente HTTP:** `dio` con interceptores (autenticación Bearer, refresh token concurrente y mapeo de errores).
* **Almacenamiento Seguro:** `flutter_secure_storage` (únicamente para tokens JWT).
* **Modelos Inmutables:** `freezed` + `json_serializable`.
* **Autenticación e Integraciones:** `google_sign_in` (SDK oficial, RF-06.4), `receive_sharing_intent` (menú Compartir, RF-01.2).
* **Testing:** `flutter_test`, `mocktail` y golden tests para el semáforo y widgets críticos.

> [!WARNING]
> **Preguntar antes de agregar dependencias:** No se permite ejecutar `flutter pub add` ni modificar `pubspec.yaml` con librerías nuevas sin aprobación explícita del equipo (DPF-02).

---

## 4. Arquitectura y Reglas de Capas

Se utiliza una arquitectura **Modular por Feature (Feature-First)** con capas ligeras y un núcleo transversal `core/`. No existe un motor de análisis o dominio pesado en el cliente (el scoring es exclusivo del backend).

```text
lib/
├── main.dart                 # Punto de entrada y ProviderScope
├── app.dart                  # MaterialApp.router, configuración de tema y l10n
├── core/                     # Transversal (sin dependencias de features)
│   ├── network/              # Dio, interceptores de auth y refresh, ErrorMapper
│   ├── session/              # SessionController (unknown, unauthenticated, pendingVerification, authenticated)
│   ├── storage/              # Acceso a FlutterSecureStorage
│   ├── errors/               # Jerarquía sealed AppFailure
│   ├── router/               # GoRouter y redirects de autenticación
│   └── ui/                   # Tema (Dark Crystal Cyber-Shield), semáforo y componentes base
├── features/                 # Módulos verticales independientes
│   ├── auth/                 # Registro, verificación por código, reenvío, login, Google, forgot, reset
│   ├── analysis/             # Entrada manual/compartir, resultado, semáforo, historial, detalle, borrado
│   ├── metrics/              # Panel de estadísticas (anillo de seguridad, contadores)
│   └── account/              # Configuración y borrado de cuenta con reautenticación
└── l10n/                     # Textos internacionalizados en español (ARB / AppLocalizations)
```

### Capas dentro de cada feature:
* `presentation/`: UI (widgets, pantallas) y controllers/notifiers. No importa `data/`.
* `domain/`: Modelos de negocio inmutables y contratos de repositorios (Dart puro).
* `data/`: DTOs de API, datasources remotos y repositorios concretos que implementan `domain/`.

### Reglas de importación (verificadas con `custom_lint`):
* Un `feature` puede importar `core` y el barrel público de otro feature (únicamente modelos o widgets explícitamente exportados).
* Un `feature` **NUNCA** puede importar carpetas internas (`data/`, `presentation/`) de otro feature.
* `core/` **NUNCA** importa código de `features/`.

---

## 5. Convenciones de Código y Diseño

* **Código:** Dart e identificadores en inglés (`AnalysisResult`, `fetchMetrics`, `RiskLevel`).
* **Textos al usuario:** Estrictamente en **español**, centralizados en `lib/l10n/` (nunca textos "hardcodeados" en widgets).
* **Enums en minúsculas:**
  * Riesgo: `bajo | medio | alto | critico`
  * Entrada: `sms | url`
  * Fuentes: `ok | timeout | rate_limit | error`
  * Estado de cuenta: `pendiente_verificacion | activa | suspendida | eliminada`
  * Proveedor auth: `local | google`
  * Cortocircuito: `lista_negra | suplantacion_marca`
* **Mapeo de datos:** Los DTOs en `data/` consumen los nombres snake_case del backend en español y se mapean a modelos Dart inmutables de `domain/`.
* **Sistema de Diseño (DESIGN.md):**
  * Estética **Dark Crystal Cyber-Shield**: fondos oscuros (`#110816`, `#180A20`), bordes y superficies glassmorphism (`.glass-panel` con blur 24px), acentos dorados (`#D7BA89`) para acciones principales/protección, resplandores lilas/púrpuras (`#B47EB3`, `#462255`).
  * Tipografías: Manrope (títulos y métricas) y DM Sans (cuerpo y controles).
  * Semáforo de riesgo: Seguro (`#6AD6A2`), Medio (`#E0CC72`), Alto (`#DD905D`), Crítico (`#D96179`). **Nunca comunicar riesgo solo mediante color** (acompañar siempre de icono, etiqueta y puntaje).

---

## 6. Contrato con el Backend y Huecos Abiertos

El cliente **no inventa endpoints ni campos**. Toda pantalla debe responder a un endpoint real documentado.

### Huecos abiertos a registrar y consultar (no asumir):
1. **Perfil de usuario (CoVE #1 / DPF-03):** No existe `GET /auth/me`. Para borrar la cuenta (`DELETE /api/v1/auth/me`), el backend exige contraseña (local) o `id_token` (Google). El cliente debe acordar cómo recibir `proveedor_auth` en el login o solicitar un endpoint de perfil.
2. **Catálogo de errores unificado (CoVE #4 / DPF-04):** Solo `ACCOUNT_NOT_VERIFIED` está formalizado. Se debe acordar el campo `code` de FastAPI antes de cerrar los tipos de `AppFailure`.
3. **OpenAPI / DTOs de respuesta (CoVE #5):** Los esquemas DTO deben validarse contra el OpenAPI generado por FastAPI en el backend.
4. **Detección de `tipo_entrada` (CoVE #6 / DP-09):** Heurística propuesta: si la entrada es una URL pura, enviar `url`; en caso contrario, `sms`. Validar con backend.

---

## 7. Reglas de Red y Sesión

* **Gestión de Tokens:**
  * `access_token` (30 min): Solo en memoria RAM, enviado vía `Authorization: Bearer <token>`.
  * `refresh_token` (30 días): Persistido exclusivamente en `flutter_secure_storage`.
* **Refresh Single-Flight:** Ante múltiples respuestas 401 concurrentes, el interceptor de Dio debe encolar las peticiones y disparar **una única llamada** a `POST /api/v1/auth/refresh`. Si el refresh es exitoso, se reintentan las peticiones. Si falla con 401/403, se destruyen los tokens locales y se redirige a login.
* **Logout:** Local en el cliente (limpieza de tokens y estado de sesión). El backend no tiene endpoint de revocación de refresh tokens.
* **Idempotencia y Reintentos:**
  * **NUNCA reintentar automáticamente** `POST /api/v1/analysis` ni los `POST` de verificación/reenvío de códigos.
  * Los botones de análisis y envío deben deshabilitarse mientras la petición HTTP está activa.
  * Solo peticiones GET idempotentes pueden tener reintento transparente ante fallo de red.
* **Timeouts:** 5 segundos para conexión, 10 segundos para recepción (objetivo p95 backend: 2.5s).
* **Mapeo de Errores:** Errores de red y códigos HTTP mapeados a la jerarquía `sealed class AppFailure` en `core/errors/`.

---

## 8. Seguridad y Privacidad en el Cliente

* **Texto de SMS confidencial:** **NUNCA** guardar en base de datos local, SQLite, SharedPreferences ni archivos temporales el contenido de un SMS analizado. Tampoco almacenar borradores de texto de SMS.
* **Logs limpios:** No imprimir en consola (`print` o `debugPrint`) ni registrar en logs bodies de peticiones, tokens JWT, contraseñas, códigos de verificación ni ID tokens de Google.
* **Almacenamiento local restringido:** Solo los tokens de autenticación se almacenan en `flutter_secure_storage`. Nunca guardar credenciales ni datos sensibles en `SharedPreferences`.
* **ID Token de Google:** Se obtiene a través de `google_sign_in`, se envía inmediatamente al backend (`POST /api/v1/auth/google`) y se descarta de la memoria del cliente.

---

## 9. Reglas de Dominio que Afectan la UI

* **Recálculo de Score Prohibido:** La app Flutter **nunca recalcula el score ni aplica fórmulas de riesgo**. El backend es la única fuente de verdad.
* **Visualización del Score:**
  * Mostrar siempre `score_total` y `puntos_por_capa`.
  * **NUNCA mostrar la suma directa de los hallazgos:** los hallazgos individuales conservan sus puntos brutos sin topar, mientras que el score total respeta los topes por capa y cortocircuitos.
* **Múltiples URLs (máx. 2):**
  * Los `hallazgos` y `fuentes_consultadas` detallados pertenecen a la URL dominante.
  * La URL secundaria únicamente expone `flags_sintacticos`. La UI debe rotular claramente cuál es la URL principal y cuál la secundaria.
* **Análisis Parcial:** Si `analisis_parcial == true`, mostrar una advertencia clara indicando que alguna fuente externa no respondió a tiempo y el resultado es preliminar.
* **Métricas vs Historial:** Eliminar un análisis del historial no reduce los contadores históricos de `metricas_usuario`. Incluir un texto aclaratorio en la pantalla de métricas para evitar que el usuario lo reporte como error.

---

## 10. Pruebas y Definición de Terminado

### Qué se prueba por feature:
* **Unit tests:** Mapeo de DTOs a modelos de dominio, validadores de formularios, heurística de `tipo_entrada`, controllers y mapeo de `AppFailure`.
* **Widget tests:** Renderizado y comportamiento de formularios, estados de carga y error en pantallas principales usando repositorios simulados (*mocks* con `mocktail`).
* **Golden tests:** Semáforo de riesgo en sus 4 niveles (`bajo`, `medio`, `alto`, `critico`) y badge de `analisis_parcial`.
* **Tests de red:** Concurrencia del interceptor de refresh (múltiples 401 disparan un solo refresh).

### Definición de terminado (DoD):
- [ ] Código sin advertencias (`flutter analyze` pasa sin errores ni warnings).
- [ ] Formato verificado con `dart format --output=none --set-exit-if-changed .`.
- [ ] Reglas de capas validadas con `dart run custom_lint`.
- [ ] Pruebas unitarias y de widgets pasando (`flutter test`).
- [ ] Textos visibles al usuario cargados desde `l10n/` en español.
- [ ] Cero persistencia o logging de texto de SMS, contraseñas o tokens.
- [ ] UI consistente con los tokens de `DESIGN.md`.
- [ ] **Sincronización documental obligatoria:** Actualizar siempre `docs/resumen_proyecto.json` (`ultimo_resumen_y_proximos_pasos`, decisiones técnicas o avances realizados) antes de dar por finalizada la interacción o tarea.

---

## 11. Límites del Agente

* **Archivos que NO debes editar manualmente:**
  * Archivos generados por `build_runner` (`*.g.dart`, `*.freezed.dart`).
  * Archivos de plataforma nativa (`android/`, `ios/`), a menos que sea estrictamente necesario para registrar permisos del sistema (SMS, compartir) o configuración de plugins.
  * Archivos de entorno (`.env*`) o pipelines de CI/CD.
* **Cuándo detenerse y preguntar:**
  * Al requerir paquetes externos no aprobados en `pubspec.yaml`.
  * Al encontrar inconsistencias entre la UI y los endpoints del backend.
  * Si se propone modificar los límites de validación (longitud máxima de URL 2,048 chars, código de 6 dígitos, etc.).
* **Sin refactors innecesarios:** Modificar únicamente los archivos asociados a la tarea en curso. No reorganizar carpetas completas ni renombrar contratos existentes.

---

## 12. Git, Ramas y Commits

* **Ramas:**
  * Features: `feat/nombre-feature`
  * Correcciones: `fix/descripcion-bug`
  * Documentación: `docs/tema`
* **Commits:** Formato *Conventional Commits*, indicando el Caso de Uso (CU-xx), Requerimiento (RF-xx) o regla (RN-xx) asociado:
  ```text
  feat(auth): implementar formulario y validacion de codigo de verificacion (CU-02, RF-06.2)
  fix(network): corregir race condition en refresh token interceptor
  test(analysis): agregar golden tests para semaforo de riesgo critico
  ```
* **Tamaño:** Cambios pequeños, atómicos y comprobables.

---

## 13. Decisiones Pendientes Frontend (DPF)

Cualquier trabajo relacionado con estas áreas debe verificar si la decisión ya fue ratificada en `docs/arquitectura_frontend_v1.json`:
* **DPF-01:** Ratificación del gestor de estado (`flutter_riverpod` vs `flutter_bloc`).
* **DPF-02:** Aprobación formal de las dependencias propuestas en `pubspec.yaml`.
* **DPF-03:** Contrato de perfil de usuario (`proveedor_auth` y nombre) para el flujo de borrado de cuenta.
* **DPF-04:** Catálogo unificado de códigos de error de FastAPI (`AppFailure`).
* **DPF-05:** Estrategia para Compartir en iOS (soporte nativo Share Extension vs flujo por portapapeles).

---

## Historial de Cambios

| Versión | Fecha | Resumen |
|---|---|---|
| 3.0 | 2026-11-02 | Adaptación completa de AGENTS.md para el frontend Flutter: fuentes de verdad, comandos de Dart/Flutter, reglas de arquitectura feature-first, convenciones, seguridad, reglas de dominio en UI, integración con DESIGN.md y decisiones DPF-01 a DPF-05. |
