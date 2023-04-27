select *
from Portfolio01..CovidDeaths
where continent is not null
order by 3,4

--select *
--from Portfolio01..CovidVaccinations
--order by 3,4

--select data for use
select location, date, total_cases, new_cases, total_deaths, population
from Portfolio01..CovidDeaths
order by 1,2

--looking at total cases vs total deaths
--shows the likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from Portfolio01..CovidDeaths
where location like '%uganda%'
order by 1,2

--looking at total cases vs population
--shows what percentage of the population got covid

select location, date, total_cases, population,(total_cases/population)*100 as PercentPopulationInfected
from Portfolio01..CovidDeaths
where location like '%uganda%'
order by 1,2

--looking at countries with highest infection rate compare to population

select location,population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
from Portfolio01..CovidDeaths
--where location like '%uganda%'
group by population, location
order by PercentPopulationInfected desc

--showing countries with the highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolio01..CovidDeaths
--where location like '%uganda%'
group by location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

--showing continents with the highest death count

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolio01..CovidDeaths
--where location like '%uganda%'
where continent is null
group by location
order by TotalDeathCount desc


--GLOBAL NUMBERS

select date, SUM(new_cases) as Total_Cases,SUM(cast(new_deaths as int)) as Total_Deaths,SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Portfolio01..CovidDeaths
--where location like '%uganda%'
where continent is not null
group by date
order by 1,2

select SUM(new_cases) as Total_Cases,SUM(cast(new_deaths as int)) as Total_Deaths,SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Portfolio01..CovidDeaths
--where location like '%uganda%'
where continent is not null
--group by date
order by 1,2

--looking at total population vs vaccinations

Select *
From Portfolio01..CovidDeaths dea
Join Portfolio01..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From Portfolio01..CovidDeaths dea
Join Portfolio01..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From Portfolio01..CovidDeaths dea
Join Portfolio01..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From Portfolio01..CovidDeaths dea
Join Portfolio01..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From Portfolio01..CovidDeaths dea
Join Portfolio01..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated
