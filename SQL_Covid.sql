-- Looking at Total_Cases vs Total_Deaths
select location, date,total_cases,total_deaths,(convert(float,total_deaths)/total_cases) *100 as fatality_rate
from portfolio_project..Covid_deaths
order by location,date


-- looking at percentage of population infected
select location, date,population, total_cases,round((convert(float,total_cases)/population) *100,4) as population_infected
from portfolio_project..Covid_deaths
order by location,date

--looking at countries with highest population percentage
select location,population, max(total_cases) as total_infected,max(round((convert(float,total_cases)/population) *100,4)) as population_infected
from portfolio_project..Covid_deaths
group by location,population
order by population_infected desc

--looking at countries with highest fatality rate
select location,population,max(total_deaths) as total_deaths_tillnow,max((convert(float,total_deaths)/population)) *100 as fatality_rate
from portfolio_project..Covid_deaths
where continent is not null
group by location,population
order by fatality_rate desc

-- looking continent wise
select location,max(total_deaths) as total_deaths_tillnow,max((convert(float,total_deaths)/population)) *100 as fatality_rate
from portfolio_project..Covid_deaths
where continent is  null
group by location
order by total_deaths_tillnow desc

-- looking at global values
select date,sum(total_cases) as total_infected,sum(total_deaths) as total_died,(convert(float,sum(total_deaths))/sum(total_cases)) *100 as fatality_rate
from portfolio_project..Covid_deaths
where continent is not null
group by date
order by date

-- Total population vs vacination
select cd.date,cd.location,cd.population,cv.new_vaccinations,sum(cast (new_vaccinations as bigint) ) over (partition by cd.location order by cd.location,cd.date) as total_vaccines_used
from portfolio_project..Covid_deaths cd
join portfolio_project..Covid_vaccination cv
    on cd.location=cv.location and cd.date=cv.date
	where cd.continent is not null and new_vaccinations is not null
order by location


-- comparing total vaccinations with population
with cte as (
select cd.date,cd.location,cd.population,cv.new_vaccinations,sum(cast (new_vaccinations as bigint) ) over (partition by cd.location order by cd.location,cd.date) as total_vaccines_used
from portfolio_project..Covid_deaths cd
join portfolio_project..Covid_vaccination cv
    on cd.location=cv.location and cd.date=cv.date
	where cd.continent is not null and new_vaccinations is not null)
select date,location,population,total_vaccines_used,(total_vaccines_used/population)*100 as Population_Percentage_Vaccinated
from cte
where location ='india'
order by location