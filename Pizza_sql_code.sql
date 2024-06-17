create database pizzahut;
use pizzahut;

# 1) Retrieve the total number of orders placed.
select count(order_id) as total_orders
from orders;

# 2) Calculate the total revenue generated from pizza sales.
select round(sum(pizzas.price*order_details.quantity),2) as total_revenue_generated
from pizzas
join order_details 
on pizzas.pizza_id = order_details.pizza_id;

# 3) Identify the highest-priced pizza.

#1 Method
select pizza_types.name, pizzas.price as highestprice
from pizzas
join pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id
order by highestprice desc;

#2 Method 
select pizza_types.pizza_type_id,pizza_types.name, max(pizzas.price) as max_price
from pizzas
join pizza_types
on pizzas.pizza_type_id = pizza_types.pizza_type_id
group by pizzas.pizza_type_id, pizza_types.name
order by max_price desc;

# 4) Identify the most common pizza size ordered.
select pizzas.size,count(*) as ordercount
from pizzas
join order_details on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size
order by ordercount desc;

# 5) List the top 5 most ordered pizza types along with their quantities.
select pizza_types.name,sum(order_details.quantity) as totalquantity
from pizza_types
join pizzas on pizza_types.pizza_type_id =pizzas.pizza_type_id
join order_details on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.name
order by totalquantity desc
limit 5;

# 6) Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.category,sum(order_details.quantity) as totalquantity
from pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category
order by totalquantity desc;

# 7) Determine the distribution of orders by hour of the day.
select hour(orders.time) as perhour, 
count(orders.order_id) as order_count
from orders
group by perhour
order by order_count desc;

# 8) Join relevant tables to find the category-wise distribution of pizzas.
select pizza_types.category, pizza_types.name,count(pizzas.pizza_id) AS pizza_count
from pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category,pizza_types.name
order by pizza_count desc;

# 9) Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(sum_quantity),0) as Average_Pizza_Ordered_PerDay
from (select orders.date, sum(order_details.quantity) as sum_quantity
from orders
join order_details 
on orders.order_id = order_details.order_id
group by orders.date) as new_table;

#10 Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.name, round(sum(pizzas.price*order_details.quantity)) as revenue
from pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.name
order by revenue desc
limit 3;

#11 Calculate the percentage contribution of each pizza type to total revenue.
select pizza_types.category, round((sum(pizzas.price*order_details.quantity) / (select sum(revenue)
from (select pizza_types.category, sum(pizzas.price*order_details.quantity) as revenue  
from pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category) as new_table))* 100,0) as percentage
from pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category
order by percentage desc;

#12 Analyze the cumulative revenue generated over time.
select date, sum(revenue) over(order by date) as cumulative_revenue
from
(select orders.date,sum(order_details.quantity*pizzas.price) as revenue
from orders
join order_details on orders.order_id = order_details.order_id
join pizzas on order_details.pizza_id = pizzas.pizza_id
group by orders.date) as sales;

#13 Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category, name, revenue, ranking
from
(select category,name,revenue,
rank() over(partition by category order by revenue desc) as Ranking
from
(select pizza_types.category, pizza_types.name, sum(order_details.quantity*pizzas.price) as revenue
from pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category, pizza_types.name) as a ) as b
where Ranking <=3;

