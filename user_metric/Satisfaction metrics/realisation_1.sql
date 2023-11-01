/*
Calculating retention
One day, product guy Yura drops by again and says that the iOS version of the movie theater is bothering him. "There's something wrong with its retention, I can feel it in my heart," Yura says. He suggests looking at retention broken down by device type. In his opinion, it's enough to pull out the first nine days. 
Calculate the retention of the ninth day by the type of device from which visitors enter the online cinema.
*/

WITH activity AS (
    SELECT app_id,
           log_date - install_date AS lifetime,
           COUNT(DISTINCT user_id) AS retained
    FROM events_log
    WHERE install_date BETWEEN '2022-11-30' AND '2022-12-04'
    GROUP BY app_id, log_date - install_date
),
retention AS (
    SELECT app_id,
           lifetime,
           retained,
           SUM(CASE WHEN lifetime = 0 THEN retained ELSE 0 END) OVER (PARTITION BY app_id) AS cohort_size,
           CAST(retained AS FLOAT) / SUM(CASE WHEN lifetime = 0 THEN retained ELSE 0 END) OVER (PARTITION BY app_id) AS retention_rate
    FROM activity
)
SELECT * FROM retention WHERE lifetime = 9
ORDER BY retention_rate DESC;
