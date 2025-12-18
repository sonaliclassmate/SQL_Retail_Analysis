-- creating clean table

-- check datatype of columns
describe retail_raw;
-- convert datatype of InvoiceDate to datetime
-- Right now InvoiceDate is varchar
-- 1. Add a new datetime column
alter table retail_raw
add column InvoiceDate_dt datetime;
-- 2. convert values into it
update retail_raw
set InvoiceDate_dt = STR_TO_DATE(InvoiceDate, '%d-%m-%Y %H:%i');
-- checking hex code of date . it should be - '30312D31322D323031302030383A3236'
select InvoiceDate, hex(InvoiceDate)
from retail_raw
limit 10;
-- trim if there unnessesary space is there
UPDATE retail_raw
SET InvoiceDate = TRIM(InvoiceDate);
-- convert - into - en dash
UPDATE retail_raw
SET InvoiceDate = REPLACE(InvoiceDate, '–', '-'); -- en dash
/*
SELECT InvoiceDate
FROM retail_raw
WHERE InvoiceDate_dt IS NULL;

update retail_raw
set InvoiceDate_dt = str_to_date(InvoiceDate, '%d-%m-%y %H:%i')
where InvoiceDate regexp '^[0-9]{2}-[0-9]{2}-[0-9]{4} [0-9]{2}:[0-9]{2}$';
*/
-- 3. check converstion
select InvoiceDate, InvoiceDate_dt
from retail_raw
limit 10;
-- remove column InvoiceDate
alter table retail_raw
drop column InvoiceDate;
-- Remove rows that are useless
-- 1. Remove rows with empty description
delete from retail_raw
where Description is null or trim(Description) = '';
-- 2. Remove price errors (0 or negative price)
delete from retail_raw
where UnitPrice <=0;

-- remove cancelled error
-- negative quantity = cancellation of order
-- insted of deleting we can store seperately.
create table cancelled_orders as
select * 
from retail_raw
where Quantity < 0;

select * from cancelled_orders; 
-- now remove negative orders from retail_raw table
delete from retail_raw
where Quantity < 0;

-- identify duplicates

-- find duplicate rows
select InvoiceNo, StockCode, Description, Quantity, InvoiceDate_dt, UnitPrice, CustomerID, Country,
count(*) as duplicate_count
from retail_raw
group by
InvoiceNo, StockCode, Description, Quantity, InvoiceDate_dt,UnitPrice,CustomerID,Country
having count(*) >1;

-- removing duplicates
-- we will create a cleaned version of retail_raw without duplicates

-- first creating temporary table
create table retail_no_duplicate as 
select distinct * 
from retail_raw;
-- check count of both talble
select count(*) from retail_no_duplicate; -- count - 78778
select count(*) from retail_raw; -- count - 79832
-- drop retail_raw table
drop table retail_raw;
-- rename table 'retail_no_duplicate' to 'retail_raw'
rename table retail_no_duplicate to retail_raw;

-- validating cleaned data

select
	sum(InvoiceNo is null) as Invoice_null,
    sum(StockCode is null) as StockCode_null,
    sum(Description is null) as Discription_null,
    sum(Quantity is null) as Quantity_null,
    sum(InvoiceDate is null) as InvoiceDate_null,
    sum(UnitPrice is null) as UnitPrice_null,
    sum(CustomerID is null) as CustomerID_null,
    sum(Country is null) as Country_null
from retail_raw;

-- check unexpected negative vallues
select * from retail_raw 
where quantity < 0;

-- check zero prices
select * from retail_raw 
where UnitPrice = 0;

-- check invalid country names
select distinct Country
from retail_raw
order by Country;
    
-- convert 'EIRE' to ireland  // EIRE is old name.
update retail_raw
set Country = "Ireland"
where Country = "EIRE";

-- remove rows with missing CustomerID. 
delete from retail_raw
where CustomerID is null;

select count(*) from retail_raw 
where CustomerID is null;

-- Add a computed field for TotalAmount 
select 
	Quantity,
    UnitPrice,
    (Quantity * UnitPrice) as TotalAmount
from retail_raw
limit 5;

-- creating retail_clean table
create table retail_clean as
select
	InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate_dt,
    UnitPrice,
    CustomerID,
    Country,
    (Quantity * UnitPrice) as TotalAmount
from retail_raw;

select * from retail_clean
limit 5;

-- performing validation check on retail_clean

-- 1. check row count matches expections
select count(*) from retail_clean;
-- 2. Check totalAmount correctness
select Quantity, UnitPrice, TotalAmount
from retail_clean
limit 10;
-- 3. check no negative or zero quantities
select * from retail_clean
where quantity <= 0;
-- 4. check no zero or negative values
select * from retail_clean 
where UnitPrice <=0;
-- 5. verify all dates are valid
select * from retail_clean
where InvoiceDate_dt is null; 
-- 6. check distinct countries
select distinct Country
from retail_clean
order by Country;

-- creating table ' retail_clean_with_customer'
/*
contains only records where CustomerID is NOT NULL
used for: 
	* RFM analysis
    * Customer Segmentation
    * CLV
    * Cohort analysis
*/
create table retail_clean_with_customer as
select *
from retail_clean
where CustomerID is not null;

select count(*) from retail_clean_with_customer;
-- creating table ' retail_clean_all_sales'
/*
Contains ALL rows, including missing CustomerID.
Used for:
	Total sales
	Product analysis
	Monthly revenue
	Top-selling items
	Inventory
	Cancellation rates
*/
create table retail_clean_all_sales as
select *
from retail_clean;
select count(*) from retail_clean_all_sales;
 
 -- ===========================================================
 select count(*) from cancelled_orders;
  select * from cancelled_orders;

describe cancelled_orders;
-- Standardize country names
UPDATE cancelled_orders
SET Country = 'Ireland'
WHERE Country = 'EIRE';
-- Trim and clean description
UPDATE cancelled_orders
SET Description = TRIM(Description)
WHERE Description IS NOT NULL;
-- set 0 to  NULL CustomerID if you want
UPDATE cancelled_orders
SET CustomerID = 0
WHERE CustomerID IS NULL;

 -- ==============================================================

-- creating ' cancelled_orders' table and 'final_clean_sales'(no cancellation)
/*
In the Online Retail dataset:

Cancelled invoices start with "C" (like: C536379)

The quantities in cancelled invoices are negative

You should not include cancelled orders in sales reports
(but you should keep them for refund analytics)
so we create two tables
*/
-- create the final sales table without cancellations
DROP TABLE IF EXISTS final_clean_sales;

CREATE TABLE final_clean_sales AS
SELECT *
FROM retail_clean_all_sales
WHERE Quantity >= 0;
select * from final_clean_sales;
select count(*) from final_clean_sales;
