CREATE SCHEMA IF NOT EXISTS dict;
-- стадии разработки месторождения
CREATE TABLE IF NOT EXISTS dict.field_stage (
    field_stage_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    stage_name      VARCHAR(50) NOT NULL,
    description     TEXT
);

COMMENT ON TABLE dict.field_stage IS 'Справочник стадий месторождений';
COMMENT ON COLUMN dict.field_stage.field_stage_id IS 'PK';
COMMENT ON COLUMN dict.field_stage.stage_name IS 'Название стадии';
COMMENT ON COLUMN dict.field_stage.description IS 'Описание стадии';

-- месторождения
CREATE TABLE IF NOT EXISTS dict.field (
    field_id        INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    field_name      VARCHAR(100) NOT NULL,
    field_stage_id  INT NOT NULL,
    
    CONSTRAINT fk_field_stage FOREIGN KEY (field_stage_id)
        REFERENCES dict.field_stage(field_stage_id)
);

COMMENT ON TABLE dict.field IS 'Справочник месторождений';
COMMENT ON COLUMN dict.field.field_id IS 'PK';
COMMENT ON COLUMN dict.field.field_name IS 'Название месторождения';
COMMENT ON COLUMN dict.field.field_stage_id IS 'FK на стадию освоения';

-- цеха
CREATE TABLE IF NOT EXISTS dict.production_shop (
    shop_id     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    shop_name   VARCHAR(100) NOT NULL,
    field_id    INT NOT NULL,
    CONSTRAINT fk_production_shop_field
        FOREIGN KEY (field_id) REFERENCES dict.field(field_id)
);

COMMENT ON TABLE  dict.production_shop               IS 'Справочник цехов добычи';
COMMENT ON COLUMN dict.production_shop.shop_id       IS 'PK цеха';
COMMENT ON COLUMN dict.production_shop.shop_name     IS 'Название цеха';
COMMENT ON COLUMN dict.production_shop.field_id      IS 'FK на месторождение';

-- виды ремонтов
CREATE TABLE IF NOT EXISTS dict.repair_type (
    repair_type_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
    repair_type_name VARCHAR(100) NOT NULL, 
    description      TEXT
);

COMMENT ON TABLE  dict.repair_type                  IS 'Виды ремонтов скважин';
COMMENT ON COLUMN dict.repair_type.repair_type_id   IS 'PK вида ремонта';
COMMENT ON COLUMN dict.repair_type.repair_type_name IS 'Название вида ремонта';
COMMENT ON COLUMN dict.repair_type.description      IS 'Описание вида ремонта';

-- статусы ремонтов
CREATE TABLE IF NOT EXISTS dict.repair_status (
    repair_status_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    repair_status_name VARCHAR(100) NOT NULL,
    description        TEXT
);

COMMENT ON TABLE  dict.repair_status                     IS 'Справочник статусов ремонта';
COMMENT ON COLUMN dict.repair_status.repair_status_id    IS 'PK статуса ремонта';
COMMENT ON COLUMN dict.repair_status.repair_status_name  IS 'Название статуса ремонта';
COMMENT ON COLUMN dict.repair_status.description         IS 'Описание статуса ремонта';

--оборудование
CREATE TABLE IF NOT EXISTS dict.equipment (
    equipment_id      INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
    equipment_name    VARCHAR(100) NOT NULL, 
    equipment_purpose TEXT
);

COMMENT ON TABLE  dict.equipment                       IS 'Справочник оборудования';
COMMENT ON COLUMN dict.equipment.equipment_id          IS 'PK оборудования';
COMMENT ON COLUMN dict.equipment.equipment_name        IS 'Наименование оборудования';
COMMENT ON COLUMN dict.equipment.equipment_purpose     IS 'Назначение оборудования';

CREATE SCHEMA IF NOT EXISTS oper;
-- ремонтные бригады

CREATE TABLE IF NOT EXISTS oper.brigade (
    brigade_id         INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- PK бригады
    brigade_name       VARCHAR(100) NOT NULL,                        -- Название бригады
    brigade_type       VARCHAR(50) NOT NULL,                         -- Тип: 'собственная' / 'подрядная'
    organization_name  TEXT                                          -- Название организации (если подрядная)
);

COMMENT ON TABLE  oper.brigade                    IS 'Справочник ремонтных бригад';
COMMENT ON COLUMN oper.brigade.brigade_id        IS 'PK бригады';
COMMENT ON COLUMN oper.brigade.brigade_name      IS 'Название бригады';
COMMENT ON COLUMN oper.brigade.brigade_type      IS 'Тип бригады (собственная/подрядная)';
COMMENT ON COLUMN oper.brigade.organization_name IS 'Организация подрядчика';

-- сотрудники
CREATE TABLE IF NOT EXISTS oper.employee (
    employee_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,   -- PK сотрудника
    last_name     VARCHAR(100) NOT NULL,                          -- фамилия
    first_name    VARCHAR(100) NOT NULL,                          -- имя
    middle_name   VARCHAR(100),                                   -- отчество (может быть NULL)
    position_name VARCHAR(100) NOT NULL,                          -- должность сотрудника
    brigade_id    INT NOT NULL,                                   -- FK на бригаду

    CONSTRAINT fk_employee_brigade
        FOREIGN KEY (brigade_id) REFERENCES oper.brigade(brigade_id)
);

COMMENT ON TABLE  oper.employee                  IS 'Сотрудники ремонтных бригад';
COMMENT ON COLUMN oper.employee.employee_id      IS 'PK сотрудника';
COMMENT ON COLUMN oper.employee.last_name        IS 'Фамилия сотрудника';
COMMENT ON COLUMN oper.employee.first_name       IS 'Имя сотрудника';
COMMENT ON COLUMN oper.employee.middle_name      IS 'Отчество сотрудника';
COMMENT ON COLUMN oper.employee.position_name    IS 'Должность сотрудника';
COMMENT ON COLUMN oper.employee.brigade_id       IS 'FK на бригаду';

-- скважины
CREATE TABLE IF NOT EXISTS oper.well (
    well_id      INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,               -- PK скважины
    well_name    VARCHAR(100) NOT NULL,                                      -- Название скважины
    shop_id      INT NOT NULL,                                               -- FK на цех добычи
    well_type    VARCHAR(50) NOT NULL,                                       -- Тип скважины (добывающая/нагнетательная и т.д.)
    well_status  VARCHAR(50) NOT NULL,                                       -- Статус скважины (активна/остановлена/в ремонте/законсервирована)

    CONSTRAINT fk_well_shop
        FOREIGN KEY (shop_id) REFERENCES dict.production_shop(shop_id)
);

COMMENT ON TABLE  oper.well                IS 'Скважины';
COMMENT ON COLUMN oper.well.well_id        IS 'PK скважины';
COMMENT ON COLUMN oper.well.well_name      IS 'Название скважины';
COMMENT ON COLUMN oper.well.shop_id        IS 'FK на цех добычи';
COMMENT ON COLUMN oper.well.well_type      IS 'Тип скважины';
COMMENT ON COLUMN oper.well.well_status    IS 'Статус скважины';

-- ремонты скважин

CREATE TABLE IF NOT EXISTS oper.well_repair (
    repair_id        INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,       -- PK ремонта
    well_id          INT NOT NULL,                                       -- FK на скважину
    repair_type_id   INT NOT NULL,                                       -- FK на вид ремонта
    repair_status_id INT NOT NULL,                                       -- FK на статус ремонта
    brigade_id       INT NOT NULL,                                       -- FK на бригаду, выполняющую ремонт
    planned_start_date DATE,
    planned_end_date   DATE,                                             -- плановые даты ремонта
    actual_start_date  DATE,
    actual_end_date    DATE,                                             -- фактические даты ремонта
    reason          TEXT,                                                -- причина ремонта
    result_comment  TEXT,                                                -- результат ремонта / комментарий

    CONSTRAINT fk_repair_well
        FOREIGN KEY (well_id) REFERENCES oper.well(well_id),

    CONSTRAINT fk_repair_type
        FOREIGN KEY (repair_type_id) REFERENCES dict.repair_type(repair_type_id),

    CONSTRAINT fk_repair_status
        FOREIGN KEY (repair_status_id) REFERENCES dict.repair_status(repair_status_id),

    CONSTRAINT fk_repair_brigade
        FOREIGN KEY (brigade_id) REFERENCES oper.brigade(brigade_id)
);

COMMENT ON TABLE  oper.well_repair                   IS 'Ремонты скважин';
COMMENT ON COLUMN oper.well_repair.repair_id         IS 'PK ремонта';
COMMENT ON COLUMN oper.well_repair.well_id           IS 'FK на скважину';
COMMENT ON COLUMN oper.well_repair.repair_type_id    IS 'FK на вид ремонта';
COMMENT ON COLUMN oper.well_repair.repair_status_id  IS 'FK на статус ремонта';
COMMENT ON COLUMN oper.well_repair.brigade_id        IS 'FK на бригаду';
COMMENT ON COLUMN oper.well_repair.planned_start_date IS 'Плановая дата начала';
COMMENT ON COLUMN oper.well_repair.planned_end_date   IS 'Плановая дата окончания';
COMMENT ON COLUMN oper.well_repair.actual_start_date  IS 'Фактическая дата начала';
COMMENT ON COLUMN oper.well_repair.actual_end_date    IS 'Фактическая дата окончания';
COMMENT ON COLUMN oper.well_repair.reason             IS 'Причина ремонта';
COMMENT ON COLUMN oper.well_repair.result_comment     IS 'Результат ремонта / комментарий';

--события статуса скважины (остановка, запуск и т.д.)

CREATE TABLE IF NOT EXISTS oper.well_state_event (
    event_id      INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,         -- PK события
    well_id       INT NOT NULL,                                         -- FK на скважину
    repair_id     INT,                                                  -- FK на ремонт (если событие связано с ремонтом), может быть NULL
    event_type    VARCHAR(50) NOT NULL,                                 -- тип события: 'Остановка', 'Запуск', 'Перевод в простой', и т.п.
    event_datetime TIMESTAMP NOT NULL,                                  -- дата и время события
    reason        TEXT,                                                 -- причина события (опционально)

    CONSTRAINT fk_event_well
        FOREIGN KEY (well_id) REFERENCES oper.well(well_id),

    CONSTRAINT fk_event_repair
        FOREIGN KEY (repair_id) REFERENCES oper.well_repair(repair_id)
);

COMMENT ON TABLE  oper.well_state_event                IS 'События состояния скважины';
COMMENT ON COLUMN oper.well_state_event.event_id       IS 'PK события';
COMMENT ON COLUMN oper.well_state_event.well_id        IS 'FK на скважину';
COMMENT ON COLUMN oper.well_state_event.repair_id      IS 'FK на ремонт (может быть NULL)';
COMMENT ON COLUMN oper.well_state_event.event_type     IS 'Тип события';
COMMENT ON COLUMN oper.well_state_event.event_datetime IS 'Дата и время события';
COMMENT ON COLUMN oper.well_state_event.reason         IS 'Причина события';

-- использование оборудования в рамках ремонта

CREATE TABLE IF NOT EXISTS oper.repair_equipment_usage (
    usage_id         INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,       -- PK записи использования оборудования
    repair_id        INT NOT NULL,                                       -- FK на ремонт скважины
    equipment_id     INT NOT NULL,                                       -- FK на оборудование
    usage_description TEXT,                                              -- Описание использования оборудования (опционально)

    CONSTRAINT fk_usage_repair
        FOREIGN KEY (repair_id) REFERENCES oper.well_repair(repair_id),

    CONSTRAINT fk_usage_equipment
        FOREIGN KEY (equipment_id) REFERENCES dict.equipment(equipment_id)
);

COMMENT ON TABLE  oper.repair_equipment_usage                IS 'Использование оборудования в ремонтах';
COMMENT ON COLUMN oper.repair_equipment_usage.usage_id       IS 'PK использования оборудования';
COMMENT ON COLUMN oper.repair_equipment_usage.repair_id      IS 'FK на ремонт скважины';
COMMENT ON COLUMN oper.repair_equipment_usage.equipment_id   IS 'FK на оборудование';
COMMENT ON COLUMN oper.repair_equipment_usage.usage_description IS 'Описание использования оборудования';

SET search_path TO oper, dict, public;

-- заполнение таблицы со стадией месторождения

INSERT INTO field_stage (stage_name, description)
VALUES
  ('Разведка',      'Этап геологоразведочных работ'),
  ('Освоение',      'Подготовка и ввод месторождения в разработку'),
  ('Разработка',    'Стадия активной добычи'),
  ('Истощение',     'Снижение дебитов и выработки запасов'),
  ('Ликвидация',    'Вывод месторождения из эксплуатации');

-- проверка
SELECT * FROM field_stage;

-- заполение месторождений
INSERT INTO field (field_name, field_stage_id)
VALUES
  ('Приобское',      3),  -- разработка
  ('Ванкорское',     3),  -- разработка
  ('Ромашкинское',   4),  -- истощение
  ('Новое Северное', 1);  -- разведка

  -- проверка
  SELECT field_stage_id, stage_name FROM field_stage;
  SELECT * FROM field;
SELECT field_id, field_name FROM field;

-- цех присваиваем к месторождению
INSERT INTO production_shop (shop_name, field_id)
VALUES
  ('ЦДНГ-1', 1),  -- у Приобского
  ('ЦДНГ-2', 1),  -- у Приобского
  ('ЦДНГ-3', 2),  -- у Ванкорского
  ('ЦДНГ-4', 3);  -- у Ромашкинского

-- проверка
SELECT * FROM production_shop;

-- виды ремонтов таблица
INSERT INTO repair_type (repair_type_name, description)
VALUES
  ('Текущий',      'Мелкий ремонт с короткой продолжительностью'),
  ('Капитальный',  'Крупный ремонт с заменой оборудования'),
  ('ГРП',          'Гидроразрыв пласта'),
  ('ОПЗ',          'Оптимизация призабойной зоны');

-- проверка
SELECT * FROM repair_type;

-- статусы ремонта
INSERT INTO repair_status (repair_status_name, description)
VALUES
  ('Планируется', 'Ремонт ещё не начат, находится в плане'),
  ('В работе',    'Ремонт выполняется'),
  ('Завершён',    'Ремонт завершён успешно'),
  ('Отменён',     'Ремонт был отменён');

-- проверка
SELECT * FROM repair_status;

-- оборудовани
INSERT INTO equipment (equipment_name, equipment_purpose)
VALUES
  ('Насос ЭЦН',        'Подъём жидкости из скважины'),
  ('Штанговый насос',  'Механизированная добыча нефти'),
  ('Пакер',            'Разделение интервалов в скважине'),
  ('Компрессорная установка', 'Закачка газа или воздуха'),
  ('Сваб',             'Удаление жидкости из ствола скважины');

-- проверка
SELECT * FROM equipment;

-- бригады
INSERT INTO brigade (brigade_name, brigade_type, organization_name)
VALUES
  ('Бригада №1', 'собственная', NULL),
  ('Бригада №2', 'собственная', NULL),
  ('Бригада №3', 'подрядная',   'ООО "РемНефть"');

-- проверка
SELECT * FROM brigade;

-- проверка Id бригад
SELECT brigade_id, brigade_name FROM brigade;

-- таблица сотрудников
INSERT INTO employee (last_name, first_name, middle_name, position_name, brigade_id)
VALUES
  ('Иванов',  'Иван',   'Иванович',  'Мастер',      1),
  ('Петров',  'Пётр',   'Сергеевич', 'Оператор',    1),
  ('Сидоров', 'Алексей','Павлович',  'Мастер',      2),
  ('Кузнецов','Александр',  'Игоревич',  'Инженер',     2),
  ('Смирнов', 'Олег',   'Ильич',     'Оператор',    3);

--проверка
SELECT * FROM employee;

-- просмотр цехов
SELECT shop_id, shop_name, field_id FROM production_shop;

-- табл скважин
INSERT INTO well (well_name, shop_id, well_type, well_status)
VALUES
  ('101', 1, 'добывающая',  'активна'),
  ('102', 1, 'добывающая',  'в ремонте'),
  ('201', 2, 'нагнетательная', 'активна'),
  ('301', 3, 'добывающая',  'остановлена'),
  ('302', 3, 'добывающая',  'активна');

SELECT * FROM well;
 -----------------
--ремонты скважин
INSERT INTO well_repair (
    well_id, repair_type_id, repair_status_id, brigade_id,
    planned_start_date, planned_end_date,
    actual_start_date,  actual_end_date,
    reason, result_comment
)
VALUES
  (2, 1, 3, 1,
   DATE '2025-01-10', DATE '2025-01-12',
   DATE '2025-01-10', DATE '2025-01-11',
   'Снижение дебита', 'Заменён насос ЭЦН'),

  (4, 2, 2, 2,
   DATE '2025-02-05', DATE '2025-02-20',
   DATE '2025-02-06', NULL,
   'Аварийный отказ оборудования', 'Ремонт в процессе');

SELECT * FROM well_repair;

SELECT repair_id, well_id FROM well_repair;
SELECT equipment_id, equipment_name FROM equipment;
----------------------

-- использование оборудования
INSERT INTO repair_equipment_usage (repair_id, equipment_id, usage_description)
VALUES
  (1, 1, 'Установлен новый насос ЭЦН'),
  (2, 3, 'Установлен новый пакер в интервале пласта');

SELECT * FROM repair_equipment_usage;

SELECT well_id, well_name FROM well;
SELECT repair_id, well_id FROM well_repair;
--------------------------------
INSERT INTO well_state_event (
    well_id, repair_id, event_type, event_datetime, reason
)
VALUES
  (2, 1, 'Остановка', TIMESTAMP '2025-01-10 08:00:00', 'Остановка для текущего ремонта'),
  (2, 1, 'Запуск',    TIMESTAMP '2025-01-11 18:30:00', 'Запуск после ремонта'),
  (4, 2, 'Остановка', TIMESTAMP '2025-02-06 03:15:00', 'Аварийный отказ насоса');

SELECT * FROM well_state_event;
--------------------------------
CREATE TABLE IF NOT EXISTS dict.repair_reason (
    repair_reason_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    repair_reason_name VARCHAR(200) NOT NULL,
    description        TEXT
);

COMMENT ON TABLE  dict.repair_reason                  IS 'Справочник причин ремонта';
COMMENT ON COLUMN dict.repair_reason.repair_reason_id IS 'PK причины ремонта';
COMMENT ON COLUMN dict.repair_reason.repair_reason_name IS 'Причина ремонта';
COMMENT ON COLUMN dict.repair_reason.description      IS 'Описание причины ремонта';

-- создание таблицы с причиной ремонта

INSERT INTO dict.repair_reason (repair_reason_name, description)
VALUES
    ('Снижение дебита', 'Уменьшение добычи нефти'),
    ('Отказ насоса', 'Неисправность ЭЦН/ШГН'),
    ('Нарушение герметичности', 'Проблемы с колонной/пакером'),
    ('Аварийная ситуация', 'Экстренный ремонт'),
    ('Плановое обслуживание', 'Регламентные работы');

SET search_path TO oper, dict, public;

-- справочник типов событий
CREATE TABLE IF NOT EXISTS dict.event_type (
    event_type_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    event_type_name VARCHAR(100) NOT NULL,
    description     TEXT
);

COMMENT ON TABLE  dict.event_type                  IS 'Справочник типов событий скважины';
COMMENT ON COLUMN dict.event_type.event_type_id    IS 'PK типа события';
COMMENT ON COLUMN dict.event_type.event_type_name  IS 'Наименование события';
COMMENT ON COLUMN dict.event_type.description      IS 'Описание события';

-- табл с типами ремонтов
INSERT INTO event_type (event_type_name, description)
VALUES
    ('Остановка', 'Скважина остановлена'),
    ('Запуск', 'Скважина запущена'),
    ('Простой', 'Скважина в простое'),
    ('В ремонт', 'Остановка на ремонт'),
    ('После ремонта', 'Запуск после завершения ремонта');

-- добавляю поле в ремонты скважин
ALTER TABLE oper.well_repair
ADD COLUMN repair_reason_id INT;

-- fk в табл ремонты скважин
ALTER TABLE oper.well_repair
ADD CONSTRAINT fk_wellrepair_reason
    FOREIGN KEY (repair_reason_id)
    REFERENCES dict.repair_reason(repair_reason_id);
-- новое поле в табл
ALTER TABLE oper.well_state_event
ADD COLUMN event_type_id INT;

-- добавляю fk
ALTER TABLE oper.well_state_event
ADD CONSTRAINT fk_event_type
    FOREIGN KEY (event_type_id)
    REFERENCES dict.event_type(event_type_id);

--добавление причины
INSERT INTO dict.repair_reason (repair_reason_name, description)
VALUES ('Аварийный отказ оборудования', 'Аварийная причина ремонта');

-- обновление причин
UPDATE oper.well_repair wr
SET repair_reason_id = rr.repair_reason_id
FROM dict.repair_reason rr
WHERE wr.reason = rr.repair_reason_name;

--проверка
SELECT repair_id, reason, repair_reason_id
FROM oper.well_repair;

-- обновление состоянияй
UPDATE oper.well_state_event we
SET event_type_id = et.event_type_id
FROM dict.event_type et
WHERE we.event_type = et.event_type_name;

--проверка
SELECT event_id, event_type, event_type_id
FROM oper.well_state_event;

SET search_path TO oper, dict, public;

-- Добавим 95 сотрудников в разные бригады
INSERT INTO employee (last_name, first_name, middle_name, position_name, brigade_id)
SELECT
    'Фамилия_'   || g AS last_name,
    'Имя_'       || g AS first_name,
    'Отчество_'  || g AS middle_name,
    CASE (g % 3)
        WHEN 0 THEN 'Мастер'
        WHEN 1 THEN 'Оператор'
        ELSE 'Инженер'
    END AS position_name,
    (
        SELECT brigade_id
        FROM brigade
        ORDER BY brigade_id
        LIMIT 1 OFFSET ((g - 1) % (SELECT count(*) FROM brigade))
    ) AS brigade_id
FROM generate_series(1, 95) AS g;

INSERT INTO employee (
    last_name,
    first_name,
    middle_name,
    position_name,
    brigade_id
)
SELECT
    'Фамилия_'  || (g + 95)       AS last_name,
    'Имя_'      || (g + 95)       AS first_name,
    'Отчество_' || (g + 95)       AS middle_name,
    CASE ((g + 95) % 3)
        WHEN 1 THEN 'Мастер'
        WHEN 2 THEN 'Оператор'
        ELSE 'Инженер'
    END                           AS position_name,
    (
        SELECT brigade_id
        FROM brigade
        ORDER BY brigade_id
        LIMIT 1 OFFSET (((g + 95) - 1) % (SELECT count(*) FROM brigade))
    )                             AS brigade_id
FROM generate_series(1, 105) AS g;

-- Проверка количества сотрудников
SELECT count(*) AS employee_count FROM employee;

-- проверка первых 10
SELECT * FROM employee ORDER BY employee_id LIMIT 10;

-- проверка месторождений
SELECT field_id, field_name, field_stage_id
FROM field
ORDER BY field_id;

-- добавляем еще месторождения
INSERT INTO field (field_name, field_stage_id)
SELECT
    'Месторождение_' || g AS field_name,
    (
        SELECT field_stage_id
        FROM field_stage
        ORDER BY field_stage_id
        LIMIT 1 OFFSET ((g - 1) % (SELECT count(*) FROM field_stage))
    ) AS field_stage_id
FROM generate_series(1, 16) AS g;

--проверка количества месторождений
SELECT count(*) AS field_count FROM field;

SELECT field_id, field_name, field_stage_id
FROM field
ORDER BY field_id;


-- очищаем существующие цехи и скважины, чтобы не мешали старые данные
TRUNCATE TABLE oper.well RESTART IDENTITY CASCADE;
TRUNCATE TABLE dict.production_shop RESTART IDENTITY CASCADE;

-- для каждого месторождения выбираем случайное число цехов от 7 до 13
WITH field_with_cnt AS (
    SELECT
        f.field_id,
        (floor(random() * 7)::int + 7) AS shop_cnt  -- 7..13 цехов на месторождение
    FROM dict.field f
)
INSERT INTO dict.production_shop (shop_name, field_id)
SELECT
    'ЦДНГ-' || g.shop_num AS shop_name,  -- ЦДНГ-1, ЦДНГ-2, ... в пределах месторождения
    f.field_id
FROM field_with_cnt f
CROSS JOIN LATERAL generate_series(1, f.shop_cnt) AS g(shop_num);

-- проверка: сколько цехов у каждого месторождения
SELECT field_id, COUNT(*) AS shop_count
FROM dict.production_shop
GROUP BY field_id
ORDER BY field_id;

-- очистка таблиц скважин
TRUNCATE TABLE
    oper.repair_equipment_usage,
    oper.well_state_event,
    oper.well_repair,
    oper.well

   RESTART IDENTITY CASCADE;

--заполнение таблиц
WITH base AS (
    SELECT
        ps.shop_id,
        ps.field_id,
        gs AS local_seq
    FROM dict.production_shop ps
    CROSS JOIN generate_series(1, 25) AS gs
),
numbered AS (
    SELECT
        shop_id,
        field_id,
        ROW_NUMBER() OVER (
            PARTITION BY field_id
            ORDER BY shop_id, local_seq
        ) AS well_seq
    FROM base
)
INSERT INTO oper.well (well_name, shop_id, well_type, well_status)
SELECT
    well_seq::text AS well_name,
    shop_id,
    CASE (well_seq % 3)
        WHEN 1 THEN 'добывающая'
        WHEN 2 THEN 'нагнетательная'
        ELSE       'оценочная'
    END,
    CASE (well_seq % 3)
        WHEN 1 THEN 'активна'
        WHEN 2 THEN 'в ремонте'
        ELSE       'остановлена'
    END
FROM numbered
ORDER BY field_id, shop_id, well_seq;

--проверка количества
SELECT COUNT(*) AS total_wells
FROM oper.well;

-- запрос для скважин которые находятся на мест-ии в ликвидации
-- Все скважины на месторождениях в стадии "Ликвидация" должны быть остановлены

UPDATE oper.well w
SET well_status = 'остановлена'
FROM dict.production_shop ps
JOIN dict.field f ON f.field_id = ps.field_id
JOIN dict.field_stage fs ON fs.field_stage_id = f.field_stage_id
WHERE w.shop_id = ps.shop_id
  AND fs.stage_name = 'Ликвидация';

-- проверка
SELECT w.well_id, w.well_name, w.well_status, f.field_name, fs.stage_name
FROM oper.well w
JOIN dict.production_shop ps ON ps.shop_id = w.shop_id
JOIN dict.field f ON f.field_id = ps.field_id
JOIN dict.field_stage fs ON fs.field_stage_id = f.field_stage_id
WHERE fs.stage_name = 'Ликвидация'
LIMIT 20;

-- очистка старых таблиц с бригадами
TRUNCATE TABLE oper.employee, oper.brigade
RESTART IDENTITY CASCADE;

--создание 3 бригад на каждый цех
INSERT INTO oper.brigade (brigade_name, brigade_type, organization_name)
SELECT
    'Бригада_' || ps.shop_id || '_' || g AS brigade_name,
    CASE 
        WHEN g = 3 THEN 'подрядная'
        ELSE 'собственная'
    END AS brigade_type,
    CASE 
        WHEN g = 3 THEN 'ООО "Подрядчик_' || ps.shop_id || '"'
        ELSE NULL
    END AS organization_name
FROM dict.production_shop ps
CROSS JOIN generate_series(1, 3) AS g;

-- на каждую бригаду  10 сотрудников
INSERT INTO oper.employee (
    last_name,
    first_name,
    middle_name,
    position_name,
    brigade_id
)
SELECT
    'Фамилия_'  || b.brigade_id || '_' || g AS last_name,
    'Имя_'      || b.brigade_id || '_' || g AS first_name,
    'Отчество_' || b.brigade_id || '_' || g AS middle_name,
    CASE (g % 3)
        WHEN 1 THEN 'Мастер'
        WHEN 2 THEN 'Оператор'
        ELSE       'Инженер'
    END AS position_name,
    b.brigade_id
FROM oper.brigade b
CROSS JOIN generate_series(1, 10) AS g;

--проверки
SELECT COUNT(*) AS brigade_count FROM oper.brigade;

SELECT COUNT(*) AS employee_count FROM oper.employee;

SELECT * FROM oper.employee
ORDER BY employee_id
LIMIT 10;

-- проверка по цеху
ALTER TABLE oper.brigade
ADD COLUMN shop_id INT;
UPDATE oper.brigade
SET shop_id = split_part(brigade_name, '_', 2)::INT;

SELECT 
    e.employee_id,
    e.last_name,
    e.first_name,
    e.position_name,
    b.brigade_name,
    b.shop_id
FROM oper.employee e
JOIN oper.brigade b ON b.brigade_id = e.brigade_id
WHERE b.shop_id = 1         -- номер нужного цеха
LIMIT 10;

--добавление видов ремонта
INSERT INTO dict.repair_type (repair_type_name, description)
VALUES
  ('Замена погружного насоса ЭЦН',
   'Снятие и установка нового электроцентробежного насоса'),

  ('Замена штангового насоса ШГН',
   'Подъём и спуск штангового насоса с заменой узлов'),

  ('Подъём колонны НКТ',
   'Подъём насосно-компрессорных труб для ревизии или ремонта'),

  ('Спуск колонны НКТ',
   'Спуск насосно-компрессорных труб после ремонта или замены'),

  ('Промывка ствола скважины',
   'Гидравлическая промывка ствола для удаления шлама и отложений'),

  ('Очистка от парафина',
   'Механическая или тепловая очистка ствола от парафиновых отложений'),

  ('Очистка от АСПО',
   'Удаление асфальтосмолопарафиновых отложений'),

  ('Кислотная обработка пласта',
   'Обработка пласта кислотными составами для увеличения проницаемости'),

  ('Кислотная обработка призабойной зоны',
   'Кислотная обработка ПЗП для восстановления приемистости/притока'),

  ('Обработка ПЗП ПАВ',
   'Обработка призабойной зоны поверхностно-активными веществами'),

  ('Повторный ГРП',
   'Повторное проведение гидроразрыва пласта на ранее обработанном объекте'),

  ('Многозонный ГРП',
   'Проведение ГРП на нескольких интервалах перфорации'),

  ('Установка пакера',
   'Спуск и установка пакера для изоляции интервала'),

  ('Замена пакера',
   'Подъём и замена пакера при отказе или выходе из строя'),

  ('Изоляция водопритока',
   'Изоляционные работы по отсечению водоносных интервалов'),

  ('Цементаж межколонного пространства',
   'Закачка цементного раствора в межколонное пространство'),

  ('Восстановление герметичности эксплуатационной колонны',
   'Ремонт негерметичных участков эксплуатационной колонны'),

  ('Устранение негерметичности фонтанной арматуры',
   'Ремонт и замена элементов фонтанной арматуры'),

  ('Установка цементного моста',
   'Установка цементного моста для изоляции интервала или ликвидации'),

  ('Ликвидация аварийного насоса',
   'Подъём заклиненного или аварийного насоса'),

  ('Ликвидация прихвата колонны НКТ',
   'Освобождение прихваченной колонны насосно-компрессорных труб'),

  ('Ликвидация прихвата инструмента',
   'Аварийно-спасательные работы по извлечению инструмента'),

  ('Ремонт забойного фильтра',
   'Очистка или замена фильтра на забое скважины'),

  ('Замена хвостовика',
   'Демонтаж и монтаж нового хвостовика'),

  ('Доперфорация интервала',
   'Дополнительная перфорация продуктивного интервала'),

  ('Переперфорация интервала',
   'Перфорация с перекрытием старых перфорационных каналов'),

  ('Перевод на другой пласт',
   'Изменение объекта эксплуатации скважины'),

  ('Перевод скважины на нагнетание',
   'Переоборудование добывающей скважины в нагнетательную'),

  ('Перевод скважины на консервацию',
   'Подземные работы по подготовке скважины к консервации'),

  ('Восстановление после консервации',
   'Ремонт и освоение скважины после периода консервации'),

  ('Освоение после ремонта',
   'Освоение скважины после проведения ремонтных работ'),

  ('Освоение новой скважины',
   'Пусковая операция для ввода новой скважины в эксплуатацию'),

  ('Газлифтная очистка ствола',
   'Очистка ствола путём газлифтной продувки'),

  ('Свабирование скважины',
   'Удаление жидкости из ствола свабами'),

  ('Установка глубинного манометра',
   'Спуск и установка глубинного измерительного прибора'),

  ('Замена глубинного манометра',
   'Подъём и замена глубинного манометра'),

  ('Переоснащение на ЭЦН',
   'Перевод скважины на эксплуатацию с установкой ЭЦН'),

  ('Переоснащение на ШГН',
   'Перевод скважины на эксплуатацию с установкой штангового насоса'),

  ('Тампонажные работы',
   'Закачка тампонажных материалов для изоляции интервалов'),

  ('Диагностика технического состояния скважины',
   'Комплекс работ по обследованию состояния ствола и колонн'),

  ('Профилактический ремонт оборудования',
   'Регламентный ремонт без проявлений отказов'),

  ('Ликвидационный подземный ремонт',
   'Подземные работы, предшествующие окончательной ликвидации'),

  ('Подземная ликвидация скважины',
   'Комплекс работ по окончательной ликвидации скважины'),

  ('Ремонт устья скважины',
   'Ремонт и замена элементов устьевого оборудования'),

  ('Испытание на герметичность колонн',
   'Проверка колонн на герметичность под давлением'),

  ('Испытание на герметичность обсадной колонны',
   'Локальное испытание обсадной колонны на герметичность'),

  ('Установка ограничителя дебита',
   'Монтаж устройств, ограничивающих дебит скважины'),

  ('Снятие ограничителя дебита',
   'Демонтаж ограничивающих устройств и восстановление дебита');

--проверка ремонтов
  SELECT repair_type_id, repair_type_name, description
FROM dict.repair_type
ORDER BY repair_type_id;


-- выбираем только те скважины, где можно делать ремонты
WITH eligible_wells AS (
    SELECT
        w.well_id
    FROM oper.well w
    JOIN dict.production_shop ps ON ps.shop_id = w.shop_id
    JOIN dict.field f            ON f.field_id = ps.field_id
    JOIN dict.field_stage fs     ON fs.field_stage_id = f.field_stage_id
    WHERE fs.stage_name <> 'Ликвидация'              -- месторождение НЕ ликвидировано
      AND w.well_status <> 'консервация'            -- скважина НЕ законсервирована
),

--выбираем 3500 разных скважин
sample AS (
    SELECT well_id
    FROM eligible_wells
    ORDER BY random()
    LIMIT 3500
)

-- 3. Генерируем ремонты (1 ремонт на каждую выбранную скважину)
INSERT INTO oper.well_repair (
    well_id,
    repair_type_id,
    repair_status_id,
    brigade_id,
    planned_start_date,
    planned_end_date,
    actual_start_date,
    actual_end_date,
    reason,
    result_comment,
    repair_reason_id
)
SELECT
    s.well_id,

    -- случайный вид ремонта
    (SELECT repair_type_id
     FROM dict.repair_type
     ORDER BY random()
     LIMIT 1),

    -- случайный статус ремонта
    (SELECT repair_status_id
     FROM dict.repair_status
     ORDER BY random()
     LIMIT 1),

    -- случайная бригада
    (SELECT brigade_id
     FROM oper.brigade
     ORDER BY random()
     LIMIT 1),

    -- даты план / факт
    DATE '2024-01-01' + (random() * 365)::INT,
    DATE '2024-02-01' + (random() * 365)::INT,
    DATE '2024-01-02' + (random() * 365)::INT,

    CASE 
        WHEN random() < 0.85 THEN DATE '2024-02-10' + (random() * 365)::INT
        ELSE NULL  -- ремонт может не завершиться
    END,

    -- текст причины
    'Причина ремонта №' || s.well_id,
    'Автоматически сгенерированный ремонт',

    -- случайная причина ремонта из справочника
    (SELECT repair_reason_id
     FROM dict.repair_reason
     ORDER BY random()
     LIMIT 1)

FROM sample s;

--проверка сколько ремонтов создалось
SELECT COUNT(*) FROM oper.well_repair;

--очистка событий
TRUNCATE TABLE oper.well_state_event
RESTART IDENTITY;

--события (по 2 события на один ремонт)
INSERT INTO oper.well_state_event (
    well_id,
    repair_id,
    event_type,
    event_datetime,
    reason,
    event_type_id
)
WITH base AS (
    SELECT
        r.repair_id,
        r.well_id,
        r.actual_start_date,
        r.actual_end_date,
        COALESCE(r.actual_start_date, r.planned_start_date) AS start_dt,
        COALESCE(r.actual_end_date,   r.planned_end_date)   AS end_dt
    FROM oper.well_repair r
),
types AS (
    SELECT
        MAX(CASE WHEN event_type_name = 'В ремонт'        THEN event_type_id END) AS id_to_repair,
        MAX(CASE WHEN event_type_name = 'После ремонта'   THEN event_type_id END) AS id_after_repair,
        MAX(CASE WHEN event_type_name = 'Простой'         THEN event_type_id END) AS id_idle
    FROM dict.event_type
)
-- 1) событие "В ремонт"
SELECT
    b.well_id,
    b.repair_id,
    'В ремонт'::varchar AS event_type,
    (b.start_dt::timestamp + (random() * interval '12 hours')) AS event_datetime,
    'Вывод скважины в ремонт' AS reason,
    t.id_to_repair AS event_type_id
FROM base b
CROSS JOIN types t

UNION ALL

-- 2) событие после ремонта или простой
SELECT
    b.well_id,
    b.repair_id,
    CASE 
        WHEN b.actual_end_date IS NOT NULL THEN 'После ремонта'
        ELSE 'Простой'
    END AS event_type,
    (b.end_dt::timestamp + (random() * interval '12 hours')) AS event_datetime,
    CASE 
        WHEN b.actual_end_date IS NOT NULL 
            THEN 'Скважина после завершения ремонта'
        ELSE 'Скважина в простое по причине незавершённого ремонта'
    END AS reason,
    CASE 
        WHEN b.actual_end_date IS NOT NULL THEN t.id_after_repair
        ELSE t.id_idle
    END AS event_type_id
FROM base b
CROSS JOIN types t;

--проверки
SELECT COUNT(*) AS event_count
FROM oper.well_state_event;

--очистка по оборудованию
TRUNCATE TABLE oper.repair_equipment_usage
RESTART IDENTITY;

--использование оборудования
INSERT INTO oper.repair_equipment_usage (
    repair_id,
    equipment_id,
    usage_description
)
SELECT
    (SELECT repair_id
     FROM oper.well_repair
     ORDER BY random()
     LIMIT 1) AS repair_id,
    (SELECT equipment_id
     FROM dict.equipment
     ORDER BY random()
     LIMIT 1) AS equipment_id,
    'Использование оборудования #' || seq AS usage_description
FROM generate_series(1, 6000) AS seq;

--очистка табл событий
TRUNCATE TABLE oper.well_state_event
RESTART IDENTITY;

--события для 1000 ремонтов
INSERT INTO oper.well_state_event (
    well_id,
    repair_id,
    event_type,
    event_datetime,
    reason,
    event_type_id
)
SELECT
    -- случайная скважина
    (SELECT well_id 
     FROM oper.well 
     ORDER BY random()
     LIMIT 1),

    -- случайный ремонт
    (SELECT repair_id
     FROM oper.well_repair
     ORDER BY random()
     LIMIT 1),

    -- случайный тип события (текст)
    (SELECT event_type_name
     FROM dict.event_type
     ORDER BY random()
     LIMIT 1),

    -- случайная дата
    TIMESTAMP '2024-01-01' + (random() * INTERVAL '365 days'),

    -- простая текстовая причина
    'Событие №' || seq,

    -- корректный FK на тип события
    (SELECT event_type_id
     FROM dict.event_type
     ORDER BY random()
     LIMIT 1)

FROM generate_series(1, 1000) seq;

--проверки
SELECT COUNT(*) 
FROM oper.well_state_event;

SELECT *
FROM oper.well_state_event
ORDER BY event_id
LIMIT 10;

--индексы btree (Тк таблица well_repair содержит большой объём данных (3500). ремонты анализируется в разарезе дат, btree подходит для этого лучше)

CREATE INDEX well_repair_actual_start_date_idx
ON oper.well_repair
USING btree (actual_start_date);

--проверка индекса
SELECT *
FROM oper.well_repair
WHERE actual_start_date
      BETWEEN DATE '2024-01-01' AND DATE '2024-03-31';

-- заполнение событий на каждый вид (в ремонтен/план и тд)
TRUNCATE TABLE oper.well_state_event
RESTART IDENTITY;

INSERT INTO oper.well_state_event (
    well_id,
    repair_id,
    event_type,
    event_datetime,
    reason,
    event_type_id
)
SELECT
    -- случайная скважина
    (SELECT well_id 
     FROM oper.well 
     ORDER BY random() 
     LIMIT 1),

    -- случайный ремонт
    (SELECT repair_id
     FROM oper.well_repair
     ORDER BY random()
     LIMIT 1),

    -- текстовое имя типа события
    et.event_type_name,

    -- случайная дата в течение года
    TIMESTAMP '2024-01-01' + (random() * INTERVAL '365 days'),

    -- текст причины
    'Событие типа ' || et.event_type_name || ' №' || seq,

    -- id типа события
    et.event_type_id
FROM dict.event_type et
JOIN generate_series(1, 200) AS seq ON true;

SELECT event_type_id, COUNT(*) AS cnt
FROM oper.well_state_event
GROUP BY event_type_id
ORDER BY event_type_id;


--индекс hash
CREATE INDEX well_state_event_event_type_idx
ON oper.well_state_event
USING hash (event_type_id);

--проверка (просмотрим типы событий)
SELECT event_type_id, event_type_name
FROM dict.event_type;

-- выбрали в ремонте
SELECT *
FROM oper.well_state_event
WHERE event_type_id = 1;


-- индекс gin
CREATE INDEX repair_equipment_usage_description_idx
ON oper.repair_equipment_usage
USING gin (to_tsvector('russian', usage_description));


UPDATE oper.repair_equipment_usage u
SET usage_description =
    'Использование оборудования: ' || e.equipment_name ||
    ' при ремонте #' || u.repair_id
FROM dict.equipment e
WHERE e.equipment_id = u.equipment_id;

SELECT
    usage_id,
    repair_id,
    equipment_id,
    usage_description
FROM oper.repair_equipment_usage
WHERE to_tsvector('russian', usage_description)
      @@ to_tsquery('russian', 'насос');

--обновление таблицы с использование оборудования
TRUNCATE TABLE oper.repair_equipment_usage
RESTART IDENTITY;

INSERT INTO oper.repair_equipment_usage (
    repair_id,
    equipment_id,
    usage_description
)
SELECT
    -- случайный ремонт
    (SELECT repair_id
     FROM oper.well_repair
     ORDER BY random()
     LIMIT 1) AS repair_id,

    -- оборудование 1..5 по кругу
    ((seq - 1) % 5) + 1 AS equipment_id,

    'Использование оборудования #' || seq AS usage_description
FROM generate_series(1, 6000) AS seq;


UPDATE oper.repair_equipment_usage u
SET usage_description =
    'Использование оборудования: ' || e.equipment_name ||
    ' при ремонте #' || u.repair_id
FROM dict.equipment e
WHERE e.equipment_id = u.equipment_id;

SELECT equipment_id, COUNT(*) AS cnt
FROM oper.repair_equipment_usage
GROUP BY equipment_id
ORDER BY equipment_id;

--проверка Gin
SELECT *
FROM oper.repair_equipment_usage
WHERE to_tsvector('russian', usage_description)
      @@ plainto_tsquery('russian', 'насос');

SELECT *
FROM oper.repair_equipment_usage
WHERE to_tsvector('russian', usage_description)
      @@ plainto_tsquery('russian', 'пакер');

SELECT *
FROM oper.repair_equipment_usage
WHERE to_tsvector('russian', usage_description)
      @@ plainto_tsquery('russian', 'сваб');


-- Некоррелирующий подзапрос (НЕ зависящий от внешнего запроса)
SELECT 
    w.well_id,
    w.well_name,
    COUNT(r.repair_id) AS repairs_count
FROM oper.well w
LEFT JOIN oper.well_repair r ON r.well_id = w.well_id
GROUP BY w.well_id, w.well_name
HAVING COUNT(r.repair_id) <
(
    SELECT AVG(repairs_per_well)
    FROM (
        SELECT COUNT(*) AS repairs_per_well
        FROM oper.well_repair
        GROUP BY well_id
    ) x
);


-- коррелирующий подзапрос (Для каждой скважины посчитать количество ремонтов с помощью подзапроса, который ССЫЛАЕТСЯ на эту же скважину.)
SELECT
    w.well_id,
    w.well_name,
    (
        SELECT COUNT(*)
        FROM oper.well_repair r
        WHERE r.well_id = w.well_id
    ) AS repairs_count
FROM oper.well w
ORDER BY w.well_id;


--функция

CREATE OR REPLACE FUNCTION oper.calc_repair_duration(p_repair_id INT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_start_date DATE;
    v_end_date   DATE;
BEGIN
    -- Получаем даты начала и окончания ремонта
    SELECT actual_start_date, actual_end_date
    INTO v_start_date, v_end_date
    FROM oper.well_repair
    WHERE repair_id = p_repair_id;

    -- Если ремонт ещё не завершён → нет длительности
    IF v_end_date IS NULL THEN
        RETURN NULL;
    END IF;

    -- Если даты перепутаны (окончание раньше начала) → ошибка данных
    IF v_end_date < v_start_date THEN
        RETURN NULL;
    END IF;

    -- Возвращаем длительность ремонта в днях
    RETURN v_end_date - v_start_date;
END;
$$;

-- проверка функции



