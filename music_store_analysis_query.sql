SELECT * FROM genre

/* Q1: Who is the senior most employee based on job title? */
--method 1--

SELECT title, first_name, last_name,hire_date
FROM employee
ORDER BY hire_date ASC
LImit 1
--method2--

SELECT *
FROM employee
ORDER BY levels DESC
LImit 1

--/Q2: Which countries have the most Invoices?/--

SELECT COUNT(*) as total_invoices, billing_country
FROM invoice
GROUP BY billing_country
ORDER BY total_invoices DESC

--/ Q3: What are top 3 values of total invoice?/--

SELECT * FROM invoice
ORDER BY total DESC
LIMIT 3

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT SUM(total) AS total_invoice, billing_city
FROM invoice
GROUP BY billing_city
ORDER BY total_invoice DESC

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select * from customer
select * from invoice
---method without join ---

SELECT sum(total) AS total_customer_purchase, customer_id
from invoice
group by customer_id
order by total_customer_purchase desc
limit 10
--method 1(with join)--

SELECT customer.customer_id, customer.first_name, customer.last_name,
SUM(invoice.total) AS total_customer_purchase
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total_customer_purchase DESC
LIMIT 1;

--Module# 2---
/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */
--optimized query--

SELECT DISTINCT email,first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name = 'Rock'
)
ORDER BY email;

---take time bcs of join--

SELECT DISTINCT email, first_name, last_name,genre.name AS name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.customer_id = invoice_line.invoice_id 
JOIN track ON invoice_line.invoice_id = track.track_id
JOIN genre ON track.genre_id = genre.genre_id
where genre.name = 'Rock'
ORDER BY email

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT artist.artist_id,  artist.name, COUNT(artist.artist_id) AS number_of_songs
FROM track 
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name = 'Rock'
GROUP BY artist.artist_id 
ORDER BY number_of_songs DESC
LIMIT 10

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT name, milliseconds
FROM track
WHERE milliseconds > (
  SELECT AVG(milliseconds) AS avg_song_length
  From track)
order by milliseconds desc

--MODULE 3---
/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */
--using CTE, 1= FIRST COLUMN and so on join backward--

with best_selling_artist AS(
 SELECT artist.artist_id, artist.name AS artist_name,
  sum(invoice_line.unit_price*invoice_line.quantity) AS total_sales
 FROM invoice_line
 JOIN track ON track.track_id = invoice_line.track_id
 JOIN album ON album.album_id = track.album_id 
 JOIN artist ON artist.artist_id = album.artist_id
 GROUP BY 1
 ORDER BY 3 DESC 
 LIMIT 1 
)

SELECT customer.customer_id, customer.first_name, customer.last_name, bsa.artist_name,
 sum(invoice_line.unit_price*invoice_line.quantity) AS amount_spend
FROM invoice
JOIN customer on customer.customer_id = invoice.customer_id
JOIN invoice_line on invoice_line.invoice_id = invoice.invoice_id 
JOIN track on track.track_id = invoice_line.track_id
JOIN album on album.album_id = track.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = album.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */
/* Method: Using CTE */

WITH popular_genre_country AS (
 SELECT COUNT(invoice_line.quantity) as Purchase,customer.country, genre.name, genre.genre_id,
 ROW_NUMBER() OVER(PARTITION BY customer.country  ORDER BY COUNT(invoice_line.quantity) DESC) AS Rowno
 from invoice_line
 JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
 JOIN customer ON customer.customer_id = invoice.customer_id
 JOIN track ON track.track_id = invoice_line.track_id
 JOIN genre ON genre.genre_id = track.genre_id 
 GROUP BY 2,3,4
 ORDER BY  2 ASC, 1 DESC
 )
 SELECT * FROM popular_genre_country WHERE Rowno <=1
 
/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */
/* Method: Using CTE */

WITH Customter_spending_country AS (
	SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
	FROM invoice
	JOIN customer ON customer.customer_id = invoice.customer_id
	GROUP BY 1,2,3,4
	ORDER BY 4 ASC, 5 DESC )
SELECT * FROM Customter_spending_country WHERE RowNo <= 1

