CREATE DATABASE BLINKIT;
USE BLINKIT;
SHOW TABLES;
CREATE TABLE blinkit_grocery_data (
    Item_Fat_Content VARCHAR(50),
    Item_Identifier VARCHAR(20),
    Item_Type VARCHAR(100),
    Outlet_Establishment_Year INT,
    Outlet_Identifier VARCHAR(20),
    Outlet_Location_Type VARCHAR(50),
    Outlet_Size VARCHAR(50),
    Outlet_Type VARCHAR(100),
    Item_Visibility FLOAT,
    Item_Weight FLOAT,
    Total_Sales DECIMAL(10,2),
    Rating INT
);

select  Item_Fat_Content from  blinkit_grocery_data;
SET SQL_SAFE_UPDATES = 0;
# replacing the value of Item_Fat_Content
UPDATE blinkit_grocery_data
SET Item_Fat_Content =
CASE
    WHEN Item_Fat_Content IN ('LF', 'low fat') THEN 'Low Fat'
    WHEN Item_Fat_Content = 'reg' THEN 'Regular'
    ELSE Item_Fat_Content
END;

select distinct(Item_Fat_Content) From blinkit_grocery_data;

select * from blinkit_grocery_data;
select cast(sum(total_sales)/ 1000000 as decimal(10,2)) as total_sales_millions 
from blinkit_grocery_data;

select round(avg(total_sales),0) as avg_sales from blinkit_grocery_data
where Outlet_Establishment_Year = 2022;
select count(*) from blinkit_grocery_data;

select cast(sum(total_sales)/ 1000000 as decimal(10,2)) as total_sales_millions 
from blinkit_grocery_data
where Item_Fat_Content = 'Low Fat';

select cast(sum(total_sales)/ 1000000 as decimal(10,2)) as total_sales_millions 
from blinkit_grocery_data
where Outlet_Establishment_Year = 2022;

select round(avg(Rating),2) as avg_rating from blinkit_grocery_data;

#How do Total Sales compare between different Item Fat Content categories?
SELECT 
    Item_Fat_content, ROUND(SUM(Total_Sales), 2) AS Total_sales
FROM
    blinkit_grocery_data
GROUP BY Item_Fat_content
ORDER BY Total_Sales DESC;

#For outlets established in 2022, what is the performance breakdown by Item Fat Content?
SELECT Item_Fat_content,
        ROUND(SUM(Total_Sales), 2) AS Total_sales,
        Round(avg(total_sales),0) as avg_sales,
        COUNT(*) as No_Of_Items,
        Round(avg(Rating),2) as avg_rating
FROM blinkit_grocery_data
where Outlet_Establishment_Year = 2022
GROUP BY Item_Fat_content
ORDER BY Total_Sales DESC;

#What are the top 5 Item Types for outlets established in 2022 based on total sales?
SELECT  Item_Type,
        ROUND(SUM(Total_Sales), 2) AS Total_sales,
        Round(avg(total_sales),0) as avg_sales,
        COUNT(*) as No_Of_Items,
        Round(avg(Rating),2) as avg_rating
FROM blinkit_grocery_data
where Outlet_Establishment_Year = 2022
GROUP BY Item_Type
ORDER BY Total_Sales DESC limit 5;

# Calculate the total sales for each category of 'Item Type'.
SELECT
    Item_Type,
    SUM(Total_Sales) AS Total_Revenue
FROM
    blinkit_grocery_data
GROUP BY
    Item_Type
ORDER BY
    Total_Revenue DESC;
    
    
#Count how many unique outlets are in each 'Outlet Location Type' to understand the distribution of stores across different tiers.
SELECT
    Outlet_Location_Type,
    COUNT(DISTINCT Outlet_Identifier) AS Number_of_Outlets
FROM
    blinkit_grocery_data
GROUP BY
    Outlet_Location_Type;
    
    #Find the top 5 'Item Identifier' based on their average 'Rating', to identify the most well-received products.
    SELECT
    Item_Identifier,
    AVG(Rating) AS Average_Rating
FROM
    blinkit_grocery_data
GROUP BY
    Item_Identifier
ORDER BY
    Average_Rating DESC
LIMIT 5;

#Calculate the average 'Item Visibility' and average 'Total Sales' for each 'Outlet Type'.
#This can help determine if visibility correlates with sales across different store formats.
SELECT
    Outlet_Type,
    AVG(Item_Visibility) AS Avg_Visibility,
    AVG(Total_Sales) AS Avg_Sales
FROM
    blinkit_grocery_data
GROUP BY
    Outlet_Type
HAVING
    COUNT(Outlet_Identifier) > 1000 -- Optional filter to only include outlet types with significant data
ORDER BY
    Avg_Sales DESC;
    
#Compare the total sales for products labeled 'Low Fat' (or 'low fat') versus those labeled 'Regular'. 
SELECT
    CASE
        WHEN Item_Fat_Content IN ('Low Fat', 'low fat') THEN 'Low Fat'
        ELSE 'Regular'
    END AS Fat_Category,
    SUM(Total_Sales) AS Total_Sales_By_Fat_Content,
    COUNT(*) AS Total_Transactions
FROM
    blinkit_grocery_data
GROUP BY
    Fat_Category;

#Find the 'Item Type' that has the highest total sales for each 'Outlet Size' (e.g., Small, Medium, High). 
    WITH RankedSales AS (
    SELECT
        Outlet_Size,
        Item_Type,
        SUM(Total_Sales) AS Item_Type_Sales,
        ROW_NUMBER() OVER (PARTITION BY Outlet_Size ORDER BY SUM(Total_Sales) DESC) AS rn
    FROM
        blinkit_grocery_data
    GROUP BY
        Outlet_Size, Item_Type
)
SELECT
    Outlet_Size,
    Item_Type,
    Item_Type_Sales
FROM
    RankedSales
WHERE
    rn = 1;
    
#Find all items where the 'Total Sales' are at least 50% greater than the average sales for their respective 'Item Type'.
SELECT
    t1.Item_Identifier,
    t1.Item_Type,
    t1.Total_Sales,
    t2.Avg_Type_Sales
FROM
    blinkit_grocery_data t1
INNER JOIN (
    SELECT
        Item_Type,
        AVG(Total_Sales) AS Avg_Type_Sales
    FROM
        blinkit_grocery_data
    GROUP BY
        Item_Type
) t2
ON t1.Item_Type = t2.Item_Type
WHERE
    t1.Total_Sales > t2.Avg_Type_Sales * 1.5
ORDER BY
    t1.Total_Sales DESC;
