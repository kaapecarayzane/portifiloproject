select *  from CovidDeaths$


---select the data that were are going to use

select  *
from CovidDeaths$
order by 1,2
--looking the total-case and totoal desth
--show the likehood of your country
select  location,date,total_cases,total_deaths,(total_cases/total_deaths)*100 as dethpersentage
from CovidDeaths$
where location like'%africa%'
order by 1,2

--totalcase vc total popolation
--- show total percentage of got covid19
select  location,date, population,total_cases,(total_cases/population)*100 as popoltionpercentage
from CovidDeaths$
order by 1,2

--lookng at countraies with highest infection rate comparede popolation
select location,population,max(total_cases) as highestinvections ,max((total_cases/population)*100) as pertentageofpoputlion
from CovidDeaths$
group by location ,population
order by pertentageofpoputlion desc


----------------show countaries with highes death per population
select location,max(cast( total_deaths as int)) as highestdeath
from CovidDeaths$
where continent is  not  null
group by location 
order by highestdeath desc
----lets break into continent
select continent,location,max(cast( total_deaths as int)) as highestdeath
from CovidDeaths$
where continent is  not  null
group by continent ,location
order by highestdeath desc


--golobal numbet
select date,SUM(new_cases),sum(CAST(total_deaths as int)),sum(CAST(total_deaths as int))/SUM(new_cases)*100 as percenyageofdeath
from CovidDeaths$
group by date
order by 1,2
--------lookimg total papolution vc vacination

select deth.continent,deth.location,deth.date,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over(partition by deth.location  order by deth.location ,deth.date ) 
from CovidDeaths$ deth
join CovidVaccinations$  vac 
on deth.location=vac.location
and deth.date=vac.date
order by 2,3

------using cte---
with popvcvac(continent,location,date,population,new_vaccinations,rollongpopulationvacinated)
as(
select deth.continent,deth.location,deth.date,population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over(partition by deth.location  order by deth.location ,deth.date )  as rollongpopulationvacinated
from CovidDeaths$ deth
join CovidVaccinations$  vac 
on deth.location=vac.location
and deth.date=vac.date
)
select *, (rollongpopulationvacinated/population)*100
from  popvcvac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 