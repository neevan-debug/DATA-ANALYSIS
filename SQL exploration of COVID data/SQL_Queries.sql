--1. Checking if the data has been imported properly into the Microsoft sql server management studio.

SELECT * 
FROM Covid_project..CovidDeaths
ORDER BY 3,4

SELECT * 
FROM Covid_project..CovidVaccinations
ORDER BY 3,4


--2. Next, we will select data that we are going to be using in this project.

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Covid_project..CovidDeaths
ORDER BY 1,2


--3. Finding the total cases vs total deaths per day. find the likelihood of dying if affected with covid?

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM Covid_project..CovidDeaths
ORDER BY 1,2


--4. Finding the total cases vs total deaths per day of india.

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM Covid_project..CovidDeaths
WHERE Location LIKE '%India%'
ORDER BY 1,2


--5. Finding the total cases vs population in india.

SELECT Location, date, total_cases, Population, (total_cases/Population)*100 AS Infection_Percentage
FROM Covid_project..CovidDeaths
WHERE Location LIKE '%India%'
ORDER BY 1,2


--6. Finding the total cases vs population .

SELECT Location, date, total_cases, Population, (total_cases/Population)*100 AS Infection_Percentage
FROM Covid_project..CovidDeaths
ORDER BY 1,2


--7. Finding the country with highest infection rate percentage .

SELECT Location, MAX(total_cases) AS HighestCount, Population, MAX(total_cases/Population)*100 AS Infection_Percentage
FROM Covid_project..CovidDeaths
GROUP BY Location, Population
ORDER BY 4 DESC


--8. Finding the country with highest Death count per population .
-- total_deaths datatype was varchar, so cast has been done. And also some of the continents were filled as wrong in the data.

SELECT Location, MAX(CAST(total_deaths as INT)) AS HighestDeath
FROM Covid_project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY 2 DESC


--9. Finding the continent with highest Death count per population.

SELECT continent, MAX(CAST(total_deaths as INT)) AS HighestDeath
FROM Covid_project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC


--10. Finding the total cases, total deaths per day in world.

SELECT date, SUM(total_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS deathPercentage
FROM Covid_project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


--11. Finding the total cases, total deaths till date in world.

SELECT SUM(total_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS deathPercentage
FROM Covid_project..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--12. Joining the two tables

SELECT *
FROM Covid_project..CovidDeaths AS de
JOIN Covid_project..CovidVaccinations AS va
ON de.location = va.location AND de.date = va.date


--12. Finding the total number of people vaccinated per day

SELECT de.continent, de.location, de.date, de.population, va.new_vaccinations
FROM Covid_project..CovidDeaths AS de
JOIN Covid_project..CovidVaccinations AS va
ON de.location = va.location AND de.date = va.date
WHERE de.continent IS NOT NULL
ORDER BY 2,3


--13. Finding the total number of people vaccinated per day and also doing cumulative per day

SELECT de.continent, de.location, de.date, de.population, va.new_vaccinations, SUM(CAST(va.new_vaccinations AS INT)) OVER (PARTITION BY de.location ORDER BY de.location, de.date) AS cumulative
FROM Covid_project..CovidDeaths AS de
JOIN Covid_project..CovidVaccinations AS va
ON de.location = va.location AND de.date = va.date
WHERE de.continent IS NOT NULL
ORDER BY 2,3


--14. use CTE

WITH PopvsVac (Continent, Location, Date, Population,New_vaccinations, RollingpeopleVaccinated)
AS
(
SELECT de.continent, de.location, de.date, de.population, va.new_vaccinations, SUM(CAST(va.new_vaccinations AS INT)) OVER (PARTITION BY de.location ORDER BY de.location, de.date) AS cumulative
FROM Covid_project..CovidDeaths AS de
JOIN Covid_project..CovidVaccinations AS va
ON de.location = va.location AND de.date = va.date
WHERE de.continent IS NOT NULL
)
SELECT *, (RollingpeopleVaccinated/Population)*100 AS vaccinationPer
FROM PopvsVac


--15. use TEMP table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT de.continent, de.location, de.date, de.population, va.new_vaccinations, SUM(CAST(va.new_vaccinations AS INT)) OVER (PARTITION BY de.location ORDER BY de.location, de.date) AS cumulative
FROM Covid_project..CovidDeaths AS de
JOIN Covid_project..CovidVaccinations AS va
ON de.location = va.location AND de.date = va.date
WHERE de.continent IS NOT NULL

SELECT *, (RollingpeopleVaccinated/Population)*100 AS vaccinationPer
FROM #PercentPopulationVaccinated


--16. creating views

CREATE VIEW PercentPopulationVaccinated AS
SELECT de.continent, de.location, de.date, de.population, va.new_vaccinations, SUM(CAST(va.new_vaccinations AS INT)) OVER (PARTITION BY de.location ORDER BY de.location, de.date) AS cumulative
FROM Covid_project..CovidDeaths AS de
JOIN Covid_project..CovidVaccinations AS va
ON de.location = va.location AND de.date = va.date
WHERE de.continent IS NOT NULL


--17. querying view
SELECT *
FROM PercentPopulationVaccinated

