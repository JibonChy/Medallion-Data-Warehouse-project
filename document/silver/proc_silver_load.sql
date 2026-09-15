/*
===========================================
    Silver Layer Loading Procedure
===========================================

Introduction:
    This stored procedure automates the transformation and loading
    of CRM and ERP data from the Bronze layer into the Silver layer.
    It applies cleaning, standardization, and enrichment rules to
    ensure data quality and consistency.

Purpose:
    - Truncate Silver tables before each load to avoid duplication.
    - Clean CRM customer data (trim names, normalize marital status/gender).
    - Standardize CRM product data (derive category IDs, normalize product lines).
    - Validate CRM sales details (fix dates, recalculate sales, correct prices).
    - Clean ERP customer data (normalize IDs, gender values).
    - Standardize ERP location data (map country codes to names).
    - Preserve ERP product category data with consistent naming.
    - Capture execution start/end timestamps for each table and batch.
    - Provide error handling with detailed messages for debugging.

Execute Procedure:
    EXEC proc_silver_layer_loding;
*/



CREATE OR ALTER PROCEDURE proc_silver_layer_loding AS

BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '=======================================================';
		PRINT '>>> START: CRM Silver Layer Loading';
		PRINT '=======================================================';


		-- Loading silver.crm_cust_info
		SET @start_time = GETDATE();
		PRINT '>>>Table Truncation: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT '>>>Data Insertion Process: silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info 
		(
				cst_id,
				cst_key,
				cst_firstname,
				cst_lastname,
				cst_marital_status,
				cst_gndr,
				cst_create_date
		)
		SELECT 
			cst_id,
			cst_key,
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) AS cst_lastname,
			CASE
				WHEN cst_marital_status = 'S' THEN 'Single'
				WHEN cst_marital_status = 'M' THEN 'Married'
				ELSE 'n/a'
			END AS cst_marital_status, --Normalize Marital Status — CASE Expression
			CASE
				WHEN cst_gndr = 'F' THEN 'Female'
				WHEN cst_gndr = 'M' THEN 'Male'
				ELSE 'n/a'
			END AS cst_gndr, --Normalize Gender
			cst_create_date
		FROM 
		(
			SELECT 
				*,
				ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS chacking_duplicate_flag
			FROM bronze.crm_cust_info
		)t
		WHERE chacking_duplicate_flag = 1; --Select Most Recent Record — ROW_NUMBER
		SET @end_time = GETDATE();
		PRINT '>>>Total Execution Duration (seconds):' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR);


		-- Loading silver.crm_prd_info
		SET @start_time = GETDATE();
		PRINT '>>>Table Truncation: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT '>>>Data Insertion Process: silver.crm_prd_info';
		INSERT INTO silver.crm_prd_info 
		(
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT
			prd_id,
			REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,  --Extract category ID
			SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key, --Extract product key
			prd_nm,
			COALESCE(prd_cost, 0) AS prd_cost,
			CASE prd_line
				WHEN 'M' THEN 'Mexo'
				WHEN 'R' THEN 'Rivo'
				WHEN 'S' THEN 'Sero'
				WHEN 'T' THEN 'Tivo'
				ELSE 'n/a'
			END prd_line, --Map Product Line
			CAST(prd_start_dt AS DATE) AS prd_start_dt,
			CAST(
				LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 
				AS DATE
			) AS prd_end_dt -- Calculate end date as one day before the next start date
		FROM bronze.crm_prd_info;
		SET @end_time = GETDATE();
		PRINT '>>>Total Execution Duration (seconds):' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR);


		-- Loading crm_sales_details
		SET @start_time = GETDATE();
		PRINT '>>>Table Truncation: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT '>>>Data Insertion Process: silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details
		(
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)

		SELECT 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			TRY_CAST(sls_order_dt AS DATE) AS sls_order_dt,
			TRY_CAST(sls_ship_dt AS DATE) AS sls_ship_dt,
			TRY_CAST(sls_due_dt AS DATE) AS sls_due_dt,
			CASE 
				WHEN sls_sales IS NULL OR sls_sales != sls_quantity * ABS(sls_price)
				THEN sls_quantity * ABS(sls_price)
				ELSE sls_sales
			END AS sls_sales, --Recalculate Sales — Handle Missing or Incorrect Values
			sls_quantity,
			CASE 
				WHEN sls_price IS NULL OR sls_price <=0
					THEN sls_sales / NULLIF(sls_quantity, 0)
				ELSE sls_price
			END AS sls_price-- Derive Price — Handle Invalid Values
		FROM bronze.crm_sales_details;
		SET @end_time = GETDATE();
		PRINT '>>>Total Execution Duration (seconds):' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR);


		SET @batch_end_time = GETDATE();
		PRINT '=======================================================';
		PRINT '>>> END:  CRM Silver Loading Completed Successfully';
		PRINT '>>>Total CRM Silver Layer Loading Duration (seconds): ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR);
		PRINT '=======================================================';


		PRINT'';
		PRINT'-----------------------------------------------------------';
		PRINT'';



		SET @batch_start_time = GETDATE();
		PRINT '=======================================================';
		PRINT '>>> START: ERP Silver Layer Loading';
		PRINT '=======================================================';

		-- Loading erp_cust_az12
		SET @start_time = GETDATE();
		PRINT '>>>Table Truncation: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT '>>>Data Insertion Process: silver.erp_cust_az12';
		INSERT INTO silver.erp_cust_az12 
		(
			cid,
			bdate,
			gen
		)
		SELECT 
			CASE 
				WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) --Remove NAS Prefix
				ELSE cid
			END AS cid,
			bdate AS bdate,
			CASE
				WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
				WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
				ELSE 'n/a'
			END AS gen --Normalize Gender — Handle Unknown Values
		FROM bronze.erp_cust_az12;
		SET @end_time = GETDATE();
		PRINT '>>>Total Execution Duration (seconds):' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR);


		-- Loading erp_loc_a101
		SET @start_time = GETDATE();
		PRINT '>>>Table Truncation: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;
		PRINT '>>>Data Insertion Process: silver.erp_loc_a101';
		INSERT INTO silver.erp_loc_a101
		(
			cid,
			cntry
		)
		SELECT
			REPLACE(cid, '-', '') AS cid,
			CASE
				WHEN TRIM(cntry) = 'DE' THEN 'Germany'
				WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
				WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
				ELSE TRIM(cntry)
			END AS cntry --Normalize Country Codes — Handle Missing Values
		FROM bronze.erp_loc_a101;
		SET @end_time = GETDATE();
		PRINT '>>>Total Execution Duration (seconds):' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR);


		-- Loading erp_px_cat_g1v2
		SET @start_time = GETDATE();
		PRINT '>>>Table Truncation: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		PRINT '>>>Data Insertion Process: silver.erp_px_cat_g1v2';
		INSERT INTO silver.erp_px_cat_g1v2
		(
			id,
			cat,
			subcat,
			maintenance
		)
		SELECT 
			id,
			cat,
			subcat,
			maintenance
		FROM bronze.erp_px_cat_g1v2;
		SET @end_time = GETDATE();
		PRINT '>>>Total Execution Duration (seconds):' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR);



		SET @batch_end_time = GETDATE();
		PRINT '=======================================================';
		PRINT '>>> END:  ERP Silver Layer Loading Completed Successfully';
		PRINT '>>>Total ERP Silver Layer Loading Duration (seconds): ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR);
		PRINT '=======================================================';

	END TRY

	BEGIN CATCH
		PRINT '===========================================';
		PRINT '❌ ERROR OCCURRED DURING EXECUTION';
		PRINT 'Error Message   : ' + ERROR_MESSAGE();   --- main error text
		PRINT 'Error Number    : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error State     : ' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT 'Error Line      : ' + CAST(ERROR_LINE() AS NVARCHAR);
		PRINT '===========================================';
	END CATCH;
END;

EXEC proc_silver_layer_loding;
