create database netflixdata;
use netflixdata;

-- Level 1: Basic SQL
/* 1. Display the first 10 customer records. */
select * from netflix_table
limit 10;

-- 2. Count all customers.
select count(*) from netflix_table;

-- 3. Find the number of unique customers.
select count(distinct customer_id) as customer_count from netflix_table;

-- 4. Find all available subscription types.
select distinct subscription_type
from netflix_table;

-- 5. Count customers by gender.
select gender, count(*) as Total_customer from netflix_table
group by gender
;

-- 6. Count customers by region.
select region, count(*) as Total_customer from netflix_table
group by region
;

-- 7. Find the average monthly fee
select round(avg(monthly_fee), 2) as average_monthly_fee
from netflix_table;

-- 8. Find the minimum and maximum customer age.
select min(age) as minimum_age, max(age) as maximum_age 
from netflix_table;

-- 9. Find customers whose monthly fee exceeds 15.
select * from netflix_table
where monthly_fee > 15 ;

-- 10. Find the number of missing values in important columns
SELECT
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN subscription_type IS NULL THEN 1 ELSE 0 END) AS missing_subscription_type,
    SUM(CASE WHEN monthly_fee IS NULL THEN 1 ELSE 0 END) AS missing_monthly_fee,
    SUM(CASE WHEN churned IS NULL THEN 1 ELSE 0 END) AS missing_churned,
    SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) AS missing_age,
    SUM(CASE WHEN region IS NULL THEN 1 ELSE 0 END) AS missing_region,
    SUM(CASE WHEN device IS NULL THEN 1 ELSE 0 END) AS missing_device
FROM netflix_table;

/* -------------------------------------------------------------------------------------------------------------------------  */

-- Level 2: Customer churn analysis
-- 11. How many customers have churned?
select count(*) as Total_churn 
from netflix_table
where churned = "Yes"
;

-- 12. What is the overall churn rate in percentage?
select round(
	sum(case when churned = "Yes" then 1 else 0 end ) * 100/ count(*)
    , 2) as overall_churn_rate
from netflix_table;    

-- 13. How many customers are retained?
select count(*) as retained_customer
from netflix_table
where churned = "No"; 

-- 14. What is the churn rate for each subscription type?
select subscription_type, round(
	sum(case 
		when churned = "Yes"
        then 1 else 0 
        end) * 100 / count(*) 
      ,2) as churn_by_subscription_type
from netflix_table 
group by subscription_type; 

-- 15. Which region has the highest churn rate?
select region, round(
	sum(case 
		when churned = "Yes"
        then 1 else 0 
        end) * 100 / count(*) 
      ,2) as churn_by_region
from netflix_table 
group by region
order by churn_by_region desc
;

-- 16. What is the churn rate for each payment method?
select payment_method, round(
	sum(case 
		when churned = "Yes"
        then 1 else 0 
        end) * 100 / count(*) 
      ,2) as churn_by_payment_method
from netflix_table 
group by payment_method
order by churn_by_payment_method desc
;

-- 17. Which device has the highest churn rate?
select device, round(
	sum(case 
		when churned = "Yes"
        then 1 else 0 
        end) * 100 / count(*) 
      ,2) as churn_by_device
from netflix_table 
group by device
order by churn_by_device desc
;

-- 18. What is the churn rate by gender?
select gender, round(
	sum(case 
		when churned = "Yes"
        then 1 else 0 
        end) * 100 / count(*) 
      ,2) as churn_by_gender
from netflix_table 
group by gender
order by churn_by_gender desc
;

-- 19. Which favorite genre has the most churned customers?
select favorite_genre, round(
	sum(case 
		when churned = "Yes"
        then 1 else 0 
        end) * 100 / count(*) 
      ,2) as churn_by_favorite_genre
from netflix_table 
group by favorite_genre
order by churn_by_favorite_genre desc
;

-- 20. Which subscription type has the most churned customers?
select subscription_type, count(*) as most_churned_customers
from netflix_table
where churned = "Yes"
group by subscription_type
order by most_churned_customers desc
limit 1 ; 

/* -------------------------------------------------------------------------------------------------------------------------  */


-- Level 3: Advanced SQL
-- 21. Which customers pay more than the average monthly fee?
select customer_id, subscription_type, monthly_fee, region
from netflix_table
where monthly_fee > (
	select avg(monthly_fee) from netflix_table 
)
order by monthly_fee asc
;

-- 22. Which subscription type has the highest average watch hours?
select subscription_type, round(avg(watch_hours), 2) as avg_watch_hours
from netflix_table 
group by subscription_type
order by avg_watch_hours asc 
;

-- 23. Compare average watch hours for churned and retained customers.
select  
churned,
    ROUND(AVG(watch_hours), 2) AS average_watch_hours
FROM netflix_table
GROUP BY churned;
;

-- 24. Which customers have not logged in for more than 20 days?
select customer_id, last_login_days 
from netflix_table
where last_login_days > 20 
order by last_login_days asc
;

select last_login_days, count(*) as number_of_customer
from netflix_table
where last_login_days > 20 
group by last_login_days
order by last_login_days asc
;

-- 25. Which combination of device and subscription has the highest churn rate?
SELECT
    device,
    subscription_type,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churned = "Yes" THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN churned = "Yes" THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS churn_rate
FROM netflix_table
GROUP BY device, subscription_type
ORDER BY churn_rate DESC;

-- 26. Which genre has the highest churn rate among customers who watch fewer than 10 hours?
SELECT
    favorite_genre,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churned = "Yes" THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN churned = "Yes" THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS churn_rate
FROM netflix_table
WHERE watch_hours < 10
GROUP BY favorite_genre
ORDER BY churn_rate DESC
;

-- 27. Rank subscription types by churn rate.
select 
	subscription_type,
	count(*) as total_customers,
    sum(case when churned = "Yes" then 1 else 0 end) as churned_customers,
    round(
		sum(case when churned = "Yes" then 1 else 0 end) * 100 / count(*) , 2
    ) as churn_rate,
    rank() over (
		order by sum(case when churned = "Yes" then 1 else 0 end) * 100 / count(*) desc
    ) as churn_rank
    
from netflix_table
group by subscription_type
order by churn_rank;    
    









