-- To check if the data is imported properly
select *
from pizza_sales
-- What is the total Revenue for the company 

select round(sum(total_price),2) as total_revenue
from pizza_sales

--What the average order value for the company 
select round(sum(total_price) / count(Distinct order_id),2) as avg_order_value
from pizza_sales

-- What is the total order that was placed
select sum(quantity) as tot_pizza_sold
from pizza_sales

-- What is the total order that was placed 
select count(distinct order_id) as tot_order_place
from pizza_sales

-- What is the average per order by the consumer

select round(cast(sum(quantity) AS float) / count(distinct order_id),2) as average_order
from pizza_sales

-- what is the Daily Trend in our data set

SELECT Datename(DW , order_date) as order_days , count(distinct order_id) as total_order
from pizza_sales
group by Datename(DW , order_date)
order by total_order DESC

-- Hourly Trend 

select DATEPART(HOUR,order_time) as order_hour , count(distinct order_id) as total_order
from pizza_sales
group by DATEPART(HOUR,order_time)
order by total_order DESC

-- Percentage wise sales in pizza category 

select pizza_category , SUM(total_price) *100 / (select Sum(total_price) from pizza_sales) as PCT
from pizza_sales
where month(order_date) = 1
group by pizza_category
order by PCT

-- Percentage wise sales for the pizza size
select pizza_size , Round(SUM(total_price) *100 / (select Sum(total_price) from pizza_sales ),2) as PCT
from pizza_sales
group by pizza_size
order by PCT desc
-- Best and the worst seller 
-- Based on the category
select pizza_category , SUM(quantity) as total_Pizza_sold
from pizza_sales
group by pizza_category
order by total_Pizza_sold desc

-- best pizza 5 

select top(5)  pizza_name , sum(quantity) as total_Pizza_sold
from pizza_sales
group by pizza_name
order by total_Pizza_sold desc

-- worst 5
select top (5)  pizza_name , sum(quantity) as total_Pizza_sold
from pizza_sales
group by pizza_name
order by total_Pizza_sold 