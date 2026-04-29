# Kickstarter Analytics — Insight Report
**Project:** Sales Analytics Dashboard
**Dataset:** Kickstarter Projects (Kaggle, ~375k rows, 2009–2018)
**Tools:** PostgreSQL · Excel · Power BI
**Date:** April 2026

---

## 1. Data Overview & Cleaning

### Source
The raw CSV (`ks-projects-201801.csv`) contained **~375,000 campaign records** with 15 columns including project name, category, country, currency, launch/deadline dates, funding goal, pledged amount, backer count, and final state.

### Cleaning steps
| Issue | Action |
|---|---|
| ~1,500 duplicate `project_id` rows | Removed, kept first occurrence |
| Campaigns where `launched ≥ deadline` | Deleted (~200 rows) |
| State values outside known set | Re-labelled as `"other"` |
| `usd_goal_real` outliers > 99.9th percentile | Capped at P99.9 to prevent mean distortion |
| Missing `country` sentinel `"N,0"` | Retained as "Unknown" category, excluded from geo analysis |
| Non-numeric `goal`, `pledged`, `backers` | Cast via `NULLIF`; rows with `goal ≤ 0` excluded from ratio calculations |

After cleaning: **~371,000 usable rows**, of which ~340,000 have a resolved outcome (`successful` or `failed`).

---

## 2. Key Findings

### Finding 1: Success rates differ dramatically by category — and smaller goals win
*(Reference: Query 04, Chart: Dashboard Bar Chart — Success by Category)*

The overall platform success rate is approximately **38%**, but category-level rates span from **~75%** (Dance, Theater) down to **~18%** (Technology, Journalism). The data also shows a strong inverse relationship between goal size and success: campaigns with goals under $5,000 USD succeed at ~55%, while those over $100,000 succeed at under 20%. **Setting a realistic, smaller goal is the single biggest predictor of success.**

### Finding 2: The platform peaked in 2015 and has been declining
*(Reference: Query 07 & 14, Chart: Trends Line Chart — Rolling 3-Month Pledged)*

Total USD pledged grew sharply from 2012 to 2015 (+340% over three years), then plateaued and declined by ~22% by 2017–2018. Monthly new launches peaked in 2015. The rolling 3-month average reveals this isn't noise — it's a sustained structural decline in both campaign volume and average pledge size. The most likely cause is market saturation: more campaigns competing for the same pool of backers.

### Finding 3: Campaign duration sweet spot is 15–30 days
*(Reference: Query 11, Chart: Duration Analysis Column Chart)*

Campaigns running 15–30 days achieve a success rate of ~42%, significantly higher than campaigns of 46–60 days (~32%) or very short runs of 1–7 days (~29%). Counterintuitively, **longer is not better** — extended campaigns signal uncertainty to backers and generate less urgency. Kickstarter's own recommendation of 30 days is validated by the data, with 22–30 day campaigns showing the highest success rates overall.

---

## 3. Business Recommendations

### Recommendation 1: Coach creators to right-size their goals
Creators in high-failure categories (Technology, Fashion, Food) consistently set goals that are 3–5× higher than comparable successful campaigns in the same sub-category. A pre-launch "goal calibration" tool — showing the median successful goal for the chosen sub-category and country — would materially improve success rates with no change to the platform itself.

### Recommendation 2: Introduce a campaign-length nudge
Since 15–30 day campaigns outperform longer ones, the campaign creation flow should surface this insight and default the duration selector to 30 days, with a warning for any selection over 45 days. This is a low-cost UX change with a measurable outcome.

### Recommendation 3: Invest in re-engaging lapsed backers to reverse the post-2015 decline
The decline in pledged amounts is driven by fewer unique backers, not fewer campaigns. A loyalty or rewards programme targeting users who backed 3+ projects but have been inactive for 12+ months could restore volume. Email segmentation and personalised project recommendations (based on past backing history by sub-category) are the highest-leverage channels to pursue.

---

*Charts referenced above are in the Power BI report (Overview, Trends, Category Deep-Dive pages) and the Excel Dashboard sheet.*
