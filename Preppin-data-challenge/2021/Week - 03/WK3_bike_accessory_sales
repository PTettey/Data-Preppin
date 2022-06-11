/*Preppin Data 2021: Bike Accessory Sales (week 3)
- Input the data source by pulling together all the tables
- Pivot 'New' columns and 'Existing' columns
- Split the former column headers to form:
  * Customer Type * Product
- Rename the measure created by the Pivot as 'Products Sold'
- Create a Store column from the data
- Remove any unnecessary data fields
- Turn Date into Quarter
- Aggregate to form two separate outputs of the number of products sold by:
  * Product, Quarter * Store, Customer Type, Product
- Output each data set as a csv file*/

---- Input the data source by pulling together all the tables
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

---- Pivot 'New' columns and 'Existing' columns
---- Rename the measure created by the Pivot as 'Products Sold'

CREATE TEMPORARY TABLE pivot AS
SELECT
	date,
	store,
	UNNEST(ARRAY['New - Saddles','New - Mudguards','New - Wheels','New - Bags','Existing - Saddles','Existing - Mudguards','Existing - Wheels','Existing - Bags']) AS  products_sold,
	UNNEST(ARRAY[new_saddles, new_mudguards, new_wheels, new_bags, existing_saddles, existing_mudguards, existing_wheels, existing_bags]) AS  products_amount
FROM total_data;
SELECT * FROM pivot; 

-- Split products into Customer type and Product

DROP TABLE IF EXISTS split ;
CREATE TEMPORARY TABLE 	split AS
SELECT
    date,
	split_part(products_sold,' - ', 1) AS customer_type,
	split_part(products_sold,' - ', 2) AS product,
	store,
	products_amount
FROM pivot;
SELECT * FROM split;

---- Aggregate to form output of the number of products sold by: Product, Quarter

SELECT
	product,
	date_part('quarter', date) AS Quarter,
	SUM(products_amount) AS products_sold
FROM split
GROUP BY 1,2
ORDER BY 1,2;

-- Aggregate to form output of the number of products sold by: Store, Customer Type, Product

SELECT
	store,
	customer_type,
	product,
	SUM(products_amount) AS products_sold
FROM split
GROUP BY 1,2,3
ORDER BY 1,2,3;
