Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations

--order by 3,4


Select Location, date, total_cases, new_cases, total_deaths,population
From PortfolioProject..CovidDeaths
order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid

Select Location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where location like '%states%'
Group by Location, population 
order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by Location
order by TotalDeathCount desc

--Lets break things down by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


--Showing continents with highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths ,SUM(cast(new_deaths as int)) /SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date 
order by 1,2 



-- Lookig at Total Population vs Vaccinations 


Select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.LOcation Order by dea.location,dea.Date ) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null
order by 2,3

 --Use CTE

;With  PopvsVac (Continent ,Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.LOcation Order by dea.location,dea.Date ) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null
     --order by 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac
    
--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Population numeric,
Date datetime,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

 Select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.LOcation Order by dea.location,dea.Date ) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location = vac.location
     and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creatin View to store data for later visualizations



GO
Create View PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date , dea.population,
vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.LOcation Order by dea.location,dea.Date ) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location = vac.location
     and dea.date = vac.date
     where dea.continent is not null 
     --order by 2,3
  GO
Select *
From PercentPopulationVaccinated