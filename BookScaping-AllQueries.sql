/* 1. Check Availability of eBooks vs Physical Books */
WITH CTE
AS (
	SELECT ISEBOOK
		,COUNT(*) AS AVAILABLITY
	FROM BOOKS
	GROUP BY ISEBOOK
	)
SELECT CASE 
		WHEN ISEBOOK = 0
			THEN 'Physical Paperback'
		ELSE 'EBook'
		END AS ISEBOOK
	,AVAILABLITY
FROM CTE;

/* 2. Find the Publisher with the Most Books Published*/
SELECT publisher
	,COUNT(*) AS book_count
FROM books
WHERE publisher <> 'NA'
GROUP BY publisher
ORDER BY book_count DESC LIMIT 1;

/* 3. Identify the Publisher with the Highest Average Rating*/
SELECT publisher
	,AVG(averageRating) AS avg_rating
FROM books
WHERE publisher <> 'NA'
GROUP BY publisher
ORDER BY avg_rating DESC LIMIT 1;

/* 4. Get the Top 5 Most Expensive Books by Retail Price*/
SELECT book_title
	,amount_retailPrice
	,currencyCode_retailPrice
FROM books
ORDER BY amount_retailPrice DESC LIMIT 5;

/* 5. Find Books Published After 2010 with at Least 500 Pages*/
SELECT book_title
	,year
	,pageCount
FROM books
WHERE year > 2010
	AND pageCount >= 500
ORDER BY 2;

/* 6. List Books with Discounts Greater than 20%*/
SELECT book_title
	,amount_listPrice
	,amount_retailPrice
	,ROUND(((amount_listPrice - amount_retailPrice) / amount_listPrice) * 100, 2) AS discount_percentage
FROM books
WHERE amount_listPrice > 0
	AND amount_retailPrice > 0
	AND ((amount_listPrice - amount_retailPrice) / amount_listPrice) * 100 > 20;

/* 7. Find the Average Page Count for eBooks vs Physical Books*/
WITH CTE
AS (
	SELECT isEbook
		,ROUND(AVG(pageCount), 2) AS avg_page_count
	FROM books
	GROUP BY isEbook
	)
SELECT CASE 
		WHEN ISEBOOK = 0
			THEN 'Physical Paperback'
		ELSE 'EBook'
		END AS ISEBOOK
	,avg_page_count
FROM CTE;

/* 8. Find the Top 3 Authors with the Most Books*/
SELECT book_authors
	,COUNT(*) AS book_count
FROM books
WHERE book_authors <> ''
GROUP BY book_authors
ORDER BY book_count DESC LIMIT 3;

/* 9. List Publishers with More than 10 Books*/
SELECT publisher
	,COUNT(*) AS book_count
FROM books
WHERE publisher <> 'NA'
GROUP BY publisher
HAVING COUNT(*) > 10;

/* 10. Find the Average Page Count for Each Category*/
SELECT categories
	,ROUND(AVG(pageCount), 2) AS avg_page_count
FROM books
WHERE categories <> ''
GROUP BY categories;

/* 11. Retrieve Books with More than 3 Authors*/
SELECT book_title
	,book_authors
FROM books
WHERE LENGTH(book_authors) - LENGTH(REPLACE(book_authors, ',', '')) >= 3;

/* 12. Books with Ratings Count Greater Than the Average*/
SELECT book_title
	,ratingsCount
FROM books
WHERE ratingsCount > (
		SELECT AVG(ratingsCount)
		FROM books
		);

/* 13. Books with the Same Author Published in the Same Year*/
SELECT book_authors
	,Year(year)
	,COUNT(*) AS book_count
FROM books
WHERE book_authors <> ''
GROUP BY book_authors
	,Year(year)
HAVING COUNT(*) > 1;

/* 14. Books with a Specific Keyword in the Title*/
SELECT book_title
FROM books
WHERE book_title LIKE '%python%';

/* 15. Year with the Highest Average Book Price*/
SELECT year
	,AVG(amount_retailPrice) AS avg_price
FROM books
GROUP BY year
ORDER BY avg_price DESC LIMIT 1;

/* 16. Count Authors Who Published 3 Consecutive Years*/
WITH SplitAuthors
AS (
	SELECT book_id
		,TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(book_authors, ',', n.n), ',', - 1)) AS author
		,YEAR(year) AS year
	FROM books
	CROSS JOIN (
		SELECT 1 AS n	
		UNION ALL		
		SELECT 2		
		UNION ALL		
		SELECT 3		
		UNION ALL		
		SELECT 4		
		UNION ALL		
		SELECT 5		
		UNION ALL		
		SELECT 6		
		UNION ALL
		SELECT 7		
		UNION ALL		
		SELECT 8		
		UNION ALL		
		SELECT 9		
		UNION ALL		
		SELECT 10
		) n
	WHERE n.n <= 1 + LENGTH(book_authors) - LENGTH(REPLACE(book_authors, ',', ''))
		AND book_authors <> ''
	)
	,RankedYears
AS (
	SELECT author
		,year
		,ROW_NUMBER() OVER (
			PARTITION BY author ORDER BY year
			) AS year_rank
	FROM SplitAuthors
	)
	,ConsecutiveYears
AS (
	SELECT author
		,year
		,year - year_rank AS year_group
	FROM RankedYears
	)
SELECT author
	,COUNT(DISTINCT year) AS consecutive_years
FROM ConsecutiveYears
GROUP BY author
	,year_group
HAVING consecutive_years >= 3;

/* 17. Find Authors with Books Published in the Same Year Under Different Publishers*/
SELECT book_authors
	,year
	,COUNT(DISTINCT publisher) AS publisher_count
FROM books
WHERE book_authors <> ''
GROUP BY book_authors
	,year
HAVING publisher_count > 1;

/* 18. Average Retail Price of eBooks and Physical Books*/
SELECT round(AVG(CASE 
				WHEN isEbook = 0
					THEN amount_retailPrice
				ELSE NULL
				END), 2) AS avg_ebook_price
	,round(AVG(CASE 
				WHEN isEbook = 1
					THEN amount_retailPrice
				ELSE NULL
				END), 2) AS avg_physical_price
FROM books;

/* 19. Write a SQL query to identify books that have an averageRating that is more than two standard deviations away from the average rating of all books. Return the title, averageRating, and ratingsCount for these outliers.*/
WITH rating_stats
AS (
	SELECT AVG(averageRating) AS avg_rating
		,STDDEV(averageRating) AS std_dev
	FROM books
	)
SELECT book_title
	,averageRating
	,ratingsCount
FROM books
	,rating_stats
WHERE averageRating > (avg_rating + 2 * std_dev)
	OR averageRating < (avg_rating - 2 * std_dev);

/* 20. Publisher with the Highest Average Rating (More Than 10 Books)*/
SELECT publisher
	,ROUND(AVG(averageRating)) AS avg_rating
	,COUNT(*) AS book_count
FROM books
GROUP BY publisher
HAVING COUNT(*) > 10
ORDER BY avg_rating DESC LIMIT 1;