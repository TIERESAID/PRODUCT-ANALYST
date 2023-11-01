/*
Calculating the share of usage of a feature
Yura also asks to see the share of users who watch movies on different devices. This is necessary to add clarifying questions to the questionnaire for newcomers. For example, if iOS users don't watch movies, they will be asked what prevents them from doing so.
Calculate the proportion of active users that are users who watch at least one movie per day. Break it down by device type.
*/

WITH dau AS (
    SELECT DISTINCT user_id, app_id, log_date
    FROM events_log
),
movies AS (
    SELECT DISTINCT user_id, log_date
    FROM events_log
    WHERE name = 'startMovie'
)
SELECT app_id,
       COUNT(DISTINCT user_id) AS dau,
       COUNT(DISTINCT movie_user_id) AS movie_dau,
       CAST(COUNT(DISTINCT movie_user_id) AS FLOAT) / CAST(COUNT(DISTINCT user_id) AS FLOAT) AS movie_rate
FROM (
    SELECT d.app_id, d.log_date, d.user_id, m.user_id AS movie_user_id
    FROM dau d
    LEFT JOIN movies m ON d.user_id = m.user_id AND d.log_date = m.log_date
) t
GROUP BY app_id
ORDER BY movie_rate DESC;
