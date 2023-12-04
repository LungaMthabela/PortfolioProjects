SELECT*
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select data that we are going to be using

 SELECT location, date, total_cases,new_cases,total_deaths,population
 FROM PortfolioProject..CovidDeaths
 WHERE continent IS NOT NULL
 ORDER BY 1,2

 --Looking at Total Cases vs Total deaths
--Shows the likelihood of dying if you contract covid in your country
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%States%' AND continent IS NOT NULL
 ORDER BY 1,2

 CREATE VIEW Case_vs_Deaths as
 SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%States%' AND continent IS NOT NULL
 --ORDER BY 1,2

 SELECT*
 FROM Case_vs_Deaths

--Looking at the total cases vs population
--Shows what percentage of population got Covid
SELECT location,date, population, total_cases,(total_cases/population)*100 as Infection_Percentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
 ORDER BY 1,2

--Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS Infection_Count, MAX((total_cases/population))*100 as Highest_Infection
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location, population
 ORDER BY Highest_Infection DESC

 --Showing Countries with the hiheest Death count population
 SELECT location, MAX(CAST(Total_deaths AS INT)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location
 ORDER BY Total_Death_Count DESC

 --LET'S BREAK THINGS DOWN BY CONTINENT
 --Showing continents with the highest deaht count per poulation
  SELECT continent, MAX(CAST(Total_deaths AS INT)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS not  NULL
GROUP BY continent
 ORDER BY Total_Death_Count DESC

 CREATE VIEW HIGHEST_DEATH_COUNT AS
 SELECT continent, MAX(CAST(Total_deaths AS INT)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS not  NULL
GROUP BY continent
-- ORDER BY Total_Death_Count DESC


--GLOBAL NUMBERS
SELECT date,SUM(total_cases) AS Total_cases, SUM(CAST(new_deaths AS INT))--,total_deaths,(total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%States%' 
WHERE continent IS NOT NULL
GROUP BY date
 ORDER BY 1,2 

 SELECT date, SUM(new_cases)as Total_Cases, SUM(CAST(new_deaths as int))as Total_Deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
 FROM PortfolioProject..CovidDeaths
 WHERE continent IS NOT NULL 
 GROUP BY date
 ORDER BY 1,2

 SELECT SUM(new_cases)as Total_Cases, SUM(CAST(new_deaths as int))as Total_Deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
 FROM PortfolioProject..CovidDeaths
 WHERE continent IS NOT NULL 
 --GROUP BY date
 ORDER BY 1,2

 --Looking at Total population vs vaccinations

 SELECT dea.continent  , dea.location, dea.date, dea.population,vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as Rolling_People_Vaccinated
 FROM PortfolioProject..CovidDeaths as dea
 JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
	 WHERE dea.continent IS NOT NULL 
	ORDER BY 2,3

--USE CTE

WITH PopVsVac (continent,location, Date, Population, New_Vaccinations,Rolling_People_Vaccinated)
AS
(
 SELECT dea.continent  , dea.location, dea.date, dea.population,vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as Rolling_People_Vaccinated
 FROM PortfolioProject..CovidDeaths as dea
 JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
	 WHERE dea.continent IS NOT NULL 
	--ORDER BY 2,3
)
SELECT*, (Rolling_People_Vaccinated/Population)*100
FROM PopVsVac

--USE TEMP TABLES
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinationated numeric,
Rolling_People_Vaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
 SELECT dea.continent  , dea.location, dea.date, dea.population,vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as Rolling_People_Vaccinated
 FROM PortfolioProject..CovidDeaths as dea
 JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
	 --WHERE dea.continent IS NOT NULL

SELECT*,(Rolling_People_Vaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Create View to store data for later visualisations

CREATE VIEW PercentPopulationVaccinated as
 SELECT dea.continent  , dea.location, dea.date, dea.population,vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as Rolling_People_Vaccinated
 FROM PortfolioProject..CovidDeaths as dea
 JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	--ORDER BY 2,3
