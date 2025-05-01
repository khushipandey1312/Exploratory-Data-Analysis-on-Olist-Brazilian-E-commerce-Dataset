1) top locations by purchase volume(join orders->customer->group by customer_state or city)

SELECT c.customer_state, COUNT(o.order_id) AS total_orders
FROM orders o
JOIN customer c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;

2)count of unique customer_id with more than one order_id

SELECT customer_id, COUNT(order_id) AS order_count
FROM orders
GROUP BY customer_id
HAVING COUNT(order_id) > 1

3) customer lifetime value(join orders->payments,group by customer_id,and sum payment_values)

SELECT o.customer_id, SUM(p.payment_value) AS lifetime_value
FROM orders o
JOIN payments p ON o.order_id = p.order_id
GROUP BY o.customer_id
ORDER BY lifetime_value DESC;

4)delivery delays(from orders,calculate diff between order_estimated_delivery_date and order_delivery_customer_date)

SELECT order_id,
(cast(order_delivered_customer_date as timestamp) - cast(order_estimated_delivery_date as timestamp) )AS delay_days
FROM orders
WHERE order_delivered_customer_date  not in('NaN','null','')
and order_estimated_delivery_date  not in ('NaN','null','')
and order_delivered_customer_date >order_estimated_delivery_date 
order by delay_days desc

5)
time taken from order_approved_at to order_delivered_customer_date

SELECT order_id,
      (cast(order_delivered_customer_date as timestamp)- cast( order_approved_at as timestamp)) AS delivery_time_days
FROM orders
WHERE order_delivered_customer_date not in ('NaN','null','') 
AND order_approved_at ('NaN','null','');

6)From order_items, analyze freight_value across regions or sellers.

SELECT 
    s.seller_state,AVG(oi.freight_value) AS avg_freight_value,COUNT(oi.order_id) AS total_items_shipped
FROM order_items oi
JOIN sellers s ON oi.seller_id = s.seller_id
GROUP BY  s.seller_state
ORDER BY avg_freight_value DESC;

7)Product Weight vs Shipping Cost	Join order_items → products, compare product_weight_g vs freight_value.

SELECT p.product_id,AVG(p.product_weight_g) AS avg_product_weight_g,AVG(oi.freight_value)AS avg_freight_value,COUNT(*) AS total_items
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id
ORDER BY avg_freight_value desc
    
8)Popular Payment Methods From payments, count of orders by payment_type.
 
 SELECT payment_type,COUNT( order_id) AS total_orders
FROM payments
GROUP BY payment_type
ORDER BY total_orders DESC;

9)Installment Trends Analyze average payment_installments by product category or price range.
SELECT  p.product_category_name,AVG(pay.payment_installments) AS avg_installments,COUNT(oi.order_id) AS total_orders
FROM payments pay
JOIN order_items oi ON pay.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE pay.payment_installments IS NOT NULL
GROUP BY p.product_category_name
ORDER BY avg_installments DESC;

10)	Revenue Trends Sum payment_value by month using order_purchase_timestamp.
SELECT TO_CHAR(CAST(o.order_purchase_timestamp AS TIMESTAMP), 'YYYY-MM') AS month,
SUM(p.payment_value) AS total_revenue,COUNT(DISTINCT o.order_id) AS total_orders
FROM payments p
JOIN orders o ON p.order_id = o.order_id
WHERE o.order_purchase_timestamp IS NOT NULL
GROUP BY month
ORDER BY month;

11)Top-Selling Products / Categories	From order_items → products → product_category_name → count of product_id

SELECT p.product_category_name,COUNT(oi.product_id) AS total_items_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_items_sold desc

12)	Product Rating Distribution Join order_items → orders → reviews, and get average review_score per product.

SELECT oi.product_id,AVG(r.review_score) AS avg_review_score,COUNT(r.review_id) AS total_reviews
FROM order_items oi
JOIN reviews r ON oi.order_id = r.order_id
GROUP BY oi.product_id
ORDER BY avg_review_score DESC;

13) 	Return / Low Score Products(Products with a high frequency of review_score ≤ 2.)(no of total bad reviws for a product)

SELECT oi.product_id,COUNT(*) AS low_score_reviews 
FROM order_items oi
JOIN reviews r ON oi.order_id = r.order_id
WHERE r.review_score <= 2
GROUP BY oi.product_id
ORDER BY low_score_reviews DESC;

14)	Top Sellers by Revenue (Join order_items → group by seller_id → sum price.)

SELECT oi.seller_id,SUM(oi.price) AS total_revenue,COUNT(oi.order_item_id) AS total_items_sold
FROM order_items oi
GROUP BY oi.seller_id
ORDER BY total_revenue DESC

15)Seller Locations vs Shipping Costs (Join sellers and order_items, analyze average freight_value per state.)

SELECT  s.seller_state,AVG(oi.freight_value) AS avg_freight_value,COUNT(oi.order_item_id) AS total_items_sold
FROM  order_items oi
JOIN sellers s ON oi.seller_id = s.seller_id
GROUP BY s.seller_state
ORDER BY avg_freight_value DESC;

16)Order Fulfillment Time(Use shipping_limit_date and order_delivered_carrier_date to compute promptness.)

SELECT oi.order_id,oi.seller_id, oi.product_id,oi.shipping_limit_date,o.order_delivered_carrier_date,
CAST(o.order_delivered_carrier_date AS date) - CAST(oi.shipping_limit_date AS date) AS fulfillment_days
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_delivered_carrier_date not in ('NaN','null','') 
and oi.shipping_limit_date not in ('NaN','null','') 
ORDER BY fulfillment_days DESC;







