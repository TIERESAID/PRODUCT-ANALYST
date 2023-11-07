/*
Calculating ROI without time breakdown
Prepare a query that will result in ROI data for the first 7 days of a user's life for all engagement channels. For the analysis, take users with an engagement date up to and including '2021-06-26'.
*/

-- Calculate the first registration date, source, and user_id for each user
WITH first_values AS (
    SELECT
        user_id,
        first_date,
        first_source
    FROM user_registration
),

-- Calculate the Customer Acquisition Cost (CAC) for each source and date
cac AS (
    SELECT
        source,
        first_date,
        cac
    FROM acquisition_costs
),

-- Create user profiles with user information and CAC
profiles AS (
    SELECT
        f.user_id,
        f.first_date,
        f.first_source,
        c.cac
    FROM first_values f
    LEFT JOIN cac c ON c.source = f.first_source AND c.first_date = f.first_date
),

-- Group users into cohorts and calculate cohort size and ad cost
cohorts AS (
    SELECT
        first_source,
        COUNT(DISTINCT user_id) AS cohort_size,
        SUM(cac) AS ad_cost
    FROM profiles
    GROUP BY first_source
    ORDER BY first_source
),

-- Analyze user orders and calculate lifetime and revenue
orders AS (
    SELECT
        o.order_id,
        p.first_date,
        p.first_source,
        o.order_date,
        (o.order_date - p.first_date) AS lifetime,
        (o.revenue * o.commission - o.delivery) AS revenue
    FROM profiles p
    LEFT JOIN order_events o ON p.user_id = o.user_id
    WHERE o.event = 'order'
        AND o.user_id IS NOT NULL
        AND o.order_date <= '2021-07-02'
        AND p.first_date <= '2021-06-26'
)
-- The rest of your query goes here

