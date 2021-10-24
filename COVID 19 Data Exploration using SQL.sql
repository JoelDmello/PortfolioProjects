
SELECT * FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT * FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Total Cases vs Total Deaths (showing likelihood of dying if you contract COVID in your country)

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Ireland'
AND continent IS NOT NULL
ORDER BY 1,2

--Total Cases vs Total Population

SELECT location, date, population, total_cases, (total_cases/population)*100 AS COVIDPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Ireland'
ORDER BY 1,2

--Which country has the highest infection rate compared to the population?

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS COVIDPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY COVIDPercentage DESC;

--Highest Death Count

SELECT location, MAX(cast(total_deaths as int)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC

--Continent wise Death Stats

SELECT continent, MAX(cast(total_deaths as int)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC

-- How many people are vaccinated and what is the percentage of total vaccinated based on the population using CTE?

With PopvsVac (continent, location, date, population, new_vaccinations, TotalVaccinatedSoFar)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS TotalVaccinatedSoFar  
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.population IS NOT NULL AND vac.new_vaccinations IS NOT NULL
)

SELECT *, (TotalVaccinatedSoFar/population)*100
FROM PopvsVac;


--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
TotalVaccinatedSoFar numeric,
)

select * from PortfolioProject..CovidVaccinations where new_vaccinations is NULL

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,ISNULL(vac.new_vaccinations, 0 ))) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS TotalVaccinatedSoFar  
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.population IS NOT NULL AND vac.new_vaccinations IS NOT NULL

SELECT *, (TotalVaccinatedSoFar/population)*100
FROM #PercentPopulationVaccinated;


--Creating View


CREATE View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,ISNULL(vac.new_vaccinations, 0 ))) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS TotalVaccinatedSoFar  
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.population IS NOT NULL AND vac.new_vaccinations IS NOT NULL

SELECT * FROM PercentPopulationVaccinated;
