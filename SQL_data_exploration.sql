select * 
from Portfolio_project..CovidDeaths 
order by 3,4

--select * 
--from Portfolio_project..CovidVaccinations
--order by 3,4

-- slecting the data

select location, date, total_cases, new_cases, total_deaths, population
from Portfolio_project..CovidDeaths 
order by 1,2

-- Looking at Total cases vs Total deaths
-- Shows Death percentage if one get infected
select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as Death_percentage
from Portfolio_project..CovidDeaths 
where location like '%india%'
order by 1,2

-- Looking ata total cases vs population
-- Shows percentage of population got covid
select location, date, total_cases, population, (total_cases/population)*100 as Percentage_of_population_got_infected
from Portfolio_project..CovidDeaths 
where location like '%india%'
order by 1,2

-- Looking at countries with highest infection rate compared to population
select location, population, MAX(total_cases) as Highest_infection_count, MAX((total_cases/population))*100 as Percentage_of_population_got_infected
from Portfolio_project..CovidDeaths 
--where location like '%india%'
where continent is not null 
group by location, population
order by 4 desc


--Showing highest death count per population

select location, population, MAX(total_cases) as Highest_infection_count, MAX((total_cases/population))*100 as Percentage_of_population_got_infected
from Portfolio_project..CovidDeaths 
where continent is not null
group by location, population
order by 4 desc

-- Showing Countries with highest death count

select location, max(cast(total_deaths as int )) as total_deaths_count
from Portfolio_project..CovidDeaths 
where continent is not null 
group by location
order by 2 desc

-- Breaking wrt continent

select location, max(cast(total_deaths as int )) as total_deaths_count
from Portfolio_project..CovidDeaths 
where continent is null 
group by location
order by 2 desc

-- Showing the continents with highest death count

select location, max(cast(total_deaths as int )) as total_deaths_count
from Portfolio_project..CovidDeaths 
where continent is null 
group by location
order by 2 desc

-- Global numbers

select  sum(new_cases) as total_cases, sum(convert(int,new_deaths)) as total_deaths, (sum(convert(int,new_deaths))/sum(new_cases))*100 as Death_percentage
from Portfolio_project..CovidDeaths 
where continent is not null 
-- group by date
order by 1,2

-- Showing total population vs total vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_total_vaccinations
from Portfolio_project..CovidDeaths dea
join Portfolio_project..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- USing CTE

With PopvsVac
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_total_vaccinations
from Portfolio_project..CovidDeaths dea
join Portfolio_project..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
)
select *, (Rolling_total_vaccinations/population) * 100 
from PopvsVac


-- Temp table


drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_total_vaccinations numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_total_vaccinations
from Portfolio_project..CovidDeaths dea
join Portfolio_project..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 

select *, (Rolling_total_vaccinations/population) * 100 
from #PercentPopulationVaccinated

-- creating view to store data for later visualization

drop view if exists PercentPopulationVaccinated
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_total_vaccinations
from Portfolio_project..CovidDeaths dea
join Portfolio_project..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 

select * 
from PercentPopulationVaccinated