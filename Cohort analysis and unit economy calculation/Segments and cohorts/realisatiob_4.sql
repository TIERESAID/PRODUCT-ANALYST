/*
Segmentation of large orders by type of establishment
Identify a promising segment that the service should promote.
Segment orders that cost more than 2500 rubles by type of establishment. For segmentation, use only those orders that were made by users within the first 14 days of registration.
*/

-- Define a Common Table Expression (CTE) named "orders" to calculate order statistics
WITH orders AS (
    -- Select relevant columns and calculate order cost and revenue
    SELECT 
        order_id,
        log_date,
        rest_id,
        city_id,
        revenue AS order_cost,
        revenue * commission - delivery AS order_revenue
    FROM analytics_events

    -- Filter for specific conditions related to orders
    WHERE event = 'order' 
          AND first_date <= '2021-06-17'  -- Orders within the first 14 days from registration
          AND log_date BETWEEN '2021-05-01' AND '2021-07-01'
          AND log_date - first_date < 14
          AND revenue > 2500
),

-- Define another CTE named "rest_info" to add information about restaurant type
rest_info AS (
    -- Select columns related to restaurant type and join with the "partners" table
    SELECT 
        p.type AS rest_type,
        o.order_id,
        o.order_cost,
        o.order_revenue
    FROM orders o
    LEFT JOIN partners p ON o.rest_id = p.rest_id AND o.city_id = p.city_id
),

-- Define a CTE named "orders_by_rest" to calculate aggregate statistics for each restaurant type
orders_by_rest AS (
    -- Calculate total orders, average order cost, and average revenue for each restaurant type
    SELECT 
        rest_type,
        COUNT(DISTINCT order_id) as total_orders,
        SUM(order_cost) / COUNT(DISTINCT order_id) AS avg_order_cost,
        SUM(order_revenue) / COUNT(DISTINCT order_id) AS avg_revenue
    FROM rest_info
    GROUP BY rest_type
)

-- Select columns from "orders_by_rest" and add a column for the share of total orders
SELECT 
    rest_type,
    total_orders,
    avg_order_cost,
    avg_revenue,
    CAST(total_orders AS FLOAT) / SUM(total_orders) OVER () AS total_orders_share
FROM orders_by_rest
ORDER BY total_orders DESC
