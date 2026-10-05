-- ====================================================================
-- BÀI TẬP: VIEW, INDEX, STORED PROCEDURE
-- CSDL: demo | Bảng: Products
-- ====================================================================

-- --------------------------------------------------------------------
-- BƯỚC 1 & 2: KHỞI TẠO CƠ SỞ DỮ LIỆU VÀ BẢNG PRODUCTS KÈM DỮ LIỆU MẪU
-- --------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS demo;
USE demo;

DROP TABLE IF EXISTS Products;
CREATE TABLE Products (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    productCode VARCHAR(20) NOT NULL,
    productName VARCHAR(100) NOT NULL,
    productPrice DECIMAL(12, 2) NOT NULL,
    productAmount INT NOT NULL DEFAULT 0,
    productDescription TEXT,
    productStatus VARCHAR(20) DEFAULT 'Active'
);

-- Thêm dữ liệu mẫu
INSERT INTO Products (productCode, productName, productPrice, productAmount, productDescription, productStatus)
VALUES 
    ('P001', 'Bàn phím cơ DareU EK87', 450000.00, 50, 'Bàn phím cơ TKL Red Switch', 'Active'),
    ('P002', 'Chuột không dây Logitech G304', 750000.00, 30, 'Chuột gaming Lightspeed', 'Active'),
    ('P003', 'Màn hình LG 27 inch 4K', 7200000.00, 15, 'Màn hình chuyên đồ họa IPS', 'Active'),
    ('P004', 'Tai nghe Sony WH-1000XM4', 5900000.00, 20, 'Tai nghe chống ồn chủ động', 'Active'),
    ('P005', 'Lót chuột Corsair MM300', 350000.00, 100, 'Lót chuột size Extended', 'Inactive');


-- --------------------------------------------------------------------
-- BƯỚC 3: TẠO VÀ ĐÁNH GIÁ CHỈ MỤC (INDEX)
-- --------------------------------------------------------------------

-- 3.1. So sánh trước và sau khi có Unique Index trên cột productCode:
-- Phân tích TRƯỚC khi tạo Index (type = 'ALL', quét toàn bộ các hàng)
EXPLAIN SELECT * FROM Products WHERE productCode = 'P002';

-- Tạo Unique Index
ALTER TABLE Products ADD UNIQUE INDEX idx_product_code(productCode);

-- Phân tích SAU khi tạo Unique Index (type = 'const', rows = 1)
EXPLAIN SELECT * FROM Products WHERE productCode = 'P002';


-- 3.2. So sánh trước và sau khi có Composite Index trên productName & productPrice:
-- Phân tích TRƯỚC khi có Composite Index (type = 'ALL')
EXPLAIN SELECT * FROM Products WHERE productName = 'Chuột không dây Logitech G304' AND productPrice = 750000.00;

-- Tạo Composite Index
ALTER TABLE Products ADD INDEX idx_name_price(productName, productPrice);

-- Phân tích SAU khi tạo Composite Index (type = 'ref', rows = 1)
EXPLAIN SELECT * FROM Products WHERE productName = 'Chuột không dây Logitech G304' AND productPrice = 750000.00;


-- --------------------------------------------------------------------
-- BƯỚC 4: LÀM VIỆC VỚI VIEW
-- --------------------------------------------------------------------

-- 4.1. Tạo View lấy productCode, productName, productPrice, productStatus
CREATE OR REPLACE VIEW view_products AS
SELECT productCode, productName, productPrice, productStatus
FROM Products;

-- Truy vấn kiểm tra View
SELECT * FROM view_products;

-- 4.2. Tiến hành sửa đổi View (chỉ lấy các sản phẩm có trạng thái 'Active')
CREATE OR REPLACE VIEW view_products AS
SELECT productCode, productName, productPrice, productStatus
FROM Products
WHERE productStatus = 'Active';

-- Kiểm tra lại View sau khi cập nhật
SELECT * FROM view_products;

-- 4.3. Tiến hành xoá View
DROP VIEW IF EXISTS view_products;


-- --------------------------------------------------------------------
-- BƯỚC 5: TẠO CÁC STORED PROCEDURE
-- --------------------------------------------------------------------

DELIMITER //

-- 5.1. SP lấy tất cả thông tin của tất cả sản phẩm
DROP PROCEDURE IF EXISTS sp_getAllProducts //
CREATE PROCEDURE sp_getAllProducts()
BEGIN
    SELECT * FROM Products;
END //

-- 5.2. SP thêm một sản phẩm mới
DROP PROCEDURE IF EXISTS sp_addProduct //
CREATE PROCEDURE sp_addProduct(
    IN p_code VARCHAR(20),
    IN p_name VARCHAR(100),
    IN p_price DECIMAL(12, 2),
    IN p_amount INT,
    IN p_desc TEXT,
    IN p_status VARCHAR(20)
)
BEGIN
    INSERT INTO Products (productCode, productName, productPrice, productAmount, productDescription, productStatus)
    VALUES (p_code, p_name, p_price, p_amount, p_desc, p_status);
END //

-- 5.3. SP sửa thông tin sản phẩm theo id
DROP PROCEDURE IF EXISTS sp_updateProductById //
CREATE PROCEDURE sp_updateProductById(
    IN p_id INT,
    IN p_name VARCHAR(100),
    IN p_price DECIMAL(12, 2),
    IN p_amount INT,
    IN p_desc TEXT,
    IN p_status VARCHAR(20)
)
BEGIN
    UPDATE Products
    SET 
        productName = p_name,
        productPrice = p_price,
        productAmount = p_amount,
        productDescription = p_desc,
        productStatus = p_status
    WHERE Id = p_id;
END //

-- 5.4. SP xoá sản phẩm theo id
DROP PROCEDURE IF EXISTS sp_deleteProductById //
CREATE PROCEDURE sp_deleteProductById(IN p_id INT)
BEGIN
    DELETE FROM Products WHERE Id = p_id;
END //

DELIMITER ;


-- --------------------------------------------------------------------
-- KIỂM THỬ GỌI TẤT CẢ CÁC STORED PROCEDURE
-- --------------------------------------------------------------------

-- Lấy danh sách ban đầu
CALL sp_getAllProducts();

-- Thêm sản phẩm mới P006
CALL sp_addProduct('P006', 'Giá đỡ laptop nhôm Orico', 220000.00, 45, 'Hợp kim nhôm gấp gọn', 'Active');
CALL sp_getAllProducts();

-- Cập nhật thông tin sản phẩm có Id = 1
CALL sp_updateProductById(1, 'Bàn phím cơ DareU EK87 v2 (Updated)', 490000.00, 40, 'Bản nâng cấp switch Kailh', 'Active');
CALL sp_getAllProducts();

-- Xoá sản phẩm có Id = 5
CALL sp_deleteProductById(5);
CALL sp_getAllProducts();