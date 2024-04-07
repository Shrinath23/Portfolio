 -- Problem :- Doctors and nurses are looking into the biggest reasons why patients die in the hospital. By understanding these reasons early, they can create specific actions and proven plans to tackle the problems that lead to patient deaths during their stay.

-- Cleaning the Data 
-- Replacing the null value in ethnicity to mixed 

update Hospital
set ethnicity = case when ethnicity is null then 'Mixed' else ethnicity end ,
apache_4a_hospital_death_prob = case when apache_4a_hospital_death_prob is null then 0 else apache_4a_icu_death_prob end 
-- How many total deaths occured in the hospital and what was the percentage of the mortality rate?

select sum(cast(hospital_death as int)) as death , round(100 * sum(cast(hospital_death as float)) / count(*) ,2) as mortality_rate
from Hospital

-- What was the death count of each ethnicity? 

select ethnicity ,sum( case when hospital_death = 1 then 1 else 0 end ) as death 
from Hospital
group by ethnicity
order by death desc

-- What was the death count of each gender? 

select gender ,sum( case when hospital_death = 1 then 1 else 0 end ) as death
from Hospital
where gender is not null
group by gender
order by death desc

-- Comparing the average and max ages of patients who died and patients who survived

select ROUND(avg(age),2) as average_age , max(age) as max_age
from Hospital
where hospital_death = 1

Union 

select ROUND(avg(age),2) as average_age , max(age)
from Hospital
where hospital_death = 0

-- Comparing the amount of patients that died and survived by each age 

select age , people_death , survived , round(cast(people_death as float) / survived , 2) as death_ratio
from (
select age,count( case when hospital_death = 1 then 1 end ) as people_death , count( case when hospital_death = 0 then 0 end ) as survived
from Hospital
where age is not null
group by age ) as sub
order by age

-- Age distribution of patients in 10-year interval

select concat(floor(age/10 )*10 , '-'  ,(floor(age/10 )*10) + 9) as age_interval , count(*) as age_distribution 
from Hospital
where age is not null
group by concat(floor(age/10 )*10 , '-'  ,(floor(age/10 )*10) + 9)
order by age_interval 

-- Amount of patients above 65 who died vs Amount of patients between 50-65 who died

select sum(case when age > 65 and hospital_death = 1 then 1 end ) as age_above_65_passed_away , sum(case when age between 55 and 65 and hospital_death = 1 then 1 end ) as people_age_between_55_and_65_passed_away
from Hospital

-- Calculating the average probability of hospital death for patients of different age groups
select case 
when age < 40 Then 'Under 40'
when age between 40 and 59 Then '40 - 59'
when age between 60 and 79 then '60 - 79'
when age > 80 then 'More than 80' 
else 'Unknow'
end as age_group , round(avg(apache_4a_hospital_death_prob) , 2) as average_probability
from (
select age , apache_4a_hospital_death_prob
from Hospital
where age is not null ) as sub
group by case 
when age < 40 Then 'Under 40'
when age between 40 and 59 Then '40 - 59'
when age between 60 and 79 then '60 - 79'
when age > 80 then 'More than 80' 
else 'Unknow'
end
order by average_probability desc

-- Which admit source of the ICU did most patients die in and get admitted to?

select icu_admit_source , sum(case when hospital_death = 1 then 1 else 0 end ) as people_dead , sum(case when hospital_death = 0 then 1 else 0 end ) as people_survied
from Hospital
where icu_admit_source is not null
group by icu_admit_source

-- Average age of people in each ICU admit source and amount that died

select icu_admit_source , count(*) as people_died , round(avg(age),2) as average_age
from Hospital
where hospital_death = 1 and icu_admit_source is not null
group by icu_admit_source

-- Average age of people in each type of ICU and amount that died

select icu_stay_type , count(*) as people_died , round(avg(age),2) as average_age
from Hospital
where hospital_death = 1 and icu_admit_source is not null
group by icu_stay_type

-- Average weight, bmi, and max heartrate of people who died

select avg(weight) , avg(bmi) , max(d1_heartrate_max) as max_heart_rate
from Hospital
where hospital_death = 1

--What were the top 5 ethnic groups with the highest BMI?

select ethnicity , average_BMI
from (
select ethnicity , average_BMI , DENSE_RANK() over( order by average_BMI desc) as rank
from (
select ethnicity , round(avg(bmi),2) as average_BMI
from Hospital
group by ethnicity) as sub_1) as sub_2
where rank <=5

-- How many patients are suffering from each comorbidity? 

select sum(cast(aids as int)) as aids , sum(cast(cirrhosis as int)) as cirrhosis,sum(cast(diabetes_mellitus as int)) as diabetes_mellitus , sum( cast(hepatic_failure as int)) as hepatic_failure , 
sum(cast(immunosuppression as int) ) as immunosuppression , sum(cast(leukemia as int)) as leukemia , sum(cast(lymphoma as int)) as lymphoma , sum(cast(solid_tumor_with_metastasis as int)) as solid_tumor
from Hospital

-- What was the percentage of patients with each comorbidity among those who died? 

SELECT 
ROUND(100 * SUM(CAST(aids AS FLOAT)) / COUNT(*), 2) AS percentage_of_people_with_aids,
ROUND(100 * SUM(CAST(cirrhosis AS FLOAT)) / COUNT(*), 2) AS percentage_of_people_with_cirrhosis,
ROUND(100 * SUM(CAST(diabetes_mellitus AS FLOAT)) / COUNT(*), 2) AS percentage_of_people_with_diabetes,
ROUND(100 * SUM(CAST(hepatic_failure AS FLOAT)) / COUNT(*), 2) AS percentage_of_people_with_hepatic_failure,
ROUND(100 * SUM(CAST(immunosuppression AS FLOAT)) / COUNT(*), 2) AS percentage_of_people_with_immunosuppression,
ROUND(100 * SUM(CAST(leukemia AS FLOAT)) / COUNT(*), 2) AS percentage_of_people_with_leukemia,
ROUND(100 * SUM(CAST(lymphoma AS FLOAT)) / COUNT(*), 2) AS percentage_of_people_with_lymphoma,
ROUND(100 * SUM(CAST(solid_tumor_with_metastasis AS FLOAT)) / COUNT(*), 2) AS percentage_of_people_with_solid_tumor
FROM Hospital

-- -- What was the percentage of patients who underwent elective surgery?

select round(100* sum(cast(elective_surgery as float)) / count(*) ,2) as percentage_of_elective_surgery
from Hospital

-- What was the average weight and height for male & female patients who underwent elective surgery?

SELECT 
    ROUND(AVG(CASE WHEN gender = 'M' AND elective_surgery = 1 THEN weight END), 2) AS average_weight_of_male_went_under_elective_surgery,
    ROUND(AVG(CASE WHEN gender = 'M' AND elective_surgery = 1 THEN height END), 2) AS average_height_of_male_went_under_elective_surgery,
    ROUND(AVG(CASE WHEN gender = 'F' AND elective_surgery = 1 THEN weight END), 2) AS average_weight_of_female_went_under_elective_surgery,
    ROUND(AVG(CASE WHEN gender = 'F' AND elective_surgery = 1 THEN height END), 2) AS average_height_of_female_went_under_elective_surgery
FROM 
    Hospital;

-- What were the top 10 ICUs with the highest hospital death probability?

select top 10 icu_id , round(apache_4a_hospital_death_prob,2) as death_probability
from Hospital
order by death_probability desc

-- What was the average length of stay at each ICU for patients who survived and those who didn't? 

select icu_type , round(AVG(case when hospital_death = 1 then pre_icu_los_days end ),2) as average_length_of_hospital_stay_for_patients_who_passed_away,
round(AVG(case when hospital_death = 0 then pre_icu_los_days end ),2) as average_length_of_hospital_stay_for_patients_who_survived 
from Hospital
group by icu_type

-- What was the average BMI for patients that died based on ethnicity? (excluding missing or null values)

select ethnicity , round(AVG(bmi),2) as average_bmi
from Hospital
where hospital_death = 1 and bmi is not null
group by ethnicity
order by average_bmi desc

-- What was the death percentage for each ethnicity? 

select ethnicity , round(100 * sum(cast(hospital_death as float)) / count(*),2) as percentage_of_death
from Hospital
group by ethnicity

-- Finding out how many patients are in each BMI category based on their BMI value

select case when bmi < 18.5 then 'underweight'
when bmi between 18.5 and 24.99 then 'Normal'
when bmi between 25 and 29.99 then 'overweight'
else 'obese' end as BMI_category , count(*) as BMI_distribution
from (
select round(bmi , 2) as bmi
from Hospital
where bmi is not null) as sub_1
group by case when bmi < 18.5 then 'underweight'
when bmi between 18.5 and 24.99 then 'Normal'
when bmi between 25 and 29.99 then 'overweight'
else 'obese' end 

-- Hospital death probabilities where the ICU type is 'MICU' and BMI is above 35

select patient_id,apache_4a_hospital_death_prob as death_probability
from Hospital
where icu_type = 'MICU'
and bmi > 35
order by death_probability desc


-- Dashboard link https://github.com/Shrinath23/Portfolio_Project_Power-Bi/blob/main/Hospital_Dashbord.pbix 