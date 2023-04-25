/* What is the average time it takes to process an order from the date it is placed to the date it is delivered, and
are there any trends or patterns in the order statuses that can be identified to improve this process? */

select year(o.created_at) as yearly, month(o.created_at) as monthly,
	avg(timestampdiff(hour, o.created_at, o.shipped_at)/24) as packing_time,
    avg(timestampdiff(hour, o.shipped_at, o.delivered_at)/24) as shipping_time,
    count(case when o.status = 'Cancelled' then o.status else NULL end)/count(o.created_at) as cancel_rate 
    
from orders as o
where date(o.created_at) >= '2022-01-01' and date(o.created_at) < '2023-01-01'
group by yearly, monthly
order by yearly asc, monthly asc;

	