/*
================================================================================
Quality Checking — Gold Layer
================================================================================
Script Purpose:
    This script validates the integrity, consistency, and accuracy of the Gold 
    Layer. It ensures:
      • Surrogate keys in dimension tables are unique.
      • Referential integrity between fact and dimension tables.
      • Logical relationships in the data model support reliable analytics.

Usage Notes:
    • Run these checks after Gold Layer views/tables are created.
    • Any results returned indicate anomalies that must be investigated.
    • Corrections should be applied upstream to maintain trusted datasets.
================================================================================
*/



-- ====================================================================
--  Dimension Validation: gold.dim_customers
-- ====================================================================
-- Ensure uniqueness of surrogate keys in customer dimension
-- Expectation: No results
SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;



-- ====================================================================
--  Dimension Validation: gold.dim_products
-- ====================================================================
-- Ensure uniqueness of surrogate keys in product dimension
-- Expectation: No results
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;



-- ====================================================================
--  Fact Validation: gold.fact_sales
-- ====================================================================
-- Validate referential integrity between fact and dimension tables
-- Expectation: No missing references
SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
WHERE p.product_key IS NULL 
   OR c.customer_key IS NULL;
