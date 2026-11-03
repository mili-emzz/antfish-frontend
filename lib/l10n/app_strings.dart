/// Textos visibles al usuario (español) centralizados.
///
/// TEMPORAL: Sustituto de `AppLocalizations` (ARB + gen-l10n) mientras se
/// aprueba la dependencia `intl` (DPF-02). Al migrar, cada constante se
/// convierte en una clave de `app_es.arb` con el mismo nombre.
abstract final class AppStrings {
  // Marca
  static const String brandName = 'AntFish';
  static const String brandTagline = 'Cyber shield';

  // Hero de autenticación (columna narrativa en pantallas anchas)
  static const String authHeroEyebrow = 'PROTECCIÓN INTELIGENTE';
  static const String authHeroTitleLead = 'Tu mundo digital,';
  static const String authHeroTitleAccent = 'bajo control.';
  static const String authHeroCopy =
      'Detecta enlaces maliciosos y mensajes fraudulentos antes de que sea '
      'demasiado tarde.';
  static const String authTrustEncryption = 'Cifrado privado';
  static const String authTrustSpeed = 'Análisis en segundos';

  // Pestañas
  static const String authTabLogin = 'Ingresar';
  static const String authTabRegister = 'Registrarme';

  // Login
  static const String loginEyebrow = 'BIENVENIDO DE NUEVO';
  static const String loginTitle = 'Accede a tu espacio seguro';
  static const String loginSubtitle =
      'Tu protección continúa donde la dejaste.';
  static const String loginSubmit = 'Entrar de forma segura';
  static const String loginForgotPassword = '¿Olvidaste tu contraseña?';

  // Registro
  static const String registerEyebrow = 'CREA TU ESCUDO';
  static const String registerTitle = 'Comienza a navegar seguro';
  static const String registerSubtitle =
      'Configura tu cuenta en menos de un minuto.';
  static const String registerSubmit = 'Crear cuenta segura';
  static const String registerPasswordHelper =
      'Usa al menos 8 caracteres. Evita datos personales.';

  // Verificación de correo (CU-14, RF-06.2)
  static const String verifyEyebrow = 'SEGURIDAD DE LA CUENTA';
  static const String verifyTitle = 'Verifica tu correo';
  static const String verifySubtitlePrefix =
      'Ingresa el código de 6 dígitos que enviamos a ';
  static const String verifyEmailPlaceholder = 'tu correo electrónico';
  static const String verifyCodeLabel = 'Código de verificación';
  static const String verifyCodeSemantics =
      'Código de verificación de 6 dígitos';
  static const String verifySubmit = 'Verificar y activar cuenta';
  static const String verifyValidity =
      'El código es válido durante 10 minutos.';
  static const String verifyValidationRequired =
      'Ingresa el código de 6 dígitos.';
  static const String verifyValidationIncomplete =
      'El código debe tener exactamente 6 dígitos.';
  static const String verifyResendPrompt = '¿No recibiste el código?';
  static const String verifyResend = 'Reenviar código';
  static const String verifyResendLimit =
      'Puedes solicitar hasta 3 reenvíos por hora.';
  static const String verifyChangeEmail = 'Cambiar correo electrónico';
  static const String verifyTemplateNotice =
      'Vista de plantilla: la verificación y el reenvío se activarán al conectar el servidor.';

  // Campos
  static const String fieldNameLabel = 'Nombre';
  static const String fieldNameHint = '¿Cómo te llamas?';
  static const String fieldEmailLabel = 'Correo electrónico';
  static const String fieldEmailHint = 'nombre@correo.com';
  static const String fieldPasswordLabel = 'Contraseña';
  static const String fieldPasswordHint = 'Mínimo 8 caracteres';
  static const String fieldPasswordShow = 'Mostrar contraseña';
  static const String fieldPasswordHide = 'Ocultar contraseña';

  // Validaciones
  static const String validationNameRequired = 'Ingresa tu nombre.';
  static const String validationEmailRequired =
      'Ingresa tu correo electrónico.';
  static const String validationEmailInvalid =
      'Revisa el formato del correo (ej. nombre@correo.com).';
  static const String validationPasswordRequired = 'Ingresa tu contraseña.';
  static const String validationPasswordTooShort =
      'La contraseña debe tener al menos 8 caracteres.';
  static const String validationFormHasErrors =
      'Revisa los campos marcados para continuar.';

  // Proveedores externos y legales
  static const String authDivider = 'o continúa con';
  static const String authGoogle = 'Continuar con Google';
  static const String authLegalPrefix = 'Al continuar, aceptas nuestros ';
  static const String authLegalTerms = 'Términos';
  static const String authLegalAnd = ' y ';
  static const String authLegalPrivacy = 'Privacidad';
  static const String authPrivacyNote =
      'Tus datos viajan cifrados. Nunca compartimos tu información.';

  // Estados de plantilla (sin backend)
  static const String templateBackendPending =
      'Vista de plantilla: la conexión con el servidor aún no está disponible.';
  static const String templateComingSoon =
      'Esta sección estará disponible pronto.';
  static const String alertDismiss = 'Cerrar aviso';

  // Navegación inferior (BottomNav en App.tsx)
  static const String navHome = 'Inicio';
  static const String navHistory = 'Historial';
  static const String navScan = 'Escanear';
  static const String navScanSemantics = 'Escanear ahora';
  static const String navStats = 'Métricas';
  static const String navProfile = 'Perfil';

  // Encabezados de secciones del shell (App.tsx)
  static const String homeEyebrow = 'ESCÁNER INTELIGENTE';
  static const String homeTitle = 'Tu espacio está protegido.';
  static const String homeTitleLead = 'Tu espacio está ';
  static const String homeTitleAccent = 'protegido.';
  static const String homeGreeting = 'Buenas tardes, Alex';
  static const String homeAvatarInitials = 'AM';
  static const String homeAvatarSemantics = 'Abrir perfil';
  static const String homeSecurityRingLabel = 'Protección activa';
  static const String homeScannerEngineStatus = 'Motor activo';
  static const String homeScannerHeading = '¿Qué quieres analizar?';
  static const String homeCopy =
      'Pega un enlace o mensaje sospechoso. Nosotros hacemos el resto.';
  static const String homeTypeUrl = 'Enlace URL';
  static const String homeTypeSms = 'Mensaje SMS';
  static const String homeInputUrlHint =
      'https://sitio-que-quieres-verificar.com';
  static const String homeInputSmsHint =
      'Pega aquí el contenido del mensaje sospechoso...';
  static const String homeInputClearSemantics = 'Limpiar';
  static const String homePrivacyNote =
      'Tu contenido se analiza de forma privada y nunca se almacena.';
  static const String homeScanSubmit = 'Analizar ahora';
  static const String homeScanSubmitting = 'Analizando señales...';

  // Semáforo informativo y tarjeta de resultado (App.tsx)
  static const String trafficLightEyebrow = 'SEMÁFORO DE RIESGO';
  static const String trafficLightTitle = 'Una respuesta clara, no solo datos.';
  static const String trafficLightCopy =
      'Traducimos cientos de señales en un nivel de riesgo fácil de entender.';
  static const String resultEyebrow = 'ANÁLISIS COMPLETADO';
  static const String resultCriticalLabel = 'RIESGO CRÍTICO';
  static const String resultCriticalTitle = 'No abras este enlace';
  static const String resultCriticalCopy =
      'Detectamos una posible suplantación de identidad y reputación negativa.';
  static const String resultFindingDeceptiveDomain = 'Dominio engañoso';
  static const String resultFindingBlacklist = 'Lista negra';

  // Actividad reciente e historial (App.tsx)
  static const String recentEyebrow = 'ACTIVIDAD';
  static const String recentTitle = 'Análisis recientes';
  static const String recentViewAll = 'Ver todos';
  static const String historyEyebrow = 'REGISTRO SEGURO';
  static const String historyTitle = 'Tu historial';
  static const String historyCopy =
      'Consulta tus análisis anteriores y vuelve a revisar los resultados.';
  static const String historyFilterAll = 'Todos';
  static const String historyFilterUrls = 'Enlaces';
  static const String historyFilterSms = 'Mensajes';

  // Métricas (StatsScreen en App.tsx)
  static const String statsEyebrow = 'TU IMPACTO';
  static const String statsTitle = 'Métricas de protección';
  static const String statsCopy =
      'Cada análisis suma una capa más de tranquilidad digital.';
  static const String statsRingLabel = 'nivel seguro';
  static const String statsHeroEyebrow = 'ESTE MES';
  static const String statsHeroTitleLead = 'Tu protección creció ';
  static const String statsHeroTitleAccent = '12%';
  static const String statsHeroCopy =
      'Has evitado interactuar con 7 amenazas potenciales.';
  static const String statsMetricTotalScans = 'Escaneos totales';
  static const String statsMetricTotalScansSub = '+18 este mes';
  static const String statsMetricBlocked = 'Amenazas bloqueadas';
  static const String statsMetricBlockedSub = '15.5% del total';
  static const String statsMetricUrls = 'Enlaces analizados';
  static const String statsMetricUrlsSub = '61% de actividad';
  static const String statsMetricSms = 'SMS analizados';
  static const String statsMetricSmsSub = '39% de actividad';
  static const String statsBreakdownEyebrow = 'DESGLOSE';
  static const String statsBreakdownTitle = 'Nivel de riesgo';
  static const String statsBreakdownPeriod = 'Últimos 30 días';
  static const String statsRiskSafe = 'Seguro';
  static const String statsRiskMedium = 'Riesgo medio';
  static const String statsRiskHigh = 'Riesgo alto';
  static const String statsRiskCritical = 'Crítico';
  static const String statsInsightTitle = 'Tu hábito más seguro';
  static const String statsInsightCopy =
      'Analizas el 84% de los enlaces antes de abrirlos.';
  static const String statsPersistenceNote =
      'Eliminar un análisis del historial no reduce los contadores históricos.';

  // Perfil (ProfileScreen en App.tsx)
  static const String profileEyebrow = 'CUENTA PROTEGIDA';
  static const String profileTitle = 'Tu perfil';
  static const String profileCopy =
      'Administra tu espacio, privacidad y preferencias.';
  static const String profileDemoName = 'Alex Morgan';
  static const String profileDemoEmail = 'alex@correo.com';
  static const String profileVerifiedBadge = 'Correo verificado';
  static const String profileSecurityTitle = 'Centro de seguridad';
  static const String profileSecuritySubtitle = 'Contraseña y sesiones activas';
  static const String profilePrivacyTitle = 'Privacidad';
  static const String profilePrivacySubtitle = 'Datos y permisos de análisis';
  static const String profilePreferencesTitle = 'Preferencias';
  static const String profilePreferencesSubtitle = 'Alertas y notificaciones';
  static const String profileLogout = 'Cerrar sesión';
  static const String profileVersion = 'AntFish 1.0 · Tu escudo digital';
}
