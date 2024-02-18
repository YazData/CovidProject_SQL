

Select *
From CovidProject..CovidDeaths
Where continent is not null
Order by 3,4

Select *
From CovidProject..CovidVaccinations
Where continent is not null
Order by 3,4

-- Total Cases vs Total Deaths %
-- Shows the percentage chance of dying getting COVID in each Country

Select location, date, total_cases, total_deaths,
(CONVERT(float, total_deaths) / (CONVERT(float, total_cases)))*100 AS DeathPerCasePercentage
From CovidProject..CovidDeaths
-- Where location = 'Morocco'
Order by 1

-- Total Cases vs Population %
-- Shows what percentage of population got COVID in each Country

Select location, date, population, total_cases, 
(CONVERT(float, total_cases) / (CONVERT(float, population)))*100 AS InfectionPerPopulationPercentage 
From CovidProject..CovidDeaths
-- Where location = 'Morocco'
Order by 1,2

-- Countries with Highest Infection Rate compared to population

Select location, population, MAX(CONVERT(float,total_cases)) as TotalInfectionCount, 
MAX((CONVERT(float, total_cases) / (CONVERT(float, population)))*100) AS InfectionPerPopulationPercentage
From CovidProject..CovidDeaths
Where continent is not null
Group by location, population
Order by 4 Desc

-- Countries with Highest Death Count compared to population

Select location, population, MAX(CONVERT(float,total_deaths)) as TotalDeathCount, 
MAX((CONVERT(float, total_deaths) / (CONVERT(float, population)))*100) AS DeathPerPopulationPercentage
From CovidProject..CovidDeaths
Where continent is not null
Group by location, population
Order by 3 Desc

-- BREAKING THINGS DOWN BY CONTINENTS

-- Continents with Highest Death Count

Select continent, SUM(CONVERT(float,new_deaths)) as TotalDeathCount
From CovidProject..CovidDeaths
Where continent is not null
Group by continent
Order by 2 Desc

-- GLOBAL NUMBERS

-- Death Percentage per case each day

Select date, SUM(CONVERT(float,new_cases)) as TotalCases, SUM(CONVERT(float,new_deaths)) as TotalDeaths
 ,(SUM(CONVERT(float,new_deaths)) / NULLIF(SUM(CONVERT(float,new_cases)),0))*100 AS DeathPerCasePercentage
From CovidProject..CovidDeaths
Where continent is not null
Group by date
Order by 1

-- Total Death Percentage per case in the world

Select SUM(CONVERT(float,new_cases)) as TotalCases, SUM(CONVERT(float,new_deaths)) as TotalDeaths
 ,(SUM(CONVERT(float,new_deaths)) / NULLIF(SUM(CONVERT(float,new_cases)),0))*100 AS DeathPerCasePercentage
From CovidProject..CovidDeaths
Where continent is not null
Order by 1


-- Using the two tables

Select *
From CovidProject..CovidDeaths deaths
Join CovidProject..CovidVaccinations vaccin
	on deaths.location = vaccin.location
	and deaths.date = vaccin.date
Order by 3,4

-- Total Population VS Vaccinations

Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccin.new_vaccinations,
SUM(CONVERT(float, vaccin.new_vaccinations)) OVER (Partition by deaths.location order by deaths.location, deaths.date) AS TotalVaccinationsToDate
From CovidProject..CovidDeaths deaths
Join CovidProject..CovidVaccinations vaccin
	on deaths.location = vaccin.location
	and deaths.date = vaccin.date
Where deaths.continent is not NULL
Order by 2,3

WITH CTE_Vaccinations (Continent, location, date, population, new_vaccinations, TotalVaccinationsToDate)
AS(Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccin.new_vaccinations,
SUM(CONVERT(float, vaccin.new_vaccinations)) OVER (Partition by deaths.location order by deaths.location, deaths.date) AS TotalVaccinationsToDate
From CovidProject..CovidDeaths deaths
Join CovidProject..CovidVaccinations vaccin
	on deaths.location = vaccin.location
	and deaths.date = vaccin.date
Where deaths.continent is not NULL
)

Select Continent, location, date, population, new_vaccinations, TotalVaccinationsToDate,
(TotalVaccinationsToDate / Population)*100 AS VaccinationPerPopulationPercentage
FROM CTE_Vaccinations
Order By 2,3



