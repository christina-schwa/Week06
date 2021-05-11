
/*1.	Show all customers whose last names start with T. Order them by first name from A-Z.*/
		SELECT last_name, first_name
		FROM customer
		WHERE last_name LIKE 'T%'
		ORDER BY first_name;
	/*
	I selected the last_name and first_name columns from the customer table, filtered by last name starts with T, and ordered by first name, which was alphabetical by default.
	*/

/*2.	Show all rentals returned from 5/28/2005 to 6/1/2005.*/
		SELECT *
		FROM rental
		WHERE return_date BETWEEN '2005-05-28'
		AND '2005-06-01';
	/*
	I selected all columns of the rental table and filtered the rows by return date (between 5/28/2005 and 6/1/2005).
	*/

/*3.	How would you determine which movies are rented the most?*/
		SELECT f.title, COUNT(r.rental_date) AS rental_count
		FROM film AS f
		INNER JOIN inventory i
		ON i.film_id = f.film_id
		INNER JOIN rental r
		ON r.inventory_id = i.inventory_id
		GROUP BY f.title
		ORDER BY COUNT(r.rental_date) DESC;
	/*
	I selected the "title" column from the film table and the count/number of rental dates from the rental table. I renamed the latter "rental_count." 
	Then, I joined the film and inventory tables on the shared "film_id" column and joined the inventory and rental tables on the shared "inventory_id" column. 
	Finally, I grouped the films by film title and ordered them by "rental_count" in descending order.
	*/

/*4.	Show how much each customer spent on movies (for all time). Order them from least to most.*/
		SELECT c.customer_id, last_name, first_name, SUM(amount)
		FROM customer AS c
		LEFT JOIN payment AS p
		ON c.customer_id = p.customer_id
		GROUP BY c.customer_id
		ORDER BY SUM(amount);
	/*
	I selected customer id, lasst name, and first name from the customer tabel and the sum of amount paid from the payment table. 
	Then, I joined customer to payment on the shared "customerr_id" column. 
	I grouped by customer ID and ordered by sum of the amount each customer paid.
	*/

/*5.	Which actor was in the most movies in 2006 (based on this dataset)? Be sure to alias the actor name and count as a more descriptive name. Order the results from most to least.*/
		SELECT COUNT(film_actor.film_id) AS total_movies, (actor.last_name, actor.first_name) AS actor_name, release_year
		FROM film
		INNER JOIN film_actor
		ON film.film_id = film_actor.film_id
		INNER JOIN actor
		ON film_actor.actor_id = actor.actor_id
		WHERE release_year = 2006
		GROUP BY actor_name, film.release_year
		ORDER BY total_movies DESC
		LIMIT 1;
		/*
		total_movies	actor_name		release_year
		54				(Davis,Susan)	2006
		*/

	/*
	Susan Davis was in the most movies (54) in 2006. 
	I selected the number of film IDs from the film_actor table and aliased it as "total_movies." 
	I also selected actors' last names and first names from the actor table and aliased them as "actor_name. 
	Then, I joined the film and film_actor tables on "film_d" and joined the film_actor and actor tables on "actor_id." 
	I filtered rows to only those with a release year of 2006. Last, I grouped rows by "actor_name" and release year, ordered by "total_movies" in descending order, and limited the results to one.
	*/

/*6.	Write an explain plan for 4 and 5. Show the queries and explain what is happening in each one. Use the following link to understand how this works http://postgresguide.com/performance/explain.html */
		
		/* 4. */
		EXPLAIN
		SELECT c.customer_id, last_name, first_name, SUM(amount)
		FROM customer AS c
		LEFT JOIN payment AS p
		ON c.customer_id = p.customer_id
		GROUP BY c.customer_id
		ORDER BY SUM(amount);
		"Sort  (cost=423.12..424.62 rows=599 width=49)"
		"  Sort Key: (sum(p.amount))"
		"  ->  HashAggregate  (cost=388.00..395.49 rows=599 width=49)"
		"        Group Key: c.customer_id"
		"        ->  Hash Right Join  (cost=22.48..315.02 rows=14596 width=23)"
		"              Hash Cond: (p.customer_id = c.customer_id)"
		"              ->  Seq Scan on payment p  (cost=0.00..253.96 rows=14596 width=8)"
		"              ->  Hash  (cost=14.99..14.99 rows=599 width=17)"
		"                    ->  Seq Scan on customer c  (cost=0.00..14.99 rows=599 width=17)"

		/* 5. */
		EXPLAIN
		SELECT COUNT(film_actor.film_id) AS total_movies, (actor.last_name, actor.first_name) AS actor_name, release_year
		FROM film
		INNER JOIN film_actor
		ON film.film_id = film_actor.film_id
		INNER JOIN actor
		ON film_actor.actor_id = actor.actor_id
		WHERE release_year = 2006
		GROUP BY actor_name, film.release_year
		ORDER BY total_movies DESC
		LIMIT 1;
		"Limit  (cost=594.75..594.75 rows=1 width=44)"
		"  ->  Sort  (cost=594.75..595.07 rows=128 width=44)"
		"        Sort Key: (count(film_actor.film_id)) DESC"
		"        ->  GroupAggregate  (cost=538.21..594.11 rows=128 width=44)"
		"              Group Key: (ROW(actor.last_name, actor.first_name)), film.release_year"
		"              ->  Sort  (cost=538.21..551.87 rows=5462 width=38)"
		"                    Sort Key: (ROW(actor.last_name, actor.first_name))"
		"                    ->  Hash Join  (cost=85.50..199.15 rows=5462 width=38)"
		"                          Hash Cond: (film_actor.actor_id = actor.actor_id)"
		"                          ->  Hash Join  (cost=79.00..178.01 rows=5462 width=8)"
		"                                Hash Cond: (film_actor.film_id = film.film_id)"
		"                                ->  Seq Scan on film_actor  (cost=0.00..84.62 rows=5462 width=4)"
		"                                ->  Hash  (cost=66.50..66.50 rows=1000 width=8)"
		"                                      ->  Seq Scan on film  (cost=0.00..66.50 rows=1000 width=8)"
		"                                            Filter: ((release_year)::integer = 2006)"
		"                          ->  Hash  (cost=4.00..4.00 rows=200 width=17)"
		"                                ->  Seq Scan on actor  (cost=0.00..4.00 rows=200 width=17)"

/*7.	What is the average rental rate per genre?*/
		SELECT c1.name, AVG(rental_rate) AS avg_rental_rate
		FROM category AS c1
		FULL JOIN film_category AS f1
		USING (category_id)
		FULL JOIN film AS f2
		ON f1.film_id = f2.film_id
		GROUP BY name
		ORDER BY avg_rental_rate;
		/*
		name		avg_rental_rate
		Action		2.6462500000000000
		Documentary	2.6664705882352900
		Classics	2.7443859649122800
		Family		2.7581159420289900
		Animation	2.8081818181818200
		Children	2.8900000000000000
		Music		2.9507843137254900
		Drama		3.0222580645161300
		Horror		3.0257142857142900
		Foreign		3.0995890410958900
		New			3.1169841269841300
		Sports		3.1251351351351400
		Comedy		3.1624137931034500
		Sci-Fi		3.2195081967213100
		Travel		3.2356140350877200
		Games		3.2522950819672100
		*/

	/*
	I selected the category (i.e., genre) name from the category table and the average rental rate (aliased as "avg_rental_rate") from the film table. 
	I joined the category and film_category tables on the shared "category_id" column and then joined the film_category tables on the shared "film_id" column. 
	Finally, I grouped by category/genre name and ordered by avg_rental_rate.
	*/

/*8.	How many films were returned late? Early? On time?*/
		SELECT film_id, 
				rental_duration, 
				i.inventory_id, 
				rental_date, 
				return_date,
				CASE WHEN DATE(return_date) - DATE(rental_date) > rental_duration THEN 'late'
				WHEN DATE(return_date) - DATE(rental_date) < rental_duration THEN 'early'
				ELSE 'on time' END
				AS rental_group
		INTO rentalreturns
		FROM film AS f
		FULL JOIN inventory AS i
		USING (film_id)
		FULL JOIN rental AS r
		USING (inventory_id)
		ORDER BY rental_group;

		SELECT rental_group, COUNT(*)
		FROM rentalreturns
		GROUP BY rental_group;
		/*
		rental_group	count	
		late: 			7,269
		on time: 		1,954
		early:			6,864	
		*/
	
	/*
	First, I created a new table called "rentalreturns." 
	To do this, I joined film, inventory, and rental based on shared columns. (Initially, I tried to join film and rental on "last_update," but the columns did not correspond to each other.)
	I gave rentalreturns a new column, "rental_group," which showed early, on time, and late returns.
	These cases were determined by finding the difference between return date and rental date, then comparing it to the "rental duration"  column.
	Next, I grouped the data in rentalreturns by rental_group to find the count for each value: late, on time, and early.
	I had difficulty when I tried to do this in the same query as all of the other steps, so I did it separately after the table was created. 
	I think that makes sense, though, since I created a whole new table in the first query, and the second query is selecting data from that new table. 
	*/	

/*9.	What categories are the most rented and what are their total sales?*/
		SELECT c.name, COUNT(rental_date) AS total_rentals, SUM(amount) AS total_sales
		FROM category AS c
		FULL JOIN film_category AS f1
		USING (category_id)
		FULL JOIN inventory as i
		USING (film_id)
		FULL JOIN rental
		USING (inventory_id)
		FULL JOIN payment
		USING (rental_id)
		GROUP BY c.name
		ORDER BY total_rentals DESC
		LIMIT 5;
		/*
		name		total_rentals	total_sales
		Sports		1179			4892.19
		Animation	1166			4245.31
		Action		1112			3951.84
		Sci-Fi		1101			4336.01
		Family		1096			3830.15
		*/
	
	/*
	I selected category name, number of rentals (by count of rental dates) aliased as "total_rentals," and sum of sales (i.e., "amount") as total sales.
	I used full joins to join category and film_category on "category_id," film_category and inventory on "film_id," inventory and rental on "inventory_id," and rental and payment on "rental_id."
	I grouped by category name, ordered by total_rentals, and limited the results to five rows to get the top five most rented categories.
	I also tried this using all inner joins instead of outer joins, which returned significantly different results. I thought a lot about this, but I couldn't work out exactly which type of join to use in each case and why. I know that full joins would include rows that contain null values, and that could affect the rental count, but how would it affect the sum of the payment amounts? Or how could rentals get grouped into specific categories if the category_id or inventory_id value is null?
	*/

/*10.	Create a view for 8 and a view for 9. Be sure to name them appropriately.*/

		/* 8. */
		CREATE VIEW late_ontime_early AS
		SELECT rental_group, COUNT(*)
		FROM rentalreturns
		GROUP BY rental_group;

		/* 9. */
		CREATE VIEW top_5_genres AS
		SELECT c.name, COUNT(rental_date) AS total_rentals, SUM(amount) AS total_sales
		FROM category AS c
		FULL JOIN film_category AS f1
		USING (category_id)
		FULL JOIN inventory as i
		USING (film_id)
		FULL JOIN rental
		USING (inventory_id)
		FULL JOIN payment
		USING (rental_id)
		GROUP BY c.name
		ORDER BY total_rentals DESC
		LIMIT 5;

	/*
	The "CREATE VIEW" statement is like aliasing an entire query. It's useful for simplifying the syntax of a query that builds off of another complex query you've already performed.
	*/




