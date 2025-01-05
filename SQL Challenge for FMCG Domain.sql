-- Q1
select*from dim_products d 
join fact_events f 
on d.product_code = f.product_code
where base_price >500 and promo_type = "BOGOF"

-- Q2
select 
city, count(store_id) as "number_of_cities"
from dim_stores 
group by city
order by number_of_cities desc


-- Q3
with cte as (
select
campaign_name, 
sum(base_price*f.`quantity_sold(before_promo)`/1000000) as "revenue_before_pro", 
sum(
case
when promo_type = '50% OFF' then base_price*(1-0.5)
when promo_type = '25% OFF' then base_price*(1-0.25)
when promo_type = 'BOGOF' then base_price*(1-0.5)
when promo_type = '500 Cashback' then base_price-500
else base_price*(1-0.33)
end * f.`quantity_sold(after_promo)`/1000000) as "revenue_after_discount"
from fact_events f 
join dim_campaigns d
on f.campaign_id = d.campaign_id 
group by campaign_name) 
select*, revenue_after_discount - revenue_before_pro as "increment"
from cte

-- Q4
with cte as (
select
category, 
sum(`quantity_sold(after_promo)` -`quantity_sold(before_promo)`)*100/sum(`quantity_sold(before_promo)`)
as "ISU%"
from dim_products p 
join fact_events f 
on p.product_code = f.product_code
join dim_campaigns c 
on c.campaign_id = f.campaign_id
where campaign_name = 'Diwali'
group by category) 
select*, 
dense_rank() over (order by `ISU%` desc) as "rank"
from cte


-- Q5
with cte as(
select
product_name, category,
sum(base_price*f.`quantity_sold(before_promo)`/1000000) as "revenue_before_pro", 
sum(
case
when promo_type = '50% OFF' then base_price*(1-0.5)
when promo_type = '25% OFF' then base_price*(1-0.25)
when promo_type = 'BOGOF' then base_price*(1-0.5)
when promo_type = '500 Cashback' then base_price-500
else base_price*(1-0.33)
end * f.`quantity_sold(after_promo)`/1000000) as "revenue_after_discount"
from fact_events f 
join dim_products p 
on f.product_code = p.product_code
group by product_name, category) 
select product_name, category,
(revenue_after_discount - revenue_before_pro)*100/revenue_before_pro as "IR%"
from cte 
order by `IR%` desc
limit 5 


