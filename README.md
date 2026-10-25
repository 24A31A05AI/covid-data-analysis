# COVID-19 Data Exploration — Guided Project + Personal Extensions

## Project status
**Guided portfolio project with personal extensions.** The project combines an initial exploration inspired by Alex Freberg's public COVID-19 SQL tutorial with additional analysis questions, Excel result tables/charts, and a Tableau Public dashboard.

The supplied result tables were calculated from the provided Excel extracts. The T-SQL script still needs to be executed in SQL Server and its results compared with the included outputs before claiming that the SQL workflow has been fully reproduced and validated.

## Project links
- **GitHub repository:** https://github.com/24A31A05AI/covid-data-analysis
- **Tableau Public dashboard:** https://public.tableau.com/views/COVID-19DataAnalysisDashboard_17929517631930/COVID-19DataAnalysisDashboard?:language=en-US&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link

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
- Tableau Public
- GitHub

## Data handling and approach
- Excluded records where `continent IS NULL` from country-level comparisons because they include aggregates such as World and regional totals.
- Used `TRY_CAST` for potentially text-stored numeric fields in the T-SQL queries.
- Used joins, CTEs, aggregate functions, `CASE`, and window functions.
- For country-level cumulative metrics, used the latest available non-null record where appropriate.
- Treated vaccine doses and people vaccinated as different measures.
- GDP buckets: Low < 5,000; Lower-middle 5,000 to < 15,000; Upper-middle 15,000 to 35,000; High > 35,000. Missing GDP is labelled `Unknown GDP`.

## Findings from the supplied extracts

> These findings were computed from the uploaded Excel data for an initial result check. They are not a claim that the SQL script has already been run in SQL Server. Execute the SQL and confirm that its results match before presenting these as verified SQL outputs.

### 1. India monthly trend
- Peak month by reported new cases: **April 2021**, with **6,943,304** reported new cases.
- Peak month by reported new deaths: **April 2021**, with **48,926** reported new deaths.
- The supplied data ends on 30 April 2021; these results describe this historical snapshot, not current COVID-19 trends.

### 2. Vaccine doses vs. people
- Israel in the supplied period: approximately **121.3 reported doses per 100 people** and **62.4%** of the population reported as having received at least one dose (latest non-null report: 2021-04-30).
- Doses per 100 people can exceed 100 because one person can receive multiple doses. The people-vaccinated metric is more appropriate for estimating the share that received at least one dose.
- Source reporting can contain anomalies. Some small locations may report people-vaccinated counts above the population estimate; do not automatically interpret those as literal coverage above 100%.

### 3. GDP-per-capita buckets
- Highest simple average reported deaths per million in these extracts: **Upper-middle**, about **923.4 deaths per million**.
- Highest average median age: **High**, about **39.9 years**.
- These are descriptive comparisons, not evidence that GDP or age bucket caused differences in death rates. Countries differ in testing, reporting, population structure, and other factors.

### 4. Top 10 deaths per million
- Highest-ranked country in the population > 1 million filter: **Hungary**, about **2,850.8 reported deaths per million** as of its latest available record in the extract.
- See `data/top10_deaths_per_million.csv` for the full ranked output.
- Rankings are sensitive to reporting differences and the historical cutoff date.

## Excel deliverable
Open `excel/COVID_Analysis_Results.xlsx`. It contains:
- `India_Monthly`: monthly India case/death totals with peak ranks.
- `Vaccination`: country-level doses and people-vaccinated comparison.
- `Income_Buckets`: average metrics by GDP bucket.
- `Top10_Deaths`: highest reported deaths per million with population > 1 million.
- `Continent_Deaths`: sum of latest reported country death counts by continent (not a sum of daily cumulative rows).
- `India_USA_Monthly`: monthly cases for India and the United States, suitable for a line chart.
- `Dashboard_Charts`: Excel charts using the calculated output tables.

## Tableau Public dashboard
The published dashboard includes:
1. **India monthly COVID-19 cases:** line chart of reported monthly cases.
2. **Top countries by COVID-19 deaths per million:** ranked horizontal bar chart.
3. **COVID-19 vaccination coverage by country:** horizontal bar chart.

The dashboard is based on historical data through 30 April 2021. The India monthly chart should be interpreted with the supplied data's date range and aggregation in mind. Verify the underlying monthly values against the SQL output before treating them as final.

## Five interview questions to prepare
1. **Why filter `continent IS NOT NULL`?** It removes aggregate rows such as World and regions from country-level comparisons, helping avoid double counting.
2. **Why can doses per 100 people exceed 100?** Doses count administrations; one person can receive multiple doses.
3. **Why use `NULLIF(population, 0)`?** It prevents division-by-zero errors by returning `NULL` when the denominator is zero.
4. **Why use `RANK()` for the top 10?** It preserves ties; a rank-10 tie can result in more than ten rows.
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

## Credit
Initial exploration based on Alex Freberg's tutorial; extended with own analysis.
