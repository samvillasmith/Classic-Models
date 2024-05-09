-- Calculate the average order amount for each country
SELECT 
	country, AVG(priceEach * quantityOrdered) AS avg_order_value
FROM customers cust
	INNER JOIN orders ord ON  cust.customerNumber = ord.customerNumber
	INNER JOIN orderdetails od ON ord.orderNumber = od.orderNumber
GROUP BY country
ORDER BY avg_order_value DESC;

-- Calculate the total sales amount for each product line
SELECT 
	productLine, SUM(priceEach * quantityOrdered) as sales_value
FROM orderdetails od
	INNER JOIN products p ON  od.productCode = p.productCode
GROUP BY productLine;

-- List the top 10 best-selling products based on total quantity sold
SELECT
    p.productCode,
    p.productName,
    SUM(od.quantityOrdered) AS total_quantity_sold
FROM
    orderdetails od
    INNER JOIN orders o ON od.orderNumber = o.orderNumber
    INNER JOIN products p ON od.productCode = p.productCode
GROUP BY
    p.productCode,
    p.productName
ORDER BY
    total_quantity_sold DESC
LIMIT 10;

-- Evaluate the sales performane of each sales representative
SELECT
    e.firstName,
    e.lastName,
    SUM(od.quantityOrdered * od.priceEach) AS total_sales
FROM
    employees e
    INNER JOIN customers c 
    ON c.salesRepEmployeeNumber = e.employeeNumber AND e.jobTitle = 'Sales Rep' 
    LEFT JOIN orders o 
    ON c.customerNumber = o.customerNumber 
    LEFT JOIN orderdetails od 
    ON o.orderNumber = od.orderNumber
GROUP BY
    e.firstName, e.lastName;
    
-- Calculate the average number of orders placed by each customer
SELECT AVG(total_orders) AS avg_orders_per_customer
FROM (
  SELECT c.customerNumber, COUNT(o.orderNumber) AS total_orders
  FROM customers c
  LEFT JOIN orders o ON c.customerNumber = o.customerNumber
  GROUP BY c.customerNumber
) AS subquery;

-- Calculate the percentage of orders that were shipped on time
SELECT SUM(CASE WHEN shippedDate <= requiredDate THEN 1  ELSE 0 END) / COUNT(orderNumber) * 100 AS PERCENT_ON_TIME
FROM orders;

-- Calculate the profit margin for each product by subracting the cost of gooods sold (COGS) from the sales revenue
SELECT productName, SUM((priceEach * quantityOrdered) - (buyPrice * quantityOrdered)) AS net_profit
FROM products p
INNER JOIN orderdetails o 
ON p.productCode = o.productCode
GROUP BY productName;

-- Segment customers based on their total purchase amount
SELECT c.*, t2.customer_segment
FROM customers c
LEFT JOIN
(SELECT *,
	CASE WHEN total_purchase_value > 100000 THEN 'High Value'
		 WHEN total_purchase_value BETWEEN 50000 AND 100000 THEN 'Medium Value'
		 WHEN total_purchase_value < 50000 THEN 'Low Value'
ELSE 'Other' END AS customer_segment
FROM
(SELECT customerNumber, SUM(priceEach * quantityOrdered) AS total_purchase_value
FROM orders o
INNER JOIN orderdetails od
ON o.orderNumber = od.orderNumber
GROUP BY customerNumber) t1
) t2
ON c.customerNumber = t2.customernumber;

-- Identify frequently co-purchased products to understand cross-selling opportunities
SELECT p1.productName, p1.productCode AS product1, p2.productName, p2.productCode AS product2, COUNT(*) AS co_purchase_frequency
FROM orderdetails od1
JOIN orderdetails od2 ON od1.orderNumber = od2.orderNumber AND od1.productCode <> od2.productCode
JOIN products p1 ON od1.productCode = p1.productCode
JOIN products p2 ON od2.productCode = p2.productCode
GROUP BY p1.productCode, p2.productCode, p1.productName, p2.productName
ORDER BY co_purchase_frequency DESC
LIMIT 10;