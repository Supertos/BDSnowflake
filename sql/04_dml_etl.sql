BEGIN;

INSERT INTO dim_location (country, state, city, postal_code)
SELECT DISTINCT country, state, city, postal_code FROM (
    SELECT customer_country AS country, NULL AS state, NULL AS city, customer_postal_code AS postal_code FROM staging_mock_data WHERE customer_country IS NOT NULL
    UNION ALL
    SELECT seller_country, NULL, NULL, seller_postal_code FROM staging_mock_data WHERE seller_country IS NOT NULL
    UNION ALL
    SELECT store_country, store_state, store_city, NULL FROM staging_mock_data WHERE store_country IS NOT NULL
    UNION ALL
    SELECT supplier_country, NULL, supplier_city, NULL FROM staging_mock_data WHERE supplier_country IS NOT NULL
) AS src
ON CONFLICT ON CONSTRAINT uq_location DO NOTHING;

INSERT INTO dim_customer (first_name, last_name, age, email, location_id, pet_type, pet_name, pet_breed)
SELECT DISTINCT s.customer_first_name, s.customer_last_name, s.customer_age, s.customer_email,
       loc.location_id, s.customer_pet_type, s.customer_pet_name, s.customer_pet_breed
FROM staging_mock_data s
LEFT JOIN dim_location loc ON loc.country = s.customer_country AND loc.postal_code IS NOT DISTINCT FROM s.customer_postal_code
WHERE s.customer_email IS NOT NULL
ON CONFLICT ON CONSTRAINT uq_customer_email DO NOTHING;

INSERT INTO dim_seller (first_name, last_name, email, location_id)
SELECT DISTINCT s.seller_first_name, s.seller_last_name, s.seller_email, loc.location_id
FROM staging_mock_data s
LEFT JOIN dim_location loc ON loc.country = s.seller_country AND loc.postal_code IS NOT DISTINCT FROM s.seller_postal_code
WHERE s.seller_email IS NOT NULL
ON CONFLICT ON CONSTRAINT uq_seller_email DO NOTHING;

INSERT INTO dim_store (name, address, phone, email, location_id)
SELECT DISTINCT s.store_name, s.store_location, s.store_phone, s.store_email, loc.location_id
FROM staging_mock_data s
LEFT JOIN dim_location loc ON loc.country = s.store_country AND loc.city IS NOT DISTINCT FROM s.store_city
WHERE s.store_name IS NOT NULL
ON CONFLICT ON CONSTRAINT uq_store_name DO NOTHING;

INSERT INTO dim_supplier (name, contact, email, phone, address, location_id)
SELECT DISTINCT s.supplier_name, s.supplier_contact, s.supplier_email, s.supplier_phone, s.supplier_address, loc.location_id
FROM staging_mock_data s
LEFT JOIN dim_location loc ON loc.country = s.supplier_country AND loc.city IS NOT DISTINCT FROM s.supplier_city
WHERE s.supplier_email IS NOT NULL
ON CONFLICT ON CONSTRAINT uq_supplier_email DO NOTHING;

INSERT INTO dim_product_category (category_name, pet_category)
SELECT DISTINCT product_category, pet_category FROM staging_mock_data
WHERE product_category IS NOT NULL
ON CONFLICT ON CONSTRAINT uq_product_category DO NOTHING;

INSERT INTO dim_product (name, category_id, price, weight, color, size, brand, material, description, rating, reviews, release_date, expiry_date)
SELECT DISTINCT s.product_name, cat.category_id, s.product_price, s.product_weight, s.product_color,
       s.product_size, s.product_brand, s.product_material, s.product_description,
       s.product_rating, s.product_reviews, s.product_release_date, s.product_expiry_date
FROM staging_mock_data s
LEFT JOIN dim_product_category cat ON cat.category_name = s.product_category AND cat.pet_category IS NOT DISTINCT FROM s.pet_category
WHERE s.product_name IS NOT NULL
ON CONFLICT ON CONSTRAINT uq_product_name DO NOTHING;

INSERT INTO fact_sales (sale_date, customer_id, seller_id, product_id, store_id, sale_quantity, sale_total_price)
SELECT s.sale_date, c.customer_id, sl.seller_id, p.product_id, st.store_id,
       s.sale_quantity, s.sale_total_price
FROM staging_mock_data s
JOIN dim_customer c ON c.email = s.customer_email
JOIN dim_seller sl ON sl.email = s.seller_email
JOIN dim_product p ON p.name = s.product_name
JOIN dim_store st ON st.name = s.store_name;

COMMIT;
