-- Step 1: Create the categories lookup table
-- This is a manually-created dimension table that we JOIN to the main projects table.
-- Run this AFTER importing the CSV as "projects_raw" in DB Browser.

DROP TABLE IF EXISTS categories;

CREATE TABLE categories (
    category_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    main_category TEXT NOT NULL
);

-- Populate with every distinct main_category from the imported data
INSERT INTO categories (main_category)
SELECT DISTINCT main_category
FROM projects_raw
WHERE main_category IS NOT NULL
ORDER BY main_category;

-- Confirm what was inserted
SELECT * FROM categories ORDER BY category_id;
