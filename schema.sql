CREATE TABLE sql_plus_project.customers (
    customer_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT
);

CREATE TABLE sql_plus_project.products (
    product_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    price NUMERIC(10, 2) NOT NULL
);

CREATE TABLE sql_plus_project.orders (
    order_id BIGSERIAL,
    customer_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    quantity INTEGER NOT NULL, -- Добавлено для согласования с генератором
    amount NUMERIC(10, 2),
    status TEXT,
    PRIMARY KEY (order_id, created_at)
) PARTITION BY RANGE (created_at);

CREATE TABLE sql_plus_project.orders_2024 PARTITION OF sql_plus_project.orders
    FOR VALUES FROM ('2024-01-01 00:00:00') TO ('2025-01-01 00:00:00');

CREATE TABLE sql_plus_project.orders_2025_01 PARTITION OF sql_plus_project.orders
    FOR VALUES FROM ('2025-01-01 00:00:00') TO ('2025-02-01 00:00:00');

CREATE TABLE sql_plus_project.orders_2025_02 PARTITION OF sql_plus_project.orders
    FOR VALUES FROM ('2025-02-01 00:00:00') TO ('2025-03-01 00:00:00');

CREATE TABLE sql_plus_project.orders_2025_03 PARTITION OF sql_plus_project.orders
    FOR VALUES FROM ('2025-03-01 00:00:00') TO ('2025-04-01 00:00:00');

CREATE TABLE sql_plus_project.orders_default PARTITION OF sql_plus_project.orders DEFAULT;

CREATE TABLE sql_plus_project.orders_audit (
    audit_id SERIAL PRIMARY KEY,
    order_id INT,
    old_amount NUMERIC(10,2),
    new_amount NUMERIC(10,2),
    changed_at TIMESTAMP DEFAULT now()
);

CREATE OR REPLACE FUNCTION log_order_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.amount IS DISTINCT FROM NEW.amount THEN
        INSERT INTO sql_plus_project.orders_audit (order_id, old_amount, new_amount)
        VALUES (OLD.order_id, OLD.amount, NEW.amount);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER orders_audit_trg
AFTER UPDATE ON sql_plus_project.orders
FOR EACH ROW
EXECUTE PROCEDURE log_order_change();
