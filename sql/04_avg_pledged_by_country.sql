-- Query 4: Top 10 countries by total USD pledged
-- Filters to completed campaigns only (successful + failed) to avoid inflating figures
-- with still-live campaigns that haven't finished funding.

SELECT
    country,
    COUNT(*)                        AS total_campaigns,
    ROUND(AVG(usd_pledged), 0)      AS avg_pledged_usd,
    ROUND(SUM(usd_pledged) / 1e6, 2) AS total_pledged_mln_usd
FROM projects
WHERE state IN ('successful', 'failed')
  AND usd_pledged IS NOT NULL
GROUP BY country
ORDER BY total_pledged_mln_usd DESC
LIMIT 10;
