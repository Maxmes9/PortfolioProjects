SELECT* 
FROM CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 3,4

--SELECT* 
--FROM CovidVaccinations
--ORDER BY 3,4

--Select Data that we are going to be using

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM
	CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows Likelihood of dying if you contract covid in your country

SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM
	CovidDeaths
WHERE location = 'Mexico'
ORDER BY 1,2


--Looking at the total Cases vs Population

SELECT location,date,total_cases,population, (total_cases/population) * 100 AS SicknessPercentage
FROM
	CovidDeaths
WHERE location = 'Mexico'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Popuplation

SELECT location,population,MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 AS PercentInfected
FROM
	CovidDeaths
--WHERE location = 'Mexico'
GROUP BY Location,population
ORDER BY HighestInfectionCount DESC

--Showing Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM
	CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM
	CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths AS INT)) AS TotalDeaths, SUM(cast(new_deaths as int)) / SUM(new_cases)* 100 
AS DeathPercentage
FROM
	CovidDeaths
--WHERE location = 'Mexico'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- TOTAL POPULATION vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS VaccinationsToDate
, (VACCINATIONSTODATE/population) *100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--USE CTE

WITH PopvsVac (Continent, Location, Date, Population, new_vaccionations, VaccinationsToDate)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS VaccinationsToDate
--, (VACCINATIONSTODATE/population) *100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT * , (VaccinatIonsToDate/Population) * 100
FROM PopvsVac

--Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccination numeric,
VaccinationsToDate numeric,
)

INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS VaccinationsToDate
--, (VACCINATIONSTODATE/population) *100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * , (VaccinatIonsToDate/Population) * 100
FROM #PercentPopulationVaccinated


--Creating View to Store DATA for later Vizualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS VaccinationsToDate
--, (VACCINATIONSTODATE/population) *100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated