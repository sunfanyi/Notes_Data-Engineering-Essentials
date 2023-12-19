# 三. 多表检索 - Retrieving Data From Multiple Tables

- [三. 多表检索 - Retrieving Data From Multiple Tables](#三-多表检索---retrieving-data-from-multiple-tables)
	- [3.1. INNER JOIN 内连接](#31-inner-join-内连接)
	- [3.2. SELF JOIN 自连接](#32-self-join-自连接)
	- [3.3. Compound JOIN 复合连接条件](#33-compound-join-复合连接条件)
	- [3.4. Outer JOIN 外连接](#34-outer-join-外连接)
	- [3.5. NATURAL JOIN 自然连接](#35-natural-join-自然连接)
	- [3.6. CROSS JOIN 交叉连接](#36-cross-join-交叉连接)
	- [3.7. UNION 联合](#37-union-联合)

## 3.1. INNER JOIN 内连接

**Horizontal concat:**
```SQL
select *
from tblA
inner join tblB  -- where 'inner' is optional
	on tblA.key = tblB.key
inner join tblC  -- multiple join
	on tblA.key = tblC.another_key

-- if they have the same key:
select *
from tblA
inner join tblB  -- where 'inner' is optional
	using (key)

-- Or implicit join:
select *
from tblA aliasA, tblB aliasB
where aliasA.key = aliasB.key
```

## 3.2. SELF JOIN 自连接

```SQL
USE sql_hr;
select 
    e.employee_id,
    e.first_name,
    m.first_name as manager
from employees e
join employees m
    on e.reports_to = m.employee_id
```

## 3.3. Compound JOIN 复合连接条件

```SQL
select *
from tbl1
join tbl2
	on tbl1.col1 = tbl2.col1
	and tbl1.col2 = tbl2.col2
```

## 3.4. Outer JOIN 外连接

- INNER JOIN: intersection, OUTER JOIN: union.
- LEFT JOIN: return all rows in the left table regardless of the condition, fill with null, same for RIGHT JOIN.

```SQL
select *
from tblA
left join tblB
	on tblA.key = tblB.key
```

## 3.5. NATURAL JOIN 自然连接

- Join by all columns with same name。

```SQL
select *
from tblA
natural join tblB
```

## 3.6. CROSS JOIN 交叉连接

- Join all records from tables (all combinations)。

```SQL
select *
from tblA
cross join tblB

-- Or implicit join:
select *
from tblA, tblB  -- without typing where
```

## 3.7. UNION 联合

- vertical concat (explicit)
- 合并的查询结果必须列数相等，否则会报错
- 合并表里的列名由排在 UNION 前面的决定

```SQL
select 
	col1
	'A' AS type  -- add a new column 'type'
from tbl
where col1 > threshold

union

select 
	arbitary_col
	'B' AS type
from tbl
where arbitary_col < threshold
```

> 合并后的第一列会被命名为 col1