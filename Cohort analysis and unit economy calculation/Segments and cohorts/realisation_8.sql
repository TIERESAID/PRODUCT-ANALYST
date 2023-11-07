
/*
Calculating ROI without time breakdown
Prepare a query that will result in ROI data for the first 7 days of a user's life for all engagement channels. For the analysis, take users with an engagement date up to and including '2021-06-26'.
*/
-- Calculate ROI with a breakdown over time
WITH roi AS (
    SELECT
        c.first_source,
        c.first_date,
        MAX(c.cohort_size) AS cohort_size,
        MAX(c.ad_cost) AS ad_cost,
        
        -- Replace missing revenue and lifetime with 0
        CASE WHEN SUM(o.rev) > 0 THEN SUM(o.rev) ELSE 0 END AS rev,
        CASE WHEN o.lifetime > 0 THEN o.lifetime ELSE 0 END AS lifetime,
        
        SUM(o.rev)::FLOAT / MAX(c.ad_cost)::FLOAT AS roi
    FROM cohorts c
    LEFT JOIN orders o ON o.first_source = c.first_source
                        AND o.first_date = c.first_date
    GROUP BY c.first_source, c.first_date, o.lifetime
)

-- Format the output by summarizing ROI values in different lifetime segments
SELECT
    first_source,
    first_date,
    SUM(rev) AS total_revenue,
    MAX(ad_cost) AS total_ad_cost,
    MAX(cohort_size) AS cohort_size,
    MAX(ad_cost) / MAX(cohort_size) AS cac,
    SUM(CASE WHEN lifetime <= 6 THEN roi ELSE 0 END) AS roi_d7
FROM roi
WHERE (first_source = 'Source_B' AND first_date <= '2021-05-07') OR (first_source = 'Source_C' AND first_date >= '2021-06-20')
GROUP BY first_source, first_date
ORDER BY first_source, first_date;
