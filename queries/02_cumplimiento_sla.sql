/* 
Pregunta 2 — Cumplimiento de SLA por área solicitante  [Nivel: Medio]
Calcula el cumplimiento del SLA para las solicitudes cerradas (Aprobadas o Rechazadas), agrupado por área del solicitante y tipo de material. Muestra:
•	Área del solicitante
•	Tipo de material
•	Total de solicitudes cerradas
•	Cantidad que cumplió SLA y cantidad que no
•	% de cumplimiento (con 1 decimal)
•	Promedio de días de ciclo

*/

SELECT   
      u.area,
      s.tipo_material,
      COUNT(*) as total_solicitudes_cerradas,

      SUM(
        CASE WHEN s.dias_ciclo <= s.sla_dias THEN 1 
        ELSE 0
        END
      ) as cumple_SLA,

      SUM(
        CASE WHEN s.dias_ciclo > s.sla_dias THEN 1 
        ELSE 0
        END
      ) as no_cumple_SLA,

      ROUND(

        SAFE_DIVIDE(
          SUM(CASE WHEN s.dias_ciclo <= s.sla_dias THEN 1 ELSE 0 END),
          COUNT(*)
            )*100,
      1) as porcentaje_cumplimiento,

      ROUND(
        AVG(s.dias_ciclo),
     2) as promedio_dias_ciclo

FROM `data_maestra.solicitudes_material` s
JOIN `data_maestra.usuarios` u
ON s.id_solicitante = u.id_usuario
group by 1,2
order by porcentaje_cumplimiento ASC
