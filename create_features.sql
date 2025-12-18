 -- Adding analysis columns to final_clean_sales table.alter
 
 /*
 Adding InvoiceYear,
		InvoiceMonth,
        InvoiceDay,
        InvoiceQuarter
 */
 
 alter table final_clean_sales
 add column InvoiceYear int,
 add column InvoiceMonth int,
 add column InvoiceDay int,
 add column InvoiceQuarter int;
 
update final_clean_sales
set
	InvoiceYear = year(InvoiceDate_dt),
    InvoiceMonth = month(InvoiceDate_dt),
    InvoiceDay = day(InvoiceDate_dt),
    InvoiceQuarter = quarter(InvoiceDate_dt);
 