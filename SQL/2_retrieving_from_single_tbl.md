# 二. 单表检索 - Retrieving Data From a Single Table

- [二. 单表检索 - Retrieving Data From a Single Table](#二-单表检索---retrieving-data-from-a-single-table)
  - [2.1. SELECT, WHERE, AND, OR, NOT 用法](#21-select-where-and-or-not-用法)
  - [2.2. IN, BETWEEN 运算符](#22-in-between-运算符)
  - [2.3. LIKE 运算符](#23-like-运算符)
  - [2.4. REGEXP 运算符 (Regular Expression 正则表达式）](#24-regexp-运算符-regular-expression-正则表达式)
  - [2.5. IS NULL, ORDER BY, LIMIT 运算符](#25-is-null-order-by-limit-运算符)

**原数据：**

![](assets/2023-12-12-23-35-05.png)

> sql_store 为一个database，其中存在多张表。

## 2.1. SELECT, WHERE, AND, OR, NOT 用法

```SQL
USE sql_store;

SELECT *
FROM customers
WHERE birth_date > '1990-01-01' OR 
      points > 1000 AND state = 'VA'
-- WHERE NOT (birth_date > '1990-01-01' OR 
--       points > 1000 AND state = 'VA')
```
> AND 优先级高于 OR（无括号情况）

## 2.2. IN, BETWEEN 运算符

```sql
USE sql_store;

select * from products
where quantity_in_stock in (38, 49, 72)
-- where quantity_in_stock between 30 and 80
```
> BETWEEN 为必区间，包含两端点
> 也可用于日期，日期本质也是数值，可比较运算

## 2.3. LIKE 运算符

- 模糊查找，查找具有某种模式的字符串的记录/行
  
```SQL
SELECT *
FROM customers
-- WHERE last_name LIKE 'b%'  -- name start with B
-- WHERE last_name LIKE '%b%'  -- name contain B
WHERE last_name LIKE '_____y'  -- sixth character is y

-- % any number of character
-- _ single character
```
> 本质是 boolean，可用 NOT 取反


## 2.4. REGEXP 运算符 (Regular Expression 正则表达式）

- 在搜索字符串方面更为强大，可搜索更复杂的模板

|符号|意义|
|:---:|:---:|
|^|开头|
|$|结尾|
[abc]|含abc|
|[a-c]|含a到c|
|\||logical or|

```SQL
USE sql_store;

SELECT *
FROM customers

-- contain field:
-- WHERE last_name REGEXP 'field'

-- ^ beginning
-- $ end
-- | or
-- WHERE last_name REGEXP '^field'
-- WHERE last_name REGEXP 'field$'
-- WHERE last_name REGEXP 'field|mac'

-- either end with field, or contain mac or rose:
-- WHERE last_name REGEXP 'field$|mac|rose'

-- before e either have g or i or m:
-- WHERE last_name REGEXP '[gim]e'
-- before e have one of: abcdefgh:
WHERE last_name REGEXP '[a-h]e'
```

## 2.5. IS NULL, ORDER BY, LIMIT 运算符

```SQL
select .. from .. where .. is null

select .. from .. order by colA DESC, colB DESC

select .. from .. limit 3;  -- return only first 3
select .. from .. limit 6, 3;  -- offset 6: return 7th - 9th
```
