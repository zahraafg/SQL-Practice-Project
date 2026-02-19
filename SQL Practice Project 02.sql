USE RealCompanyDB;

/* 🧩 RealCompanyDB – SQL Practice Project

Mövzu: Sales & Orders Analysis

🎯 Tapşırıq

RealCompanyDB bazasından istifadə edərək elə bir sorğu yaz ki:

1️. Hər customer üçün:

customer_id, full_name, country

Toplam orders sayı

Toplam ödəniş (total_amount sum)

Orta order dəyəri

CASE ilə status:

Toplam ödəniş > 10000 → 'VIP'

Toplam ödəniş > 5000 → 'LOYAL'

Əks halda → 'NEW'

2️. Hər product category üçün:

category

Toplam satılan quantity

Toplam gəlir (quantity * unit_price)

Hər category-də ən çox satılan product (ad + quantity)

3️. Bonus (advanced):

Window function istifadə et:

Hər customer üçün rank orders by total_amount → ən böyük order 1-ci sırada*/

with CustomerStats as (
select 
	c.customer_id, 
	c.customer_name,
	c.city,

	COUNT(o.order_id) as count_orders,
    COALESCE(SUM(o.total_amount),0) as total_amount,
    COALESCE(AVG(o.total_amount),0) as avg_order,

	case 
		when COALESCE(SUM(o.total_amount),0) > 1000 then 'VIP'
		when COALESCE(SUM(o.total_amount),0) > 500 then 'LOYAL'
		else 'NEW'
	end as status
from Customers c
left join Orders o
on c.customer_id = o.customer_id
group by 
    c.customer_id, 
	c.customer_name,
	c.city
),
CityStats as (
	select 
		c.city,
		COUNT(c.customer_id) as count_customers,
		COUNT(o.order_id) as count_orders,
		COALESCE(SUM(o.total_amount),0) as total_amount
	from Customers c
	left join Orders o
	on o.customer_id = c.customer_id
	group by c.city
),
functions as (
	select
	o.customer_id,
	o.order_id,
	o.total_amount,
	rank() over (partition by o.customer_id order by o.total_amount desc) as order_rank
	from Orders o
)
select 
cs.customer_id,
cs.customer_name,
cs.city,
cs.count_orders,
cs.total_amount as customer_total_amount,
cs.avg_order,
cs.status,
ci.count_customers,
ci.count_orders,
ci.total_amount as city_total_customers,
f.order_id,
f.order_rank,
f.total_amount as total_amount
from CustomerStats cs
left join CityStats ci
on cs.customer_id = cs.customer_id
left join functions f
on f.customer_id = cs.customer_id;

-- OR

select
    c.customer_id,
    c.customer_name,
    c.city,

    COALESCE(cs.count_orders, 0) as count_orders,
    COALESCE(cs.total_amount, 0) as customer_total_amount,
    COALESCE(cs.avg_order, 0) as avg_order,

    case
        when COALESCE(cs.total_amount,0) > 1000 then 'VIP'
        when COALESCE(cs.total_amount,0) > 500 then 'LOYAL'
        else 'NEW'
    end as status,

    COALESCE(ci.total_customers,0) as city_total_customers,
    COALESCE(ci.total_orders,0) as city_total_orders,
    COALESCE(ci.total_amount,0) as city_total_amount,

    o.order_id,
    o.total_amount as order_amount,
    rank() over (partition by c.customer_id order by o.total_amount desc) as order_rank
from Customers c

left join (
    select 
        customer_id,
        COUNT(*) as count_orders,
        SUM(COALESCE(total_amount,0)) as total_amount,
        AVG(COALESCE(total_amount,0)) as avg_order
    from Orders
    group by customer_id
) cs
on cs.customer_id = c.customer_id

left join (
    select
	c.city,
        COUNT(distinct c.customer_id) as total_customers,
        COUNT(o.order_id) as total_orders,
        SUM(COALESCE(o.total_amount,0)) as total_amount
    from Customers c
    left join Orders o on c.customer_id = o.customer_id
    group by c.city
) ci
on ci.city = c.city
left join Orders o 
on o.customer_id = c.customer_id
order by c.customer_id, order_rank;



