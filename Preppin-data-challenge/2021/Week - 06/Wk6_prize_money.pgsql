/*Preppin Data Challenge: Comparing Prize Money for Professional Golfers (Week 6)
- Input the data
- Answer these questions:
  * What's the Total Prize Money earned by players for each tour?
  * How many players are in this dataset for each tour?
  * How many events in total did players participate in for each tour?
  * How much do players win per event? What's the average of this for each tour?
  * How do players rank by prize money for each tour? What about overall? What is the average difference between 
    where they are ranked within their tour compared to the overall rankings where both tours are combined?
    (Here we would like the difference to be positive as you would presume combining the tours would cause 
	a player's ranking to increase)
- Combine the answers to these questions into one dataset
- Pivot the data so that we have a column for each tour, with each row representing an answer to the above questions
- Clean up the Measure field and create a new column showing the difference between the tours for each measure
  * We're looking at the difference between the LPGA from the PGA, so in most instances this number will be negative
- Output the data

CREATE TABLE official_money(
             player_name varchar(80), money varchar(20), 
	         events numeric, tour varchar(10));
			 
SELECT * from official_money;*/

DROP TABLE IF EXISTS ranking;
CREATE TEMPORARY TABLE 	ranking AS
WITH step_1 AS ( 
	SELECT
		player_name,
		TO_NUMBER(REGEXP_REPLACE(money, '([$,]+)', ''), '9G999g999') AS new_money,
		events,
		tour
	FROM official_money
)
SELECT
	*,
	RANK() OVER (ORDER BY new_money DESC) AS overall_rank, ---what is the overall rank?
	RANK() OVER (PARTITION BY tour ORDER BY new_money DESC) AS tour_rank, ---players rank per prize money
	RANK() OVER (ORDER BY new_money DESC) - RANK() OVER (PARTITION BY tour ORDER BY new_money DESC) AS rank_diff ---rank difference
FROM step_1
;

SELECT * FROM ranking; 

-- Questions

DROP TABLE IF EXISTS answers ;
CREATE TEMPORARY TABLE answers AS
SELECT
	tour,
	count(DISTINCT player_name) AS number_of_players, ---How many players are in this dataset for each tour?
	sum(events) AS number_of_events, ---How many events in total did players participate in fore each tour?
	round(avg(new_money/events),0) AS average_money_per_event, --- average money won per event?
	sum(new_money) AS total_prize_money, ---How much do players win per event?
	round(avg(rank_diff),2) AS avg_diff_in_rank
FROM
	ranking
GROUP BY 1;
SELECT * FROM answers;

--Pivot the data so that we have a column for each tour, with each row representing an answer to the above questions

DROP TABLE IF EXISTS 	pivoted ;
CREATE TEMPORARY TABLE 	pivoted AS
SELECT tour,
	UNNEST( ARRAY['avg_diff_in_rank','number_of_players','number_of_events','average_money_per_event','total_prize_money']) AS description,
	UNNEST(ARRAY[avg_diff_in_rank, number_of_players, number_of_events, average_money_per_event, total_prize_money]) AS figures
FROM answers;
SELECT * FROM pivoted;

-- Clean up the Measure field and create a new column showing the difference between the tours for each measure

WITH pivoted2 AS (
	SELECT
		description,
		MAX(CASE WHEN tour = 'PGA' THEN figures ELSE NULL END) AS PGA,
		MAX(CASE WHEN tour = 'LPGA' THEN figures ELSE NULL END) AS LPGA
	FROM pivoted 
	GROUP BY description
)
SELECT
	*,
	lpga - pga AS difference_between_tours
FROM pivoted2
;

