/*Preppin Data 2021: Bike Sales Target (Week 4)
- Input the file
- Union the Stores data together
- Remove any unnecessary data fields your Input step might create and rename the 'Table Names' as 'Store'
- Pivot the product columns
- Split the 'Customer Type - Product' field to create:
  * Customer Type  * Product
- Also rename the Values column resulting from you pivot as 'Products Sold'
- Turn the date into a 'Quarter' number
- Sum up the products sold by Store and Quarter
- Add the Targets data
- Join the Targets data with the aggregated Stores data
  * Note: this should give you 20 rows of data
- Remove any duplicate fields formed by the Join
- Calculate the Variance between each Store's Quarterly actual sales and the target. Call this field 'Variance to Target'
- Rank the Store's based on the Variance to Target in each quarter
  * The greater the variance the better the rank
- Output the data*/

---- Input the file and Union the Stores data together
CREATE TEMPORARY TABLE total_data AS
SELECT *, 'birmingham' AS store FROM wk3_bas_birmingham
UNION ALL
SELECT *, 'leeds' AS store  FROM wk3_bas_leeds
UNION ALL
SELECT *, 'london'AS store  FROM wk3_bas_london
UNION ALL
SELECT *, 'manchester' AS store  FROM  wk3_bas_manchester
UNION ALL
SELECT *, 'york' AS store  FROM wk3_bas_york;
SELECT * FROM total_data;


CREATE TEMPORARY TABLE total_products AS
SELECT 
    date,
    date_part('quarter', date) AS Quarter,
    (New_Saddles + New_Mudguards + New_Wheels + New_Bags + Existing_Saddles + Existing_Mudguards + Existing_Wheels + Existing_Bags) AS Products_sold,
    store
FROM total_data;

WITH all_data AS (
	SELECT
		tp.quarter,
		tp.store,
		SUM(tp.Products_sold) AS Products_sold,
		ROUND(AVG(t.target)) AS Target, 
		SUM(tp.Products_sold) - ROUND(AVG(t.target)) AS Variance_to_Target
	FROM total_products tp
	INNER JOIN wk4_bas_target t
		ON tp.quarter = t.quarter
		AND tp.store = t.store
	GROUP BY 
		tp.quarter,
		tp.store
)
SELECT 
	Quarter,
	RANK() OVER( PARTITION BY quarter ORDER BY Variance_to_Target DESC ) AS ranks,
    store,
    Products_sold,
    Target,
    Variance_to_Target
FROM all_data;