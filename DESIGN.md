# AntFish Design System

## 1. Visión

AntFish utiliza el lenguaje visual **Dark Crystal Cyber‑Shield**: una interfaz inmersiva y tecnológica que comunica seguridad, inteligencia y control sin recurrir a una estética agresiva.

La experiencia combina:

- Fondos oscuros con profundidad.
- Superficies de cristal altamente translúcidas.
- Acentos dorados para protección, acciones y estados positivos.
- Resplandores púrpura para inteligencia y actividad tecnológica.
- Bordes finos, reflejos internos y sombras etéreas.
- Formas redondeadas que suavizan el carácter técnico del producto.

La interfaz debe sentirse confiable, sofisticada y comprensible para usuarios sin conocimientos técnicos.

---

## 2. Principios de diseño

### Seguridad comprensible

Los diagnósticos deben traducirse a lenguaje sencillo. Las métricas técnicas se complementan con mensajes claros, recomendaciones y niveles de riesgo reconocibles.

### Jerarquía antes que decoración

El glassmorphism se utiliza para organizar la información, no únicamente como efecto visual. Las superficies importantes reciben mayor contraste y definición.

### Acción principal evidente

En cada pantalla debe existir una acción dominante. En el dashboard es **Analizar ahora**; en autenticación es **Entrar de forma segura** o **Crear cuenta segura**.

### Color con significado

Los colores de riesgo están reservados para resultados y estados. El dorado identifica protección, acciones principales y elementos destacados.

### Privacidad visible

Los mensajes sobre cifrado, privacidad y tratamiento de datos deben estar presentes cerca de los puntos donde el usuario introduce información.

---

## 3. Paleta de color

### Colores principales

| Token | Valor | Uso |
| --- | --- | --- |
| `--plum` | `#462255` | Morado principal, fondos y superficies activas |
| `--lilac` | `#B47EB3` | Resplandores, inteligencia y estados secundarios |
| `--gold` | `#D7BA89` | Acciones, protección y destacados |
| `--muted` | `#AA9EAE` | Texto secundario |

### Fondos

| Nombre | Valor aproximado | Uso |
| --- | --- | --- |
| Fondo profundo | `#110816` | Fondo raíz |
| Fondo berenjena | `#180A20` | Inicio de gradientes |
| Fondo violeta | `#240E2D` | Zona central de gradientes |
| Fondo de panel | `rgba(255,255,255,0.055)` | Superficies de cristal |

Los fondos principales utilizan gradientes entre variaciones de `#1B0D22` y `#2C1236`.

### Colores de riesgo

| Nivel | Color | Uso |
| --- | --- | --- |
| Seguro | `#6AD6A2` | Riesgo bajo, protección correcta |
| Medio | `#E0CC72` | Precaución |
| Alto | `#DD905D` | Riesgo elevado |
| Crítico | `#D96179` | Amenaza confirmada o inmediata |

No utilizar estos colores como decoración general. Deben conservar su significado semántico.

---

## 4. Tipografía

### Familias

- **Manrope**: encabezados, cifras, marca y elementos de alta jerarquía.
- **DM Sans**: cuerpo, controles, etiquetas y texto funcional.

Las fuentes se cargan desde Google Fonts en `src/index.css`.

### Escala recomendada

| Elemento | Tamaño | Peso |
| --- | --- | --- |
| Hero de autenticación | `42–67px` | `700–800` |
| Título de página | `27–38px` | `700` |
| Título de tarjeta | `18–24px` | `600–700` |
| Texto base | `12–16px` | `400–500` |
| Etiqueta | `9–11px` | `600–700` |
| Metadato | `8–10px` | `400–500` |

### Reglas

- Los títulos usan tracking negativo para una apariencia compacta.
- Las etiquetas superiores usan mayúsculas y tracking amplio.
- No utilizar más de tres pesos tipográficos en una misma vista.
- Los textos secundarios deben conservar contraste suficiente sobre cristal.

---

## 5. Espaciado

La interfaz utiliza una escala basada principalmente en múltiplos de 4.

| Token conceptual | Valor |
| --- | --- |
| Extra pequeño | `4px` |
| Pequeño | `8px` |
| Compacto | `12px` |
| Base | `16px` |
| Medio | `20–24px` |
| Amplio | `28–32px` |
| Sección | `36–48px` |

### Reglas

- Separación entre etiqueta y título: `5–10px`.
- Separación entre título y descripción: `6–12px`.
- Separación entre campos de formulario: `18px`.
- Separación antes de la acción principal: `18px`.
- Padding habitual de tarjetas: `20–28px`.
- Padding lateral móvil: `18–24px`.
- Mantener al menos `24px` entre bloques funcionales diferentes.

El panel de autenticación seleccionado actualmente tiene `padding-bottom: 0` como ajuste específico de instancia.

---

## 6. Bordes y radios

| Componente | Radio |
| --- | --- |
| Panel principal | `25–32px` |
| Tarjeta | `18–23px` |
| Campo o botón | `13–15px` |
| Control segmentado | `10–13px` |
| Icono contenido | `9–12px` |
| Píldora de estado | `20px` o circular |

Los bordes utilizan blanco con opacidades entre `0.06` y `0.15`. Los elementos dorados pueden usar `rgba(215,186,137,0.15–0.36)`.

---

## 7. Glassmorphism

Clase principal: `.glass-panel`.

Características:

- Fondo translúcido con gradiente.
- `backdrop-filter: blur(24px)`.
- Borde fino semitransparente.
- Reflejo superior interno.
- Sombra profunda y suave.

Ejemplo conceptual:

```css
.glass-panel {
  border: 1px solid rgba(255, 255, 255, 0.105);
  background: linear-gradient(
    145deg,
    rgba(255, 255, 255, 0.082),
    rgba(255, 255, 255, 0.035)
  );
  box-shadow:
    inset 0 1px rgba(255, 255, 255, 0.08),
    0 30px 80px rgba(4, 0, 8, 0.35);
  backdrop-filter: blur(24px);
}
```

No todas las superficies deben tener el mismo nivel de cristal. Utilizar mayor opacidad en controles y menor opacidad en fondos secundarios.

---

## 8. Botones

### Acción principal

Los botones principales utilizan un gradiente dorado con texto oscuro.

Características:

- Altura recomendada: `51–54px`.
- Radio: `14–15px`.
- Peso: `700`.
- Sombra dorada tenue.
- Reflejo superior interno.
- Movimiento vertical máximo de `1px` al pasar el cursor.

Ejemplos:

- Entrar de forma segura.
- Crear cuenta segura.
- Analizar ahora.

### Acción secundaria

Utiliza cristal oscuro, borde fino y texto claro. Puede recibir un borde dorado sutil en hover.

### Botón destructivo

Utiliza rojo crítico con baja opacidad. No debe competir visualmente con la acción principal.

### Controles segmentados

Los controles de acceso/registro y URL/SMS:

- Utilizan un contenedor oscuro.
- Mantienen `4px` de espacio entre opciones.
- La opción activa usa fondo púrpura translúcido.
- Las opciones deben tener el mismo ancho.

---

## 9. Campos de formulario

Características:

- Altura base: `50px`.
- Fondo oscuro translúcido.
- Borde blanco de baja opacidad.
- Icono inicial de contexto.
- Placeholder con contraste reducido.
- Foco con borde dorado y halo discreto.

Los campos deben mostrar siempre una etiqueta visible. El placeholder no sustituye a la etiqueta.

En formularios:

- Mantener `18px` entre campos.
- Colocar mensajes de recuperación o ayuda cerca del campo correspondiente.
- Mantener una separación clara antes del botón principal.

---

## 10. Navegación inferior

La barra inferior es una superficie de cristal flotante:

- Altura: `78px`.
- Separación del borde inferior: `10–15px`.
- Radio: `25px`.
- Fondo berenjena con alta transparencia.
- Blur: `25px`.
- Cinco columnas visuales.

El botón central **Escanear**:

- Se eleva por encima de la barra.
- Utiliza forma circular.
- Tiene borde del mismo color que el fondo para crear separación.
- Incluye resplandor púrpura.
- Conserva el acento dorado para el icono.

La navegación activa usa dorado. Los destinos inactivos usan gris violeta.

---

## 11. Anillo de seguridad

El anillo comunica el nivel general de protección:

- Utiliza `conic-gradient`.
- El progreso activo es dorado.
- El tramo restante es blanco translúcido.
- El centro mantiene el fondo oscuro.
- La cifra es el elemento más importante.
- La etiqueta debe ser breve.

Puede variar de tamaño según el contexto:

- Dashboard: `94–108px`.
- Panel de métricas: `105–125px`.

---

## 12. Semáforo y estados de riesgo

La escala de riesgo utiliza cuatro niveles:

1. Seguro.
2. Riesgo medio.
3. Riesgo alto.
4. Crítico.

Cada resultado debe incluir:

- Color semántico.
- Nombre textual del nivel.
- Puntuación cuando esté disponible.
- Explicación breve.
- Hallazgos principales.
- Recomendación accionable.

Nunca comunicar el riesgo únicamente mediante color.

---

## 13. Iconografía

Los iconos actuales son SVG lineales definidos en el componente `Icon` de `src/App.tsx`.

Características:

- Trazo redondeado.
- Grosor habitual: `1.8`.
- Tamaño base: `18–24px`.
- Sin rellenos decorativos.
- El color se hereda del contenedor.

No utilizar emojis como iconos de interfaz.

---

## 14. Movimiento e interacción

Las animaciones deben comunicar respuesta, no ornamentación.

### Duraciones

- Hover y foco: `150–200ms`.
- Cambio de estado: `200–300ms`.
- Análisis simulado: aproximadamente `900ms`.

### Reglas

- Evitar desplazamientos superiores a `2px` en botones.
- No animar grandes superficies de fondo de manera continua.
- Los resplandores pueden aumentar ligeramente durante estados activos.
- Respetar `prefers-reduced-motion` si se incorporan animaciones adicionales.

---

## 15. Responsive

### Escritorio

- Autenticación en dos columnas.
- Columna izquierda narrativa y visual.
- Formulario contenido en un panel de aproximadamente `440px`.
- Aplicación principal limitada a `760px` para preservar proporciones móviles.

### Tablet y móvil

A partir de `800px`:

- La autenticación pasa a una sola columna.
- Se oculta el visual decorativo lateral.
- La marca se integra dentro del panel.
- Las métricas pasan de cuatro a dos columnas.

A partir de `520px`:

- Padding lateral de contenido: `18px`.
- Anillo y encabezados reducen tamaño.
- Las tarjetas ajustan padding.
- La barra inferior ocupa casi todo el ancho.
- Se simplifican etiquetas secundarias cuando sea necesario.

No reducir áreas táctiles importantes por debajo de `44px`.

---

## 16. Accesibilidad

- Mantener contraste suficiente entre texto y fondo.
- No depender únicamente del color para comunicar estados.
- Todos los botones con icono deben tener nombre accesible.
- Los controles de formulario deben conservar etiquetas visibles.
- Los estados de foco no deben eliminarse.
- Los textos secundarios no deben reducirse por debajo de `9px` salvo metadatos no esenciales.
- Las acciones principales deben tener un área táctil mínima de `44 × 44px`.

---

## 17. Vistas actuales

### Autenticación

- Login.
- Registro.
- Acceso mediante Google.
- Recuperación de contraseña como acción secundaria.

### Inicio

- Estado de protección.
- Entrada URL/SMS.
- Mensaje de privacidad.
- Análisis simulado.
- Semáforo de riesgo.
- Actividad reciente.

### Historial

- Filtros por tipo.
- Lista de análisis.
- Estado semántico por registro.

### Métricas

- Nivel general de seguridad.
- Escaneos totales.
- Amenazas bloqueadas.
- Desglose URL/SMS.
- Distribución por riesgo.
- Insight de comportamiento seguro.

### Perfil

- Identidad y correo verificado.
- Centro de seguridad.
- Privacidad.
- Preferencias.
- Cierre de sesión.

---

## 18. Implementación

Los estilos globales y tokens se encuentran en:

```text
src/index.css
```

La estructura de vistas, componentes e iconos se encuentra en:

```text
src/App.tsx
```

La aplicación utiliza:

- React 19.
- Vite.
- TypeScript.
- Tailwind CSS v4.
- CSS personalizado para el sistema visual.

Las nuevas pantallas deben reutilizar las clases y patrones existentes antes de introducir variantes nuevas.
