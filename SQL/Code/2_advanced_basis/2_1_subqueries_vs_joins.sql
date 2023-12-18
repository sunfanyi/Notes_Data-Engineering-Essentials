-- 选出买过生菜（id = 3）的顾客

-- Subqueries:
USE sql_store;

SELECT *
FROM customers
WHERE customer_id IN (
	SELECT DISTINCT customer_id
	FROM orders
    WHERE order_id IN (
		SELECT order_id
        FROM order_items
        WHERE product_id = 3
	)
);


-- JOIN
USE sql_store;

SELECT DISTINCT customers.* 
FROM customers
LEFT JOIN orders 
	USING (customer_id)
LEFT JOIN order_items
	USING (order_id)
WHERE product_id = 3;
