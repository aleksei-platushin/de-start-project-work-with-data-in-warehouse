-- 1. Создание таблицы логов для инкрементальной загрузки витрины
DROP TABLE IF EXISTS dwh.load_dates_customer_report_datamart;
CREATE TABLE dwh.load_dates_customer_report_datamart (
    id BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    load_dttm TIMESTAMP NOT NULL,
    CONSTRAINT pk_load_dates_customer_report_datamart PRIMARY KEY (id)
);
COMMENT ON TABLE dwh.load_dates_customer_report_datamart IS 'Техническая таблица для хранения дат загрузки инкрементальной витрины по заказчикам';

-- 2. Создание инкрементальной витрины по заказчикам
DROP TABLE IF EXISTS dwh.customer_report_datamart;
CREATE TABLE dwh.customer_report_datamart (
    id BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    customer_id BIGINT NOT NULL,
    customer_name VARCHAR NOT NULL,
    customer_address VARCHAR NOT NULL,
    customer_birthday DATE NOT NULL,
    customer_email VARCHAR NOT NULL,
    customer_money NUMERIC(15, 2) NOT NULL,
    platform_money NUMERIC(15, 2) NOT NULL,
    count_order BIGINT NOT NULL,
    avg_price_order NUMERIC(10, 2) NOT NULL,
    median_time_order_completed NUMERIC(10, 1),
    top_product_category VARCHAR NOT NULL,
    top_craftsman_id BIGINT NOT NULL,
    count_order_created BIGINT NOT NULL,
    count_order_in_progress BIGINT NOT NULL,
    count_order_delivery BIGINT NOT NULL,
    count_order_done BIGINT NOT NULL,
    count_order_not_done BIGINT NOT NULL,
    report_period VARCHAR NOT NULL,
    CONSTRAINT pk_customer_report_datamart PRIMARY KEY (id)
);

-- 3. Добавление комментариев к полям витрины
COMMENT ON TABLE dwh.customer_report_datamart IS 'Инкрементальная витрина с ежемесячным отчётом по заказчикам маркетплейса';
COMMENT ON COLUMN dwh.customer_report_datamart.id IS 'Идентификатор записи (PK)';
COMMENT ON COLUMN dwh.customer_report_datamart.customer_id IS 'Идентификатор заказчика';
COMMENT ON COLUMN dwh.customer_report_datamart.customer_name IS 'Ф. И. О. заказчика';
COMMENT ON COLUMN dwh.customer_report_datamart.customer_address IS 'Адрес заказчика';
COMMENT ON COLUMN dwh.customer_report_datamart.customer_birthday IS 'Дата рождения заказчика';
COMMENT ON COLUMN dwh.customer_report_datamart.customer_email IS 'Электронная почта заказчика';
COMMENT ON COLUMN dwh.customer_report_datamart.customer_money IS 'Сумма, которую потратил заказчик';
COMMENT ON COLUMN dwh.customer_report_datamart.platform_money IS 'Сумма, которую заработала платформа от покупок заказчика за месяц (10%)';
COMMENT ON COLUMN dwh.customer_report_datamart.count_order IS 'Количество заказов у заказчика за месяц';
COMMENT ON COLUMN dwh.customer_report_datamart.avg_price_order IS 'Средняя стоимость одного заказа у заказчика за месяц';
COMMENT ON COLUMN dwh.customer_report_datamart.median_time_order_completed IS 'Медианное время в днях от создания до завершения заказа за месяц';
COMMENT ON COLUMN dwh.customer_report_datamart.top_product_category IS 'Самая популярная категория товаров у заказчика за месяц';
COMMENT ON COLUMN dwh.customer_report_datamart.top_craftsman_id IS 'Идентификатор самого популярного мастера у заказчика за месяц';
COMMENT ON COLUMN dwh.customer_report_datamart.count_order_created IS 'Количество созданных заказов за месяц';
COMMENT ON COLUMN dwh.customer_report_datamart.count_order_in_progress IS 'Количество заказов в процессе изготовления за месяц';
COMMENT ON COLUMN dwh.customer_report_datamart.count_order_delivery IS 'Количество заказов в доставке за месяц';
COMMENT ON COLUMN dwh.customer_report_datamart.count_order_done IS 'Количество завершённых заказов (со статусом done) за месяц';
COMMENT ON COLUMN dwh.customer_report_datamart.count_order_not_done IS 'Количество незавершённых заказов (со статусом != done) за месяц';
COMMENT ON COLUMN dwh.customer_report_datamart.report_period IS 'Отчётный период (формат YYYY-MM)';

-- 4. Инициализация таблицы логов стартовым значением (Техническая доработка)
/* 
  ВАЖНО: Принудительно добавляем «нулевую» точку отсчета в таблицу логов.
  Это необходимо, чтобы при самом первом запуске скрипта обновления витрины 
  подзапрос (SELECT MAX(load_dttm) ...) не возвращал пустой NULL, из-за которого дельта отсекается.
  Значение '1900-01-01' гарантирует, что первый инкрементальный расчет успешно заберет абсолютно все 
  исторические данные, накопленные в хранилище DWH на текущий момент.
*/
INSERT INTO dwh.load_dates_customer_report_datamart (load_dttm)
VALUES ('1900-01-01 00:00:00'::timestamp);
