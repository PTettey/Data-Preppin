/*Preppin Data Challenge: Longest Flights (Week 24)
Input the data
- Remove the airport names from the From and To fields
e.g. New York-JFK should just read New York
- Create a Route field which concatenates the From and To fields with a hyphen
e.g. Dubai - Dallas
- Split out the Distance field so that we have one field for the Distance in km and one field for the Distance in miles
Ensure these fields are numeric
- Rank the flights based on Distance
Use a dense rank in order to match the wikipedia page
- The Scheduled duration is a Date/Time data type. Change this to a string so that we only keep the time element
- Update the First flight field to be a date
- Join on the lat & longs for the From and To cities
- Output the data

CREATE TABLE non_stop_flights (
             from_ varchar(50),to_ varchar(50),airline varchar(50),
             flight_number varchar(50),distance varchar(50),sheducled_duration time,
	         aircraft varchar(50), first_flight date);
			 
SELECT * from non_stop_flights;

CREATE TABLE world_cities (city varchar(50), lat numeric, lng numeric);
SELECT * from world_cities;*/
WITH clean_ns AS (
           SELECT
	             REGEXP_REPLACE(from_,'([-–/].*)','') AS From_, --- Remove the airport names 
                 REGEXP_REPLACE(To_, '([-–].*)','') AS To_,
	             airline,
                 flight_number,	             
	             SUBSTRING(distance, '(.*)km') AS Distance_km, --- Split out the Distance field 
                 SUBSTRING(distance, 'km\s\((.*)\smi') AS Distance_mi,
	             sheducled_duration AS Scheduled_duration,
	             aircraft,
	             first_flight
           FROM  non_stop_flights)  
  
SELECT
      DENSE_RANK() OVER( ORDER BY A.Distance_mi DESC) AS Rank_,  --- Rank the flights based on Distance
	  A.From_,
	  A.To_,
     (A.From_ || ' - ' || A.To_) AS Route, --- Create a Route field 
      A.airline,
	  A.flight_number,
	  A.distance_mi,
	  A.distance_km,
	  A.Scheduled_duration,
	  A.aircraft,
	  A.first_flight,
	  B.lat AS From_lat,
	  B.lng AS From_lng,
	  C.lat AS To_lat,
	  C.lng AS To_lng
FROM  clean_ns A 
      
LEFT JOIN world_cities B
     ON A.From_ = B.city
LEFT JOIN world_cities C
     ON A.To_ = C.city;




