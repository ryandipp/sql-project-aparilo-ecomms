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

