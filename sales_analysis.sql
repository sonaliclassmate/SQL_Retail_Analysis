-- ______________SALES ANALYSIS____________________

select * from fact_sales limit 5;
-- 1. Total sales Summary
-- Total Revenue, Total Orders, Total Quantity
select 
	sum(fs.TotalAmount) as Total_Revenue,
    count(distinct(fs.InvoiceNo)) as Total_Orders,
    sum(fs.Quantity) as Total_Quantity
from fact_sales fs;

-- 2. sales by country
-- show revenue, orders, customers by country
select
	cd.country,
    sum(fs.TotalAmount) as Revenue,
    count(distinct(fs.InvoiceNo)) as Orders,
    count(distinct(fs.CustomerID)) as Cusromers
from fact_sales fs
join country_dim cd 
on fs.Country = cd.Country
group by cd.Country
order by Revenue desc;

-- 3. Sales by Monnth
-- show year, month and monthly revenue

select
	dd.year,
    dd.month,
    sum(fs.TotalAmount) as Monthly_Revenue
from fact_sales fs
join dim_date dd
on fs.date_key = dd.date_key
group by dd.year, dd.month
order by dd.year, dd.month;
-- daily Sales trend
select
	dd.full_date,
    sum(fs.TotalAmount) as daily_sales
from fact_sales fs
join dim_date dd
	on dd.date_key = fs.date_key
group by dd.full_date
order by dd.full_date;

-- Quarterly Revenue
select
	dd.year,
    dd.quarter,
    sum(fs.TotalAmount) as Total_sales
from fact_sales fs
join dim_date dd
	on dd.date_key = fs.date_key
group by dd.year, dd.quarter
order by dd.year, dd.quarter;

-- weekday vs weekend analysis
select
	dd.day_name,
    sum(fs.TotalAmount) as Total_sales
from fact_sales fs
join dim_date dd
	on dd.date_key = fs.date_key
group by dd.day_name
order by field(dd.day_name, 'Monday','Tuesday', 'Wednesday','Thursday', 'Friday','Saturday', 'Sunday');

-- sales heatmap by week and day
select
	dd.week_of_year,
    dd.day_name,
    sum(fs.TotalAmount)
from fact_sales fs
join dim_date dd
	on dd.date_key = fs.date_key
group by dd.week_of_year, dd.day_name
order by dd.week_of_year;


-- 4. top 10 products by revenue
select * from product_dim;
select
	pd.StockCode,
    pd.Description,
    sum(fs.TotalAmount) as Revenue
from fact_sales fs
join product_dim pd 
	on fs.StockCode = pd.StockCode
group by pd.StockCode, pd.Description
order by revenue desc
limit 10;

-- 5. Customer-Level Sales Summary
select * from customer_dim;
select
	cd.CustomerID,
    count(distinct( fs.InvoiceNo)) as Total_orders,
    sum(fs.TotalAmount) as Total_Spent,
    max(fs.InvoiceDate_dt) as Last_Purchase_Date
from fact_sales fs
join customer_dim cd
	on fs.CustomerID = cd.CustomerID
group by cd.CustomerID
order by Total_spent desc;

-- 6. Daly Sales Trend
select 
	dd.full_date,
    sum(TotalAmount) as Daily_revenue
from fact_sales fs
join dim_date dd
	on fs.date_key = dd.date_key
group by dd.full_date
order by dd.full_date;

-- 7. Average order value 
select
	 sum(TotalAmount) / count(distinct(InvoiceNo)) as AOV
from fact_sales;

-- 8. Revenue Contribution by top 20% Customers (Pareto)
with 
CustomerRevenue as
	(-- Calculate Total revenue per Customer.
	select 
		CustomerID,
		sum(TotalAmount) as Total_Revenue
	from fact_sales
	group by CustomerID
    ),
	RankRevenue as 
    (-- Rank Customer by revennue and commulative Distribution. 
	select
		CustomerID,
		Total_Revenue,
		-- cume_dist
		cume_dist() over(order by Total_Revenue desc) as customer_cume_dist_percentage,
		-- calculate running total of revenue
		sum(Total_Revenue) over(order by Total_Revenue desc 
		rows between unbounded preceding and current row) as running_revenue_total
	from CustomerRevenue
    ),
    G_TotalRevenue as 
    (-- calculate grand total revenue across all cutomers
    select
		sum(Total_Revenue) as grand_total_revenue
	from CustomerRevenue
    )
    -- final selection to find 20% of customer revenue distribution.
    select 
		count(rr.CustomerID) as top_20_percent_customer_count,
        sum(rr.Total_Revenue) as top_20_percent_Revenue,
        (sum(rr.Total_Revenue)* 100.0 / gtr.grand_total_revenue) as Revenue_Contribution_Percentage
	from RankRevenue rr
    cross join G_TotalRevenue gtr
    where 
		rr.customer_cume_dist_percentage <=0.20
	group by 
		gtr.grand_total_revenue;
        
-- 9. calculate most returned products
select 
	pd.StockCode,
    pd.Description,
    sum(
    case
    when co.Quantity < 0 then 1
    else 0
    end
    ) as returned_products
from cancelled_orders co
join product_dim pd
	on co.StockCode = pd.StockCode
group by pd.StockCode, pd.Description
order by returned_products desc
limit 10;

-- 10. Repeate vs New Customer

with first_purchase as(
	select 
		CustomerID,
        min(InvoiceDate_dt) as first_date
	from fact_sales
    group by CustomerID
)
select 
	case
    when fp.first_date = fs.InvoiceDate_dt then 'new customer'
    else 'repeate customer'
    end as customer_type,
    count(distinct(fs.CustomerID)) as customers,
    sum(fs.TotalAmount) as revenue
from fact_sales fs
join first_purchase fp
	on fs.CustomerID = fp.CustomerID
group by customer_type;


    


	