
select * from PortfolioProject..CovidDeaths

alter table PortfolioProject..CovidDeaths 
alter column total_cases float
alter table PortfolioProject..CovidDeaths
alter column total_deaths float

--likelihood of death after catching covid in the US
select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%' and continent is not null
order by 1,2

--Total Cases vs Population
select Location, date, population, total_cases, (total_deaths/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
order by 1,2

--Countries with the highest Covid infection rate
select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc

--Countries with highest death rate
select Location, population, max(total_deaths) as TotalDeathCount
--, max((total_deaths/population))*100 as PercentTotalDeaths
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by TotalDeathCount desc


--Continents with highest death rate with different demographics
select Location, population, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location,population
order by TotalDeathCount desc

--Continents with highest death rate
select continent, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Global covid numbers each day
select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(nullif(new_cases,0))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%' 
where continent is not null
group by date
order by 1,2

--Global overall Death percentage regardless of location or date
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(nullif(new_cases,0))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%' 
where continent is not null
order by 1,2

--Total Population vs Total Vaccination
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
sum(convert(bigint, CV.new_vaccinations)) over (partition by CD.location order by CD.location, 
CD.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths CD
join PortfolioProject..CovidVaccinations CV
	on CD.location = CV.location
	and CD.date = CV.date
where CD.continent is not null
order by 2,3

--Use CTE
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
sum(convert(bigint, CV.new_vaccinations)) over (partition by CD.location order by CD.location, 
CD.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths CD
join PortfolioProject..CovidVaccinations CV
	on CD.location = CV.location
	and CD.date = CV.date
where CD.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 as PercentPeopleVaccinated
from PopvsVac



--Temp table instead of CTE
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
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
sum(convert(bigint, CV.new_vaccinations)) over (partition by CD.location order by CD.location, 
CD.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths CD
join PortfolioProject..CovidVaccinations CV
	on CD.location = CV.location
	and CD.date = CV.date
where CD.continent is not null

select *, (RollingPeopleVaccinated/population)*100 as PercentPeopleVaccinated
from #PercentPopulationVaccinated

go
--create view for visualization
create view PercentPopulationVaccinated as
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
sum(convert(bigint, CV.new_vaccinations)) over (partition by CD.location order by CD.location, 
CD.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths CD
join PortfolioProject..CovidVaccinations CV
	on CD.location = CV.location
	and CD.date = CV.date
where CD.continent is not null

go
create view PercentPopulationInfected as
select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
