USE indian_crimes_state_wise;


-- 1. Year with highest number cases reported of Dacoity Robbery, Burglary and Theft 

SELECT
	 [STATE/UT]
	,[YEAR]
	,MAX([Dacoity (Section 395-398 IPC) - Number of cases registered]) AS [Dacoity (Section 395-398 IPC) - Number of cases registered]
	,MAX([Robbery(Section 392-394, 397, 398 IPC) - Number of cases registered]) AS [Robbery(Section 392-394, 397, 398 IPC) - Number of cases registered]
	,MAX([Burglary(Section 449-452, 454, 455, 457-460 IPC) - Number of cases registered]) AS [Burglary(Section 449-452, 454, 455, 457-460 IPC) - Number of cases registered]
	,MAX([Theft (Section 379-382 IPC) - Number of cases registered]) AS [Theft (Section 379-382 IPC) - Number of cases registered]
FROM Case_reported_and_value_of_property_taken_away
GROUP BY [YEAR], [STATE/UT]
ORDER BY [STATE/UT], [YEAR]




-- 2. Year with highest number of property stolen in Dacoity Robbery, Burglary and Theft

SELECT
	 [STATE/UT]
	,[YEAR]
	,MAX([Dacoity (Section 395-398 IPC) - Value Of Property Stolen (in rupees)]) AS [Dacoity (Section 395-398 IPC) - Value Of Property Stolen (in rupees)]
	,MAX([Robbery(Section 392-394, 397, 398 IPC) - Value Of Property Stolen (in rupees)]) AS [Robbery(Section 392-394, 397, 398 IPC) - Value Of Property Stolen (in rupees)]
	,MAX([Burglary(Section 449-452, 454, 455, 457-460 IPC) - Value Of Property Stolen (in rupees)]) AS [Burglary(Section 449-452, 454, 455, 457-460 IPC) - Value Of Property Stolen (in rupees)]
	,MAX([Theft (Section 379-382 IPC) - Value Of Property Stolen (in rupees)]) AS [Theft (Section 379-382 IPC) - Value Of Property Stolen (in rupees)]
FROM Case_reported_and_value_of_property_taken_away
GROUP BY [YEAR], [STATE/UT]
ORDER BY [STATE/UT], [YEAR];



-- 3. Most crime reported each state each year

WITH A
AS
	(SELECT 
		   [STATE/UT]
		  ,YEAR
		  ,crime_type
		  ,case_reported
	FROM Case_reported_and_value_of_property_taken_away
	UNPIVOT (
			  case_reported FOR crime_type 
			  IN ([Dacoity (Section 395-398 IPC) - Number of cases registered]
				 ,[Robbery(Section 392-394, 397, 398 IPC) - Number of cases registered]
				 ,[Burglary(Section 449-452, 454, 455, 457-460 IPC) - Number of cases registered]
				 ,[Theft (Section 379-382 IPC) - Number of cases registered]) 
		) AS [UNPIVOT TABLE]),

B AS
	(SELECT
		 [STATE/UT]
		,YEAR
		,crime_type
		,FIRST_VALUE(CONCAT('crime: ',SUBSTRING(crime_type, 1, CHARINDEX(')', crime_type)), '   ', 'cases reported: ', case_reported)) OVER(PARTITION BY [YEAR], [STATE/UT] ORDER BY case_reported DESC ) AS highest_crime_and_number_of_case_reported
	FROM A)

SELECT
	 [STATE/UT]
	,YEAR
	,highest_crime_and_number_of_case_reported
FROM B
GROUP BY [YEAR], [STATE/UT], highest_crime_and_number_of_case_reported;


-- 4. Running total of crimes reported 

WITH A
AS
	(SELECT
		 [STATE/UT]
		,YEAR
		,SUM([Dacoity (Section 395-398 IPC) - Number of cases registered]
		+[Theft (Section 379-382 IPC) - Number of cases registered]
		+[Burglary(Section 449-452, 454, 455, 457-460 IPC) - Number of cases registered]
		+[Robbery(Section 392-394, 397, 398 IPC) - Number of cases registered]) AS total_cases_reported_of_property_stolen
	FROM Case_reported_and_value_of_property_taken_away
	GROUP BY [STATE/UT], YEAR)

SELECT
	 [STATE/UT]
	,YEAR
	,SUM(total_cases_reported_of_property_stolen) OVER(PARTITION BY [STATE/UT] ORDER BY YEAR ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total_cases_reported_of_property_stolen
FROM A;



-- 5. Safest state to live in India

WITH A
AS
	(SELECT
		 [STATE/UT]
		,YEAR
		,SUM([Dacoity (Section 395-398 IPC) - Number of cases registered]
		+[Theft (Section 379-382 IPC) - Number of cases registered]
		+[Burglary(Section 449-452, 454, 455, 457-460 IPC) - Number of cases registered]
		+[Robbery(Section 392-394, 397, 398 IPC) - Number of cases registered]) AS total_cases_reported_of_property_stolen
	FROM Case_reported_and_value_of_property_taken_away
	GROUP BY [STATE/UT], YEAR)

SELECT
	 YEAR
	,[STATE/UT]
	,total_cases_reported_of_property_stolen
	,FIRST_VALUE(CONCAT('STATE: ',[STATE/UT], ' ', 'CASES RIGISTRED: ', total_cases_reported_of_property_stolen)) OVER( PARTITION BY YEAR ORDER BY total_cases_reported_of_property_stolen ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS safest_state_in_current_year
FROM A
ORDER BY YEAR, [STATE/UT];


-- 6. Most unsafe state to live in India

WITH A
AS
	(SELECT
		 [STATE/UT]
		,YEAR
		,SUM([Dacoity (Section 395-398 IPC) - Number of cases registered]
		+[Theft (Section 379-382 IPC) - Number of cases registered]
		+[Burglary(Section 449-452, 454, 455, 457-460 IPC) - Number of cases registered]
		+[Robbery(Section 392-394, 397, 398 IPC) - Number of cases registered]) AS total_cases_reported_of_property_stolen
	FROM Case_reported_and_value_of_property_taken_away
	GROUP BY [STATE/UT], YEAR)

SELECT
	 YEAR
	,[STATE/UT]
	,total_cases_reported_of_property_stolen
	,LAST_VALUE(CONCAT('STATE: ',[STATE/UT], ' ', 'CASES RIGISTRED: ', total_cases_reported_of_property_stolen)) OVER( PARTITION BY YEAR ORDER BY total_cases_reported_of_property_stolen ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS most_unsafe_state_in_current_year
FROM A
ORDER BY YEAR, [STATE/UT];


-- 7. state with most value of property stolen 

WITH A
AS
	(SELECT
		 [STATE/UT]
		,YEAR
		,SUM([Dacoity (Section 395-398 IPC) - Value Of Property Stolen (in rupees)]
		+[Theft (Section 379-382 IPC) - Value Of Property Stolen (in rupees)]
		+[Burglary(Section 449-452, 454, 455, 457-460 IPC) - Value Of Property Stolen (in rupees)]
		+[Robbery(Section 392-394, 397, 398 IPC) - Value Of Property Stolen (in rupees)]) AS total_cases_reported_of_property_stolen
	FROM Case_reported_and_value_of_property_taken_away
	GROUP BY [STATE/UT], YEAR)

SELECT
	 YEAR
	,[STATE/UT]
	,total_cases_reported_of_property_stolen
	,DENSE_RANK() OVER( PARTITION BY YEAR ORDER BY total_cases_reported_of_property_stolen DESC) AS state_with_most_value_of_property_stolen_in_current_year
FROM A;


-- 8. state with least value of property stolen 

WITH A
AS
	(SELECT
		 [STATE/UT]
		,YEAR
		,SUM([Dacoity (Section 395-398 IPC) - Value Of Property Stolen (in rupees)]
		+[Theft (Section 379-382 IPC) - Value Of Property Stolen (in rupees)]
		+[Burglary(Section 449-452, 454, 455, 457-460 IPC) - Value Of Property Stolen (in rupees)]
		+[Robbery(Section 392-394, 397, 398 IPC) - Value Of Property Stolen (in rupees)]) AS total_cases_reported_of_property_stolen
	FROM Case_reported_and_value_of_property_taken_away
	GROUP BY [STATE/UT], YEAR)

SELECT
	 YEAR
	,[STATE/UT]
	,total_cases_reported_of_property_stolen
	,DENSE_RANK() OVER( PARTITION BY YEAR ORDER BY total_cases_reported_of_property_stolen) AS state_with_least_value_of_property_stolen_in_current_year
FROM A;


-- 9 Most and least safe place for theft per year

CREATE OR ALTER PROCEDURE pr_most_and_least_safe_places @p_crime VARCHAR(50)
AS

BEGIN
	WITH A
	AS
		(SELECT
			 [STATE/UT]
			,YEAR
			,[place of occurance]
			,[Case_reported]
		FROM crime_by_place_of_occurance
		UNPIVOT(
				[Case_reported] FOR [place of occurance]
			IN(
				[RESIDENTIAL PREMISES - Dacoity]
			   ,[RESIDENTIAL PREMISES - Robbery]
			   ,[RESIDENTIAL PREMISES - Burglary]
			   ,[RESIDENTIAL PREMISES - Theft]
			   ,[HIGHWAYS - Dacoity]
			   ,[HIGHWAYS - Robbery]
			   ,[HIGHWAYS - Burglary]
			   ,[HIGHWAYS - Theft]
			   ,[RIVER and SEA - Dacoity]
			   ,[RIVER and SEA - Robbery]
			   ,[RIVER and SEA - Burglary]
			   ,[RIVER and SEA - Theft]
			   ,[RAILWAYS - Dacoity]
			   ,[RAILWAYS - Robbery]
			   ,[RAILWAYS - Burglary]
			   ,[RAILWAYS - Theft]
			   ,[BANKS - Dacoity]
			   ,[BANKS - Robbery]
			   ,[BANKS - Burglary]
			   ,[BANKS - Theft]
			   ,[COMMERCIAL ESTABLISHMENTS - Dacoity]
			   ,[COMMERCIAL ESTABLISHMENTS - Robbery]
			   ,[COMMERCIAL ESTABLISHMENTS - Burglary]
			   ,[COMMERCIAL ESTABLISHMENTS - Theft]
			   ,[OTHER PLACES - Dacoity]
			   ,[OTHER PLACES - Robbery]
			   ,[OTHER PLACES - Burglary]
			   ,[OTHER PLACES - Theft]
	
			)

		) AS unpiviot_table)
	
	SELECT
		 [STATE/UT]
		,YEAR
		,LAST_VALUE([place of occurance]) OVER(PARTITION BY [STATE/UT], YEAR ORDER BY [Case_reported] ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS most_theft
		,FIRST_VALUE([place of occurance]) OVER(PARTITION BY [STATE/UT], YEAR ORDER BY [Case_reported] ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS least_theft
	FROM A
	WHERE [place of occurance] LIKE '%' + @p_crime + '%';
END;

EXEC pr_most_and_least_safe_places @p_crime = 'Robbery';


-- 10. dynamic query


CREATE OR ALTER PROCEDURE pr_x @state NVARCHAR(MAX), @year NVARCHAR(MAX), @column NVARCHAR(MAX)
AS

BEGIN
	DECLARE @query NVARCHAR(MAX)

	SET @query = N'
		SELECT
		   [STATE/UT]
		  ,[YEAR]
		  ,SUM(['+@column+']) AS case_reported
	  FROM crime_by_place_of_occurance
	  WHERE [STATE/UT] LIKE ''%'+@state+'%'' AND YEAR = '+@year+'
	  GROUP BY [STATE/UT], YEAR;';

	  EXEC sp_executesql @query;
END;


EXEC pr_x @state = 'chandigarh', @year = '2004', @column = 'RESIDENTIAL PREMISES - Theft';