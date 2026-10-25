/*
COVID-19 DATA ANALYSIS — GUIDED STARTER + PERSONAL EXTENSIONS
SQL Server / T-SQL
Source extracts: Our World in Data, records through 2021-04-30.
Country-level queries exclude rows where continent IS NULL because these rows
include aggregate locations such as World and regional totals.
*/

USE PortfolioProject;
GO

/* EXTENSION 1: INDIA MONTHLY TREND
Monthly totals are sums of daily reported new cases and new deaths.
The ranks make the peak month visible; ties share rank 1.
*/
WITH IndiaMonthly AS
(
    SELECT
        YEAR(TRY_CAST(date AS date)) AS [year],
        DATEPART(MONTH, TRY_CAST(date AS date)) AS [month_number],
        DATENAME(MONTH, TRY_CAST(date AS date)) AS [month_name],
        SUM(TRY_CAST(new_cases AS bigint)) AS monthly_new_cases,
        SUM(TRY_CAST(new_deaths AS bigint)) AS monthly_new_deaths
    FROM dbo.CovidDeaths
    WHERE continent IS NOT NULL
      AND location = 'India'
      AND TRY_CAST(date AS date) IS NOT NULL
    GROUP BY
        YEAR(TRY_CAST(date AS date)),
        DATEPART(MONTH, TRY_CAST(date AS date)),
        DATENAME(MONTH, TRY_CAST(date AS date))
)
SELECT
    [year], [month_number], [month_name],
    monthly_new_cases, monthly_new_deaths,
    RANK() OVER (ORDER BY monthly_new_cases DESC) AS cases_peak_rank,
    RANK() OVER (ORDER BY monthly_new_deaths DESC) AS deaths_peak_rank
FROM IndiaMonthly
ORDER BY [year], [month_number];
GO

/* EXTENSION 2: DOSES VS PEOPLE
The rolling sum counts reported dose administrations. MAX(people_vaccinated)
is a cumulative count of people who received at least one dose. They are not
the same metric. A person can receive more than one dose.
*/
WITH DailyVaccination AS
(
    SELECT
        dea.continent,
        dea.location,
        TRY_CAST(dea.date AS date) AS [date],
        TRY_CAST(dea.population AS decimal(20,2)) AS population,
        TRY_CAST(vac.new_vaccinations AS bigint) AS new_vaccinations,
        TRY_CAST(vac.people_vaccinated AS bigint) AS people_vaccinated,
        SUM(COALESCE(TRY_CAST(vac.new_vaccinations AS bigint), 0)) OVER
        (
            PARTITION BY dea.location
            ORDER BY TRY_CAST(dea.date AS date)
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS rolling_reported_doses
    FROM dbo.CovidDeaths AS dea
    INNER JOIN dbo.CovidVaccinations AS vac
        ON dea.location = vac.location
       AND TRY_CAST(dea.date AS date) = TRY_CAST(vac.date AS date)
    WHERE dea.continent IS NOT NULL
      AND TRY_CAST(dea.date AS date) IS NOT NULL
),
CountryVaccination AS
(
    SELECT
        continent,
        location,
        MAX(population) AS population,
        MAX(rolling_reported_doses) AS cumulative_reported_doses,
        MAX(people_vaccinated) AS people_vaccinated
    FROM DailyVaccination
    GROUP BY continent, location
)
SELECT
    continent, location, population,
    cumulative_reported_doses,
    cumulative_reported_doses * 100.0 / NULLIF(population, 0) AS doses_per_100_people,
    people_vaccinated,
    people_vaccinated * 100.0 / NULLIF(population, 0) AS pct_population_with_at_least_one_dose
FROM CountryVaccination
ORDER BY doses_per_100_people DESC;
GO

/* EXTENSION 3: GDP PER CAPITA BUCKETS
Country-level deaths per million use each country's latest non-null total_deaths
and population values. The averages are simple country averages, not population-
weighted averages. Unknown GDP is kept visible instead of silently discarded.
*/
WITH CountryLatest AS
(
    SELECT
        continent, location,
        TRY_CAST(population AS decimal(20,2)) AS population,
        TRY_CAST(total_deaths AS decimal(20,2)) AS total_deaths,
        TRY_CAST(gdp_per_capita AS decimal(20,2)) AS gdp_per_capita,
        TRY_CAST(median_age AS decimal(10,2)) AS median_age,
        ROW_NUMBER() OVER
        (
            PARTITION BY location
            ORDER BY TRY_CAST(date AS date) DESC
        ) AS rn
    FROM dbo.CovidDeaths
    WHERE continent IS NOT NULL
      AND TRY_CAST(date AS date) IS NOT NULL
),
CountryMetrics AS
(
    SELECT
        continent, location,
        population, total_deaths,
        MAX(gdp_per_capita) OVER (PARTITION BY location) AS country_gdp_per_capita,
        MAX(median_age) OVER (PARTITION BY location) AS country_median_age
    FROM CountryLatest
    WHERE rn = 1
),
Bucketed AS
(
    SELECT
        *,
        CASE
            WHEN country_gdp_per_capita IS NULL THEN 'Unknown GDP'
            WHEN country_gdp_per_capita < 5000 THEN 'Low'
            WHEN country_gdp_per_capita < 15000 THEN 'Lower-middle'
            WHEN country_gdp_per_capita <= 35000 THEN 'Upper-middle'
            ELSE 'High'
        END AS income_bucket,
        total_deaths * 1000000.0 / NULLIF(population, 0) AS deaths_per_million
    FROM CountryMetrics
)
SELECT
    income_bucket,
    COUNT(*) AS country_count,
    AVG(deaths_per_million) AS avg_deaths_per_million,
    AVG(country_median_age) AS avg_median_age
FROM Bucketed
GROUP BY income_bucket
ORDER BY CASE income_bucket
    WHEN 'Low' THEN 1
    WHEN 'Lower-middle' THEN 2
    WHEN 'Upper-middle' THEN 3
    WHEN 'High' THEN 4
    ELSE 5
END;
GO

/* EXTENSION 4: TOP 10 DEATHS PER MILLION
Only countries with population > 1,000,000 are included. RANK preserves ties,
so the result may contain more than ten rows if rank 10 is tied.
*/
WITH CountryLatest AS
(
    SELECT
        continent, location,
        TRY_CAST(population AS decimal(20,2)) AS population,
        TRY_CAST(total_deaths AS decimal(20,2)) AS total_deaths,
        TRY_CAST(date AS date) AS [date],
        ROW_NUMBER() OVER
        (
            PARTITION BY location
            ORDER BY TRY_CAST(date AS date) DESC
        ) AS rn
    FROM dbo.CovidDeaths
    WHERE continent IS NOT NULL
      AND TRY_CAST(date AS date) IS NOT NULL
),
CountryRates AS
(
    SELECT
        continent, location, population, total_deaths,
        total_deaths * 1000000.0 / NULLIF(population, 0) AS deaths_per_million
    FROM CountryLatest
    WHERE rn = 1
      AND population > 1000000
      AND population IS NOT NULL
      AND total_deaths IS NOT NULL
),
Ranked AS
(
    SELECT *,
        RANK() OVER (ORDER BY deaths_per_million DESC) AS death_rate_rank
    FROM CountryRates
)
SELECT continent, location, population, total_deaths, deaths_per_million, death_rate_rank
FROM Ranked
WHERE death_rate_rank <= 10
ORDER BY death_rate_rank, location;
GO
