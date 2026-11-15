# Regla de Flujo Git: Ramas por Feature y Commits Atómicos

## 1. Verificación Obligatoria de Rama Activa
Antes de realizar cualquier modificación, el agente o desarrollador DEBE verificar en qué rama se encuentra (`git branch --show-current` o `git status`) y confirmar que coincide con la feature en la que va a trabajar.
Nunca realizar cambios en una rama incorrecta ni trabajar directamente sobre `main` o `develop`.

## 2. Mapa Oficial de Ramas y Responsabilidades
* `main`: Código funcional de producción. Prohibido tocar directamente. Su única regla de admisión es que debe estar completamente validado por pruebas automatizadas aprobadas.
* `develop`: Rama de integración donde se junta todo el trabajo de las ramas de feature antes de pasar a `main`.
* `auth`: Autenticación completa (Login, Registro, verificación de código): contiene vistas, lógica de estados y consumo de API.
* `main-view`: Es EXCLUSIVAMENTE la vista de la pantalla Home (interfaz de escaneo, semáforo visual, selectores, campos y estados locales visuales).
  * Regla especial: `main-view` es la ÚNICA que separa la vista y su lógica en ramas distintas porque el motor de escaneo es la parte más crítica y delicada de AntFish.
* `analysis-flow`: Rama dedicada a la lógica de consumo y envío de URLs y SMS del frontend al backend (orquestación, servicio HTTP de análisis, recepción de puntajes y modelos).
* `metrics-view`: Métricas y estadísticas: igual que auth, incluye tanto vistas como lógica y consumo de API.

## 3. Política de Commits Atómicos
* Cada cambio por feature debe tener su propio commit independiente para mantener una estructura limpia y una secuencia segura y trazable.
* Queda prohibido hacer commits masivos que mezclen múltiples pantallas, lógica de features distintas o cambios de configuración con lógica.
* Cada commit debe dejar el proyecto compilando y con pruebas pasando (`flutter analyze` y `flutter test`).
* Formato de commit: Conventional Commits indicando feature y alcance (`feat(auth): ...`, `fix(metrics): ...`, `test(analysis): ...`).

