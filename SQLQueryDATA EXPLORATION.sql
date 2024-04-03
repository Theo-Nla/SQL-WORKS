select *
from [ATA Projects].[dbo].[CovidDeaths]

select *
from [ATA Projects].[dbo].[CovidVaccinations]

select location, date, total_cases, new_cases, total_deaths, population
from [ATA Projects].[dbo].[CovidDeaths]
order by 1,2

---------Likelihood of death after contracting the virus IN nigeria


select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [ATA Projects].[dbo].[CovidDeaths]
where location = 'AFRICA'
order by 1,2

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [ATA Projects].[dbo].[CovidDeaths]
where location = 'Nigeria'
order by 1,2

------- Total cases vs population

select location, date,population, total_cases,  (total_cases/population)*100 as PercentageOfPopulationInfected
from [ATA Projects].[dbo].[CovidDeaths] 
where location = 'Nigeria'
order by 1,2


-------countries with highest infection rate compared to population

select location,  population, max(total_cases) as HighestInfectionCount,  max((total_cases/population))*100 as PercentageOfPopulationInfected
from [ATA Projects].[dbo].[CovidDeaths]  
Group by location,population
--order by 1,2
order by PercentageOfPopulationInfected desc 

-------countries with the highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from [ATA Projects].[dbo].[CovidDeaths]
where continent is not null
group by location
order by TotalDeathCount desc 

select *
from [ATA Projects].[dbo].[CovidDeaths]
where continent is null

--------continent total death count

select location, max(cast(total_deaths as int)) as TotalDeathCount
from [ATA Projects].[dbo].[CovidDeaths] 
where continent is null
group by location
order by TotalDeathCount desc 

-------GLOBAL NUMBERS

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [ATA Projects].[dbo].[CovidDeaths] 
--where location = 'Nigeria'
Where continent is not null
order by 1,2

select sum(new_cases) as total_cases, sum(cast(new_deaths as int))as total_deaths, sum (cast(new_deaths as int))/sum(new_cases)*100 as deathPercentage
From [ATA Projects].[dbo].[CovidDeaths]
where continent is not null
order by 1,2

-------Amount of people vaccinated in the world: Total Population vs World
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from [ATA Projects].[dbo].[CovidDeaths] dea
join [ATA Projects].[dbo].[CovidVaccinations] vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-------Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated 
From [ATA Projects].[dbo].[CovidDeaths]  dea
Join [ATA Projects].[dbo].[CovidVaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-------Using CTE to perform Calculation on Partition By in previous query

With POPvsVAC (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [ATA Projects].[dbo].[CovidDeaths] dea
Join [ATA Projects].[dbo].[CovidVaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From POPvsVAC


--------Using Temp Table to perform Calculation on Partition By in previous query

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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [ATA Projects].[dbo].[CovidDeaths] dea
Join [ATA Projects].[dbo].[CovidVaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [ATA Projects].[dbo].[CovidDeaths] dea
Join [ATA Projects].[dbo].[CovidVaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


Select * from PercentPopulationVaccinated
