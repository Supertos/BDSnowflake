
CREATE TABLE IF NOT EXISTS dim_location (
    location_id SERIAL PRIMARY KEY,
    country VARCHAR(100),
    state VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    CONSTRAINT uq_location UNIQUE (country, state, city, postal_code)
);

CREATE TABLE IF NOT EXISTS dim_customer (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    age INTEGER,
    email VARCHAR(255),
    location_id INTEGER REFERENCES dim_location(location_id),
    pet_type VARCHAR(100),
    pet_name VARCHAR(100),
    pet_breed VARCHAR(100),
    CONSTRAINT uq_customer_email UNIQUE (email)
);

CREATE TABLE IF NOT EXISTS dim_seller (
    seller_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    location_id INTEGER REFERENCES dim_location(location_id),
    CONSTRAINT uq_seller_email UNIQUE (email)
);

CREATE TABLE IF NOT EXISTS dim_store (
    store_id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    address VARCHAR(255),
    phone VARCHAR(50),
    email VARCHAR(255),
    location_id INTEGER REFERENCES dim_location(location_id),
    CONSTRAINT uq_store_name UNIQUE (name)
);

CREATE TABLE IF NOT EXISTS dim_supplier (
    supplier_id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    contact VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(50),
    address VARCHAR(255),
    location_id INTEGER REFERENCES dim_location(location_id),
    CONSTRAINT uq_supplier_email UNIQUE (email)
);

CREATE TABLE IF NOT EXISTS dim_product_category (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100),
    pet_category VARCHAR(100),
    CONSTRAINT uq_product_category UNIQUE (category_name, pet_category)
);

CREATE TABLE IF NOT EXISTS dim_product (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    category_id INTEGER REFERENCES dim_product_category(category_id),
    price NUMERIC(10,2),
    weight NUMERIC(10,2),
    color VARCHAR(50),
    size VARCHAR(50),
    brand VARCHAR(100),
    material VARCHAR(100),
    description TEXT,
    rating NUMERIC(3,2),
    reviews INTEGER,
    release_date DATE,
    expiry_date DATE,
    CONSTRAINT uq_product_name UNIQUE (name)
);

CREATE TABLE IF NOT EXISTS fact_sales (
    sale_id SERIAL PRIMARY KEY,
    sale_date DATE,
    customer_id INTEGER REFERENCES dim_customer(customer_id),
    seller_id INTEGER REFERENCES dim_seller(seller_id),
    product_id INTEGER REFERENCES dim_product(product_id),
    store_id INTEGER REFERENCES dim_store(store_id),
    sale_quantity INTEGER,
    sale_total_price NUMERIC(10,2)
);
