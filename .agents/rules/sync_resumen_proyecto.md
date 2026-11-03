---
name: sync-resumen-proyecto
description: Regla mandatoria para mantener docs/resumen_proyecto.json actualizado al finalizar cualquier tarea o cambio en el frontend.
---

# Regla de Sincronización Obligatoria: resumen_proyecto.json

Cada vez que el agente complete una tarea, refactor, implementación o cambio relevante en el proyecto, DEBE actualizar obligatoriamente el archivo `docs/resumen_proyecto.json` antes de responder al usuario.

## Campos a verificar y actualizar:
1. `metadata.ultima_actualizacion`: Colocar la fecha actual (ISO 8601 o YYYY-MM-DD).
2. `decisiones_tecnicas_tomadas`: Registrar cualquier nueva decisión técnica tomada con su ID consecutivo (DT-xx), tema, decisión y razón.
3. `decisiones_pendientes_a_ratificar`: Actualizar el estado de las DPF si alguna fue acordada o cerrada.
4. `ultimo_resumen_y_proximos_pasos`:
   - `ultimo_resumen`: Sintetizar con precisión el último cambio y el estado funcional alcanzado.
   - `proximos_pasos_inmediatos`: Ajustar la lista de siguientes pasos prioritarios.

## Criterio de parada:
Ninguna tarea se considera terminada (Definition of Done) si `docs/resumen_proyecto.json` no refleja el estado exacto del repositorio.

