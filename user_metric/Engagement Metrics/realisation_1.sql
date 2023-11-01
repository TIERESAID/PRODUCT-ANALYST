/*
Calculating conversion to movie viewing
Yura's product manager has a hypothesis that iOS is underperforming. To test it, he asks to see how many new users watch at least one movie and make a breakdown by device. 
Calculate the conversion rate of new users to watching at least one movie by device type.
*/

WITH NEW AS (
    SELECT
        user_id,
        app_id,
        MIN(install_date) AS install_date
    FROM events_log
    WHERE log_date = install_date
    GROUP BY user_id, app_id
), movies AS (
    SELECT DISTINCT user_id
    FROM events_log
    WHERE name = 'startMovie'
)
SELECT app_id,
       COUNT(DISTINCT n.user_id) AS new_users,
       COUNT(DISTINCT m.user_id) AS movie_watchers,
       CAST(COUNT(DISTINCT m.user_id) AS FLOAT) / NULLIF(CAST(COUNT(DISTINCT n.user_id) AS FLOAT), 0) AS conversion
FROM NEW n
LEFT OUTER JOIN movies m ON m.user_id = n.user_id
GROUP BY app_id
ORDER BY conversion DESC;
