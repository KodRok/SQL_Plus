INSERT INTO sql_plus_project.products (name, price)
SELECT
    'Product_' || generate_series(1, 100),
    (random() * 1000 + 1)::NUMERIC(10, 2);

INSERT INTO sql_plus_project.customers (name, email)
SELECT
    'Customer_' || generate_series(1, 1000),
    'user' || generate_series(1, 1000) || '@example.com';
    
INSERT INTO sql_plus_project.orders (customer_id, product_id, created_at, quantity, amount, status)
SELECT
    (random() * 999 + 1)::INTEGER,
    (random() * 99 + 1)::INTEGER,
    NOW() - (FLOOR(random() * 425) || ' days')::INTERVAL,
    (random() * 9 + 1)::INTEGER,
    (random() * 5000 + 10)::NUMERIC(10, 2),
    CASE WHEN random() < 0.9 THEN 'COMPLETED' ELSE 'NEW' END
FROM generate_series(1, 40000000);