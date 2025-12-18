-- bulding RFM Analysis Table (Recency, Frequency, Monetaty)
/*
Using Table - final_clean_sales ,
creating RFM anlysis table named rfm_table
*/

-- finding the maximum Invoice Date
-- The RFM requires a reference date( the day after last transaction)

select max(InvoiceDate_dt) as last_date
from final_clean_sales;

-- creating RFM Table

create table rfm_table as
select 
	CustomerID,
    
    -- Recency: days since last perchase
    datediff('2011-03-16', max(InvoiceDate_dt)) as Recency,
    
    -- Frequency: number of uniqe invoices
    count(distinct InvoiceNo) as Frequency,
    
    -- Monetary: total Spending
    sum(TotalAmount) as Monetary
from final_clean_sales
group by CustomerID;

-- verifying rfm table
select * from rfm_table;

-- check how many customers 
select count(*) from rfm_table;

-- Now we add rfm Scores (1 to 5)

-- add new columns in table
alter table rfm_table
add column Recency_score int,
add column Frequency_score int,
add column Monetary_score int;

-- Calculate Recency_score
-- Lower Recency = More recent = Higher score
-- (5 is best , 1 is wrost)

-- creating temporary table with Recency buckets
with ranked as (
	select
		CustomerID,
        Recency,
        ntile(5) over(order by Recency desc) as r_bucket
	from rfm_table
)
update rfm_table r
join ranked t
on r.CustomerID = t.CustomerID
set r.Recency_score = t.r_bucket;

select * from rfm_table limit 5;

-- calculating Frequency_score
-- Higher Frequency = Better (5)

with ranked as (
	select
		CustomerID,
        Frequency,
        ntile(5) over(order by Frequency desc) as f_bucket
	from rfm_table
)
update rfm_table r
join ranked t 
on r.CustomerID = t.CustomerID
set r.Frequency_score = t.f_bucket;

select * from rfm_table limit 5;

-- Calculating Monetory_score
-- Higher Monetory = better

with ranked as (
	select 
		CustomerID,
        Monetary,
        ntile(5) over(order by Monetary desc) as m_bucket
	from rfm_table
)
update rfm_table r
join ranked t 
on r.CustomerID = t.CustomerID
set r.Monetary_score = t.m_bucket;

select * from rfm_table limit 5;

-- combine to final RFM score

alter table rfm_table
add column RFM_Score varchar(10);

update rfm_table
set RFM_Score = concat(Recency_score, Frequency_score, Monetary_score);

select * from rfm_table limit 5;

-- Adding segment names 
/*
Champions
loyal Customers
At- Risk
Hibernating
other
*/ 

alter table rfm_table
add column Segment varchar(50);

update rfm_table
set Segment = 
	case
		when Recency_score >=4 and Frequency_score >=4 and Monetary_score >=4 then 'Champions'
        when Recency_score >=4 and Frequency_score >= 3 then 'Loyal Customers'
        when Recency_score <= 2 and Frequency_score <=2 then 'Hibernating'
        when recency_score <=2 and Monetary_score >=3 then 'At Risk'
        else 'others'
	end;
        
select * from rfm_table limit 5;

with last_purchase as (
    select
        CustomerID,
        MAX(date_key) as last_purchase_key
    from fact_sales
    group by CustomerID
)
SELECT
    l.CustomerID,
    DATEDIFF((SELECT MAX(full_date) FROM dim_date),
             d.full_date) AS Recency
FROM last_purchase l
JOIN dim_date d ON l.last_purchase_key = d.date_key;
