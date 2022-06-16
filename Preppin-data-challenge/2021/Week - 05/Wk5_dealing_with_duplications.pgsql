/*Preppin Data Challenge: Dealing with Duplication (Week 5)
- Input the data
- For each Client, work out who the most recent Account Manager is
- Filter the data so that only the most recent Account Manager remains
  * Be careful not to lose any attendees from the training sessions!
- In some instances, the Client ID has changed along with the Account Manager. Ensure only the most recent Client ID remains
- Output the data

CREATE TABLE joined_dataset(
             Training varchar(50), contact_email varchar(100), contact_name varchar(80),
             client varchar(100), client_ID numeric, account_manager varchar(80),
	         from_date date);
			 
SELECT * from joined_dataset;*/

CREATE TEMPORARY TABLE 	tds AS --- who attended the training
SELECT
	training,
	contact_email,
	contact_name,
	client
FROM joined_dataset
GROUP BY
1, 2, 3, 4;
SELECT * FROM tds;

-- Use an Aggregate step to group by Client, Client ID, Account Manager, and From Date.

CREATE TEMPORARY TABLE 	amd AS
SELECT
	client,
	Client_ID,
	Account_Manager,
	From_Date,
	count(*) AS records
FROM joined_dataset
GROUP BY
1, 2, 3, 4;
SELECT * FROM amd;

-- Next, use a further Summarize step to group by Client and get the Max From_Date.

CREATE TEMPORARY TABLE 	recent AS
SELECT
	client,
	max(From_Date) AS recent_date
FROM amd
GROUP BY 1;
SELECT * FROM recent;

-- Finally, use a Join step to join the results of these two Aggregates together on Client = Client and From Date = From Date. 
-- This gives us a nice, clean, up-to-date list of the current Account Managers and Client IDs for each Client.

CREATE TEMPORARY TABLE 	rmds AS
SELECT
	a.client,
	a.client_ID,
	a.account_manager,
	r.recent_date
FROM amd a INNER JOIN recent r
	       ON a.client = r.client AND a.from_date = r.recent_date;
SELECT * FROM rmds;

-- Join back with the trainings dataset
SELECT
	t.training,
	t.Contact_Email,
	t.Contact_Name,
	t.client,
	cm.Client_ID,
	cm.Account_Manager,
	cm.recent_date AS from_date
FROM tds t INNER JOIN rmds cm
           ON t.client = cm.client;

