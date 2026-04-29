-- Step 2: Create a clean projects table from the raw import
-- Removes nulls on key columns, strips duplicates, and standardises state values.
-- Also adds category_id by JOINing to the categories lookup table.

DROP TABLE IF EXISTS projects;

CREATE TABLE projects AS
SELECT
    CAST(p.ID              AS INTEGER)  AS project_id,
    p.name                              AS project_name,
    c.category_id,
    p.main_category,
    p.category,
    p.country,
    p.currency,
    p.deadline,
    p.launched,
    CAST(p.goal            AS REAL)     AS goal,
    CAST(p.pledged         AS REAL)     AS pledged,
    CAST(p.usd_pledged_real AS REAL)    AS usd_pledged,
    CAST(p.usd_goal_real   AS REAL)     AS usd_goal,
    CAST(p.backers         AS INTEGER)  AS backers,
    CASE
        WHEN p.state IN ('successful','failed','canceled','live','suspended')
        THEN p.state
        ELSE 'other'
    END                                 AS state
FROM projects_raw p
JOIN categories c ON p.main_category = c.main_category
WHERE
    p.ID            IS NOT NULL
    AND p.name      IS NOT NULL
    AND p.state     IS NOT NULL
    AND p.launched  IS NOT NULL
    AND p.deadline  IS NOT NULL
    -- launched must be before deadline
    AND p.launched < p.deadline
    -- deduplicate: keep only the first occurrence of each project ID
    AND p.rowid IN (
        SELECT MIN(rowid)
        FROM projects_raw
        GROUP BY ID
    );

-- Post-cleaning row count by state
SELECT state, COUNT(*) AS total
FROM projects
GROUP BY state
ORDER BY total DESC;
