# AntFish: Registro Definitivo de Decisiones Técnicas y de Arquitectura (ADR)

> **Documento Canónico de Arquitectura y Diseño.** Este archivo reúne el 100% de las decisiones técnicas, modelos de datos, flujos de seguridad y reglas de negocio acordadas para el desarrollo del backend en Python/FastAPI y su integración con la aplicación móvil AntFish.

---

## A. Contradicciones, Fuentes de Verdad y Estructura

### 1. Actualización de Requerimientos en AGENTS.md
* **Decisión:** Se actualiza `AGENTS.md` para especificar que las Secciones 1 a 8 contienen el levantamiento inicial de requerimientos junto con sus rectificaciones técnicas oficiales aprobadas por el equipo.
* **Por qué:** Elimina ambigüedades entre los prompts de la IA/desarrolladores y la especificación del proyecto, garantizando una única interpretación de las reglas.

### 2. Nombre Canónico del Documento de Contexto
* **Decisión:** El documento de especificaciones técnicas se denomina oficialmente `docs/CONTEXTO_AntFish_V2.md`. Las directivas generales para agentes se ubican en la raíz como `/AGENTS.md`.
* **Por qué:** Establece un estándar único de rutas y versiones, eliminando referencias cruzadas obsoletas.

### 3. Restauración de Secciones Técnicas §9.5 a §9.11 en CONTEXTO
* **Decisión:** Se restauran e integran explícitamente en `docs/CONTEXTO_AntFish_V2.md` las secciones correspondientes al flujo del análisis, SSRF, TLS, seguridad, convenciones e infraestructura (§9.5 a §9.11).
* **Por qué:** Asegura que el documento de contexto sea auto-contenido y posea máxima precedencia técnica sobre cualquier otro archivo.

### 4. Restauración de Secciones en el Modelo NoSQL
* **Decisión:** Se reponen las secciones `patrones_de_acceso`, `motor_de_puntuacion` y `supuestos_de_capacidad` en `antfish_modelo_nosql.json`.
* **Por qué:** Mantiene la trazabilidad técnica directa entre los patrones de acceso $P1$ a $P11$ y las entidades NoSQL definidas.

### 5. Restauración del Hallazgo en el Ejemplo JSON
* **Decisión:** Se restaura el hallazgo `TXT_SOLICITUD_DATOS` (+10 pts) en el documento de ejemplo de `antfish_modelo_nosql.json`.
* **Por qué:** Restablece la coherencia matemática con el objeto `puntos_por_capa.texto: 20` (+10 pts de `TXT_URGENCIA` y +10 pts de `TXT_SOLICITUD_DATOS`). → Modificado por ADR #56

### 6. Persistencia de `respuestas_apis`
* **Decisión:** La colección `respuestas_apis` se mantiene activa. La persistencia de auditoría la realiza directamente `AnalysisRepository` dentro de la misma transacción de sesión ACID del análisis.
* **Por qué:** Garantiza la trazabilidad y auditoría de llamadas externas sin introducir repositorios secundarios innecesarios.

---

## B. URLs Múltiples

### 7. Selección de URLs en SMS Múltiples
* **Decisión:** Ante un SMS con 3 o más enlaces, el motor extrae todas las URLs en memoria, evalúa la heurística sintáctica (Capa 2) a cada una y selecciona las **2 URLs de mayor riesgo sintáctico**. En caso de empate en puntos sintácticos, se eligen por orden de aparición en el texto.
* **Por qué:** Protege las cuotas de las APIs externas y garantiza que el tiempo total de respuesta permanezca por debajo del umbral $p95 \le 2.5\text{s}$ (RNF-01).

### 8. Consultas Exteriores y Selección de URL Dominante
* **Decisión:** Se consultan en paralelo las 2 URLs seleccionadas contra las APIs externas. La **URL dominante** final (almacenada en `dominio_principal` y utilizada para asignar la puntuación global) se determina evaluando el riesgo total combinado (APIs + Sintaxis).
* **Por qué:** Previene falsos negativos en escenarios donde una URL sintácticamente limpia se encuentra en listas negras activas de phishing.

### 9. Desglose de Hallazgos y RF-03.3
* **Decisión:** RF-03.3 se acota a la URL dominante. Los arreglos `hallazgos`, `fuentes_consultadas` y `puntos_por_capa` pertenecen unívocamente a la URL dominante. La URL secundaria conserva sus alertas sintácticas en `urls_extraidas[].flags_sintacticos`.
* **Por qué:** Mantiene un esquema NoSQL plano sin anidamientos redundantes, proporcionando al usuario claridad sobre la amenaza principal.

---

## C. Cortocircuito por Marca

### 10. Mecanismo de Suplantación Directa de Marca
* **Decisión:** Es un disparador explícito de cortocircuito (*override*), no una regla en `reglas_heuristicas`. Se activa cuando un subdominio o estructura coincide con `marcas_protegidas` pero el dominio registrado no pertenece a `dominios_oficiales`.
* **Por qué:** Permite elevar el score total a un piso mínimo de 80 pts sin violar el tope estricto de 30 pts de la Capa 2 ni alterar la ponderación heurística base.

### 11. Registro del Cortocircuito por Marca
* **Decisión:** No requiere un código en `reglas_heuristicas`. Se marca estableciendo `cortocircuito: true` y registrando la bandera descriptiva en las alertas sintácticas de la URL.
* **Por qué:** Mantiene aislada la lógica de reglas heurísticas ponderadas de las reglas de negocio de *override* de seguridad. → Modificado por ADR #52

### 12. Mapeo del Motivo de Cortocircuito
* **Decisión:** Se añade el campo `"motivo_cortocircuito": "lista_negra" | "suplantacion_marca" | null` al esquema de `analisis`. Si ambas condiciones coinciden, prevalece `"lista_negra"`.
* **Por qué:** Proporciona trazabilidad completa en el modelo de datos y permite al cliente Flutter mostrar advertencias específicas según la causa raíz. → Modificado por ADR #52

---

## D. Autenticación y Usuarios

### 13. Expiración de Access Token
* **Decisión:** Se configura `ACCESS_TOKEN_EXPIRE_MINUTES = 30` en `core/config.py`.
* **Por qué:** Brinda un balance idóneo entre seguridad y comodidad de uso en dispositivos móviles.

### 14. Manejo de Refresh Token
* **Decisión:** Refresh Token *stateless* firmado con `JWT_REFRESH_SECRET` (expiración de 30 días). El endpoint `/api/v1/auth/refresh` valida la firma criptográfica y verifica en MongoDB que `estado_cuenta == "activa"` mediante `AuthService`. Esta estrategia aplica de manera idéntica tanto para cuentas con método de acceso `local` como `google`.
* **Por qué:** Evita almacenar y gestionar listas negras de tokens en Redis sin renunciar a la revocación inmediata si una cuenta es inhabilitada, manteniendo una experiencia homogénea independientemente del proveedor de autenticación. → Modificado por ADR #68

### 15. Verificación de Usuario en `deps.py`
* **Decisión:** La comprobación de estado de cuenta se realiza invocando la capa de servicio `AuthService.get_active_user(user_id)`.
* **Por qué:** Respeta la arquitectura en capas impidiendo que el módulo `api` importe directamente repositorios de infraestructura.

### 16. Borrado y Ciclo de Vida de Cuenta (O12)
* **Decisión:** `DELETE /api/v1/auth/me` exige reautenticación obligatoria en el *body* según el método de acceso de la cuenta: si la cuenta es `local`, exige `{ "password": "..." }`; si la cuenta es `google` o vinculada, exige `{ "id_token": "..." }` con un token reciente de Google validado criptográficamente contra el `google_sub` del usuario. Si no se provee la credencial requerida o es inválida, se rechaza con HTTP `401 Unauthorized`. Tras la validación, ejecuta una anonimización de la cuenta (`estado_cuenta = "eliminada"`, ofuscando el email para liberar la restricción de unicidad del índice I1) y elimina físicamente en transacción ACID las colecciones `analisis`, `metricas_usuario` y `respuestas_apis`.
* **Por qué:** Evita borrados accidentales o maliciosos desde sesiones activas sin confirmación del titular, se adapta al método de autenticación del usuario, permite volver a registrarse con el mismo correo en el futuro y cumple con los estándares de purga de datos. → Modificado por ADR #54

---

## E. Estructura, Capas e Infraestructura

### 17. Inyección de Dependencias y `container.py`
* **Decisión:** Se autoriza `app/container.py` como *Composition Root*. La capa `deps.py` obtiene la instancia de `Container` desde `request.app.state.container` y expone métodos que retornan únicamente servicios de aplicación.
* **Por qué:** Desacopla la capa de presentación de la infraestructura técnica y cumple con las reglas estrictas de `.importlinter`.

### 18. Unit of Work, Transacciones ACID y Docker Compose
* **Decisión:** Se aprueba la creación de `repositories/mongo/unit_of_work.py`. Se autoriza la modificación de `docker-compose.yml` para iniciar MongoDB con un Replica Set de nodo único (`mongod --replSet rs0`).
* **Por qué:** Habilita el soporte de transacciones ACID en PyMongo Async para operaciones compuestas destructivas o multicolección.

### 19. Manejo de Sufijos Públicos en `engine/`
* **Decisión:** Se adopta la opción de embeber la tabla de sufijos públicos como una constante local o JSON estático dentro del paquete `engine/`.
* **Por qué:** Garantiza que el paquete `engine/` sea 100% puro, sin dependencias de terceros, I/O ni llamadas a la red.

### 20. Inicialización de Esquemas e Índices
* **Decisión:** La creación de índices y validaciones de esquema se ejecuta de forma idempotente en el evento `lifespan` de FastAPI en `app/main.py`, invocando a `app/repositories/mongo/init_db.py`.
* **Por qué:** Garantiza la correcta configuración de MongoDB al desplegar el contenedor sin requerir scripts manuales.

### 21. Ubicación de la Regla de Caché Redis
* **Decisión:** La evaluación de si las 3 APIs respondieron `ok` antes de escribir en caché (RF-04.3) se traslada a `AnalysisService`. `ReputationCacheRepository` únicamente ejecuta comandos atómicos de Redis.
* **Por qué:** Garantiza que la lógica de negocio permanezca en la capa de servicios y no en la capa de persistencia.

### 22. Jerarquía de Excepciones
* **Decisión:** Nombre base oficial `AntFishError`. Jerarquía unificada con el sufijo `Error`: `AntFishError`, `UnauthorizedError`, `DomainNotFoundError`, `QuotaExceededError`, `RateLimitExceededError`, `AccountNotVerifiedError`, `InvalidVerificationCodeError`, `VerificationAttemptsExceededError`, `EmailDeliveryError` y `GoogleTokenInvalidError`.
* **Por qué:** Estandariza el tratamiento de errores en todas las capas del backend, cubriendo los nuevos escenarios de autenticación federada y verificación por correo, y facilita el mapeo automático en `api/errors.py`.

### 23. Inclusión de Raíz y Esquemas en el JSON de Arquitectura
* **Decisión:** Se agregan los archivos de la raíz (`pyproject.toml`, `.importlinter`, `Dockerfile`, `docker-compose.yml`, `AGENTS.md`, `.env.example`, `docs/`), los esquemas de API (`app/api/schemas/auth.py`, `analysis.py`, `metrics.py`) y los nuevos módulos de autenticación y verificación (`clients/resend_email.py`, `clients/google_identity.py`, `services/verification_service.py`, `repositories/redis/verification_repository.py`) a la especificación de arquitectura.
* **Por qué:** Mantiene la especificación del proyecto reflejando con fidelidad absoluta la estructura real del repositorio y sus capas de soporte.

---

## F. Tecnología

### 24. Driver de MongoDB
* **Decisión:** Uso exclusivo del driver asíncrono oficial **PyMongo Async** (`pymongo.AsyncMongoClient`). Se descarta Motor.
* **Por qué:** Es el driver oficial soportado por MongoDB para aplicaciones asíncronas modernas en Python 3.11+.

### 25. Hashing de Contraseñas
* **Decisión:** Uso de la librería **`argon2-cffi`** en `core/security.py`.
* **Por qué:** Implementa de forma nativa el algoritmo Argon2id requerido por las especificaciones de seguridad del proyecto.

### 26. Versión de Python
* **Decisión:** Se fija la versión oficial en **Python 3.11**.
* **Por qué:** Ofrece las mejoras de rendimiento en el tiempo de ejecución asíncrono (`asyncio`) requeridas para el backend.

### 27. Pruebas de Carga y Rendimiento
* **Decisión:** La herramienta oficial aprobada es **Locust**.
* **Por qué:** Permite definir escenarios de prueba asíncronos y verificar la latencia $p95 \le 2.5\text{s}$ establecida en el RNF-01.

---

## G. Entrada, APIs y Comportamiento

### 28. Clasificación y Normalización de Entradas
* **Decisión:** El cliente Flutter envía explícitamente `tipo_entrada` (`sms` | `url`). Si un SMS no contiene enlaces, se omiten las Capas 1 y 2, registrando `dominio_principal: null`. URLs sin esquema se normalizan con `https://`. Si `tipo_entrada: "url"` no contiene un dominio válido, la API responde HTTP `422 Unprocessable Entity`.
* **Por qué:** Garantiza la validación en la capa de entrada y evita errores en el motor de procesamiento.

### 29. Longitudes Máximas
* **Decisión:** Longitud máxima para texto de SMS: **1,600 caracteres**. Longitud máxima para URL: **2,048 caracteres**.
* **Por qué:** Previene abusos de memoria y ataques de Denegación de Servicio (DoS) sobre las expresiones regulares del motor heurístico.

### 30. Variantes y Tratamiento de APIs Externas
* **Decisión:**
  * **Google Web Risk:** Lookup API (`uris:search`).
  * **PhishTank:** Consultas puntuales API REST (`checkurl`).
  * **VirusTotal:** HTTP 404 se procesa como `ok` (`positivo: false`, `detecciones: 0`). El backend no envía URLs a escanear activamente para no violar la regla de no visitar URLs.
* **Por qué:** Minimiza latencias y respeta la política estricta contra SSRF.

### 31. Clave de Caché en Redis y Sanitización
* **Decisión:** Se remueve la *query string* de las URLs antes de consultar APIs o guardar en BD. La clave en Redis se construye como `rep:{url_normalizada}`.
* **Por qué:** Protege la privacidad evitando almacenar o transmitir tokens de sesión presentes en la URL y resuelve la ambigüedad con acortadores de enlaces. → Modificado por ADR #60

### 32. Estados de Fuentes Consultadas
* **Decisión:** Se añade el valor `error` al enum (`ok` | `timeout` | `rate_limit` | `error`). Si el backend agota su cuota local configurada para una API, el estado de dicha fuente se registra como `rate_limit`.
* **Por qué:** Brinda trazabilidad detallada en las auditorías de llamadas a servicios de terceros.

### 33. Resiliencia de Infraestructura
* **Decisión:**
  * **Caída de Redis:** Comportamiento diferenciado por dominio funcional:
    * *Caché de reputación y cuotas de APIs:* Falla abierto (*fail open*), omitiendo caché y cuotas locales para consultar APIs de reputación directamente.
    * *Verificación y autenticación:* Falla cerrado (*fail closed*); si Redis no está disponible, no se despachan ni validan códigos de verificación o recuperación, respondiendo HTTP `503 Service Unavailable`.
  * **Fallo de persistencia en Mongo:** Responde HTTP `503 Service Unavailable`.
  * **Arranque con Mongo vacío:** El evento `lifespan` ejecuta la siembra inicial idempotente desde `initial_data.json`.
* **Por qué:** Prioriza la disponibilidad del servicio central de análisis sin comprometer la seguridad crítica ni la integridad del proceso de autenticación de usuarios.

### 34. Rate Limiting en Capa de Presentación
* **Decisión:**
  * `POST /api/v1/auth/login` y `POST /api/v1/auth/google`: Máximo 5 intentos por minuto por IP.
  * `POST /api/v1/auth/resend-code`: Máximo 3 solicitudes por hora por usuario (`user_id`), controlado en Redis (`reenvio:{user_id}`).
  * `POST /api/v1/analysis`: Máximo 20 peticiones por minuto por usuario (`user_id`).
  * Administrado por `services/rate_limiter.py` y `repositories/redis/rate_limit_repository.py`. Si se excede, retorna HTTP `429 Too Many Requests`.
* **Por qué:** Evita ataques de fuerza bruta en autenticación y abuso en el envío de correos transaccionales, además de proteger las cuotas de las APIs de reputación. → Modificado por ADR #67

### 35. Sanitización de URLs Extraídas
* **Decisión:** Se eliminan los parámetros de consulta (*query parameters*) en los elementos del arreglo `urls_extraidas[]` antes de persistir en MongoDB.
* **Por qué:** Evita la fuga o almacenamiento inintencionado de credenciales o identificadores personales en la base de datos. → Modificado por ADR #60

### 36. Métricas Históricas de Usuario
* **Decisión:** Las estadísticas en `metricas_usuario` son acumulados históricos. Eliminar un análisis del historial no decrementa estos contadores.
* **Por qué:** Preserva la integridad de la métrica histórica global de amenazas detectadas para el usuario.

### 37. Caché en Memoria de Reglas Heurísticas
* **Decisión:** `RulesProvider` implementa un caché local en memoria RAM con un TTL de 3,600 segundos (1 hora).
* **Por qué:** Elimina consultas repetitivas a MongoDB en cada escaneo sin añadir infraestructura adicional.

### 38. Ubicación del Endpoint `/health`
* **Decisión:** El controlador reside en `app/api/v1/health.py`, pero se registra en FastAPI en la ruta raíz global `GET /health`.
* **Por qué:** Facilita la integración directa con balanceadores de carga y health checks de orquestadores de contenedores.

### 39. Configuración de Cuotas Reales de APIs
* **Decisión:**
  * **VirusTotal:** `VT_LIMIT_PM = 4`, `VT_LIMIT_DAILY = 500`.
  * **Google Web Risk:** `GWR_LIMIT_PM = 600`, `GWR_LIMIT_DAILY = 100000`.
  * **PhishTank:** `PT_LIMIT_PM = 400`, `PT_LIMIT_DAILY = 2000`.
  * Control gestionado con claves duales `cuota:{api}:pm` (TTL 60s) y `cuota:{api}:daily` (TTL 86400s) en Redis.
* **Por qué:** Protege las credenciales contra bloqueos o suspensión de cuota por parte de proveedores externos y activa la degradación grácil (`analisis_parcial: true`) de forma transparente.

### 40. Integración con PhishTank
* **Decisión:** Consulta puntual API REST a `https://checkurl.phishtank.com/checkurl/` enviando de forma obligatoria el encabezado `User-Agent: AntFish/1.0 (antfish-app)` mediante HTTPX asíncrono.
* **Por qué:** Evita la sobrecarga de mantener un proceso secundario de descarga y sincronización del archivo `online-valid.json` (~80 MB) en el servidor.

---

## H. Autenticación Federada y Verificación por Correo

### 41. Proveedor de Correo Transaccional (Resend)
* **Decisión:** Se adopta **Resend** como proveedor oficial de correo transaccional para la entrega de códigos de verificación de cuenta y recuperación de contraseña. Se consume mediante su API HTTP REST desde `clients/resend_email.py` utilizando `httpx.AsyncClient`. Credenciales configuradas en `RESEND_API_KEY` y dirección remitente en `EMAIL_FROM`.
* **Por qué:** Ofrece una API REST moderna y rápida, excelente entregabilidad, soporte nativo para peticiones HTTP asíncronas sin necesidad de configurar ni mantener servidores SMTP bloqueantes, y alta confiabilidad para códigos efímeros.

### 42. Código Numérico de 6 Dígitos vs. Enlace de Verificación
* **Decisión:** La verificación de correo y recuperación de cuenta se implementa exclusivamente mediante un **código numérico de 6 dígitos**, descartando enlaces o magic links. El código tiene una vigencia estricta de **10 minutos**, un límite máximo de **5 intentos fallidos** y un tope de **3 reenvíos por hora** por usuario. El código se almacena en memoria hash (HMAC-SHA256 con `HMAC_PEPPER`), nunca en texto plano.
* **Por qué:** Los códigos de 6 dígitos proporcionan una experiencia de usuario superior en aplicaciones móviles (copiar/pegar o tipeo directo en la app Flutter sin requerir deep links complejos ni redirecciones de navegador web), permitiendo control estricto de intentos y previniendo ataques de intercepción o reutilización.

### 43. Almacenamiento y Resiliencia de Verificación en Redis (Fail-Closed)
* **Decisión:** El estado y digesto del código temporal se almacenan en Redis bajo la clave `verif:{user_id}` con un TTL de 600 segundos (10 minutos). A diferencia de la caché de reputación que opera en modo *fail-open*, el módulo de verificación opera estrictamente como **fail-closed**: si Redis no está disponible o falla la conexión, el backend deniega la emisión o validación de códigos y responde HTTP `503 Service Unavailable`.
* **Por qué:** Garantiza la seguridad e integridad del acceso: no es admisible permitir accesos o activaciones de cuenta sin validar fehacientemente el código contra un almacén seguro e inviolable.

### 44. Google Sign-In con Validación de ID Token en Backend
* **Decisión:** Para el acceso con Google, la aplicación Flutter utiliza el SDK oficial de Google Sign-In para autenticar al usuario y remitir el ID token criptográfico al endpoint `POST /api/v1/auth/google`. El backend valida el token de Google y, tras su verificación, emite sus propios tokens de sesión (Access Token JWT de 30 min y Refresh Token de 30 días). El backend **no** almacena el ID token de Google. Las cuentas creadas con Google nacen directamente con `estado_cuenta = "activa"` y `email_verificado = true`.
* **Por qué:** Sigue las mejores prácticas de autenticación federada OpenID Connect: el backend delega la captura de credenciales al proveedor certificado pero conserva el control total de la sesión, revocación y autorización en su propio ecosistema JWT.

### 45. Librería de Validación de Google Identity (`google-auth`)
* **Decisión:** Se utiliza la librería oficial **`google-auth`** en `clients/google_identity.py` (`google.oauth2.id_token.verify_oauth2_token`) para la verificación criptográfica del Google ID Token. Se comprueba la firma con las claves públicas rotativas de Google, la fecha de caducidad, que la audiencia coincida estrictamente con `GOOGLE_CLIENT_ID` y que el correo reporte `email_verified = true`.
* **Por qué:** Garantiza la validación criptográfica conforme a las especificaciones oficiales de Google, evitando implementaciones manuales propensas a vulnerabilidades en la verificación de firma o expiración.

### 46. Contraseña Opcional en el Modelo de Usuarios
* **Decisión:** El campo `password_hash` en la colección `usuarios` pasa a ser opcional (`string | null`). Es obligatorio únicamente cuando `proveedor_auth = "local"`. Para usuarios con `proveedor_auth = "google"`, `password_hash` se establece en `null` y se registra el identificador federado `google_sub`.
* **Por qué:** Los usuarios que inician sesión mediante federación de identidad (Google Sign-In) no poseen una contraseña local en AntFish, eliminando vectores innecesarios de almacenamiento de credenciales.

### 47. Vinculación de Cuentas por Correo Verificado
* **Decisión:** Si un usuario registrado originalmente con credenciales locales (`proveedor_auth = "local"`) inicia sesión con Google utilizando la misma dirección de correo electrónico, y Google certifica que `email_verified = true`, el sistema vincula automáticamente la cuenta asignando el campo `google_sub` sin alterar `proveedor_auth = "local"` y preservando su `password_hash`. Si el correo en Google no está verificado, la solicitud es rechazada con HTTP `409 Conflict`.
* **Por qué:** Evita la duplicación de cuentas y fricción para el usuario legítimo, asegurando simultáneamente que cuentas de terceros sin verificación no puedan secuestrar cuentas locales existentes.

### 48. Borrado de Cuenta con Reautenticación por Método
* **Decisión:** En `DELETE /api/v1/auth/me`, el mecanismo de reautenticación depende del método de acceso de la cuenta: si la cuenta es `local`, se exige `{ "password": "..." }` en el cuerpo; si es `google` o vinculada, se exige `{ "id_token": "..." }` reciente de Google, validándolo criptográficamente contra el `google_sub` registrado. La ausencia o invalidez de la credencial resulta en HTTP `401 Unauthorized`.
* **Por qué:** Protege la cuenta contra solicitudes no autorizadas de borrado destructivo originadas desde sesiones activas comprometidas, adaptando el desafío al factor de autenticación que corresponde a cada usuario. → Modificado por ADR #54

### 49. Recuperación de Contraseña mediante Código Resend y Revocación de Sesión
* **Decisión:** Se establece el flujo de recuperación de contraseña en dos pasos: `POST /api/v1/auth/password/forgot` (genera y despacha el código de 6 dígitos vía Resend) y `POST /api/v1/auth/password/reset` (valida el código y aplica la nueva contraseña hasheada con Argon2id). El flujo adopta las mismas reglas de 10 min de vigencia, máx. 5 intentos y máx. 3 reenvíos/hora. Al completarse con éxito, se actualiza el campo `password_changed_at` en `usuarios` y se invalidan de forma inmediata todos los Refresh Tokens emitidos antes de esa marca de tiempo.
* **Por qué:** Permite recuperar el acceso a usuarios legítimos de cuentas locales de forma segura, garantizando la revocación instantánea de cualquier sesión activa que pudiera estar en manos de un atacante. → Modificado por ADR #68

### 50. Depuración Física de Cuentas Pendientes de Verificación (48 horas)
* **Decisión:** Las cuentas en `estado_cuenta = "pendiente_verificacion"` que permanezcan sin verificar tras 48 horas desde su creación (`fecha_registro`) son eliminadas físicamente de MongoDB mediante una tarea programada del Sistema. Estas cuentas no verificadas nunca generan documentos en `analisis` ni en `metricas_usuario`.
* **Por qué:** Previene la ocupación innecesaria de almacenamiento y la acumulación de registros huérfanos por intentos de registro abandonados o ataques de spam de registros. → Modificado por ADR #65

---

## I. Cierre del Modelo de Datos v2.1

### 51. Normalización de URLs y Trazabilidad en `respuestas_apis`
* **Decisión:** En la colección `respuestas_apis` se agregan los campos `url_normalizada` (string, conservando el protocolo, dominio y ruta sin query, fragmento ni userinfo) y `dominio`. Se persisten las respuestas de auditoría para las hasta 2 URLs analizadas por mensaje (máx. 6 documentos por análisis: 2 URLs × 3 APIs). El TTL de auditoría se fija en 30 días (`expira_en = fecha + 30 días`), respaldado por el índice TTL I8 (`expira_en: 1`) y el índice compuesto I9 (`user_id: 1, analisis_id: 1`).
* **Por qué:** Resuelve la ambigüedad identificada en la auditoría técnica (CoVE pregunta 6), permitiendo identificar con precisión qué API evaluó qué URL sin retener parámetros sensibles de consulta, optimizando el ciclo de vida del almacenamiento.

### 52. Eliminación de Booleano Redundante y Formalización de `motivo_cortocircuito`
* **Decisión:** Se elimina el campo booleano `cortocircuito` del esquema de `analisis`. El estado de cortocircuito queda determinado unívocamente por `motivo_cortocircuito: "lista_negra" | "suplantacion_marca" | null`. Existe cortocircuito si y solo si `motivo_cortocircuito != null`. En caso de concurrencia de ambas condiciones, prevalece estrictamente `"lista_negra"`. Cierra la decisión pendiente DP-11.
* **Por qué:** Elimina duplicidad de datos en la colección, simplifica las validaciones estructurales en MongoDB y descarta discrepancias entre una bandera booleana y la causa técnica del cortocircuito.

### 53. Semántica de `analisis_parcial` con Múltiples URLs
* **Decisión:** El atributo `analisis_parcial = true` se activa si falla cualquier consulta a cualquier API sobre cualquiera de las hasta 2 URLs analizadas del mensaje. Sin embargo, los arreglos `fuentes_consultadas`, `hallazgos` y el desglose `puntos_por_capa` describen exclusivamente a la URL dominante. Cierra la decisión pendiente DP-05.
* **Por qué:** Garantiza veracidad técnica e integridad diagnóstica reportando cualquier degradación en las fuentes externas del mensaje, al tiempo que mantiene una estructura de respuesta limpia y legible centrada en la amenaza de mayor impacto.

### 54. Anonimización Completa en Baja de Cuenta (O12)
* **Decisión:** En `DELETE /api/v1/auth/me`, tras validar la reautenticación y purgar en cascada bajo transacción ACID los registros de `analisis`, `metricas_usuario` y `respuestas_apis`, el documento en `usuarios` se anonimiza: `email = "deleted_<id>@deleted.local"`, `password_hash = null`, `google_sub = null`, `nombre = null`, `email_verificado = false`, `estado_cuenta = "eliminada"` y `fecha_eliminacion = ISODate`. El `$jsonSchema` permite estos campos nulos únicamente si `estado_cuenta == "eliminada"`. Las operaciones de login y refresh rechazan cuentas eliminadas con HTTP 401. Cierra la decisión pendiente DP-06.
* **Por qué:** Libera el índice único I1 (`email: 1`) permitiendo que el usuario legítimo pueda registrarse nuevamente en el futuro, elimina cualquier residuo de información de identificación personal cumpliendo normativas de privacidad, y previene la reactivación no autorizada de sesiones previas.

### 55. Normalización Canónica de Correos e Índice I1 sin Collation
* **Decisión:** Las direcciones de correo se normalizan en la aplicación (FastAPI) convirtiéndolas a minúsculas y removiendo espacios antes de consultar, insertar o comparar en base de datos. El índice único I1 (`email: 1`) en MongoDB opera como índice estándar sin collation.
* **Por qué:** Previene la degradación de rendimiento y la complejidad operativa asociadas a collations en MongoDB, asegurando consistencia e interoperabilidad directa desde el punto de entrada de la API.

### 56. Nomenclatura Estricta de Reglas Heurísticas y Unificación TXT
* **Decisión:** Los códigos de reglas heurísticas utilizan prefijos semánticos fijos: `URL_` para Capa 2, `TXT_` para Capa 3 y `API_` para Capa 1. Se unifica el identificador histórico `TXT_URGENCIA` al canónico `TXT_LENGUAJE_URGENCIA`. Los únicos códigos fijados para la Capa 3 son `TXT_LENGUAJE_URGENCIA` (+10 pts) y `TXT_SOLICITUD_DATOS` (+10 pts).
* **Por qué:** Corrige la disparidad numérica en el ejemplo del modelo y asegura trazabilidad uniforme entre los hallazgos producidos por el motor de análisis y el catálogo de reglas heurísticas.

### 57. Reclasificación de Índices I3 e I4 como Diferidos
* **Decisión:** Se retiran de la especificación activa v1 de MongoDB los índices I3 (`mensaje_hash: 1`) e I4 (`urls_extraidas.dominio: 1`). Quedan formalizados como "índices diferidos" para su eventual creación únicamente si se incorpora analítica cruzada de campañas de smishing entre usuarios (rama E de casos de uso). La relación R10 se reclasifica como diferida.
* **Por qué:** Ningún endpoint operativo de la v1 consulta por `mensaje_hash` ni por `urls_extraidas.dominio`. Su retiro optimiza el consumo de memoria RAM y la velocidad de escritura en transacciones ACID sin comprometer ninguna funcionalidad actual.

### 58. Paginación de Historial por Cursor Compuesto (I2)
* **Decisión:** El índice I2 de la colección `analisis` se define como compuesto `{ "user_id": 1, "fecha": -1, "_id": -1 }`. La paginación en `GET /api/v1/analysis` emplea como cursor opaco para el cliente el par `(fecha, _id)`, retornando 20 elementos por página.
* **Por qué:** Proporciona un ordenamiento estrictamente determinista y previene omisiones o duplicidades durante la navegación de historial en casos donde múltiples análisis coincidan en la misma marca de tiempo (`fecha`).

### 59. Separación de Responsabilidades en Validación: `$jsonSchema` + `$expr`
* **Decisión:** MongoDB valida la coherencia relacional y estructural de datos mediante `$jsonSchema` y expresiones `$expr` (`validaciones_mongo`): rangos de puntuación (0-100), correspondencia entre `score_total` y `nivel_riesgo`, condicionamiento de `motivo_cortocircuito` con sus respectivos pisos ($\ge 95$ para lista negra, $\ge 80$ para marca), tipado de `mensaje_hash` según `tipo_entrada`, topes de `puntos_por_capa` (60, 30, 20), invariantes de contadores en `metricas_usuario` y estados de cuenta en `usuarios`. La formulación matemática exacta del scoring permanece con exclusividad en `engine/`. Se adopta `validationLevel: "strict"` y `validationAction: "error"` [SUPUESTO por confirmar].
* **Por qué:** Constituye una barrera inmutable de integridad a nivel de base de datos que evita la persistencia de estados corruptos o contradictorios, sin acoplar la base de datos con lógica algorítmica de negocio.

### 60. Normalización de URLs en Almacenamiento y Claves de Caché
* **Decisión:** Tanto los elementos del arreglo `urls_extraidas[]` como la clave de caché de reputación en Redis (`rep:{url_normalizada}`) utilizan la URL normalizada: protocolo (`https://`), dominio y ruta (`path`), pero descartando estrictamente parámetros de consulta (`query`), fragmentos (`#`) e información de usuario (`userinfo`). Amplía y consolida los ADR #31 y #35.
* **Por qué:** Salvaguarda la privacidad del usuario eliminando identificadores y credenciales presentes en cadenas de consulta, mientras mantiene la diferenciación por ruta requerida para acortadores de enlaces y páginas falsas en servicios compartidos.

### 61. Idempotencia de la Siembra de Reglas y Marcas
* **Decisión:** La siembra inicial automática ejecutada en el lifespan de FastAPI (`app/repositories/mongo/init_db.py`) se condiciona estrictamente a que las colecciones `reglas_heuristicas` y `marcas_protegidas` se encuentren vacías (`count_documents == 0`). El script `scripts/seed_rules.py` se conserva como la herramienta exclusiva de reinicialización o restablecimiento manual. El ADR #33 se mantiene sin alteraciones.
* **Por qué:** Garantiza la seguridad en despliegues e inicios de contenedor evitando sobrescribir modificaciones operativas o reglas ajustadas en caliente en producción.

---

## J. Endurecimiento de Autenticación

### 62. Secuencia de Validación en Login y Manejo Uniforme de Errores
* **Decisión:** En `POST /api/v1/auth/login`, la comprobación criptográfica de la contraseña con Argon2id se realiza obligatoriamente antes de evaluar el estado de verificación de la cuenta. Credenciales inválidas o usuarios inexistentes devuelven un error HTTP 401 genérico (`UnauthorizedError`). El error HTTP 403 Forbidden con código `ACCOUNT_NOT_VERIFIED` se emite únicamente si la contraseña suministrada fue matemáticamente válida pero la cuenta se encuentra en `pendiente_verificacion`.
* **Por qué:** Bloquea la enumeración de usuarios y previene que un atacante descubra si una dirección de correo electrónico está registrada o pendiente de verificación mediante intentos de acceso no autorizados.

### 63. Vinculación Google sobre Cuentas en Pendiente de Verificación
* **Decisión:** Si un usuario inicia sesión con Google (`POST /api/v1/auth/google`) utilizando un correo que ya existe en `usuarios` con `estado_cuenta == "pendiente_verificacion"` y Google certifica `email_verified = true`: se descarta cualquier `password_hash` preexistente (fijándolo en `null`), se asigna `proveedor_auth = "google"` [SUPUESTO por confirmar], `estado_cuenta = "activa"`, `email_verificado = true`, `fecha_verificacion = ahora` y `password_changed_at = ahora`. Para cuentas locales que ya estaban activas, se mantiene la regla del ADR #47 (conservan `proveedor_auth = "local"` y su `password_hash`, incorporando `google_sub`).
* **Por qué:** Neutraliza el ataque de secuestro previo de cuenta (*pre-account takeover*): si un tercero malintencionado registró preventivamente el correo de una víctima sin poder verificarlo, el titular legítimo autenticado mediante Google Identity toma control de su cuenta, revocando cualquier credencial espuria previa.

### 64. Manejo de Registro sobre Cuentas Existentes y Aceptación de Enumeración en 409
* **Decisión:** En `POST /api/v1/auth/register`, si el correo suministrado ya existe: (a) Si la cuenta está en `estado_cuenta == "pendiente_verificacion"`, se sobrescriben `nombre` y `password_hash`, se emite un nuevo código de verificación (computado contra el límite de `reenvio:{user_id}`) y se reinicia `fecha_registro = ahora` [SUPUESTO por confirmar]; (b) Si la cuenta se encuentra en estado `activa` o `suspendida`, la API responde HTTP 409 Conflict. Se acepta y documenta formalmente la enumeración de correos por HTTP 409 en registro como un riesgo conocido y asumido para permitir la experiencia legítima de usuario.
* **Por qué:** Facilita que usuarios que abandonaron un registro inicial inconcluso puedan retomar el alta sin bloqueos de soporte técnico, manteniendo los controles anti-spam de entrega de correo.

### 65. Purga Automática de Cuentas No Verificadas por Índice TTL (I11)
* **Decisión:** Se elimina el uso de "tarea programada", "tarea del Sistema" o "scheduler" para depurar cuentas no verificadas (modificando ADR #50 y RN-20). Se sustituye íntegramente por el índice TTL parcial en MongoDB I11 sobre la colección `usuarios`: `{ "fecha_registro": 1 }`, con `expireAfterSeconds: 172800` (48 horas) y filtro parcial `{ "estado_cuenta": "pendiente_verificacion" }`.
* **Por qué:** Prescinde de componentes de programación externos (schedulers, cron o dependencias añadidas), delegando la eliminación física higiénica en el ciclo nativo de purga TTL de MongoDB (~60 s), mientras que el login deniega inmediatamente el acceso a dichas cuentas.

### 66. Respuesta Uniforme en Recuperación de Contraseña (Forgot Password)
* **Decisión:** El endpoint `POST /api/v1/auth/password/forgot` retorna siempre HTTP 200 OK con un mensaje uniforme e idéntico (`"Si el correo está registrado y activo, se ha enviado un código de recuperación."`), independientemente de si el correo existe o no en el sistema. El código solo se emite y envía vía Resend si el usuario existe, se encuentra activo y posee `password_hash != null` (cuentas registradas exclusivamente mediante Google no reciben código).
* **Por qué:** Elimina vectores de enumeración de cuentas a través de las solicitudes de restablecimiento de contraseña.

### 67. Rate Limiting Compartido y Contratos con Resolución Interna de Usuario
* **Decisión:** El endpoint `POST /api/v1/auth/password/forgot` comparte el contador en Redis `reenvio:{user_id}` (máx. 3 por hora) con `POST /api/v1/auth/resend-code`. Los endpoints `POST /api/v1/auth/verify-email` (recibe `{ "email": "...", "codigo": "..." }`) y `POST /api/v1/auth/password/reset` (recibe `{ "email": "...", "codigo": "...", "nueva_password": "..." }`) reciben el email y resuelven el `user_id` de forma interna. Ante un email inexistente responden con la misma respuesta de error genérico que ante un código inválido. Completa los límites de tasa faltantes en el ADR #34.
* **Por qué:** Protege las cuotas transaccionales de Resend unificando el control de emisión de correos por usuario y estandariza los contratos de API garantizando respuestas uniformes y seguras.

### 68. Revocación Inmediata de Sesiones y Refresh Tokens vía `password_changed_at` e `iat`
* **Decisión:** Se incorpora el campo `password_changed_at` (`ISODate | null`) en la colección `usuarios`. En cada validación de Access Token en `deps.py` y en cada ejecución de `POST /api/v1/auth/refresh`, se contrasta el claim `iat` (*issued at*) del token contra `password_changed_at`. Si `iat` es anterior a `password_changed_at`, la petición es rechazada de inmediato con HTTP 401 Unauthorized.
* **Por qué:** Consigue la revocación instantánea y confiable de todos los tokens emitidos (Access y Refresh) tras un cambio de contraseña o reclamación de cuenta, sin necesidad de infraestructura de listas negras de tokens.

---


---

### ADR #69: Validadores de MongoDB con $type y exigencia de null explícito (v2.2)

* **Fecha:** 2026-10-28
* **Decisión:** 
  1. En las expresiones de validación `$expr` de MongoDB, las comprobaciones de presencia y valor de campos opcionales o condicionales deben realizarse mediante `{"$type": "$campo"}` y no con comprobaciones de igualdad directa (`$eq`/`$ne` contra `null`).
  2. Se exige valor `null` explícito (tipo `"null"`) en la base de datos para:
     * `mensaje_hash` cuando `tipo_entrada == "url"`.
     * `nombre`, `password_hash` y `google_sub` cuando `estado_cuenta == "eliminada"`.
  3. Se exige tipo `"string"` para `password_hash` en cuentas locales no eliminadas, y para `google_sub` en cuentas Google no eliminadas.
  4. En cuentas con `estado_cuenta == "eliminada"`, se exige que `fecha_eliminacion` sea de tipo `"date"`.
  5. Los campos numéricos enteros en `$jsonSchema` se configuran como `["int", "long"]` en lugar de únicamente `"int"` para evitar rechazos accidentales ante tipos numéricos enteros de 64 bits en drivers de Python/PyMongo.
* **Por qué:** En el motor de agregación de MongoDB, la evaluación de un campo inexistente o ausente en `$eq: ["$campo", null]` puede resultar verdadera dependiendo del contexto y de la versión del motor, permitiendo el paso de documentos inválidos que omiten propiedades mandatorias o de auditoría. Exigir explícitamente el tipo BSON (`"null"`, `"string"`, `"date"`) garantiza invariantes estrictas tanto a nivel de aplicación como de persistencia física.
* **Impacto:** Los repositorios de MongoDB (`AnalysisRepository`, `UserRepository`) deben persistir `null` explícito en lugar de omitir la clave en los documentos BSON generados.


---

### ADR #70: Script mongosh de inicialización (scripts/init_antfish_db.js)

* **Fecha:** 2026-10-28
* **Decisión:** 
  1. Implementar scripts/init_antfish_db.js como script interactivo y de aprovisionamiento en mongosh, funcionalmente idéntico a pp/repositories/mongo/init_db.py.
  2. El script crea o sincroniza mediante collMod los validadores $jsonSchema +  según las correcciones técnicas de ADR #69 (, nulos explícitos y tipos enteros ['int', 'long']).
  3. Crea de forma idempotente los índices I1, I2, I5 a I11, omitiendo explícitamente los diferidos I3 e I4. Actualiza TTL de I8 e I11 vía collMod ante cambios de expireAfterSeconds.
  4. Incluye lógica de siembra condicional condicionada a countDocuments == 0 en ambas colecciones (
eglas_heuristicas y marcas_protegidas).
  5. Soporta autoprueba integral de validadores mediante la variable de entorno SELFTEST=1.
* **Por qué:** Permite a operadores de infraestructura y desarrolladores inicializar, validar y diagnosticar la base de datos de AntFish directamente desde la línea de comandos con mongosh sin requerir el runtime completo de Python ni la ejecución de la API FastAPI.
* **Impacto:** Cualquier modificación en esquemas, validaciones, índices o TTL obliga a sincronizar tanto pp/repositories/mongo/init_db.py como scripts/init_antfish_db.js.

## Historial de cambios

| Versión | Fecha | Resumen | ADR relacionados |
|---|---|---|---|
| 2.1 | 2026-10-27 | Sincronización documental v2.1: Cierre del modelo de datos v2.1 y endurecimiento de autenticación. Incorporación de ADR #51 a #61 (Sección I: D1 a D11) y ADR #62 a #68 (Sección J: D12 a D18). Anotación de modificaciones históricas en ADR #5, #11, #12, #14, #16, #31, #34, #35, #48, #49 y #50. | ADR #51 a #68 |
