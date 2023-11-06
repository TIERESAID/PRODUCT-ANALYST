/*
Maximum cohort size
You have multiple user profiles, but are there too many parameters you've taken that define cohorts? Will the segments turn out to be too small? To answer these questions, define a maximum size cohort. 
For now, cohorts are defined by the intersection of the parameters city, device type, and date of first product use.
*/

-- Define a Common Table Expression (CTE) named "first_values" to extract initial user parameters
WITH first_values AS (
    -- Select distinct user_id and use FIRST_VALUE function to get the initial values
    SELECT DISTINCT user_id,
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
),

-- Define a CTE named "cohorts" to form cohorts based on user profiles
cohorts AS (
    -- Form cohorts by grouping profiles based on first_date, city_name, and device_type
    SELECT
        first_date,
        city_name,
        device_type,
        COUNT(DISTINCT user_id) AS cohort_size
    FROM profiles
    GROUP BY
        first_date,
        city_name,
        device_type
)

-- Select all columns from the "cohorts" CTE and filter for the cohort with the maximum cohort size
SELECT * FROM cohorts
WHERE cohort_size = (SELECT MAX(cohort_size) FROM cohorts)
