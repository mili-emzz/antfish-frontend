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
  static const String verifySuccessDefault =
      'Cuenta verificada exitosamente. Ya puedes iniciar sesión.';
  static const String verifyResendDefault =
      'Si la cuenta está pendiente de verificación, se envió un nuevo código.';
  static String verifyResendCooldown(int seconds) =>
      'Reenviar código (${seconds}s)';

  // Recuperación de contraseña (POST /auth/password/forgot y /reset)
  static const String forgotPasswordEyebrow = 'RECUPERACIÓN SEGURA';
  static const String forgotPasswordTitle = 'Recupera tu contraseña';
  static const String forgotPasswordSubtitle =
      'Ingresa tu correo y te enviaremos un código de 6 dígitos para restablecerla.';
  static const String forgotPasswordSubmit = 'Enviar código de recuperación';
  static const String forgotPasswordBackToLogin = 'Volver a iniciar sesión';
  static const String forgotPasswordSuccessDefault =
      'Si el correo corresponde a una cuenta activa, recibirás un código de recuperación.';

  static const String resetPasswordEyebrow = 'NUEVA CONTRASEÑA';
  static const String resetPasswordTitle = 'Restablece tu acceso';
  static const String resetPasswordSubtitlePrefix =
      'Ingresa el código de 6 dígitos enviado a ';
  static const String resetPasswordSubtitleFallback =
      'Ingresa tu correo, el código de 6 dígitos y tu nueva contraseña.';
  static const String resetPasswordCodeLabel = 'Código de recuperación';
  static const String resetPasswordCodeSemantics =
      'Código de recuperación de 6 dígitos';
  static const String resetPasswordNewLabel = 'Nueva contraseña';
  static const String resetPasswordSubmit = 'Restablecer contraseña';
  static const String resetPasswordRequestAgain = 'Solicitar otro código';
  static const String resetPasswordSuccessDefault =
      'Contraseña restablecida exitosamente. Ya puedes iniciar sesión con tu nueva contraseña.';

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
  static const String validationLegalRequired =
      'Acepta los Términos y condiciones y el Aviso de privacidad para crear tu cuenta.';

  // Proveedores externos y legales
  static const String authDivider = 'o continúa con';
  static const String authGoogle = 'Continuar con Google';
  static const String registerAcceptTermsPrefix = 'Acepto los ';
  static const String registerAcceptPrivacyPrefix = 'Acepto el ';
  static const String authLegalGooglePrefix =
      'Al ingresar con Google aceptas nuestros ';
  static const String authLegalTerms = 'Términos y condiciones';
  static const String authLegalAnd = ' y el ';
  static const String authLegalPrivacy = 'Aviso de privacidad';
  static const String authPrivacyNote =
      'Tus datos viajan cifrados. Nunca compartimos tu información.';
  static const String legalLinkPendingBody =
      'Muy pronto podrás consultar este documento completo desde nuestra landing page oficial.';
  static const String legalLinkPendingClose = 'Entendido';

  // Google Sign-In
  static const String googleSignInSuccess =
      'Sesión iniciada con Google correctamente.';
  static const String googleEmailNotVerified =
      'Google indica que ese correo no está verificado. Usa otra cuenta.';
  static const String googleInvalidCredential =
      'No se pudo validar tu cuenta de Google. Inténtalo de nuevo.';
  static const String googleNoCredential =
      'No se pudo obtener la credencial de Google.';
  static const String googleGenericError =
      'No se pudo iniciar sesión con Google. Inténtalo de nuevo.';
  static const String googleWebUnsupported =
      'El inicio con Google directo desde este botón requiere probar en Android/iOS o usar una sesión de Google activa en el navegador.';
  static const String serverInvalidResponse =
      'Respuesta inesperada del servidor.';
  static const String authGenericError =
      'No se pudo completar la operación. Inténtalo de nuevo.';

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
  static const String resultSafeTitle = 'No se detectaron amenazas críticas';
  static const String resultSafeCopy =
      'Las señales analizadas no muestran indicios claros de fraude.';
  static const String resultMediumTitle = 'Procede con precaución';
  static const String resultMediumCopy =
      'Se detectaron algunas señales inusuales. Verifica la fuente antes de continuar.';
  static const String resultHighTitle = 'Riesgo alto detectado';
  static const String resultHighCopy =
      'Recomendamos no abrir este enlace ni compartir datos personales.';
  static const String resultPartialWarning =
      'Análisis preliminar: alguna fuente externa no respondió a tiempo.';
  static const String resultShortCircuitBlacklist = 'Detectado en lista negra';
  static const String resultShortCircuitImpersonation =
      'Posible suplantación de marca';
  static const String resultLayerApis = 'APIs';
  static const String resultLayerUrl = 'URL';
  static const String resultLayerText = 'Texto';
  static const String resultViewDetail = 'Ver detalle completo';
  static const String analysisSubmitError =
      'No se pudo completar el análisis. Inténtalo de nuevo.';
  static const String analysisUrlTooLong =
      'La URL supera el límite máximo de 2,048 caracteres.';
  static const String analysisSmsTooLong =
      'El mensaje SMS supera el límite máximo de 1,600 caracteres.';
  static const String analysisDetailTitle = 'Detalle del análisis';
  static const String analysisDetailLayersTitle = 'Puntaje por capa';
  static const String analysisDetailPrimaryUrl = 'URL principal';
  static const String analysisDetailSecondaryUrl =
      'URL secundaria (solo señales sintácticas)';
  static const String analysisDetailFindingsTitle = 'Hallazgos detectados';
  static const String analysisDetailRecommendationsTitle = 'Recomendaciones';
  static const String analysisDisclaimerTitle =
      'Aviso sobre fuentes y precisión';
  static const String analysisDisclaimerBody =
      'Este diagnóstico es orientativo y sus puntajes y porcentajes son una estimación basada en nuestro motor heurístico y en servicios externos de terceros (Google Web Risk, VirusTotal y PhishTank). Estas fuentes pueden contener falsos positivos, falsos negativos o retrasos ante amenazas recientes, por lo que un resultado bajo no garantiza que el enlace o mensaje sea 100 % seguro. AntFish no sustituye tu criterio ni asume responsabilidad por decisiones, accesos o pérdidas derivadas del uso de esta información.';
  static const String analysisDetailSourcesTitle = 'Fuentes consultadas';
  static const String analysisDetailClose = 'Cerrar';
  static const String analysisDetailDelete = 'Eliminar del historial';
  static const String analysisDeleteConfirmTitle = 'Eliminar análisis';
  static const String analysisDeleteConfirmCopy =
      'Se eliminará este registro de tu historial. Los contadores históricos de métricas no se reducirán.';
  static const String analysisDeleteSuccess =
      'Análisis eliminado del historial.';
  static const String analysisDeleteError =
      'No se pudo eliminar el análisis. Inténtalo de nuevo.';
  static const String historyLoading = 'Cargando historial...';
  static const String historyLoadError =
      'No se pudo cargar tu historial. Inténtalo de nuevo.';
  static const String historyEmpty =
      'Aún no tienes análisis registrados en tu historial.';
  static const String historyLoadMore = 'Cargar más';
  static String homeGreetingFor(String firstName) => 'Hola, $firstName';

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

  // Métricas (StatsScreen - GET /api/v1/metrics/me)
  static const String statsEyebrow = 'TU IMPACTO';
  static const String statsTitle = 'Métricas de protección';
  static const String statsCopy =
      'Cada análisis suma una capa más de tranquilidad digital.';
  static const String statsRingLabel = 'nivel seguro';
  static const String statsMetricTotalScans = 'Escaneos totales';
  static const String statsMetricTotalScansSub = 'Histórico acumulado';
  static const String statsMetricBlocked = 'Amenazas bloqueadas';
  static const String statsMetricUrls = 'Enlaces analizados';
  static const String statsMetricSms = 'SMS analizados';
  static String statsPercentOfTotal(int percent) => '$percent% del total';
  static String statsPercentOfActivity(int percent) => '$percent% de actividad';
  static const String statsBreakdownEyebrow = 'DESGLOSE';
  static const String statsBreakdownTitle = 'Nivel de riesgo';
  static const String statsNoScansYet = 'Sin escaneos registrados';
  static String statsLastUpdated(String formattedDate) =>
      'Actualizado: $formattedDate';
  static const String statsRiskSafeOrMedium = 'Seguro / precaución';
  static const String statsRiskBlockedThreats = 'Amenazas (alto / crítico)';
  static const String statsBreakdownUrls = 'Enlaces URL';
  static const String statsBreakdownSms = 'Mensajes SMS';
  static const String statsPersistenceNote =
      'Eliminar un análisis del historial no reduce los contadores históricos.';
  static const String statsLoading = 'Actualizando métricas...';
  static const String statsRetry = 'Reintentar';
  static const String statsRefresh = 'Actualizar';
  static const String metricsLoadError =
      'No se pudieron cargar tus métricas. Inténtalo de nuevo.';

  // Perfil (ProfileScreen en App.tsx)
  static const String profileEyebrow = 'CUENTA PROTEGIDA';
  static const String profileTitle = 'Tu perfil';
  static const String profileDemoName = 'Alex Morgan';
  static const String profileDemoEmail = 'alex@correo.com';
  static const String profileVerifiedBadge = 'Correo verificado';
  static const String profileSecurityTitle = 'Centro de seguridad';
  static const String profileSecuritySubtitle = 'Cambiar contraseña';
  static const String profilePrivacyTitle = 'Privacidad';
  static const String profilePrivacySubtitle =
      'Lee nuestro aviso de privacidad';
  static const String profilePreferencesTitle = 'Términos y condiciones';
  static const String profilePreferencesSubtitle =
      'Conoce los términos del servicio';
  static const String profileLogout = 'Cerrar sesión';
  static const String profileDeleteAccount = 'Eliminar cuenta';
  static const String deleteAccountDialogTitle = 'Eliminar cuenta';
  static const String deleteAccountDialogCopy =
      'Esta acción es definitiva. Se anonimizará tu cuenta y se eliminará todo tu historial de análisis y métricas.';
  static const String deleteAccountPasswordLabel = 'Contraseña actual';
  static const String deleteAccountPasswordHint =
      'Confirma tu contraseña para continuar';
  static const String deleteAccountGoogleHint =
      'Por seguridad, verifica nuevamente tu identidad con Google para confirmar la baja definitiva.';
  static const String deleteAccountCancel = 'Cancelar';
  static const String deleteAccountConfirm = 'Eliminar definitivamente';
  static const String deleteAccountConfirmGoogle =
      'Verificar con Google y eliminar';
  static const String deleteAccountSuccess =
      'Tu cuenta fue eliminada definitivamente.';
  static const String profileVersion = 'AntFish 1.0 · Tu escudo digital';
}
