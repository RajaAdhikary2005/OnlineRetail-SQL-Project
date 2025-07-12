-- ======================================
-- 1) INSERT TEST DATA
-- ======================================

USE OnlineRetail;

-- ---- Customers ----
INSERT INTO Customers (name, email, phone, address, region) VALUES
('Alice Johnson','alice@example.com','555-0100','12 Elm St','North'),
('Bob Smith','bob@example.com','555-0111','34 Oak Ave','South'),
('Carol Lee','carol@example.com','555-0222','56 Pine Rd','East'),
('David Kim','david@example.com','555-0333','78 Maple Blvd','West'),
('Eva Brown','eva@example.com','555-0444','90 Cedar Ln','North');

-- ---- Categories ----
INSERT INTO Categories (name, parent_id) VALUES
('Electronics', NULL),
('Phones', 1),
('Laptops', 1),
('Home', NULL),
('Kitchen', 4);

-- ---- Suppliers ----
INSERT INTO Suppliers (name, contact_email, phone, address) VALUES
('Acme Electronics','sales@acme.com','555-1000','100 Tech Park'),
('Global Gadgets','contact@ggadgets.com','555-2000','200 Innovation Way'),
('Home Goods Co','info@homegoods.com','555-3000','300 Comfort St');

-- ---- Products ----
INSERT INTO Products (name, category_id, supplier_id, price, stock) VALUES
('iPhone 14',        2, 1, 799.00, 50),
('Samsung Galaxy S23',2, 2, 699.00, 40),
('MacBook Air',      3, 1,1199.00, 30),
('Dell XPS 13',      3, 2,1099.00, 25),
('Blender Pro',      5, 3, 149.99, 60),
('Toaster Deluxe',   5, 3,  39.99, 80),
('LED TV 50"',       1, 2, 499.00, 20),
('Headphones X',     1, 1, 199.99,100),
('Coffee Maker',     5, 3,  89.99, 45),
('Smart Watch',      2, 2, 249.99, 55);

-- ---- Orders ----
INSERT INTO Orders (customer_id, order_date, ship_address, status) VALUES
(1,'2025-01-05','12 Elm St','Shipped'),
(2,'2025-01-15','34 Oak Ave','Completed'),
(3,'2025-02-10','56 Pine Rd','Pending'),
(4,'2025-02-20','78 Maple Blvd','Completed'),
(5,'2025-03-03','90 Cedar Ln','Shipped'),
(1,'2025-03-18','12 Elm St','Completed'),
(2,'2025-04-01','34 Oak Ave','Pending'),
(3,'2025-04-12','56 Pine Rd','Shipped');

-- ---- Order_Items ----
-- Order 1
INSERT INTO Order_Items VALUES
(1, 1, 1, 799.00),
(1, 8, 2, 199.99);
-- Order 2
INSERT INTO Order_Items VALUES
(2, 2, 1, 699.00),
(2,10, 1, 249.99);
-- Order 3
INSERT INTO Order_Items VALUES
(3, 3, 1,1199.00);
-- Order 4
INSERT INTO Order_Items VALUES
(4, 5, 2, 149.99),
(4, 6, 1,  39.99);
-- Order 5
INSERT INTO Order_Items VALUES
(5, 7, 1, 499.00),
(5, 9, 1,  89.99);
-- Order 6
INSERT INTO Order_Items VALUES
(6, 4, 1,1099.00),
(6,10, 1, 249.99);
-- Order 7
INSERT INTO Order_Items VALUES
(7, 8, 3, 199.99);
-- Order 8
INSERT INTO Order_Items VALUES
(8, 2, 2, 699.00),
(8, 1, 1, 799.00);

-- ---- Payments ----
INSERT INTO Payments (order_id, payment_date, amount, method) VALUES
(1,'2025-01-06',1198.98,'Credit Card'),  -- full
(2,'2025-01-16',948.99,'PayPal'),
(3,'2025-02-11',1199.00,'Credit Card'),
(4,'2025-02-21',339.97,'Credit Card'),
(5,'2025-03-04',588.99,'Bank Transfer'),
(6,'2025-03-19',1348.99,'Credit Card'),
(7,'2025-04-02',599.97,'PayPal'),
(8,'2025-04-13',2197.00,'Credit Card');

-- ---- Shipments ----
INSERT INTO Shipments (order_id, shipped_date, carrier, tracking_number) VALUES
(1,'2025-01-06','UPS','1Z999AA10123456784'),
(2,'2025-01-17','FedEx','123456789012'),
(4,'2025-02-22','USPS','940011089882502743'),
(5,'2025-03-05','DHL','JD014600004536279850'),
(6,'2025-03-20','UPS','1Z999AA10123456785'),
(8,'2025-04-14','FedEx','123456789013');

-- ---- Reviews ----
INSERT INTO Reviews (product_id, customer_id, rating, review_text, review_date) VALUES
(1,1,5,'Love the camera quality!','2025-01-10'),
(2,2,4,'Great phone but battery could be better.','2025-01-20'),
(3,3,5,'Super light and fast.','2025-02-15'),
(5,4,3,'Blends well but is a bit loud.','2025-02-25'),
(7,5,4,'Picture quality is sharp.','2025-03-10'),
(8,1,5,'Very comfortable over-ear design.','2025-03-22'),
(10,2,4,'Useful health tracking features.','2025-04-05'),
(4,1,4,'Solid laptop but pricey.','2025-04-20');

-- ======================================
SELECT revenue() AS total_revenue;

SELECT
  monthly_revenue(2025,1) AS rev_jan,
  monthly_revenue(2025,2) AS rev_feb,
  monthly_revenue(2025,3) AS rev_mar,
  monthly_revenue(2025,4) AS rev_apr;

SELECT avg_order_value() AS avg_order_value;

CALL top_n_customers(3);



