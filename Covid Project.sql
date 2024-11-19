select *
from CovidAnalysis..CovidDeaths
order by 3,4

select *
from CovidAnalysis..CovidVaccinations
order by 3,4


--Select data that i am going to use
select date, population, total_cases, new_cases,total_deaths
from CovidAnalysis..CovidDeaths
where continent is not null
order by 1,2



--total deaths against total cases
--used case because having error because of division by 0
select date, population, total_cases, new_cases,total_deaths,
CASE 
when total_cases> 0 then (total_deaths/total_cases)*100
Else 0
end as death_percentage
from CovidAnalysis..CovidDeaths
where location like '%states%' and continent is not null
order by death_percentage desc



--total cases against the population
select location ,MAX(total_cases) as Highest_Cases, MAX((total_cases/population))*100 As Percentage_Population_infected
from CovidAnalysis..CovidDeaths
where continent is not null
Group by Location
order by Percentage_Population_infected desc


--countries with highest death count per population 
select location, max(total_deaths) as total_deaths
from CovidAnalysis..CovidDeaths
where continent is not null
group by location
order by total_deaths desc


-- sorting data by continent
select continent, max(total_deaths) as total_deaths
from CovidAnalysis..CovidDeaths
where continent is not null
group by continent
order by total_deaths desc



-- Looking at total population vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
       SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RollingPeopleVacinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations vac 
    ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- using CTE to show the percentage of the population vaccinated
with PopvsVac ( Continent, location, date, population, new_vaccinations, RollingPeopleVacinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
       SUM(CONVERT(bigint,  vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RollingPeopleVacinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations vac 
    ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

)

select *, (RollingPeopleVacinated/population)*100 as VaccinationPercentage
from PopvsVac


-- ceate view for later visualization
create view PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
       SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RollingPeopleVacinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations vac 
    ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

select * 
from PercentPopulationVaccinated

