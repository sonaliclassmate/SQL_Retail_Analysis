create database retail_project;
use retail_project;

-- create retail-row table
create table retail_raw (
	InvoiceNo varchar(20),
    StockCode varchar(20),
    Description text,
    Quantity int,
    InvoiceDate varchar(50),
    UnitPrice decimal(10,2),
    CustomerID int,
    Country varchar(100)
);
