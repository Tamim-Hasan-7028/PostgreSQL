-- Count all columns as total_rows
-- Count the number of non-missing entries for description, listing_price, and last_visited
-- Join info, finance, and traffic
select 
    count(*) as total_rows,
    count(description) as count_description,
    count(listing_price) as count_listing_price,
    count(last_visited) as count_last_visited
from info as i
inner join finance as f
using(product_id)
inner join traffic as t
using(product_id);


-- Select the brand, listing_price as an integer, and a count of all products in finance 
-- Join brands to finance on product_id
-- Filter for products with a listing_price more than zero
-- Aggregate results by brand and listing_price, and sort the results by listing_price in descending order
select brand, listing_price::integer, count(f.product_id)
from brands as b
inner join finance as f
using(product_id)
where listing_price>0
group by brand, listing_price
order by listing_price desc;



-- Select the brand, a count of all products in the finance table, and total revenue
-- Create four labels for products based on their price range, aliasing as price_category
-- Join brands to finance on product_id and filter out products missing a value for brand
-- Group results by brand and price_category, sort by total_revenue
select brand, count(f.product_id), sum(revenue) as total_revenue,
    case 
        when listing_price<42 then 'Budget'
        when listing_price>=42 and listing_price<74 then 'Average'
        when listing_price>=74 and listing_price<129 then 'Expensive'
        else 'Elite'
    end as price_category
from brands as b
inner join finance as f
using(product_id)
where brand is not null
group by brand, price_category
order by total_revenue desc;



-- Select brand and average_discount as a percentage
-- Join brands to finance on product_id
-- Aggregate by brand
-- Filter for products without missing values for brand
select brand, avg(discount)*100 as average_discount
from brands as b
inner join finance as f
using(product_id)
group by brand
having brand is not null
order by average_discount;



-- Calculate the correlation between reviews and revenue as review_revenue_corr
-- Join the reviews and finance tables on product_id
select corr(reviews,revenue) as review_revenue_corr
from finance
inner join reviews
using(product_id);



-- Calculate description_length
-- Convert rating to a numeric data type and calculate average_rating
-- Join info to reviews on product_id and group the results by description_length
-- Filter for products without missing values for description, and sort results by description_length
select 
    trunc(length(description),-2)as description_length,
    round(avg(rating::numeric),2) as average_rating
from info
inner join reviews
using(product_id)
where description is not null
group by description_length
order by description_length;



-- Select brand, month from last_visited, and a count of all products in reviews aliased as num_reviews
-- Join traffic with reviews and brands on product_id
-- Group by brand and month, filtering out missing values for brand and month
-- Order the results by brand and month
select brand, date_part('month', last_visited) as month, count(r.product_id) as num_reviews
from traffic
inner join reviews as r
using(product_id)
inner join brands
using(product_id)
group by brand,month
having brand is not null
    and date_part('month', last_visited) is not null
order by brand, month;



-- Create the footwear CTE, containing description and revenue
-- Filter footwear for products with a description containing %shoe%, %trainer, or %foot%
-- Also filter for products that are not missing values for description
-- Calculate the number of products and median revenue for footwear products
with footwear as
(
    select description, revenue
    from info
    inner join finance
    using(product_id)
    where description ilike '%shoe%'
        OR description ILIKE '%trainer%'
        OR description ILIKE '%foot%'
        and description is not null
)
SELECT COUNT(*) AS num_footwear_products, 
    percentile_disc(0.5) WITHIN GROUP (ORDER BY revenue) AS median_footwear_revenue
FROM footwear;



-- Copy the footwear CTE from the previous task
-- Calculate the number of products in info and median revenue from finance
-- Inner join info with finance on product_id
-- Filter the selection for products with a description not in footwear
with footwear as
(
    select description, revenue
    from info
    inner join finance
    using(product_id)
    where description ilike '%shoe%'
        OR description ILIKE '%trainer%'
        OR description ILIKE '%foot%'
        and description is not null
)
SELECT COUNT(i.*) AS num_clothing_products, 
    percentile_disc(0.5) WITHIN GROUP (ORDER BY f.revenue) AS median_clothing_revenue
FROM info AS i
INNER JOIN finance AS f on i.product_id = f.product_id
WHERE i.description NOT IN (SELECT description FROM footwear);