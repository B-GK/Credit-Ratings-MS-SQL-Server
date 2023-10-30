SELECT *
FROM airport

--1--Look into binary categorical variables

--1-1-List airports based on size
--size_____medium=0   large=1
SELECT DISTINCT airport_name AS name, size
FROM airport
WHERE size  IN ('large', 'Medium')

--Count the number of airports based on size (Medium - Large)
SELECT COUNT(Distinct airport_name) AS name, size
FROM airport
GROUP BY size

--1-2-List the airports based on thier Legacy
--lagacy_____non-legacy=0   legacy=1
SELECT DISTINCT airport_name, size, 
				CASE WHEN legacy=0 THEN 'non-legacy'
					WHEN legacy = 1 THEN 'legacy'
					ELSE 'unkown' END AS legacy_status 
FROM airport

--Count the number of lagacy and non-legacy airports
WITH air_legacy AS
				(SELECT DISTINCT airport_name, size, state, 
				 CASE WHEN legacy=0 THEN 'non-legacy'
				 WHEN legacy = 1 THEN 'legacy'
				 ELSE 'unkown' END AS legacy_status
				 FROM airport) 
SELECT legacy_status, COUNT(*) as count
FROM air_legacy
GROUP BY legacy_status

--1-3-find the 'Use agreement types' of airpots
--Use agreement type(met)______residual=0   compensatory=1   hybrid=2
SELECT DISTINCT airport_name as name, size,legacy, 
				CASE 
				WHEN met = 0 THEN 'residual'
				WHEN met = 1 THEN 'compensatory'
			    WHEN met = 2 THEN 'hybrid'
				ELSE 'unknown' 
				END AS 'type_agreement'
FROM airport

--Count airports by their Use agreement type
WITH use_agree AS 
				(SELECT DISTINCT airport_name as name, size, 
				CASE 
				WHEN met = 0 THEN 'residual'
				WHEN met = 1 THEN 'compensatory'
			    WHEN met = 2 THEN 'hybrid'
				ELSE 'unknown' 
				END AS 'type_agreement'
				FROM airport)
SELECT type_agreement,  COUNT(*) as count
FROM use_agree
GROUP BY type_agreement
ORDER BY type_agreement DESC

--1-4-Show governance of the airports
--governance_______city=0    pa/aa=1   state/county=2
SELECT DISTINCT airport_name as name, state, governance
FROM airport

--count airports for each governance
SELECT COUNT(DISTINCT airport_name) as name, governance
FROM airport
GROUP BY governance

--combine state and county governance 
SELECT COUNT(DISTINCT airport_name) as airport_count,
		CASE 
        WHEN governance = 'state' OR governance = 'county' THEN 'state/county'
        ELSE governance
		END AS governance_group   
FROM airport
GROUP BY CASE 
        WHEN governance = 'state' OR governance = 'county' THEN 'state/county'
        ELSE governance 
		END
       
--1-5-credit ratings of each airport
--fitch ratings______0=high/good    1=highest/very high
SELECT DISTINCT airport_name as name, fitch
FROM airport
WHERE fitch IS NOT NULL

--show the fitch ratings for airports 
WITH fitch_rating AS (
			SELECT DISTINCT airport_name as name, fitch
			FROM airport
			WHERE fitch IS NOT NULL)
SELECT name, 
				CASE
				WHEN fitch = 0 THEN 'high/good'
				WHEN fitch = 1 THEN 'highest/veryhigh'
				ELSE 'unknown'
				END AS ratings
FROM fitch_rating

--Count large and medium size airports with highest/veryhigh and high/good ratings 
WITH fitch_rating AS (
			SELECT DISTINCT airport_name as name, fitch
			FROM airport
			WHERE fitch IS NOT NULL)

SELECT COUNT(DISTINCT airport_name) as count_airport,size,fitch,
				CASE
				WHEN fitch = 1 THEN 'highest/veryhigh'
				WHEN fitch = 0 THEN 'high/good'
				ELSE 'unknown'
				END AS ratings
FROM airport
WHERE fitch IN (0,1)
GROUP BY fitch, size


--list highest/very good rating large and medium size airports 
WITH highest_large AS (SELECT DISTINCT airport_name as name, size, fitch
						FROM airport
						WHERE fitch = 1 AND size IN('Large', 'Medium')),

high_medium AS (SELECT DISTINCT airport_name as name, size, fitch
				 FROM airport
				 WHERE fitch = 1 AND size IN ('Large', 'Medium'))
SELECT name, size, fitch
FROM highest_large
UNION 
SELECT name, size, fitch
FROM high_medium

--list high/good rating large and medium size airports 
WITH highest_large AS (SELECT DISTINCT airport_name as name, size, fitch
						FROM airport
						WHERE fitch = 0 AND size IN('Large', 'Medium')),

high_medium AS (SELECT DISTINCT airport_name as name, size, fitch
				 FROM airport
				 WHERE fitch = 0 AND size IN ('Large', 'Medium'))
SELECT name, size, fitch
FROM highest_large
UNION 
SELECT name, size, fitch
FROM high_medium

--2--Create new variables

--2-1-Operating financial ratio (ofr)
ALTER TABLE airport
ADD ofr FLOAT;

UPDATE airport
SET ofr= ROUND(total_operating_expenses / total_operating_revenue, 3)

--2-2-Net take-down ratio(ntdr)
ALTER TABLE airport
ADD ntdr FLOAT;

UPDATE airport
SET ntdr = ROUND((total_operating_revenue + [total_non-operating_revenue] - total_operating_expenses) 
				/ 
				(total_operating_revenue + [total_non-operating_revenue]), 3);


--2-3-Debt service safety margin(dssm)
ALTER TABLE airport
ADD dssm FLOAT;

UPDATE airport
SET dssm = ROUND(
    ((total_operating_revenue + [total_non-operating_revenue] - total_operating_expenses + [Debt service (excluding coverage)])
    / 
    (total_operating_revenue + [total_non-operating_revenue])), 3);

--2-4-Days cash on hand(dcoh)
ALTER TABLE airport
ADD dcoh FLOAT;

UPDATE airport
SET dcoh = ROUND([Unrestricted Cash and Investments] / (total_operating_expenses / 365),0) 

--2-5-current ratio(cr)
ALTER TABLE airport
ADD cr FLOAT;

UPDATE airport
SET cr = ROUND ((ca / cl), 3)

