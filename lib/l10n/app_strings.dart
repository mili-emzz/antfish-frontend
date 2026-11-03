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
}
