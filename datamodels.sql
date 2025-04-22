

create database [D597 TASK 1];
USE [D597 TASK 1];

-- Create dimension tables
CREATE TABLE Regions (
    region_id INT IDENTITY(1,1) PRIMARY KEY,
    Region NVARCHAR(50) NOT NULL
);

CREATE TABLE Countries (
    country_id INT IDENTITY(1,1) PRIMARY KEY,
    Country NVARCHAR(50) NOT NULL,
    region_id INT FOREIGN KEY REFERENCES Regions(region_id)
);

CREATE TABLE Item_Types (
    item_type_id INT IDENTITY(1,1) PRIMARY KEY,
    Item_Type NVARCHAR(50) NOT NULL,
);

CREATE TABLE Sales_Channels (
    channel_id INT IDENTITY(1,1) PRIMARY KEY,
    Sales_Channel NVARCHAR(20) NOT NULL
);

CREATE TABLE Order_Priorities (
    priority_id INT IDENTITY(1,1) PRIMARY KEY,
    Order_Priority CHAR(1) NOT NULL
);

-- Create fact table
CREATE TABLE Orders (
    order_id BIGINT PRIMARY KEY,
    Region NVARCHAR(50),
    Country NVARCHAR(50),
    Item_Type NVARCHAR(50), 
    Sales_Channel NVARCHAR(20),
    Order_Priority CHAR(1), 
    order_date DATE NULL,
    ship_date DATE NULL,
    units_sold INT NULL,
    unit_price DECIMAL(10,2) NULL,
    unit_cost DECIMAL(10,2) NULL,
    total_revenue DECIMAL(12,2) NULL,
    total_cost DECIMAL(12,2) NULL,
    total_profit DECIMAL(12,2) NULL
);

GO



select * from Orders;



-- Query1
SELECT 
    o.Region,
    SUM(o.total_profit) AS total_profit
FROM Orders o
GROUP BY o.Region
ORDER BY total_profit DESC;


--Query2
SELECT 
    o.Item_Type,
    SUM(o.units_sold) AS total_units_sold
FROM Orders o
GROUP BY o.Item_Type
ORDER BY total_units_sold DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;

--Query3
SELECT 
    o.Sales_Channel,
    FORMAT(o.order_date, 'yyyy-MM') AS Month,
    SUM(o.total_revenue) AS monthly_revenue
FROM Orders o
GROUP BY o.Sales_Channel, FORMAT(o.order_date, 'yyyy-MM')
ORDER BY o.Sales_Channel, Month;

-- Improve GROUP BY and filtering on Region
CREATE NONCLUSTERED INDEX idx_orders_region ON Orders (Region);

-- Improve GROUP BY and aggregation on Item_Type
CREATE NONCLUSTERED INDEX idx_orders_item_type ON Orders (Item_Type);

-- Improve GROUP BY on order_date and Sales_Channel
CREATE NONCLUSTERED INDEX idx_orders_order_date ON Orders (order_date);
CREATE NONCLUSTERED INDEX idx_orders_sales_channel ON Orders (Sales_Channel);

--q1opt
-- Total profit per region (uses idx_orders_region)
SELECT 
    Region,
    SUM(total_profit) AS total_profit
FROM Orders
GROUP BY Region
ORDER BY total_profit DESC;

--q2opt
-- Top 5 selling products (uses idx_orders_item_type)
SELECT TOP 5
    Item_Type,
    SUM(units_sold) AS total_units_sold
FROM Orders
GROUP BY Item_Type
ORDER BY total_units_sold DESC;


--q3opt
-- Monthly revenue by channel (uses idx_orders_order_date and idx_orders_sales_channel)
SELECT 
    Sales_Channel,
    CONVERT(VARCHAR(7), order_date, 120) AS Month,  -- yyyy-MM
    SUM(total_revenue) AS monthly_revenue
FROM Orders
GROUP BY Sales_Channel, CONVERT(VARCHAR(7), order_date, 120)
ORDER BY Sales_Channel, Month;
