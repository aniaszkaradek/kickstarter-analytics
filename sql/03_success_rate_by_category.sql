-- Query 3: Success rate by main category
-- JOINs the projects table to the categories lookup table.
-- Only counts campaigns that reached a definitive outcome (successful or failed).

SELECT
    c.main_category,
    COUNT(*)                                                        AS total_campaigns,
    SUM(CASE WHEN p.state = 'successful' THEN 1 ELSE 0 END)        AS successful,
    SUM(CASE WHEN p.state = 'failed'     THEN 1 ELSE 0 END)        AS failed,
    ROUND(
        SUM(CASE WHEN p.state = 'successful' THEN 1.0 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN p.state IN ('successful','failed') THEN 1 ELSE 0 END), 0)
        * 100,
    1)                                                              AS success_rate_pct,
    ROUND(AVG(p.usd_pledged), 0)                                    AS avg_pledged_usd
FROM projects p
JOIN categories c ON p.category_id = c.category_id
WHERE p.state IN ('successful', 'failed')
GROUP BY c.main_category
ORDER BY success_rate_pct DESC;
