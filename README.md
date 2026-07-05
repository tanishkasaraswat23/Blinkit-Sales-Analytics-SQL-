# 🛒 Blinkit Sales Analytics using SQL

An end-to-end SQL project analyzing grocery sales data from Blinkit (India's quick-commerce platform). This project covers the complete analytics workflow — from raw data cleaning to solving real business questions using intermediate-to-advanced SQL techniques.

---

## 📌 Project Overview

Using a dataset of **8,523 sales records**, this project answers key business questions that a Business Intelligence / Data Analyst would typically be asked to solve — such as identifying top-performing product categories, comparing outlet types, and analyzing revenue trends across store locations and establishment years.

The final output includes a SQL **View** that is directly connected to **Power BI** for dashboard reporting.

---

## 🛠️ Tools & Technologies

- **Database:** MySQL 8.0
- **IDE:** MySQL Workbench
- **Dataset:** Blinkit Grocery Sales Data (Kaggle)
- **Visualization:** Power BI (connected via SQL View)

---

## 🧹 Data Cleaning

- Standardized inconsistent categorical values (`Low Fat`, `low fat`, `LF` → `Low Fat`)
- Handled 1,463 missing values in the `Item Weight` column using mean imputation (grouped by item type)
- Renamed and restructured raw columns into a clean, query-ready table (`blinkit_cleaned`)

---

## ❓ Business Questions Solved

1. What is the total revenue generated?
2. What is the average sale value per item?
3. Which item category generates the highest revenue?
4. Which outlet type performs best?
5. How does revenue vary across city tiers (Tier 1/2/3)?
6. Does outlet size impact sales performance?
7. What are the top 10 best-selling items?
8. What are the bottom 10 worst-performing items?
9. Which outlets are the highest revenue generators?
10. Do older outlets outperform newer ones?
11. Do Low Fat items sell better than Regular items?

---

## 🔑 Key Insights

- **Total Revenue:** ₹12,01,681.49 across all outlets
- **Fruits & Vegetables** and **Snack Foods** are the top-grossing categories
- **Supermarket Type1** outlets generate ~65% of total revenue alone
- **Tier 3** cities outperform Tier 1 and Tier 2 in total sales — indicating strong demand in smaller cities
- **Low Fat** items generate ~65% more revenue than Regular items
- One outlet (established in 2018) significantly outperforms all others in revenue

---

## 💡 SQL Concepts Used

| Concept | Example Use |
|---|---|
| Data Cleaning | `CASE WHEN`, `UPDATE`, `NULLIF` |
| Aggregation | `SUM`, `AVG`, `COUNT`, `GROUP BY`, `HAVING` |
| Joins | `INNER JOIN` between sales and outlet dimension tables |
| Subqueries | Filtering items above average sale value |
| CTEs | `WITH ... AS` for readable, layered logic |
| Window Functions | `RANK() OVER (PARTITION BY ...)`, running totals |
| Views | Created a reusable view for Power BI integration |

---

## 📁 Repository Structure

```
Blinkit-Sales-Analytics-SQL/
│
├── Blinkit_Sales_Analytics_Project.sql   # Complete SQL script
├── README.md                              # Project documentation
└── screenshots/                           # Query results (optional)
```

---

## 🚀 How to Run

1. Clone this repository
2. Import the dataset into MySQL (`blinkit_data` table)
3. Open `Blinkit_Sales_Analytics_Project.sql` in MySQL Workbench
4. Run the script section by section (Data Cleaning → Business Questions → Joins → CTEs → Window Functions → Views)

---

## 🔗 Connected Dashboard

The `vw_outlet_performance` view created in this project powers a Power BI dashboard, available here: https://github.com/tanishkasaraswat23/Blinkit-Sales-Dashboard---POWER-BI-

---

## 👩‍💻 Author

**Tanishka Saraswat**

[LinkedIn: www.linkedin.com/in/tanishka-saraswat] | [Github:tanishkasaraswat23]
