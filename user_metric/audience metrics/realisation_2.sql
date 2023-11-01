/*
DAU calculation
Let's move on to more complex tasks.
Yura, a product manager, comes to you and says that six months ago the share of Android users in the theater was 10%, and recently the product team released a new and improved version of Android. Yura asks for an estimate of what percentage of the active audience are Android users now.

Help figure out the distribution of active users by platform. For each of the days, calculate:
total DAU;
DAU for each device type;
the share of DAU for each device type from the total DAU.
From the result, select the DAUs of users using Android devices.
*/

WITH dau AS (
    -- Calculate daily unique visitors for 'pageOpen' events grouped by log_date and app_id
    SELECT
        log_date,
        app_id,
        COUNT(DISTINCT user_id) AS uniques
    FROM events_log
    WHERE name = 'pageOpen'
    GROUP BY log_date, app_id
)

-- Calculate total daily unique visitors and percentage of daily unique visitors
SELECT *
FROM (
    SELECT *,
        SUM(uniques) OVER (PARTITION BY log_date) AS total_dau,
        CAST(uniques AS FLOAT) / SUM(uniques) OVER (PARTITION BY log_date) AS perc_dau
    FROM dau
) r
-- Filter by app_id 'Android' and order by log_date
WHERE app_id = 'Android'
ORDER BY log_date;


