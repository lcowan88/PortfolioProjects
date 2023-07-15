
SELECT *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--SELECT *
--from PortfolioProject..CovidVaccinations$
--order by 3,4

-- Select Data that we will be using

SELECT location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2

--Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected 
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population 

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as 
PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by location 
order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing continents with the highest death count per population 

SELECT continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by continent 
order by TotalDeathCount desc



--GLOBAL NUMBERS


SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint))as total_deaths,CASE WHEN SUM(new_cases) = 0 THEN 0 ELSE 
SUM(cast(new_deaths as bigint))/SUM(new_cases) end *100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as
RollingPeopleVaccinated
--, (RollingPeopleVaccinated//population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as
RollingPeopleVaccinated
--, (RollingPeopleVaccinated//population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as
RollingPeopleVaccinated
--, (RollingPeopleVaccinated//population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as
RollingPeopleVaccinated
--, (RollingPeopleVaccinated//population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3