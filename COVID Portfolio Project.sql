Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidDeaths
--order by 3,4

-- select the date to use

Select location, date, total_cases, new_cases,total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
--
Select location, date, total_cases,total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

--Looking at Total Cases Vs Population
--Shows what percentage of population got covid
Select location, date, total_cases,population, (total_cases/population)* 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%states%'
Where continent is not null
order by 1,2


--Looking at countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))* 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
--where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc


--LET'S BREAK THINGS DOWN BY CONTINENT


--Showing Continents with the highest death count
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
Where continent is not null
Group by date
order by 1,2


----Looking at total population vs vaccinations
--Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations 
--, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--from PortfolioProject..CovidDeaths dea
--join PortfolioProject..CovidVaccinations vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null
--order by 1,2,3

--use CTE
With PopvsVac (Continent, location, date, population,New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
Select * , (RollingPeopleVaccinated / population)*100
from PopvsVac


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
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 1,2,3

Select * , (RollingPeopleVaccinated / population)*100
from #PercentPopulationVaccinated

--Creating View to store data for visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3


Select *
From PercentPopulationVaccinated