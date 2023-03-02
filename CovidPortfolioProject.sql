select *
from CovidPortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2

--Total deaths vs Total cases
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location='India'
order by 1,2

--Total cases vs Population
select location,date,population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
where location='India'
order by 1,2

--Countries with highest Infection Rate compared to population
select location,population,max(total_cases) as HghestTotalCases, max((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths
where continent is not null
group by location,population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population
select location,max(cast(total_deaths as int)) as totalDeathCount
from CovidDeaths
where continent is not null
group by location
order by totalDeathCount desc

--Showing Continents with Highest Death Count per Population
select continent, max(cast(total_deaths as int)) as TotalDeath
from CovidDeaths
where continent is not null
group by continent
order by TotalDeath desc

--global numbers
select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2

--Total population vs vaccination
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Using CTE
with PopvsVac (continent,location,date,population,total_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100 from PopvsVac

--Using Temp Table
CREATE TABLE PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
total_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/population)*100 from PercentPopulationVaccinated

--View

create view PercentPopVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopVaccinated