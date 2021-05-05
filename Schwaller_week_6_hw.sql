
/*1.	Show all customers whose last names start with T. Order them by first name from A-Z.*/
		SELECT last_name, first_name
		FROM customer
		WHERE last_name LIKE 'T%'
		ORDER BY first_name;
	/*I selected the last_name and first_name columns from the customer table, filtered by last name starts with T, and ordered by first name, which was alphabetical by default.*/

/*2.	Show all rentals returned from 5/28/2005 to 6/1/2005.*/
		SELECT *
		FROM rental
		WHERE return_date BETWEEN '2005-05-28'
		AND '2005-06-01';
	/**/

/*3.	How would you determine which movies are rented the most?*/
		SELECT f.title, f.film_id
		FROM film AS f
		INNER JOIN inventory i
		ON i.film_id = f.film_id
		INNER JOIN rental r
		ON r.inventory_id = i.inventory_id
		GROUP BY f.film_id
		ORDER BY count(*) DESC;
	/**/

/*4.	Show how much each customer spent on movies (for all time). Order them from least to most.*/
		SELECT c.customer_id, last_name, first_name, SUM(amount)
		FROM customer AS c
		LEFT JOIN payment AS p
		ON c.customer_id = p.customer_id
		GROUP BY c.customer_id
		ORDER BY SUM(amount);


/*5.	Which actor was in the most movies in 2006 (based on this dataset)? Be sure to alias the actor name and count as a more descriptive name. Order the results from most to least.*/
		SELECT COUNT(last_name) AS total_movies, last_name AS actor_name,
		release_year, title
		FROM film
		INNER JOIN film_actor
		ON film.film_id = film_actor.film_id
		INNER JOIN actor
		ON film_actor.actor_id = actor.actor_id
		WHERE release_year = 2006
		GROUP BY actor.last_name, film.title, film.release_year
		ORDER BY COUNT(last_name) DESC;

/*6.	Write an explain plan for 4 and 5. Show the queries and explain what is happening in each one. Use the following link to understand how this works http://postgresguide.com/performance/explain.html */



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
		name	avg_rental_rate
		Action	2.6462500000000000
		Documentary	2.6664705882352900
		Classics	2.7443859649122800
		Family	2.7581159420289900
		Animation	2.8081818181818200
		Children	2.8900000000000000
		Music	2.9507843137254900
		Drama	3.0222580645161300
		Horror	3.0257142857142900
		Foreign	3.0995890410958900
		New	3.1169841269841300
		Sports	3.1251351351351400
		Comedy	3.1624137931034500
		Sci-Fi	3.2195081967213100
		Travel	3.2356140350877200
		Games	3.2522950819672100
		*/


/*8.	How many films were returned late? Early? On time?

			late: 7,269
			on time: 1,954
			early: 6,864	

			First, I created a new table called "rentalreturns." 
			To do this, I joined film, inventory, and rental based on shared columns. (Initially, I tried to join film and rental on "last_update," but the columns did not correspond to each other.)
			I gave rentalreturns a new column, "rental_group," which showed early, on time, and late returns.
			These cases were determined by finding the difference between return date and rental date, then comparing it to the "rental duration"  column.

			Next, I grouped the data in rentalreturns by rental_group to find the count for each value: late, on time, and early.
			I had difficulty when I tried to do this in the same query as all of the other steps, so I did it separately after the table was created.
		*/	

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


/*9.	What categories are the most rented and what are their total sales?*/

		SELECT c1.name, SUM(rental_rate) AS total_rental_rate
		FROM category AS c1
		FULL JOIN film_category AS f1
		USING (category_id)
		FULL JOIN film AS f2
		ON f1.film_id = f2.film_id
		GROUP BY name
		ORDER BY total_rental_rate;

		/*
		"name"	"total_rental_rate"
		"Music"	150.49
		"Classics"	156.43
		"Action"	169.36
		"Horror"	169.44
		"Children"	173.4
		"Documentary"	181.32
		"Comedy"	183.42
		"Travel"	184.43
		"Animation"	185.34
		"Drama"	187.38
		"Family"	190.31
		"New"	196.37
		"Sci-Fi"	196.39
		"Games"	198.39
		"Foreign"	226.27
		"Sports"	231.26
		*/


/*10.	Create a view for 8 and a view for 9. Be sure to name them appropriately.*/





