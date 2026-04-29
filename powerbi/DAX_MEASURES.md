# Power BI — Data Model & DAX Measures

## Data model

### Tables & relationships
| Table | Source | Grain |
|---|---|---|
| `Projects` | `export_project_detail.csv` | 1 row per project |
| `Categories` | `export_category_summary.csv` | 1 row per main_category |
| `DateTable` | Auto-generated or M query | 1 row per calendar day |

**Relationships:**
- `Projects[main_category]` → `Categories[main_category]` (Many-to-One)
- `Projects[launched]` → `DateTable[Date]` (Many-to-One)

### DateTable (M query — paste into a blank query)
```m
= List.Dates(#date(2009,1,1), 365*10, #duration(1,0,0,0))
```
Then add columns: Year, Month, MonthName, Quarter, YearMonth.

---

## DAX Measures

Paste each measure into the Measures table in Power BI Desktop.

---

### 1. Success Rate
```dax
Success Rate =
DIVIDE(
    CALCULATE(COUNTROWS(Projects), Projects[state] = "successful"),
    CALCULATE(COUNTROWS(Projects), Projects[state] IN {"successful", "failed"}),
    0
)
```
Format: Percentage, 2 decimal places.

---

### 2. Total Pledged vs Goal Ratio
```dax
Funding Ratio =
DIVIDE(
    SUM(Projects[pledged_usd]),
    SUM(Projects[goal_usd]),
    0
)
```
Format: Decimal number, 2 places.

```dax
Total Pledged USD =
SUM(Projects[pledged_usd])
```

```dax
Total Goal USD =
SUM(Projects[goal_usd])
```

---

### 3. Rolling 3-Month Average Pledged
```dax
Rolling 3M Avg Pledged =
AVERAGEX(
    DATESINPERIOD(
        DateTable[Date],
        LASTDATE(DateTable[Date]),
        -3,
        MONTH
    ),
    CALCULATE(SUM(Projects[pledged_usd]))
)
```

---

### 4. Year-over-Year Change in Pledged
```dax
Pledged YoY % =
VAR CurrentYear   = SUM(Projects[pledged_usd])
VAR PreviousYear  =
    CALCULATE(
        SUM(Projects[pledged_usd]),
        SAMEPERIODLASTYEAR(DateTable[Date])
    )
RETURN
    DIVIDE(CurrentYear - PreviousYear, PreviousYear, BLANK())
```
Format: Percentage, 1 decimal place.

```dax
Pledged YoY Change =
SUM(Projects[pledged_usd]) -
CALCULATE(
    SUM(Projects[pledged_usd]),
    SAMEPERIODLASTYEAR(DateTable[Date])
)
```

---

### 5. Campaign Count by Status
```dax
Campaigns Successful =
CALCULATE(COUNTROWS(Projects), Projects[state] = "successful")

Campaigns Failed =
CALCULATE(COUNTROWS(Projects), Projects[state] = "failed")

Campaigns Canceled =
CALCULATE(COUNTROWS(Projects), Projects[state] = "canceled")

Total Campaigns =
COUNTROWS(Projects)
```

---

### 6. Average Pledge Per Backer (bonus)
```dax
Avg Pledge Per Backer =
DIVIDE(
    SUM(Projects[pledged_usd]),
    SUM(Projects[backers]),
    0
)
```

### 7. % of Total Pledged (for category share)
```dax
% of Total Pledged =
DIVIDE(
    SUM(Projects[pledged_usd]),
    CALCULATE(SUM(Projects[pledged_usd]), ALL(Projects)),
    0
)
```

---

## Report pages

### Page 1: Overview
| Visual | Fields | Notes |
|---|---|---|
| Card KPI | `Total Campaigns` | |
| Card KPI | `Success Rate` | conditional green/red |
| Card KPI | `Total Pledged USD` | format as $M |
| Card KPI | `Avg Pledge Per Backer` | |
| Bar chart | Axis: `main_category`, Value: `Success Rate` | sorted desc |
| Donut chart | Legend: `state`, Value: `Total Campaigns` | |
| Slicer | `DateTable[Year]` | |
| Slicer | `Categories[main_category]` | |

### Page 2: Trends
| Visual | Fields | Notes |
|---|---|---|
| Line chart | X-axis: `DateTable[YearMonth]`, Values: `Rolling 3M Avg Pledged`, `Total Pledged USD` | dual axis |
| Line chart | X-axis: `DateTable[YearMonth]`, Value: `Success Rate` | |
| Column chart | X-axis: `DateTable[Year]`, Value: `Pledged YoY %` | color by +/- |
| Matrix | Rows: `Year`, Columns: `main_category`, Value: `Success Rate` | heatmap format |
| Slicer | `Categories[main_category]` | multi-select |

### Page 3: Category Deep-Dive
| Visual | Fields | Notes |
|---|---|---|
| Bar chart | `category_name`, `Total Campaigns` | top 20 sub-categories |
| Scatter plot | X: `Avg Pledge Per Backer`, Y: `Success Rate`, Size: `Total Campaigns`, Legend: `main_category` | |
| Table/Matrix | `main_category`, `category_name`, `Success Rate`, `Funding Ratio`, `Avg Pledge Per Backer` | conditional formatting |
| Slicer | `main_category` | single-select |
| Card | `Funding Ratio` | updates with slicer |

---

## Publishing to Power BI Service
1. File → Publish → Publish to Power BI
2. Choose your workspace
3. In Power BI Service: open the report → Share → copy link
4. Paste the shareable link in your README
