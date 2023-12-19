-- 在 sql_invoicing 库 invoices 表中，找出高于每位顾客平均发票金额的发票

USE sql_invoicing;

SELECT * 
FROM invoices i
WHERE invoice_total > (
	SELECT AVG(invoice_total)
    FROM invoices
    WHERE client_id = i.client_id
);