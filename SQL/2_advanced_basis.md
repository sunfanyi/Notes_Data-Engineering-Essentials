# 二. 基础进阶 - 汇总、复杂查询、内置函数 <!-- omit from toc -->

- [1. 汇总数据](#1-汇总数据)
  - [1.1. 聚合函数 Aggregation Functions](#11-聚合函数-aggregation-functions)
  - [1.2. GROUP BY 子句](#12-group-by-子句)
  - [1.3. HAVING 子句](#13-having-子句)
  - [1.4. ROLLUP 运算符](#14-rollup-运算符)
  - [1.5. \*\* SQL 执行顺序](#15--sql-执行顺序)
- [2. 复杂查询](#2-复杂查询)
  - [2.1. 子查询 Subqueries vs JOINS](#21-子查询-subqueries-vs-joins)
  - [2.2. ALL 关键字](#22-all-关键字)
  - [2.3. ANY 关键字](#23-any-关键字)
  - [2.4. 相关子查询 Correlated Subqueries](#24-相关子查询-correlated-subqueries)
  - [2.5. EXISTS 运算符](#25-exists-运算符)
  - [2.6. SELECT 子句的子查询](#26-select-子句的子查询)
  - [2.7. FROM 子句的子查询](#27-from-子句的子查询)
- [3. MySQL的基本函数](#3-mysql的基本函数)
  - [3.1. 数值函数](#31-数值函数)
  - [3.2. 字符串函数](#32-字符串函数)
  - [3.3. 日期函数](#33-日期函数)
  - [3.4. 格式化日期和时间](#34-格式化日期和时间)
  - [3.5. 计算日期和时间](#35-计算日期和时间)
  - [3.6. IFNULL 和 COALESCE 函数](#36-ifnull-和-coalesce-函数)
  - [3.7. IF 函数](#37-if-函数)
  - [3.8. CASE 函数](#38-case-函数)


# 1. 汇总数据
## 1.1. 聚合函数 Aggregation Functions

```SQL
USE sql_invoicing;

SELECT 
    MAX(invoice_date) AS latest_date,  
    -- SELECT选择的不仅可以是列，也可以是数字、列间表达式、列的聚合函数
    MIN(invoice_total) lowest,
    AVG(invoice_total) average,
    SUM(invoice_total * 1.1) total,
    COUNT(*) total_records,
    COUNT(invoice_total) number_of_invoices, 
    -- 和上一个相等
    COUNT(payment_date) number_of_payments,  
    -- 【聚合函数会忽略空值】，得到的支付数少于发票数
    COUNT(DISTINCT client_id) number_of_distinct_clients
    -- DISTINCT client_id 筛掉了该列的重复值，再COUNT计数，会得到不同顾客数
FROM invoices
WHERE invoice_date > '2019-07-01'  -- 想只统计下半年的结果
```

## 1.2. GROUP BY 子句

```SQL
SELECT 
    client_id,  
    SUM(invoice_total) AS total_sales
FROM invoices
WHERE invoice_date >= '2019-07-01'  -- 筛选，过滤器
GROUP BY client_id  -- 分组
ORDER BY invoice_total DESC
```

## 1.3. HAVING 子句

- HAVING 和 WHERE 都是是条件筛选语句，条件的写法相通。
- WHERE 是对原表中的列进行事前筛选，所以WHERE可以对没选择的列进行筛选，但必须用原表列名而不能用SELECT中的别名
- HAVING 对 SELECT 查询后（通常是分组并聚合查询后）的结果列进行事后筛选，筛选选用聚合条件，该聚合条件可以不在 SELECT 中体现。
  - MySQL 允许使用 SELECT 中使用过的聚合条件的别名用为 HAVING 筛选（看下一章的SQL执行顺序）。

**WHERE 例子：**


```SQL
SELECT 
    client_id,
    SUM(invoice_total) AS total_sales,
    COUNT(*) AS number_of_invoices
FROM invoices
GROUP BY client_id
WHERE invoice_total > 10
```

> 展示所有invoice_total大于10的SUM

**HAVING 例子：**

```SQL
SELECT 
    client_id,
    SUM(invoice_total) AS total_sales,
    COUNT(*) AS number_of_invoices
FROM invoices
GROUP BY client_id
HAVING SUM(invoice_total) > 500
-- HAVING total_sales > 500
```

> 展示 SUM 大于500的数据

- 当HAVING筛选的是聚合函数时，该聚合函数可以不在SELECT里显性出现。

```SQL
SELECT state
FROM customers
GROUP BY state
HAVING SUM(points) > 3000
```

## 1.4. ROLLUP 运算符

- GROUP BY …… WITH ROLL UP 自动汇总型分组。
- **MySQL**扩展语法，不是SQL标准语法。
- 在 GROUP BY 的基础上，额外加一行汇总：

```SQL
SELECT 
    client_id,
    SUM(invoice_total)
FROM invoices
GROUP BY client_id WITH ROLLUP
```
<img src="assets/2023-12-13-23-55-30.png" alt="drawing" width="210"/>


## 1.5. ** SQL 执行顺序

**标准的 SQL 查询语句的执行顺序：**

1. FROM JOIN 选择和连接本次查询所需的表
2. ON/USING WHERE 按条件筛选行
3. GROUP BY 分组
4. HAVING （事后/分组后）筛选行
5. SELECT 筛选列
6. DISTINCT 去重
7. UNION 纵向合并
8. ORDER BY 排序
9. LIMIT 限制

"SELECT 是在大部分语句执行了之后才执行的，严格的说是在 FROM、WHERE 和 GROUP BY （以及 HAVING）之后执行的。这就是不能在 WHERE 中使用在 SELECT 中设定别名的字段作为判断条件的原因。"

这个顺序可以由下面这个例子的缩进表现出来（出右往左）：

```SQL
                SELECT name, SUM(invoice_total) AS total_sales
         -- DISTINCT
                                FROM invoices JOIN clients USING (client_id) 
                            WHERE due_date < '2019-07-01'
                        GROUP BY name  
                    HAVING total_sales > 150

        UNION

                SELECT name, SUM(invoice_total) AS total_sales
         -- DISTINCT
                                FROM invoices JOIN clients USING (client_id) 
                            WHERE due_date > '2019-07-01'
                        GROUP BY name  
                    HAVING total_sales > 150

    ORDER BY total_sales
LIMIT 2
```

关于SELECT和HAVING的顺序，文献表示 HAVING 在 SELECT 前，但尚未找到 HAVING 中使用 SELECT 里定义的别名也可以运行的明确解释。如下代码注释部分：

```SQL
SELECT 
    client_id,
    SUM(invoice_total) AS total_sales,
    COUNT(*) AS number_of_invoices
FROM invoices
GROUP BY client_id
HAVING SUM(invoice_total) > 500
-- HAVING total_sales > 500
```

目前 MySQL 和 MaxCompute SQL 中此用法均可行。但貌似其他大部分 SQL 中非法。暂时理解成标准 SQL 非法，前两者做了兼容（如中间生成虚拟表）。

# 2. 复杂查询

## 2.1. 子查询 Subqueries vs JOINS

选出买过生菜（id = 3）的顾客

```SQL
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
```

等效于：

```SQL
SELECT DISTINCT customers.* 
FROM customers
LEFT JOIN orders 
    USING (customer_id)
LEFT JOIN order_items
    USING (order_id)
WHERE product_id = 3;
```

## 2.2. ALL 关键字

- `(MAX (……))` 和 `> ALL(……)` 等效:

```SQL
SELECT *
FROM invoices
WHERE invoice_total > (
    SELECT MAX(invoice_total)
    FROM invoices
    WHERE client_id = 3
)
```

```SQL
SELECT *
FROM invoices
WHERE invoice_total > ALL (
    SELECT invoice_total
    FROM invoices
    WHERE client_id = 3
)
```

## 2.3. ANY 关键字

- `> ANY/SOME (……)` 和 `> (MIN (……))` 等效:

```SQL
SELECT *
FROM invoices

WHERE invoice_total > ANY (
    SELECT invoice_total
    FROM invoices
    WHERE client_id = 3
)

-- equivalent:

WHERE invoice_total > (
    SELECT MIN(invoice_total)
    FROM invoices
    WHERE client_id = 3
)
```

- `= ANY/SOME (……)` 和 `IN (……)` 等效:


```SQL
SELECT *
FROM clients
WHERE client_id IN (  
-- WHERE client_id = ANY ( 
    -- 有2次以上发票记录的顾客
    SELECT client_id
    FROM invoices
    GROUP BY client_id
    HAVING COUNT(*) >= 2
)
```


## 2.4. 相关子查询 Correlated Subqueries

- 之前都是非关联主/子（外/内）查询，这种子查询与主查询无关，会先一次性得出查询结果再返回给主查询供其使用。
- 而下面这种相关联子查询例子里，子查询是依赖主查询的，注意这种关联查询是在主查询的每一行/每一条记录层面上依次进行的，相关子查询会比非关联查询执行起来**慢**。

找出高于每位顾客平均发票金额的发票：

```SQL
USE sql_invoicing;

SELECT * 
FROM invoices i
WHERE invoice_total > (
    SELECT AVG(invoice_total)
    FROM invoices
    WHERE client_id = i.client_id
    -- 可以理解成对每一个 i.client_id 进行 Implicit JOIN 后的 AVG
);
```

## 2.5. EXISTS 运算符

- `IN + 子查询` 等效于 `EXIST + 相关子查询`。
- 如果前者子查询的结果集过大占用内存，用后者逐条验证**更有效率**。
-  EXIST() 本质上是根据是否为空返回 TRUE 和 FALSE，所以也可以加 NOT 取反。

找出有过发票记录的客户

```SQL
SELECT *
FROM clients
WHERE client_id IN (
    SELECT DISTINCT client_id
    FROM invoices
)
```

等效于

```SQL
SELECT *
FROM clients c
WHERE EXISTS (
    SELECT */client_id  
    /* 就这个子查询的目的来说，SELECT的选择不影响结果，
    因为EXISTS()函数只根据是否为空返回 TRUE 和 FALSE */
    FROM invoices
    WHERE client_id = c.client_id
)
```

> 理解成 client_id = c.client_id 的 boolean array


## 2.6. SELECT 子句的子查询

得到一个有如下列的表格：invoice_id, invoice_total, avarege（总平均发票额）, difference（前两个值的差）：

```SQL
SELECT 
    invoice_id,
    invoice_total,
    (SELECT AVG(invoice_total) FROM invoices) AS invoice_average,  -- 见知识点1
    -- 不能直接用聚合函数，因为“比较强势”，会压缩聚合结果为一条;
    -- 用括号+子查询(SELECT AVG(invoice_total) FROM invoices) 将其作为一个数值结果加入主查询语句
    invoice_total - (SELECT invoice_average) AS difference  -- 见知识点2
    -- SELECT表达式里要用原列名，不能直接用别名invoice_average
FROM invoices
```

- 知识点1：直接用 AVG(invoice_total) AS invoice_average 会报错，因为AVG(invoice_total) 是一个聚合函数，而在SELECT子句中使用聚合函数时，它会被解释为一个单一的值，而不是一个可以在同一级别直接引用的别名。
- 为了解决这个问题，可以使用子查询将聚合函数的结果作为一个单一的值嵌套在主查询中。
- 尝试单独运行：

```SQL
SELECT AVG(invoice_total) FROM invoices;
```

结果：
![](assets/2023-12-18-22-27-01.png)

- 知识点2：invoice_total - invoice_average AS difference 会报错，在同一级别无法直接引用其他别名。
- 解决方法是使用子查询，将invoice_average 作为一个子查询中的别名，然后在主查询中引用它。


得到一个有如下列的表格：client_id, name, total_sales（各个客户的发票总额）, average（总平均发票额）, difference（前两个值的差）：

```SQL
SELECT 
    client_id,
    name,
    (SELECT SUM(invoice_total) FROM invoices i WHERE i.client_id = c.client_id) AS total_sales,
    -- 可以理解成对每一个c.client_id, 进行和invoices 的Implicit JOIN
    (SELECT AVG(invoice_total) FROM invoices) AS average,
    (SELECT average - total_sales) AS difference
FROM clients c;
```



## 2.7. FROM 子句的子查询

将上一节练习里的查询结果当作来源表，查询其中 total_sales 非空的记录

```SQL
SELECT * 
FROM (
    SELECT 
        client_id,
        name,
        (SELECT SUM(invoice_total) FROM invoices i WHERE i.client_id = c.client_id) AS total_sales,
        -- 可以理解成对每一个c.client_id, 进行和invoices 的Implicit JOIN
        (SELECT AVG(invoice_total) FROM invoices) AS average,
        (SELECT average - total_sales) AS difference
    FROM clients c
) AS sales_summury
WHERE total_sales IS NOT NULL
```

> - 在FROM中使用子查询，即使用 “派生表” 时，必须给派生表取个别名（不管用不用），这是硬性要求，不写会报错：
> - Error Code: 1248. Every derived table（派生表、导出表）must have its own alias


# 3. MySQL的基本函数

## 3.1. 数值函数

```SQL
SELECT ROUND(5.7365, 2)  -- 四舍五入
SELECT TRUNCATE(5.7365, 2)  -- 截断
SELECT CEILING(5.2)  -- 天花板函数，大于等于此数的最小整数
SELECT FLOOR(5.6)  -- 地板函数，小于等于此数的最大整数
SELECT ABS(-5.2)  -- 绝对值
SELECT RAND()  -- 随机函数，0到1的随机值
```

## 3.2. 字符串函数

长度、转大小写：

```SQL
SELECT LENGTH('sky')  -- 字符串字符个数/长度（LENGTH）
SELECT UPPER('sky')  -- 转大写
SELECT LOWER('Sky')  -- 转小写
```

用户输入时时常多打空格，下面三个函数用于处理/修剪（trim）字符串前后的空格，L、R 表示 LEFT、RIGHT：

```SQL
SELECT LTRIM('  Sky')
SELECT RTRIM('Sky  ')
SELECT TRIM(' Sky ')
```

切片：

```SQL
SELECT LEFT('Kindergarden', 4)  -- 取左边（LEFT）4个字符
SELECT RIGHT('Kindergarden', 6)  -- 取右边（RIGHT）6个字符
SELECT SUBSTRING('Kindergarden', 7, 6)  
-- 取中间从第7个开始的长度为6的子串（SUBSTRING）
-- 从第1个（而非第0个）开始计数的
-- 省略第3参数（子串长度）则一直截取到最后
```

定位：

```SQL
SELECT LOCATE('gar', 'Kindergarden')  -- 定位（LOCATE）首次出现的位置
-- 没有的话返回0（其他编程语言大多返回-1，可能因为索引是从0开始的）
-- 这个定位/查找函数依然是不区分大小写的
```

替换：

```SQL
SELECT REPLACE('Kindergarten', 'garten', 'garden')
```

连接：

```SQL
SELECT CONCAT(first_name, ' ', last_name) AS full_name
FROM customers
```

## 3.3. 日期函数

当前时间，返回时间日期对象：

```SQL
SELECT NOW()  -- 2020-09-12 08:50:46
SELECT CURDATE()  -- current date, 2020-09-12
SELECT CURTIME()  -- current time, 08:50:46
```

提取时间日期对象中的元素，返回整数：

```SQL
SELECT YEAR(NOW())  -- 2023
-- MONTH, DAY, HOUR, MINUTE, SECOND
```

返回字符串：

```SQL
SELECT DAYNAME(NOW())  -- Saturday
SELECT MONTHNAME(NOW())  -- September
```

标准SQL语句有一个类似的函数 EXTRACT()，若需要在不同DBMS中录入代码，最好用EXTRACT()：

```SQL
SELECT EXTRACT(YEAR FROM NOW())
```

当然第一参数也可以是MONTH, DAY, HOUR ……
总之就是：EXTRACT(单位 FROM 日期时间对象)


## 3.4. 格式化日期和时间

- `DATE_FORMAT(date, format)` 将 date 根据 format 字符串进行格式化。
- `TIME_FORMAT(time, format)` 类似于 DATE_FORMAT 函数，但这里 format 字符串只能包含用于小时，分钟，秒和微秒的格式说明符。其他说明符产生一个 NULL 值或0。

```SQL
SELECT DATE_FORMAT(NOW(), '%m %d, %y')  -- 12 18, 23
SELECT DATE_FORMAT(NOW(), '%M %D, %Y')  -- December 18th, 2023
SELECT TIME_FORMAT(NOW(), '%h:%i %p')  -- 11:46 PM
SELECT TIME_FORMAT(NOW(), '%H:%I %P')  -- 23:11 P （I看不懂）
```

## 3.5. 计算日期和时间

增加或减少一定的天数、月数、年数、小时数等等

```SQL 
SELECT DATE_ADD(NOW(), INTERVAL -1 DAY)
SELECT DATE_SUB(NOW(), INTERVAL 1 YEAR)
```

但其实不用函数，直接加减更简洁：

```SQL 
NOW() - INTERVAL 1 DAY
NOW() - INTERVAL 1 YEAR 
```

计算日期差异

```SQL 
SELECT DATEDIFF('2019-01-01 09:00', '2019-01-05')  -- -4
-- 会忽略时间部分，只算日期差异

借助 TIME_TO_SEC 函数计算时间差异

TIME_TO_SEC：计算从 00:00 到某时间经历的秒数

SELECT TIME_TO_SEC('09:00')  -- 32400
SELECT TIME_TO_SEC('09:00') - TIME_TO_SEC('09:02')  -- -120
```


## 3.6. IFNULL 和 COALESCE 函数

两个用来替换空值的函数：IFNULL, COALESCE. 后者更灵活

```SQL 
SELECT 
    order_id,
    IFNULL(shipper_id, 'Not Assigned') AS shipper
    /* If expr1 is not NULL, IFNULL() returns expr1; 
    otherwise it returns expr2. */
FROM orders
```

将 orders 里 shipper.id 中的空值替换为 comments，若 comments 也为空则替换为 'Not Assigned'（未分配）

```SQL 
SELECT 
    order_id,
    COALESCE(shipper_id, comments, 'Not Assigned') AS shipper
    /* Returns the first non-NULL value in the list, 
    or NULL if there are no non-NULLvalues. */
FROM orders
```

## 3.7. IF 函数

`IF(条件表达式, 返回值1, 返回值2)` 返回值可以是任何东西，数值 文本 日期时间 空值null 均可

```SQL 
SELECT 
    *,
    IF(YEAR(order_date) = YEAR(NOW()),
       'Active',
       'Archived') AS category
FROM orders
```


## 3.8. CASE 函数

当分类多余两种时，可以用IF嵌套，也可以用CASE语句，后者可读性更好

```SQL 
CASE 
    WHEN …… THEN ……
    WHEN …… THEN ……
    WHEN …… THEN ……
    ……
    [ELSE ……] （ELSE子句是可选的）
END
```