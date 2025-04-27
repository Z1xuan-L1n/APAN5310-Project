DROP TABLE IF EXISTS customers, products, orders, order_items,customer_feedback,delivery,employees,
					 employee_schedule,inventory,marketing_performance,stores,vendors,vendor_deliveries CASCADE;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    area VARCHAR(100),
    pincode VARCHAR(10),
    registration_date DATE,
    customer_segment VARCHAR(50),
    total_orders INT,
    avg_order_value DECIMAL(10,2)
);


CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    brand VARCHAR(50),
    price DECIMAL(10,2),
    mrp DECIMAL(10,2),
    margin_percentage DECIMAL(5,2),
    shelf_life_days INT,
    min_stock_level INT,
    max_stock_level INT
);

CREATE TABLE stores (
    store_id VARCHAR(10) PRIMARY KEY,
    store_name VARCHAR(100),
    location VARCHAR(100),
    address TEXT,
    contact_phone VARCHAR(20),
    store_manager_id INT
);

CREATE TABLE orders (
    order_id VARCHAR(10) PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    order_total DECIMAL(10,2),
	order_type VARCHAR(20) NOT NULL CHECK (order_type IN ('Walk in', 'delivery')),
    payment_method VARCHAR(50),
    store_id VARCHAR(10),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
	FOREIGN KEY (store_id) REFERENCES stores(store_id)
);

CREATE TABLE order_items (
    order_id VARCHAR(10),
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);


CREATE TABLE customer_feedback (
    feedback_id INT PRIMARY KEY,
    order_id VARCHAR(10),
    customer_id INT,
    rating INT,
    feedback_text TEXT,
    feedback_category VARCHAR(100),
    sentiment VARCHAR(50),
    feedback_date DATE,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE delivery (
    delivery_id INT PRIMARY KEY,
	order_id VARCHAR(10),
    delivery_partner_id INT,
    promised_time TIMESTAMP,
    actual_time TIMESTAMP,
    delivery_time_minutes INT,
    distance_km DECIMAL(6,2),
    delivery_status VARCHAR(50),
    reasons_if_delayed TEXT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE inventory (
    product_id INT,
    date DATE,
    stock_received INT,
    damaged_stock INT,
    PRIMARY KEY (product_id, date),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);


CREATE TABLE marketing_performance (
    campaign_id INT PRIMARY KEY,
    campaign_name VARCHAR(100),
    date DATE,
    target_audience VARCHAR(100),
    channel VARCHAR(50),
    impressions INT,
    clicks INT,
    conversions INT,
    spend DECIMAL(10,2),
    revenue_generated DECIMAL(10,2),
    roas DECIMAL(5,2)
);


CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    name VARCHAR(100),
    role VARCHAR(50),
    hire_date DATE,
    store_id VARCHAR(10),
    email VARCHAR(100),
    phone VARCHAR(20),
    FOREIGN KEY (store_id) REFERENCES stores(store_id)
);


CREATE TABLE vendors (
    vendor_id SERIAL PRIMARY KEY,
    vendor_name VARCHAR(100),
    contact_person VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    region VARCHAR(100)
);

CREATE TABLE vendor_deliveries (
    vendor_delivery_id SERIAL PRIMARY KEY,
    product_id INT,
    vendor_id INT,
    store_id VARCHAR(10),
    delivery_date DATE,
    quantity_delivered INT,
    unit_cost DECIMAL(10,2),
    delivery_status VARCHAR(50),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (vendor_id) REFERENCES vendors(vendor_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id)
);

CREATE TABLE employee_schedule (
    schedule_id SERIAL PRIMARY KEY,
    employee_id INT,
    store_id VARCHAR(10),
    shift_date DATE,
    shift_type VARCHAR(50),  -- Morning, Afternoon, Night
    status VARCHAR(50),      -- Scheduled, Leave, Sick, Absent
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id)
);

