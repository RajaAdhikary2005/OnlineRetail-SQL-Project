-- /schema/create_tables_and_routines.sql
-- Drop and recreate database
DROP DATABASE IF EXISTS OnlineRetail;
CREATE DATABASE OnlineRetail;
USE OnlineRetail;

-- ==========================
-- TABLE DEFINITIONS
-- ==========================

-- Customers Table
DROP TABLE IF EXISTS Customers;
CREATE TABLE Customers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) UNIQUE NOT NULL,
  phone VARCHAR(20),
  address VARCHAR(255),
  region VARCHAR(50),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Categories Table (hierarchy)
DROP TABLE IF EXISTS Categories;
CREATE TABLE Categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  parent_id INT NULL,
  FOREIGN KEY (parent_id) REFERENCES Categories(id)
) ENGINE=InnoDB;

-- Suppliers Table
DROP TABLE IF EXISTS Suppliers;
CREATE TABLE Suppliers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  contact_email VARCHAR(150),
  phone VARCHAR(20),
  address VARCHAR(255)
) ENGINE=InnoDB;

-- Products Table
DROP TABLE IF EXISTS Products;
CREATE TABLE Products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  category_id INT NOT NULL,
  supplier_id INT,
  price DECIMAL(10,2) NOT NULL,
  stock INT DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES Categories(id),
  FOREIGN KEY (supplier_id) REFERENCES Suppliers(id)
) ENGINE=InnoDB;

-- Orders Table
DROP TABLE IF EXISTS Orders;
CREATE TABLE Orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  order_date DATE NOT NULL,
  ship_address VARCHAR(255),
  status VARCHAR(50) DEFAULT 'Pending',
  FOREIGN KEY (customer_id) REFERENCES Customers(id)
) ENGINE=InnoDB;

-- Order_Items Table
DROP TABLE IF EXISTS Order_Items;
CREATE TABLE Order_Items (
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (order_id, product_id),
  FOREIGN KEY (order_id) REFERENCES Orders(id),
  FOREIGN KEY (product_id) REFERENCES Products(id)
) ENGINE=InnoDB;

-- Payments Table
DROP TABLE IF EXISTS Payments;
CREATE TABLE Payments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  payment_date DATE,
  amount DECIMAL(12,2) NOT NULL,
  method VARCHAR(50),
  FOREIGN KEY (order_id) REFERENCES Orders(id)
) ENGINE=InnoDB;

-- Shipments Table
DROP TABLE IF EXISTS Shipments;
CREATE TABLE Shipments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  shipped_date DATE,
  carrier VARCHAR(100),
  tracking_number VARCHAR(100),
  FOREIGN KEY (order_id) REFERENCES Orders(id)
) ENGINE=InnoDB;

-- Reviews Table
DROP TABLE IF EXISTS Reviews;
CREATE TABLE Reviews (
  id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  customer_id INT NOT NULL,
  rating TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  review_text TEXT,
  review_date DATE,
  FOREIGN KEY (product_id) REFERENCES Products(id),
  FOREIGN KEY (customer_id) REFERENCES Customers(id)
) ENGINE=InnoDB;

-- ==========================
-- STORED FUNCTIONS & PROCEDURES
-- ==========================

-- Function: revenue()
-- Usage: SELECT revenue();
DROP FUNCTION IF EXISTS revenue;
CREATE FUNCTION revenue()
RETURNS DECIMAL(12,2) DETERMINISTIC
BEGIN
  DECLARE total DECIMAL(12,2);
  SELECT SUM(quantity * price) INTO total
    FROM Order_Items;
  RETURN IFNULL(total, 0);
END;

-- Function: monthly_revenue(year, month)
-- Usage: SELECT monthly_revenue(2024, 11);
DROP FUNCTION IF EXISTS monthly_revenue;
CREATE FUNCTION monthly_revenue(
  in_year INT,
  in_month INT
) RETURNS DECIMAL(12,2) DETERMINISTIC
BEGIN
  DECLARE total DECIMAL(12,2);
  SELECT SUM(oi.quantity * oi.price) INTO total
    FROM Orders o
    JOIN Order_Items oi ON o.id = oi.order_id
    WHERE YEAR(o.order_date)=in_year
      AND MONTH(o.order_date)=in_month;
  RETURN IFNULL(total, 0);
END;

-- Function: avg_order_value()
-- Usage: SELECT avg_order_value();
DROP FUNCTION IF EXISTS avg_order_value;
CREATE FUNCTION avg_order_value()
RETURNS DECIMAL(12,2) DETERMINISTIC
BEGIN
  DECLARE avg_val DECIMAL(12,2);
  SELECT AVG(order_total) INTO avg_val
    FROM (
      SELECT SUM(quantity * price) AS order_total
      FROM Order_Items
      GROUP BY order_id
    ) sub;
  RETURN IFNULL(avg_val, 0);
END;

-- Procedure: top_n_customers(n)
-- Usage: CALL top_n_customers(5);
DROP PROCEDURE IF EXISTS top_n_customers;
CREATE PROCEDURE top_n_customers(
  IN n INT
)
BEGIN
  SELECT c.id AS customer_id,
         c.name,
         SUM(oi.quantity * oi.price) AS total_spent
  FROM Customers c
  JOIN Orders o ON c.id = o.customer_id
  JOIN Order_Items oi ON o.id = oi.order_id
  GROUP BY c.id
  ORDER BY total_spent DESC
  LIMIT n;
END;

-- Procedure: insert_customer(...)
-- Usage: CALL insert_customer('Jane','j@example.com','555-1234','456 Oak St','West');
DROP PROCEDURE IF EXISTS insert_customer;
CREATE PROCEDURE insert_customer(
  IN p_name VARCHAR(100),
  IN p_email VARCHAR(150),
  IN p_phone VARCHAR(20),
  IN p_address VARCHAR(255),
  IN p_region VARCHAR(50)
)
BEGIN
  INSERT INTO Customers(name,email,phone,address,region)
    VALUES(p_name,p_email,p_phone,p_address,p_region);
END;

-- Procedure: insert_order(...)
-- Usage: CALL insert_order(1,'2025-01-10','123 Main St');
DROP PROCEDURE IF EXISTS insert_order;
CREATE PROCEDURE insert_order(
  IN p_cust_id INT,
  IN p_order_date DATE,
  IN p_ship_address VARCHAR(255)
)
BEGIN
  INSERT INTO Orders(customer_id,order_date,ship_address)
    VALUES(p_cust_id,p_order_date,p_ship_address);
END;

-- Procedure: add_order_item(...)
-- Usage: CALL add_order_item(10,7,2,19.99);
DROP PROCEDURE IF EXISTS add_order_item;
CREATE PROCEDURE add_order_item(
  IN p_order_id INT,
  IN p_product_id INT,
  IN p_quantity INT,
  IN p_price DECIMAL(10,2)
)
BEGIN
  INSERT INTO Order_Items(order_id,product_id,quantity,price)
    VALUES(p_order_id,p_product_id,p_quantity,p_price);
END;

-- Procedure: show_commands()
-- Usage: CALL show_commands();
-- Lists all available commands
DROP PROCEDURE IF EXISTS show_commands;
CREATE PROCEDURE show_commands()
BEGIN
  SELECT 'SELECT revenue()' AS command, 'Return total revenue' AS description
  UNION ALL SELECT 'SELECT monthly_revenue(year,month)','Revenue for given year & month'
  UNION ALL SELECT 'SELECT avg_order_value()','Average order value'
  UNION ALL SELECT 'CALL top_n_customers(N)','Top N customers by spend'
  UNION ALL SELECT 'CALL insert_customer(...)','Insert a new customer'
  UNION ALL SELECT 'CALL insert_order(...)','Insert a new order'
  UNION ALL SELECT 'CALL add_order_item(...)','Add an item to an order';
END;


CALL show_commands();


