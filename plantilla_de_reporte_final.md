# Reporte Final del Proyecto: \[Nombre del Proyecto\]

## Ficha de Identificación

* **Institución:** Universidad Politécica de Chiapas

* **Carrera / Programa:** Ingeniería en Tecnologías de la Información e Innovación Digital

* **Asignatura:** Seguridad Informática

* **Profesor:** M.C. José Alonso Macías Montoya

* **Fecha de Entrega:** [DD/MM/AAAA\]

* **Nombre del Equipo / Grupo:** [Ej. Equipo 01 / Grupo 9B\]

* **Nombre del Proyecto:** [Ej. Proyecto\]

### Integrantes del Equipo

| Nombre Completo | Matrícula | Correo Electrónico | Rol / Enfoque Principal | 
| ----- | ----- | ----- | ----- | 
| \[Nombre Integrante 1\] | \[12345678\] | \[correo1@it2id.upchiapas.edu.mx\] | Frontend & UI/UX | 
| \[Nombre Integrante 2\] | \[12345678\] | \[correo2@it2id.upchiapas.edu.mx\] | Backend & API | 
| \[Nombre Integrante 3\] | \[12345678\] | \[correo3@it2id.upchiapas.edu.mx\] | Ciberseguridad & DevOps | 

## Sección I: Control de Acceso y Enlaces del Proyecto

> **Instrucciones:** Asegúrese de verificar que todos los enlaces estén activos y sean accesibles antes de generar el PDF final.

| Recurso | Enlace / Estado | Notas de Acceso | 
| ----- | ----- | ----- | 
| **Repositorio de Código Fuente** | `https://github.com/usuario/repositorio` | \[Público / Privado con acceso docente concedido\] | 
| **Aplicación Web / Despliegue API** | `https://mi-proyecto.render.com` | \[Opcional: URL del Live Demo\] | 
| **Video Demostrativo (3-5 min)** | `https://youtu.be/video_id` | \[YouTube Unlisted / Loom / Google Drive\] | 

## Sección II: Declaración de Licencia de Software

### 2.1 Tipo de Licencia Seleccionada

* **Licencia Elegida:** \[Ej. Licencia MIT / Apache 2.0 / GNU GPLv3 / Propietaria - Todos los derechos reservados\]

### 2.2 Justificación de la Licencia

*\[Explique brevemente por qué eligieron esta licencia para su proyecto. Ej. "Se seleccionó la Licencia MIT debido a que se busca otorgar la máxima flexibilidad para que la comunidad académica pueda utilizar, modificar y distribuir los módulos de la solución sin restricciones comerciales."\]*

> **Nota:** Verifique que el archivo `LICENSE` esté incluido en la raíz del repositorio de código.

## Sección III: Resumen Ejecutivo y Planteamiento

### 3.1 Descripción del Proyecto

*\[Proporcione una descripción clara y sintética de la solución desarrollada. Indique si es una app Web o Móvil y qué herramientas/módulos integra.\]*

### 3.2 Planteamiento del Problema y Justificación

*\[Contextualice la problemática real de ciberseguridad que atiende el proyecto y por qué es relevante resolverla.\]*

### 3.3 Matriz de Cumplimiento de Objetivos

| Objetivo Inicial Planteado | Estado de Implementación | Observaciones / Alcance Logrado | 
| ----- | ----- | ----- | 
| **General:** \[Objetivo general inicial\] | \[Completado / Parcial\] | \[Detalles breves\] | 
| **Específico 1:** \[Diseño de arquitectura y API\] | \[Completado\] | \[Se implementó API RESTful con 8 endpoints\] | 
| **Específico 2:** \[Desarrollo del Frontend Web/Móvil\] | \[Completado\] | \[Interfaz desarrollada en React Native\] | 
| **Específico 3:** \[Pruebas de Seguridad / Pentesting\] | \[Completado\] | \[Pruebas ejecutadas con OWASP ZAP\] | 

## Sección IV: Arquitectura Técnica y Stack Tecnológico

### 4.1 Stack Tecnológico

* **Frontend (Web / Móvil):** \[Ej. React 18, TailwindCSS / Flutter 3.0\]

* **Backend & API:** \[Ej. Python 3.11 con FastAPI / Node.js con Express\]

* **Base de Datos:** \[Ej. PostgreSQL 15 / MongoDB\]

* **Infraestructura & Contenedores:** \[Ej. Docker, Nginx, Vercel\]

* **Librerías de Seguridad / Cifrado:** \[Ej. PyJWT, cryptography (AES-256), OpenSSL\]

### 4.2 Diagrama de Arquitectura de la Solución

```
[ Coloque aquí la imagen o diagrama del flujo de arquitectura ]
(Frontend UI <---> API RESTful / Backend <---> Base de Datos / Servicios Externos de Seguridad)
```

### 4.3 Especificación de Endpoints Principales de la API

| Método HTTP | Ruta / Endpoint | Descripción | Requiere Autenticación | 
| ----- | ----- | ----- | ----- | 
| `POST` | `/api/v1/auth/login` | Autenticación de usuario y retorno de JWT | NO | 
| `POST` | `/api/v1/scan/headers` | Análisis de cabeceras de seguridad HTTP | SÍ (Bearer Token) | 
| `GET` | `/api/v1/vault/secrets` | Obtención de credenciales cifradas (AES-256) | SÍ (Bearer Token) | 
| `POST` | `/api/v1/tools/hash-check` | Evaluación de hashes y filtraciones | SÍ (Bearer Token) | 

## Sección V: Matriz de Seguridad y Evidencias de Funcionamiento

### 5.1 Mecanismos de Seguridad Implementados

*\[Describa las prácticas aplicadas: sanitización de entradas, cifrado en reposo/tránsito, mitigación de OWASP Top 10, control de accesos RBAC, etc.\]*

### 5.2 Evidencias de Funcionamiento (Capturas de Pantalla)

#### Interfaz de Usuario (Frontend)

*\[Inserte capturas representativas de la interfaz web/móvil ejecutando los módulos de la solución.\]*

#### Peticiones y Respuestas de la API

*\[Inserte capturas de pantalla utilizando herramientas como Postman, Insomnia o Swagger UI donde se observe la respuesta en formato JSON de la API.\]*

#### Pruebas de Seguridad / Análisis

*\[Inserte evidencia del escaneo de código (SAST), pruebas de penetración o logs del backend mostrando el correcto manejo de errores y seguridad.\]*

## Conclusiones y Trabajo Futuro

* **Conclusiones:** \[Reflexión sobre los aprendizajes del equipo, desafíos técnicos superados e impacto del proyecto.\]

* **Trabajo Futuro / Mejoras:** \[Listado de características que se podrían añadir en versiones posteriores para robustecer la suite de ciberseguridad.\]