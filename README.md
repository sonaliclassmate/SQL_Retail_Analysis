# 🛒 Online Retail Analysis using SQL
## 📌 Project Overview
This project performs **end-to-end retail data analysis** using the **Online Retail dataset**.
It covers **data loading, cleaning, transformation, dimensional modeling, RFM analysis,** and **sales analytics**.

This project is designed as a **portfolio-ready SQL analytics project**, following real-world data warehouse and analytics practices.

---

## 🧩 Dataset
**Source:** Online Retail Dataset (Kaggle Dataset)

### Key Columns
- InvoiceNo
- StockCode
- Description
- Quantity
- InvoiceDate
- UnitPrice
- CustomerID
- Country

---

## 🛠️ Tools & Technologies
- **Database:** MySQL 8.0
- **SQL Concepts:**  
  - Data Cleaning & Validation  
  - CTEs & Window Functions  
  - Star Schema Design  
  - Feature Engineering  
  - RFM Analysis  


---

## 📂 Project Structure

```
SQL_RETAIL_PROJECT/
│
├── schema.sql                -- Database & raw table creation
├── load_raw.sql              -- Load CSV data
├── clean_transform.sql       -- Data cleaning & validation
├── create_features.sql       -- Feature engineering (date parts, totals)
├── dimension_build.sql       -- Dimension tables
├── fact_build.sql            -- Fact table creation
├── rfm_analysis.sql          -- RFM segmentation
├── sales_analysis.sql        -- Sales KPIs & insights
├── README.md
```

---

## 🧱 Database Tables

### 🔹 Raw & Clean Tables
| Table Name | Description |
|-----------|------------|
| retail_raw | Raw imported data |
| cancelled_orders | Cancelled transactions (negative quantity) |
| retail_clean | Cleaned transactional data |
| final_clean_sales | Final clean sales with TotalAmount |

---

### 🔹 Dimension Tables
| Dimension | Description |
|----------|------------|
| customer_dim | Customer master |
| product_dim | Product master |
| country_dim | Country lookup |
| dim_date | Calendar date dimension |

---

### 🔹 Fact Table
| Table | Description |
|------|------------|
| fact_sales | Central sales fact table |

---
---

## 📊 Feature Engineering
Additional analytical features created:
- InvoiceYear
- InvoiceMonth
- InvoiceDay
- TotalAmount (Quantity × UnitPrice)

---

## 📈 RFM Analysis
RFM metrics calculated per customer:
- **Recency:** Days since last purchase
- **Frequency:** Number of unique invoices
- **Monetary:** Total spending

Customers are segmented using **NTILE scoring**.

---

## 📊 Sales Analysis
Key insights generated:
- Total revenue
- Monthly & yearly trends
- Top products
- Top countries
- Customer contribution analysis

---


## 🚀 How to Run the Project
1. Execute `schema.sql`
2. Load data using `load_raw.sql`
3. Clean data using `clean_transform.sql`
4. Create features using `create_features.sql`
5. Build dimensions using `dimension_build.sql`
6. Build fact table using `fact_build.sql`
7. Run analytics using:
   - `rfm_analysis.sql`
   - `sales_analysis.sql`


---

## 🎯 Learning Outcomes
- Real-world SQL project structure
- Data warehousing fundamentals
- Advanced SQL analytics
- Portfolio-grade analytics project

---

## 📌 Author
**Sonali Mayekar**  
MSc Data Science 
