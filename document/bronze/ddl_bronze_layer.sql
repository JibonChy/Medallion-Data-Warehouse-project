/*
===========================================
     CRM & ERP Bronze Schema Creation
===========================================

Introduction:
    This script builds the Bronze layer tables for CRM and ERP data.
    Bronze is the raw landing zone where source data is ingested
    without transformations, ensuring full traceability.

Purpose:
    - Define raw CRM tables (cust_info, prd_info, sales_details).
    - Define raw ERP tables (cust_az12, loc_a101, px_cat_g1v2).
    - Preserve original source structure and column definitions.
    - Provide a foundation for Silver layer cleaning and enrichment.
*/

IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;
GO

CREATE TABLE bronze.crm_cust_info
(
    cst_id                 INT,
    cst_key                NVARCHAR(45),
    cst_firstname          NVARCHAR(45),
    cst_lastname           NVARCHAR(45),
    cst_marital_status     NVARCHAR(45),
    cst_gndr               NVARCHAR(45),
    cst_create_date        DATE
);

IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;
GO

CREATE TABLE bronze.crm_prd_info
(
    prd_id                 INT,
    prd_key                NVARCHAR(45),
    prd_nm                 NVARCHAR(45),
    prd_cost               INT,
    prd_line               NVARCHAR(45),
    prd_start_dt           DATETIME,
    prd_end_dt             DATETIME
);

IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;
GO

CREATE TABLE bronze.crm_sales_details
(
    sls_ord_num            NVARCHAR(45),
    sls_prd_key            NVARCHAR(45),
    sls_cust_id            INT,
    sls_order_dt           NVARCHAR(45),
    sls_ship_dt            NVARCHAR(45),
    sls_due_dt             NVARCHAR(45),
    sls_sales              INT,
    sls_quantity           INT,
    sls_price              INT
);

IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;
GO

CREATE TABLE bronze.erp_cust_az12
(
    cid                    NVARCHAR(45),
    btate                  DATE,
    gen                    NVARCHAR(45)
);

IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;
GO

CREATE TABLE bronze.erp_loc_a101
(
    cid                    NVARCHAR(45),
    cntry                  NVARCHAR(45)
);

IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;
GO

CREATE TABLE bronze.erp_px_cat_g1v2
(
    id                     NVARCHAR(45),
    cat                    NVARCHAR(45),
    subcat                 NVARCHAR(45),
    maintenance            NVARCHAR(45)
);
