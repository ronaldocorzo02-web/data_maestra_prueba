/*
Pregunta 1 — Volumen y distribución de solicitudes  [Nivel: Básico-Medio]
Obtén un resumen mensual del año 2024 que muestre, por mes y categoría:
•	Total de solicitudes recibidas
•	Total aprobadas, rechazadas y en proceso
•	Porcentaje de aprobación sobre el total del mes
•	Ordenado por mes ascendente y por total de solicitudes descendente
*/

SELECT 
    FORMAT_DATE('%Y-%m',s.fecha_solicitud) as mes,
    COUNT(*) as total_solicitudes_recibidas,

    SUM(
      CASE WHEN s.estado = 'Aprobado' THEN 1
      ELSE 0
      END
    ) as total_aprobadas,

    SUM(
      CASE WHEN s.estado = 'Rechazado' THEN 1
      ELSE 0
      END
    ) as total_rechazadas,
    
    SUM(
      CASE WHEN s.estado = 'En Proceso' THEN 1
      ELSE 0
      END
    ) as total_en_proceso,

    ROUND(
      SAFE_DIVIDE(
        SUM(CASE WHEN s.estado= 'Aprobado' THEN 1 ELSE 0 END),
        COUNT(*)
      )*100,
    2) AS porcentaje_aprobacion

FROM `data_maestra.solicitudes_material` s
WHERE EXTRACT(YEAR FROM s.fecha_solicitud) = 2024
group by 1
order by mes ASC, total_solicitudes_recibidas DESC
