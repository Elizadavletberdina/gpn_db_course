CREATE SCHEMA IF NOT EXISTS dm;
CREATE OR REPLACE VIEW dm.well_repairs_failures AS
SELECT
    -- МОИ СКВАЖИНЫ
    w.well_id                           AS my_well_id,
    w.well_name                         AS my_well_name,
    ps.shop_name,
    f.field_name,

    -- СКВАЖИНЫ ЧУЖОЙ БД
    yw.well_id                          AS other_well_id,
    yw.well_number                      AS other_well_number,

    -- РЕМОНТЫ
    COALESCE(r.repairs_count, 0)        AS repairs_count,

    -- ОТКАЗЫ ОБОРУДОВАНИЯ
    COALESCE(yw.failures_count, 0)      AS failures_count

FROM oper.well w
JOIN dict.production_shop ps ON w.shop_id = ps.shop_id
JOIN dict.field f            ON ps.field_id = f.field_id

LEFT JOIN (
    SELECT
        wr.well_id,
        COUNT(wr.repair_id) AS repairs_count
    FROM oper.well_repair wr
    GROUP BY wr.well_id
) r ON r.well_id = w.well_id

LEFT JOIN (
    SELECT
        w2.well_id,
        w2.well_number,
        COUNT(ef.failure_id) AS failures_count
    FROM well_equipment_failures.wells w2
    LEFT JOIN well_equipment_failures.equipment e
           ON e.well_id = w2.well_id
    LEFT JOIN well_equipment_failures.equipmentfailures ef
           ON ef.equipment_id = e.equipment_id
    GROUP BY w2.well_id, w2.well_number
) yw
    ON CAST(w.well_name AS int) = CAST(SUBSTRING(yw.well_number, 2) AS int)

ORDER BY w.well_id;


SELECT *
FROM dm.well_repairs_failures
LIMIT 5;


SELECT
    w.well_id,
    w.well_name,
    COALESCE(r.repairs_count, 0) AS repairs_count,
    COALESCE(f.failures_count, 0) AS failures_count
FROM oper.well w
LEFT JOIN (
    SELECT well_id, COUNT(*) AS repairs_count
    FROM oper.well_repair
    GROUP BY well_id
) r USING (well_id)
LEFT JOIN (
    SELECT w.well_id, COUNT(ef.failure_id) AS failures_count
    FROM well_equipment_failures.wells w
    LEFT JOIN well_equipment_failures.equipment e USING (well_id)
    LEFT JOIN well_equipment_failures.equipmentfailures ef USING (equipment_id)
    GROUP BY w.well_id
) f USING (well_id)
ORDER BY w.well_id;

