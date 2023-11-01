/*
And Yura also asks to see the share of active buyers and the average number of purchases.
Of course, we want users not only to watch movies, but also to make other equally important target actions - purchases. Calculate the average number of purchases per day for active buyers and for active users in general. Use the data description to find the analytic event responsible for purchases.
*/
SELECT log_date,
       COUNT(DISTINCT user_id) as dau,
       COUNT(DISTINCT CASE WHEN name = 'purchase' THEN user_id ELSE NULL END) as feature_dau,
       CAST(COUNT(DISTINCT CASE WHEN name = 'purchase' THEN user_id ELSE NULL END) AS FLOAT) / CAST(COUNT(DISTINCT user_id) AS FLOAT) as perc_feature_dau,
       SUM(CASE WHEN name = 'purchase' THEN 1 ELSE 0 END) as events,
       CAST(SUM(CASE WHEN name = 'purchase' THEN 1 ELSE 0 END) AS FLOAT) / CAST(COUNT(DISTINCT CASE WHEN name = 'purchase' THEN user_id ELSE NULL END) AS FLOAT) as mean_events,
       CAST(SUM(CASE WHEN name = 'purchase' THEN 1 ELSE 0 END) AS FLOAT) / CAST(COUNT(DISTINCT user_id) AS FLOAT) as mean_events_per_dau
FROM events_log
GROUP BY log_date
ORDER BY log_date;
