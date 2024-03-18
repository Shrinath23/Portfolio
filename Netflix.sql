-- Cleaning The Dataset 
-- Fixing the null values
update titles 
set age_certification = coalesce(age_certification , 'Not Available')

update titles 
set seasons = COALESCE(seasons , 0.0 ),
imdb_id = COALESCE(imdb_id , 'Not Available'),
imdb_score = COALESCE(imdb_score , 0),
imdb_votes = COALESCE(imdb_votes , 0),
tmdb_popularity = coalesce(tmdb_popularity,0.0);

update Actor
set  character = coalesce(character , 'Not Available')
where role = 'ACTOR'

update Actor
set  character = coalesce(character , 'Director')
where role = 'DIRECTOR'

-- Proper Capitalize in role Column
update Actor
set role = UPPER(left(role, 1 )) + lower(right(role , len(role) - 1))

-- Removing Square Bracket and ' from production countries
update titles
set production_countries = replace(replace(REPLACE(production_countries,'[' ,''),']',''),'''','')

-- Creating Hours column for runtime 

alter table titles
add hours_runtime float

update titles
set hours_runtime = round(CAST(runtime as float) / 60,2)

-- Adding Category based on the Hours Runtime 
alter table titles 
add Category varchar(100)

update titles
set Category =  CASE 
        WHEN hours_runtime <= 0.5 THEN 'less than or Equal than 30 min' 
        WHEN hours_runtime > 0.5 AND hours_runtime < 1 THEN 'more than  30 min '
        WHEN hours_runtime >= 1 AND hours_runtime <= 1.5 THEN 'more than or Equal to  1 hour but less than 1.5 hour'
        WHEN hours_runtime > 1.5 And hours_runtime <= 2 Then 'More than 1.5 but equal to 2 hours'
		else 'More than 2 Hours'
    END

-- Which movies and shows on Netflix ranked in the top 10 and bottom 10 based on their IMDB scores?

-- Top 10 Movie Based on IMDB Score

select title , score
from (SELECT title,DENSE_RANK() OVER (ORDER BY ROUND(imdb_score, 2) DESC) AS rank,ROUND(imdb_score, 2) AS score
FROM titles
WHERE type = 'Movie') as sub_1
where rank <= 10
order by score desc, title desc 

-- Top 10 Show Based on IMDB Score
select title , score
from (SELECT title,DENSE_RANK() OVER (ORDER BY ROUND(imdb_score, 2) DESC) AS rank,ROUND(imdb_score, 2) AS score
FROM titles
WHERE type = 'Show') as sub_1
where rank <= 10
order by score desc, title desc 

-- Bottom 10 Movie Based on IMDB Score
select title , score 
from (SELECT title,DENSE_RANK() OVER (ORDER BY ROUND(imdb_score, 2) asc) AS rank,ROUND(imdb_score, 2) AS score
FROM titles
WHERE type = 'Movie' and  ROUND(imdb_score, 2) > 0) as sub_1
where rank <= 10
order by score ASC, title desc 

-- Bottom 10 Movie Based on IMDB Score
select title , score 
from (SELECT title,DENSE_RANK() OVER (ORDER BY ROUND(imdb_score, 2) asc) AS rank,ROUND(imdb_score, 2) AS score
FROM titles
WHERE type = 'Show' and  ROUND(imdb_score, 2) > 0) as sub_1
where rank <= 10
order by score ASC, title desc 

-- How many movies and shows fall in each decade in Netflix's library?

select case when release_year < 2020 then concat(floor(release_year/10)* 10,'s') else 
concat(floor(release_year/10)* 10,'s',' ','till now') end as decade , count(*) as Netflix_Release
from titles
group by case when release_year < 2020 then concat(floor(release_year/10)* 10,'s') else 
concat(floor(release_year/10)* 10,'s',' ','till now') end 
order by decade

-- The Percentage Change in the Number of Netflix Releases from Decade to Decade, compared to the Previous Decade.

with Decade as (select case when release_year < 2020 then concat(floor(release_year/10)* 10,'s') else 
concat(floor(release_year/10)* 10,'s',' ','till now') end as decade , count(*) as Netflix_Release
from titles
group by case when release_year < 2020 then concat(floor(release_year/10)* 10,'s') else 
concat(floor(release_year/10)* 10,'s',' ','till now') end 
)

select decade , Concat(Round((cast(Netflix_Release as float)/Pervious_Year_Release  - 1) *100 , 2 ) , '%') as PCT_Change
from (select decade,Netflix_Release,lag(Netflix_Release,1) over(order by decade asc) as Pervious_Year_Release 
from Decade) as sub_1
where decade != '2020s till now' 

-- How did age-certifications impact the IMDB Score ?

select distinct age_certification  , round(AVG(imdb_score),2) as average, count(*) as count
from titles
where age_certification != 'Not Available'
group by age_certification
order by average desc , count  

-- Which genres are the most common?

-- By Movies
with cte as (select  Genre1 , case when 
Genre2 is not null then Genre2
else '-' end as Genre_2 , DENSE_RANK() over(order by count(*) desc) as rank , count(*) as Count_Genres
from titles
where type = 'Movie'
group by Genre1 ,  Genre2)

select *
from cte
where rank <= 10

-- By Show 
with cte1 as (select  Genre1 , case when 
Genre2 is not null then Genre2
else '-' end as Genre_2 , DENSE_RANK() over(order by count(*) desc) as rank , count(*) as Count_Genres
from titles
where type = 'Show'
group by Genre1 ,  Genre2)

select *
from cte1
where rank <= 10

-- Which Country Produce Most Shows and Movies 

-- By Movies
select top 1 production_countries , count(*) as Movie_Produce
from titles
where type = 'Movie' and production_countries != ' '
group by production_countries
order by Movie_Produce desc

-- By Show 

select top 1  production_countries , count(*) as Show_Produce
from titles
where type = 'Show' and production_countries != ' '
group by production_countries
order by Show_Produce desc

-- Show With the Most Season 
select title
from titles
where type = 'Show'
and seasons = (select max(seasons) from titles )

-- Creating a view for titles and actor table 

CREATE VIEW TitleActorInfo AS
SELECT t.id , title , type , release_year , runtime , production_countries , imdb_score , imdb_votes , Genre1 , Genre2 , name , character , role
FROM titles AS t
INNER JOIN Actor AS a ON t.id = a.id

-- The actor who has performed the most in Netflix shows and movies.

-- By Movies 
select name 
from (select name , count(*) as Actor_appear
from TitleActorInfo
group by name
) as sub_10
where Actor_appear = (select max(cc) from (select count(*) as cc from TitleActorInfo group by name) as su)

-- By Shows 
select name
from (select name , count(*) as Actor_Appear
from TitleActorInfo
where type = 'Show'
group by name ) as sub_1
where Actor_Appear = (select max(cc) from ( select count(*) as cc from TitleActorInfo where type = 'Show' group by name) as sub_2 )

-- Where do most actors come from?
select  production_countries , count(*) as Actor_country
from TitleActorInfo
where production_countries != ' '
group by production_countries
order by count(*) desc

-- What are the most common genre combinations among titles featuring actors, and which actors appear most frequently in those genres?
select Genre1 , Genre2 , name , count(*) as actor_count
from TitleActorInfo
where Genre1 is not null and Genre2 is not null
group by Genre1 , Genre2 , name
order by COUNT(*) desc

-- What is the distribution of titles based on their runtime (in hours) for titles with a runtime of one hour or more?
select hours_runtime , count(*) as hours_wise_distribution 
from titles
where hours_runtime >= 1
group by hours_runtime 
order by count(*) desc

-- Duration Distribution Analysis
SELECT Category, 
       concat(ROUND(CAST(100 * duration_Distribution AS float) / SUM(duration_Distribution) OVER(), 2) , '%') AS proportion
FROM (
    SELECT Category, 
           COUNT(*) AS duration_Distribution
    FROM titles
    GROUP BY Category
) AS sub_1
ORDER BY proportion DESC;



	
