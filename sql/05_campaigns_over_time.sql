-- Query 5: Campaign volume and success rate by launch year
-- Uses strftime() to extract the year from the launched timestamp.
-- Helps identify platform growth and decline trends.

SELECT
    strftime('%Y', launched)                                            AS launch_year,
    COUNT(*)                                                            AS total_campaigns,
    SUM(CASE WHEN state = 'successful' THEN 1 ELSE 0 END)              AS successful,
    ROUND(
        SUM(CASE WHEN state = 'successful' THEN 1.0 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN state IN ('successful','failed') THEN 1 ELSE 0 END), 0)
        * 100,
    1)                                                                  AS success_rate_pct,
    ROUND(SUM(usd_pledged) / 1e6, 2)                                    AS total_pledged_mln_usd
FROM projects
WHERE state IN ('successful', 'failed')
  AND launched IS NOT NULL
GROUP BY launch_year
ORDER BY launch_year;
