/*What is the customer retention rate over time for each acquisition source,
and are there any sources that are performing better or worse than others?
How can we leverage this information to improve customer retention and drive repeat business from these sources?*/

-- 2022 ACTIVE USERS BY SOURCE
select year(o.created_at) as yearly, month(o.created_at) as monthly,  
	count(case when u.traffic_source = 'Search' then u.traffic_source else null end) as af_search,
    count(case when u.traffic_source = 'Organic' then u.traffic_source else null end) as af_organic,
    count(case when u.traffic_source = 'Facebook' then u.traffic_source else null end) as af_facebook,
    count(case when u.traffic_source = 'Email' then u.traffic_source else null end) as af_email,
    count(case when u.traffic_source = 'Display' then u.traffic_source else null end) as af_display
from users u join orders o on o.user_id = u.id
where o.status in ('Shipped', 'Complete')
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

-- INACTIVE USERS & EMAIL to be ad target
select u.id, u.email, u.age, u.traffic_source
from users u
where u.id not in ( select o.user_id 
			from orders o)
order by id;
