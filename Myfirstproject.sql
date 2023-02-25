SELECT *
FROM Covid_Death
where continent is  null
ORder by 3,4

--Select *
--FROM [Covid_Vaccination ]
--ORDER BY 3,4

--Select Data that we are going to be using 

Select location, date , total_cases,new_cases,total_deaths,population
FROM Covid_Death
where continent is not null
Order by 1,2

--Looking at total cases vs Total Deaths 
--Show likelihood of dying if you contract covid in the countrys
Select location, date , total_cases,total_deaths,(total_deaths/total_cases)*100 as deaths_Percentage
FROM Covid_Death
Where location = 'India' and continent is not null
Order by 1,2

--Looking at total case Vs population
--Show the percentage of poplation who got covid
Select location, date , total_cases,population,(total_cases/population)*100 as population_affeted_by_covid
FROM Covid_Death
--Where location = 'India' and continent is not null
Order by 1,2

--Looking at countries with Highest infection Tate compared to population 
Select location, MAX(total_cases)as Highestinfectioncount , population ,max(total_cases/population)*100 as high_covid_case
FROM Covid_Death
--Where location like '%states%' and continent is not null
Group By location,population
Order by 4 DESC
-- Looking at countries with highest death rate
Select location, MAX(cast(total_deaths as bigint)) as countofdeath
FROM Covid_Death
Where continent is not null
Group By location,population
order by 2 DESC

--Let's Break things down by continent
Select  MAX(cast(total_deaths as bigint)) as countofdeath, continent
FROM Covid_Death
Where continent is not null
Group By continent

-- Breaking Gobal numbers 
Select   SUM(new_cases) as Number_of_new_cases,SUM(cast(new_deaths As bigint)) as number_of_death ,SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 As percentage_of_the_case--total_deaths,(total_deaths/total_cases)*100 as deaths_Percentage
FROM Covid_Death
--Where location = 'India' and 
Where continent is not null
--Group by date
order by 1

--Total Population and vaccination
Select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations ,
SUM(convert(bigint , vac.new_vaccinations)) Over (partition by dea.location order by dea.location , dea.date) as Rolling_people_vaccinated 
From Covid_Death as dea
Join [Covid_Vaccination ] vac on dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null 
Order by 2,3

--Use CTE
With Popvsvac (Continent, location , date , Population , new_vaccinations,Rolling_people_vaccinated)
As
(
Select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations ,
SUM(convert(bigint , vac.new_vaccinations)) Over (partition by dea.location order by dea.location , dea.date) as Rolling_people_vaccinated 
From Covid_Death as dea
Join [Covid_Vaccination ] vac on dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null 
--Order by 2,3
)

select *, (Rolling_people_vaccinated/Population)*100 rolling 
From Popvsvac
where (Rolling_people_vaccinated/Population)*100 is not null

--Temp Table 

Drop Table If exists #Percentpopulationvaccinated
Create Table #Percentpopulationvaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
date datetime ,
Population Float ,
New_vaccinations numeric , 
Rolling_people_vaccinated numeric)

Insert into #Percentpopulationvaccinated
Select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations ,
SUM(convert(bigint , vac.new_vaccinations)) Over (partition by dea.location order by dea.location , dea.date) as Rolling_people_vaccinated 
From Covid_Death as dea
Join [Covid_Vaccination ] vac on dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null 
Order by 2,3

select *
from #Percentpopulationvaccinated

--Creating view to store data for later visulation 

Create View Percentpopulationvaccinated as 
Select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations ,
SUM(convert(bigint , vac.new_vaccinations)) Over (partition by dea.location order by dea.location , dea.date) as Rolling_people_vaccinated 
From Covid_Death as dea
Join [Covid_Vaccination ] vac on dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null 
--Order by 2,3

select *
from Percentpopulationvaccinated
