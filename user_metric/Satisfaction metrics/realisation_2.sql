/*
Calculating the consumer loyalty index
Yura generates another idea: he suggests checking whether viewer satisfaction is the same on all devices. To do this, he asks to check the NPS by device type.
Calculate the NPS by device type. Round the result to two decimal places using the ROUND function
*/
SELECT app_id,
       SUM(CASE WHEN nps_score <= 6 THEN votes ELSE 0 END) AS detractors,
       SUM(CASE WHEN nps_score >= 9 THEN votes ELSE 0 END) AS promoters,
       SUM(votes) AS total,
       ROUND(
           SUM(CASE WHEN nps_score >= 9 THEN votes ELSE 0 END) / SUM(votes) - 
           SUM(CASE WHEN nps_score <= 6 THEN votes ELSE 0 END) / SUM(votes),
           2
       ) AS nps
FROM (
    SELECT app_id,
           CAST(object_value AS FLOAT) AS nps_score,
           COUNT(DISTINCT user_id) AS votes
    FROM events_log
    WHERE name = 'npsDialogVote'
    GROUP BY app_id, CAST(object_value AS FLOAT)
) nps
GROUP BY app_id
ORDER BY nps DESC;
