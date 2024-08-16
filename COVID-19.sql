SELECT *
FROM public."CovidDeaths"

-- Looking at Total Cases vs Total Deaths in 'Germany' & 'India'
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM public."CovidDeaths"
WHERE location IN ('Germany','India')
AND total_cases <> 0
ORDER BY location, date

--Looking at Total Cases vs Population for 'Germany' & 'India'
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM public."CovidDeaths"
WHERE location IN ('Germany','India')
ORDER BY location, date

-- Looking at Countries with Highest Infection Rates compared to Population
-- all the rows having continents as Null are having the location as the name of the Continents.
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, 
       MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM public."CovidDeaths"
WHERE continent IS NOT NULL
GROUP BY location, population
HAVING MAX((total_cases/population))*100 IS NOT NULL
ORDER BY PercentPopulationInfected DESC

--Looking at Total Deaths vs Population for 'Germany' & 'India'
SELECT location, date, total_deaths, population, (total_deaths/population)*100 AS PercentPopulationDeaths
FROM public."CovidDeaths"
WHERE location IN ('Germany','India')
ORDER BY location, date

-- Looking at Countries with Highest Death Counts
-- all the rows having continents as Null are having the location as the name of the Continents.
SELECT Location, MAX(total_deaths) AS HighestDeathCount
FROM public."CovidDeaths"
WHERE continent IS NOT NULL 
GROUP BY location
HAVING MAX(total_deaths) IS NOT NULL
ORDER BY HighestDeathCount DESC

-- Looking at the Death Counts per Continents
SELECT Continent, MAX(Total_Deaths) AS DeathCounts
FROM public."CovidDeaths"
WHERE continent IS NOT NULL
GROUP BY Continent
ORDER BY DeathCounts DESC

SELECT location, continent, total_deaths
FROM public."CovidDeaths"
WHERE location = 'Canada'

SELECT location, continent, MAX(total_deaths) 
FROM public."CovidDeaths"
WHERE location = 'Canada'
GROUP BY location, continent

--Looking at the Global Death Percentage on each Date
--here we can see new cases and new deaths were recorded weekly
SELECT date, SUM(new_cases) AS totalcases, SUM(new_Deaths) AS totaldeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM public."CovidDeaths"
WHERE continent IS NOT NULL
GROUP BY date
HAVING SUM(new_cases) <> 0
ORDER BY date

--Looking at the Global Death Percentage 
SELECT SUM(new_cases) AS totalcases, SUM(new_Deaths) AS totaldeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM public."CovidDeaths"
WHERE Continent IS NOT NULL

--Looking at Total Vaccinations per day
SELECT dea.continent, dea.location, dea.date, vac.new_vaccinations
FROM public."CovidDeaths" dea
JOIN public."CovidVaccinations" vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date

--Looking at Population vs Total Vaccinations

--Using CTE to check the total percentage of population vaccinated per DAY
WITH popvsvac (continent,location,date,population,new_vaccinations,peoplevaccinated_rolling)
AS(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	AS peoplevaccinated_rolling
	FROM public."CovidDeaths" dea
    JOIN public."CovidVaccinations" vac
    ON dea.location = vac.location AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
	GROUP BY dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
    ORDER BY dea.location, dea.date
 )
 SELECT *, (peoplevaccinated_rolling/population)*100 AS vaccinatedpercentage
 FROM popvsvac
 
 --Using CTE to check the total percentage of population vaccinated per location
 WITH popvsvac (continent,location,population,totalvaccinations)
AS(
	SELECT dea.continent, dea.location, dea.population, 
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location)
	AS totalvaccinations
	FROM public."CovidDeaths" dea
    JOIN public."CovidVaccinations" vac
    ON dea.location = vac.location AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
	GROUP BY dea.continent, dea.location, dea.population, vac.new_vaccinations
    ORDER BY dea.location
 )
 SELECT *, MAX((totalvaccinations/population))*100 AS vaccinatedpercentage
 FROM popvsvac
 GROUP BY continent,location,population,totalvaccinations
 ORDER BY location
 
 --Using Temp Table to check the total percentage of population vaccinated
 DROP TABLE IF EXISTS PercentPopulationVaccinated
 CREATE Temp Table PercentPopulationVaccinated
 (
	 continent varchar (100),
     location varchar (100),
     date date,
	 population real,
	 new_vaccinations real,
	 peoplevaccinated_rolling real
 )
	 
 INSERT INTO PercentPopulationVaccinated
 (
	 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	AS peoplevaccinated_rolling
	FROM public."CovidDeaths" dea
    JOIN public."CovidVaccinations" vac
    ON dea.location = vac.location AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
	GROUP BY dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
    ORDER BY dea.location, dea.date
  )
 
  SELECT *, (peoplevaccinated_rolling/population)*100 AS vaccinatedpercentage
  FROM PercentPopulationVaccinated
  
  --Creating View to store data for later visualizations
  CREATE VIEW PercentPopulationVaccinated
  AS
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	AS peoplevaccinated_rolling
	FROM public."CovidDeaths" dea
    JOIN public."CovidVaccinations" vac
    ON dea.location = vac.location AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
	GROUP BY dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
    ORDER BY dea.location, dea.date
	
--Checking the View
SELECT *
FROM PercentPopulationVaccinated




