/*
===========================================
     Silver Layer DDL — CRM & ERP
===========================================

Introduction:
    This script defines the Silver layer tables for CRM and ERP data.
    Silver is the cleaned and standardized zone where raw Bronze data
    is transformed into consistent, reliable structures.

Purpose:
    - Create CRM Silver tables (cust_info, prd_info, sales_details).
    - Create ERP Silver tables (cust_az12, loc_a101, px_cat_g1v2).
    - Add dwh_create_date for audit and lineage tracking.
    - Ensure data quality with standardized column definitions.
    - Provide a foundation for Gold layer aggregation and analytics.
*/


IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_cust_info;
GO

CREATE TABLE silver.crm_cust_info
(
    cst_id                 INT,
    cst_key                NVARCHAR(45),
    cst_firstname          NVARCHAR(45),
    cst_lastname           NVARCHAR(45),
    cst_marital_status     NVARCHAR(45),
    cst_gndr               NVARCHAR(45),
    cst_create_date        DATE,
    dwh_create_date        DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;
GO

CREATE TABLE silver.crm_prd_info
(
    prd_id                 INT,
    cat_id                 NVARCHAR(45),
    prd_key                NVARCHAR(45),
    prd_nm                 NVARCHAR(45),
    prd_cost               INT,
    prd_line               NVARCHAR(45),
    prd_start_dt           DATE,
    prd_end_dt             DATE,
    dwh_create_date        DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;
GO

CREATE TABLE silver.crm_sales_details
(
    sls_ord_num            NVARCHAR(45),
    sls_prd_key            NVARCHAR(45),
    sls_cust_id            INT,
    sls_order_dt           DATE,
    sls_ship_dt            DATE,
    sls_due_dt             DATE,
    sls_sales              INT,
    sls_quantity           INT,
    sls_price              INT,
    dwh_create_date        DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE silver.erp_cust_az12;
GO

CREATE TABLE silver.erp_cust_az12
(
    cid                    NVARCHAR(45),
    bdate                  DATE,
    gen                    NVARCHAR(45),
    dwh_create_date        DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE silver.erp_loc_a101;
GO

CREATE TABLE silver.erp_loc_a101
(
    cid                    NVARCHAR(45),
    cntry                  NVARCHAR(45),
    dwh_create_date        DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE silver.erp_px_cat_g1v2;
GO

CREATE TABLE silver.erp_px_cat_g1v2
(
    id                     NVARCHAR(45),
    cat                    NVARCHAR(45),
    subcat                 NVARCHAR(45),
    maintainance            NVARCHAR(45),
    dwh_create_date        DATETIME2 DEFAULT GETDATE()
);
