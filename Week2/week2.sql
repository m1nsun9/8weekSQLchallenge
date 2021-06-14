DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" TIMESTAMP
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2021-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2021-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2021-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2021-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2021-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2021-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2021-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2021-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2021-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2021-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2021-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2021-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2021-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2021-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2021-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2021-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2021-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2021-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2021-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2021-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2021-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2021-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
-- Case Study Questions
-- This case study has LOTS of questions - they are broken up by area of focus including:

-- Pizza Metrics
-- Runner and Customer Experience
-- Ingredient Optimisation
-- Pricing and Ratings
-- Bonus DML Challenges (DML = Data Manipulation Language)
-- Each of the following case study questions can be answered using a single SQL statement.

-- Again, there are many questions in this case study - please feel free to pick and choose which ones you’d like to try!

-- Before you start writing your SQL queries however - you might want to investigate the data, you may want to do something with some of those null values and data types in the customer_orders and runner_orders tables!
SELECT * FROM runner_orders;

-- perform ETL on table runner_orders
update runner_orders
SET cancellation = NULL
WHERE duration != 'null';

update runner_orders
SET distance = NULL, duration = NULL, pickup_time = NULL
WHERE distance = 'null';

update runner_orders
SET distance = SUBSTRING(distance, 1, 2)
WHERE distance LIKE '%km' AND distance NOT LIKE '%.%';

update runner_orders
SET distance = SUBSTRING(distance, 1, 4)
WHERE distance LIKE '%.%';

update runner_orders
SET duration = SUBSTRING(duration, 1, 2)
WHERE duration IS NOT NULL;

-- perform ETL on customer_orders table
SELECT * FROM customer_orders;

update customer_orders
SET exclusions = NULL
WHERE exclusions = 'null' OR exclusions = '';

update customer_orders
SET extras = NULL
WHERE extras = 'null' OR extras = '';

ALTER TABLE customer_orders
ADD orderdate DATE;

ALTER TABLE customer_orders
ADD ordertime TIME;

update customer_orders
SET orderdate = CAST(order_time AS DATE), ordertime = CAST(order_time AS TIME);

-- Pizza Metrics
-- 1. How many pizzas were ordered?
SELECT COUNT(order_id) FROM customer_orders;
-- 14 pizzas were ordered in total.

-- 2. How many unique customer orders were made?
SELECT COUNT(DISTINCT(order_id)) FROM customer_orders;
-- There were 10 unique customer orders made.

-- 3. How many successful orders were delivered by each runner?
SELECT r.runner_id, COUNT(r.distance) AS delivered
FROM runner_orders r
WHERE r.distance IS NOT NULL
GROUP BY r.runner_id
ORDER BY r.runner_id;
-- Runner 1 delivered 4 orders, Runner 2 delivered 3, and Runner 3 delivered 1.

-- 4. How many of each type of pizza was delivered?
SELECT p.pizza_name, COUNT(c.pizza_id) AS "amount delivered"
FROM pizza_names p
INNER JOIN customer_orders c ON p.pizza_id = c.pizza_id
	INNER JOIN runner_orders r ON r.order_id = c.order_id
WHERE r.distance IS NOT NULL
GROUP BY p.pizza_name;
-- 9 Meatlovers pizzas and 3 Vegetarian Pizzas were delivered.

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT c.customer_id, SUM(CASE WHEN c.pizza_id = 1 THEN 1 ELSE 0 END) AS "Meat Lovers",
SUM(CASE WHEN c.pizza_id = 2 THEN 1 ELSE 0 END) AS "Vegetarian"
FROM pizza_names p
INNER JOIN customer_orders c ON p.pizza_id = c.pizza_id
GROUP BY c.customer_id
ORDER BY c.customer_id;
-- Customer 101 ordered 2 ML and 1 V, Customer 102 ordered 2 ML and 1 V, 
-- Customer 103 ordered 3 ML and 1 V, Customer 104 ordered 3 ML and 0 V, and Customer 105 ordered 0 ML and 1 V

-- 6. What was the maximum number of pizzas delivered in a single order?
SELECT c.order_id, COUNT(r.order_id) AS "pizzas delivered"
FROM customer_orders c
JOIN runner_orders r ON c.order_id = r.order_id
WHERE r.distance IS NOT NULL
GROUP BY c.order_id
ORDER BY c.order_id;
-- The maximum number of pizzas delivered in a single order is 3 pizzas.

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT c.customer_id, SUM(CASE WHEN c.exclusions IS NULL THEN 0 ELSE 1 END) AS "changes",
SUM(CASE WHEN c.exclusions IS NULL THEN 1 ELSE 0 END) AS "no changes"
FROM customer_orders c
JOIN runner_orders r ON c.order_id = r.order_id
WHERE r.distance IS NOT NULL
GROUP BY c.customer_id
ORDER BY c.customer_id;
-- Customer 101 was delivered 2 pizzas with no changes, Customer 102 was delivered 3 pizzas with no changes,
-- Customer 103 was delivered 3 pizzas with at least 1 change, Customer 104 was delivered 1 pizzas with at least 1 change
-- and 2 pizzas with no changes, and Customer 105 was delivered 1 pizza with no change.

-- 8. How many pizzas were delivered that had both exclusions and extras?
SELECT c.customer_id, c.order_id, SUM(CASE WHEN c.exclusions IS NOT NULL AND c.extras IS NOT NULL THEN 1 ELSE 0 END) AS "exclusions/extras"
FROM customer_orders c
JOIN runner_orders r ON c.order_id = r.order_id
WHERE r.distance IS NOT NULL
GROUP BY c.customer_id, c.order_id
ORDER BY c.customer_id, c.order_id;
-- There was only 1 pizza that was delivered with both exclusions and extras.

-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT to_char(ordertime, 'HH24') AS hour, COUNT(*)
FROM customer_orders c
GROUP BY hour
ORDER BY hour;

-- 10. What was the volume of orders for each day of the week?
SELECT (DATE_PART('dow', c.orderdate) + 1) AS DOW, COUNT(*)
FROM customer_orders c
GROUP BY DOW
ORDER BY DOW;
-- There was 1 order on the 1st day of the week, five orders on the 2nd day of the week,
-- 5 orders for the 6th day of the week, and 3 orders for the 7th day of the week

-- Runner and Customer Experience
-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT (DATE('2021-01-01') + ((r.registration_date - '2021-01-01')/7 * interval '1 week')) AS week, COUNT(*)
FROM runners r
GROUP BY week
ORDER BY week;
-- Starting 01-01, 2 drivers signed up. Starting 01-08, 1 driver signed up. Starting 01-15, 1 driver signed up.

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
WITH cte AS
(select r.runner_id, TO_TIMESTAMP(r.pickup_time, 'YYYY-MM-DD HH24:MI:SS')::timestamp as pickuptime, c.order_time
	from customer_orders c
	INNER JOIN runner_orders r ON c.order_id = r.order_id
	WHERE r.pickup_time IS NOT NULL
 	ORDER BY r.runner_id)
SELECT runner_id, AVG(pickuptime - order_time) AS mins
FROM cte
GROUP BY runner_id
ORDER BY runner_id;
-- The average time to arrive at the Pizza Runner HQ for runner 1 was 15 mins and 41 secs,
-- for runner 2 was 23 mins and 43 secs, and for runner 3 was 10 mins and 28 secs.

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH cte AS
(select r.order_id, TO_TIMESTAMP(r.pickup_time, 'YYYY-MM-DD HH24:MI:SS')::timestamp as pickuptime, c.order_time
from customer_orders c
INNER JOIN runner_orders r ON c.order_id = r.order_id
WHERE r.pickup_time IS NOT NULL
ORDER BY r.order_id),
cte2 AS
(SELECT order_id, AVG(pickuptime - order_time) AS average_mins, COUNT(*) AS pizzas
FROM cte
GROUP BY order_id
ORDER BY pizzas)
SELECT pizzas, AVG(average_mins) AS avg_prep_time
FROM cte2
GROUP BY pizzas
ORDER BY pizzas;
-- Yes, there's a relationship between the number of pizzas and how long the order takes to prepare.

-- 4. What was the average distance travelled for each customer?
WITH cte AS
(SELECT c.customer_id AS customer, CAST(r.distance AS FLOAT) AS distance
FROM customer_orders c
INNER JOIN runner_orders r ON r.order_id = c.order_id
WHERE distance IS NOT NULL)
SELECT customer, AVG(distance) AS avg_distance_km
FROM cte
GROUP BY customer
ORDER BY customer;
-- Average distance travelled for customer 101 is 20km, for customer 102 is 16.73km,
-- for customer 103 is 23.4km, for customer 104 is 10km, and for customer 105 is 25km.

-- 5. What was the difference between the longest and shortest delivery times for all orders?
WITH cte AS
(SELECT CAST(duration AS FLOAT) AS duration
FROM runner_orders)
SELECT MAX(duration) - MIN(duration) AS difference
FROM cte;
-- The difference between the longest and shortest delivery times is 30 mins.

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
WITH cte AS
(SELECT DISTINCT(c.order_id), c.customer_id, r.runner_id, CAST(r.duration AS INTEGER), CAST(r.distance AS FLOAT)
FROM runner_orders r
INNER JOIN customer_orders c ON c.order_id = r.order_id
WHERE r.duration IS NOT NULL)
SELECT order_id, runner_id, distance, duration, AVG(distance/duration)*60 AS km_per_hr
FROM cte
GROUP BY runner_id, order_id, distance, duration
ORDER BY distance;
-- A noticeable trend is that runner 2 takes deliveries that are the furthest, but has the most inconsistent speeds,
-- having an average km/hr speed of from 35.1 to 93.6 for orders with the same distance.
-- Runners 1 and 3 have delivered for orders with the shortest distances, with much more consistency.


-- 7. What is the successful delivery percentage for each runner?
WITH cte AS
(SELECT runner_id, SUM(CASE WHEN cancellation IS NULL THEN 1 ELSE 0 END) AS successes, COUNT(order_id) AS orders
FROM runner_orders
GROUP BY runner_id
ORDER BY runner_id)
SELECT runner_id, (successes::float/orders) AS success_percentage
FROM cte
GROUP BY runner_id, success_percentage
ORDER BY runner_id;
-- Successful delivery percentage for each runner is:
-- Runner 1: 100%
-- Runner 2: 75%
-- Runner 3: 50%

-- Ingredient Optimisation
-- 1. What are the standard ingredients for each pizza?
WITH cte AS
(SELECT pizza_id, CAST(s.topping AS INTEGER)
FROM pizza_recipes r, unnest(string_to_array(r.toppings, ', ')) s(topping)),
cte2 AS
(SELECT c.pizza_id, array_agg(t.topping_name) AS ingredients
FROM cte c
JOIN pizza_toppings t ON c.topping = t.topping_id
GROUP BY c.pizza_id
ORDER BY c.pizza_id)
SELECT p.pizza_name, ingredients
FROM cte2
JOIN pizza_names p ON p.pizza_id = cte2.pizza_id;
-- Standard ingredients for Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, and Salami
-- For Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce

-- 2. What was the most commonly added extra?
WITH cte AS
(SELECT pizza_id, CAST(s.topping AS INTEGER)
FROM customer_orders c, unnest(string_to_array(c.extras, ', ')) s(topping)
WHERE c.extras IS NOT NULL)
SELECT c.topping, COUNT(c.topping) AS times_ordered, p.topping_name
FROM cte c
JOIN pizza_toppings p ON p.topping_id = c.topping
GROUP BY c.topping, p.topping_name
ORDER BY times_ordered DESC;
-- The most commonly added extra was Bacon, ordered 4 times.

-- 3. What was the most common exclusion?
WITH cte AS
(SELECT pizza_id, CAST(s.topping AS INTEGER)
FROM customer_orders c, unnest(string_to_array(c.exclusions, ', ')) s(topping)
WHERE c.exclusions IS NOT NULL)
SELECT c.topping, COUNT(c.topping) AS times_excluded, p.topping_name
FROM cte c
JOIN pizza_toppings p ON p.topping_id = c.topping
GROUP BY c.topping, p.topping_name
ORDER BY times_excluded DESC;
-- The most common exclusion was Cheese, excluded 4 times.

-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
-- 		Meat Lovers
-- 		Meat Lovers - Exclude Beef
-- 		Meat Lovers - Extra Bacon
-- 		Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers


-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- 		For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"


-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?


-- Pricing and Ratings
-- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
-- 2. What if there was an additional $1 charge for any pizza extras?
-- 		Add cheese is $1 extra
-- 3. What if substitutes were allowed at no additional cost but any additional extras were charged at $1?
-- 		Exclude Cheese and add Bacon is free
-- 		Exclude Cheese but add bacon and beef costs $1 extra
-- 4. What if meat substitutes and vegetable substitutes were allowed but any change outside were charged at $2 and $1 respectively?
-- 		Exclude Cheese and add Bacon is $2 extra
-- 		Exclude Beef and add mushroom is $1 extra
-- 		Exclude Beef and add Bacon is free
-- 		Exclude Beef and Mushroom, and add Bacon and Cheese is free
-- 5. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
-- 6. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
-- 		customer_id
-- 		order_id
-- 		runner_id
-- 		rating
-- 		order_time
-- 		pickup_time
-- 		Time between order and pickup
-- 		Delivery duration
-- 		Average speed
-- 		Total number of pizzas
-- 7. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
-- 8. If 1 unit of each ingredient costs $0.50 - how much net revenue will Pizza Runner make if the costs from question 30 are used?

-- Bonus Questions
-- 1. If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?
-- 2. Danny notices a new existing data issue - the recipe for Meat Lovers pizzas was actually incorrect for the second week of January - there was actually a shortage of salami! Write an UPDATE statement to reflect this in the existing data
-- 3. Danny wants you to create 2 database views on top of the customer_orders and the runner_orders data tables to fix up all of the data issues