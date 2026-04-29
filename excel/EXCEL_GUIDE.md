# Excel Dashboard — Step-by-Step Guide

## Source file

Import `export_projects.csv` (exported from the `vw_export` view in DB Browser).

---

## Step 1 — Import the CSV with Power Query

Power Query cleans the data before it lands in your spreadsheet.

1. Open a new Excel workbook
2. **Data → Get Data → From Text/CSV**
3. Select `export_projects.csv`
4. Click **Transform Data** (this opens the Power Query Editor)

In Power Query Editor, apply these 3 steps in order:

**Step A — Remove duplicates**  
Home → Remove Rows → Remove Duplicates  
(removes any row where `project_id` appears more than once)

**Step B — Fix date format**  
Click the `launched` column header → Transform → Data Type → Date  
Do the same for the `deadline` column

**Step C — Filter out blank rows**  
Home → Remove Rows → Remove Blank Rows

5. Click **Close & Load** — this creates a sheet called `export_projects`
6. Select the loaded data and press **Ctrl+T** to convert it to a Table — name it `tblProjects`

---

## Step 2 — Add 3 formulas

Create a new sheet called `Summary`. In this sheet, build a small reference table:

| Cell | Label | Formula |
|---|---|---|
| A1 | Category | (type a category name, e.g. `Music`) |
| B1 | Total pledged for category | `=SUMIF(tblProjects[main_category],A1,tblProjects[usd_pledged])` |
| A2 | State to count | (type `successful`) |
| B2 | Count of that state | `=COUNTIF(tblProjects[state],A2)` |
| A3 | Category to look up | (type a category name) |
| B3 | Success rate via INDEX-MATCH | *(see below)* |

For B3, use INDEX-MATCH to pull the success rate from the pivot table you will create in Step 3:
```
=INDEX(tblPivotCategory[success_rate_pct],
       MATCH(A3, tblPivotCategory[main_category], 0))
```
*(Create tblPivotCategory in Step 3 first, then come back and enter this formula)*

---

## Step 3 — Build 2 pivot tables

Create a new sheet called `Pivots`.

### Pivot Table 1: Campaigns by category with success rate

1. Insert → PivotTable → select `tblProjects` → place on the `Pivots` sheet
2. Configure:
   - **Rows:** `main_category`
   - **Values:** Count of `project_id` (rename to "Total Campaigns")
   - **Values:** Count of `project_id` again, but add a calculated field or use a helper column for success rate (see below)
3. To get success rate: add a second pivot on the same sheet using `state` as a filter and `main_category` as rows — or use COUNTIF formulas next to the pivot:
   ```
   =COUNTIFS(tblProjects[main_category], A5, tblProjects[state], "successful")
   / COUNTIF(tblProjects[main_category], A5)
   ```
   Format the result column as Percentage.
4. Convert the pivot result range to a Table named `tblPivotCategory` (for the INDEX-MATCH in Step 2)

### Pivot Table 2: Top 10 countries by total pledged

1. Insert → PivotTable → select `tblProjects` → place below Pivot 1 on the same sheet
2. Configure:
   - **Rows:** `country`
   - **Values:** Sum of `usd_pledged` (format as Number, 0 decimal places)
3. Sort descending by sum of `usd_pledged`
4. Right-click the row labels → Filter → Top 10

---

## Step 4 — Build the dashboard

Create a new sheet called `Dashboard`.

### Charts

**Chart 1 — Bar chart: success rate by category**  
- Select the category and success_rate columns from Pivot 1
- Insert → Bar Chart → Clustered Bar
- Title: "Success Rate by Category"

**Chart 2 — Line chart: campaigns launched over time**  
- Create a small pivot or helper table on the Pivots sheet:
  - Rows: `launch_year`, Values: Count of `project_id`
- Select that range → Insert → Line Chart
- Title: "Campaigns Launched by Year"

**Chart 3 — Bar chart: top 10 countries by total pledged**  
- Use Pivot 2 as the source
- Insert → Bar Chart → Clustered Bar
- Title: "Top 10 Countries by Total Pledged (USD)"

Copy all three charts onto the `Dashboard` sheet. Arrange them so they fit on one screen without scrolling.

### Slicers

1. Click on Pivot 1 → PivotTable Analyze → Insert Slicer
2. Add a slicer for `main_category`
3. Add a slicer for `launch_year`
4. Position the slicers on the Dashboard sheet
5. Right-click each slicer → Report Connections → connect it to all pivots so filtering one updates all charts

### Conditional formatting

In the category success-rate column (on the Pivots sheet or a summary area):
1. Select the success rate values
2. Home → Conditional Formatting → New Rule → Format cells that contain a value less than 0.3 → fill red font
3. Add another rule: greater than 0.5 → fill green font

This visually flags which categories over- or underperform.

---

## Step 5 — Scenario tab

Create a new sheet called `Scenario`.

Build this input table:

| Cell | Label | Value |
|---|---|---|
| B3 | Current overall success rate | `=COUNTIF(tblProjects[state],"successful")/COUNTA(tblProjects[project_id])` |
| B4 | Scenario: % drop in success rate | `-10%` (type this manually — user changes it) |
| B5 | Scenario success rate | `=B3*(1+B4)` |
| B6 | Total campaigns in dataset | `=COUNTA(tblProjects[project_id])` |
| B7 | Projected successful campaigns | `=B6*B5` |
| B8 | Current successful campaigns | `=COUNTIF(tblProjects[state],"successful")` |
| B9 | Avg pledge (successful only) | `=AVERAGEIF(tblProjects[state],"successful",tblProjects[usd_pledged])` |
| B10 | Revenue impact (USD) | `=(B7-B8)*B9` |

Add a small chart next to this table:
- In column D, list 5 drop scenarios: -5%, -10%, -15%, -20%, -30%
- In column E, calculate revenue impact for each using the same formula as B10 but referencing column D
- Select columns D and E → Insert → Bar Chart
- Title: "Revenue Impact by Success Rate Drop Scenario"

When B4 changes, B5 through B10 and the chart update automatically.

---

## Step 6 — Written summary (text box inside Excel or separate Word doc)

Add a text box on the Dashboard sheet (Insert → Text Box) with a half-page summary:

**What the data is:**  
The Kickstarter Projects dataset covers ~375,000 crowdfunding campaigns launched between 2009 and 2018. Each row is one campaign with its category, country, funding goal, amount pledged, and final outcome.

**3 findings (fill in from your actual query results):**  
1. "Campaigns in the [X] category have the highest average pledge at $[Y]"
2. "The platform peaked in [year] with [N] campaigns launched — success rates declined from [X]% to [Y]% by 2017"
3. "The top 10 countries account for [X]% of all USD pledged; the US alone represents [Y]%"

**2 recommendations:**  
1. (Based on your findings — e.g. "Campaigns should target the 22–30 day duration window which correlates with the highest success rates")
2. (e.g. "Categories with <30% success rates may benefit from lower funding goals to improve completion likelihood")
