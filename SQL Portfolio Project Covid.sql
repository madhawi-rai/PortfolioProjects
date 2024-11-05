SELECT *
FROM PortfolioProject.. CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.. CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using 

SELECT location, date,total_cases, new_cases, total_deaths, population
FROM PortfolioProject.. CovidDeaths
ORDER BY 1, 2

-- Looking at Total Cases versus Total Deaths

SELECT location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.. CovidDeaths
ORDER BY 1, 2

--Shows Likelihood  of dying if you contract covid in your country

SELECT location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.. CovidDeaths
Where location like '%states%'
ORDER BY 1, 2

--Looking at Total cases vs Population
--Shows what percentage of Population  got Covid

SELECT location, date,population, total_cases, (total_cases/population)*100 AS PercentagePopulationInfected
FROM PortfolioProject.. CovidDeaths
Where location like '%states%'
ORDER BY 1, 2

--Looking at Countries with the Highest Infection Rate compared to Population

SELECT location,population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject.. CovidDeaths
--Where location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

-- Showing Countries with the Highest Death Count per Population

SELECT location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.. CovidDeaths
--Where location like '%states%'
GROUP BY location
ORDER BY TotalDeathCount desc


--Pull up data where Continent column is filled

SELECT *
FROM PortfolioProject.. CovidDeaths
WHERE continent  is not null
ORDER BY 3,4

--Checking with only the country wise 

SELECT location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.. CovidDeaths
--Where location like '%states%'
WHERE continent  is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--Lets check the entire with the Null values 

SELECT location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.. CovidDeaths
--Where location like '%states%'
WHERE continent  is null
GROUP BY location
ORDER BY TotalDeathCount desc

--Showing continents with t he highest death count per population

SELECT continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.. CovidDeaths
--Where location like '%states%'
WHERE continent  is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS  total_deaths, SUM(cast(new_deaths AS int))/ SUM(New_Cases)* 100 AS DEathPercentage 
FROM PortfolioProject.. CovidDeaths
--Where location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

-- Death percentage overall total

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS  total_deaths, SUM(cast(new_deaths AS int))/ SUM(New_Cases)* 100 AS DEathPercentage 
FROM PortfolioProject.. CovidDeaths
--Where location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2

-- Joining the two different tables

SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	
--Looking at total Population Vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (CAST (vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
-- instead of CAST you can do CONVERT (int, vac.new_vaccinations)
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3
	

--Withg CTE  Population Vs Vaccination

WITH PopvsVac (Continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/ population) * 100
FROM PopvsVac


--TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nVarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2, 3
SELECT *, (RollingPeopleVaccinated/ population) * 100
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizations

CREATE View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated
