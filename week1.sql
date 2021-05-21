CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);
 
INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  
-- Case Study Questions

-- 1. What is the total amount each customer spent at the restaurant?
SELECT sales.customer_id, SUM(m.price) AS "Total Spent"
FROM sales
INNER JOIN menu m ON m.product_id = sales.product_id
WHERE sales.product_id = m.product_id
GROUP BY sales.customer_id
ORDER BY sales.customer_id;
-- Customer A spent $76, Customer B spent $74, and Customer C spent $36.

-- 2. How many days has each customer visited the restaurant?
SELECT sales.customer_id, COUNT(DISTINCT sales.order_date) AS "Days Visited"
FROM sales
GROUP BY sales.customer_id
ORDER BY sales.customer_id;
-- Customer A has visited 4 times, Customer B has visited 6 times, Customer C has visited 2 days.

-- 3. What was the first item from the menu purchased by each customer?
WITH cte (customer, order_date, product_id, product, price, RowNumber) AS
(SELECT sales.customer_id AS customer, sales.order_date AS order_date, sales.product_id AS product_id,
 m.product_name AS product, m.price AS price, ROW_NUMBER() OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date, sales.product_id) AS RowNumber
FROM sales
INNER JOIN menu m ON m.product_id = sales.product_id)

SELECT customer, product, order_date, RowNumber
FROM cte
WHERE RowNumber = 1;
-- First item purchased by Customer A is sushi, by Customer B is curry, and by Customer C is ramen.

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers? 
SELECT m.product_name, COUNT(sales.product_id) AS "Times Purchased"
FROM sales
INNER JOIN menu m ON m.product_id = sales.product_id
GROUP BY m.product_name
ORDER BY "Times Purchased" DESC;
-- Most purchased item was ramen, which was ordered 8 times

-- 5. Which item was the most popular for each customer?
WITH cte (customer, times_ordered, product, RowNumber) AS
(SELECT sales.customer_id AS customer, COUNT(sales.product_id) AS times_ordered,
 m.product_name AS product, ROW_NUMBER() OVER (PARTITION BY sales.customer_id ORDER BY COUNT(sales.product_id) DESC) AS RowNumber
FROM sales
INNER JOIN menu m ON m.product_id = sales.product_id
GROUP BY sales.customer_id, m.product_name),

cte2 (customer, times_ordered, product, MaxOrdered) AS
(SELECT customer, times_ordered, product, MAX(times_ordered) OVER (PARTITION BY customer ORDER BY customer) AS "MaxOrdered"
	FROM cte
	ORDER BY customer)

SELECT customer, times_ordered, product
FROM cte2
WHERE times_ordered = MaxOrdered;
-- Most popular item for Customer A was Ramen, for Customer B was a tie between all three menu items, and for Customer C was also ramen.


-- 6. Which item was purchased first by the customer after they became a member?
WITH cte AS
(SELECT sales.customer_id AS customer, m.product_name AS product, sales.order_date AS date, b.join_date AS joined
 FROM menu m
 INNER JOIN sales ON m.product_id = sales.product_id
 	INNER JOIN members b ON b.customer_id = sales.customer_id
 ORDER BY sales.customer_id),
cte2 AS
(SELECT *, ROW_NUMBER() OVER (PARTITION BY customer ORDER BY date) AS RowNumber
FROM cte
WHERE date >= joined)

SELECT * FROM cte2
WHERE RowNumber = 1;
-- First product ordered after becoming a member for Customer A is curry, for Customer B is sushi

-- 7. Which item was purchased just before the customer became a member?
WITH cte AS
(SELECT sales.customer_id AS customer, m.product_name AS product, sales.order_date AS date, b.join_date AS joined, 
 ROW_NUMBER() OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date) AS RowNumber
 FROM menu m
 INNER JOIN sales ON m.product_id = sales.product_id
 	INNER JOIN members b ON b.customer_id = sales.customer_id
 ORDER BY sales.customer_id),
 
cte2 AS
(SELECT *, ROW_NUMBER() OVER (PARTITION BY customer ORDER BY RowNumber DESC) AS reversed
FROM cte
WHERE date < joined)

SELECT customer, product, date, joined
FROM cte2
WHERE reversed = 1;
-- Last item purchased before becoming a member for Customer A was curry, for Customer B was sushi

-- 8. What is the total items and amount spent for each member before they became a member?
WITH cte AS
(SELECT sales.customer_id AS customer, m.product_name AS product, sales.order_date AS date, b.join_date AS joined, m.price AS price,
 ROW_NUMBER() OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date) AS RowNumber
 FROM menu m
 INNER JOIN sales ON m.product_id = sales.product_id
 	INNER JOIN members b ON b.customer_id = sales.customer_id
 ORDER BY sales.customer_id)

SELECT customer, COUNT(customer) AS items, SUM(price) AS spent
FROM cte
WHERE date < joined
GROUP BY customer;
-- Customer A spent $25 on 2 items and Customer B spent $40 on 3 items before becoming members.

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH cte AS
(SELECT sales.customer_id AS customer, m.product_id AS product_id, sales.order_date AS date, m.price AS price, price*10 AS points
 FROM menu m
 INNER JOIN sales ON m.product_id = sales.product_id
 ORDER BY sales.customer_id),
cte2 AS
(SELECT *, CASE 
WHEN product_id = 1 THEN points*2
ELSE points
END AS FinalPoints
FROM cte)

SELECT customer, SUM(finalpoints) AS Points 
FROM cte2
GROUP BY customer;
-- Customer A has 860 pts, Customer B has 940 pts, and Customer C has 360 points

-- 10. In the first week after a customer joins the program (including their join date) 
-- they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
WITH cte AS
(SELECT sales.customer_id AS customer, m.product_id AS product_id, sales.order_date AS date, b.join_date AS joined, m.price AS price, price*10 AS points
 FROM menu m
 FULL JOIN sales ON m.product_id = sales.product_id
 FULL JOIN members b ON sales.customer_id = b.customer_id
 ORDER BY sales.customer_id, date),
cte2 AS
(SELECT *, CASE 
WHEN product_id = 1 THEN points*2
WHEN joined IS NOT NULL AND date >= joined THEN points*2
ELSE points
END AS FinalPoints
FROM cte)

SELECT customer, SUM(finalpoints) AS points_end_jan
FROM cte2
WHERE date < '2021-02-01'
GROUP BY customer;
-- Customer A has 1370 pts, Customer B has 940 pts at the end of January
