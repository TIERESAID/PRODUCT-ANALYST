/* 

Распределение заказов по возрасту пользователей
Проверьте возраст основной целевой аудитории сервиса с помощью сегментации заказов. 
Посчитайте количество заказов по каждой из возрастных категорий пользователей. При расчёте учитывайте заказы, совершённые в первые 14 дней с момента регистрации. Поскольку время проведения анализа — 01.07.2021, то нужно ограничить дату регистрации пользователей по 17.06.2021 включительно, чтобы у всех клиентов была информация о заказах, совершённых за первые 14 дней.

*/
-- Define a Common Table Expression (CTE) named "orders" to store intermediate results
WITH orders AS (
    -- Select relevant columns from the "analytics_events" table
    SELECT 
        user_id,
        age,
        log_date,
        (log_date - first_date) AS lifetime,  -- Calculate the user's lifetime based on log_date and first_date
        COUNT(DISTINCT order_id) as total_orders  -- Count the distinct orders for each user
    FROM analytics_events
    WHERE event = 'order'  -- Filter for events of type 'order'
          AND first_date BETWEEN '2021-05-01' AND '2021-06-17'  -- Filter by date range
    GROUP BY
        user_id,
        age,
        log_date,
        lifetime  -- Group the results by user_id, age, log_date, and lifetime
)

-- Select data from the "orders" CTE and perform additional calculations
SELECT age AS age_group,  -- Rename the "age" column to "age_group" in the final result
       COUNT(DISTINCT user_id) AS total_users,  -- Count the distinct users in each age group
       SUM(total_orders) AS total_orders  -- Sum the total_orders to get the total orders in each age group
FROM orders
WHERE lifetime < 14  -- Filter the results to include only users with a lifetime less than 14
GROUP BY age  -- Group the results by age
ORDER BY age_group  -- Sort the results by the "age_group" column
