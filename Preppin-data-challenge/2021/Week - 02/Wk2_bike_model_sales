/*Preppin Data 2021 Week 2
- Input the data
- Clean up the Model field to leave only the letters to represent the Brand of the bike
- Workout the Order Value using Value per Bike and Quantity.
- Aggregate Value per Bike, Order Value and Quantity by Brand and Bike Type to form:
  * quantity_sold
  * order_value
- Average Value Sold per Brand, Type
- Calculate Days to ship by measuring the difference between when an order was placed and when it was shipped as 'Days to Ship'
- Aggregate Order Value, Quantity and Days to Ship by Brand and Store to form:
  * Total Quantity Sold
  * Total Order Value
  * Average Days to Ship
- Round any averaged values to one decimal place to make the values easier to read
- Output both data setsalculate Days to ship by measuring the difference between when an order was placed and when it was shipped as 'Days to Ship'*/

CREATE TABLE WK02_Bike_Model_Sales (bike_type varchar(50),     --input the data
							        store varchar(50),
									order_date date,
									quantity numeric,
									value_per_bike numeric,
									shipping_date date,
									model varchar(50));
select * from WK02_Bike_Model_Sales;

---CREATE TEMPORARY TABLE 	clean(
SELECT
	bike_type,
	store,
	order_date,
	shipping_date,
	quantity,
	value_per_bike,
	(quantity * value_per_bike) AS order_value, 	--- Workout the Order Value using Value per Bike and Quantity.
	model,
	substring(model, '([A-Z]+)') AS brand,          --- Clean up the Model field to leave only the letters to represent the Brand of the bike
	(shipping_date - order_date) AS days_to_ship
INTO TEMP TABLE clean
FROM wk02_bike_model_sales;

SELECT * FROM clean; 

/*Aggregate Value per Bike, Order Value and Quantity by Brand and Bike Type to form:
	* Quantity Sold * Order Value * Average Value Sold per Brand, Type*/

SELECT
	brand,
	bike_type,
	sum(quantity) AS quantity_sold,
	sum(order_value) AS sum_order_value,
	round(avg(value_per_bike), 1) AS avg_bike_value_sold_per_brand_type
FROM
	clean
GROUP BY
	1,2;

/*Aggregate Order Value, Quantity and Days to Ship by Brand and Store to form:
	* Total Quantity Sold * Total Order Value * Average Days to Ship*/

SELECT
	brand,
	store,
	sum(order_value) AS sum_order_value,
	sum(quantity) AS quantity_sold,
	round(avg(days_to_ship),1) AS avg_days_to_ship
FROM
	clean 
GROUP BY
	1,2;