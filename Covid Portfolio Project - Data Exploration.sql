Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVacctination$
--Order by 3,4

-- Select Data that we aare going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likehood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Indonesia%'
Where total_deaths is not null
order by 1,2


-- Looking at Total Cases vs Population
-- Show what percentage of Population got Covid

Select location, total_cases, population, (total_cases/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
-- Where location like '%Indonesia%'
Where total_cases is not null
Order by 1,2


-- Looking at Countries with Highet Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
-- Where location like '%Indonesia%'
Group by location, population
Order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Indonesia&'
Where continent is not null
Group by location
Order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing Continents with Highest death count per Population 

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%Indonesia%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


 -- GLOBAL NUMBER
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
 SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Indonesia%'
Where continent is not null
--Group by date
Order by 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
Order by 2,3


-- Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinated numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date =vac.date
Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	dea.date) as RollingPopulationVaccinated
	--, (RollingPopulationVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3


Select *
From PercentPopulationVaccinated