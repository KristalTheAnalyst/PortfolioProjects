/*
SELECT *
FROM PortfolioProject..[COVID Deaths]
order by 3, 4

SELECT *
FROM PortfolioProject..[COVID Vaccinations]
order by 3, 4
*/

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.[COVID Deaths]
ORDER BY 1, 2

--Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.[COVID Deaths]
ORDER BY 1, 2

--Shows Likelihood of Dying if you contract COVID in your Country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.[COVID Deaths]
WHERE Location LIKE '%states%'
ORDER BY 1, 2


--Looking at Total Cases vs Population
--Shows what percentage of population got COVID
SELECT location, date, population, total_cases, (total_cases/population)*100 AS CasesvsPopPercentage
FROM PortfolioProject.dbo.[COVID Deaths]
WHERE Location LIKE '%states%'
ORDER BY 1, 2


--Looking at countries with high infection rates compared their Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.[COVID Deaths]
--WHERE Location LIKE '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


--Showing Countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject.dbo.[COVID Deaths]
--WHERE Location LIKE '%states%'
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--Breaking Things Down By Continent
SELECT continent, MAX(cast(total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject.dbo.[COVID Deaths]
--WHERE Location LIKE '%states%'
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Breaking Down by Location
SELECT location, MAX(cast(total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject.dbo.[COVID Deaths]
--WHERE Location LIKE '%states%'
WHERE continent is NULL AND location not like '%income%'
GROUP BY location
ORDER BY TotalDeathCount DESC


--Showing Continents with Highest Death Count per Population
SELECT continent, MAX(cast(total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject.dbo.[COVID Deaths]
--WHERE Location LIKE '%states%'
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



--Global Numbers
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.[COVID Deaths]
--WHERE Location LIKE '%states%'
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1, 2


SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.[COVID Deaths]
--WHERE Location LIKE '%states%'
WHERE continent is NOT NULL
--GROUP BY date
ORDER BY 1, 2


--Looking at Total Population vs Vaccinations

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations
FROM PortfolioProject.dbo.[COVID Deaths] as Dea
JOIN PortfolioProject.dbo.[COVID Vaccinations] as Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE dea.continent is NOT NULL
ORDER BY 1, 2, 3



SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
	SUM(CONVERT(BIGINT, Vac.new_vaccinations)) OVER (Partition BY Dea.location ORDER BY Dea.location, 
	dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.[COVID Deaths] as Dea
JOIN PortfolioProject.dbo.[COVID Vaccinations] as Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent is NOT NULL
ORDER BY 1, 2, 3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(CONVERT(BIGINT, Vac.new_vaccinations)) OVER (Partition BY Dea.location ORDER BY Dea.location, 
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.[COVID Deaths] as Dea
JOIN PortfolioProject.dbo.[COVID Vaccinations] as Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent is NOT NULL
)