SELECT * 
FROM `Covid project`.coviddeaths
Where continent is not null
ORDER BY 3,4;

-- SELECT * 
-- FROM `Covid project`.covidvaccinations
-- ORDER BY 3,4

-- Select Data that we are going to be using
 
SELECT location, date, total_cases, new_cases, total_deaths,population
FROM `Covid project`.coviddeaths
Where continent is not null;

-- looking at Total cases vs Total Deaths 
-- Shows the likelihood of dying if you contact covid in your country 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM `Covid project`.coviddeaths
WHERE location like '%states%' 
AND continent is not null;

-- Looking at Total Cases vs Pop 
-- Shows what percentage of Pop got covid 

SELECT location, date, total_cases, population, (total_cases/population)*100 as PopPercentage
FROM `Covid project`.coviddeaths
WHERE location like '%states%' 
AND continent is not null;

-- Looking at countries with highest infection rate compared to pop.

SELECT location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PercentPopInfected
FROM `Covid project`.coviddeaths
Where continent is not null
-- WHERE location like '%states%' 
GROUP by location, population 
ORDER BY PercentPopInfected desc;

-- Showing countries with the highest Death Count per Pop. 

SELECT location, MAX(cast(total_deaths AS Bigint)) as TotalDeathCount 
FROM `Covid project`.coviddeaths
Where continent is not null
-- WHERE location like '%states%' 
GROUP by location
ORDER BY TotalDeathCount desc;

-- LET'S BREAK THINGS DOWN BY CONTINENT 
SELECT location, MAX(cast(total_deaths AS Bigint)) as TotalDeathCount 
FROM `Covid project`.coviddeaths
Where continent is null
-- WHERE location like '%states%' 
GROUP by location
ORDER BY TotalDeathCount desc

-- Showing the continents with the Highest Death_count per population

SELECT location, MAX(cast(total_deaths AS Bigint)) as TotalDeathCount 
FROM `Covid project`.coviddeaths
Where continent is not null
-- WHERE location like '%states%' 
GROUP by continent 
ORDER BY TotalDeathCount desc;

-- Global numbers 

SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths,
 SUM(new_cases)/SUM(new_deaths)*100 as deathpercentage  -- total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM `Covid project`.coviddeaths
-- WHERE location like '%states%' 
WHERE continent is not null
Group by date
ORDER BY 1,2;


-- Looking at total Pop vs Vaccinations 
Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations, 
Sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
FROM `Covid project`.covidvaccinations vac
JOIN `Covid project`.coviddeaths dea
ON dea.location = vac.location 
and dea.date = vac.date 
WHERE dea.continent is not null 
ORDER by 2,3;

-- USE CTE 

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations, 
Sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
FROM `Covid project`.covidvaccinations vac
JOIN `Covid project`.coviddeaths dea
ON dea.location = vac.location 
and dea.date = vac.date 
WHERE dea.continent is not null 
-- ORDER by 2,3
)
Select *, (RollingPeopleVaccinated/Population)* 100 
FROM PopvsVac;

-- TEMP Table

DROP Table if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
(
continent nvarchar (255), 
location nvarcher (255), 
Date datetime, 
Population numeric, 
New_vaccination numeric,
RollingPeopleVaccinated numeric  
)

INSERT INTO #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations, 
Sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
FROM `Covid project`.covidvaccinations vac
JOIN `Covid project`.coviddeaths dea
ON dea.location = vac.location 
and dea.date = vac.date 
WHERE dea.continent is not null 
-- ORDER by 2,3
)
Select *, (RollingPeopleVaccinated/Population)* 100 
FROM #PercentPopulationVaccinated;


-- Creating View to store data for later visulizations 

Create View 
