# AntFish

AntFish es una aplicación móvil pensada para ayudarte a detectar enlaces y mensajes SMS maliciosos (phishing y smishing) en segundos, antes de que hagas clic o compartas información personal.

Este repositorio (`landing-antfish`) aloja la landing page oficial del proyecto [AntFish](https://www.antfish.xyz/), donde se presenta la aplicación y se ofrece el enlace directo de descarga.

## ¿Qué hace y cuál es su propósito?

El phishing y el smishing aprovechan la urgencia y la suplantación de marcas conocidas (bancos, paqueterías o servicios digitales) para robar credenciales o cometer fraudes. El propósito de AntFish es darte una forma rápida y clara de verificar cualquier enlace o mensaje sospechoso antes de interactuar con él.

Al analizar un texto o URL, la app combina reglas heurísticas propias (detección de lenguaje de urgencia, ofuscación y patrones sospechosos en el dominio) con consultas en tiempo real a servicios de inteligencia de amenazas como Google Web Risk, VirusTotal y PhishTank. Con eso calcula un puntaje de riesgo de 0 a 100 y te muestra un semáforo visual junto con los motivos concretos del riesgo y recomendaciones prácticas, sin guardar el texto de tus mensajes SMS.

## Cómo descargar AntFish

Por ahora, la aplicación para Android se distribuye directamente en formato APK (la versión para iOS estará disponible próximamente). Puedes descargarla de dos maneras:

### 1. Desde la landing page
1. Ingresa a la landing page de AntFish.
2. Haz clic en el botón de descarga para Android (**Descarga APK directa**).
3. Abre el archivo `app-release.apk` descargado en tu teléfono y acepta la instalación (si es la primera vez que instalas una app fuera de Play Store, Android te pedirá permitir instalaciones desde esa fuente).

### 2. Desde GitHub Releases
1. Ve a la sección de [Releases de `antfish-frontend`](https://github.com/mili-emzz/antfish-frontend/releases).
2. Selecciona la versión más reciente (por ejemplo, `v1.0.1`).
3. Descarga el archivo `app-release.apk` incluido en los assets de la release e instálalo en tu dispositivo Android.
