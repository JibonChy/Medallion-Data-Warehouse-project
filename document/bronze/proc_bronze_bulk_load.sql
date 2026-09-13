/*
===========================================
       Bronze Bulk Load Procedure
===========================================

Introduction:
    This stored procedure automates the bulk loading of raw CRM and ERP
    source files into the Bronze schema. It ensures that all customer,
    product, and sales data is ingested directly from CSV files.

Purpose:
    - Truncate existing Bronze tables before each load to avoid duplication.
    - Perform BULK INSERT operations for CRM (cust_info, prd_info, sales_details).
    - Perform BULK INSERT operations for ERP (cust_az12, loc_a101, px_cat_g1v2).
    - Capture execution start/end timestamps for each table and batch.
    - Print total execution duration for CRM and ERP loads.
    - Provide error handling with detailed messages for debugging.

Execute Procedure:
    - EXEC bronze_bulk_load;
*/



CREATE OR ALTER PROCEDURE bronze_bulk_load AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '=======================================================';
		PRINT '>>> START: Raw CRM Bronze Loading';
		PRINT '=======================================================';

		SET @start_time = GETDATE();
		PRINT '>>>Table Truncation: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;
		PRINT '>>>Data Insertion Process: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'D:\project_data\source_crm\cust_info.csv'
		WITH
		(
			FIELDTERMINATOR = ',',
			FIRSTROW = 2,
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>>>Total Execution Duration (seconds):' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR);


		SET @start_time = GETDATE();
		PRINT '>>>Table Truncation: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;
		PRINT '>>>Data Insertion Process: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'D:\project_data\source_crm\prd_info.csv'
		WITH
		(
			FIELDTERMINATOR = ',',
			FIRSTROW = 2,
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>>>Total Execution Duration (seconds):' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR);


		SET @start_time = GETDATE();
		PRINT '>>>Table Truncation: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;
		PRINT '>>>Data Insertion Process: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'D:\project_data\source_crm\sales_details.csv'
		WITH
		(
			FIELDTERMINATOR = ',',
			FIRSTROW = 2,
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>>>Total Execution Duration (seconds):' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR);


		SET @batch_end_time = GETDATE();
		PRINT '=======================================================';
		PRINT '>>> END: Raw CRM Bronze Loading Completed Successfully';
		PRINT '>>>Total CRM Bronze Loading Duration (seconds): ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR);
		PRINT '=======================================================';


		PRINT'';
		PRINT'-----------------------------------------------------------';
		PRINT'';

		SET @batch_start_time = GETDATE();
		PRINT '=======================================================';
		PRINT '>>> START: Raw ERP Bronze Loading';
		PRINT '=======================================================';


		SET @start_time = GETDATE();
		PRINT '>>>Table Truncation: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;
		PRINT '>>>Data Insertion Process: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'D:\project_data\source_erp\CUST_AZ12.csv'
		WITH
		(
			FIELDTERMINATOR = ',',
			FIRSTROW = 2,
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>>>Total Execution Duration (seconds):' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR);


		SET @start_time = GETDATE();
		PRINT '>>>Table Truncation: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;
		PRINT '>>>Data Insertion Process: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'D:\project_data\source_erp\LOC_A101.csv'
		WITH
		(
			FIELDTERMINATOR = ',',
			FIRSTROW = 2,
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>>>Total Execution Duration (seconds):' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR);


		SET @start_time = GETDATE();
		PRINT '>>>Table Truncation: bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		PRINT '>>>Data Insertion Process: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'D:\project_data\source_erp\PX_CAT_G1V2.csv'
		WITH
		(
			FIELDTERMINATOR = ',',
			FIRSTROW = 2,
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>>>Total Execution Duration (seconds):' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR);


		SET @batch_end_time = GETDATE();
		PRINT '=======================================================';
		PRINT '>>> END: Raw ERP Bronze Loading Completed Successfully';
		PRINT '>>>Total ERP Bronze Loading Duration (seconds): ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR);
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

EXEC bronze_bulk_load;
