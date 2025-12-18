-- creating fact table named fact_sales
drop table if exists fact_sales;

create table fact_sales as
select 
    InvoiceNo,
    InvoiceDate_dt,
    CustomerID,
    StockCode,
    Description,
    Country,
    Quantity,
    UnitPrice,
    TotalAmount,
    InvoiceYear,
    InvoiceMonth,
    InvoiceDay,
    InvoiceQuarter
from final_clean_sales;

select * from fact_sales;
select count(*) from fact_sales;

-- add column date_key in fact table
alter table fact_sales
add column date_key int;

update fact_sales
set date_key = cast(date_format(InvoiceDate_dt, '%Y%m%d') as unsigned);

alter table fact_sales
add column product_key int;

-- not run yet
update fact_sales f
join product_dim p 
	on f.StockCode = p.StockCode
set f.product_key = p.product_key;




