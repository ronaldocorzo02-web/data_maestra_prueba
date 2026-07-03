/* 
Pregunta 4 — Análisis de tiempos por etapa del proceso  [Nivel: Avanzado]
Descompón el tiempo total del ciclo en las tres etapas del proceso y calcula para cada categoría:
•	Tiempo promedio en Etapa 1: Validación de Datos (fecha_validacion_datos - fecha_solicitud)
•	Tiempo promedio en Etapa 2: Revisión de Calidad (fecha_revision_calidad - fecha_validacion_datos)
•	Tiempo promedio en Etapa 3: Aprobación Regulatoria (fecha_aprobacion_regulatoria - fecha_revision_calidad) — considera solo las solicitudes que pasaron por esta etapa
•	Tiempo promedio total (fecha_cierre - fecha_solicitud)
•	Etapa más lenta (la que tiene mayor promedio) — identifícala con un CASE WHEN

Utiliza CTEs para calcular cada etapa de forma independiente antes de unirlas.

*/

WITH etapa_1 AS(

  select 
        c.categoria,

        AVG(
          DATETIME_DIFF(DATE(s.fecha_validacion_datos), s.fecha_solicitud,DAY)
        ) as promedio_etapa_1,   

  from `data_maestra.solicitudes_material` s
  join `data_maestra.categorias` c
  ON s.id_categoria = c.id_categoria
  group by c.categoria

),

etapa_2 AS (

    select 
        c.categoria,

        AVG(
          DATETIME_DIFF(s.fecha_revision_calidad, DATE(s.fecha_validacion_datos),DAY)
        ) as promedio_etapa_2,   

  from `data_maestra.solicitudes_material` s
  join `data_maestra.categorias` c
  ON s.id_categoria = c.id_categoria
  group by c.categoria

),

etapa_3 AS (
    select 
        c.categoria,

        AVG(
          DATETIME_DIFF(s.fecha_aprobacion_regulatoria, s.fecha_revision_calidad,DAY)
        ) as promedio_etapa_3,   

  from `data_maestra.solicitudes_material` s
  join `data_maestra.categorias` c
  ON s.id_categoria = c.id_categoria
  group by c.categoria

),

tiempo_total as(

    select 
        c.categoria,

        AVG(
          DATETIME_DIFF(s.fecha_cierre, s.fecha_solicitud,DAY)
        ) as promedio_tiempo_total,   

  from `data_maestra.solicitudes_material` s
  join `data_maestra.categorias` c
  ON s.id_categoria = c.id_categoria
  group by c.categoria

)

SELECT
    e1.categoria,
    
    ROUND(e1.promedio_etapa_1, 2) AS promedio_etapa_1_validacion,
    ROUND(e2.promedio_etapa_2, 2) AS promedio_etapa_2_calidad,
    ROUND(e3.promedio_etapa_3, 2) AS promedio_etapa_3_regulatoria,    
    ROUND(tt.promedio_tiempo_total,2) as promedio_tiempo_total,

    CASE
      WHEN e1.promedio_etapa_1 >= e2.promedio_etapa_2 and 
      e1.promedio_etapa_1 >=  COALESCE(e3.promedio_etapa_3,0) THEN 'Validación de Datos' 
      WHEN e2.promedio_etapa_2 >= e1.promedio_etapa_1 and 
      e2.promedio_etapa_2 >=  COALESCE(e3.promedio_etapa_3,0) THEN 'Revisión de Calidad' 
      ELSE 'Aprobación Regulatoria'
    END AS etapa_mas_lenta


    FROM etapa_1 e1
    JOIN etapa_2 e2
    ON e1.categoria = e2.categoria
    LEFT JOIN etapa_3 e3
    ON e1.categoria = e3.categoria
    JOIN tiempo_total tt
    ON e1.categoria = tt.categoria
    ORDER BY 1

