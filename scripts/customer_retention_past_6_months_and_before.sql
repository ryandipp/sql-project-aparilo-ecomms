/*
What is the average order value and purchase frequency for customers who made a purchase in the past 6 months,
and how do these metrics compare to customers who made a purchase more than 6 months ago?
*/

select 
	case
    when oi.created_at >= '2020-01-01' and oi.created_at < '2021-01-01' then '2020'
    when oi.created_at >= '2021-01-01' and oi.created_at < '2022-01-01' then '2021'
    when oi.created_at >= current_date - interval '6' month then 'Past 6 Months'
    when oi.created_at < current_date - interval '6' month then 'More 6 Months Ago'
    end as `customer_timeline_group`,
    avg(oi.sale_price) as avg_order_value,
    count(oi.order_id) / count(distinct oi.user_id) as order_freq
from orders o join orderitems oi on o.order_id = oi.order_id
join products p on oi.product_id = p.id
where oi.delivered_at is not null
group by `customer_timeline_group`
order by `customer_timeline_group` desc
