# COVID-19 Data Exploration — Guided Project + Personal Extensions

## Project status
**Prepared portfolio starter.** The SQL queries and documentation are included, and the attached Excel extracts were independently analyzed to produce the result tables in `data/` and the workbook in `excel/`. The T-SQL script still needs to be executed in your own SQL Server environment to verify that SQL Server returns matching results.

## Overview
Explore reported COVID-19 cases, deaths, vaccination reporting, and country-level indicators using SQL Server (T-SQL), Excel, and Tableau Public.


**Data period:** 1 January 2020 to 30 April 2021 in the supplied files.

## Business questions
1. Which month had the highest reported new cases and new deaths in India?
2. Why can cumulative vaccine doses per 100 people exceed 100, and how does this differ from the share of people who received at least one dose?
3. How do average reported deaths per million and average median age vary across GDP-per-capita buckets?
4. Which countries with populations above one million had the highest reported deaths per million?

## Tools
- SQL Server / T-SQL
- Microsoft Excel
- Tableau Public (dashboard build is a suggested next step)
- GitHub for version control and project presentation

## Data handling and approach
- Excluded records where `continent IS NULL` from country-level comparisons because they include aggregates such as World and regional totals.
- Used `TRY_CAST` for potentially text-stored numeric fields in the T-SQL queries.
- Used joins, CTEs, aggregate functions, `CASE`, and window functions.
- For country-level cumulative metrics, used the latest available non-null record where appropriate.
- Vaccine doses and people vaccinated are treated as different measures.
- GDP buckets: Low < 5,000; Lower-middle 5,000 to < 15,000; Upper-middle 15,000 to 35,000; High > 35,000. Missing GDP is labelled `Unknown GDP`.

## Findings from the supplied extracts

> These are computed from the uploaded Excel data for an initial result check. They are not a claim that the SQL script has already been run in SQL Server. Run the SQL and confirm parity before presenting the findings as SQL query outputs.

### 1. India monthly trend
- Peak month by reported new cases: **April 2021**, with **6,943,304** reported new cases.
- Peak month by reported new deaths: **April 2021**, with **48,926** reported new deaths.
- The supplied data ends on 30 April 2021, so April 2021 is a partial historical snapshot only in the sense that the dataset stops at that date, not a complete current trend.

### 2. Vaccine doses vs. people
- Israel in the supplied period: approximately **121.3 reported doses per 100 people** and **62.4%** of the population reported as having received at least one dose (latest non-null report: 2021-04-30).
- Doses per 100 people can exceed 100 because the same person can receive multiple doses. The people-vaccinated metric is the more appropriate measure for the share who received at least one dose.
- Source reporting can have anomalies. For example, some small locations can report a people-vaccinated count above the population estimate; do not silently interpret that as literal population coverage above 100%.

### 3. GDP-per-capita buckets
- Highest simple average reported deaths per million in these extracts: **Upper-middle**, about **923.4 deaths per million**.
- Highest average median age: **High**, about **39.9 years**.
- These are descriptive comparisons, not evidence that GDP or age bucket caused the death-rate differences. Countries differ in testing, reporting, population structure, and many other factors.

### 4. Top 10 deaths per million
- Highest-ranked country in the population > 1 million filter: **Hungary**, about **2850.8 reported deaths per million** as of its latest available record in the extract.
- See `data/top10_deaths_per_million.csv` for the full ranked output.
- The ranking is sensitive to reporting differences and the historical cutoff date.

## Excel deliverable
Open `excel/COVID_Analysis_Results.xlsx`. It contains:
- `India_Monthly`: monthly India case/death totals with peak ranks.
- `Vaccination`: country-level doses and people-vaccinated comparison.
- `Income_Buckets`: average metrics by GDP bucket.
- `Top10_Deaths`: highest reported deaths per million with population > 1 million.
- `Continent_Deaths`: sum of latest reported country death counts by continent (not a sum of daily cumulative rows).
- `India_USA_Monthly`: monthly cases for India and the United States, suitable for a line chart.
- `Dashboard_Charts`: Excel charts using the calculated output tables.

## Suggested Tableau Public dashboard
1. **India monthly trend:** line chart of monthly new cases and new deaths; optionally use separate charts or dual axes because the scales differ.
2. **Doses vs people:** compare doses per 100 people and people vaccinated % for selected countries. Label both measures clearly.
3. **Top 10 deaths per million:** ranked horizontal bar chart with the population > 1 million filter applied.

Add a dashboard title, data source, date cutoff (30 April 2021), and filters for continent/country where useful. Do not label this as current COVID data.

## Five interview questions to prepare
1. **Why filter `continent IS NOT NULL`?** It removes aggregate rows such as World and regions from country-level comparisons, avoiding double counting.
2. **Why can doses per 100 people exceed 100?** Doses count administrations; one person may receive multiple doses.
3. **Why use `NULLIF(population, 0)`?** It prevents division-by-zero errors by returning NULL when the denominator is zero.
4. **Why use `RANK()` for the top 10?** It preserves ties; rank 10 ties can cause more than ten rows to appear.
5. **Does a higher average death rate in a GDP bucket prove GDP causes deaths?** No. This is descriptive, ecological analysis and cannot establish causation.

## Limitations
- Historical data only, through 30 April 2021; it must not be presented as current.
- Cases and deaths depend on reporting, testing, and country-specific practices.
- Missing and revised vaccination data can affect cumulative totals.
- `new_vaccinations` counts doses, not unique individuals.
- Simple averages give each country equal weight; they are not population-weighted averages.
- GDP per capita and median age are country-level indicators; correlation does not establish causation.
- `RANK()` can return more than ten rows when ranks tie.
- The SQL script must be executed in SQL Server and compared with the included result files before claiming reproducibility.
- 
