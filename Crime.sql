-- Cleaning The Dataset

-- Null Value Cleaning 

delete from Crimes 
where date_reported is null

update Crimes 
set 
location_description = COALESCE(location_description,'Not Available'),
primary_type = COALESCE(primary_type,'Not Available'),
primary_description = COALESCE(primary_description,'Not Available'),
arrest = COALESCE(cast(arrest as varchar(10)),'Not Available'),
domestic = COALESCE(cast(domestic as varchar(10)),'Not Available'),
community_area = COALESCE(cast(community_area as varchar(10)),'Not Available'),
latitude = COALESCE(cast(latitude as varchar(100)),'Not Available'),
longitude = COALESCE(cast(latitude as varchar(100)),'Not Available'),
location = COALESCE(cast(location as varchar(100)),'Not Available')

-- Creating Function for proper case 

CREATE FUNCTION [dbo].[InitCap] ( @InputString varchar(4000) ) 
RETURNS VARCHAR(4000)
AS
BEGIN

DECLARE @Index          INT
DECLARE @Char           CHAR(1)
DECLARE @PrevChar       CHAR(1)
DECLARE @OutputString   VARCHAR(255)

SET @OutputString = LOWER(@InputString)
SET @Index = 1

WHILE @Index <= LEN(@InputString)
BEGIN
    SET @Char     = SUBSTRING(@InputString, @Index, 1)
    SET @PrevChar = CASE WHEN @Index = 1 THEN ' '
                         ELSE SUBSTRING(@InputString, @Index - 1, 1)
                    END

    IF @PrevChar IN (' ', ';', ':', '!', '?', ',', '.', '_', '-', '/', '&', '''', '(')
    BEGIN
        IF @PrevChar != '''' OR UPPER(@Char) != 'S'
            SET @OutputString = STUFF(@OutputString, @Index, 1, UPPER(@Char))
    END

    SET @Index = @Index + 1
END

RETURN @OutputString

END
GO

-- Proper Case For Primary_type , Primary_Description , Location_description

update Crimes
set primary_type = [dbo].InitCap(primary_type),
primary_description = [dbo].InitCap(primary_description),
location_description = [dbo].InitCap(location_description),
city_block = [dbo].InitCap(city_block)

-- Making Season Column and adding the season 
alter table Crimes 
add  Season Varchar(100)

update Crimes
set Season = case when 
MONTH(date_reported) in (12,1,2) then '1' 
when MONTH(date_reported) in (3,4,5) then '2' 
when MONTH(date_reported) in (6,7,8) then '3' 
when Month(date_reported) in (9,10,11) then '4'
end



-- Total Number Of Crime Committed During 2018 to 2023

select count(*) as Total_Crime 
from Crimes

-- What is the count of Homicides, Battery and Assaults reported?

select primary_type as crime , count(*) as crime_committed
from Crimes
where primary_type in ('Homicide', 'Battery','Assault')
group by primary_type
order by crime_committed desc

-- Which are the 3 most common crimes reported and what percentage amount are they from the total amount of reported crimes?

with cte as (select primary_type , count(*) as crime_committed
from Crimes
group by primary_type
)

select top 3 primary_type ,crime_committed,round(100*cast(crime_committed as float)/sum(crime_committed) over(),2) as Percentage_Of_Crime
from cte
order by Percentage_Of_Crime desc

--What are the top ten communities that had the MOST amount of crimes reported? Include the current population, density and order by the number of reported crimes.
select name , population , density , crime_committed 
from (
select name,population,density,crime_committed,DENSE_RANK() over(order by crime_committed desc) as rank
from (select  name , population , density , count(*) as crime_committed
from Crimes as c
inner join areas as a 
on c.community_area = a.community_id
group by name , population , density ) as sub) as sub_2
where rank <= 10

-- What are the top ten communities that had the LEAST amount of crimes reported? Include the current population, density and order by the number of reported crimes.

select name , population , density , crime_committed 
from (
select name,population,density,crime_committed,DENSE_RANK() over(order by crime_committed asc) as rank
from (select  name , population , density , count(*) as crime_committed
from Crimes as c
inner join areas as a 
on c.community_area = a.community_id
group by name , population , density ) as sub) as sub_2
where rank <= 10

-- What month had the most crimes reported

select top 1 DATENAME(month,date_reported) as month , count(*) as crime_committed
from Crimes
group by DATENAME(month,date_reported)
order by crime_committed desc

--  What month had the most homicides reported

select top 1 datename(month,date_reported) as month , count(*) as Homicides_Committed 
from Crimes
where primary_type = 'Homicide'
group by datename(month,date_reported)
order by Homicides_Committed desc

-- List the most violent year and the number of arrests with percentage.  Order by the number of crimes in decending order. Determine the most violent year by the number of reported Homicides, Assaults and Battery for that year.

select year , crime_committed , concat(arrest,' ( ',round(100*cast(arrest as float)/sum(arrest) over(),2),' )' , '%') as percentage_of_total_arrest
from (
select year(date_reported) as year , count(*) as crime_committed , sum(cast(arrest as int)) as arrest
from Crimes
where primary_type in ('Homicide', 'Assault','Battery')
group by year(date_reported)
) as sub
order by crime_committed desc

-- List the day of the week, year the highest number of reported crimes for days

select datename(day,date_reported) as day ,count(*) as Crime_Committed
from Crimes
group by datename(day,date_reported)
order by Crime_Committed desc

-- List the most consecutive days where a homicide occured and the timeframe.

WITH diff AS (
    SELECT date_reported,DATEDIFF(day, LAG(date_reported) OVER (ORDER BY date_reported), date_reported) AS date_diff
FROM 
Crimes
WHERE 
primary_type = 'Homicide'
)
SELECT 
MIN(date_reported) AS start_date,
MAX(date_reported) AS end_date,
COUNT(*) AS consecutive_days
FROM 
    diff
WHERE 
date_diff = 1
GROUP BY 
date_diff;

-- What are the top 10 most common locations for reported crimes and the number of reported crime (add percentage) 

select top 10 location ,  Crime_Committed ,round(100* cast(Crime_Committed as float)/sum(Crime_committed) over(),2) as percentage
from (
select location_description as location , count(*) as Crime_Committed
from Crimes
group by location_description 
) as sub_1
order by Crime_Committed desc

-- Calculate the year over year growth in the number of reported crimes.

select year , Crime_Committed,Crime_Previous_Year,round(((cast(Crime_Committed as float) / Crime_Previous_Year) - 1)*100,2) as Percentage_Change
from (
select year , Crime_Committed , lag(Crime_Committed) over(order by year ) as Crime_Previous_Year
from (select DATENAME(year,date_reported) as year , count(*) as Crime_Committed
from Crimes
group by DATENAME(year,date_reported)) as sub_1 ) as sub_2

 --Calculate the year over year growth in the number of reported domestic violence crimes.

 select year , total_domestic_crime,previous_year_domestic_crime,concat(round((total_domestic_crime / previous_year_domestic_crime - 1) * 100,2),'%')
 from (select year , total_domestic_crime , lag(total_domestic_crime) over(order by year) as previous_year_domestic_crime
from (select datename(year,date_reported) as year ,sum(cast(domestic as float)) as total_domestic_crime
from Crimes
group by datename(year,date_reported)) as sub_1) as sub_2
order by year 

-- Calculate the cumulative Month over Month growth in the number of reported crimes

select month_name , crime_committed_month,previous_month,concat(round(((cast(crime_committed_month as float)/ previous_month) - 1 ) * 100,2),' %')
from (
select  month_name, crime_committed_month,LAG(crime_committed_month) over(order by month) as previous_month
from (
select month(date_reported) as month ,count(*) as crime_committed_month,DATENAME(MONTH,date_reported) as month_name
from Crimes
group by month(date_reported),DATENAME(MONTH,date_reported) ) as sub_1) as sub_2

--  List the number of crimes seasonal reported and seasonal growth

select seasons , Crime_Committed,previous_season_crime,round((cast(Crime_Committed as float) / previous_season_crime - 1 ) * 100,2) as Percentage_change
from (
select case when 
Season = 1 Then 'Winter' 
when Season = 2 Then 'Spring'
when Season = 3 Then 'Summer'
when Season = 4 Then 'Autumn'
end as seasons ,
Crime_Committed , lag(Crime_Committed) over(order by Season) as previous_season_crime
from (
select Season , count(*) as Crime_Committed
from Crimes
group by Season ) as sub_1 ) as sub_2
