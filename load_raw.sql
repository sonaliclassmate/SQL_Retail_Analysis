-- load onlineRetail file in load_raw 
load data infile "F:/Msc Data Science/SQL_RETAIL_PROJECT/Online Retail.csv"
into table retail_raw
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;


show variables like 'secure_file_priv';

select * from retail_raw;
-- count records
select count(*) from retail_raw;
-- check columns
select * from retail_raw limit 20;
-- checking missing customer_ID
select count(*) as missing_CustomerID
from retail_raw
where CustomerID is null;
-- check negative quantities
select count(*) as negative_quantity
from retail_raw
where Quantity < 0;