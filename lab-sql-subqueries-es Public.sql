USE SAKILA;

-- 1.¿Cuántas copias de la película El Jorobado Imposible existen en el sistema de inventario?

SELECT COUNT(*)
FROM inventory
JOIN film ON inventory.film_id = film.film_id
WHERE film.title = 'El Jorobado Imposible';


-- 2.Lista todas las películas cuya duración sea mayor que el promedio de todas las películas

SELECT title, length
FROM film
WHERE length > (SELECT AVG(length) FROM film);


-- 3. Usa subconsultas para mostrar todos los actores que aparecen en la película Viaje Solo.
SELECT actor.first_name, actor.last_name
FROM actor
WHERE actor.actor_id IN (
    SELECT film_actor.actor_id
    FROM film_actor
    JOIN film ON film_actor.film_id = film.film_id
    WHERE film.title = 'Viaje Solo'
);
-- 4. Las ventas han estado disminuyendo entre las familias jóvenes, y deseas dirigir todas las películas familiares a una promoción. 
-- Identifica todas las películas categorizadas como películas familiares.
SELECT film.title
FROM film
JOIN film_category ON film.film_id = film_category.film_id
JOIN category ON film_category.category_id = category.category_id
WHERE category.name = 'Family';


-- 5. Obtén el nombre y correo electrónico de los clientes de Canadá usando subconsultas. Haz lo mismo con uniones.
-- Ten en cuenta que para crear una unión, tendrás que identificar las tablas correctas con sus claves primarias y claves foráneas, que te ayudarán a obtener la información relevante.

SELECT first_name, last_name, email
FROM customer
WHERE address_id IN (
    SELECT address_id
    FROM address
    WHERE city_id IN (
        SELECT city_id
        FROM city
        WHERE country_id = (
            SELECT country_id
            FROM country
            WHERE country = 'Canada'
        )
    )
);
SELECT customer.first_name, customer.last_name, customer.email
FROM customer
JOIN address ON customer.address_id = address.address_id
JOIN city ON address.city_id = city.city_id
JOIN country ON city.country_id = country.country_id
WHERE country.country = 'Canada';

-- 6. ¿Cuáles son las películas protagonizadas por el actor más prolífico? El actor más prolífico se define como el actor que ha actuado en el mayor número de películas. 
-- Primero tendrás que encontrar al actor más prolífico y luego usar ese actor_id para encontrar las diferentes películas en las que ha protagonizado.

WITH actor_counts AS (
    SELECT actor_id, COUNT(*) AS film_count
    FROM film_actor
    GROUP BY actor_id
),
most_prolific AS (
    SELECT actor_id
    FROM actor_counts
    WHERE film_count = (SELECT MAX(film_count) FROM actor_counts)
)

-- Encuentra las películas en las que ha actuado el actor más prolífico
SELECT film.title
FROM film
JOIN film_actor ON film.film_id = film_actor.film_id
WHERE film_actor.actor_id IN (SELECT actor_id FROM most_prolific);
-- 7. Películas alquiladas por el cliente más rentable. 
-- Puedes usar la tabla de clientes y la tabla de pagos para encontrar al cliente más rentable, es decir, el cliente que ha realizado la mayor suma de pagos.

WITH customer_payments AS (
    SELECT customer_id, SUM(amount) AS total_amount_spent
    FROM payment
    GROUP BY customer_id
),
most_profitable_customer AS (
    SELECT customer_id
    FROM customer_payments
    WHERE total_amount_spent = (SELECT MAX(total_amount_spent) FROM customer_payments)
)

-- Encuentra las películas alquiladas por el cliente más rentable
SELECT film.title
FROM rental
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN film ON inventory.film_id = film.film_id
WHERE rental.customer_id IN (SELECT customer_id FROM most_profitable_customer);
;

-- 8. Obtén el client_id y el total_amount_spent de esos clientes que gastaron más que el promedio del total_amount gastado por cada cliente.


WITH avg_spent AS (
    SELECT AVG(total_amount_spent) AS avg_amount
    FROM (
        SELECT customer_id, SUM(amount) AS total_amount_spent
        FROM payment
        GROUP BY customer_id
    ) AS customer_totals
)

-- Encuentra los clientes que gastaron más que el promedio
SELECT customer_id, total_amount_spent
FROM (
    SELECT customer_id, SUM(amount) AS total_amount_spent
    FROM payment
    GROUP BY customer_id
) AS customer_totals
WHERE total_amount_spent > (SELECT avg_amount FROM avg_spent);


