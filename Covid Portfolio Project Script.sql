--Select *
--From PortfolioProject..CovidDeaths$
--where location = 'Afghanistan' And new_deaths > 2
--Order By new_deaths desc;

-- Select data that we are going to be using 
Select 
location , date , total_cases , new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$

-- Looking At Total Cases Vs Total Deaths
-- Shows Likelihood Of Dying If You Contarct Covid In Your Country
Select location, date, total_cases,total_deaths,Convert(decimal(15,2),total_deaths) /Convert(decimal(15,2),total_cases) *100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where location like 'Pales%'
order by 1,2


--Looking At Total Cases Vs Population
-- Shows What Percentage Of Population Got Covid
Select location, date,population, total_cases,Cast(total_deaths as float) /Cast(total_cases as int) *100 as InfectionRate
From PortfolioProject..CovidDeaths$
Where continent Is Not Null
--where location LIKE 'Pales%'
order by 1,2

-- Looking At Countries With Highest Infection Rate Compared To Population

Select 
location ,
population ,
Max(Cast(total_cases as int)) as TotalCases,
Max(Cast(total_cases as float) /Cast(population as int) *100) as PopulationInfectionRate
From PortfolioProject..CovidDeaths$
Where continent Is Not Null
--where location LIKE 'Pales%'
Group By  location ,population
Order by PopulationInfectionRate Desc


-- Shows Countries With Highest Death Count Per Population

Select
location,
Max(Cast (total_deaths as float)) TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent Is Not Null
Group By location
Order By TotalDeathCount Desc

-- Shows Continent With Highest Death Count Per Population

Select
location,
Max(Cast (total_deaths as float)) TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent Is  Null And location Not Like '%income' And location Not Like 'World'
Group By location
Order By TotalDeathCount Desc


-- Shows Highest Death Count Per Population according to income level

Select
location,
Max(Cast (total_deaths as float)) TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent Is  Null And location Like '%income' And location Not Like 'World'
Group By location
Order By TotalDeathCount Desc

-- Shows The Total Infected Cases Vs Total Death Cases And Death Percentage Per Year

Select
YEAR(date) as year,
Sum(new_cases) as total_cases,
Sum(new_deaths) as total_deaths,
Case 
When Sum(new_cases) < 0 THEN Null
Else Round(Sum(new_deaths) / Sum(new_cases) * 100,2) End As DeathPercentage 
From PortfolioProject..CovidDeaths$
group by YEAR(date)
ORDER by 3 desc

-- Looking At Total Population Vs Total Vaccination

Select dea.continent,dea.location, dea.date,dea.population, vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as float)) Over (Partition By dea.location Order By dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccination$ vac
On dea.location = vac.location And dea.date = vac.date
Where dea.continent Is Not Null --And dea.location = 'Palestine'
Order By 2,3

-- Using CTE To Find The Population Vaccinated Percentage

With PopvsVac AS 
(Select dea.continent,dea.location, dea.date,dea.population, vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as float)) Over (Partition By dea.location Order By dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccination$ vac
On dea.location = vac.location And dea.date = vac.date
Where dea.continent Is Not Null --And dea.location = 'Palestine'
--Order By 2,3
)
Select * , (RollingPeopleVaccinated / population) *100 as PopulationVaccinatedPercentage
From PopvsVac
ORDER BY location,date



-- Using Temp Table To Find The Population Vaccinated Percentage

Drop Table If Exists #PopulationVaccinatedPercentage 

Create Table #PopulationVaccinatedPercentage
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
Insert Into #PopulationVaccinatedPercentage 
Select dea.continent,dea.location, dea.date,dea.population, vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as float)) Over (Partition By dea.location Order By dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccination$ vac
On dea.location = vac.location And dea.date = vac.date
Where dea.continent Is Not Null --And dea.location = 'Palestine'
--Order By 2,3

Select * , (RollingPeopleVaccinated / population) *100 as PopulationVaccinatedPercentage
From #PopulationVaccinatedPercentage
ORDER BY location,date


-- Creating View To Use Later In The Visualization

Create View PopulationVaccinatedPercentage As
Select dea.continent,dea.location, dea.date,dea.population, vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as float)) Over (Partition By dea.location Order By dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccination$ vac
On dea.location = vac.location And dea.date = vac.date
Where dea.continent Is Not Null --And dea.location = 'Palestine'
--Order By 2,3

Select * From PopulationVaccinatedPercentage
Order by location , date

