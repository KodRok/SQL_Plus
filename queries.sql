SELECT COUNT(*) FROM sql_plus_project.orders;

SELECT * FROM sql_plus_project.orders 
	WHERE created_at >= '2025-01-01' AND created_at < '2025-02-01';

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM sql_plus_project.orders 
	WHERE created_at >= '2025-01-01' AND created_at < '2025-02-01';

SELECT o.order_id, c.name, p.name, o.amount
FROM sql_plus_project.orders o
	JOIN sql_plus_project.customers c ON o.customer_id = c.customer_id
	JOIN sql_plus_project.products p ON o.product_id = p.product_id
	WHERE o.created_at BETWEEN '2025-01-01' AND '2025-01-31';

EXPLAIN (ANALYZE, BUFFERS)
SELECT o.order_id, c.name, p.name, o.amount
	FROM sql_plus_project.orders o
	JOIN sql_plus_project.customers c ON o.customer_id = c.customer_id
	JOIN sql_plus_project.products p ON o.product_id = p.product_id
	WHERE o.created_at BETWEEN '2025-01-01' AND '2025-01-31';
	

CREATE INDEX idx_orders_created_at ON sql_plus_project.orders (created_at);

CREATE INDEX idx_orders_customer_id ON sql_plus_project.orders (customer_id);

CREATE INDEX idx_orders_product_id ON sql_plus_project.orders (product_id);

VACUUM ANALYZE sql_plus_project.orders;


EXPLAIN (ANALYZE, BUFFERS)
SELECT o.order_id, c.name, p.name, o.amount
FROM sql_plus_project.orders o
	JOIN sql_plus_project.customers c ON o.customer_id = c.customer_id
	JOIN sql_plus_project.products p ON o.product_id = p.product_id
	WHERE o.created_at BETWEEN '2025-01-01 00:00:00' AND '2025-01-01 23:59:59';


SELECT o.order_id, c.name, p.name, o.amount
FROM sql_plus_project.orders o
	JOIN sql_plus_project.customers c ON o.customer_id = c.customer_id
	JOIN sql_plus_project.products p ON o.product_id = p.product_id
	WHERE o.created_at BETWEEN '2025-01-01 00:00:00' AND '2025-01-01 23:59:59';