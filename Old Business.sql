-- What is the oldest business, and from which category and country does it originate?

select busniess , year , category , country , continent
from business as b 
inner join categories as cat
	on b.category_code = cat.category_code 
	inner join countries as c 
	on c.country_code = b.country_code
where cast(year as int) = (select min(cast(year as int)) from business)

-- how many business's started before 1950 
select count(*) as count_of_country
from business
where year < '1950';

-- In which category most of the business comes from 
select category , count(*) as total_category_count
from business as b  
inner join categories as c 
on b.category_code = c.category_code
group by category
order by total_category_count desc
limit 1;

-- In which continent does the most business originate?

select continent , count(*)
from business as b 
inner join countries as c
on b.country_code = c.country_code 
group by continent;

-- What are the top-ranking categories, along with their respective continents and the count of countries
select category , continent , country_count
from (select * , dense_rank() over(partition by continent order by country_count desc) as rnk
from (select category  , continent, count(*) as country_count
from business as b 
inner join categories as cat
on b.category_code = cat.category_code
	inner join countries as c
	on c.country_code = b.country_code
group by category,  continent 
) sub_1) sub_2
where rnk = 1 
