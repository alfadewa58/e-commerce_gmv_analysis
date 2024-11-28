-- ** GMV Analysis Based on Buyer Country ** --
-- Identifying countries with the highest contribution to GMV can help prioritize marketing efforts and regional expansion strategies.
-- The average GMV per country provides insights into purchasing power in each country.

SELECT 
    u.country,
    COUNT(DISTINCT o.buyerid) AS total_buyers,
    SUM(o.gmv) AS total_gmv,
    ROUND(AVG(o.gmv),2) AS avg_gmv
FROM `e_commerce.order_tab` o
JOIN `e_commerce.user_tab` u ON o.buyerid = u.buyerid
GROUP BY u.country
ORDER BY total_gmv DESC;


-- ** GMV Analysis Based on Store Performance ** --
-- Identifying the relationship between digital marketing metrics (such as total clicks) and revenue outcomes can enhance store optimization strategies.
-- Helps pinpoint high-performing stores that can serve as benchmarks for others.

SELECT
    o.shopid,
    SUM(o.gmv) AS total_gmv,
    ROUND(AVG(p.total_clicks),2) AS avg_total_clicks,
    ROUND(AVG(p.Item_views),2) AS avg_total_views,
    ROUND(AVG(p.impressions),2) AS avg_impressions
FROM `e_commerce.order_tab` o
    JOIN `personalproject-443012.e_commerce.performance_tab` p
    ON o.shopid = p.shopid
GROUP BY 1
ORDER BY 2 ASC;

-- ** GMV Trends Based on Time ** --
-- Understanding revenue fluctuations over time helps in planning promotions, managing inventory, and devising operational strategies.
-- Assists in preparing for peak sales periods or analyzing the impact of specific promotional periods.

SELECT 
    EXTRACT(MONTH FROM order_time) AS order_month,
    SUM(o.gmv) AS total_gmv,
    ROUND(AVG(o.gmv),2) AS avg_gmv,
    ROUND(COUNT(o.orderid),2) AS total_orders
FROM `e_commerce.order_tab` o
GROUP BY order_month
ORDER BY order_month ASC;


-- ** GMV Contribution Per Store ** --
-- Provides insights into underperforming stores that may need intervention to boost performance.
-- Enables an evaluation of individual store performance based on their GMV contribution.

SELECT
    shopid,
    COUNT(orderid) AS total_orders,
    SUM(gmv) AS total_gmv,
    ROUND(AVG(gmv),2) AS avg_gmv,
    CASE
        WHEN SUM(gmv) > 2000 THEN 'High'
        WHEN SUM(gmv) BETWEEN 1000 AND 2000 THEN 'Moderate'
        ELSE 'Low'
    END AS performance 
FROM `e_commerce.order_tab`
GROUP BY 1
ORDER BY 3 DESC;


-- ** Active Buyer Analysis ** --
-- Identifying top-tier buyers (e.g., the top 20% contributing most to GMV) helps in designing loyalty programs or retention strategies.
-- Evaluates whether GMV contribution is concentrated among a few buyers or distributed broadly.

WITH buyer_gmv AS (
    SELECT
        buyerid,
        SUM(gmv) AS total_gmv
    FROM `e_commerce.order_tab`
    GROUP BY 1
),
total_gmv_cte AS (
    SELECT
        SUM(buyer_gmv.total_gmv) as overall_gmv
    FROM buyer_gmv
)

SELECT
    b.buyerid,
    b.total_gmv,
    ROUND((b.total_gmv / t.overall_gmv)*100,2) AS contribution
FROM buyer_gmv b
    CROSS JOIN total_gmv_cte t
ORDER BY 3 ASC
LIMIT 10;

-- ** The Relationship Between Buyer Registration, GMV, and Account Age Categories ** 
-- This query will provide insights into how the timing of buyer registrations within 2020 influenced their contribution to GMV

SELECT 
    CASE 
        WHEN EXTRACT(QUARTER FROM DATE(u.register_date)) = 1 THEN 'Q1 (Jan-Mar)'
        WHEN EXTRACT(QUARTER FROM DATE(u.register_date)) = 2 THEN 'Q2 (Apr-Jun)'
        WHEN EXTRACT(QUARTER FROM DATE(u.register_date)) = 3 THEN 'Q3 (Jul-Sep)'
        ELSE 'Q4 (Oct-Dec)'
    END AS registration_quarter_label,
    COUNT(DISTINCT o.buyerid) AS total_buyers,
    SUM(o.gmv) AS total_gmv,
    AVG(o.gmv) AS avg_gmv,
FROM `e_commerce.user_tab` u
JOIN `e_commerce.order_tab` o ON u.buyerid = o.buyerid
WHERE EXTRACT(YEAR FROM DATE(u.register_date)) = 2020
GROUP BY registration_quarter_label;