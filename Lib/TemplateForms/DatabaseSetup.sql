-- ============================================================================
-- Database Setup Scripts for FireMonkey Template Forms
-- ============================================================================
-- This file contains example SQL scripts for creating tables compatible
-- with the TemplateForm framework
-- ============================================================================

-- ----------------------------------------------------------------------------
-- SQLite Example
-- ----------------------------------------------------------------------------
-- Create a simple customer table with UIJSON field
CREATE TABLE IF NOT EXISTS Customers (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    UIJSON TEXT,
    CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Create trigger to update ModifiedDate
CREATE TRIGGER IF NOT EXISTS update_customers_timestamp 
AFTER UPDATE ON Customers
BEGIN
    UPDATE Customers SET ModifiedDate = CURRENT_TIMESTAMP WHERE ID = NEW.ID;
END;

-- ----------------------------------------------------------------------------
-- Microsoft SQL Server Example
-- ----------------------------------------------------------------------------
-- Create a customer table with UIJSON field
/*
CREATE TABLE Customers (
    ID INT PRIMARY KEY IDENTITY(1,1),
    UIJSON VARCHAR(4000),
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE()
);

-- Create trigger to update ModifiedDate
CREATE TRIGGER trg_UpdateCustomersTimestamp
ON Customers
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Customers
    SET ModifiedDate = GETDATE()
    FROM Customers c
    INNER JOIN inserted i ON c.ID = i.ID;
END;
GO
*/

-- ----------------------------------------------------------------------------
-- MySQL Example
-- ----------------------------------------------------------------------------
-- Create a customer table with UIJSON field
/*
CREATE TABLE IF NOT EXISTS Customers (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    UIJSON TEXT,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
*/

-- ----------------------------------------------------------------------------
-- PostgreSQL Example
-- ----------------------------------------------------------------------------
-- Create a customer table with UIJSON field
/*
CREATE TABLE IF NOT EXISTS Customers (
    ID SERIAL PRIMARY KEY,
    UIJSON TEXT,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create function to update ModifiedDate
CREATE OR REPLACE FUNCTION update_modified_date()
RETURNS TRIGGER AS $$
BEGIN
    NEW.ModifiedDate = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to update ModifiedDate
CREATE TRIGGER trg_update_customers_timestamp
BEFORE UPDATE ON Customers
FOR EACH ROW
EXECUTE FUNCTION update_modified_date();
*/

-- ----------------------------------------------------------------------------
-- Oracle Example
-- ----------------------------------------------------------------------------
-- Create a customer table with UIJSON field
/*
CREATE TABLE Customers (
    ID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    UIJSON CLOB,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create trigger to update ModifiedDate
CREATE OR REPLACE TRIGGER trg_update_customers_timestamp
BEFORE UPDATE ON Customers
FOR EACH ROW
BEGIN
    :NEW.ModifiedDate := CURRENT_TIMESTAMP;
END;
/
*/

-- ----------------------------------------------------------------------------
-- Sample Data Inserts
-- ----------------------------------------------------------------------------
-- Insert sample customer with UIJSON data
INSERT INTO Customers (UIJSON) VALUES (
    '{"EditCustomerName":"John Doe","EditEmail":"john@example.com","EditPhone":"+90 555 123 4567","MemoNotes":"Important customer","CheckBoxActive":true,"DateEditRegistration":"18.02.2026","NumberBoxAge":35,"ComboBoxCity":"Istanbul","SpinBoxRating":5,"RadioButtonMale":true,"RadioButtonFemale":false,"TimeEditPreferredContactTime":"14:30:00"}'
);

INSERT INTO Customers (UIJSON) VALUES (
    '{"EditCustomerName":"Jane Smith","EditEmail":"jane@example.com","EditPhone":"+90 555 987 6543","MemoNotes":"VIP customer","CheckBoxActive":true,"DateEditRegistration":"15.01.2026","NumberBoxAge":28,"ComboBoxCity":"Ankara","SpinBoxRating":9,"RadioButtonMale":false,"RadioButtonFemale":true,"TimeEditPreferredContactTime":"10:00:00"}'
);

INSERT INTO Customers (UIJSON) VALUES (
    '{"EditCustomerName":"Ali Veli","EditEmail":"ali@example.com","EditPhone":"+90 555 111 2222","MemoNotes":"Regular customer","CheckBoxActive":true,"DateEditRegistration":"01.03.2026","NumberBoxAge":42,"ComboBoxCity":"Izmir","SpinBoxRating":7,"RadioButtonMale":true,"RadioButtonFemale":false,"TimeEditPreferredContactTime":"16:00:00"}'
);

-- ----------------------------------------------------------------------------
-- Query Examples
-- ----------------------------------------------------------------------------
-- Select all customers
SELECT ID, 
       json_extract(UIJSON, '$.EditCustomerName') as CustomerName,
       json_extract(UIJSON, '$.EditEmail') as Email,
       CreatedDate
FROM Customers;

-- Select active customers only (SQLite with JSON extension)
SELECT ID, UIJSON
FROM Customers
WHERE json_extract(UIJSON, '$.CheckBoxActive') = 'true';

-- Update UIJSON for a specific customer
UPDATE Customers 
SET UIJSON = '{"EditCustomerName":"John Doe Updated","EditEmail":"john.new@example.com"}'
WHERE ID = 1;

-- Delete a customer
DELETE FROM Customers WHERE ID = 1;

-- Count total customers
SELECT COUNT(*) as TotalCustomers FROM Customers;
