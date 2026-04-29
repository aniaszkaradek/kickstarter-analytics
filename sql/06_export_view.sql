-- Step 6: Create a view for Excel export
-- Combines projects and categories into one flat table ready to export as CSV.
-- In DB Browser: File > Export > Table(s) as CSV File, select "vw_export"

DROP VIEW IF EXISTS vw_export;

CREATE VIEW vw_export AS
SELECT
    p.project_id,
    p.project_name,
    c.main_category,
    p.category,
    p.country,
    p.currency,
    p.state,
    p.backers,
    p.launched,
    p.deadline,
    CAST(strftime('%Y', p.launched) AS INTEGER)     AS launch_year,
    CAST(strftime('%m', p.launched) AS INTEGER)     AS launch_month,
    p.usd_goal,
    p.usd_pledged,
    ROUND(p.usd_pledged / NULLIF(p.usd_goal, 0), 4) AS funding_ratio,
    CASE WHEN p.usd_pledged >= p.usd_goal THEN 'Funded' ELSE 'Not Funded' END AS funded_flag,
    ROUND(p.usd_pledged / NULLIF(p.backers, 0), 2)  AS pledge_per_backer_usd
FROM projects p
JOIN categories c ON p.category_id = c.category_id;

-- Preview
SELECT * FROM vw_export LIMIT 5;
