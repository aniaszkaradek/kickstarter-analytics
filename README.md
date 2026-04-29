# Kickstarter Sales Analytics Dashboard

A portfolio project built on the Kickstarter Projects dataset from Kaggle, covering SQL data cleaning and analysis, and Excel dashboarding.

## Dataset

**Source:** [Kickstarter Projects — Kaggle](https://www.kaggle.com/datasets/kemical/kickstarter-projects)  
**File:** `ks-projects-201801.csv` (~375k rows)  
**Period:** 2009–2018

Place the CSV in the `data/` folder before running the SQL scripts.

---

## Tools

| Tool | Purpose |
|---|---|
| DB Browser for SQLite | Database, all SQL queries and views |
| Microsoft Excel | Power Query, pivot tables, dashboard, scenario analysis |

---

## Folder structure

```
/
├── data/                           — raw CSV (not committed to git)
├── sql/
│   ├── 01_create_categories.sql   — categories lookup table
│   ├── 02_clean_data.sql          — clean projects table (dedup, nulls, state normalisation)
│   ├── 03_success_rate_by_category.sql
│   ├── 04_avg_pledged_by_country.sql
│   ├── 05_campaigns_over_time.sql
│   └── 06_export_view.sql         — vw_export view → CSV for Excel
├── excel/
│   └── EXCEL_GUIDE.md
└── README.md
```

---

## How to run

See `SETUP.md` for the full step-by-step walkthrough. In brief:

1. Install DB Browser for SQLite (https://sqlitebrowser.org/dl/)
2. Create a new database (`kickstarter.db`)
3. Import `data/ks-projects-201801.csv` as table `projects_raw`
4. Run the SQL scripts in order (01 → 02 → 03 → 04 → 05 → 06)
5. Export `vw_export` as `export_projects.csv`
6. Open in Excel following `excel/EXCEL_GUIDE.md`

---

## Key findings

1. **Success rates range from ~18% to ~75% by category** — Dance and Theater lead; Technology and Journalism trail significantly.
2. **The platform peaked around 2015** — total pledged declined in subsequent years, driven by backer saturation rather than fewer campaigns.
3. **The US dominates total pledged** — the top 10 countries account for the vast majority of all funding on the platform.

---

Ania — Data Analytics Portfolio Project, April 2026
