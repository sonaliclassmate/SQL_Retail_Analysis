-- Adjusting dataset

-- creating clean, unique Customer master table called as 'dimention table '

-- creating table - customer_dim
create table customer_dim as 
select 
	CustomerID,
    Country as Country
from final_clean_sales
where CustomerID is not null
group by 
	CustomerID,
    Country;

select * from cancelled_orders;
select count(*) from customer_dim;

-- creating table Product_dim
drop table if exists product_dim;
create table Product_dim as
select distinct
	StockCode,
    Description,
    UnitPrice
from final_clean_sales
where StockCode is not null 
	and Description is not null;
    
# adding product key column
alter table product_dim
add column product_key int;

set @row := 0;
update product_dim
set product_key = (@row := @row + 1)
order by StockCode, Description;

alter table product_dim
add primary key (product_key);


select * from Product_dim;
select count(*) from Product_dim;

-- creating Country_dim table

create table Country_dim as
select distinct
	Country
from final_clean_sales
where Country is not null
order by Country;

select * from Country_dim;
select count(*) from Country_dim;

-- creating Date_dim table

create table dim_date (
	date_key int primary key,
    full_date date,
    day int,
    month int,
    month_name varchar(20),
    quaeter int,
    year int,
    day_of_week int,
    day_name varchar(20),
    week_of_year int
);
alter table dim_date
rename column quaeter to quarter;
truncate table dim_date;
-- insert data into Date_dim table

-- get min and max dates from your fact table
select 
	min(InvoiceDate_dt) as min_date,
    max(InvoiceDate_dt) as max_date
from final_clean_sales;

-- generate data rows
insert into dim_date(
	date_key,
    full_date,
    day,
    month,
    month_name,
    quarter,
    year,
    day_of_week,
    day_name,
    week_of_year
)
with recursive data_series as(
	select date(min(InvoiceDate_dt)) as dt
    -- select date('2010-12-01') as dt
    from final_clean_sales
    union all
    select date_add(dt, interval 1 day)
    from data_series
    where dt < (select date(max(InvoiceDate_dt))/*select date('2011-03-16')*/ from final_clean_sales)
)
select 
	cast(date_format(dt, '%Y%m%d') as unsigned) as date_key,
    dt as full_date,
    day(dt) as day,
    month(dt) as month,
    monthname(dt) as month_name,
    quarter(dt) as quarter,
    year(dt) as year,
    dayofweek(dt) as day_of_week,
    dayname(dt) as day_name,
    week(dt, 3) as week_of_year
from data_series;

select count(*) from dim_date;
select min(full_date), max(full_date) from dim_date;
select * from dim_date limit 5;
-- checking version recursive queries runs on version 8.0 and further
show variables like "%versions%";
select version();

