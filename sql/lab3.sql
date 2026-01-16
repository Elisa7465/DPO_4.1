--Задача 3.1

CREATE TABLE order_history (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    field_name VARCHAR(50) NOT NULL,
    old_value INTEGER,
    new_value INTEGER NOT NULL
);

INSERT INTO order_history(order_id, created_at, field_name, old_value, new_value) VALUES
 (101,'2025-10-01 09:00+03','status_id',NULL,'10'),
 (101,'2025-10-01 09:05+03','manager_id',NULL,'7'),
 (101,'2025-10-01 09:30+03','total_sum',NULL,'129.90'),
 (101,'2025-10-01 10:00+03','status_id','10','20'),
 (101,'2025-10-01 15:00+03','status_id','20','30'),
 (101,'2025-10-02 12:00+03','status_id','30','40');

INSERT INTO order_history(order_id, created_at, field_name, old_value, new_value) VALUES
 (102,'2025-10-03 11:10+03','status_id',NULL,'10'),
 (102,'2025-10-03 11:12+03','total_sum',NULL,'59.00'),
 (102,'2025-10-03 11:20+03','status_id','10','20'),
 (102,'2025-10-03 13:45+03','status_id','20','50');

INSERT INTO order_history(order_id, created_at, field_name, old_value, new_value) VALUES
 (103,'2025-10-05 08:00+03','status_id',NULL,'10'),
 (103,'2025-10-05 08:10+03','manager_id',NULL,'9'),
 (103,'2025-10-05 09:00+03','status_id','10','20'),
 (103,'2025-10-06 18:30+03','status_id','20','30'),
 (103,'2025-10-08 10:15+03','status_id','30','40');

INSERT INTO order_history(order_id, created_at, field_name, old_value, new_value) VALUES
 (104,'2025-10-10 10:00+03','status_id',NULL,'10'),
 (104,'2025-10-10 10:30+03','status_id','10','20'),
 (104,'2025-10-11 09:00+03','status_id','20','30');


CREATE TABLE dict_status(id INT PRIMARY KEY, name TEXT NOT NULL);
INSERT INTO dict_status(id,name) VALUES
 (10,'new'),(20,'processing'),(30,'shipped'),(40,'delivered'),(50,'cancelled');

--Статус заказа | Среднее время пребывания заказа в этом статусе
WITH status_changes AS (
  SELECT 
    order_id,
    created_at,
    new_value AS status_id,
    COALESCE(
      LEAD(created_at) OVER (PARTITION BY order_id ORDER BY created_at),
      '2025-10-09 12:00'
    ) AS next_status_time
  FROM order_history
  WHERE field_name = 'status_id'
),
status_durations AS (
  SELECT 
    status_id,
    next_status_time - created_at AS duration
  FROM status_changes
)
SELECT 
  ds.name AS status_name,
  AVG(sd.duration) AS average_duration
FROM status_durations sd
JOIN dict_status ds ON sd.status_id = ds.id
GROUP BY ds.name
ORDER BY ds.name;



--- ЗАДАНИЕ 3.2 ---

-- 1) Визиты
CREATE TABLE customer_visit (
  id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  customer_id   BIGINT NOT NULL,
  created_at    TIMESTAMP NOT NULL,
  visit_length  INT NOT NULL CHECK (visit_length >= 0),
  landing_page  VARCHAR(500) NOT NULL,
  exit_page     VARCHAR(500) NOT NULL,
  utm_source    VARCHAR(200)
);

-- 2) Страницы визита
CREATE TABLE customer_visit_page (
  id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  visit_id     BIGINT NOT NULL REFERENCES customer_visit(id) ON DELETE CASCADE,
  page         VARCHAR(500) NOT NULL,
  time_on_page INT NOT NULL CHECK (time_on_page >= 0)
);



INSERT INTO customer_visit (customer_id, created_at, visit_length, landing_page, exit_page, utm_source) VALUES
(101, '2025-12-01 10:00:00', 300, '/home',        '/catalog',    'google'),
(101, '2025-12-10 18:20:00', 900, '/landing/a',   '/checkout',   'yandex'),
(202, '2025-12-05 12:00:00', 600, '/home',        '/pricing',    'email'),
(303, '2025-12-02 09:10:00', 120, '/blog/1',      '/blog/1',     'organic'),
(303, '2025-12-08 14:30:00', 240, '/catalog',     '/catalog/2',  'google'),
(303, '2025-12-12 20:00:00', 780, '/landing/b',   '/thanks',     'vk');

-- Страницы привяжем к визитам через подзапросы по (customer_id, created_at)
INSERT INTO customer_visit_page (visit_id, page, time_on_page) VALUES
((SELECT id FROM customer_visit WHERE customer_id=101 AND created_at='2025-12-01 10:00:00'), '/home',       120),
((SELECT id FROM customer_visit WHERE customer_id=101 AND created_at='2025-12-01 10:00:00'), '/catalog',    180),

((SELECT id FROM customer_visit WHERE customer_id=101 AND created_at='2025-12-10 18:20:00'), '/landing/a',  200),
((SELECT id FROM customer_visit WHERE customer_id=101 AND created_at='2025-12-10 18:20:00'), '/catalog',    250),
((SELECT id FROM customer_visit WHERE customer_id=101 AND created_at='2025-12-10 18:20:00'), '/cart',       150),
((SELECT id FROM customer_visit WHERE customer_id=101 AND created_at='2025-12-10 18:20:00'), '/checkout',   300),

((SELECT id FROM customer_visit WHERE customer_id=202 AND created_at='2025-12-05 12:00:00'), '/home',       200),
((SELECT id FROM customer_visit WHERE customer_id=202 AND created_at='2025-12-05 12:00:00'), '/pricing',    400),

((SELECT id FROM customer_visit WHERE customer_id=303 AND created_at='2025-12-02 09:10:00'), '/blog/1',     120),

((SELECT id FROM customer_visit WHERE customer_id=303 AND created_at='2025-12-08 14:30:00'), '/catalog',    140),
((SELECT id FROM customer_visit WHERE customer_id=303 AND created_at='2025-12-08 14:30:00'), '/catalog/2',  100),

((SELECT id FROM customer_visit WHERE customer_id=303 AND created_at='2025-12-12 20:00:00'), '/landing/b',  180),
((SELECT id FROM customer_visit WHERE customer_id=303 AND created_at='2025-12-12 20:00:00'), '/catalog',    200),
((SELECT id FROM customer_visit WHERE customer_id=303 AND created_at='2025-12-12 20:00:00'), '/checkout',   200),
((SELECT id FROM customer_visit WHERE customer_id=303 AND created_at='2025-12-12 20:00:00'), '/thanks',     200);



--ID клиента | Дата последнего визита
SELECT
  customer_id AS "ID клиента",
  MAX(created_at) AS "Дата последнего визита"
FROM customer_visit
GROUP BY customer_id;


--ID клиента | Среднее количество просмотров страниц за визит

WITH per_visit AS (
  SELECT
    v.id AS visit_id,
    v.customer_id,
    COUNT(p.id) AS pageviews
  FROM customer_visit v
  LEFT JOIN customer_visit_page p ON p.visit_id = v.id
  GROUP BY v.id, v.customer_id
)
SELECT
  customer_id AS "ID клиента",
  AVG(pageviews) AS "Среднее просмотров страниц за визит"
FROM per_visit
GROUP BY customer_id;

--ID клиента | Адреса страниц с визитами дольше среднего времени визита этого клиента
WITH avg_len AS (
  SELECT customer_id, AVG(visit_length) AS avg_visit_length
  FROM customer_visit
  GROUP BY customer_id
)
SELECT DISTINCT
  v.customer_id AS "ID клиента",
  p.page AS "Адрес страницы"
FROM customer_visit v
JOIN avg_len a ON a.customer_id = v.customer_id
JOIN customer_visit_page p ON p.visit_id = v.id
WHERE v.visit_length > a.avg_visit_length;



--- ЗАДАНИЕ 3.3 ---
CREATE TABLE customer (
  id         BIGINT PRIMARY KEY,
  created_at TIMESTAMP NOT NULL,
  first_name TEXT NOT NULL,
  last_name  TEXT NOT NULL,
  phone      TEXT,
  email      TEXT
);

CREATE TABLE customer_visit (
  id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  customer_id   BIGINT NOT NULL REFERENCES customer(id) ON DELETE CASCADE,
  created_at    TIMESTAMP NOT NULL,
  visit_length  INT NOT NULL CHECK (visit_length >= 0),
  landing_page  VARCHAR(500) NOT NULL,
  exit_page     VARCHAR(500) NOT NULL,
  utm_source    VARCHAR(200)
);

CREATE TABLE customer_visit_page (
  id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  visit_id     BIGINT NOT NULL REFERENCES customer_visit(id) ON DELETE CASCADE,
  page         VARCHAR(500) NOT NULL,
  time_on_page INT NOT NULL CHECK (time_on_page >= 0)
);

-- Статусы заказов
CREATE TABLE order_status (
  id   INT PRIMARY KEY,
  name TEXT NOT NULL UNIQUE
);

-- Заказы
CREATE TABLE "order" (
  id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  created_at  TIMESTAMP NOT NULL,
  customer_id BIGINT NOT NULL REFERENCES customer(id) ON DELETE CASCADE,
  manager_id  BIGINT NOT NULL,
  status_id   INT NOT NULL REFERENCES order_status(id),
  is_paid     BOOLEAN NOT NULL DEFAULT FALSE,
  total_sum   NUMERIC(12,2) NOT NULL CHECK (total_sum >= 0),
  utm_source  VARCHAR(200),
  closed_at   TIMESTAMP NULL  -- для расчёта времени выполнения/отмены
);


-- 1) ID клиента | Среднее время между заказами
WITH t AS (
  SELECT
    customer_id,
    created_at,
    --находит дату предыдущего заказа
    LAG(created_at) OVER (PARTITION BY customer_id ORDER BY created_at) AS prev_created_at
  FROM "order"
)
SELECT
  customer_id AS "ID клиента",
  AVG(created_at - prev_created_at) AS "Среднее время между заказами"
FROM t
WHERE prev_created_at IS NOT NULL
GROUP BY customer_id
ORDER BY customer_id;


-- 2) ID клиента | Количество визитов | Количество заказов
SELECT
  c.id AS "ID клиента",
  COALESCE(v.visit_cnt, 0) AS "Количество визитов",
  COALESCE(o.order_cnt, 0) AS "Количество заказов"
FROM customer c
LEFT JOIN (
  SELECT customer_id, COUNT(*) AS visit_cnt
  FROM customer_visit
  GROUP BY customer_id
) v ON v.customer_id = c.id
LEFT JOIN (
  SELECT customer_id, COUNT(*) AS order_cnt
  FROM "order"
  GROUP BY customer_id
) o ON o.customer_id = c.id
ORDER BY c.id;


-- 3) Источник | визиты | созданные заказы | оплаченные | выполненные
WITH v AS (
  SELECT utm_source, COUNT(*) AS visit_cnt
  FROM customer_visit
  GROUP BY utm_source
),
o AS (
  SELECT
    utm_source,
    COUNT(*) AS order_cnt,
    SUM(CASE WHEN is_paid THEN 1 ELSE 0 END) AS paid_cnt,
    SUM(CASE WHEN status_id = 2 THEN 1 ELSE 0 END) AS done_cnt
  FROM "order"
  GROUP BY utm_source
)
SELECT
  COALESCE(v.utm_source, o.utm_source) AS "Источник трафика",
  COALESCE(v.visit_cnt, 0)             AS "Количество визитов",
  COALESCE(o.order_cnt, 0)             AS "Количество созданных заказов",
  COALESCE(o.paid_cnt, 0)              AS "Количество оплаченных заказов",
  COALESCE(o.done_cnt, 0)              AS "Количество выполненных заказов"
FROM v
FULL OUTER JOIN o USING (utm_source)
ORDER BY 1;

-- 4) ID менеджера | Среднее время выполнения | Доля отмененных | Сумма выполненных | Средняя стоимость
SELECT
  manager_id AS "ID менеджера",
  AVG(closed_at - created_at) FILTER (WHERE status_id = 2 AND closed_at IS NOT NULL)
    AS "Среднее время выполнения заказов",
  (SUM(CASE WHEN status_id = 3 THEN 1 ELSE 0 END)::numeric / COUNT(*))
    AS "Доля отмененных заказов",
  SUM(total_sum) FILTER (WHERE status_id = 2)
    AS "Сумма выполненных заказов",
  AVG(total_sum)
    AS "Средняя стоимость заказа"
FROM "order"
GROUP BY manager_id
ORDER BY manager_id;


-- 5) ID менеджера | Рейтинг менеджера
WITH overall AS (
  SELECT
    (SUM(CASE WHEN status_id = 2 THEN 1 ELSE 0 END)::numeric / COUNT(*)) AS done_share_all,
    AVG(EXTRACT(EPOCH FROM (closed_at - created_at))) FILTER (WHERE status_id = 2 AND closed_at IS NOT NULL) AS avg_done_sec_all,
    (SUM(CASE WHEN status_id = 3 THEN 1 ELSE 0 END)::numeric / COUNT(*)) AS cancel_share_all
  FROM "order"
),
per_manager AS (
  SELECT
    manager_id,
    (SUM(CASE WHEN status_id = 2 THEN 1 ELSE 0 END)::numeric / COUNT(*)) AS done_share_m,
    AVG(EXTRACT(EPOCH FROM (closed_at - created_at))) FILTER (WHERE status_id = 2 AND closed_at IS NOT NULL) AS avg_done_sec_m,
    (SUM(CASE WHEN status_id = 3 THEN 1 ELSE 0 END)::numeric / COUNT(*)) AS cancel_share_m
  FROM "order"
  GROUP BY manager_id
)
SELECT
  p.manager_id AS "ID менеджера",
  (
    (p.done_share_m - o.done_share_all)
    + (COALESCE(p.avg_done_sec_m, o.avg_done_sec_all) - o.avg_done_sec_all)
    - (p.cancel_share_m - o.cancel_share_all)
  ) AS "Рейтинг менеджера"
FROM per_manager p
CROSS JOIN overall o
ORDER BY "Рейтинг менеджера" DESC;