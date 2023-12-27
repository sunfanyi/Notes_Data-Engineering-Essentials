# 七. DWS 层搭建 <!-- omit from toc -->


# 指标创建

## 创建原子指标

![](assets/2023-12-26-21-58-45.png)

![](assets/2023-12-26-21-57-47.png)

![](assets/2023-12-26-21-44-33.png)

![](assets/2023-12-26-21-45-51.png)

![](assets/2023-12-26-21-46-45.png)

![](assets/2023-12-26-21-48-11.png)

![](assets/2023-12-26-21-48-57.png)

![](assets/2023-12-26-21-49-58.png)

![](assets/2023-12-26-21-50-45.png)

![](assets/2023-12-26-21-52-24.png)

![](assets/2023-12-26-21-53-09.png)

![](assets/2023-12-26-21-56-42.png)

![](assets/2023-12-26-21-54-01.png)

![](assets/2023-12-26-21-54-51.png)

## 创建派生指标

可以手动一个一个创建，或者直接批量创建。

### 下单

![](assets/2023-12-26-22-13-06.png)

点击生成，创建并提交：

![](assets/2023-12-26-22-04-55.png)


### 交易流程

![](assets/2023-12-26-22-09-02.png)

### 支付成功

![](assets/2023-12-26-22-11-40.png)


# 创建汇总表

去维度建模新建汇总表：

## 用户粒度订单1日汇总表 dws_gmall_trade_user_order_1d

![](assets/2023-12-26-22-21-16.png)

![](assets/2023-12-26-22-36-31.png)

**关联字段：**

或者看下一张表格用到的指标导入

![](assets/2023-12-26-22-25-08.png)

保存 -> 提交 -> 发布。

## 用户粒度支付1日汇总表 - dws_gmall_trade_user_payment_1d

![](assets/2023-12-26-22-32-00.png)

**指标导入：**

相当于直接关联上了

![](assets/2023-12-26-22-38-49.png)

![](assets/2023-12-26-22-33-23.png)

![](assets/2023-12-26-22-37-36.png)

然后去把user_id关联上：

![](assets/2023-12-26-22-39-47.png)

## 省份粒度订单1日汇总表 - dws_gmall_trade_province_order_1d

![](assets/2023-12-26-22-41-28.png)

前五个手动添加：

![](assets/2023-12-26-22-45-10.png)

![](assets/2023-12-26-22-45-23.png)

## 下单到支付时间间隔1日汇总表 - dws_gmall_trade_order_to_pay_interval_1d

不需要粒度，这张表是所有这一天内订单的时间间隔，只需要分区来表示时间就行：

![](assets/2023-12-26-22-49-21.png)

![](assets/2023-12-26-22-50-57.png)

## 省份粒度订单n日汇总表 - dws_gmall_trade_province_order_nd

![](assets/2023-12-26-22-53-10.png)

![](assets/2023-12-26-22-55-50.png)

![](assets/2023-12-26-22-55-35.png)

## 用户粒度订单至今汇总表 - dws_gmall_trade_user_order_std

![](assets/2023-12-26-22-57-28.png)

前三个手动加：

![](assets/2023-12-26-23-00-01.png)

![](assets/2023-12-26-23-00-40.png)


# 同步汇总表

## 用户粒度订单1日汇总表

### 首日装载

把昨天以前的 groupby 分区就行：

```SQL
INSERT OVERWRITE TABLE dws_gmall_trade_user_order_1d PARTITION (ds)
SELECT  user_id
        ,COUNT(DISTINCT order_id) order_count_1d
        ,SUM(CAST(sku_num AS BIGINT)) order_sku_num_1d
        ,SUM(split_original_amount) order_original_amount_1d
        ,SUM(NVL(split_activity_amount,0)) activity_reduce_amount_1d
        ,SUM(NVL(split_coupon_amount,0)) coupon_reduce_amount_1d
        ,SUM(split_total_amount) order_total_amount_1d
        ,ds
FROM    dwd_gmall_trade_order_detail_di
WHERE   ds <= '20231222'
GROUP BY user_id
         ,ds
;
```

### 每日装载

分区换一下就行：


```SQL
INSERT OVERWRITE TABLE dws_gmall_trade_user_order_1d PARTITION (ds)
SELECT  user_id
        ,COUNT(DISTINCT order_id) order_count_1d
        ,SUM(CAST(sku_num AS BIGINT)) order_sku_num_1d
        ,SUM(split_original_amount) order_original_amount_1d
        ,SUM(NVL(split_activity_amount,0)) activity_reduce_amount_1d
        ,SUM(NVL(split_coupon_amount,0)) coupon_reduce_amount_1d
        ,SUM(split_total_amount) order_total_amount_1d
        ,ds
FROM    dwd_gmall_trade_order_detail_di
WHERE   ds = '${bizdate}'
GROUP BY user_id
         ,ds
;
```

## 用户粒度支付1日汇总表


跟上一张表一样很简单。

### 首日装载

```SQL
INSERT OVERWRITE TABLE dws_gmall_trade_user_payment_1d PARTITION (ds)
SELECT  user_id
        ,SUM(CAST(sku_num AS BIGINT)) payment_suc_sku_num_1d
        ,COUNT(*) payment_suc_count_1d
        ,SUM(split_total_amount) payment_suc_amount_1d
        ,ds
FROM    dwd_gmall_trade_payment_suc_detail_di
WHERE   ds <= '20231222'
GROUP BY user_id
         ,ds
;
```

### 每日装载

```SQL
INSERT OVERWRITE TABLE dws_gmall_trade_user_payment_1d PARTITION (ds)
SELECT  user_id
        ,SUM(CAST(sku_num AS BIGINT)) payment_suc_sku_num_1d
        ,COUNT(*) payment_suc_count_1d
        ,SUM(split_total_amount) payment_suc_amount_1d
        ,ds
FROM    dwd_gmall_trade_payment_suc_detail_di
WHERE   ds = '${bizdate}'
GROUP BY user_id
         ,ds
;
```



## 省份粒度订单1日汇总表


### 首日装载

```SQL
INSERT OVERWRITE TABLE dws_gmall_trade_province_order_1d PARTITION (ds)
SELECT  province_id
        ,name province_name
        ,area_code
        ,iso_code
        ,iso_3166_2
        ,activity_reduce_amount_1d
        ,order_count_1d
        ,coupon_reduce_amount_1d
        ,order_total_amount_1d
        ,order_user_num_1d
        ,order_original_amount_1d
        ,ds
FROM    (
            SELECT  province_id
                    ,SUM(split_activity_amount) activity_reduce_amount_1d
                    ,SUM(split_coupon_amount) coupon_reduce_amount_1d
                    ,SUM(split_total_amount) order_total_amount_1d
                    ,SUM(split_original_amount) order_original_amount_1d
                    ,COUNT(*) order_count_1d
                    ,COUNT(DISTINCT user_id) order_user_num_1d
                    ,ds
            FROM    dwd_gmall_trade_order_detail_di 
            WHERE   ds <= '20231222'
            GROUP BY province_id
                     ,ds
        ) t1
LEFT JOIN   (
                SELECT  id
                        ,name
                        ,area_code
                        ,iso_code
                        ,iso_3166_2
                FROM    dim_province_df 
                WHERE   ds = '20231222'
            ) province
ON      t1.province_id = province.id
;
```

### 每日装载

```SQL
INSERT OVERWRITE TABLE dws_gmall_trade_province_order_1d PARTITION (ds)
SELECT  province_id
        ,name province_name
        ,area_code
        ,iso_code
        ,iso_3166_2
        ,activity_reduce_amount_1d
        ,order_count_1d
        ,coupon_reduce_amount_1d
        ,order_total_amount_1d
        ,order_user_num_1d
        ,order_original_amount_1d
        ,ds
FROM    (
            SELECT  province_id
                    ,SUM(split_activity_amount) activity_reduce_amount_1d
                    ,SUM(split_coupon_amount) coupon_reduce_amount_1d
                    ,SUM(split_total_amount) order_total_amount_1d
                    ,SUM(split_original_amount) order_original_amount_1d
                    ,COUNT(*) order_count_1d
                    ,COUNT(DISTINCT user_id) order_user_num_1d
                    ,ds
            FROM    dwd_gmall_trade_order_detail_di 
            WHERE   ds = '${bizdate}'
            GROUP BY province_id
                     ,ds
        ) t1
LEFT JOIN   (
                SELECT  id
                        ,name
                        ,area_code
                        ,iso_code
                        ,iso_3166_2
                FROM    dim_province_df 
                WHERE   ds = '${bizdate}'
            ) province
ON      t1.province_id = province.id
;
```




## 下单到支付时间间隔1日汇总表

回忆一下源表（dwd_gmall_trade_trade_flow_order_di）长啥样：

![](assets/2023-12-27-22-48-50.png)

### 首日装载

选取未完成、或初始化日期前已完成的已付款订单：

```SQL
SET odps.sql.hive.compatible = true
;

INSERT OVERWRITE TABLE dws_gmall_trade_order_to_pay_interval_1d PARTITION (ds)
SELECT  CAST(AVG(UNIX_TIMESTAMP(payment_time,'yyyy-MM-dd HH:mm:ss') - UNIX_TIMESTAMP(order_time,'yyyy-MM-dd HH:mm:ss')) AS BIGINT)
        ,DATE_FORMAT(payment_time,'yyyyMMdd') ds
FROM    dwd_gmall_trade_trade_flow_order_di
WHERE   (
            ds = '99991231'  -- 未完成的
            OR      ds <= '20231222'
)
AND     payment_time IS NOT NULL -- 只要已付款的订单
GROUP BY DATE_FORMAT(payment_time,'yyyyMMdd')
;



```

### 每日装载

选取未完成、bizdate刚完成的刚付款订单：

```SQL
SET odps.sql.hive.compatible = true
;

INSERT OVERWRITE TABLE dws_gmall_trade_order_to_pay_interval_1d PARTITION (ds)
SELECT  CAST(AVG(UNIX_TIMESTAMP(payment_time,'yyyy-MM-dd HH:mm:ss') - UNIX_TIMESTAMP(order_time,'yyyy-MM-dd HH:mm:ss')) AS BIGINT)
        ,DATE_FORMAT(payment_time,'yyyyMMdd') ds
FROM    dwd_gmall_trade_trade_flow_order_di
WHERE   (
            ds = '99991231'  -- 未完成的
            OR  ds = '${bizdate}'  -- bizdate刚完成的
)
AND     DATE_FORMAT(payment_time,'yyyyMMdd') = '${bizdate}'  -- 刚付款的
GROUP BY DATE_FORMAT(payment_time,'yyyyMMdd')
;

```


## 省份粒度订单n日汇总表


n日表不需要首日装载，因为首日往回拿n天毫无意义。

需要对格式为`yyyyMMdd`的 ds 进行时间上的加减：
- 需要用到 `date_add` 函数。虽然这个函数支持 DATE、DATETIME 或 STRING 类型，但参数为 STRING 类型时，STRING参数格式至少要包含`yyyy-mm-dd`；
- 所以需要用 `date_format` 转换，但只支持 DATE 或 TIMESTAMP 类型；
- 这个时候需要转换成 DATE 或 TIMESTAMP 类型，这时候需要连用 `FROM_UNIXTIME(UNIX_TIMESTAMP())`，其中`UNIX_TIMESTAMP`会把 STRING 转换成表示时间的 UNIX 整数值，`FROM_UNIXTIME`会把它转换回时间;
- 加起来就是：
  
```SQL
DATE_ADD(DATE_FORMAT(FROM_UNIXTIME(UNIX_TIMESTAMP('20231222','yyyyMMdd')), 'yyyy-MM-dd'), -6)
```

-> 结果为 '2023-12-16'




## 用户粒度订单至今汇总表


### 首日装载


### 每日装载


