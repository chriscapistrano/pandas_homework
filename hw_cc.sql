SET SQL_SAFE_UPDATES = 0;

USE sakila;

#1a. Display the first and last names of all actors from the table actor
select first_name, last_name from actor;

#1b. Display the first and last name of each actor in a single column in upper case
# letters. Name the column Actor Name
SELECT CONCAT(first_name, ' ', last_name) AS Actor_Name FROM actor; #note: names are already upper case 

#2a. You need to find the ID number, first name, and last name of an actor, of whom 
#you know only the first name, "Joe." What is one query would you use to obtain 
#this information?
select actor_id, first_name, last_name from actor
where first_name = 'JOE';

#2b. Find all actors whose last name contain the letters GEN
select * from actor
where last_name LIKE '%GEN%';

#2c. Find all actors whose last names contain the letters LI. This time, order the 
#rows by last name and first name, in that order:
select * from actor
where last_name LIKE '%LI%'
order by last_name DESC, first_name DESC; 

#2d. Using IN, display the country_id and country columns of the following countries: 
#Afghanistan, Bangladesh, and China:
select country_id, country from country
where country IN ('Afghanistan', 'Bangladesh', 'China');

#3a. You want to keep a description of each actor. You don't think you will be 
#performing queries on a description, so create a column in the table actor named 
#description and use the data type BLOB (Make sure to research the type BLOB, 
#as the difference between it and VARCHAR are significant).
ALTER TABLE actor add column description BLOB;

#3b. Very quickly you realize that entering descriptions for each actor is too 
#much effort. Delete the description column.
ALTER TABLE actor DROP description; 

#4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(last_name) from actor
group by last_name;

#4b. List last names of actors and the number of actors who have that last name, 
#but only for names that are shared by at least two actors
select last_name, count(last_name) from actor
group by last_name
having count(last_name) > 1;

#4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as 
#GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET
	first_name = 'HARPO'
WHERE 
	first_name = 'GROUCHO';
   
 #4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that 
#GROUCHO was the correct name after all! In a single query, if the first name of the 
#actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET
	first_name = 'GROUCHO'
WHERE 
	first_name = 'HARPO';
    
# 5a. You cannot locate the schema of the address table. Which query would you use 
#to re-create it?
#Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
SHOW CREATE TABLE address;

#6a. Use JOIN to display the first and last names, as well as the address, of each staff 
#member. Use the tables staff and address:
SELECT s.first_name, s.last_name FROM staff AS s
JOIN address AS a ON s.address_id = a.address_id;

#6b. Use JOIN to display the total amount rung up by each staff member in August of 
#2005. Use tables staff and payment.
SELECT p.staff_id, sum(amount) FROM payment AS p
JOIN staff AS s ON p.staff_id = s.staff_id
WHERE p.payment_date >=  2008-08-01
GROUP BY p.staff_id;

#6c. List each film and the number of actors who are listed for that film. 
#Use tables film_actor and film. Use inner join.
SELECT f.title, COUNT(actor_id) FROM film AS f
INNER JOIN film_actor AS a ON f.film_id = a.film_id
GROUP BY f.title;

#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select * from inventory;
select * from film;

SELECT COUNT(film_id) FROM inventory
WHERE film_id IN
	(
    SELECT film_id FROM film
    WHERE title = 'HUNCHBACK IMPOSSIBLE'
    );

#6e. Using the tables payment and customer and the JOIN command, list the total paid by each 
#customer. List the customers alphabetically by last name:
SELECT * from payment;
select * from customer;

SELECT p.customer_id, c.first_name, c.last_name, SUM(amount) FROM payment AS p
JOIN customer AS  c ON p.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY c.last_name ASC;

#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
#As an unintended consequence, films starting with the letters K and Q have also 
#soared in popularity. Use subqueries to display the titles of movies starting with 
#the letters K and Q whose language is English.
SELECT * FROM film;
SELECT * FROM language; 

SELECT title FROM film 
WHERE title LIKE 'K%' OR
			  title LIKE 'Q%' AND
			  language_id IN
	(
    SELECT language_id FROM language 
    WHERE name = 'English'
    );

#7b. Use subqueries to display all actors who appear in the film Alone Trip
SELECT * FROM film_actor;
SELECT * FROM film;
SELECT * FROM actor;

SELECT a.first_name, a.last_name FROM actor AS a
WHERE actor_id IN
	(
    SELECT actor_id FROM film_actor
    WHERE film_id in
		(
        SELECT film_id FROM film
        WHERE title = 'ALONE TRIP'
        )
	);		

#7c. You want to run an email marketing campaign in Canada, for which you will 
#need the names and email addresses of all Canadian customers. 
#Use joins to retrieve this information.
SELECT first_name, last_name, email FROM customer
WHERE address_id IN
	(
    SELECT address_id FROM address
    WHERE city_id IN
		(
        SELECT city_id FROM city
        WHERE country_id IN
			(
            SELECT country_id FROM country
            WHERE country = 'Canada'
            )
         )
     );   
            
#7d. Sales have been lagging among young families, and you wish to target 
#all family movies for a promotion. Identify all movies categorized as family films.
SELECT * FROM category;
SELECT * FROM film_category;
SELECT * FROM film;

SELECT title FROM film
WHERE film_id IN
	(
	SELECT film_id FROM film_category
    WHERE category_id in
		(
        SELECT category_id FROM category
			WHERE name = 'Family'
		)
    );
    
#7f. Write a query to display how much business, in dollars, each store brought in.
SELECT * FROM store; 
SELECT * FROM staff;
SELECT * FROM payment;

SELECT SUM(amount) AS Business_Per_Store FROM payment AS p
JOIN staff AS s ON p.staff_id = s.staff_id
JOIN store as r ON s.store_id = r.store_id
GROUP BY r.store_id;

#7g. Write a query to display for each store its store ID, city, and country.
SELECT * FROM store;
SELECT * FROM city;
SELECT * FROM country;
SELECT * FROM address;

SELECT s.store_id, c.city, d.country FROM store AS s
JOIN address AS a ON s.address_id = a.address_id
JOIN city AS c ON a.city_id = c.city_id
JOIN country AS d ON c.country_id = d.country_id;

#7h. List the top five genres in gross revenue in descending order. 
#(Hint: you may need to use the following tables: category, film_category, 
#inventory, payment, and rental.)
SELECT c.name, sum(amount) AS Gross FROM payment AS p
JOIN rental AS r ON p.rental_id = r.rental_id
JOIN inventory AS i ON r.inventory_id = i.inventory_id
JOIN film AS f ON i.film_id = f.film_id
JOIN film_category AS g ON f.film_id = g.film_id
JOIN category AS c ON g.category_id = c.category_id
group by c.name
ORDER BY sum(amount) desc limit 5;

#8a. In your new role as an executive, you would like to have an easy way of 
#viewing the Top five genres by gross revenue. Use the solution from the 
#problem above to create a view. If you haven't solved 7h, you can substitute 
#another query to create a view.
CREATE VIEW top_five_genres AS
SELECT c.name, sum(amount) AS Gross FROM payment AS p
JOIN rental AS r ON p.rental_id = r.rental_id
JOIN inventory AS i ON r.inventory_id = i.inventory_id
JOIN film AS f ON i.film_id = f.film_id
JOIN film_category AS g ON f.film_id = g.film_id
JOIN category AS c ON g.category_id = c.category_id
group by c.name
ORDER BY sum(amount) desc limit 5;
SELECT * from `top_five_genres`;

#8b. How would you display the view that you created in 8a?
#ANSWER: Does the question above mean what graph I would use to display the view
# I created above? If so, I think bar graphs would be the best way to do so since these 
#are categorical variables. 

#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres;



