/*Prepping Data Challenge: Bike Sales (week 1)
This week's focus is on cleaning the dataset, and make them ready to answer some questions from our stakeholders.
Requirement:
1. Connect and load the csv file.
2. Split the 'Store-Bike' field into 'Store' and 'Bike'
3. Clean up the 'Bike' field to leave just three values in the 'Bike' field (Mountain, Gravel, Road)
4. Create two different cuts of the date field: 'quarter' and 'day of month'
5. Remove the first 10 orders as they are test values
6. Output the data as a csv*/
CREATE TABLE WK01_Bike_Sales (order_id serial,          --Connect and load the csv file
							  customer_age numeric, 
							  bike_value numeric, 
							  existing_customer varchar(3), 
							  order_date date, 
							  Store_bike varchar(50));

WITH clean AS (
	SELECT
		order_id,
		customer_age,
		bike_value,
		existing_customer,
		order_date,
		date_part('quarter', order_date) AS qt, 		--Create two different cuts of the date field: 'quarter' and 'day of month' 
		date_part('day', order_date) AS day_of_month, 	--Create two different cuts of the date field: 'quarter' and 'day of month' 
		split_part(store_bike, ' - ', 1) AS store, 		--Split the 'Store-Bike' field into 'Store' and 'Bike'
		split_part(store_bike, ' - ', 2) AS bike 		--Split the 'Store-Bike' field into 'Store' and 'Bike'
	FROM
		wk01_bike_sales
	WHERE order_id > 10) 								--Remove the first 10 orders as they are test values
SELECT
	qt,
	store,
	CASE
		WHEN LEFT(bike, 1) = 'G' THEN 'Gravel'
		WHEN LEFT(bike, 1) = 'M' THEN 'Mountain'
		WHEN LEFT(bike, 1) = 'R' THEN 'Road'
		ELSE 'Check'
	END AS bike, 				-- Clean up the 'Bike' field to leave just three values in the 'Bike' field (Mountain, Gravel, Road) 
	order_id,
	customer_age,
	bike_value,
	existing_customer,
	day_of_month
FROM clean
ORDER BY 1;