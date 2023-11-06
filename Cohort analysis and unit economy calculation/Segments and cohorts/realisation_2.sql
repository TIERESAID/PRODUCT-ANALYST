/*
2.
Segmentation of customers by average order value
To understand how to properly improve the monetization of the service, the vendor suggested looking at the statistics on user orders and segmenting the audience by order value.
For each user, calculate the average order value (avg_revenue), create categories by the value of the average order value (payment_category) and segment users by these categories. Sort the result by the number of users in decreasing order of values.
Take the categories by average order value as follows:
0-1000 rubles - Small;
1001-2000 rubles - Medium;
2001-5000 rubles - Large;
5001+ rubles - Very Large.
*/

-- Define a Common Table Expression (CTE) named "AVG_revenue" to calculate average revenue per user
WITH AVG_revenue AS (
    -- Select user_id and calculate the average revenue for each user
    SELECT
        user_id,
        AVG(revenue) AS avg_revenue
    FROM analytics_events
    WHERE event = 'order'  -- Filter for events of type 'order'
    GROUP BY user_id  -- Group the results by user_id
)

-- Select data from the "AVG_revenue" CTE and categorize average revenue
SELECT
    CASE
        WHEN avg_revenue >= 0 AND avg_revenue <= 1000 THEN 'Маленькие' -- Categories based on average revenue ranges
        WHEN avg_revenue >= 1001 and avg_revenue < 2001 THEN 'Средние'
        WHEN avg_revenue >= 2001 and avg_revenue < 5000 THEN 'Большие'
        WHEN avg_revenue >= 5000 THEN 'Очень большие'
    END AS payment_category,
    COUNT(DISTINCT user_id) AS total_users  -- Count the distinct users in each payment category
FROM AVG_revenue
GROUP BY payment_category  -- Group the results by payment category
ORDER BY total_users DESC  -- Sort the results by the number of total users in descending order
