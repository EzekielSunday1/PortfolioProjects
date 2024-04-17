select *
from portfolioproject..CovidDeaths
order by 3,4
select *
from portfolioproject..Covidvaccinations
order by 3,4

--select data for usage

select location, date, total_cases, new_cases, total_deaths, population
from portfolioproject..CovidDeaths
order by 1,2

--total cases vs total deaths for the entire cases
--showing likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolioproject..CovidDeaths
where location like 'Africa'
order by 1,2

--looking at the total_cases vs population
--shows what percentage of population got covid

select location, date, population, total_cases,(total_cases/population)*100 as PercentpopulationInfected
from portfolioproject..CovidDeaths
where location like '%states%' and continent is not null
order by 1,2

select location, date, population, total_cases,(total_cases/population)*100 as  PercentpopulationInfected
from portfolioproject..CovidDeaths
where location like 'Africa'
order by 1,2

--looking at countries with highest infection Rate compare to population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as  PercentpopulationInfected
from portfolioproject..CovidDeaths
where continent is not null
group by location, population
order by  PercentpopulationInfected desc

--showing countries with highest death count per population

select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from portfolioproject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--breaking down by continent

--Showing continents with the highest death count per population

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from portfolioproject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
from portfolioproject..CovidDeaths
where continent is not null
--group by date
order by 1,2

--looking at total Population vs Vaccinations

select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date ) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

with PopvsVac (Continent, Loction, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.location, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date ) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--TEMP TABLE
DROP Table if exists #PerceentPopulationVaccinated
create Table #PerceentPopulationVaccinated
(
continent nvarchar (255),
Location nvarchar (255),
Date Datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into  #PerceentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.location, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date ) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PerceentPopulationVaccinated


--Creating view to store data for later visualisations

create view PerceentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.location, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date ) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PerceentPopulationVaccinated


