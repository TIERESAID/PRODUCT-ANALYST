/*
Conversion to purchases
Following Yura, Yulia, a marketer, runs into your office and asks you to urgently look at the conversion rate to ad monetization by channel for the first 
5 days of Lifetime. She has a theory that organic users interact with in-app ads less often than non-organic users.
Ad views aren't exactly purchases, but your company earns revenue from each ad view a user performs in an online movie theater.
Calculate the conversion to ads_rev (paid ad views) event of the first five days of Lifetime by user engagement channel.
*/

WITH installs AS (
    SELECT
        utm_source,
        COUNT(DISTINCT user_id) AS new_dau
    FROM events_log
    WHERE
        log_date BETWEEN '2022-11-30' AND '2022-12-08'
        AND install_date = log_date
    GROUP BY utm_source
),
orders AS (
    SELECT
        utm_source,
        lifetime,
        COUNT(DISTINCT user_id) as conversions
    FROM (
        SELECT
            user_id,
            MIN(utm_source) AS utm_source,
            MIN(install_date) AS install_date,
            MIN(log_date) AS order_date,
            MIN(log_date) - MIN(install_date) AS lifetime
        FROM events_log
        WHERE
            name = 'ads_rev'
            AND install_date BETWEEN '2022-11-30' AND '2022-12-08'
            AND log_date BETWEEN TO_DATE('2022-11-30', 'YYYY-MM-DD') 
            AND TO_DATE('2022-12-08', 'YYYY-MM-DD') + INTERVAL '5 day'
        GROUP BY user_id
    ) c
    GROUP BY utm_source, lifetime
),
conv AS (
    SELECT
        i.utm_source,
        i.new_dau,
        o.lifetime,
        o.conversions
    FROM installs i
    LEFT JOIN orders o ON i.utm_source = o.utm_source
)
SELECT
    utm_source,
    lifetime,
    conversions,
    CAST(SUM(conversions) OVER (PARTITION BY utm_source ORDER BY lifetime) AS INT) AS cumulative_conversions,
    CAST(new_dau AS INT) AS new_dau,
    CAST(SUM(conversions) OVER (PARTITION BY utm_source ORDER BY lifetime) AS FLOAT) / CAST(new_dau AS FLOAT) AS conversion_rate
FROM conv
WHERE lifetime <= 5;
