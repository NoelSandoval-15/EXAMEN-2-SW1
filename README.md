# EXAMEN-2-SW1

Sistema tipo **workflow** para la empresa CREE, con automatización por departamentos.

## Flujo automatizado propuesto

El proceso principal se encuentra modelado en Camunda en:

- `/home/runner/work/EXAMEN-2-SW1/EXAMEN-2-SW1/workflow/proceso-cree.bpmn`

### Departamentos involucrados

1. **Recepción**: inicia la solicitud.
2. **RRHH**: valida información del colaborador.
3. **Finanzas**: aprueba disponibilidad de presupuesto.
4. **TI**: automatiza aprovisionamiento y configuración.
5. **Gerencia**: realiza la aprobación final.
6. **Notificaciones automáticas**: cierra el proceso y comunica resultado.

## Implementación actual en el repositorio

- Se agregó el diagrama BPMN ejecutable con compuertas de aprobación/rechazo.
- Se modelaron tareas de usuario para los departamentos clave.
- Se incluyeron tareas de servicio para automatización de TI y notificaciones.

## Siguiente paso sugerido

Integrar este BPMN en un backend Spring Boot con Camunda y exponer formularios/tareas en React.
