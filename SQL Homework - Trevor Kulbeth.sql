-- Select database for use in the homework --
USE sakila;

-- Part 1a. display the first and last names of all actors from the table actor.
SELECT first_name, last_name FROM actor;

-- Part 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT UPPER(CONCAT(first_name, " ", last_name)) as "Actor Name"
FROM actor;

-- Part 2a. You need to find the ID number, 
-- first name, and last name of an actor, of whom you know only the first name, 
-- "Joe." What is one query would you use to obtain this information?
SELECT * from actor;
SELECT actor_id AS "ID", 
first_name AS "First Name",
last_name AS "Last Name"
FROM actor
WHERE first_name = "Joe";

-- Part 2b. Find all actors whose last name contain the letters GEN:--
SELECT *
FROM actor
WHERE last_name LIKE "%GEN%";

-- Part 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT *
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name , first_name;

-- Part 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China");

-- Part 3a. You want to keep a description of each actor. 
-- You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB 
ALTER TABLE actor
ADD COLUMN description BLOB;
SELECT * FROM actor;

-- Part 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP COLUMN description;
SELECT * FROM actor;

-- Part 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) AS "Actors with same last name"
FROM actor
GROUP BY last_name;

-- Part 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) AS "Last Name Count"
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) > 1;

-- Part 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

SELECT * FROM actor
WHERE first_name = "HARPO" AND last_name = "WILLIAMS";

-- Part 4d. In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO
UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO";

SELECT * FROM actor
WHERE first_name = "GROUCHO";

-- Part 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- Part 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT first_name, last_name, address 
FROM staff s
INNER JOIN address a
USING (address_id);

-- Part 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT first_name, last_name, SUM(amount) AS "Total Amount"
FROM staff s
JOIN payment p
USING(staff_id)
GROUP BY (staff_id);

-- Part 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT title AS "Title", COUNT(actor_id) AS "No. of Actors"
FROM film
INNER JOIN film_actor
USING(film_id)
GROUP BY (film_id);

-- Part 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(inventory_id) AS "No. of Movies in Inventory"
FROM inventory
WHERE film_id IN 
(
	SELECT film_id
	FROM film
	WHERE title = "Hunchback Impossible"
    );

-- Also 

SELECT title AS "Title", COUNT(inventory_id) AS "No. of Copies"
FROM film f
INNER JOIN inventory i
ON f.film_id = i.film_id
WHERE title = "Hunchback Impossible";

-- Part 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select * from payment;
SELECT first_name, last_name, SUM(amount) AS "Total Amount Paid"
FROM customer 
JOIN payment
USING(customer_id)
GROUP BY (customer_id)
ORDER BY last_name ASC;

-- Part 7a. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
-- SELECT title, name
-- FROM film
-- join language
-- WHERE language.name = "English" AND (title LIKE "K%" OR title LIKE "Q%");
SELECT title 
FROM film 
WHERE language_id IN 
(
	SELECT language_id
	FROM language
	WHERE name = "English") 
    AND title LIKE "K%" OR title LIKE "Q%";
    
-- Part 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, Last_name
FROM actor
WHERE actor_id IN 
(
	SELECT actor_id
    FROM film_actor
    WHERE film_id IN
    (
		SELECT film_id
        FROM film
        WHERE title = "Alone Trip"
        )
	);
    
-- Part 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
SELECT first_name, last_name, email
FROM customer
JOIN address ON customer.address_id = address.address_id
JOIN city ON address.city_id = city.city_id
JOIN country ON city.country_id = country.country_id
WHERE country = "Canada";

-- Part 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT title
FROM film
WHERE film_id IN
(
	SELECT film_id
    FROM film_category
    WHERE category_id IN
    (
		SELECT category_id
        FROM category
        WHERE name = "Family"
        )
	);
    
-- Part 7e. Display the most frequently rented movies in descending order.
SELECT film.title, COUNT(rental.inventory_id) AS CountRental
FROM rental
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN film on inventory.film_id = film.film_id
GROUP BY film.title
ORDER BY CountRental DESC;

-- Part 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id as StoreID, SUM(payment.amount)
FROM payment
JOIN staff on payment.staff_id = staff.staff_id
JOIN store on staff.store_id = store.store_id
GROUP BY store.store_id;

-- Part 7g. Write a query to display for each store its store ID, city, and country.
SELECT store.store_ID as StoreID, city.city, country.country
FROM store
JOIN address ON store.address_id = address.address_ID
JOIN city ON city.city_id = address.city_id
JOIN country ON country.country_id = city.country_id
GROUP BY store.store_id;

-- Part 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT category.name as filmCategory, SUM(payment.amount) as totalRevenue
FROM payment
JOIN rental ON payment.rental_id = rental.rental_id
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN film_category ON inventory.film_id = film_category.film_id
JOIN category ON film_category.category_id = category.category_id
GROUP BY filmCategory
ORDER BY totalRevenue DESC
LIMIT 5;

-- Part 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW  top_five_genres_view
AS (
	SELECT category.name as filmCategory, SUM(payment.amount) as totalRevenue
	FROM payment
	JOIN rental ON payment.rental_id = rental.rental_id
	JOIN inventory ON rental.inventory_id = inventory.inventory_id
	JOIN film_category ON inventory.film_id = film_category.film_id
	JOIN category ON film_category.category_id = category.category_id
	GROUP BY filmCategory
	ORDER BY totalRevenue DESC
	LIMIT 5
);

-- Part 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres_view;

-- Part 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW IF EXISTS top_five_genres_view;
