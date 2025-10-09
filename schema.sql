CREATE TABLE customers
(
    customer_id SERIAL PRIMARY KEY,
    name        VARCHAR NOT NULL,
    email       VARCHAR
);

CREATE TABLE products
(
    product_id SERIAL PRIMARY KEY,
    name       VARCHAR NOT NULL,
    price      NUMERIC(10, 2) NOT NULL
);

CREATE TABLE orders
(
    order_id    BIGSERIAL,
    customer_id INTEGER                     NOT NULL,
    product_id  INTEGER                     NOT NULL,
    created_at  TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    quantity    INTEGER                     NOT NULL,
    amount      NUMERIC(10, 2),
    status      TEXT,
    PRIMARY KEY (order_id, created_at)
) PARTITION BY RANGE (created_at);

ALTER TABLE orders
    ADD CONSTRAINT chk_order_status
        CHECK (status IN ('NEW', 'PROCESSING', 'COMPLETED', 'CANCELLED'));

CREATE TABLE orders_2024 PARTITION OF orders
    FOR VALUES FROM ('2024-01-01 00:00:00') TO ('2025-01-01 00:00:00');

CREATE TABLE orders_2025_01 PARTITION OF orders
    FOR VALUES FROM ('2025-01-01 00:00:00') TO ('2025-02-01 00:00:00');

CREATE TABLE orders_2025_02 PARTITION OF orders
    FOR VALUES FROM ('2025-02-01 00:00:00') TO ('2025-03-01 00:00:00');

CREATE TABLE orders_2025_03 PARTITION OF orders
    FOR VALUES FROM ('2025-03-01 00:00:00') TO ('2025-04-01 00:00:00');

CREATE TABLE orders_default PARTITION OF orders DEFAULT;

CREATE TABLE orders_audit
(
    audit_id   SERIAL PRIMARY KEY,
    order_id   BIGINT,
    old_amount NUMERIC(10, 2),
    new_amount NUMERIC(10, 2),
    changed_at TIMESTAMP DEFAULT now()
);

CREATE OR REPLACE FUNCTION log_order_change()
    RETURNS TRIGGER AS
$$
BEGIN
    IF OLD.amount IS DISTINCT FROM NEW.amount THEN
        INSERT INTO orders_audit (order_id, old_amount, new_amount)
        VALUES (OLD.order_id, OLD.amount, NEW.amount);
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER orders_audit_trg
    AFTER UPDATE
    ON orders
    FOR EACH ROW
    EXECUTE PROCEDURE log_order_change();


CREATE INDEX idx_orders_created_at ON orders (created_at);

CREATE INDEX idx_orders_customer_id ON orders (customer_id);

CREATE INDEX idx_orders_product_id ON orders (product_id);