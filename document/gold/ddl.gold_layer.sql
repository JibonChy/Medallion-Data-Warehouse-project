/*
===========================================
 Gold Schema Creation — Dimensions & Facts
===========================================

Introduction:
    This script defines the Gold layer views for dimensional modeling.
    Gold is the curated reporting zone where cleaned Silver data is
    transformed into business‑ready dimensions and fact tables.

Purpose:
    - Create Dimension: gold.dim_customers
        • Surrogate key assignment
        • Merge CRM + ERP attributes (gender, country, birthdate)
    - Create Dimension: gold.dim_products
        • Surrogate key assignment
        • Map product categories and subcategories
        • Filter out historical products
    - Create Fact Table: gold.fact_sales
        • Link measures (sales, quantity, price) to dimensions
        • Provide order timeline attributes (order, ship, due dates)
    - Enable analytics, dashboards, and reporting with standardized keys.
*/



-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY ci.cst_key) AS customer_key,
    ci.cst_id               AS customer_id,
    ci.cst_key              AS customer_number,
    ci.cst_firstname        AS first_name,
    ci.cst_lastname         AS last_name,
    ci.cst_marital_status   AS marital_status,
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE ca.gen
    END                     AS gender,
    ca.bdate                AS birthday,
    la.cntry                AS country,
    ci.cst_create_date      AS customer_create_date
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
    ON ci.cst_key = la.cid;



-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================

IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY pri.prd_id) AS product_key,
    pri.prd_id              AS product_id,
    pri.cat_id              AS category_id,
    pri.prd_key             AS product_number,
    pri.prd_nm              AS product_name,
    pc.cat                  AS category,
    pc.subcat               AS subcat,
    pc.maintainance         AS maintainance,
    pri.prd_cost            AS product_cost,
    pri.prd_line            AS product_line,
    pri.prd_end_dt          AS product_end_date
FROM silver.crm_prd_info AS pri
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
    ON pc.id = pri.cat_id
WHERE pri.prd_end_dt IS NULL;   -- Filter out historical products



-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================

IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT 
    sd.sls_ord_num          AS order_number,
    c.customer_key,
    p.product_key,
    sd.sls_order_dt         AS order_date,
    sd.sls_ship_dt          AS shipping_date,
    sd.sls_due_dt           AS due_date,
    sd.sls_sales            AS sales,
    sd.sls_quantity         AS sales_quantity,
    sd.sls_price            AS price
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_customers AS c
    ON c.customer_id = sd.sls_cust_id
LEFT JOIN gold.dim_products AS p
    ON p.product_number = sd.sls_prd_key;
