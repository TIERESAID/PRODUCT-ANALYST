/*
Let's start with a simple task. Calculate the total DAU with grouping by days. To make the query work faster, do not count all types of events, but take only analytical events like pageOpen. Every active user sends at least one such event when logging into the product. Try to do it completely on your own!
*/

SELECT
    log_date,
    COUNT(DISTINCT user_id) AS unique_users
FROM
    events_log
WHERE
    name = 'pageOpen'
GROUP BY
    log_date;
