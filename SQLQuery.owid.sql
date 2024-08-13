select*
from portfolioproject01.dbo.coviddeath
order by 3,4

--select*
--from portfolioproject01.dbo.Sheet1$_xlnm#_FilterDatabase
--order by 3,4

--select data that we are going to be using 

select Location,date,total_cases,new_cases,total_deaths,population
from portfolioproject01.dbo.Sheet1$
order by 1,2

--Looking at total cases vs total deaths
--shows likelihood if you track covid in your country

select Location,date,total_cases,total_deaths,(total_deaths/NULLIF(total_cases,0))*100 as DeathPercentage
from portfolioproject01.dbo.Sheet1$
where Location like '%India%'
order by 1,2


--looking total cases vs population
-- shows what percentage of population got covid

select Location,date,population,total_cases,(total_cases/NULLIF(population,0))*100 as PERCENTAGEOFPOPULATION
from portfolioproject01.dbo.Sheet1$
--where Location like '%India%'
order by 1,2

--Looking at highest infection rate compared to population
select Location,population,MAX(total_cases) AS HIGHESTINFECTIONCOUNT, MAX(total_cases/NULLIF(population,0))*100 as PERCENTAGEOFPOPULATION
from portfolioproject01.dbo.Sheet1$
--where Location like '%India%'
Group by Location,population
order by PERCENTAGEOFPOPULATION desc,HIGHESTINFECTIONCOUNT desc


--showing country highest death percentage
select Location,max(cast(total_deaths as int)) as totaldeath
from portfolioproject01.dbo.Sheet1$
--where Location like '%India%'
where continent is not null
Group by Location
order by totaldeath desc

--let break down by continent


select location,max(cast(total_deaths as int)) as totaldeath
from portfolioproject01.dbo.Sheet1$
--where Location like '%India%'
where continent is null
Group by location
order by totaldeath desc


--showing continent with a highest death case 

select continent,max(cast(total_deaths as int)) as totaldeath
from portfolioproject01.dbo.Sheet1$
--where Location like '%India%'
where continent is null
Group by continent
order by totaldeath desc


--global number
SELECT 
   date,
    SUM(New_Cases) AS TotalCases,
    SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
    CASE 
        WHEN SUM(new_Cases) = 0 THEN 0
        ELSE SUM(CAST(new_deaths AS INT)) /  SUM(new_Cases)* 100.0 
    END AS DeathPercentage
FROM 
    portfolioproject01.dbo.Sheet1$
WHERE 
    continent IS NOT NULL
GROUP BY 
    date
ORDER BY 
    TotalCases desc, TotalDeaths desc;

--looking at total popultion vs vaccinations
with popvsvac (Continent,Location,Date,Population,New_vaccinations,RollingPeoplevaccinatinated)
as
(
select death.Continent,death.Location,death.Date,death.Population,vacc.New_vaccinations,SUM(CONVERT(int,vacc.New_vaccinations)) over (partition by death.Location,death.date)as RollingPeoplevaccinatinated
from portfolioproject01.dbo.coviddeath as death
join portfolioproject01.dbo.covidvacc as vacc on death.location=vacc.location and death.date =vacc.date
where death.Continent is not null
)
SELECT*,(RollingPeoplevaccinatinated/population)*100
FROM popvsvac


--temp table 

DROP Table if exists #percentpopulationvaccinated
Create Table #percentpopulationvaccinated
(
continent nvarchar(225),
Location nvarchar(225),
Date datetime,
population numeric,
new_vaccine numeric,
RollingPeopleVaccinated numeric
)
insert into #percentpopulationvaccinated
select death.Continent,death.Location,death.Date,death.Population,vacc.New_vaccinations,SUM(CONVERT(int,vacc.New_vaccinations)) over (partition by death.Location,death.date)as RollingPeopleVaccinated
from portfolioproject01.dbo.coviddeath as death
join portfolioproject01.dbo.covidvacc as vacc on death.location=vacc.location and death.date =vacc.date
where death.Continent is not null

SELECT*,(RollingPeopleVaccinated/population)*100
FROM #percentpopulationvaccinated

--creating view to store data for later visualizations
create view percentpopulationvaccinated as
select death.Continent,death.Location,death.Date,death.Population,vacc.New_vaccinations,SUM(CONVERT(int,vacc.New_vaccinations)) over (partition by death.Location,death.date)as RollingPeopleVaccinated
from portfolioproject01.dbo.coviddeath as death
join portfolioproject01.dbo.covidvacc as vacc on death.location=vacc.location and death.date =vacc.date
where death.Continent is not null

select*
from percentpopulationvaccinated























