select * from CovidDeaths order by 3, 4;

select * from CovidVaccinations order by 3, 4;

--Select data that we are using

Select Location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1, 2;

--Looking at total cases vs total deaths
--shows likelihood of dying people if you contract covid in your country 
Select Location, date, total_cases, total_deaths, (cast(total_deaths as float) /cast(total_cases as float ))*100 
as Deathpercentage
from CovidDeaths
where location like '%india%'
order by 1, 2;

--looking at total cases vs population
--shows what percentage of population got covid
Select Location, date, population,total_cases,  (cast(total_cases as float) /cast(population as float ))*100 
as casepercentage
from CovidDeaths
where continent is not null
order by 1, 2;

--Looking at countries with highest infection rate compared to population

Select Location,population,max(total_cases) as HighestInfectionRate,  Max((cast(total_cases as float) /cast(population as float ))*100 )
as Percentpopulationinfected
from CovidDeaths
where continent is not null
group by Location,population
order by Percentpopulationinfected desc

--showing countries with highest death count rate against the population

Select Location,max(cast(total_deaths as int)) as Totaldeathcount
from CovidDeaths
where continent is not null
group by Location
order by Totaldeathcount desc

--let's break things down by continent

Select Location,max(cast(total_deaths as int)) as Totaldeathcount
from CovidDeaths
where continent is  null
group by location
order by Totaldeathcount desc


--Global numbers


Select date, sum(new_cases) as totalcases,sum(cast(new_deaths as int)) as totaldeaths
,SUM(cast(new_deaths as int))/nullif(sum(new_cases),0)*100 as Totaldeathcount
from CovidDeaths
where continent is not null
group by date
order by 1,2

--Looking at total population vs vaccination
--CTE
with popvsvac(continent,location,date,population,new_vaccinations,Rollingpeoplevaccinated)
as(
Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
nullif(sum(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date),0)
as Rollingpeoplevaccinated from
coviddeaths dea
join CovidVaccinations vac
on dea.location=vac.location 
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)

select *, (Rollingpeoplevaccinated/population)*100 from popvsvac

--Temp table
Drop table if exists #percentpopulationvaccinated
Create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population bigint,
new_vaccinations bigint,
Rollingpeoplevaccinated bigint
)
Insert Into #percentpopulationvaccinated
Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
nullif(sum(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date),0) as Rollingpeoplevaccinated from
coviddeaths dea
join CovidVaccinations vac
on dea.location=vac.location 
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3


select *,(Rollingpeoplevaccinated/population)*100 as percentpopulationvaccinated 
from #percentpopulationvaccinated

--Creating view to store data for later visualisation


Create view PercentPopulationvaccinated as 
Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
nullif(sum(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date),0) as Rollingpeoplevaccinated from
coviddeaths dea
join CovidVaccinations vac
on dea.location=vac.location 
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

select * from percentpopulationvaccinated






