/*Prepping Data Challenge: Restaurant Menu & Orders (week 15)
This week we want to analyse the orders that customers have made over a period of time in our restaurant Serendipia. 
In order to identify how much money we earn each day of the week and also to discover who our top customer is. 

#### Requirement:
 - Input the data
 - Modify the structure of the Menu table so we can have one column for the Type (pizza, pasta, house plate), 
   the name of the plate, ID, and Price
 - Modify the structure of the Orders table to have each item ID in a different row
 - Join both tables
 - On Monday's we offer a 50% discount on all items. Recalculate the prices to reflect this
 - For Output 1, we want to calculate the total money for each day of the week
 - For Output 2, we want to reward the customer who has made the most orders for their loyalty. 
  Work out which customer has ordered the most single items..

*/

 SELECT * FROM Menu;
 SELECT * FROM Orders;

-- Modify the structure of the Menu Table

CREATE TABLE Menu_Normalized AS
SELECT
    'Pizza' AS Type, Pizza AS Plate_Name, Pizza_ID AS ID, Pizza_Price AS Price FROM Menu
UNION ALL
SELECT
    'Pasta', Pasta, Pasta_ID, Pasta_Price FROM Menu
WHERE Pasta IS NOT NULL
UNION ALL
SELECT
    'House Plate', House_Plates, House_Plates_ID, House_Plates_Prices FROM Menu
WHERE House_Plates IS NOT NULL;

SELECT * FROM Menu_Normalized;

-----------------------------------------------
-- Modify the Structure of the Orders Table

CREATE TABLE Orders_Normalized AS
SELECT
        "order_date",
        "customer_name",
        UNNEST(STRING_TO_ARRAY("order_items", '-'))::INTEGER AS "Order"
FROM Orders;
	
SELECT * FROM Orders_Normalized;

-----------------------------
-- Join the tables
CREATE VIEW Orders_With_Menu AS
SELECT 
    o.customer_name,
    o.order_date,
    o."Order",
    m.type,
    m.plate_name,
    m.price
FROM Orders_Normalized o
LEFT JOIN Menu_Normalized m ON o."Order" = m.id;

SELECT * FROM Orders_With_Menu;

-----------------------------

-- Apply Monday discount (50% off)
-- Create a view to recalculate prices for orders placed on Monday
CREATE VIEW Orders_With_Discount AS
SELECT 
    *,
    CASE 
        WHEN TO_CHAR(order_date, 'Day') ILIKE 'Monday%' THEN price * 0.5
        ELSE price
    END AS Discounted_Price
FROM Orders_With_Menu;

SELECT * FROM Orders_With_Discount;

-------------------------------------------------

-- Output 1 - Total money earned per day of the week
CREATE VIEW Total_Revenue_Per_Day AS
SELECT 
    TO_CHAR(order_date, 'Day') AS Day_Of_Week,
    SUM(discounted_price) AS Total_Revenue
FROM Orders_With_Discount
GROUP BY TO_CHAR(order_date, 'Day')
ORDER BY Total_Revenue DESC;

SELECT * FROM Total_Revenue_Per_Day;

--------------------------------------------------
-- Output 2 - Customer with the most single items ordered
CREATE VIEW Top_Customer AS
SELECT 
    customer_name,
    COUNT(DISTINCT "Order") AS Total_Items_Ordered
FROM Orders_Normalized
GROUP BY customer_name
ORDER BY Total_Items_Ordered DESC
LIMIT 1;

SELECT * FROM Top_Customer;


