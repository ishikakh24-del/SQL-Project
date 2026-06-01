--EASY Question Set


--Q1: Who is senior most employee based on job title?

SELECT 
first_name,
last_name,
title
FROM employee
ORDER BY levels DESC
LIMIT 1;

--Q2: Which countries have the most invoices?

SELECT 
billing_country, 
COUNT(invoice_id) AS total
FROM invoice
GROUP BY billing_country
ORDER BY total DESC;

--Q3: What are the top 3 values of total invoice?

SELECT 
total 
FROM invoice
ORDER BY total DESC
LIMIT 3;

-- Q4: Which city has best customers? We would like to throw a promotional Music festival in the city we made
-- the most money. Write a query that returns one city that has the highest sum of invoice totals.
-- Return both the city name & sum of all invoice totals

SELECT 
billing_city,
SUM(total) as total_invoice
FROM invoice
GROUP BY billing_city
ORDER BY total_invoice DESC
LIMIT 1;

--Q5: Who is the best customer with highest spent money? 

SELECT 
c.customer_id,
c.first_name,
c.last_name,
SUM(i.total) as total_spent
FROM customer AS c
INNER JOIN invoice AS i
ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 1;




--MODERATE



--Q1: Write query to return the email, first name, last name & genre of all rock music listeners.
--Return list ordered alphabetically by email starting with A.

SELECT DISTINCT c.first_name,
c.last_name,
c.email,
g.name 
FROM customer AS c
JOIN invoice AS i ON i.customer_id = c.customer_id
JOIN invoice_line AS il ON il.invoice_id = i.invoice_id
JOIN track AS t ON t.track_id = il.track_id
JOIN genre AS g ON g.genre_id = t.genre_id
WHERE g.name = 'Rock'
ORDER BY email;



-- Q2: Let's invite the artist who have written most rock music in our dataset. Write a query that returns artist name
-- and total track count of top 10 rock bands

SELECT 
a.name,
COUNT(DISTINCT track_id) as total_track_count
FROM artist AS a
JOIN album AS al ON a.artist_id = al.artist_id
JOIN track AS t ON al.album_id = t.album_id
JOIN genre AS g ON g.genre_id = t.genre_id
WHERE g.name = 'Rock'
GROUP BY a.name
ORDER BY total_track_count desc
LIMIT 10;


--  Q3: Return all the track names that have a song length longer than the average song length. Return the name and milli-
-- seconds for each track. Order by the song length with the longest songs listed first.

SELECT 
	name, 
	milliseconds
FROM track 
WHERE milliseconds >
( SELECT AVG(milliseconds) AS avg_track_length
 FROM track)
ORDER BY milliseconds DESC;



-- ADVANCE



--  Q1: Find how much amount spent by each customer on best selling artist? Write a query to return customer name, artist name
-- and total spend.
WITH best_selling_artist AS (
	SELECT 
	    a.artist_id,
		a.name,
		SUM(il.unit_price * il.quantity) AS total_sales
		FROM invoice_line AS il 
		JOIN track AS t ON t.unit_price = il.unit_price
		JOIN album AS al ON al.album_id = t.album_id
		JOIN artist AS a ON al.artist_id = a.artist_id
	GROUP BY a.artist_id,a.name
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT
c.first_name,
c.last_name,
SUM(il.unit_price * il.quantity) AS total_spent,
bsa.name
FROM customer AS c
JOIN invoice AS i ON c.customer_id = i.customer_id
JOIN invoice_line AS il ON i.invoice_id = il.invoice_id
JOIN track AS t ON t.unit_price = il.unit_price
JOIN album AS al ON al.album_id = t.album_id
JOIN best_selling_artist AS bsa ON al.artist_id = bsa.artist_id
GROUP BY 1,2,4
ORDER BY 3 DESC

--  Q2: We want to find out most popular music genre for each country. We determine most popular genre as the genre with the highest amount of purchases
-- Write a query that returns each country along with the top genre, For countries where the maximum number of purchases is shared return all genres.

WITH popular_artist_cte AS (
	SELECT
		i.billing_country,
		g.name,
		COUNT(il.quantity) AS purchases,
		ROW_NUMBER() OVER (PARTITION BY billing_country ORDER BY COUNT(il.quantity) DESC) AS rank
	FROM invoice AS i
	JOIN invoice_line AS il ON i.invoice_id = il.invoice_id
	JOIN track AS t ON t.unit_price = il.unit_price
	JOIN genre AS g ON t.genre_id = g.genre_id
	GROUP BY 1,2
	)

SELECT
billing_country,
name,
purchases
FROM popular_artist_cte
WHERE rank <= 1

-- Q3: Write a query that determines the customer that has spent the most on music for each country. Write query that returns the country along with
-- top customer and how much they spent. For countries where the top spent is shared, provide all customers who spent this amount.

With top_cust_cte AS (
SELECT 
c.first_name,
c.last_name,
c.country,
ROW_NUMBER() OVER (PARTITION BY c.country ORDER BY SUM(i.total) DESC ) AS rank,
SUM(i.total) AS total_spend
FROM customer AS c
JOIN invoice AS i 
ON c.customer_id = i.customer_id
GROUP BY 1,2,3
)
SELECT 
first_name,
last_name,
country
FROM top_cust_cte
WHERE rank = 1

