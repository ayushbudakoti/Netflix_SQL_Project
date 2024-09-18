DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(10),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);

SELECT 
COUNT(*) AS TOTAL_CONTENT
FROM netflix;

SELECT 
 DISTINCT type
FROM netflix;

--Count the Number of Movies vs TV Shows

SELECT 
    type,
    COUNT(*)
FROM netflix
GROUP BY 1;

--Find the Most Common Rating for Movies and TV Shows
WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;

--List All Movies Released in a Specific Year (e.g., 2020)

SELECT * 
FROM netflix
WHERE release_year = 2020;

--Find the Top 5 Countries with the Most Content on Netflix
SELECT * 
FROM
(
    SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
        COUNT(*) AS total_content
    FROM netflix
    GROUP BY 1
) AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;

--Identify the Longest Movie
SELECT 
    *
FROM netflix
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC;

--Movies realead in the Last 5 Years
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'YYYY') >= CURRENT_DATE - INTERVAL '5 years';

--Find All Movies/TV Shows by Director 'Rajiv Chilaka'
SELECT *
FROM (
    SELECT 
        *,
        UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
    FROM netflix
) AS t
WHERE director_name = 'Rajiv Chilaka';

--List All TV Shows with More Than 5 Seasons
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;

--Count the Number of Content Items in Each Genre
SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY 1;

--Find each year and the average numbers of content release in India on netflix.

SELECT
   EXTRACT(YEAR FROM TO_DATE(REGEXP_REPLACE(date_added, '^[A-Za-z]+, ', ''), 'Month DD, YYYY')) as year,
   COUNT(*) as yearly_content,
   ROUND(
   COUNT(*)::numeric/(SELECT COUNT(*)FROM netflix WHERE country = 'India')::numeric * 100
    ,2)as avg_content_per_year
FROM netflix
WHERE country = 'India'
  AND REGEXP_REPLACE(date_added, '^[A-Za-z]+, ', '') ~ '^[A-Za-z]+ [0-9]{1,2}, [0-9]{4}$'
GROUP BY 1;


-- List all the movies that are documentaries
SELECT * 	FROM netflix
WHERE
   listed_in ILIKE '%documentaries%'

-- FIND ALL CONTENT WITHOUT DIRECTOR

SELECT * FROM netflix
WHERE
   director is NULL

-- FIND HOW MANY MOVIES ACTOR SALMAN KHAN APPEARED IN LAST 10 YEARS

SELECT * 	FROM netflix
WHERE
   casts ILIKE '%Salman Khan%'
   AND
   release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10
   
-- FIND THE 10 ACTORS WHO HAVE APPEARED IN THE HIGHEST NUMBER OF MOVIES PRODUCED IN INDIA

SELECT
UNNEST(STRING_TO_ARRAY(casts, ',')) as actors,
COUNT(*) as total_content
FROM netflix
WHERE country ILIKE '%india'
GROUP BY 1
order by 2 desc
limit 10 

--(Categorize the content based on the presence of the keywords 'kill' and 'violence' in
the description field. Label content containing these keywords as
'Bad' and all other
content as 'Good'. Count how many items fall into each category.)

WITH new_table
AS
(
SELECT
*,
 CASE
 WHEN description ILIKE '%kills%' OR
      description ILIKE '%violence%' THEN 'action_content'
	  ELSE 'other_genre'
END category	  
 FROM netflix
)
SELECT
 category,
 COUNT(*) as total_content
FROM new_table
GROUP BY 1
 


   
















