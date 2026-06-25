1. What is the total amount each customer spent at the restaurant?
 select s.customer_id, sum(m.price) as total_amount
 from dannys_diner.sales s
 join dannys_diner.menu m on s.product_id=m.product_id
 group by s.customer_id
 order by total_amount desc

2. How many days has each customer visited the restaurant?
 select customer_id, count(distinct order_date) as days 
 from dannys_diner.sales 
 group by customer_id

3. What was the first item from the menu purchased by each customer?
 select t.customer_id,m.product_name
 from
 (select customer_id,product_id,
 row_number() over(partition by customer_id order by order_date asc) as rn
 from dannys_diner.sales) t
 join dannys_diner.menu m on t.product_id=m.product_id
 where rn=1

4. What is the most purchased item on the menu and how many times was it purchased by all customers?
 select m.product_name,count(*) as total_orders
 from dannys_diner.sales s
 join dannys_diner.menu m 
 on s.product_id=m.product_id
 group by m.product_name
 order by total_orders desc
 limit 1

5. Which item was the most popular for each customer?
 select customer_id,product_name
 from
 (select s.customer_id,m.product_name, count(*) as c,
 row_number() over(partition by s.customer_id order by count(*) desc) as rn
 from dannys_diner.sales s 
 join dannys_diner.menu m 
 on s.product_id=m.product_id
 group by s.customer_id,m.product_name) t
 where rn=1

6. Which item was purchased first by the customer after they became a member?
 select t.customer_id,m.product_name
 from
 (select m.customer_id, s.product_id,
 row_number() over(partition by m.customer_id order by s.order_date) as rn
 from dannys_diner.members m
 join dannys_diner.sales s
 on m.customer_id=s.customer_id) t
 join dannys_diner.menu m
 on m.product_id=t.product_id
 where rn=1

7. Which item was purchased just before the customer became a member?
 select t.customer_id,m.product_name
 from
 (select s.customer_id,s.order_date,m.join_date,s.product_id,
 rank() over (partition by s.customer_id order by order_date desc) as rn
 from dannys_diner.sales s
 join dannys_diner.members m 
 on s.customer_id=m.customer_id and s.order_date<m.join_date) t
 join dannys_diner.menu m 
 on t.product_id=m.product_id
 where rn=1

8. What is the total items and amount spent for each member before they became a member?
 select t.customer_id,count(*) as total_item,sum(m.price) as amount_spend
 from 
 (select s.customer_id,s.order_date,s.product_id
 from dannys_diner.sales s
 join dannys_diner.members m 
 on s.customer_id=m.customer_id and s.order_date<m.join_date) t
 join dannys_diner.menu m
 on m.product_id=t.product_id
 group by t.customer_id

9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
 select customer_id,sum(points) as total_points
 from
 (select *,
 case 
 	when product_name='sushi' then price*20
     else price*10
 end as points
 from dannys_diner.menu m) t
 join dannys_diner.sales s
 on s.product_id=t.product_id
 group by customer_id

10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
 select sample.customer_id,sum(points) 
 from 
 (select t.customer_id,t.order_date,t.join_date,t.product_id,
 case
 	when order_date between join_date and join_date + interval '6 days' then price*20
     when product_name='sushi' then price*20
     else price*10
 end as points
 from 
 (select s.customer_id,s.order_date,s.product_id,m.join_date
 from dannys_diner.members m
 join dannys_diner.sales s
 on s.customer_id=m.customer_id) t
 join dannys_diner.menu m
 on m.product_id=t.product_id) sample
 where order_date<='2021-01-31'
 group by sample.customer_id

-- creating basic data tables that Danny and his team can use to quickly derive insights 
-- select s.customer_id,s.order_date,m1.product_name,m1.price,
-- case
-- 	when s.customer_id in (select distinct customer_id from dannys_diner.members) and s.order_date>=m2.join_date then 'Y'
--     else 'N'
-- end as member
-- from dannys_diner.sales s
-- left join dannys_diner.menu m1 on s.product_id=m1.product_id
-- left join dannys_diner.members m2 on s.customer_id=m2.customer_id


-- ranking of customer products
-- with t as (
-- select 
-- row_number() over(order by s.customer_id,s.order_date,s.product_id) as rn,
-- s.customer_id,s.order_date,me.product_name,me.price,
-- case
-- 	when s.order_date>=m.join_date and s.customer_id in (select distinct customer_id from dannys_diner.members) then 'Y'
--     else 'N'
-- end as member
-- from dannys_diner.sales s
-- left join dannys_diner.members m
-- on s.customer_id=m.customer_id
-- join dannys_diner.menu me
-- on s.product_id=me.product_id
-- ),
 
-- t1 as (
-- select rn,customer_id,order_date,
-- dense_rank() over (partition by customer_id order by order_date) as rating
-- from t
-- where member='Y'
-- )

-- select t.customer_id,t.order_date,t.product_name,t.price,t.member,t1.rating
-- from t
-- left join t1
-- on t.rn=t1.rn
