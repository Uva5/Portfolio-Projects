SELECT *
FROM [PortFolio Project]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


--SELECT *
--FROM [PortFolio Project]..CovidVaccinations
--ORDER BY 3,4

--Selecting Data to be used

SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM [PortFolio Project]..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the possibility of dying if you contract covid-19 in India

SELECT Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM [PortFolio Project]..CovidDeaths
WHERE location LIKE '%india%'
AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at the total cases vs population
-- Shows what percentage has got Covid

SELECT Location,date,population,total_cases, (total_cases/population)*100 AS PercentOfPopulationInfected
FROM [PortFolio Project]..CovidDeaths
-- WHERE location LIKE '%india%'
ORDER BY 1,2

-- Looking at countries highest infection rates compared to population

SELECT Location,population,MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentOfPopulationInfected
FROM [PortFolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Population,location
ORDER BY PercentOfPopulationInfected DESC

-- Showing the countries with the highest death count as per population

SELECT Location,MAX(CAST(total_deaths AS bigint)) AS TotalDeathCount
FROM [PortFolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

---Showing the continents with the highest death count

SELECT continent,MAX(CAST(total_deaths AS bigint)) AS TotalDeathCount
FROM [PortFolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


---Global Numbers

SELECT date,SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS bigint)) AS total_deaths,SUM(CAST(new_deaths AS bigint))/SUM(new_cases)*100 AS DeathPercentage
FROM [PortFolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date 
ORDER BY 1,2

---Joining By date and location

SELECT *
FROM [PortFolio Project]..CovidDeaths dea
JOIN [PortFolio Project]..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date

--- Looking at total population vs vaccination

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [PortFolio Project]..CovidDeaths dea
JOIN [PortFolio Project]..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--- USING CTE

WITH PopvsVac (Continent,Location, date,population,new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [PortFolio Project]..CovidDeaths dea
JOIN [PortFolio Project]..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT * ,(RollingPeopleVaccinated/population)*100
FROM PopvsVac

--- Temp Table

Drop Table if exists #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(225),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [PortFolio Project]..CovidDeaths dea
JOIN [PortFolio Project]..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

SELECT * ,(RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--- Creating view to store date for later visualization


CREATE VIEW PercentPopulationVaccinated1 AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [PortFolio Project]..CovidDeaths dea
JOIN [PortFolio Project]..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * 
FROM PercentPopulationVaccinated1