# Regla de Variables de Entorno y Credenciales (.env)

Toda credencial de cliente, identificador OAuth o configuración dependiente del entorno debe gestionarse exclusivamente a través de variables de entorno y nunca escribirse de forma fija (hardcoded) en el código fuente de Dart.

## Lineamientos obligatorios

1. **Ubicación única en `.env`:**
   * Los identificadores de Google OAuth (`GOOGLE_WEB_CLIENT_ID`, `GOOGLE_ANDROID_CLIENT_ID`, `GOOGLE_IOS_CLIENT_ID`) y la dirección del backend (`API_BASE_URL`) viven únicamente en el archivo `.env` en la raíz del proyecto.
   * Si el usuario comparte un Client ID o clave en el chat, el agente debe colocarlo en `.env` (o indicarle cómo ponerlo ahí) y referenciarlo desde el código mediante variables de entorno, jamás pegarlo como literal en archivos dentro de `lib/` o `test/`.

2. **Inyección segura en Flutter (`--dart-define-from-file`):**
   * Las variables se inyectan en tiempo de compilación/ejecución usando `--dart-define-from-file=.env` y se leen en Dart con `String.fromEnvironment('NOMBRE_VARIABLE')` centralizadas en `lib/core/config/env_config.dart`.
   * Queda prohibido declarar el archivo `.env` dentro de la sección `assets:` de `pubspec.yaml`, ya que eso empaqueta el archivo en texto plano dentro del APK/IPA final.

3. **Protección en control de versiones (Git):**
   * El archivo `.gitignore` debe excluir siempre `.env` y cualquier variante `.env.*` (excepto `.env.example`).
   * En el repositorio solo se versiona `.env.example` con los nombres de las variables vacíos o con valores de ejemplo no sensibles para documentar qué claves necesita el proyecto.

4. **Cero exposición en logs:**
   * Nunca imprimir en consola (`print`, `debugPrint`) ni incluir en mensajes de error de UI los valores de los Client IDs o secretos cargados desde el entorno.
