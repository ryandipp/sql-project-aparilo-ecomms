/*
What are the top-selling products by category and brand,
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
limit 20;