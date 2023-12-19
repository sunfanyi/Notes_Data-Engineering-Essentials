# 七. MySQL内置函数 - MySQL Built-In Functions

- [七. MySQL内置函数 - MySQL Built-In Functions](#七-mysql内置函数---mysql-built-in-functions)
  - [7.1. 数值函数](#71-数值函数)
  - [7.2. 字符串函数](#72-字符串函数)
  - [7.3. 日期函数](#73-日期函数)
  - [7.4. 格式化日期和时间](#74-格式化日期和时间)
  - [7.5. 计算日期和时间](#75-计算日期和时间)
  - [7.6. IFNULL 和 COALESCE 函数](#76-ifnull-和-coalesce-函数)
  - [7.7. IF 函数](#77-if-函数)
  - [7.8. CASE 函数](#78-case-函数)

## 7.1. 数值函数

```SQL
SELECT ROUND(5.7365, 2)  -- 四舍五入
SELECT TRUNCATE(5.7365, 2)  -- 截断
SELECT CEILING(5.2)  -- 天花板函数，大于等于此数的最小整数
SELECT FLOOR(5.6)  -- 地板函数，小于等于此数的最大整数
SELECT ABS(-5.2)  -- 绝对值
SELECT RAND()  -- 随机函数，0到1的随机值
```

## 7.2. 字符串函数

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

## 7.3. 日期函数

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


## 7.4. 格式化日期和时间

- `DATE_FORMAT(date, format)` 将 date 根据 format 字符串进行格式化。
- `TIME_FORMAT(time, format)` 类似于 DATE_FORMAT 函数，但这里 format 字符串只能包含用于小时，分钟，秒和微秒的格式说明符。其他说明符产生一个 NULL 值或0。

```SQL
SELECT DATE_FORMAT(NOW(), '%m %d, %y')  -- 12 18, 23
SELECT DATE_FORMAT(NOW(), '%M %D, %Y')  -- December 18th, 2023
SELECT TIME_FORMAT(NOW(), '%h:%i %p')  -- 11:46 PM
SELECT TIME_FORMAT(NOW(), '%H:%I %P')  -- 23:11 P （I看不懂）
```

## 7.5. 计算日期和时间

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


## 7.6. IFNULL 和 COALESCE 函数

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

## 7.7. IF 函数

`IF(条件表达式, 返回值1, 返回值2)` 返回值可以是任何东西，数值 文本 日期时间 空值null 均可

```SQL 
SELECT 
    *,
    IF(YEAR(order_date) = YEAR(NOW()),
       'Active',
       'Archived') AS category
FROM orders
```


## 7.8. CASE 函数

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