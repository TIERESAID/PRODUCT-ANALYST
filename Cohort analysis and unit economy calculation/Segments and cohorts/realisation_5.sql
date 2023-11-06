/*
User Profile
You have undertaken to explore cohorts of users who are highlighted by date of first use of the service. The boundaries of the time period are from '2021-05-01' to '2021-05-07'. You are just starting your analysis and assume that, in addition to the date of first use, you may also need the user's city and device type from the user profile.
Print the first five profiles by date, city and device type to see the results of your query and draw your first conclusions.
*/

-- Define a Common Table Expression (CTE) named "first_values" to extract initial user parameters
WITH first_values AS (
    -- Select distinct user_id and use FIRST_VALUE function to get the initial values
    SELECT 
        DISTINCT user_id,
        FIRST_VALUE(c.city_name) OVER (PARTITION BY user_id ORDER BY datetime) AS city_name,
        FIRST_VALUE(c.city_id) OVER (PARTITION BY user_id ORDER BY datetime) AS city_id,
        FIRST_VALUE(a.first_date) OVER (PARTITION BY user_id ORDER BY datetime) AS first_date,
        FIRST_VALUE(a.device_type) OVER (PARTITION BY user_id ORDER BY datetime) AS device_type
    FROM analytics_events AS a
    LEFT JOIN cities c ON a.city_id = c.city_id
    WHERE first_date BETWEEN '2021-05-01' AND '2021-05-07'  -- Filter by date range
          AND event = 'authorization'  -- Filter for events of type 'authorization'
          AND user_id IS NOT NULL  -- Filter for non-null user_ids
),

-- Define another CTE named "profiles" to form user profiles based on initial values
profiles AS (
    -- Select user_id, first_date, and initial parameter values from "first_values"
    SELECT f.user_id,
           f.first_date,
           f.city_name, 
           f.city_id,
           f.device_type
    FROM first_values AS f
)

-- Select all columns from "profiles" and order the results by first_date, city_name, and device_type
SELECT * from profiles
ORDER BY first_date, city_name, device_type
LIMIT 5  -- Limit the output to the top 5 profiles
