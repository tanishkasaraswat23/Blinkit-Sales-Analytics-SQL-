-- ============================================================
-- BLINKIT SALES ANALYTICS PROJECT (SQL)
-- Author: Tanishka Saraswat
-- ============================================================

USE blinkit_sales_db;

-- ============================================================
-- SECTION 1: DATA CLEANING
-- ============================================================

-- 1.1 Create a clean table with proper column names & data types
DROP TABLE IF EXISTS blinkit_cleaned;

CREATE TABLE blinkit_cleaned AS
SELECT
    `Item Identifier`                          AS item_id,
    CASE
        WHEN LOWER(TRIM(`Item Fat Content`)) IN ('low fat','lf') THEN 'Low Fat'
        WHEN LOWER(TRIM(`Item Fat Content`)) IN ('regular','reg') THEN 'Regular'
        ELSE `Item Fat Content`
    END                                         AS item_fat_content,
    `Item Type`                                 AS item_type,
    CAST(NULLIF(TRIM(`Item Weight`), '') AS DECIMAL(10,3)) AS item_weight,
    `Item Visibility`                           AS item_visibility,
    `Outlet Identifier`                         AS outlet_id,
    CAST(`Outlet Establishment Year` AS UNSIGNED) AS outlet_est_year,
    `Outlet Size`                               AS outlet_size,
    `Outlet Location Type`                      AS outlet_location_type,
    `Outlet Type`                                AS outlet_type,
    `Sales`                                      AS sales,
    `Rating`                                     AS rating
FROM blinkit_data;

-- 1.2 Quick sanity check
SELECT COUNT(*) AS total_rows FROM blinkit_cleaned;
SELECT * FROM blinkit_cleaned LIMIT 10;

-- 1.3 Check how many item_weight values are still NULL (missing)
SELECT COUNT(*) AS missing_weights FROM blinkit_cleaned WHERE item_weight IS NULL;

-- 1.4 Fill missing item_weight with the AVERAGE weight of that same item_type
--     (common real-world technique: mean imputation)
UPDATE blinkit_cleaned b
JOIN (
    SELECT item_type, AVG(item_weight) AS avg_weight
    FROM blinkit_cleaned
    WHERE item_weight IS NOT NULL
    GROUP BY item_type
) avg_table ON b.item_type = avg_table.item_type
SET b.item_weight = avg_table.avg_weight
WHERE b.item_weight IS NULL;

-- 1.5 Confirm no more missing weights
SELECT COUNT(*) AS missing_weights_after_fix FROM blinkit_cleaned WHERE item_weight IS NULL;

-- 1.6 Standardize outlet_size blanks (if any) to 'Unknown'
UPDATE blinkit_cleaned
SET outlet_size = 'Unknown'
WHERE outlet_size IS NULL OR TRIM(outlet_size) = '';


-- ============================================================
-- SECTION 2: BUSINESS QUESTIONS (Core SQL: SELECT, WHERE, GROUP BY, ORDER BY)
-- ============================================================

-- Q1: What is the total revenue generated?
SELECT ROUND(SUM(sales), 2) AS total_revenue
FROM blinkit_cleaned;

-- Q2: What is the average sale value per item sold?
SELECT ROUND(AVG(sales), 2) AS avg_sale_value
FROM blinkit_cleaned;

-- Q3: Which Item Type generates the highest total revenue?
SELECT item_type, ROUND(SUM(sales), 2) AS total_revenue
FROM blinkit_cleaned
GROUP BY item_type
ORDER BY total_revenue DESC;

-- Q4: Which Outlet Type performs best in terms of revenue?
SELECT outlet_type, ROUND(SUM(sales), 2) AS total_revenue
FROM blinkit_cleaned
GROUP BY outlet_type
ORDER BY total_revenue DESC;

-- Q5: How does revenue vary by city Tier (Outlet Location Type)?
SELECT outlet_location_type, ROUND(SUM(sales), 2) AS total_revenue
FROM blinkit_cleaned
GROUP BY outlet_location_type
ORDER BY total_revenue DESC;

-- Q6: How does Outlet Size impact sales performance?
SELECT outlet_size, ROUND(SUM(sales), 2) AS total_revenue, ROUND(AVG(sales), 2) AS avg_sale
FROM blinkit_cleaned
GROUP BY outlet_size
ORDER BY total_revenue DESC;

-- Q7: Top 10 best-selling individual items (by total sales)
SELECT item_id, item_type, ROUND(SUM(sales), 2) AS total_sales
FROM blinkit_cleaned
GROUP BY item_id, item_type
ORDER BY total_sales DESC
LIMIT 10;

-- Q8: Bottom 10 worst-performing items
SELECT item_id, item_type, ROUND(SUM(sales), 2) AS total_sales
FROM blinkit_cleaned
GROUP BY item_id, item_type
ORDER BY total_sales ASC
LIMIT 10;

-- Q9: Which outlets (stores) generate the most revenue? (using HAVING)
SELECT outlet_id, ROUND(SUM(sales), 2) AS total_revenue
FROM blinkit_cleaned
GROUP BY outlet_id
HAVING total_revenue > 200000
ORDER BY total_revenue DESC;

-- Q10: Do older outlets sell more than newer ones?
SELECT outlet_est_year, ROUND(SUM(sales), 2) AS total_revenue
FROM blinkit_cleaned
GROUP BY outlet_est_year
ORDER BY outlet_est_year;

-- Q11: Regular vs Low Fat items -- which sells more?
SELECT item_fat_content, ROUND(SUM(sales), 2) AS total_revenue, COUNT(*) AS num_items_sold
FROM blinkit_cleaned
GROUP BY item_fat_content
ORDER BY total_revenue DESC;


-- ============================================================
-- SECTION 3: JOINS (simulating a normalized structure)
-- ============================================================

-- 3.1 Create a separate "outlets" summary table (like a dimension table)
DROP TABLE IF EXISTS outlets_summary;
CREATE TABLE outlets_summary AS
SELECT DISTINCT outlet_id, outlet_size, outlet_location_type, outlet_type, outlet_est_year
FROM blinkit_cleaned;

-- 3.2 INNER JOIN: combine sales data with outlet info
SELECT bc.outlet_id, os.outlet_type, os.outlet_location_type, ROUND(SUM(bc.sales),2) AS total_sales
FROM blinkit_cleaned bc
INNER JOIN outlets_summary os ON bc.outlet_id = os.outlet_id
GROUP BY bc.outlet_id, os.outlet_type, os.outlet_location_type
ORDER BY total_sales DESC;


-- ============================================================
-- SECTION 4: SUBQUERIES & CTEs
-- ============================================================

-- 4.1 Subquery: Items that sell above the overall average sale value
SELECT item_id, item_type, sales
FROM blinkit_cleaned
WHERE sales > (SELECT AVG(sales) FROM blinkit_cleaned)
ORDER BY sales DESC
LIMIT 10;

-- 4.2 CTE: Revenue by item type, then filter top categories only
WITH revenue_by_type AS (
    SELECT item_type, SUM(sales) AS total_revenue
    FROM blinkit_cleaned
    GROUP BY item_type
)
SELECT *
FROM revenue_by_type
WHERE total_revenue > 150000
ORDER BY total_revenue DESC;


-- ============================================================
-- SECTION 5: WINDOW FUNCTIONS
-- ============================================================

-- 5.1 Rank items within each Item Type by sales (top performer per category)
SELECT item_id, item_type, sales,
       RANK() OVER (PARTITION BY item_type ORDER BY sales DESC) AS rank_in_category
FROM blinkit_cleaned;

-- 5.2 Running total of revenue by outlet (ordered by outlet_id)
SELECT outlet_id,
       ROUND(SUM(sales),2) AS outlet_revenue,
       ROUND(SUM(SUM(sales)) OVER (ORDER BY outlet_id), 2) AS running_total
FROM blinkit_cleaned
GROUP BY outlet_id;


-- ============================================================
-- SECTION 6: VIEWS (for BI tool / Power BI connection)
-- ============================================================

DROP VIEW IF EXISTS vw_outlet_performance;
CREATE VIEW vw_outlet_performance AS
SELECT outlet_id, outlet_type, outlet_size, outlet_location_type,
       ROUND(SUM(sales), 2) AS total_revenue,
       ROUND(AVG(sales), 2) AS avg_sale_value,
       COUNT(*) AS items_sold
FROM blinkit_cleaned
GROUP BY outlet_id, outlet_type, outlet_size, outlet_location_type;

-- Test the view (this is what Power BI would connect to)
SELECT * FROM vw_outlet_performance ORDER BY total_revenue DESC;
