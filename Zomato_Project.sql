drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);

select *
from product

select *
from goldusers_signup

select *
from sales

select *
from users

-- What is the total amount of purchase by each person ?

select s.userid , sum(p.price) as total_spending
from product as p
inner join sales  as s on p.product_id = s.product_id 
group by s.userid
order by total_spending desc

-- What is the average amount of purchase by each person ?
select s.userid , AVG(p.price) as average_spending, count(s.userid)
from product as p
inner join sales  as s on p.product_id = s.product_id 
group by s.userid
order by average_spending desc

-- how many days a person visted zomato 
select userid , count(distinct(created_date)) as num_of_vist
from sales 
group by userid;

-- What was the first product that was purchased my the customer ?

with Sale_CTE (userid,rnk,product_id)
as (
SELECT userid, RANK() OVER (PARTITION BY userid ORDER BY created_date) AS rnk, product_id
FROM sales
)

select *
from Sale_CTE
where rnk = 1

-- what was the most purchased item on the menu and how many time the item was purchased by the customer ?

select product_id , count(product_id) as num_of_product
from sales
group by product_id
order by num_of_product desc

select userid , count(product_id) as num_of_product
from sales 
where product_id = 2
group by userid

-- which item was the most popluar 

select userid , product_id
from 
(SELECT *, RANK() OVER (PARTITION BY userid ORDER BY cnt DESC) AS rnk
FROM (
    SELECT userid, product_id, COUNT(product_id) AS cnt
    FROM sales
    GROUP BY userid, product_id
) AS subquery_alias) as sub2
where rnk = 1

-- what was the first product purchase by the customer after becoming a memeber and what was the price of the product 

select userid , product_id 
from (
select s.userid,rank() over(partition by s.userid order by created_date asc) as rnk, s.product_id
from sales as s 
inner join goldusers_signup as g on s.userid = g.userid and s.created_date >= g.gold_signup_date)as WT
where rnk = 1


with The(userid , product_id) 
as (
select userid , product_id 
from (
select s.userid,rank() over(partition by s.userid order by created_date asc) as rnk, s.product_id
from sales as s 
inner join goldusers_signup as g on s.userid = g.userid and s.created_date >= g.gold_signup_date)as WT
where rnk = 1)

select t.userid,t.product_id,p.product_name,p.price
from The as t
inner join product as p on t.product_id = p.product_id

-- What was the product that the customer purchase before he/she became a member ?

select userid , product_id
from 
(select s.userid ,rank() over(partition by s.userid order by created_date desc) as rnk,product_id
from sales as s 
inner join goldusers_signup as g on s.userid = g.userid and s.created_date <= g.gold_signup_date) as u
where rnk = 1

-- What is the amount of total spending and the amount of order did my the customer before they become member ?

select s.userid , SUM(p.price) , count(p.product_id)
from sales as s 
inner join goldusers_signup as g on s.userid = g.userid and s.created_date <= g.gold_signup_date
inner join product as p on s.product_id = p.product_id 
group by s.userid

select c.userid , sum(p.price),COUNT(p.product_id)
from 
(select s.userid, s.product_id
from sales as s 
inner join goldusers_signup as g on s.userid = g.userid and s.created_date <= g.gold_signup_date) as c inner join product as p
on c.product_id = p.product_id
group by c.userid;

-- point given to the customer p1 = 5Rs = 1 zomoto point , p2 10Rs = 1 zomoto point , p3 = 1 zomoto 

WITH zomoto_thing (product_id, product_name, zomoto_point) AS (
    SELECT product_id, product_name,
           CASE
               WHEN product_id = 1 THEN price / 5
               WHEN product_id = 2 THEN price / 2
               ELSE price / 5
           END AS zomoto_point
    FROM product
)

select userid , SUM(z.zomoto_point) as total_point
from zomoto_thing as z
inner join sales as s on z.product_id = s.product_id
group by userid
order by total_point  desc

select pp.product_id , SUM(pp.zomoto_point) as point_per
from (SELECT product_id, product_name,
           CASE
               WHEN product_id = 1 THEN price / 5
               WHEN product_id = 2 THEN price / 2
               ELSE price / 5
           END AS zomoto_point
    FROM product) as pp inner join sales as s
	on s.product_id = pp.product_id
	group by pp.product_id
	order by point_per desc

-- Who have more point in the first year for the member 1zp - 2rs

select s.userid , sum(price/2) as zomoto_point
from sales as s 
inner join goldusers_signup as g on s.userid = g.userid and s.created_date >= g.gold_signup_date 
and s.created_date <= DATEADD(year,1,g.gold_signup_date) inner join product as p 
on s.product_id = p.product_id
group by s.userid
order by zomoto_point desc

-- Rank all the transaction 

select *,rank() over(partition by userid order by created_date) as ranks
from sales 

-- rank all the transaction done by the gold member mark rest as na 


select *
from sales as s 
left join goldusers_signup as g on s.userid = g.userid and s.created_date >= g.gold_signup_date