select *
from portpro..CovidDeaths
order by 3,4

--select *
--from portpro..CovidVaccinations
--order by 3,4

--select data for using


select location, date, total_cases, new_cases, total_deaths, population
from portpro..CovidDeaths
order by 1,2 

--total cases vs total deaths

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portpro..CovidDeaths 
where location like '%India%'
order by 1,2

--total cases vs population


select location, date, total_cases,population, (total_cases/population)*100 as CasePercentage
from portpro..CovidDeaths 
where location like '%India%'
order by 1,2


--highest infection rate as compared to population

select location, MAX(total_cases) as "Highest Infection Count" ,population, MAX(total_cases/population)*100 as "% of Population Infected"
from portpro..CovidDeaths 
--where location like '%India%'
group by location, population
order by "% of Population Infected" desc

--highest death count per population


select location, MAX(cast(total_deaths as int)) as "Total Death" 
from portpro..CovidDeaths 
--where location like '%India%'
Where continent is not null
group by location, population
order by "Total Death" desc


--conttinent wise

select continent, MAX(cast(total_deaths as int)) as "Total Death" 
from portpro..CovidDeaths 
--where location like '%India%'
Where continent is not null
Group by continent
order by "Total Death" desc


---GLOBAL NUMBERS


select  SUM(NEW_cases) AS "NEW CASES" , SUM(CAST(NEW_DEATHS AS INT)) AS "nEW DEATHS", SUM(CAST(NEW_DEATHS AS INT))/SUM(NEW_cases)*100 as DeathPercentage
from portpro..CovidDeaths 
--where location like '%India%'
WHERE continent IS NOT NULL
--GROUP BY date
order by 1,2



---VACCINATION
--TOTAL POPULATION VS VACCINATION


SELECT DEA.CONTINENT, DEA.LOCATION, DEA.DATE, DEA.POPULATION, DEA.NEW_VACCINATIONS
, SUM(CAST(DEA.NEW_VACCINATIONS AS INT)) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION, DEA.DATE) AS "CUMULATIVE VACCINATION"
from portpro..CovidDeaths DEA
JOIN portpro..CovidVaccinations VAC
ON DEA.LOCATION = VAC.LOCATION
AND DEA.DATE= VAC.DATE
WHERE DEA.continent IS NOT NULL
ORDER BY 1,2,3

---CTE

WITH POPVSVAC (CONTINENT, LOCATION, DATE, POPULATION,NEW_VACCINATIONS, "CUMULATIVE VACCINATION")
AS 
(
SELECT DEA.CONTINENT, DEA.LOCATION, DEA.DATE, DEA.POPULATION, DEA.NEW_VACCINATIONS
, SUM(CAST(DEA.NEW_VACCINATIONS AS INT)) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION, DEA.DATE) AS "CUMULATIVE VACCINATION"
from portpro..CovidDeaths DEA
JOIN portpro..CovidVaccinations VAC
ON DEA.LOCATION = VAC.LOCATION
AND DEA.DATE= VAC.DATE
WHERE DEA.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, ("CUMULATIVE VACCINATION"/POPULATION)*100 as "total vaccination %"
FROM POPVSVAC

---TEMP TABLE
DROP TABLE IF EXISTS #PERCENTPOPULATIONVACCINATED
CREATE TABLE #PERCENTPOPULATIONVACCINATED
(
CONTINENT NVARCHAR(255),
LOCATION NVARCHAR(255),
DATE DATETIME,
POPULATION NUMERIC, 
NEW_VACCINATIONS NUMERIC,
"CUMULATIVE VACCINATION" NUMERIC
)

INSERT INTO #PERCENTPOPULATIONVACCINATED



SELECT DEA.CONTINENT, DEA.LOCATION, DEA.DATE, DEA.POPULATION, DEA.NEW_VACCINATIONS
, SUM(CAST(DEA.NEW_VACCINATIONS AS INT)) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION, DEA.DATE) AS "CUMULATIVE VACCINATION"
from portpro..CovidDeaths DEA
JOIN portpro..CovidVaccinations VAC
ON DEA.LOCATION = VAC.LOCATION
AND DEA.DATE= VAC.DATE
--WHERE DEA.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, ("CUMULATIVE VACCINATION"/POPULATION)*100 as "total vaccination %"
FROM #PERCENTPOPULATIONVACCINATED




--VISUALISATION

CREATE VIEW PERCENTAGEPOPULATIONVACCINATED AS
SELECT DEA.CONTINENT, DEA.LOCATION, DEA.DATE, DEA.POPULATION, DEA.NEW_VACCINATIONS
, SUM(CAST(DEA.NEW_VACCINATIONS AS INT)) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION, DEA.DATE) AS "CUMULATIVE VACCINATION"
from portpro..CovidDeaths DEA
JOIN portpro..CovidVaccinations VAC
ON DEA.LOCATION = VAC.LOCATION
AND DEA.DATE= VAC.DATE
WHERE DEA.continent IS NOT NULL
--ORDER BY 2,3

SELECT * 
FROM PERCENTAGEPOPULATIONVACCINATED



