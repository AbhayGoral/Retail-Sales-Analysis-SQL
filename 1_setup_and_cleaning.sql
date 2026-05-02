
-- Project: Retail Sales Analysis
-- File: 1_setup_and_cleaning.sql

-- Description:
-- This file contains database creation, table setup,
-- data cleaning (NULL handling, duplicates removal),data validation

-- Key Tasks:
-- - Create database and table
-- - Handle missing values
-- - Remove invalid records
-- - Validate data consistency
-- - Create indexes for optimization

-- Note:
-- Dataset contains ~2000 records. Designed with scalability in mind for larger datasets.

-- Author: Abhay Goral
-- =========================================

--CREATING DATABASE
CREATE DATABASE retailsalesdb;


--CREATING TABLE
CREATE TABLE retail_sales(
	transaction_id INT PRIMARY KEY,
	sale_date DATE,
	sale_time TIME,
	customer_id INT,
	gender VARCHAR(15),
	age INT,
	category VARCHAR(15),
	quantity INT,
	price_per_unit FLOAT,
	cogs FLOAT ,
	total_sale FLOAT	
);

SELECT*FROM retail_sales;

-- COUNTING TOTAL ROWS
SELECT COUNT(*) TOTAL_ROWS FROM retail_sales ;

--DATA CLEANING

--FIRST CHECKING NULL VALUES
SELECT * FROM retail_sales
WHERE 
	transaction_id IS NULL 
	OR sale_date IS NULL 
	OR sale_time IS NULL 
	OR customer_id IS NULL 
	OR gender IS NULL 
	OR age IS NULL 
	OR category IS NULL 
	OR quantity IS NULL 
	OR price_per_unit IS NULL 
	OR cogs IS NULL 
	OR total_sale IS NULL;

--THERE ARE 14 ROWS WHICH HAS SOME NULL VALUES 
-- WE WILL FILL NULL VALUES IN age COLUMN BY AVG AGE

UPDATE retail_sales
SET age = (
    SELECT AVG(age) 
    FROM retail_sales 
    WHERE age IS NOT NULL
)
WHERE age IS NULL;

SELECT*FROM retail_sales;

--NOW AGAIN CHECKING FOR NULL VALUES
SELECT * FROM retail_sales
WHERE 
	transaction_id IS NULL 
	OR sale_date IS NULL 
	OR sale_time IS NULL 
	OR customer_id IS NULL 
	OR gender IS NULL 
	OR age IS NULL 
	OR category IS NULL 
	OR quantity IS NULL 
	OR price_per_unit IS NULL 
	OR cogs IS NULL 
	OR total_sale IS NULL;

--NOW ONLY 3 ROWS HAVE NULL VALUES SO WE WILL DELETE THESE 3 RECORDS
DELETE FROM retail_sales
WHERE 
	transaction_id IS NULL 
	OR sale_date IS NULL 
	OR sale_time IS NULL 
	OR customer_id IS NULL 
	OR gender IS NULL 
	OR age IS NULL 
	OR category IS NULL 
	OR quantity IS NULL 
	OR price_per_unit IS NULL 
	OR cogs IS NULL 
	OR total_sale IS NULL;


SELECT * FROM retail_sales;

--AGAIN CHECKING FOR NULL RECORDS
SELECT * FROM retail_sales
WHERE 
	transaction_id IS NULL 
	OR sale_date IS NULL 
	OR sale_time IS NULL 
	OR customer_id IS NULL 
	OR gender IS NULL 
	OR age IS NULL 
	OR category IS NULL 
	OR quantity IS NULL 
	OR price_per_unit IS NULL 
	OR cogs IS NULL 
	OR total_sale IS NULL;

--SO WE FOUND 0 NULL RECORDS

--Duplicate Check
-- Check duplicate transaction IDs
SELECT transaction_id, COUNT(*)
FROM retail_sales
GROUP BY transaction_id
HAVING COUNT(*) > 1;

--WE found 0 duplicate records 
--We writing query if incase we have duplicates
 Remove duplicates 
DELETE FROM retail_sales
WHERE transaction_id IN (
    SELECT transaction_id
    FROM (
        SELECT transaction_id,
               ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY transaction_id) AS rn
        FROM retail_sales
    ) t
    WHERE rn > 1
);


--Detecting Outliers in age column

SELECT *
FROM retail_sales
WHERE age < 10 OR age > 100;
--WE found 0 outliers
--We writing query to replace if we have outliers 
UPDATE retail_sales
SET age = (
    SELECT AVG(age) FROM retail_sales
)
WHERE age < 10 OR age > 100;

--Checking negative values OR 0 values

SELECT *
FROM retail_sales
WHERE quantity <= 0 
   OR price_per_unit <= 0
   OR total_sale <= 0;
--There is no negative value or 0 value
--This query for fixing negative values incase if we have
DELETE FROM retail_sales
WHERE quantity <= 0 
   OR price_per_unit <= 0
   OR total_sale <= 0;

--Data validation
--Checking if total sale matches quantity*price
SELECT *
FROM retail_sales
WHERE total_sale <> quantity * price_per_unit;
--Query to fix it
UPDATE retail_sales
SET total_sale = quantity * price_per_unit
WHERE total_sale <> quantity * price_per_unit;



--CREATING INDEXES 
--We will create index for some columns that requires frequently like sale_date,customer_id
CREATE INDEX idx_sale_date ON retail_sales(sale_date);
CREATE INDEX idx_customer_id ON retail_sales(customer_id);
