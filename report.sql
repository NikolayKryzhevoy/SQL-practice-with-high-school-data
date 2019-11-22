/*
Objective

An advice is needed by a team of policymakers seeking to make more informed 
decisions on education. It is necessary to understand how external factors 
influence performance in state assessment exams for public high school students.
https://docs.google.com/spreadsheets/d/1EyKaewf2Oyhh_Qfmn_csZxxC1ypkb5oPsqMFfJTlndE/edit#gid=274575715
https://docs.google.com/spreadsheets/d/1NAgjKKhdGrvwwlc0aoH4JvjrScsytst0g_cVCsdX0Jk/edit#gid=1774413306
*/

-- How many public high schools are in each zip code? in each state?
SELECT zip_code, city, COUNT(DISTINCT school_id) as 'Schools'
FROM public_hs_data
GROUP BY 1
ORDER BY 3 DESC;
-- The number of public school per zip-code varies from 1 to 11
-- New York (zip_code 10002) has 11 schools, Long Island City (zip_code 11101) has 10

SELECT state_code, COUNT(DISTINCT school_id) as 'Schools'
FROM public_hs_data
GROUP BY 1
ORDER BY 2 DESC;
-- There are 1294 high schools in CA, 1199 in TX .... 6 in GU, 4 in VI

-- Deciphering the locale_code
SELECT school_id, city, state_code, locale_code,
	CASE
		WHEN substr(locale_code,1,1) = '1' THEN 'City'
		WHEN substr(locale_code,1,1) = '2' THEN 'Suburb'
		WHEN substr(locale_code,1,1) = '3' THEN 'Town'
		WHEN substr(locale_code,1,1) = '4' THEN 'Rural'
		ELSE 'XZ'
	END AS 'locale_text',
	CASE
		WHEN substr(locale_code,2,1) = '1' AND CAST(substr(locale_code,1,1) as INTEGER) <= 2 THEN 'Large'
		WHEN substr(locale_code,2,1) = '2' AND CAST(substr(locale_code,1,1) as INTEGER) <= 2 THEN 'Midsize'
		WHEN substr(locale_code,2,1) = '3' AND CAST(substr(locale_code,1,1) as INTEGER) <= 2 THEN 'Small'
		WHEN substr(locale_code,2,1) = '1' AND CAST(substr(locale_code,1,1) as INTEGER) > 2 THEN 'Fringe'
		WHEN substr(locale_code,2,1) = '2' AND CAST(substr(locale_code,1,1) as INTEGER) > 2 THEN 'Distant'
		WHEN substr(locale_code,2,1) = '3' AND CAST(substr(locale_code,1,1) as INTEGER) > 2 THEN 'Remote'
		ELSE 'XZ'
	END AS 'locale_size'
FROM public_hs_data
LIMIT 100;

-- Do various levels of urbanization influence students' performance in high school?
WITH tmp
AS	(
	SELECT school_id, city, state_code, pct_proficient_math, pct_proficient_reading, locale_code,
		CASE
			WHEN substr(locale_code,1,1) = '1' THEN 'City'
			WHEN substr(locale_code,1,1) = '2' THEN 'Suburb'
			WHEN substr(locale_code,1,1) = '3' THEN 'Town'
			WHEN substr(locale_code,1,1) = '4' THEN 'Rural'
			ELSE 'XZ'
		END AS 'locale_text',
		CASE
			WHEN substr(locale_code,2,1) = '1' AND CAST(substr(locale_code,1,1) as INTEGER) <= 2 THEN 'Large'
			WHEN substr(locale_code,2,1) = '2' AND CAST(substr(locale_code,1,1) as INTEGER) <= 2 THEN 'Midsize'
			WHEN substr(locale_code,2,1) = '3' AND CAST(substr(locale_code,1,1) as INTEGER) <= 2 THEN 'Small'
			WHEN substr(locale_code,2,1) = '1' AND CAST(substr(locale_code,1,1) as INTEGER) > 2 THEN 'Fringe'
			WHEN substr(locale_code,2,1) = '2' AND CAST(substr(locale_code,1,1) as INTEGER) > 2 THEN 'Distant'
			WHEN substr(locale_code,2,1) = '3' AND CAST(substr(locale_code,1,1) as INTEGER) > 2 THEN 'Remote'
			ELSE 'XZ'
		END AS 'locale_size'
	FROM public_hs_data
	)
SELECT locale_text as 'Urbanization Level', AVG(pct_proficient_math), AVG(pct_proficient_reading)
FROM tmp
GROUP BY 1
HAVING 1 IS NOT 'XZ' AND locale_size IS NOT 'XZ';
-- As seen from figure 'Score_vs_Urbanization.png' students in Suburbs and Rurals
-- are more proficient in both math and reading than students in Cities and Towns 

-- Does city size influence students' performance in high school?
WITH tmp
AS	(
	SELECT school_id, city, state_code, pct_proficient_math, pct_proficient_reading, locale_code,
		CASE
			WHEN substr(locale_code,1,1) = '1' THEN 'City'
			WHEN substr(locale_code,1,1) = '2' THEN 'Suburb'
			WHEN substr(locale_code,1,1) = '3' THEN 'Town'
			WHEN substr(locale_code,1,1) = '4' THEN 'Rural'
			ELSE 'XZ'
		END AS 'locale_text',
		CASE
			WHEN substr(locale_code,2,1) = '1' AND CAST(substr(locale_code,1,1) as INTEGER) <= 2 THEN 'Large'
			WHEN substr(locale_code,2,1) = '2' AND CAST(substr(locale_code,1,1) as INTEGER) <= 2 THEN 'Midsize'
			WHEN substr(locale_code,2,1) = '3' AND CAST(substr(locale_code,1,1) as INTEGER) <= 2 THEN 'Small'
			WHEN substr(locale_code,2,1) = '1' AND CAST(substr(locale_code,1,1) as INTEGER) > 2 THEN 'Fringe'
			WHEN substr(locale_code,2,1) = '2' AND CAST(substr(locale_code,1,1) as INTEGER) > 2 THEN 'Distant'
			WHEN substr(locale_code,2,1) = '3' AND CAST(substr(locale_code,1,1) as INTEGER) > 2 THEN 'Remote'
			ELSE 'XZ'
		END AS 'locale_size'
	FROM public_hs_data
	)
SELECT locale_size as 'City Size', AVG(pct_proficient_math), AVG(pct_proficient_reading)
FROM tmp
WHERE locale_text = 'City'
GROUP BY 1
HAVING locale_text IS NOT 'XZ' AND locale_size IS NOT 'XZ';
-- Students in midsize cities are on average less proficient than those in large and small cities (figure 'Income_vs_CitySize.png')


-- What is the minimum, maximum, and average median_household_income of the nation? for each state?
SELECT zip_code, state_code, pop_total, MIN(median_household_income)
FROM census_data
WHERE median_household_income IS NOT 'NULL';
-- the minimum median_household_income is $2499 (Agawan, MA)

SELECT zip_code, state_code, pop_total, MAX(median_household_income)
FROM census_data
WHERE median_household_income IS NOT 'NULL';
-- the maximum median_household_income is $250,001 (Short Hills, NJ)

SELECT AVG(median_household_income)
FROM census_data
WHERE median_household_income IS NOT 'NULL';
-- the average median_household_income of USA is $54,683 

SELECT state_code, MIN(median_household_income), MAX(median_household_income), AVG(median_household_income) 
FROM census_data
WHERE median_household_income IS NOT 'NULL'
GROUP BY 1
ORDER BY 4 DESC;
-- The four richest states with more than $80K median_houshold_income are NJ, CT, MD and DC
-- PR is the poorest with  $19,599 median_houshold_income

-- Do characteristics of the zip-code area, such as median household income, influence students' performance in high school?
SELECT 
	CASE 
		WHEN median_household_income < 50000 THEN 'Low '
		WHEN median_household_income > 100000 THEN 'High'
		ELSE 'Medium'
	END as 'Income', AVG(pct_proficient_math) as 'Mean_Score_Math', AVG(pct_proficient_reading) as 'Mean_Score_Reading'
FROM public_hs_data
JOIN census_data ON census_data.zip_code = public_hs_data.zip_code
WHERE (median_household_income IS NOT 'NULL') AND (pct_proficient_math IS NOT 'NULL') AND (pct_proficient_reading IS NOT 'NULL')
GROUP BY 1
ORDER BY 2 DESC;
/* The income was separated into three groups (<$50k, $50k-$100k, $100k+) and for each group 
the mean score in math and reading was found. As seen from figure 'Score_vs_Income.png'
the scores of both math and reading exams decrease with income
*/

-- On average, do students perform better on the math or reading exam? 
SELECT AVG(pct_proficient_math), AVG(pct_proficient_reading)
FROM public_hs_data
WHERE (pct_proficient_math IS NOT 'NULL') AND (pct_proficient_reading IS NOT 'NULL'); 
-- 48.85(math) vs 60.34(reading)

-- Find the number of states where students do better on the math exam, and vice versa.
WITH tmp
AS	(
	SELECT state_code, AVG(pct_proficient_math), AVG(pct_proficient_reading), 
	CASE 
		WHEN AVG(pct_proficient_math) > AVG(pct_proficient_reading) THEN 'M'
		ELSE 'R'
	END AS 'M_vs_R'
	FROM public_hs_data
	WHERE (pct_proficient_math IS NOT 'NULL') AND (pct_proficient_reading IS NOT 'NULL')
	GROUP BY 1
	)
SELECT M_vs_R, COUNT(*)
FROM tmp
GROUP BY M_vs_R;
-- Of 52 states with the scores available, 45 do better on the reading exam and 7 do better on math.


-- Average proficiency on the math exam for each state
SELECT state_code, AVG(pct_proficient_math) as 'State_avg_math' 
FROM public_hs_data
WHERE pct_proficient_math IS NOT 'NULL'
GROUP BY 1
ORDER BY 2 DESC;
-- NY 91, MD 85, IA 85, .... PR 7.7

-- Proficiency on the math exam of each school relative to the averaged value in a given state
WITH tmp
AS	(
	SELECT state_code, AVG(pct_proficient_math) as 'State_avg_math' 
	FROM public_hs_data
	WHERE pct_proficient_math IS NOT 'NULL'
	GROUP BY 1
	)
SELECT school_id, school_name, city, tmp.state_code, zip_code, pct_proficient_math, pct_proficient_math - State_avg_math as 'Diff'
FROM public_hs_data
JOIN tmp ON public_hs_data.state_code = tmp.state_code
WHERE pct_proficient_math IS NOT 'NULL' AND public_hs_data.state_code = 'CA';

WITH tmp
AS	(
	SELECT state_code, AVG(pct_proficient_math) as 'State_avg_math' 
	FROM public_hs_data
	WHERE pct_proficient_math IS NOT 'NULL'
	GROUP BY 1
	)
SELECT zip_code, AVG(pct_proficient_math) as Zip_avg_math, State_avg_math, AVG(pct_proficient_math) - State_avg_math as '[mean(zip)-mean(state)](PR,math)'
FROM public_hs_data
JOIN tmp ON public_hs_data.state_code = tmp.state_code
WHERE pct_proficient_math IS NOT 'NULL' AND public_hs_data.state_code = 'PR'
GROUP BY zip_code;

/*
What is the average proficiency on state assessment exams for each zip code, and how do 
they compare to other zip codes in the same state?
*/
-- Let's consider the math exam
-- The average proficiency for each state can be found from the following query
SELECT state_code, AVG(pct_proficient_math) as 'State_avg_math' 
FROM public_hs_data
WHERE pct_proficient_math IS NOT 'NULL'
GROUP BY 1
ORDER BY 2 DESC;
-- NY 91, MD 85, IA 85, .... PR 7.7

-- Proficiency on the math exam of each school relative to the averaged value in a given state (CA as an example)
WITH tmp
AS	(
	SELECT state_code, AVG(pct_proficient_math) as 'State_avg_math' 
	FROM public_hs_data
	WHERE pct_proficient_math IS NOT 'NULL'
	GROUP BY 1
	)
SELECT school_id, school_name, city, tmp.state_code, zip_code, pct_proficient_math, pct_proficient_math - State_avg_math as 'Diff'
FROM public_hs_data
JOIN tmp ON public_hs_data.state_code = tmp.state_code
WHERE pct_proficient_math IS NOT 'NULL' AND public_hs_data.state_code = 'CA';

-- Proficiency on the math exam of each zip_code relative to the averaged value in a given state (PR as an example)
WITH tmp
AS	(
	SELECT state_code, AVG(pct_proficient_math) as 'State_avg_math' 
	FROM public_hs_data
	WHERE pct_proficient_math IS NOT 'NULL'
	GROUP BY 1
	)
SELECT zip_code, AVG(pct_proficient_math) as Zip_avg_math, State_avg_math, AVG(pct_proficient_math) - State_avg_math as '[mean(zip)-mean(state)](PR,math)'
FROM public_hs_data
JOIN tmp ON public_hs_data.state_code = tmp.state_code
WHERE pct_proficient_math IS NOT 'NULL' AND public_hs_data.state_code = 'PR'
GROUP BY zip_code;
-- see figures 'MeanZIP_PR.png' and 'MeanZIP_CA.png' for more detail
