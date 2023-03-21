-- Select all columns from table CovidDeaths
-- Order by location
select *
from PortfolioProjectCovid..CovidDeaths
order by 3


-- Select all columns from table CovidVaccinations
-- Order by location
select *
from PortfolioProjectCovid..CovidVaccinations
order by 3


-- Select Data that we are going to be using
-- Order by location and date
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProjectCovid..CovidDeaths
order by 1,2


-- Change the data type of several columns so that calculation operations can be performed
-- Change from nvarchar to float
alter table CovidDeaths
alter column new_deaths float;


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProjectCovid..CovidDeaths
where location = 'united states'
and continent is not null
order by 1,2


-- Looking at Total Cases v Population
-- Shows what percentage of population got covid
select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
from PortfolioProjectCovid..CovidDeaths
where continent is not null
order by 1,2


-- Looking at Countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProjectCovid..CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc


-- Showing countries with highest death count per population
select location, max(total_deaths) as TotalDeathCount
from PortfolioProjectCovid..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continent with highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjectCovid..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global Numbers
-- New Cases vs New Deaths
-- Using NULLIF because some data has a value of '0', so the division operation cannot be performed
select nullif(sum(new_cases), 0) as NewCasesPerDay, nullif(sum(new_deaths),0) as NewDeathsPerDay, nullif(sum(new_deaths), 0)/nullif(sum(new_cases), 0)*100 as DeathPercentage
from PortfolioProjectCovid..CovidDeaths
where continent is not null
group by date
order by 1,2



-- JOIN 2 tables
-- JOIN CovidDeaths & CovidVaccinations and display all columns
select *
from PortfolioProjectCovid..CovidDeaths dea
join PortfolioProjectCovid..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date


-- Looking at total population vs vaccination
-- Using PARTITION BY to see the addition of new vaccine data to the total number of vaccines, Rolling data
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProjectCovid..CovidDeaths dea
join PortfolioProjectCovid..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE
-- Looking for Percentage of rolling data
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProjectCovid..CovidDeaths dea
join PortfolioProjectCovid..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 as RollingVaccinationPercentage
from PopvsVac


-- USE TEMP TABLE
-- Looking for Percentage of rolling data
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProjectCovid..CovidDeaths dea
join PortfolioProjectCovid..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 as RollingVaccinationPercentage
from #PercentPopulationVaccinated



-- Creating View to store data for later visualization
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProjectCovid..CovidDeaths dea
join PortfolioProjectCovid..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated