create database RetailSales
use RetailSales

select * from dbo.customers
select * from dbo.order_items
select * from dbo.orders
select * from dbo.products


--Display all customers who belong to Chennai.
select * from customers
where City = 'chennai';


--Display products whose price is greater than ₹1,000.
select * from products
where UnitPrice > 1000;

--Q3. Total number of orders
--Find the total number of orders.
select COUNT(*) as total_orders
from orders

--Display each product category and the number of products in that category.
select category, COUNT(*) as no_of_products
from products
group by Category


--Display the top 5 most expensive products.

select  top 5 * from products
order by UnitPrice desc


--Display all orders with the status Delivered.
select * from orders 
where OrderStatus = 'Delivered'


--Find all customers whose city value is missing (NULL).
select * from customers
where city is null


--Calculate the average price of all products.
select AVG(UnitPrice) as avg_price
from products;


--Display each order status and the total number of orders for that status.
select orderstatus, COUNT(*) as order_count
from orders
group by OrderStatus


--Find customers who have placed more than 3 orders. Display the customer ID and the number of orders.
select c.customerID, COUNT(o.OrderID)
from customers as c
inner join orders as o
on c.CustomerID = o.CustomerID
group by c.CustomerID
having COUNT(o.OrderID) > 3;	


--Calculate the total revenue from all order items using quantity and unit price.

SELECT
    SUM(quantity * unitprice) AS total_revenue
FROM order_items;


--Q12. Products Never Ordered
--Find products that have never been ordered.
select p.productID, p.productname
from products as p
left join order_items as oi
on p.ProductID = oi.ProductID



--Display the total revenue for each month.

SELECT
    YEAR(o.OrderDate) AS SalesYear,
    MONTH(o.OrderDate) AS SalesMonth,
    SUM(oi.Quantity * oi.UnitPrice) AS TotalRevenue
FROM Orders AS o
INNER JOIN Order_Items AS oi
    ON o.OrderID = oi.OrderID
GROUP BY
    YEAR(o.OrderDate),
    MONTH(o.OrderDate)
ORDER BY
    SalesYear,
    SalesMonth;




--Find the top 3 customers based on their total spending.

SELECT TOP 3
    c.CustomerID,
    c.CustomerName,
    SUM(oi.Quantity * oi.UnitPrice) AS TotalSpending
FROM Customers AS c
INNER JOIN Orders AS o
    ON c.CustomerID = o.CustomerID
INNER JOIN Order_Items AS oi
    ON o.OrderID = oi.OrderID
GROUP BY
    c.CustomerID,
    c.CustomerName
ORDER BY TotalSpending DESC;




--Find orders whose total value is greater than the average order value.

WITH OrderTotals AS (
    SELECT
        o.OrderID,
        SUM(oi.Quantity * oi.UnitPrice) AS OrderValue
    FROM Orders AS o
    INNER JOIN Order_Items AS oi
        ON o.OrderID = oi.OrderID
    GROUP BY o.OrderID
)
SELECT OrderID, OrderValue
FROM OrderTotals
WHERE OrderValue > (
    SELECT AVG(OrderValue)
    FROM OrderTotals
);


--Find customers who have never placed an order. Display CustomerID and CustomerName.
select c.customerID, c.customername
from customers as c
left join orders as o
on c.CustomerID = O.CustomerID
WHERE C.CustomerName IS NULL

--Q17. Highest-Priced Product
--Find the product with the highest price. Display ProductID, ProductName, and Price.
select productID, productname, UnitPrice
from products
order by UnitPrice desc

 
--Display each customer's ID, name, and total number of orders. Include only customers who have placed at least 2 orders.

select c.customerID, c.customername
from customers as c
left join orders as o
on c.CustomerID = o.CustomerID
where c.CustomerID = 2;


--Find the second-highest distinct product price from the Products table.
with secound_highest as (
select productname, unitprice,
DENSE_RANK()
over(order by unitprice desc) as rnk
from products)
select productname, unitprice
from secound_highest
where rnk = 2


--Calculate the total revenue for each product category. Display the category and total revenue, sorted from highest to lowest.

SELECT
    p.Category,
    SUM(oi.UnitPrice * oi.Quantity) AS TotalRevenue
FROM Products AS p
INNER JOIN Order_Items AS oi
    ON p.ProductID = oi.ProductID
GROUP BY p.Category
ORDER BY TotalRevenue DESC;

--Q21. Running Total of Revenue

--Display each order date, order ID, and the cumulative revenue over time.
select o.orderdate, o.orderID, SUM(oi.quantity * oi.unitprice)
OVER(PARTITION BY orderdate order by o.orderID) AS RUNNING_TOTAL
FROM oi.orderiteams

--Q22. Rank Products Within Each Category
select *,
RANK()
over(partition by category order by unitprice desc ) as rnk
from products

--Rank products by unit price from highest to lowest within each category.
select *,
RANK()
over(partition by category order by unitprice desc ) as rnk
from products



--Calculate monthly revenue and the percentage change compared with the previous month.


WITH MonthlySales AS (
    SELECT
        YEAR(o.OrderDate) AS SalesYear,
        MONTH(o.OrderDate) AS SalesMonth,
        SUM(oi.Quantity * oi.UnitPrice) AS Revenue
    FROM Orders AS o
    INNER JOIN Order_Items AS oi
        ON o.OrderID = oi.OrderID
    GROUP BY YEAR(o.OrderDate), MONTH(o.OrderDate)
),
PreviousSales AS (
    SELECT *,
        LAG(Revenue) OVER (
            ORDER BY SalesYear, SalesMonth
        ) AS PreviousRevenue
    FROM MonthlySales
)
SELECT *,
    (Revenue - PreviousRevenue) * 100.0
        / NULLIF(PreviousRevenue, 0) AS GrowthPercentage
FROM PreviousSales
ORDER BY SalesYear, SalesMonth;


--Q24. Customers Spending Above Average


WITH CustomerSpending AS (
    SELECT
        c.CustomerID,
        c.CustomerName,
        SUM(oi.Quantity * oi.UnitPrice) AS TotalSpending
    FROM Customers AS c
    INNER JOIN Orders AS o
        ON c.CustomerID = o.CustomerID
    INNER JOIN Order_Items AS oi
        ON o.OrderID = oi.OrderID
    GROUP BY c.CustomerID, c.CustomerName
)
SELECT *
FROM CustomerSpending
WHERE TotalSpending > (
    SELECT AVG(TotalSpending)
    FROM CustomerSpending
);


--Find customers whose total spending is greater than the average spending per customer.

WITH CustomerSpending AS (
    SELECT
        c.CustomerID,
        c.CustomerName,
        SUM(oi.Quantity * oi.UnitPrice) AS TotalSpending
    FROM Customers AS c
    INNER JOIN Orders AS o
        ON c.CustomerID = o.CustomerID
    INNER JOIN Order_Items AS oi
        ON o.OrderID = oi.OrderID
    GROUP BY c.CustomerID, c.CustomerName
)
SELECT *
FROM CustomerSpending
WHERE TotalSpending > (
    SELECT AVG(TotalSpending)
    FROM CustomerSpending
);


--Q25. Best-Selling Product in Each Category

--Find the product or products with the highest quantity sold within each category.

WITH ProductSales AS (
    SELECT
        p.Category,
        p.ProductID,
        p.ProductName,
        SUM(oi.Quantity) AS TotalQuantitySold
    FROM Products AS p
    INNER JOIN Order_Items AS oi
        ON p.ProductID = oi.ProductID
    GROUP BY p.Category, p.ProductID, p.ProductName
),
RankedProducts AS (
    SELECT *,
        DENSE_RANK() OVER (
            PARTITION BY Category
            ORDER BY TotalQuantitySold DESC
        ) AS rnk
    FROM ProductSales
)
SELECT Category, ProductID, ProductName, TotalQuantitySold
FROM RankedProducts
WHERE rnk = 1
ORDER BY Category;







