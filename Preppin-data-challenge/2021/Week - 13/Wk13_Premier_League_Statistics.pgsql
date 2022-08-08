/*Preppin Data Challenge: Premier League Statistis (Week 13)
 - Input all the files
 - Remove all goalkeepers from the data set
 - Remove all records where appearances = 0
 - In this challenge we are interested in the goals scored from open play
    * Create a new “Open Play Goals” field (the goals scored from open play is the number of goals 
	   scored that weren’t penalties or freekicks)
    * Note some players will have scored free kicks or penalties with their left or right foot
    * Rename the original Goals scored field to Total Goals Scored
 - Calculate the totals for each of the key metrics across the whole time period for each player, 
   (be careful not to lose their position)
 - Create an open play goals per appearance field across the whole time period
 - Rank the players for the amount of open play goals scored across the whole time period, 
   we are only interested in the top 20 (including those that are tied for position) – Output 1
 - Rank the players for the amount of open play goals scored across the whole time period by position, 
   we are only interested in the top 20 (including those that are tied for position) – Output 2
 - Output the data – in your solution on twitter / the forums, state the name of the player who was 
    the only non-forward to make it into the overall top 20 for open play goals scored
*/
SELECT * FROM premier_league_stats;

DROP TABLE IF EXISTS altered_table;
CREATE TEMPORARY TABLE altered_table AS
SELECT 
      *, 
      ("Goals" - 
	  (CASE WHEN "Penalties scored" IS NULL THEN 0 ELSE "Penalties scored" END) - 
	  (CASE WHEN "Freekicks scored" IS NULL THEN 0 ELSE "Freekicks scored" END)) AS "Open play goals"
FROM premier_league_stats
WHERE
	"Position" != 'Goalkeeper' AND "Appearances" != 0 
ORDER BY "Name";

select * from altered_table;
---------------------------
DROP TABLE IF EXISTS totals;
CREATE TEMPORARY TABLE totals AS
SELECT
    "Name",
	"Position",
	SUM("Open play goals") AS "Open play goals",
	SUM("Goals with right foot") AS "Goals with right foot",
	SUM("Goals with left foot") AS "Goals with left foot",
	SUM("Appearances") AS Appearances,
	SUM("Goals") AS "Total goals",
	SUM("Open play goals") / SUM("Appearances") As "Open play goals per game",
	SUM("Headed goals") AS "Headed goals"
FROM
	altered_table 
GROUP BY
	"Name",
	"Position";
SELECT * FROM totals;
-----------------------------
SELECT
    "Name",
	"Position",
	"Open play goals",
	"Goals with right foot",
	"Goals with left foot",
	Appearances,
	RANK() OVER ( ORDER BY "Open play goals" DESC ) AS rank_1,
	"Total goals",
	"Open play goals per game",
	"Headed goals"
FROM
	totals
ORDER BY
	"Open play goals" DESC;
-------------------------------------
WITH position_rank AS (
	SELECT
	    "Name",
	    "Position",
		RANK() OVER (PARTITION BY "Position" ORDER BY "Open play goals" DESC ) AS Rank_by_position,
		"Open play goals",
		"Goals with right foot",
		"Goals with left foot",
		Appearances,
		"Total goals",
		"Open play goals per game",
		"Headed goals"
	FROM
		totals
	ORDER BY
		"Position",
		"Open play goals" DESC)

SELECT * FROM position_rank WHERE Rank_by_position <= 20;


