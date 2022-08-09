/*Prepping Data Challenge: Prep Air In-Flight Purchases (week 14)
For this week's challenge, there is a selection of different data sources that needs 
to be combined them to answer some questions that will help in the understanding of 
some purchasing patterns on the flights.

#### Requirement:
 - Input the Data
 - Assign a label for where each seat is located. 
   They are assigned as follows:
     * A & F - Window Seats
     * B & E - Middle Seats
     * C & D - Aisle Seats 
 - Combine the Seat List and Passenger List tables. 
 - Parse the Flight Details so that they are in separate fields  
 - Calculate the time of day for each flight. 
   They are assigned as follows: 
    * Morning - Before 12:00 
    * Afternoon - Between 12:00 - 18:00
    * Evening - After 18:00
 - Join the Flight Details & Plane Details to the Passenger & Seat tables. 
 We should be able to identify what rows are Business or Economy Class for each flight. 
 - Answer the following questions: 
   1. What time of day were the most purchases made? We want to take a look at the average 
      for the flights within each time period. 
   2. What seat position had the highest purchase amount? Is the aisle seat the highest earner 
      because it's closest to the trolley?
   3. As Business Class purchases are free, how much is this costing us? 
*/
-- SELECT * FROM "Flight";
-- SELECT * FROM "Plane";
-- SELECT * FROM "passenger";
-- SELECT * FROM "seat";

DROP TABLE IF EXISTS label_seats;
WITH Unpivoted AS (
	SELECT
		"Row",
		seat_letter,
		seat_number
	FROM "seat"
	CROSS JOIN LATERAL (
	VALUES ('A', "A"),('B',"B"),('C',"C"),('D',"C"),('E',"E"),('F',"F")) AS s(seat_letter, seat_number)
)
SELECT 
	*,
	CASE 
	WHEN seat_letter = 'A' OR seat_letter = 'F' THEN 'Window'
	WHEN seat_letter = 'B' OR seat_letter = 'E' THEN 'Middle'
	WHEN seat_letter = 'C' OR seat_letter = 'D' THEN 'Aisle'
	ELSE 'Check'
	END AS Seat_type
INTO TEMPORARY TABLE label_seats -- creates new temp table
FROM Unpivoted;

SELECT * FROM label_seats;
---------------------------
-- Parse flight details so that they are in separate fields
-- Calculate the time of day for each flight
DROP TABLE IF EXISTS parsed_flight_details;
WITH Parsed AS (
		SELECT 
	--		*,
			CAST( ((regexp_match("[FlightID|DepAir|ArrAir|DepDate|DepTime]", '\d+'))[1]) AS INT) AS flightID,
			LEFT(((regexp_match("[FlightID|DepAir|ArrAir|DepDate|DepTime]", '\w{3}\|\w{3}'))[1]),3) AS origin,
			RIGHT(((regexp_match("[FlightID|DepAir|ArrAir|DepDate|DepTime]", '\w{3}\|\w{3}'))[1]),3) AS destination,
			(regexp_match("[FlightID|DepAir|ArrAir|DepDate|DepTime]", '\d{4}-\d{2}-\d{2}'))[1] AS Depdate,
			(regexp_match("[FlightID|DepAir|ArrAir|DepDate|DepTime]", '\d{2}:\d{2}:\d{2}'))[1] AS Deptime
		FROM "Flight" 
)
SELECT 
	*, 
	CASE 
	WHEN CAST( LEFT(Deptime,2) AS INT) < 12 THEN 'Morning'
	WHEN CAST( LEFT(Deptime,2) AS INT) > 12 AND CAST( LEFT(Deptime,2) AS INT) < 18 THEN 'Afternoon'
	WHEN CAST( LEFT(Deptime,2) AS INT) > 18 THEN 'Evening'
	ELSE 'Check' END AS time_of_day
INTO TEMPORARY TABLE parsed_flight_details
FROM Parsed;

SELECT * FROM parsed_flight_details;

-----------------------------
-- identify what rows are Business or Economy Class for each flight

DROP TABLE IF EXISTS plane_details;
SELECT
	"FlightNo.",
	"Business Class",
	CAST( SUBSTRING("Business Class", 3) AS INT) AS "business class"
INTO TEMPORARY TABLE plane_details
FROM "Plane";

SELECT * FROM plane_details;

--------------------------------------------------
--Combine the Passenger List table with New Seat List, New Flight Details and New Plane Details

DROP TABLE IF EXISTS combined;
SELECT
	pl."first_name",
	pl."last_name",
	pl."passenger_number",
	pl."flight_number",
	pl."purchase_amount",
	ns."Row",
	ns.seat_letter,
	ns.seat_type,
	fd.origin,
	fd.destination,
	fd.Depdate,
	fd.Deptime,
	fd.time_of_day,
	pd."business class",
	CASE WHEN ns."Row" <= pd."business class" THEN 'Business' ELSE 'Economy' END AS seat_class
INTO TEMPORARY TABLE Combined
FROM "passenger" pl
INNER JOIN 	label_seats ns 		ON pl."passenger_number" = ns.seat_number
INNER JOIN 	parsed_flight_details fd 	ON pl."flight_number" = fd.flightID
INNER JOIN 	plane_details pd 	ON pl."flight_number" = pd."FlightNo.";

SELECT * FROM Combined 
ORDER BY flight_number, passenger_number; 

-- STEP 5 Get the final results from the combined table in three separate queries
-- 1. What time of day were the most purchases made? (Avg per flight)
WITH purchases_made AS (
		SELECT 
			flight_number,
			time_of_day,
			SUM(purchase_amount) AS purchases 
		FROM Combined
		WHERE seat_class = 'Economy'
		GROUP BY 
			flight_number, 
			time_of_day
)
SELECT 
	ROW_NUMBER() OVER (ORDER BY AVG(purchases) DESC) AS Rank1,
	time_of_day,
	CAST( AVG(purchases) AS DECIMAL (7,2)) AS Purchase_amount 
FROM purchases_made
GROUP BY time_of_day
ORDER BY AVG(purchases) DESC;

-- 2. What seat position had the highest purchase amount? 
SELECT 
	ROW_NUMBER() OVER (ORDER BY SUM(purchase_amount) DESC) AS Rank1,	
	seat_type as seat_position,
	SUM(purchase_amount) AS purchase_amount
FROM Combined
WHERE seat_class = 'Economy'
GROUP BY seat_type
ORDER BY SUM(purchase_amount) DESC;

-- 3. Business class purchases are free. How much is this costing us?
SELECT 
	ROW_NUMBER() OVER (ORDER BY SUM(purchase_amount) DESC) AS Rank1,
	seat_class,
	SUM(purchase_amount) AS purchase_amount
FROM Combined
GROUP BY seat_class
ORDER BY SUM(purchase_amount) DESC;