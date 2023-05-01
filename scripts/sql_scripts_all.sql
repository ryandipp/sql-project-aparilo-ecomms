/*
What is the average order value and purchase frequency for customers who made a purchase in the past 6 months,
and how do these metrics compare to customers who made a purchase more than 6 months ago? and 2 past years.
*/
select 
	case
    when oi.created_at >= '2020-01-01' and oi.created_at < '2021-01-01' then '2020'
    when oi.created_at >= '2021-01-01' and oi.created_at < '2022-01-01' then '2021'
    when oi.created_at >= current_date - interval '6' month then 'Past 6 Months'
    when oi.created_at < current_date - interval '6' month then 'More 6 Months Ago'
    end as `customer_timeline_group`,
    avg(oi.sale_price) as avg_order_value,
    count(oi.order_id) / count(distinct o.user_id) as order_freq
from
	orders o	join orderitems oi on o.order_id = oi.order_id
				join products p on oi.product_id = p.id
where oi.delivered_at is not null
group by `customer_timeline_group`
order by `customer_timeline_group` desc;

/*
What are the 15 top-selling products by category and brand,
and what is the average sale price for these products?
*/
select
	concat(p.category, ' - ', p.brand) as cat_brand, o.gender,
    count(oi.product_id) as orderqty,
    sum(oi.sale_price) / count(oi.product_id) as avg_sale_price
from
	orders o	join orderitems oi on o.order_id = oi.order_id
				join products p on oi.product_id = p.id
where oi.delivered_at is not null
group by p.category, p.brand, o.gender
order by orderqty desc, avg_sale_price desc
limit 15;

/*How does the distribution of male and female customers differ across different product categories,
and are there any categories that are predominantly purchased by one gender?*/
select
	o.gender, p.category,
    count(oi.product_id) as purchased    
from
	orders o	join orderitems oi on o.order_id = oi.order_id
				join products p on oi.product_id = p.id
where o.delivered_at is not null and
year(o.created_at) = '2022'
group by o.gender, p.category
order by o.gender asc, purchased desc;

/*Purchase value by users' country*/
select u.country Country, sum(oi.sale_price) Purchase_Value
from users u join orderitems oi on u.id = oi.user_id
where oi.status = 'Complete'
group by Country
order by Purchase_Value desc;

/* What is the average time it takes to process an order from the date it is placed to the date it is delivered, and
are there any trends or patterns in the order statuses that can be identified to improve this process? */
select year(o.created_at) as yearly, month(o.created_at) as monthly,
	avg(timestampdiff(hour, o.created_at, o.shipped_at)/24) as packing_time,
    avg(timestampdiff(hour, o.shipped_at, o.delivered_at)/24) as shipping_time,
    count(if(o.status = 'Cancelled', o.status,NULL))/count(o.created_at) as cancel_rate 
from orders as o
where date(o.created_at) >= '2022-01-01' and date(o.created_at) < '2023-01-01'
group by yearly, monthly
order by yearly asc, monthly asc;

/*What is the customer retention rate over time for each acquisition source,
and are there any sources that are performing better or worse than others?
How can we leverage this information to improve customer retention and drive repeat business from these sources?*/

-- 2022 ACTIVE USERS BY SOURCE WITH COMPLETE ORDER
select year(o.created_at) as yearly, month(o.created_at) as monthly,  
	count(case when u.traffic_source = 'Search' then u.traffic_source else null end) as af_search,
    count(case when u.traffic_source = 'Organic' then u.traffic_source else null end) as af_organic,
    count(case when u.traffic_source = 'Facebook' then u.traffic_source else null end) as af_facebook,
    count(case when u.traffic_source = 'Email' then u.traffic_source else null end) as af_email,
    count(case when u.traffic_source = 'Display' then u.traffic_source else null end) as af_display
from users u join orders o on o.user_id = u.id
where o.status = 'Complete'
and date(o.created_at) >= '2022-01-01' and date(o.created_at) < '2023-01-01'
group by yearly, monthly
order by yearly, monthly;

-- ACTIVE USERS ALL TIME BY SOURCE
with t1 as (select traffic_source, count(id) as total_users from users
group by traffic_source)

select u.traffic_source,
count(DISTINCT o.user_id) as active_users,
t1.total_users from orders o join users u on o.user_id = u.id
join t1 on u.traffic_source = t1.traffic_source
where o.created_at is not null
group by u.traffic_source
order by active_users desc;


-- INACTIVE USERS & EMAIL for targeted ads
select u.id, u.email, u.age, u.traffic_source
from users u
where u.id not in ( select o.user_id 
					from orders o)
order by id;

/* extract dataset for a test for correlation analysis*/
select
o.order_id as Order_ID,
sum(oi.sale_price) as Sale_Price,
count(case when o.status = 'Cancelled' then o.status else null end)/count(o.status) as Cancellation_Rate,
count(o.order_id) as num_items
from orders o join orderitems oi on o.order_id = oi.order_id
where o.created_at between '2021-01-01' and '2022-12-31'
	and o.num_of_item is not null and o.num_of_item > 0
group by Order_ID;

-- continue to python
-- (pandas, statsmodels.api)



