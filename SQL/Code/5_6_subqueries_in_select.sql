-- 得到一个有如下列的表格：client_id, name, total_sales（各个客户的发票总额）, 
-- average（总平均发票额）, difference（前两个值的差）

USE sql_invoicing;

SELECT 
	client_id,
    name,
    (SELECT SUM(invoice_total) FROM invoices i WHERE i.client_id = c.client_id) AS total_sales,
    (SELECT AVG(invoice_total) FROM invoices) AS average,
    (SELECT average - total_sales) AS difference
FROM clients c;