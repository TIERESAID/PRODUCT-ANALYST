/*

Segmentation of orders by day of the week
It is hypothesized that the number of orders decreases on Saturday and Sunday, because on weekdays customers order food both to work and home, and on weekends - mainly to home. You also need to test the hypothesis that when the number of orders decreases on weekends, the average cost of orders and average revenue per customer is greater than on weekdays.
Segment the orders by day of the week and for each segment calculate:
the number of customers who ordered food delivery (total_users);
total number of orders (total_orders);
average cost per order (avg_order_cost);
average service revenue per customer (avg_users_revenue);
Additionally, for each segment, calculate the share of completed orders (orders_share).

*/

-- Define a Common Table Expression (CTE) named "orders" to calculate order statistics per user and day
WITH orders AS (
    -- Select user_id, log_date, day of the week, and calculate various statistics related to orders
    SELECT 
        user_id,
        log_date,
        TO_CHAR(log_date, 'Day') AS day_of_week,  -- Extract the day of the week from log_date
        COUNT(DISTINCT order_id) AS total_orders,  -- Count the distinct orders for each user and day
        SUM(revenue) AS sum_order_costs,  -- Sum of order costs
        SUM(revenue * commission - delivery) AS sum_revenue  -- Sum of revenue after deducting commission and delivery costs
    FROM analytics_events
    WHERE event = 'order'  -- Filter for events of type 'order'
    GROUP BY user_id, log_date  -- Group the results by user_id and log_date
),

-- Define another CTE named "days_stat" to calculate daily statistics
days_stat AS (
    -- Select day_of_week and calculate various statistics for each day of the week
    SELECT 
        day_of_week,
        COUNT(DISTINCT user_id) AS total_users,  -- Count the distinct users for each day
        SUM(total_orders) AS total_orders,  -- Sum of total orders for each day
        SUM(sum_order_costs) / SUM(total_orders) AS avg_order_cost,  -- Calculate average order cost
        SUM(sum_revenue) / COUNT(DISTINCT user_id) AS avg_users_revenue,  -- Calculate average user revenue
        CAST(SUM(total_orders) / (SELECT SUM(total_orders) FROM orders) AS FLOAT) AS orders_share  -- Calculate the share of orders for each day
    FROM orders
    GROUP BY day_of_week  -- Group the results by day_of_week
)

-- Select all columns from the "days_stat" CTE and sort the results by average user revenue in descending order
SELECT
    *
FROM days_stat
ORDER BY avg_users_revenue DESC
