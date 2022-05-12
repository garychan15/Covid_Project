SELECT * 
FROM Covid_Project ..covid_deaths
order by 3,4

--SELECT * 
--FROM Covid_Project ..covid_vaccination
--order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid_Project ..covid_deaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract the virus

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_rate
FROM Covid_Project ..covid_deaths
Where location like '%United States%'
order by 1,2

-- Looking at Total Cases by the population
SELECT location, date, population, total_cases, (total_cases/population)*100 as case_rate
FROM Covid_Project ..covid_deaths
Where location like '%United States%'
order by 1,2

-- Which country has the highest infection rate 
SELECT location, population, MAX(total_cases) as highest_infection_count, MAX(total_cases/population)*100 as max_case_rate
FROM Covid_Project ..covid_deaths
Where continent is not null
group by location, population
order by max_case_rate DESC

-- Which country has the highest death rate 
SELECT location, MAX(cast(total_deaths as int)) as total_death_count, MAX(cast(total_deaths as int)/population)*100 as max_death_rate
FROM Covid_Project ..covid_deaths
Where continent is not null
group by location
order by total_death_count DESC


--Lets look at deaths by continents
SELECT location, MAX(cast(total_deaths as int)) as total_death_count
FROM Covid_Project ..covid_deaths
Where continent is null
group by location
order by total_death_count DESC

-- Global numbers

SELECT date, SUM(new_cases) as case_count, SUM(cast(new_deaths as int)) as death_count --total_deaths, (total_deaths/total_cases)*100 as death_rate
FROM Covid_Project ..covid_deaths
Where continent is null 
Group By date
order by 1,2

SELECT SUM(new_cases) as case_count, SUM(cast(new_deaths as int)) as death_count --total_deaths, (total_deaths/total_cases)*100 as death_rate
FROM Covid_Project ..covid_deaths
Where continent is null
order by 1,2

-- Looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, 
SUM(Convert(bigint, vax.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingCountVaxed
From Covid_Project ..covid_deaths dea
Join Covid_Project ..covid_vaccination vax
	On dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null

--USE CTE (Common Table Expressions)

With PopVsVax (Continent, Location, Date, Population, new_vaccinations, RollingCountVaxed)
as(
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, 
SUM(Convert(bigint, vax.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingCountVaxed
From Covid_Project ..covid_deaths dea
Join Covid_Project ..covid_vaccination vax
	On dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
)
Select * , (RollingCountVaxed/Population)*100 as Percentage_Vaxed
From PopVsVax

--Create View

Create View PopVsVax as
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, 
SUM(Convert(bigint, vax.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingCountVaxed
From Covid_Project ..covid_deaths dea
Join Covid_Project ..covid_vaccination vax
	On dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
--order by 2,3