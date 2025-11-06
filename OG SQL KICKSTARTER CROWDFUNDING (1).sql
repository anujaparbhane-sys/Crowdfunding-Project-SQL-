CREATE DATABASE crowdfunding;
USE crowdfunding;



CREATE TABLE crowdfunding_kickstarter (
    id INT PRIMARY KEY,
    state VARCHAR(50),
    name TEXT,
    country VARCHAR(10),
    creator_id BIGINT,
    location_id FLOAT,
    category_id INT,
    upd_Created_at VARCHAR(50),
    upd_deadline VARCHAR(50),
    upd_updated_at VARCHAR(50),
    upd_state_changed_at VARCHAR(50),
    upd_successful_at VARCHAR(50),
    upd_lanched_at VARCHAR(50),
    goal BIGINT,
    goal_in_usd FLOAT,
    symbol_currency VARCHAR(50),
    pledged FLOAT,
    usd_pledged BIGINT,
    static_usd_rate FLOAT,
    backers_count INT,
    spotlight INT,
    staff_pick INT,
    blurb TEXT,
    currency_trailing_code INT,
    disable_communication INT
);



SELECT 
    id,
    STR_TO_DATE(upd_Created_at, '%d/%m/%Y %H:%i') AS created_date,
    STR_TO_DATE(upd_deadline, '%d/%m/%Y %H:%i') AS deadline_date
FROM crowdfunding_kickstarter;







SET @@cte_max_recursion_depth = 5000;


-- Drop the table if it already exists
DROP TABLE IF EXISTS calendar_table;
-- Create a calendar table for all dates from 2009-01-01 to 2019-12-31
CREATE TABLE calendar_table AS
WITH RECURSIVE all_dates AS (
    SELECT DATE('2009-01-01') AS calendar_date
    UNION ALL
    SELECT DATE_ADD(calendar_date, INTERVAL 1 DAY)
    FROM all_dates
    WHERE calendar_date < '2019-12-31'
)
SELECT
    calendar_date AS created_date,
    YEAR(calendar_date) AS year,
    MONTH(calendar_date) AS monthno,
    MONTHNAME(calendar_date) AS monthfullname,
    CASE 
        WHEN MONTH(calendar_date) <= 3 THEN 'Q1'
        WHEN MONTH(calendar_date) <= 6 THEN 'Q2'
        WHEN MONTH(calendar_date) <= 9 THEN 'Q3'
        ELSE 'Q4'
    END AS quarter,
    DATE_FORMAT(calendar_date, '%Y-%b') AS yearmonth,
    DAYOFWEEK(calendar_date) AS weekdayno,
    DAYNAME(calendar_date) AS weekdayname,
    CASE 
        WHEN MONTH(calendar_date) = 4 THEN 'FM1'
        WHEN MONTH(calendar_date) = 5 THEN 'FM2'
        WHEN MONTH(calendar_date) = 3 THEN 'FM12'
        ELSE NULL
    END AS financialmonth,
    CASE 
        WHEN MONTH(calendar_date) <= 3 THEN 'FQ1'
        WHEN MONTH(calendar_date) <= 6 THEN 'FQ2'
        WHEN MONTH(calendar_date) <= 9 THEN 'FQ3'
        ELSE 'FQ4'
    END AS financialquarter
FROM all_dates
ORDER BY calendar_date;

SHOW TABLES;


-------------------------------------------------------------------------------------------------

LOAD DATA LOCAL INFILE 'D:/Tussh R/crowdfunding.csv'
INTO TABLE crowdfunding_kickstarter
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(id, state, name, country, creator_id, location_id, category_id, upd_Created_at, upd_deadline,
 upd_updated_at, upd_state_changed_at, upd_successful_at, upd_lanched_at, goal, goal_in_usd,
 symbol_currency, pledged, usd_pledged, static_usd_rate, backers_count, spotlight, staff_pick,
 blurb, currency_trailing_code, disable_communication);



SELECT COUNT(*) FROM crowdfunding_kickstarter;


--------------------------------------------------------------------------------------------------------

-- STEP 5
-- Total Projects by Outcome
SELECT state, COUNT(*) AS total_projects
FROM crowdfunding_kickstarter
GROUP BY state;

-- Total Projects by Country
SELECT country, COUNT(*) AS total_projects
FROM crowdfunding_kickstarter
GROUP BY country
ORDER BY total_projects DESC;

-- Total Projects by Category
SELECT category_id, COUNT(*) AS total_projects
FROM crowdfunding_kickstarter
GROUP BY category_id
ORDER BY total_projects DESC;


-----------------------------------------------------------------------------------------------------------


-- STEP 6
-- Total Projects by Year and Month
SELECT 
    YEAR(STR_TO_DATE(upd_Created_at, '%d/%m/%Y %H:%i')) AS year,
    MONTH(STR_TO_DATE(upd_Created_at, '%d/%m/%Y %H:%i')) AS month,
    COUNT(id) AS total_projects
FROM crowdfunding_kickstarter
GROUP BY year, month
ORDER BY year, month;



SELECT 
    SUM(usd_pledged) AS total_amount_raised_usd,
    SUM(backers_count) AS total_backers,
    ROUND(AVG(DATEDIFF(
        STR_TO_DATE(upd_deadline, '%d/%m/%Y %H:%i'),
        STR_TO_DATE(upd_Created_at, '%d/%m/%Y %H:%i')
    )),2) AS avg_days_to_complete
FROM crowdfunding_kickstarter
WHERE LOWER(state) = 'successful';


--------------------------------------------------------------------------------------------------------------


-- STEP 7
-- Top 10 by Backers

SELECT id, name, backers_count
FROM crowdfunding_kickstarter
WHERE LOWER(state)='successful'
ORDER BY backers_count DESC
LIMIT 10;

-- Top 10 by Amount Raised
SELECT id, name, usd_pledged
FROM crowdfunding_kickstarter
WHERE LOWER(state)='successful'
ORDER BY usd_pledged DESC
LIMIT 10;


-------------------------------------------------------------------------------------------------------------------


-- STEP 8           
-- Overall Success Rate

SELECT ROUND(
    (SUM(CASE WHEN LOWER(state)='successful' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2
) AS success_percentage
FROM crowdfunding_kickstarter;

-- By Category
SELECT category_id,
    ROUND((SUM(CASE WHEN LOWER(state)='successful' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS success_percentage
FROM crowdfunding_kickstarter
GROUP BY category_id
ORDER BY success_percentage DESC;

-- By Goal Range
SELECT 
    CASE 
        WHEN goal_in_usd < 1000 THEN '<1K USD'
        WHEN goal_in_usd BETWEEN 1000 AND 4999 THEN '1K–5K USD'
        WHEN goal_in_usd BETWEEN 5000 AND 9999 THEN '5K–10K USD'
        ELSE '>10K USD'
    END AS goal_range,
    ROUND(
        (SUM(CASE WHEN LOWER(state)='successful' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2
    ) AS success_percentage
FROM crowdfunding_kickstarter
GROUP BY goal_range
ORDER BY goal_range;


