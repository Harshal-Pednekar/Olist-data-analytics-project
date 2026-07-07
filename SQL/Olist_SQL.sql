create database oliststore;
use oliststore;

#==========================================================================================
### KPI 1 : Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics
#==========================================================================================

-- Table used
select *  from olist_orders;
select *  from olist_order_payments;

-- KPI Begins  
select d.Day_End, 
Concat(round((d.Total_pmt/(Select sum(payment_value) from olist_order_payments)) *100,0),'%') as percent_payment_value 
from 
(select ord.Day_End, sum(pmt.payment_value) as Total_pmt 
from olist_order_payments as pmt 
join 
(Select distinct (order_id), 	
case when weekday (order_purchase_timestamp) in (5,6) then "Weekend" 
else 
"Weekday" end as Day_End from olist_orders_dataset) as ord on ord.order_id=pmt.order_id group by ord.Day_End) as d;


#==========================================================================================
### KPI 2 :  Number of Orders with review score 5 and payment type as credit card.
#==========================================================================================

-- Table used
select *  from olist_orders;
select *  from olist_order_reviews;
select *  from olist_order_payments;

-- KPI Begins  
select pymt.payment_type,  CONCAT(FORMAT(count(pymt.order_id) / 1000, 1), 'k') as Total_Orders 
from olist_order_payments as pymt 
join 
(select distinct ord.order_id,rw.review_score 
from olist_orders_dataset as ord 
join 
olist_order_reviews rw on ord.order_id=rw.order_id where review_score=5) as rw5 
on pymt.order_id=rw5.order_id 
group by pymt.payment_type 
order by Total_Orders desc;


-- Reflects on the basis of Paymenttype as Credit_Card
SELECT pymt.payment_type, CONCAT(FORMAT(COUNT(pymt.order_id) / 1000, 1), 'k') AS Total_orders
FROM olist_order_payments AS pymt
INNER JOIN olist_order_reviews AS rev ON pymt.order_id = rev.order_id
WHERE rev.review_score = 5
AND pymt.payment_type = 'credit_card';

#==========================================================================================
### KPI 3 :  Average number of days taken for order_delivered_customer_date for pet_shop
#==========================================================================================

-- Table used
select *  from olist_orders;
select *  from olist_products;
select *  from olist_order_items;

-- KPI Begins  
SELECT prod.product_category_name,
       ROUND(AVG(DATEDIFF(ord.order_delivered_customer_date, ord.order_purchase_timestamp)), 0) AS Avg_delivery_days
FROM olist_orders AS ord
JOIN olist_order_items AS oi ON ord.order_id = oi.order_id
JOIN olist_products AS prod ON oi.product_id = prod.product_id
WHERE prod.product_category_name = 'Pet_shop'
GROUP BY prod.product_category_name;

#==============================================================================
### KPI 4 :  Average price and payment values from customers of sao paulo city
#==============================================================================

-- Table used
select *  from olist_orders;
select *  from olist_customers;
select *  from olist_order_items;
select *  from olist_order_payments;

-- KPI Begins  
WITH orderItemAvg AS (
    SELECT ROUND(AVG(item.price)) AS avg_order_item_price
    FROM olist_order_items item
    JOIN olist_orders ord ON item.order_id = ord.order_id
    JOIN olist_customers cust ON ord.customer_id = cust.customer_id
    WHERE cust.customer_city = 'Sao Paulo'
)
SELECT
    cust.customer_city,(SELECT avg_order_item_price FROM orderItemAvg) AS avg_order_item_price,
    ROUND(AVG(pmt.payment_value)) AS avg_payment_value
FROM olist_order_payments pmt
JOIN olist_orders ord ON pmt.order_id = ord.order_id
JOIN olist_customers cust ON ord.customer_id = cust.customer_id
WHERE cust.customer_city = "Sao Paulo";

#============================================================================================================================
### KPI 5 :  Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores.
#============================================================================================================================

-- Table used
select *  from olist_orders;
select *  from olist_order_reviews;

-- KPI Begins 
Select rev.review_score,
CONCAT(ROUND(avg(DATEDIFF(ord.order_delivered_customer_date, order_purchase_timestamp)), 0),'   Days') as "Avg_shipping_days"
from olist_orders as ord
join olist_order_reviews as rev on rev.order_id = ord.order_id
group by rev.review_score
order by rev.review_score;

