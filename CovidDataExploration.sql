/*
Covid Data Exploration 
*/

Select *
From CovidDeaths
Where continent is not null 
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%canada%'
and continent is not null 
order by 1,2


-- Total Cases vs Population

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,
Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null 
order by 1,2

-- Total Population vs Vaccinations

Select covd.continent, covd.location, covd.date, covd.population, covac.new_vaccinations, 
SUM(CONVERT(int,covac.new_vaccinations)) 
OVER (Partition by covd.Location Order by covd.location, covd.Date) as RollingPeopleVaccinated
From CovidDeaths covd
Join CovidVaccinations covac
	On covd.location = covac.location
	and covd.date = covac.date
where covd.continent is not null 
order by 2,3

-- Calculation on Partition By 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) as
(Select covd.continent, covd.location, covd.date, covd.population, covac.new_vaccinations, 
SUM(CONVERT(int,covac.new_vaccinations)) OVER (Partition by covd.Location Order by covd.location, covd.Date) as 
RollingPeopleVaccinated
From CovidDeaths covd
Join CovidVaccinations covac
	On covd.location = covac.location
	and covd.date = covac.date
where covd.continent is not null)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By 

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)
Insert into #PercentPopulationVaccinated
Select covd.continent, covd.location, covd.date, covd.population, covac.new_vaccinations, 
SUM(CONVERT(int,covac.new_vaccinations)) OVER (Partition by covd.Location Order by covd.location, covd.Date) as 
RollingPeopleVaccinated
From CovidDeaths covd
Join CovidVaccinations covac
	On covd.location = covac.location
	and covd.date = covac.date
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- store data for later visualizations

Create View PercentPopulationVaccinated as
Select covd.continent, covd.location, covd.date, covd.population, covac.new_vaccinations, 
SUM(CONVERT(int, covac.new_vaccinations)) OVER (Partition by covd.Location Order by covd.location, covd.Date) as 
RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On covd.location = covac.location
	and covd.date = covac.date
where covd.continent is not null 

