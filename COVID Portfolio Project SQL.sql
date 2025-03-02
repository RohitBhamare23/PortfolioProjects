-- Selecting Data to Operate:
Select location, date, total_cases, new_cases, total_deaths, population
From SQLPROJECT..CovidDeaths
order by 1,2

-- Total Cases Vs Total Deaths:
-- Shows % of dying if diagnosed by Covid in your country:
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From SQLPROJECT..CovidDeaths
where location like '%india%'
order by 1,2

-- Total Cases Vs Population:
-- Shows % of the population that got Covid in your country:
Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From SQLPROJECT..CovidDeaths
where location like '%india%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population:
Select location, population, MAX(total_cases) as max_count_cases, MAX((total_cases/population))*100 as PercentPopulationInfected
From SQLPROJECT..CovidDeaths
group by location, population
order by 4 desc 

-- Countries with Highest Death Count by Population:
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from SQLPROJECT..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- Continents with Highest Death Count:
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from SQLPROJECT..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global numbers:
select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentageGlobally
from SQLPROJECT..CovidDeaths
where continent is not null
order by 1,2


-- Total Population vs Vaccinations 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingSumVaccinated
from SQLPROJECT..CovidDeaths dea
join SQLPROJECT..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Using CTE:
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingSumVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingSumVaccinated
from SQLPROJECT..CovidDeaths dea
join SQLPROJECT..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select * , (RollingSumVaccinated/Population)*100 as PercentagePeopleVaccinated 
from PopvsVac


--TEMP TABLE:
DROP TABLE IF EXISTS #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingSumVaccinated numeric
)


insert into #PercentPopulationVaccinated 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingSumVaccinated
from SQLPROJECT..CovidDeaths dea
join SQLPROJECT..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Select * , (RollingSumVaccinated/Population)*100 as PercentagePeopleVaccinated 
from #PercentPopulationVaccinated


-- Creating View
Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingSumVaccinated
from SQLPROJECT..CovidDeaths dea
join SQLPROJECT..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * 
from PercentPopulationVaccinated









