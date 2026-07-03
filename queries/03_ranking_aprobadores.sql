/*
Pregunta 3 — Ranking de aprobadores por desempeño  [Nivel: Medio-Avanzado]
Construye un ranking de aprobadores usando ROW_NUMBER() (y opcionalmente DENSE_RANK()) basado en el % de solicitudes aprobadas sobre el total que gestionaron. Para cada aprobador muestra:
•	Nombre del aprobador y su área
•	Total de solicitudes gestionadas
•	Aprobadas / Rechazadas
•	% aprobación
•	Promedio de días de ciclo de sus solicitudes
•	ROW_NUMBER() particionado por área del aprobador, ordenado por % aprobación DESC
*/

WITH resumen_aprobadores AS (

SELECT
    u.nombre_completo as aprobador,
    u.area,
    COUNT(*) as total_solicitudes_gestionadas,

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

    ROUND(
      SAFE_DIVIDE(SUM(CASE WHEN s.estado = 'Aprobado' THEN 1 ELSE 0 END),
      COUNT(*) 
    )*100,
    2) as porcentaje_aprobacion,

    ROUND(
      AVG(s.dias_ciclo),
    2) as promedio_dias_ciclo

FROM `data_maestra.solicitudes_material` s
JOIN `data_maestra.usuarios` u
ON s.id_aprobador = u.id_usuario
WHERE s.estado in ('Aprobado','Rechazado')
group by 1,2
)

SELECT 
  ROW_NUMBER() OVER(
    PARTITION BY area
    ORDER BY porcentaje_aprobacion DESC
  ) AS ranking_area,
  aprobador,
  area,
  total_solicitudes_gestionadas,
  total_aprobadas,
  total_rechazadas,
  porcentaje_aprobacion,
  promedio_dias_ciclo,
  FROM
  resumen_aprobadores
  order by 1,2

